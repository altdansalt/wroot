//! `wasmdev-host exec`: run one wasip1 module with process spawn enabled,
//! stdio inherited, without the control plane. A test harness for tool
//! drivers (cmd/go, clang) that spawn child wasm processes.
//!
//!   wasmdev-host exec [--dir HOST[::GUEST][:ro]]... [--env K=V]... [--cwd GUEST]
//!                     [--cache DIR] [--memory-mb N] -- module.wasm [args...]

use crate::exec::{self, Exec, Prepared};
use crate::proc::Stdio;
use anyhow::{Context, Result, bail};
use std::collections::BTreeMap;
use std::path::PathBuf;
use std::time::{Duration, Instant};
use wasmtime::{Config, Engine};

pub fn main(args: Vec<String>) -> Result<()> {
    let mut mounts = Vec::new();
    let mut env = BTreeMap::new();
    let mut cwd: Option<String> = None;
    let mut cache_dir = std::env::var_os("WASMDEV_CACHE")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(std::env::var("HOME").unwrap_or_default()).join(".cache/wasmdev-host"));
    let mut memory_mb: u64 = 2048;
    let mut it = args.into_iter();
    let mut rest = Vec::new();
    while let Some(f) = it.next() {
        let mut v = || it.next().with_context(|| format!("{f} needs a value"));
        match f.as_str() {
            "--dir" => {
                let s = v()?;
                let (s, ro) = match s.strip_suffix(":ro") {
                    Some(s) => (s.to_string(), true),
                    None => (s, false),
                };
                let (host, guest) = match s.split_once("::") {
                    Some((h, g)) => (h.to_string(), g.to_string()),
                    None => (s.clone(), s.clone()),
                };
                let host = PathBuf::from(&host).canonicalize().with_context(|| format!("--dir {host}"))?;
                mounts.push((host, guest, ro));
            }
            "--env" => {
                let kv = v()?;
                let (k, val) = kv.split_once('=').context("--env KEY=VALUE")?;
                env.insert(k.to_string(), val.to_string());
            }
            "--cwd" => cwd = Some(v()?),
            "--cache" => cache_dir = v()?.into(),
            "--memory-mb" => memory_mb = v()?.parse()?,
            "--" => {
                rest = it.by_ref().collect();
            }
            _ => bail!("exec: unknown flag {f}"),
        }
    }
    if rest.is_empty() {
        bail!("usage: wasmdev-host exec [--dir HOST[::GUEST][:ro]]... [--env K=V]... [--cwd GUEST] -- module.wasm [args...]");
    }
    if let Some(d) = &cwd {
        env.insert("PWD".into(), d.clone());
    }

    let mut cfg = Config::new();
    cfg.epoch_interruption(true);
    cfg.wasm_exceptions(true);
    cfg.wasm_component_model(true);
    let engine = Engine::new(&cfg)?;
    {
        let engine = engine.clone();
        std::thread::Builder::new().name("epoch".into()).spawn(move || loop {
            std::thread::sleep(exec::EPOCH_TICK);
            engine.increment_epoch();
        })?;
    }
    let cache = crate::cache::ModuleCache::new(&engine, cache_dir)?;
    let ex = Exec::new(
        engine,
        cache,
        exec::Config {
            data_dir: std::env::temp_dir(),
            service_bind: "127.0.0.1".into(),
            service_ports: (0, 0),
            default_memory_mb: memory_mb,
        },
    )?;
    let module = PathBuf::from(&rest[0]).canonicalize().with_context(|| rest[0].clone())?;
    let component = crate::cache::is_component_file(&module)?;
    let t0 = Instant::now();
    let p = Prepared {
        module,
        component,
        precompile_only: false,
        args: rest.clone(),
        env,
        mounts,
        stdin: None,
        stdout: None,
        stderr: None,
        timeout: None,
        memory_bytes: (memory_mb as usize) << 20,
        listener: None,
        stdio: Some([Stdio::Inherit(0), Stdio::Inherit(1), Stdio::Inherit(2)]),
        exit_notify: None,
        depth: 0,
        trace: std::env::var_os("WASMDEV_TRACE_PROC").map(|_| rest[0].clone()),
    };
    let (_, job) = ex.start_prepared(p);
    let st = loop {
        let st = job.status();
        if st.done {
            break st;
        }
        std::thread::sleep(Duration::from_millis(2));
    };
    if std::env::var_os("WASMDEV_TRACE_PROC").is_some() {
        eprintln!("[exec] total {:.2}s", t0.elapsed().as_secs_f64());
    }
    match st.state {
        "exited" => std::process::exit(st.exit_code.unwrap_or(0)),
        _ => {
            eprintln!("wasmdev-host exec: {} {}", st.state, st.error.unwrap_or_default());
            std::process::exit(125)
        }
    }
}
