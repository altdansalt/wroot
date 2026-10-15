//! Compiled-module cache: in memory (keyed by content hash) and on disk
//! (`Module::serialize` artifacts, keyed by content hash + engine
//! compatibility hash) so 30-100 MB toolchain modules are compiled once.
//! Handles both core modules (wasip1) and components (wasip2); the kind is
//! detected from the binary header.

use anyhow::{Context, Result};
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
use std::path::{Path, PathBuf};
use std::sync::Mutex;
use std::time::{Instant, SystemTime};
use wasmtime::component::Component;
use wasmtime::{Engine, Module};

/// How a module was obtained; reported in job status for measurement.
#[derive(Clone, Copy, Debug, serde::Serialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum CacheResult {
    Memory,
    Disk,
    Compiled,
}

/// A compiled core module or component.
#[derive(Clone)]
pub enum Compiled {
    Module(Module),
    Component(Component),
}

/// True if the file at `path` is a component (header layer field = 1).
/// Core modules: `\0asm 01 00 00 00`; components: `\0asm 0d 00 01 00`.
pub fn is_component_file(path: &Path) -> Result<bool> {
    use std::io::Read;
    let mut h = [0u8; 8];
    std::fs::File::open(path)
        .and_then(|mut f| f.read_exact(&mut h))
        .with_context(|| format!("read header of {}", path.display()))?;
    if &h[..4] != b"\0asm" {
        anyhow::bail!("{}: not a wasm binary", path.display());
    }
    Ok(header_is_component(&h))
}

pub struct ModuleCache {
    engine: Engine,
    dir: PathBuf,
    engine_tag: String,
    mem: Mutex<HashMap<String, Compiled>>,
    /// (path, size, mtime) -> (content hash, is component), to avoid
    /// re-hashing big files.
    hashes: Mutex<HashMap<(PathBuf, u64, SystemTime), (String, bool)>>,
    /// Serializes compilation so two jobs don't compile the same 100 MB
    /// module concurrently (and to bound memory on small VMs).
    compile_lock: Mutex<()>,
}

pub struct Loaded {
    pub module: Compiled,
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

    fn content_hash(&self, path: &Path) -> Result<(String, bool)> {
        let md = std::fs::metadata(path).with_context(|| format!("stat {}", path.display()))?;
        let key = (path.to_path_buf(), md.len(), md.modified()?);
        if let Some(h) = self.hashes.lock().unwrap().get(&key) {
            return Ok(h.clone());
        }
        let bytes = std::fs::read(path)?;
        let h = (hex::encode(Sha256::digest(&bytes)), header_is_component(&bytes));
        self.hashes.lock().unwrap().insert(key, h.clone());
        Ok(h)
    }

    pub fn load(&self, path: &Path) -> Result<Loaded> {
        let t0 = Instant::now();
        let (hash, component) = self.content_hash(path)?;
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
            let r = if component {
                unsafe { Component::deserialize_file(&self.engine, &cpath) }.map(Compiled::Component)
            } else {
                unsafe { Module::deserialize_file(&self.engine, &cpath) }.map(Compiled::Module)
            };
            match r {
                Ok(m) => {
                    self.mem.lock().unwrap().insert(hash, m.clone());
                    return Ok(done(m, CacheResult::Disk));
                }
                Err(e) => eprintln!("wasmdev-host: bad cache entry {}: {e:#}", cpath.display()),
            }
        }
        let bytes = std::fs::read(path).with_context(|| format!("read {}", path.display()))?;
        let m = if component {
            Component::new(&self.engine, &bytes).map(Compiled::Component)
        } else {
            Module::new(&self.engine, &bytes).map(Compiled::Module)
        }
        .map_err(anyhow::Error::from)
        .with_context(|| format!("compile {}", path.display()))?;
        drop(bytes);
        let ser = match &m {
            Compiled::Module(m) => m.serialize(),
            Compiled::Component(c) => c.serialize(),
        };
        match ser {
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

fn header_is_component(bytes: &[u8]) -> bool {
    bytes.len() >= 8 && bytes[6..8] == [1, 0]
}
