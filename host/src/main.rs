//! wasmdev-host: thin native host for the wasmdev control plane.
//!
//! The control plane (a wasip1 module, e.g. Go) holds all application
//! logic. This binary only grants it low-level capabilities: one listening
//! TCP socket, the data directory, stdio, env/args, and the `wasmdev.*`
//! imports for running other wasm modules natively via wasmtime.
//! See docs/HOST_CAPABILITIES.md.

mod cache;
mod exec;

use anyhow::{Context, Result, bail};
use exec::{EPOCH_TICK, Exec, GUEST_DATA};
use std::net::TcpListener;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Instant;
use wasmtime::{Caller, Config, Engine, Extern, Linker, Store};
use wasmtime_wasi::p1::WasiP1Ctx;
use wasmtime_wasi::{FsPerms, I32Exit, WasiCtxBuilder};

const USAGE: &str = "usage: wasmdev-host --control <control.wasm> --listen <addr:port> --data <dir>
       [--token <tok>] [--service-bind 0.0.0.0] [--service-ports 8100-8199]
       [--public-host <host>] [--memory-mb 1024] [--env K=V]...
       [-- control-plane args...]

Env passed to the control plane: WASMDEV_TOKEN (from --token or $WASMDEV_TOKEN),
WASMDEV_LISTEN_FD, WASMDEV_PUBLIC_HOST, plus any WASMDEV_* from the host env.";

struct Args {
    control: PathBuf,
    listen: String,
    data: PathBuf,
    token: Option<String>,
    service_bind: String,
    service_ports: (u16, u16),
    public_host: String,
    memory_mb: u64,
    env: Vec<(String, String)>,
    rest: Vec<String>,
}

fn parse_args() -> Result<Args> {
    let mut a = Args {
        control: PathBuf::new(),
        listen: "127.0.0.1:8080".into(),
        data: PathBuf::from("data"),
        token: std::env::var("WASMDEV_TOKEN").ok(),
        service_bind: "0.0.0.0".into(),
        service_ports: (8100, 8199),
        public_host: "127.0.0.1".into(),
        memory_mb: 1024,
        env: vec![],
        rest: vec![],
    };
    let mut it = std::env::args().skip(1);
    while let Some(f) = it.next() {
        let mut v = || it.next().with_context(|| format!("{f} needs a value"));
        match f.as_str() {
            "--control" => a.control = v()?.into(),
            "--listen" => a.listen = v()?,
            "--data" => a.data = v()?.into(),
            "--token" => a.token = Some(v()?),
            "--service-bind" => a.service_bind = v()?,
            "--public-host" => a.public_host = v()?,
            "--memory-mb" => a.memory_mb = v()?.parse()?,
            "--env" => {
                let kv = v()?;
                let (k, val) = kv.split_once('=').context("--env KEY=VALUE")?;
                a.env.push((k.into(), val.into()));
            }
            "--service-ports" => {
                let s = v()?;
                let (lo, hi) = s.split_once('-').context("--service-ports lo-hi")?;
                a.service_ports = (lo.parse()?, hi.parse()?);
            }
            "--" => {
                a.rest = it.by_ref().collect();
            }
            "-h" | "--help" => {
                println!("{USAGE}");
                std::process::exit(0);
            }
            _ => bail!("unknown flag {f}\n{USAGE}"),
        }
    }
    if a.control.as_os_str().is_empty() {
        bail!("--control is required\n{USAGE}");
    }
    Ok(a)
}

struct ControlState {
    wasi: WasiP1Ctx,
    exec: Arc<Exec>,
}

/// Reads `len` bytes at `ptr` from the caller's exported memory.
fn read_mem(caller: &mut Caller<'_, ControlState>, ptr: i32, len: i32) -> wasmtime::Result<Vec<u8>> {
    let Some(Extern::Memory(mem)) = caller.get_export("memory") else {
        wasmtime::bail!("control plane exports no memory");
    };
    let mut buf = vec![0u8; len as u32 as usize];
    mem.read(&caller, ptr as u32 as usize, &mut buf)?;
    Ok(buf)
}

/// Writes `data` at `ptr` if it fits in `cap`; returns `data.len()` either
/// way (callers retry with a bigger buffer when the result exceeds `cap`).
fn write_mem(caller: &mut Caller<'_, ControlState>, ptr: i32, cap: i32, data: &[u8]) -> wasmtime::Result<i32> {
    if data.len() <= cap as u32 as usize {
        let Some(Extern::Memory(mem)) = caller.get_export("memory") else {
            wasmtime::bail!("control plane exports no memory");
        };
        mem.write(caller, ptr as u32 as usize, data)?;
    }
    Ok(data.len() as i32)
}

