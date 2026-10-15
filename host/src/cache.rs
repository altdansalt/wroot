//! Compiled-module cache: in memory (keyed by content hash) and on disk
//! (`Module::serialize` artifacts, keyed by content hash + engine
//! compatibility hash) so 30-100 MB toolchain modules are compiled once.

use anyhow::{Context, Result};
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
use std::path::{Path, PathBuf};
use std::sync::Mutex;
use std::time::{Instant, SystemTime};
use wasmtime::{Engine, Module};

/// How a module was obtained; reported in job status for measurement.
#[derive(Clone, Copy, Debug, serde::Serialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum CacheResult {
    Memory,
    Disk,
    Compiled,
}

pub struct ModuleCache {
    engine: Engine,
    dir: PathBuf,
    engine_tag: String,
    mem: Mutex<HashMap<String, Module>>,
    /// (path, size, mtime) -> content hash, to avoid re-hashing big files.
    hashes: Mutex<HashMap<(PathBuf, u64, SystemTime), String>>,
    /// Serializes compilation so two jobs don't compile the same 100 MB
    /// module concurrently (and to bound memory on small VMs).
    compile_lock: Mutex<()>,
}

pub struct Loaded {
    pub module: Module,
    pub cache: CacheResult,
    pub load_ms: f64,
}

impl ModuleCache {
    pub fn new(engine: &Engine, dir: PathBuf) -> Result<Self> {
        std::fs::create_dir_all(&dir).with_context(|| format!("create {}", dir.display()))?;
        let mut h = std::collections::hash_map::DefaultHasher::new();
        engine.precompile_compatibility_hash().hash(&mut h);
        Ok(Self {
            engine: engine.clone(),
            dir,
            engine_tag: format!("{:016x}", h.finish()),
            mem: Mutex::new(HashMap::new()),
            hashes: Mutex::new(HashMap::new()),
            compile_lock: Mutex::new(()),
        })
    }

    fn content_hash(&self, path: &Path) -> Result<String> {
        let md = std::fs::metadata(path).with_context(|| format!("stat {}", path.display()))?;
        let key = (path.to_path_buf(), md.len(), md.modified()?);
        if let Some(h) = self.hashes.lock().unwrap().get(&key) {
            return Ok(h.clone());
        }
        let bytes = std::fs::read(path)?;
        let h = hex::encode(Sha256::digest(&bytes));
        self.hashes.lock().unwrap().insert(key, h.clone());
        Ok(h)
    }

    pub fn load(&self, path: &Path) -> Result<Loaded> {
        let t0 = Instant::now();
        let hash = self.content_hash(path)?;
        let done = |module, cache| Loaded {
            module,
            cache,
            load_ms: t0.elapsed().as_secs_f64() * 1e3,
        };
        if let Some(m) = self.mem.lock().unwrap().get(&hash) {
            return Ok(done(m.clone(), CacheResult::Memory));
        }
        let _g = self.compile_lock.lock().unwrap();
        if let Some(m) = self.mem.lock().unwrap().get(&hash) {
            return Ok(done(m.clone(), CacheResult::Memory));
        }
        let cpath = self.dir.join(format!("{hash}-{}.cwasm", self.engine_tag));
        if cpath.exists() {
            // SAFETY: files in the cache dir are only written by this
            // process (below) from `Module::serialize`; the cache dir is
            // outside anything a guest can write to (see HOST_CAPABILITIES).
            match unsafe { Module::deserialize_file(&self.engine, &cpath) } {
                Ok(m) => {
                    self.mem.lock().unwrap().insert(hash, m.clone());
                    return Ok(done(m, CacheResult::Disk));
                }
                Err(e) => eprintln!("wasmdev-host: bad cache entry {}: {e:#}", cpath.display()),
            }
        }
        let bytes = std::fs::read(path).with_context(|| format!("read {}", path.display()))?;
        let m = Module::new(&self.engine, &bytes)
            .map_err(anyhow::Error::from)
            .with_context(|| format!("compile {}", path.display()))?;
        match m.serialize() {
            Ok(ser) => {
                let tmp = cpath.with_extension(format!("tmp{}", std::process::id()));
                if std::fs::write(&tmp, &ser).and_then(|_| std::fs::rename(&tmp, &cpath)).is_err() {
                    let _ = std::fs::remove_file(&tmp);
                }
            }
            Err(e) => eprintln!("wasmdev-host: serialize failed: {e:#}"),
        }
        self.mem.lock().unwrap().insert(hash, m.clone());
        Ok(done(m, CacheResult::Compiled))
    }
}
