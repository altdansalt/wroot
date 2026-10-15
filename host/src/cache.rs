//! Compiled-module cache: in memory (keyed by content hash) and on disk
//! (`Module::serialize` artifacts, keyed by content hash + engine
//! compatibility hash) so 30-100 MB toolchain modules are compiled once.
//! Handles both core modules (wasip1) and components (wasip2); the kind is
//! detected from the binary header.

use anyhow::{Context, Result};
use sha2::{Digest, Sha256};
use crate::rt::Rt;
use std::collections::{HashMap, VecDeque};
use std::path::{Path, PathBuf};
use std::sync::Mutex;
use std::time::{Instant, SystemTime};
use wasmtime::component::Component;
use wasmtime::Module;

/// Memory-only ("ephemeral") entries kept at most; oldest evicted first.
const MAX_EPHEMERAL: usize = 32;

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
    dir: PathBuf,
    /// (runtime id, content hash) -> compiled module (engine-bound).
    mem: Mutex<HashMap<(usize, String), Compiled>>,
    /// Insertion order of memory-only entries, for eviction.
    ephemeral: Mutex<VecDeque<(usize, String)>>,
    /// (path, size, mtime) -> (content hash, is component), to avoid
    /// re-hashing big files.
    hashes: Mutex<HashMap<(PathBuf, u64, SystemTime), (String, bool)>>,
    /// Serializes compilation so two jobs don't compile the same 100 MB
    /// module concurrently (and to bound memory on small VMs).
    compile_lock: Mutex<()>,
    /// Separate lock for small modules (user programs, test binaries), so
    /// they never queue behind a multi-minute toolchain compile.
    small_lock: Mutex<()>,
    /// A background (tier-up) compile is running.
    bg_busy: std::sync::atomic::AtomicBool,
}

/// Modules below this size use `small_lock` (compiling them needs at most
/// a few hundred MB).
const SMALL_MODULE: u64 = 16 << 20;

pub struct Loaded {
    pub module: Compiled,
    pub cache: CacheResult,
    pub load_ms: f64,
}