/// The `wasmdev` import module: the only non-WASI capabilities the control
/// plane gets. All calls are non-blocking.
fn add_wasmdev_imports(linker: &mut Linker<ControlState>) -> Result<()> {
    // exec_start(spec_ptr, spec_len) -> handle (>0). Spec errors are
    // reported through exec_status (state "failed").
    linker.func_wrap("wasmdev", "exec_start", |mut c: Caller<'_, ControlState>, p: i32, l: i32| {
        let spec = read_mem(&mut c, p, l)?;
        Ok(c.data().exec.start(&spec))
    })?;
    // exec_status(handle, buf_ptr, buf_cap) -> json_len, or -1 if unknown.
    // If json_len > buf_cap nothing was written; call again with a bigger buffer.
    linker.func_wrap(
        "wasmdev",
        "exec_status",
        |mut c: Caller<'_, ControlState>, h: i64, p: i32, cap: i32| {
            let Some(job) = c.data().exec.get(h) else { return Ok(-1) };
            let json = serde_json::to_vec(&job.status())?;
            write_mem(&mut c, p, cap, &json)
        },
    )?;
    // exec_kill(handle) -> 0, or -1 if unknown. Asynchronous: poll status.
    linker.func_wrap("wasmdev", "exec_kill", |c: Caller<'_, ControlState>, h: i64| {
        Ok(if c.data().exec.kill(h) { 0i32 } else { -1 })
    })?;
    // exec_release(handle) -> 0, or -1 if unknown. Kills if still running
    // and forgets the job record.
    linker.func_wrap("wasmdev", "exec_release", |c: Caller<'_, ControlState>, h: i64| {
        Ok(if c.data().exec.release(h) { 0i32 } else { -1 })
    })?;
    Ok(())
}

fn main() -> Result<()> {
    let args = parse_args()?;
    std::fs::create_dir_all(&args.data)?;
    let data_dir = args.data.canonicalize()?;

    let mut cfg = Config::new();
    cfg.epoch_interruption(true);
    let engine = Engine::new(&cfg)?;
    {
        let engine = engine.clone();
        std::thread::Builder::new().name("epoch".into()).spawn(move || loop {
            std::thread::sleep(EPOCH_TICK);
            engine.increment_epoch();
        })?;
    }

    // Compiled-module cache lives next to (not inside) the data dir so no
    // guest can write a .cwasm that we would later deserialize.
    let cache_dir = data_dir.with_file_name(format!(
        "{}.cache",
        data_dir.file_name().unwrap().to_string_lossy()
    ));
    let cache = cache::ModuleCache::new(&engine, cache_dir)?;
    let exec = Exec::new(
        engine.clone(),
        cache,
        exec::Config {
            data_dir: data_dir.clone(),
            service_bind: args.service_bind.clone(),
            service_ports: args.service_ports,
            default_memory_mb: args.memory_mb,
        },
    )?;

    let listener = TcpListener::bind(&args.listen).with_context(|| format!("bind {}", args.listen))?;
    let token = args.token.clone().unwrap_or_else(|| {
        let t = hex::encode(rand_bytes());
        eprintln!("wasmdev-host: generated token (pass --token to fix): {t}");
        t
    });

    let mut b = WasiCtxBuilder::new();
    b.allow_blocking_current_thread(true);
    b.inherit_stdout().inherit_stderr();
    let mut argv = vec!["control".to_string()];
    argv.extend(args.rest.iter().cloned());
    b.args(&argv);
    for (k, v) in std::env::vars().filter(|(k, _)| k.starts_with("WASMDEV_")) {
        b.env(k, v);
    }
    for (k, v) in &args.env {
        b.env(k, v);
    }
    b.env("WASMDEV_TOKEN", &token);
    b.env("WASMDEV_PUBLIC_HOST", &args.public_host);
    // Preopened dirs come first (fd 3..), then the listener; see
    // WasiP1Ctx::preopen_tcp_listener for why.
    b.env("WASMDEV_LISTEN_FD", "4");
    b.preopened_dir(&data_dir, GUEST_DATA, FsPerms::ReadWrite)?;
    let mut wasi = b.build_p1();
    wasi.preopen_tcp_listener(listener);

    let mut linker: Linker<ControlState> = Linker::new(&engine);
    wasmtime_wasi::p1::add_to_linker_async(&mut linker, |s| &mut s.wasi)?;
    add_wasmdev_imports(&mut linker)?;

    let t0 = Instant::now();
    let loaded = exec.cache.load(&args.control)?;
    eprintln!(
        "wasmdev-host: control plane {} loaded in {:.1} ms ({:?}); listening on {}; data {}",
        args.control.display(),
        loaded.load_ms,
        loaded.cache,
        args.listen,
        data_dir.display()
    );
    let mut store = Store::new(&engine, ControlState { wasi, exec });
    // The control plane is trusted-ish but must not spin forever without
    // letting our executor run; yield on every epoch tick.
    store.set_epoch_deadline(1);
    store.epoch_deadline_async_yield_and_update(1);

    let rt = tokio::runtime::Builder::new_current_thread().enable_all().build()?;
    let res = rt.block_on(async {
        let inst = linker.instantiate_async(&mut store, &loaded.module).await?;
        let start = inst.get_typed_func::<(), ()>(&mut store, "_start")?;
        start.call_async(&mut store, ()).await
    });
    eprintln!("wasmdev-host: control plane exited after {:.1}s", t0.elapsed().as_secs_f64());
    match res {
        Ok(()) => Ok(()),
        Err(e) => match e.downcast_ref::<I32Exit>() {
            Some(I32Exit(c)) => std::process::exit(*c),
            None => Err(e.into()),
        },
    }
}

fn rand_bytes() -> [u8; 16] {
    use std::io::Read;
    let mut b = [0u8; 16];
    std::fs::File::open("/dev/urandom").and_then(|mut f| f.read_exact(&mut b)).expect("urandom");
    b
}
