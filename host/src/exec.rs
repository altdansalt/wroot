//! Workload execution: each workload (a wasip1 core module or a wasip2
//! component, detected from the binary header) runs on its own
//! OS thread with a single-threaded tokio runtime, so the control plane is
//! never blocked. Timeouts and kills use epoch interruption (CPU-bound guest
//! code) plus future cancellation (guest blocked in a host call such as
//! `poll_oneoff` or `sock_accept`).

use crate::cache::{CacheResult, Compiled, ModuleCache, is_component_file};
use anyhow::{Context, Result, anyhow, bail};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::net::{IpAddr, SocketAddr, TcpListener};
use std::path::{Component, Path, PathBuf};
use std::sync::atomic::{AtomicBool, AtomicI64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use wasmtime::component::ResourceTable;
use wasmtime::{Engine, Linker, Store, StoreLimits, StoreLimitsBuilder, UpdateDeadline};
use wasmtime_wasi::p1::WasiP1Ctx;
use wasmtime_wasi::sockets::SocketAddrUse;
use wasmtime_wasi::{FsPerms, I32Exit, WasiCtx, WasiCtxBuilder, WasiCtxView, WasiView};

/// Where the control plane sees the data dir. Spec paths must live under it.
pub const GUEST_DATA: &str = "/data";
pub const EPOCH_TICK: Duration = Duration::from_millis(5);

/// JSON spec passed to `wasmdev.exec_start`. All paths are guest paths under
/// `/data` (the control plane's view); the host maps them to the data dir.
#[derive(Deserialize, Debug, Default)]
#[serde(default, deny_unknown_fields)]
pub struct ExecSpec {
    /// Wasm module to run (`/data/...`).
    pub module: String,
    /// Full argv including argv[0].
    pub args: Vec<String>,
    pub env: BTreeMap<String, String>,
    pub dirs: Vec<Mount>,
    /// Files for stdio (`/data/...`); stdin defaults to empty, stdout/stderr
    /// to discarded.
    pub stdin: Option<String>,
    pub stdout: Option<String>,
    pub stderr: Option<String>,
    /// 0 = no timeout.
    pub timeout_ms: u64,
    /// 0 = host default.
    pub memory_limit_mb: u64,
    /// Request a listening TCP socket (long-running "service" workloads).
    /// Core modules get a preopened listener fd; components get permission
    /// to bind/listen on the assigned port only (`$PORT`).
    pub listen: bool,
    /// Only compile the module into the cache (no instantiation); used to
    /// warm toolchains when they are registered.
    pub precompile_only: bool,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Mount {
    pub host: String,
    pub guest: String,
    #[serde(default)]
    pub readonly: bool,
}

#[derive(Serialize, Clone, Debug, Default)]
pub struct Status {
    pub handle: i64,
    pub state: &'static str, // starting | running | exited | failed | killed | timeout
    pub done: bool,
    pub exit_code: Option<i32>,
    pub error: Option<String>,
    pub wall_ms: f64,
    /// Time spent obtaining the compiled module, and from where.
    pub load_ms: f64,
    pub cache: Option<CacheResult>,
    pub port: Option<u16>,
    pub listen_fd: Option<u32>,
    /// "module" (wasip1 core module) or "component" (wasip2).
    pub kind: Option<&'static str>,
}

pub struct Job {
    status: Mutex<Status>,
    started: Instant,
    kill: AtomicBool,
    kill_notify: tokio::sync::Notify,
}

impl Job {
    pub fn status(&self) -> Status {
        let mut s = self.status.lock().unwrap().clone();
        if !s.done {
            s.wall_ms = ms(self.started.elapsed());
        }
        s
    }
}

pub struct Config {
    pub data_dir: PathBuf,
    pub service_bind: String,
    pub service_ports: (u16, u16),
    pub default_memory_mb: u64,
}

pub struct Exec {
    pub engine: Engine,
    pub cache: ModuleCache,
    pub cfg: Config,
    linker: Linker<WorkloadState>,
    clinker: wasmtime::component::Linker<ComponentState>,
    jobs: Mutex<HashMap<i64, Arc<Job>>>,
    next: AtomicI64,
    ports: Mutex<BTreeSet<u16>>,
}

pub struct WorkloadState {
    wasi: WasiP1Ctx,
    limits: StoreLimits,
}

/// Store state for wasip2 components.
pub struct ComponentState {
    ctx: WasiCtx,
    table: ResourceTable,
    limits: StoreLimits,
}

impl WasiView for ComponentState {
    fn ctx(&mut self) -> WasiCtxView<'_> {
        WasiCtxView { ctx: &mut self.ctx, table: &mut self.table }
    }
}

fn ms(d: Duration) -> f64 {
    (d.as_secs_f64() * 1e6).round() / 1e3
}

impl Exec {
    pub fn new(engine: Engine, cache: ModuleCache, cfg: Config) -> Result<Arc<Self>> {
        let mut linker = Linker::new(&engine);
        wasmtime_wasi::p1::add_to_linker_async(&mut linker, |s: &mut WorkloadState| &mut s.wasi)?;
        let mut clinker = wasmtime::component::Linker::new(&engine);
        wasmtime_wasi::p2::add_to_linker_async(&mut clinker)?;
        Ok(Arc::new(Exec {
            engine,
            cache,
            cfg,
            linker,
            clinker,
            jobs: Mutex::new(HashMap::new()),
            next: AtomicI64::new(1),
            ports: Mutex::new(BTreeSet::new()),
        }))
    }

    /// Map a guest path (`/data/...`) to a host path inside the data dir,
    /// rejecting `..` and resolving symlinks so a guest can't point the host
    /// at files outside the data dir.
    pub fn host_path(&self, guest: &str, must_exist: bool) -> Result<PathBuf> {
        let rel = guest
            .strip_prefix(GUEST_DATA)
            .filter(|r| r.is_empty() || r.starts_with('/'))
            .ok_or_else(|| anyhow!("path {guest:?} is not under {GUEST_DATA}"))?;
        let rel = Path::new(rel.trim_start_matches('/'));
        if rel.components().any(|c| !matches!(c, Component::Normal(_))) {
            bail!("path {guest:?} must be normalized");
        }
        let p = self.cfg.data_dir.join(rel);
        let check = if must_exist || p.exists() {
            p.canonicalize().with_context(|| format!("{guest}: not found"))?
        } else {
            // New file: check its parent directory instead.
            let parent = p.parent().unwrap().canonicalize().with_context(|| format!("{guest}: parent not found"))?;
            parent.join(p.file_name().unwrap())
        };
        if !check.starts_with(&self.cfg.data_dir) {
            bail!("path {guest:?} escapes the data dir");
        }
        Ok(check)
    }

    pub fn get(&self, h: i64) -> Option<Arc<Job>> {
        self.jobs.lock().unwrap().get(&h).cloned()
    }

    pub fn kill(&self, h: i64) -> bool {
        match self.get(h) {
            Some(j) => {
                j.kill.store(true, Ordering::SeqCst);
                j.kill_notify.notify_one();
                true
            }
            None => false,
        }
    }

    /// Forget a finished job (frees its status record). Running jobs are
    /// killed first.
    pub fn release(&self, h: i64) -> bool {
        self.kill(h);
        self.jobs.lock().unwrap().remove(&h).is_some()
    }

    fn alloc_listener(&self) -> Result<(u16, TcpListener)> {
        let (lo, hi) = self.cfg.service_ports;
        let mut used = self.ports.lock().unwrap();
        for port in lo..=hi {
            if used.contains(&port) {
                continue;
            }
            if let Ok(l) = TcpListener::bind((self.cfg.service_bind.as_str(), port)) {
                used.insert(port);
                return Ok((port, l));
            }
        }
        bail!("no free port in {lo}-{hi}")
    }

    /// Start a workload. Never fails: spec errors are reported via status.
    pub fn start(self: &Arc<Self>, spec_json: &[u8]) -> i64 {
        let handle = self.next.fetch_add(1, Ordering::SeqCst);
        let job = Arc::new(Job {
            status: Mutex::new(Status {
                handle,
                state: "starting",
                ..Default::default()
            }),
            started: Instant::now(),
            kill: AtomicBool::new(false),
            kill_notify: tokio::sync::Notify::new(),
        });
        self.jobs.lock().unwrap().insert(handle, job.clone());

        let prepared = serde_json::from_slice::<ExecSpec>(spec_json)
            .context("invalid exec spec")
            .and_then(|spec| self.prepare(spec, &job));
        match prepared {
            Err(e) => self.finish(&job, "failed", None, Some(format!("{e:#}"))),
            Ok(p) => {
                let me = self.clone();
                std::thread::Builder::new()
                    .name(format!("workload-{handle}"))
                    .spawn(move || me.run_thread(job, p))
                    .expect("spawn workload thread");
            }
        }
        handle
    }

    fn finish(&self, job: &Job, state: &'static str, code: Option<i32>, err: Option<String>) {
        let mut s = job.status.lock().unwrap();
        s.state = state;
        s.done = true;
        s.exit_code = code;
        s.error = err;
        s.wall_ms = ms(job.started.elapsed());
        if let Some(p) = s.port {
            self.ports.lock().unwrap().remove(&p);
        }
    }

    /// Synchronous validation + resource acquisition (port binding), so the
    /// port is known as soon as `exec_start` returns.
    fn prepare(&self, spec: ExecSpec, job: &Job) -> Result<Prepared> {
        let module = self.host_path(&spec.module, true)?;
        let component = is_component_file(&module)?;
        job.status.lock().unwrap().kind = Some(if component { "component" } else { "module" });
        let mut mounts = Vec::new();
        for m in &spec.dirs {
            let host = self.host_path(&m.host, true)?;
            if !host.is_dir() {
                bail!("mount {}: not a directory", m.host);
            }
            mounts.push((host, m.guest.clone(), m.readonly));
        }
        let stdin = spec.stdin.as_deref().map(|p| self.host_path(p, true)).transpose()?;
        let stdout = spec.stdout.as_deref().map(|p| self.host_path(p, false)).transpose()?;
        let stderr = spec.stderr.as_deref().map(|p| self.host_path(p, false)).transpose()?;
        let listener = if spec.listen && !spec.precompile_only {
            let (port, l) = self.alloc_listener()?;
            let fd = 3 + mounts.len() as u32;
            let mut s = job.status.lock().unwrap();
            s.port = Some(port);
            // Components bind the port themselves (wasi:sockets); we hold
            // the reservation until just before the guest starts.
            s.listen_fd = (!component).then_some(fd);
            Some((fd, l))
        } else {
            None
        };
        let mem_mb = if spec.memory_limit_mb > 0 { spec.memory_limit_mb } else { self.cfg.default_memory_mb };
        Ok(Prepared {
            module,
            component,
            precompile_only: spec.precompile_only,
            args: spec.args,
            env: spec.env,
            mounts,
            stdin,
            stdout,
            stderr,
            timeout: (spec.timeout_ms > 0).then(|| Duration::from_millis(spec.timeout_ms)),
            memory_bytes: (mem_mb as usize) << 20,
            listener,
        })
    }

    fn run_thread(self: Arc<Self>, job: Arc<Job>, p: Prepared) {
        let rt = tokio::runtime::Builder::new_current_thread().enable_all().build().unwrap();
        let timeout = p.timeout;
        let outcome = rt.block_on(async {
            let run = self.run_workload(&job, p);
            let killed = job.kill_notify.notified();
            let sleep = async {
                match timeout {
                    Some(t) => tokio::time::sleep(t).await,
                    None => std::future::pending().await,
                }
            };
            tokio::select! {
                r = run => r,
                _ = killed => Outcome::Killed,
                _ = sleep => Outcome::Timeout,
            }
        });
        // Re-check flags: an epoch-interrupt trap may have raced the select.
        let outcome = match outcome {
            Outcome::Failed(_) if job.kill.load(Ordering::SeqCst) => Outcome::Killed,
            Outcome::Failed(_) if timeout.is_some_and(|t| job.started.elapsed() >= t) => Outcome::Timeout,
            o => o,
        };
        match outcome {
            Outcome::Exited(c) => self.finish(&job, "exited", Some(c), None),
            Outcome::Failed(e) => self.finish(&job, "failed", None, Some(e)),
            Outcome::Killed => self.finish(&job, "killed", None, Some("killed".into())),
            Outcome::Timeout => self.finish(&job, "timeout", None, Some("timeout".into())),
        }
    }

    async fn run_workload(&self, job: &Arc<Job>, p: Prepared) -> Outcome {
        match self.run_inner(job, p).await {
            Ok(code) => Outcome::Exited(code),
            Err(e) => Outcome::Failed(format!("{e:#}")),
        }
    }

    async fn run_inner(&self, job: &Arc<Job>, p: Prepared) -> Result<i32> {
        let loaded = self.cache.load(&p.module)?;
        {
            let mut s = job.status.lock().unwrap();
            s.state = "running";
            s.load_ms = loaded.load_ms;
            s.cache = Some(loaded.cache);
        }
        if p.precompile_only {
            return Ok(0);
        }
        let mut b = WasiCtxBuilder::new();
        // This thread is dedicated to the workload, so file I/O may block it
        // directly instead of bouncing through spawn_blocking.
        b.allow_blocking_current_thread(true);
        b.args(&p.args);
        for (k, v) in &p.env {
            b.env(k, v);
        }
        for (host, guest, ro) in &p.mounts {
            let perms = if *ro { FsPerms::ReadOnly } else { FsPerms::ReadWrite };
            b.preopened_dir(host, guest, perms)
                .map_err(anyhow::Error::from)
                .with_context(|| format!("mount {}", host.display()))?;
        }
        if let Some(f) = &p.stdin {
            b.stdin(wasmtime_wasi::cli::InputFile::new(std::fs::File::open(f)?));
        }
        if let Some(f) = &p.stdout {
            b.stdout(wasmtime_wasi::cli::OutputFile::new(std::fs::File::create(f)?));
        }
        if let Some(f) = &p.stderr {
            b.stderr(wasmtime_wasi::cli::OutputFile::new(std::fs::File::create(f)?));
        }
        // Network policy (wasi:sockets; only reachable from components):
        // no DNS, no UDP, no outbound TCP. A service may bind/listen only on
        // its assigned port, on an address no wider than --service-bind.
        b.allow_ip_name_lookup(false).allow_udp(false);
        let port = p.listener.as_ref().map(|_| job.status.lock().unwrap().port.unwrap());
        b.allow_tcp(port.is_some());
        if let Some(port) = port {
            b.env("PORT", port.to_string());
            b.env("WASMDEV_PORT", port.to_string());
            let bind_ip: Option<IpAddr> = self.cfg.service_bind.parse().ok();
            b.socket_addr_check(move |addr, usage| {
                let ok = service_socket_allowed(bind_ip, port, addr, usage);
                Box::pin(async move { ok })
            });
        }
        let limits = |instances| StoreLimitsBuilder::new().memory_size(p.memory_bytes).instances(instances).build();
        match loaded.module {
            Compiled::Module(module) => {
                if let Some((fd, _)) = &p.listener {
                    b.env("WASMDEV_LISTEN_FD", fd.to_string());
                }
                let mut wasi = b.build_p1();
                if let Some((_, l)) = p.listener {
                    wasi.preopen_tcp_listener(l);
                }
                let mut store = Store::new(&self.engine, WorkloadState { wasi, limits: limits(4) });
                store.limiter(|s| &mut s.limits);
                interruptible(&mut store, job);
                let instance = self.linker.instantiate_async(&mut store, &module).await?;
                let start = instance
                    .get_typed_func::<(), ()>(&mut store, "_start")
                    .map_err(anyhow::Error::from)
                    .context("module has no _start (not a wasip1 command?)")?;
                exit_code(start.call_async(&mut store, ()).await.map(|()| 0))
            }
            Compiled::Component(component) => {
                // Release the port reservation; the guest binds it itself.
                drop(p.listener);
                let state = ComponentState { ctx: b.build(), table: ResourceTable::new(), limits: limits(64) };
                let mut store = Store::new(&self.engine, state);
                store.limiter(|s| &mut s.limits);
                interruptible(&mut store, job);
                let cmd = wasmtime_wasi::p2::bindings::Command::instantiate_async(&mut store, &component, &self.clinker)
                    .await
                    .map_err(anyhow::Error::from)
                    .context("instantiate component (only wasi:cli/command components are supported)")?;
                let r = cmd.wasi_cli_run().call_run(&mut store).await;
                exit_code(r.map(|r| if r.is_ok() { 0 } else { 1 }))
            }
        }
    }
}

/// Socket policy for components started as services.
fn service_socket_allowed(bind_ip: Option<IpAddr>, port: u16, addr: SocketAddr, usage: SocketAddrUse) -> bool {
    match usage {
        SocketAddrUse::TcpBind | SocketAddrUse::TcpListen => {
            let ip_ok = match bind_ip {
                None => false,
                Some(b) if b.is_unspecified() => true,
                Some(b) => addr.ip() == b || addr.ip().is_loopback(),
            };
            ip_ok && addr.port() == port
        }
        SocketAddrUse::TcpAccept => true,
        _ => false, // TcpConnect, UDP: no outbound network
    }
}

/// Epoch interruption: every tick, yield to our executor so the kill/timeout
/// select in `run_thread` gets a chance to run, and trap if a kill was
/// requested. (Cancellation is by dropping the future.)
fn interruptible<T>(store: &mut Store<T>, job: &Arc<Job>) {
    store.set_epoch_deadline(1);
    let job = job.clone();
    store.epoch_deadline_callback(move |_| {
        if job.kill.load(Ordering::Relaxed) {
            Ok(UpdateDeadline::Interrupt)
        } else {
            Ok(UpdateDeadline::Yield(1))
        }
    });
}

fn exit_code(r: wasmtime::Result<i32>) -> Result<i32> {
    match r {
        Ok(c) => Ok(c),
        Err(e) => match e.downcast_ref::<I32Exit>() {
            Some(I32Exit(c)) => Ok(*c),
            None => Err(e.into()),
        },
    }
}

enum Outcome {
    Exited(i32),
    Failed(String),
    Killed,
    Timeout,
}

struct Prepared {
    module: PathBuf,
    #[allow(dead_code)]
    component: bool,
    precompile_only: bool,
    args: Vec<String>,
    env: BTreeMap<String, String>,
    mounts: Vec<(PathBuf, String, bool)>,
    stdin: Option<PathBuf>,
    stdout: Option<PathBuf>,
    stderr: Option<PathBuf>,
    timeout: Option<Duration>,
    memory_bytes: usize,
    listener: Option<(u32, TcpListener)>,
}