impl ModuleCache {
    pub fn new(dir: PathBuf) -> Result<Self> {
        std::fs::create_dir_all(&dir).with_context(|| format!("create {}", dir.display()))?;
        Ok(Self {
            dir,
            mem: Mutex::new(HashMap::new()),
            ephemeral: Mutex::new(VecDeque::new()),
            hashes: Mutex::new(HashMap::new()),
            compile_lock: Mutex::new(()),
            small_lock: Mutex::new(()),
            bg_busy: Default::default(),
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

    /// Get `path` compiled for runtime `rt`: from memory, from the disk
    /// cache, or by compiling it. `persist` = write a compiled module to the
    /// disk cache; memory-only modules (fresh test binaries) are evicted
    /// after MAX_EPHEMERAL newer ones.
    pub fn load(&self, rt: &Rt, path: &Path, persist: bool) -> Result<Loaded> {
        let t0 = Instant::now();
        let (hash, component) = self.content_hash(path)?;
        let key = (rt.id, hash.clone());
        let engine = &rt.engine;
        let done = |module, cache| Loaded {
            module,
            cache,
            load_ms: t0.elapsed().as_secs_f64() * 1e3,
        };
        if let Some(m) = self.mem.lock().unwrap().get(&key) {
            return Ok(done(m.clone(), CacheResult::Memory));
        }
        // Disk hits are deserialized without the compile lock (cheap, and
        // must not wait behind another module's multi-minute compile).
        let cpath = self.dir.join(format!("{hash}-{}.cwasm", rt.tag));
        let small = std::fs::metadata(path).map(|m| m.len() < SMALL_MODULE).unwrap_or(false);
        let lock = if small { &self.small_lock } else { &self.compile_lock };
        let mut locked = None;
        loop {
            if let Some(m) = self.mem.lock().unwrap().get(&key) {
                return Ok(done(m.clone(), CacheResult::Memory));
            }
            if cpath.exists() || locked.is_some() {
                break;
            }
            // Not on disk: take the compile lock, then re-check memory and
            // disk (another thread may have just compiled it).
            locked = Some(lock.lock().unwrap());
        }
        if cpath.exists() {
            // SAFETY: files in the cache dir are only written by this
            // process (below) from `Module::serialize`; the cache dir is
            // outside anything a guest can write to (see HOST_CAPABILITIES).
            let r = if component {
                unsafe { Component::deserialize_file(engine, &cpath) }.map(Compiled::Component)
            } else {
                unsafe { Module::deserialize_file(engine, &cpath) }.map(Compiled::Module)
            };
            match r {
                Ok(m) => {
                    self.mem.lock().unwrap().insert(key, m.clone());
                    return Ok(done(m, CacheResult::Disk));
                }
                Err(e) => eprintln!("wasmdev-host: bad cache entry {}: {e:#}", cpath.display()),
            }
        }
        let _g = match locked {
            Some(g) => g,
            None => lock.lock().unwrap(),
        };
        let bytes = std::fs::read(path).with_context(|| format!("read {}", path.display()))?;
        let m = if component {
            Component::new(engine, &bytes).map(Compiled::Component)
        } else {
            Module::new(engine, &bytes).map(Compiled::Module)
        }
        .map_err(anyhow::Error::from)
        .with_context(|| format!("compile {}", path.display()))?;
        drop(bytes);
        // Cranelift compiles functions on many threads; glibc keeps their
        // freed arenas (≈1.9 GB after clang), so hand them back to the OS.
        #[cfg(target_env = "gnu")]
        unsafe {
            libc::malloc_trim(0);
        }
        if !persist {
            self.insert_ephemeral(key, m.clone());
            return Ok(done(m, CacheResult::Compiled));
        }
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
        self.mem.lock().unwrap().insert(key, m.clone());
        Ok(done(m, CacheResult::Compiled))
    }

    /// The module compiled for `rt` if it is already in memory.
    pub fn lookup(&self, rt: &Rt, path: &Path) -> Option<Loaded> {
        let t0 = Instant::now();
        let (hash, _) = self.content_hash(path).ok()?;
        let m = self.mem.lock().unwrap().get(&(rt.id, hash))?.clone();
        Some(Loaded { module: m, cache: CacheResult::Memory, load_ms: t0.elapsed().as_secs_f64() * 1e3 })
    }

    /// Compile `path` for `rt` into the memory cache on a background thread
    /// (tier-up: a module first run with Winch gets Cranelift code for its
    /// next runs). At most one background compile at a time; requests while
    /// one is running are dropped (a later run asks again).
    pub fn compile_background(self: &std::sync::Arc<Self>, rt: std::sync::Arc<Rt>, path: PathBuf) {
        if self.bg_busy.swap(true, std::sync::atomic::Ordering::SeqCst) {
            return;
        }
        let me = self.clone();
        let spawned = std::thread::Builder::new().name("tier-up".into()).spawn(move || {
            let r = (|| -> Result<()> {
                let (hash, component) = me.content_hash(&path)?;
                if me.mem.lock().unwrap().contains_key(&(rt.id, hash.clone())) {
                    return Ok(());
                }
                let bytes = std::fs::read(&path)?;
                let m = if component {
                    Component::new(&rt.engine, &bytes).map(Compiled::Component)
                } else {
                    Module::new(&rt.engine, &bytes).map(Compiled::Module)
                }
                .map_err(anyhow::Error::from)?;
                me.insert_ephemeral((rt.id, hash), m);
                Ok(())
            })();
            if let Err(e) = r {
                eprintln!("wasmdev-host: tier-up compile of {} failed: {e:#}", path.display());
            }
            me.bg_busy.store(false, std::sync::atomic::Ordering::SeqCst);
        });
        if spawned.is_err() {
            self.bg_busy.store(false, std::sync::atomic::Ordering::SeqCst);
        }
    }

    fn insert_ephemeral(&self, key: (usize, String), m: Compiled) {
        let mut q = self.ephemeral.lock().unwrap();
        let mut mem = self.mem.lock().unwrap();
        if mem.insert(key.clone(), m).is_none() {
            q.push_back(key);
        }
        while q.len() > MAX_EPHEMERAL {
            if let Some(old) = q.pop_front() {
                mem.remove(&old);
            }
        }
    }
}

fn header_is_component(bytes: &[u8]) -> bool {
    bytes.len() >= 8 && bytes[6..8] == [1, 0]
}
