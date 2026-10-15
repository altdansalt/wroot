//! Workload execution: each workload (a wasip1 core module or a wasip2
//! component, detected from the binary header) runs on its own
//! OS thread with a single-threaded tokio runtime, so the control plane is
//! never blocked. Timeouts and kills use epoch interruption (CPU-bound guest
//! code) plus future cancellation (guest blocked in a host call such as
//! `poll_oneoff` or `sock_accept`).

use crate::cache::{CacheResult, Compiled, ModuleCache, is_component_file};
use crate::proc::Stdio;
use crate::rt::{Compiler, Rt, Runtimes};
use anyhow::{Context, Result, anyhow, bail};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::net::{IpAddr, SocketAddr, TcpListener};
use std::path::{Component, Path, PathBuf};
use std::sync::atomic::{AtomicBool, AtomicI64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use wasmtime::component::ResourceTable;
use wasmtime::{Store, StoreLimits, StoreLimitsBuilder, UpdateDeadline};
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
    /// wasm call-stack limit in bytes (wasmtime `max_wasm_stack`); 0 = host
    /// default (8 MiB). Child processes inherit it.
    pub max_wasm_stack: u64,
    /// Compiler for the module: "cranelift" (default) or "winch".
    pub compiler: Option<Compiler>,
    /// Don't write the compiled module to the disk cache (memory only,
    /// evicted after a few newer ones). For short-lived builds.
    pub ephemeral: bool,
    /// Grant the `wasmdev_proc` process-spawn imports (inherited by
    /// children). Off: spawn fails with ENOEXEC.
    pub spawn: bool,
    /// With compiler "winch": use Cranelift code if it is already in memory;
    /// otherwise run the Winch code and compile Cranelift in the background
    /// for the next run (tier-up).
    pub tier_up: bool,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Mount {
    pub host: String,
    pub guest: String,
    #[serde(default)]
    pub readonly: bool,
    /// Modules spawned from this mount are compiled with this compiler and
    /// kept in memory only (e.g. "winch" for a build tool's temp dir, where
    /// `go test` puts the test binaries it runs once).
    #[serde(default)]
    pub compiler: Option<Compiler>,
}

/// A workload's preopened directory.
#[derive(Clone, Debug)]
pub struct HostMount {
    pub host: PathBuf,
    pub guest: String,
    pub readonly: bool,
    pub compiler: Option<Compiler>,
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
    /// For state "failed" by a wasm trap: stack_overflow,
    /// memory_out_of_bounds, unreachable, integer_division_by_zero, ...
    pub trap: Option<String>,
    /// Compiler actually used ("cranelift" | "winch").
    pub compiler: Option<Compiler>,
}

/// How to tell that a service is accepting connections.
enum Ready {
    /// wasip1: the guest has called `sock_accept` on its listener.
    Accept(Arc<AtomicBool>),
    /// wasip2: the guest binds the port itself; probe with a TCP connect.
    Probe(SocketAddr),
}

pub struct Job {
    status: Mutex<Status>,
    ready: Mutex<Option<Ready>>,
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
    pub rts: Arc<Runtimes>,
    pub cache: Arc<ModuleCache>,
    pub cfg: Config,
    jobs: Mutex<HashMap<i64, Arc<Job>>>,
    next: AtomicI64,
    ports: Mutex<BTreeSet<u16>>,
}

pub struct WorkloadState {
    pub(crate) wasi: WasiP1Ctx,
    limits: StoreLimits,
    /// Process-spawn state (`wasmdev_proc` imports, see proc.rs).
    pub(crate) proc: Option<crate::proc::ProcCtx>,
}

/// Store state for wasip2 components.
pub struct ComponentState {
    pub(crate) ctx: WasiCtx,
    pub(crate) table: ResourceTable,
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
    pub fn new(rts: Arc<Runtimes>, cache: ModuleCache, cfg: Config) -> Result<Arc<Self>> {
        Ok(Arc::new(Exec {
            rts,
            cache: Arc::new(cache),
            cfg,
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

    /// Is service `h` accepting connections? None = unknown handle or not
    /// a service.
    pub fn ready(&self, h: i64) -> Option<bool> {
        let job = self.get(h)?;
        let r = job.ready.lock().unwrap();
        match r.as_ref()? {
            Ready::Accept(flag) => Some(flag.load(Ordering::Relaxed)),
            Ready::Probe(addr) => Some(std::net::TcpStream::connect_timeout(addr, Duration::from_millis(200)).is_ok()),
        }
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
            ready: Mutex::new(None),
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

    /// Start an already-validated workload (used for child processes).
    pub(crate) fn start_prepared(self: &Arc<Self>, p: Prepared) -> (i64, Arc<Job>) {
        let handle = self.next.fetch_add(1, Ordering::SeqCst);
        let job = Arc::new(Job {
            status: Mutex::new(Status {
                handle,
                state: "starting",
                kind: Some(if p.component { "component" } else { "module" }),
                ..Default::default()
            }),
            ready: Mutex::new(None),
            started: Instant::now(),
            kill: AtomicBool::new(false),
            kill_notify: tokio::sync::Notify::new(),
        });
        self.jobs.lock().unwrap().insert(handle, job.clone());
        let me = self.clone();
        let j = job.clone();
        std::thread::Builder::new()
            .name(format!("workload-{handle}"))
            .spawn(move || me.run_thread(j, p))
            .expect("spawn workload thread");
        (handle, job)
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
            mounts.push(HostMount { host, guest: m.guest.clone(), readonly: m.readonly, compiler: m.compiler });
        }
        let stack = crate::rt::normalize_stack(spec.max_wasm_stack)?;
        let compiler = spec.compiler.unwrap_or_default();
        let rt = self.rts.get(compiler, stack)?;
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
            rt,
            persist: !spec.ephemeral,
            spawn: spec.spawn,
            tier_up: spec.tier_up,
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
            stdio: None,
            exit_notify: None,
            depth: 0,
            trace: None,
        })
    }

    fn run_thread(self: Arc<Self>, job: Arc<Job>, mut p: Prepared) {
        let rt = tokio::runtime::Builder::new_current_thread().enable_all().build().unwrap();
        let timeout = p.timeout;
        // Closed (EOF for the parent) only after the final status is set.
        let exit_notify = p.exit_notify.take();
        let trace = p.trace.take();
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
            Outcome::Failed(..) if job.kill.load(Ordering::SeqCst) => Outcome::Killed,
            Outcome::Failed(..) if timeout.is_some_and(|t| job.started.elapsed() >= t) => Outcome::Timeout,
            o => o,
        };
        match outcome {
            Outcome::Exited(c) => self.finish(&job, "exited", Some(c), None),
            Outcome::Failed(e, trap) => {
                job.status.lock().unwrap().trap = trap;
                self.finish(&job, "failed", None, Some(e))
            }
            Outcome::Killed => self.finish(&job, "killed", None, Some("killed".into())),
            Outcome::Timeout => self.finish(&job, "timeout", None, Some("timeout".into())),
        }
        // Drop the runtime (and with it any stdio stream tasks) before
        // signalling exit, so the parent sees output EOF promptly too.
        drop(rt);
        if let Some(path) = trace {
            let s = job.status();
            eprintln!(
                "[proc] pid={} {} {} code={:?} wall={:.0}ms load={:.1}ms cache={:?}{}",
                s.handle,
                path,
                s.state,
                s.exit_code,
                s.wall_ms,
                s.load_ms,
                s.cache,
                s.error.map(|e| format!(" error={e}")).unwrap_or_default()
            );
        }
        drop(exit_notify);
    }

    async fn run_workload(self: &Arc<Self>, job: &Arc<Job>, p: Prepared) -> Outcome {
        match self.run_inner(job, p).await {
            Ok(code) => Outcome::Exited(code),
            Err(e) => {
                let trap = e.downcast_ref::<wasmtime::Trap>().map(trap_name);
                Outcome::Failed(format!("{e:#}"), trap)
            }
        }
    }

    async fn run_inner(self: &Arc<Self>, job: &Arc<Job>, mut p: Prepared) -> Result<i32> {
        // Winch is a first tier for fresh modules; it rejects some
        // features (e.g. exceptions, components): fall back to Cranelift.
        let mut bg = None;
        let tiered = if p.tier_up && p.rt.compiler == Compiler::Winch {
            let crt = self.rts.get(Compiler::Cranelift, p.rt.stack)?;
            match self.cache.lookup(&crt, &p.module) {
                Some(l) => Some((crt, l)),
                None => {
                    // after the (fast) Winch compile below, so they don't compete
                    bg = Some(crt);
                    None
                }
            }
        } else {
            None
        };
        let (rt, loaded) = match tiered.map_or_else(|| self.cache.load(&p.rt, &p.module, p.persist).map(|l| (p.rt.clone(), l)), Ok) {
            Ok(x) => x,
            Err(e) if p.rt.compiler == Compiler::Winch => {
                let rt = self.rts.get(Compiler::Cranelift, p.rt.stack)?;
                let l = self.cache.load(&rt, &p.module, p.persist).map_err(|e2| e2.context(format!("winch: {e:#}")))?;
                (rt, l)
            }
            Err(e) => return Err(e),
        };
        if let Some(crt) = bg {
            self.cache.compile_background(crt, p.module.clone());
        }
        {
            let mut s = job.status.lock().unwrap();
            s.state = "running";
            s.load_ms = loaded.load_ms;
            s.cache = Some(loaded.cache);
            s.compiler = Some(rt.compiler);
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
        for m in &p.mounts {
            let perms = if m.readonly { FsPerms::ReadOnly } else { FsPerms::ReadWrite };
            b.preopened_dir(&m.host, &m.guest, perms)
                .map_err(anyhow::Error::from)
                .with_context(|| format!("mount {}", m.host.display()))?;
        }
        let stdio = match p.stdio.take() {
            Some(s) => s,
            None => [
                p.stdin.as_ref().map(std::fs::File::open).transpose()?,
                p.stdout.as_ref().map(std::fs::File::create).transpose()?,
                p.stderr.as_ref().map(std::fs::File::create).transpose()?,
            ]
            .map(|f| f.map_or(Stdio::Null, Stdio::File)),
        };
        // Keep copies so children can be handed this workload's stdio.
        let own_stdio = [stdio[0].try_clone()?, stdio[1].try_clone()?, stdio[2].try_clone()?];
        for (i, s) in stdio.into_iter().enumerate() {
            s.apply(&mut b, i as u8)?;
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
            if p.component {
                let ip = match bind_ip {
                    Some(ip) if !ip.is_unspecified() => ip,
                    _ => IpAddr::from([127, 0, 0, 1]),
                };
                *job.ready.lock().unwrap() = Some(Ready::Probe(SocketAddr::new(ip, port)));
            }
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
                    *job.ready.lock().unwrap() = Some(Ready::Accept(wasi.accept_called_flag()));
                }
                let proc = p.spawn.then(|| {
                    crate::proc::ProcCtx::new(self.clone(), p.mounts.clone(), own_stdio, p.memory_bytes, p.rt.stack, p.depth)
                });
                let mut store = Store::new(&rt.engine, WorkloadState { wasi, limits: limits(4), proc });
                store.limiter(|s| &mut s.limits);
                interruptible(&mut store, job);
                let instance = rt.linker.instantiate_async(&mut store, &module).await?;
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
                let mut store = Store::new(&rt.engine, state);
                store.limiter(|s| &mut s.limits);
                interruptible(&mut store, job);
                let cmd = wasmtime_wasi::p2::bindings::Command::instantiate_async(&mut store, &component, &rt.clinker)
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

/// snake_case name of a trap code ("StackOverflow" -> "stack_overflow").
fn trap_name(t: &wasmtime::Trap) -> String {
    let mut out = String::new();
    for (i, c) in format!("{t:?}").chars().enumerate() {
        if c.is_ascii_uppercase() {
            if i > 0 {
                out.push('_');
            }
            out.push(c.to_ascii_lowercase());
        } else {
            out.push(c);
        }
    }
    match out.as_str() {
        "unreachable_code_reached" => "unreachable".into(),
        _ => out,
    }
}

enum Outcome {
    Exited(i32),
    Failed(String, Option<String>),
    Killed,
    Timeout,
}

pub(crate) struct Prepared {
    pub module: PathBuf,
    pub component: bool,
    /// Engine to compile/run with (compiler + call-stack limit).
    pub rt: Arc<Rt>,
    /// Write the compiled module to the disk cache.
    pub persist: bool,
    /// Grant `wasmdev_proc` (process spawn).
    pub spawn: bool,
    /// See ExecSpec::tier_up.
    pub tier_up: bool,
    pub precompile_only: bool,
    pub args: Vec<String>,
    pub env: BTreeMap<String, String>,
    pub mounts: Vec<HostMount>,
    pub stdin: Option<PathBuf>,
    pub stdout: Option<PathBuf>,
    pub stderr: Option<PathBuf>,
    pub timeout: Option<Duration>,
    pub memory_bytes: usize,
    pub listener: Option<(u32, TcpListener)>,
    /// Stdio objects (child processes, `wasmdev-host exec`); overrides
    /// stdin/stdout/stderr paths.
    pub stdio: Option<[Stdio; 3]>,
    /// Dropped when the workload has finished (parent's exit fd -> EOF).
    pub exit_notify: Option<std::os::unix::net::UnixStream>,
    /// Process nesting depth (0 = started by the control plane).
    pub depth: u32,
    /// Log a one-line summary to stderr when done (WASMDEV_TRACE_PROC).
    pub trace: Option<String>,
}
