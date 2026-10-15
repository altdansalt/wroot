//! Wasmtime runtimes: one `Engine` (plus its linkers) per (compiler,
//! max wasm call-stack size) combination, created on first use.
//!
//! Both settings are engine-wide in wasmtime: `max_wasm_stack` is read from
//! the engine config whenever wasm is entered, and the compiler strategy is
//! fixed per engine. A run that asks for a bigger call stack, or a module
//! that should be compiled with Winch (the fast baseline compiler, for
//! freshly built short-lived modules such as Go test binaries), therefore
//! gets its own engine. Compiled modules are engine-bound in memory, but
//! Cranelift engines that differ only in stack size share the disk cache
//! (the stack limit is a runtime setting, not part of the compiled code).

use crate::exec::{ComponentState, WorkloadState};
use anyhow::{Result, bail};
use serde::{Deserialize, Serialize};
use std::hash::{Hash, Hasher};
use std::sync::{Arc, Mutex};
use wasmtime::{Config, Engine, Linker, Strategy};

/// Default wasm call-stack limit (wasmtime's own default is 512 KiB, which
/// deep-recursion programs such as interpreters hit quickly).
pub const DEFAULT_STACK: usize = 8 << 20;
pub const MAX_STACK: usize = 256 << 20;
/// Extra fiber stack for host functions called from wasm.
const HOST_STACK_MARGIN: usize = 2 << 20;

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Compiler {
    /// Optimizing compiler: slow to compile, fast code. Tools, services.
    #[default]
    Cranelift,
    /// Baseline compiler: ~5x faster to compile, slower code. Modules that
    /// are built and then run once or twice (test binaries).
    Winch,
}

pub struct Rt {
    pub id: usize,
    pub compiler: Compiler,
    pub stack: usize,
    pub engine: Engine,
    /// Engine compatibility tag for disk-cache file names.
    pub tag: String,
    pub linker: Linker<WorkloadState>,
    pub clinker: wasmtime::component::Linker<ComponentState>,
}

pub struct Runtimes {
    list: Mutex<Vec<Arc<Rt>>>,
}

fn make_engine(compiler: Compiler, stack: usize) -> Result<Engine> {
    let mut cfg = Config::new();
    cfg.epoch_interruption(true);
    cfg.wasm_component_model(true);
    cfg.max_wasm_stack(stack);
    cfg.async_stack_size(stack + HOST_STACK_MARGIN);
    match compiler {
        // C++ built with -fwasm-exceptions (exnref) needs this; Cranelift
        // only (Winch rejects such modules and we fall back to Cranelift).
        Compiler::Cranelift => {
            cfg.wasm_exceptions(true);
        }
        Compiler::Winch => {
            cfg.strategy(Strategy::Winch);
        }
    }
    Ok(Engine::new(&cfg)?)
}

/// Round a requested stack size to 64 KiB; 0 = default.
pub fn normalize_stack(bytes: u64) -> Result<usize> {
    if bytes == 0 {
        return Ok(DEFAULT_STACK);
    }
    let b = (bytes as usize).max(64 << 10).div_ceil(64 << 10) * (64 << 10);
    if b > MAX_STACK {
        bail!("max_wasm_stack {bytes} exceeds the limit of {MAX_STACK} bytes");
    }
    Ok(b)
}

impl Runtimes {
    pub fn new() -> Result<Arc<Self>> {
        let r = Arc::new(Runtimes { list: Mutex::new(Vec::new()) });
        r.get(Compiler::Cranelift, DEFAULT_STACK)?;
        Ok(r)
    }

    /// The default runtime (Cranelift, default stack); also runs the
    /// control plane.
    pub fn default_rt(&self) -> Arc<Rt> {
        self.list.lock().unwrap()[0].clone()
    }

    pub fn get(&self, compiler: Compiler, stack: usize) -> Result<Arc<Rt>> {
        let mut list = self.list.lock().unwrap();
        if let Some(rt) = list.iter().find(|r| r.compiler == compiler && r.stack == stack) {
            return Ok(rt.clone());
        }
        let engine = make_engine(compiler, stack)?;
        let mut h = std::collections::hash_map::DefaultHasher::new();
        engine.precompile_compatibility_hash().hash(&mut h);
        let mut linker = Linker::new(&engine);
        wasmtime_wasi::p1::add_to_linker_async(&mut linker, |s: &mut WorkloadState| &mut s.wasi)?;
        crate::proc::add_to_linker(&mut linker)?;
        let mut clinker = wasmtime::component::Linker::new(&engine);
        wasmtime_wasi::p2::add_to_linker_async(&mut clinker)?;
        let rt = Arc::new(Rt {
            id: list.len(),
            compiler,
            stack,
            engine,
            tag: format!("{:016x}", h.finish()),
            linker,
            clinker,
        });
        list.push(rt.clone());
        Ok(rt)
    }

    /// Advance every engine's epoch (drives timeouts, kills and yielding).
    pub fn increment_epochs(&self) {
        for rt in self.list.lock().unwrap().iter() {
            rt.engine.increment_epoch();
        }
    }

    pub fn start_epoch_thread(self: &Arc<Self>) -> Result<()> {
        let me = self.clone();
        std::thread::Builder::new().name("epoch".into()).spawn(move || loop {
            std::thread::sleep(crate::exec::EPOCH_TICK);
            me.increment_epochs();
        })?;
        Ok(())
    }
}
