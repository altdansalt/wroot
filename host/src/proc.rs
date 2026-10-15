//! Process spawn for wasip1 workloads (`wasmdev_proc` import module).
//!
//! Lets an unmodified tool driver running in wasm (Go's `cmd/go`, clang's
//! driver, ...) start *other wasm modules* as child processes, the way it
//! would `fork/exec` natively. The host only executes; the orchestration
//! (what to run, in which order, with what arguments) stays in the guest.
//!
//! Model (deliberately Unix-like, so a thin `syscall` shim in the guest's
//! libc/runtime is enough):
//! * the program is a guest path, resolved through the *caller's* preopens
//!   to a host file, which must be a wasm module (else `ENOEXEC`);
//! * the child gets exactly the caller's preopens (same guest paths and
//!   permissions, so absolute paths mean the same thing), the given argv and
//!   env, and `PWD=dir` (wasip1 has no cwd; Go and wasi-libc emulate it);
//! * child stdin/stdout/stderr are *caller fds* (any file, pipe or socket the
//!   caller holds, or its own stdio), or -1 for /dev/null;
//! * `spawn` never blocks. It returns a pid plus an "exit fd": a stream
//!   socket that becomes readable (EOF) when the child exits, so the guest
//!   can wait in its normal event loop (Go: netpoller via `poll_oneoff`)
//!   without freezing its single thread; `wait` then reaps the status;
//! * `pipe` creates a connected pair of non-blocking stream fds (Unix socket
//!   pair) for capturing child output; `open_null` gives a real /dev/null fd.
//! * children run on their own OS threads (true parallelism), use the shared
//!   compiled-module cache, and are killed when the parent goes away.
//!
//! All functions return a WASI errno (0 = success).

use crate::exec::{Exec, Job, Prepared, WorkloadState};
use anyhow::Result;
use std::collections::{BTreeMap, HashMap};
use std::os::fd::OwnedFd;
use std::os::unix::net::UnixStream;
use std::path::{Component, Path, PathBuf};
use std::sync::{Arc, OnceLock};
use wasmtime::{Caller, Extern, Linker};
use wasmtime_wasi::p1::HostFd;

// WASI errno values (wasi_snapshot_preview1).
const EACCES: i32 = 2;
const EAGAIN: i32 = 6;
const EBADF: i32 = 8;
const ECHILD: i32 = 12;
const EINVAL: i32 = 28;
const EIO: i32 = 29;
const EMFILE: i32 = 33;
const ENOENT: i32 = 44;
const ENOEXEC: i32 = 45;
const ESRCH: i32 = 70;

/// Max live (unreaped) children per process, and max nesting depth.
const MAX_CHILDREN: usize = 64;
const MAX_DEPTH: u32 = 8;
/// Guest pid = host job handle + PID_BASE (Go's wasip1 Getpid() is 3, and
/// Kill(Getpid()) means "exit self", so small pids must not be used).
const PID_BASE: i64 = 1000;

/// A source/sink for a workload's stdin/stdout/stderr.
pub enum Stdio {
    /// stdin: empty; stdout/stderr: discarded.
    Null,
    /// The host process's own stdio (0, 1 or 2); used by `wasmdev-host exec`.
    Inherit(u8),
    File(std::fs::File),
    /// A stream socket (pipe end or TCP connection).
    Socket(OwnedFd),
}

impl Stdio {
    pub fn try_clone(&self) -> std::io::Result<Stdio> {
        Ok(match self {
            Stdio::Null => Stdio::Null,
            Stdio::Inherit(n) => Stdio::Inherit(*n),
            Stdio::File(f) => Stdio::File(f.try_clone()?),
            Stdio::Socket(s) => Stdio::Socket(s.try_clone()?),
        })
    }

    /// Install as stdin (`which == 0`), stdout (1) or stderr (2). Must run
    /// inside the workload's tokio runtime (sockets register with it).
    pub fn apply(self, b: &mut wasmtime_wasi::WasiCtxBuilder, which: u8) -> Result<()> {
        use wasmtime_wasi::cli::{AsyncStdinStream, AsyncStdoutStream, InputFile, OutputFile};
        match (self, which) {
            (Stdio::Null, _) => {}
            (Stdio::Inherit(n), 0) => {
                if n == 0 {
                    b.inherit_stdin();
                }
            }
            (Stdio::Inherit(n), w) => {
                use wasmtime_wasi::cli::{stderr, stdout};
                match (w, n) {
                    (1, 2) => b.stdout(stderr()),
                    (1, _) => b.stdout(stdout()),
                    (_, 2) => b.stderr(stderr()),
                    (_, _) => b.stderr(stdout()),
                };
            }
            (Stdio::File(f), 0) => {
                b.stdin(InputFile::new(f));
            }
            (Stdio::File(f), 1) => {
                b.stdout(OutputFile::new(f));
            }
            (Stdio::File(f), _) => {
                b.stderr(OutputFile::new(f));
            }
            (Stdio::Socket(fd), w) => {
                let s = UnixStream::from(fd);
                s.set_nonblocking(true)?;
                let s = tokio::net::UnixStream::from_std(s)?;
                match w {
                    0 => {
                        b.stdin(AsyncStdinStream::new(s));
                    }
                    1 => {
                        b.stdout(AsyncStdoutStream::new(1 << 16, s));
                    }
                    _ => {
                        b.stderr(AsyncStdoutStream::new(1 << 16, s));
                    }
                }
            }
        }
        Ok(())
    }
}

/// Per-workload process state (stored in the workload's `Store`).
pub struct ProcCtx {
    pub exec: Arc<Exec>,
    /// The workload's preopens: (host dir, guest path, readonly).
    pub mounts: Vec<(PathBuf, String, bool)>,
    /// What this workload's own stdin/stdout/stderr are, so a child can be
    /// given "fd 1" of its parent.
    pub stdio: [Stdio; 3],
    pub memory_bytes: usize,
    pub depth: u32,
    children: HashMap<i32, Arc<Job>>,
}

impl ProcCtx {
    pub fn new(exec: Arc<Exec>, mounts: Vec<(PathBuf, String, bool)>, stdio: [Stdio; 3], memory_bytes: usize, depth: u32) -> Self {
        ProcCtx { exec, mounts, stdio, memory_bytes, depth, children: HashMap::new() }
    }

    /// Resolve an absolute guest path through the preopens to a host path
    /// (symlinks resolved; must stay inside the mount it was found in).
    fn resolve(&self, guest: &str) -> Result<PathBuf, i32> {
        let norm = normalize(guest).ok_or(ENOENT)?;
        let mut best: Option<(&PathBuf, PathBuf, usize)> = None;
        for (host, g, _) in &self.mounts {
            let Some(gn) = normalize(g) else { continue };
            if let Ok(rest) = norm.strip_prefix(&gn) {
                let depth = gn.components().count();
                if best.as_ref().is_none_or(|b| depth > b.2) {
                    best = Some((host, rest.to_path_buf(), depth));
                }
            }
        }
        let (host, rest, _) = best.ok_or(ENOENT)?;
        let p = host.join(rest).canonicalize().map_err(|_| ENOENT)?;
        if !p.starts_with(host) {
            return Err(EACCES);
        }
        Ok(p)
    }
}

impl Drop for ProcCtx {
    /// Children do not outlive their parent (no orphans/daemons).
    fn drop(&mut self) {
        for (pid, _) in self.children.drain() {
            self.exec.release(pid as i64 - PID_BASE);
        }
    }
}

/// Lexically normalize an absolute path ("/a/./b/../c" -> "/a/c").
fn normalize(p: &str) -> Option<PathBuf> {
    let p = Path::new(p);
    if !p.is_absolute() {
        return None;
    }
    let mut out = PathBuf::from("/");
    for c in p.components() {
        match c {
            Component::RootDir | Component::CurDir => {}
            Component::ParentDir => {
                out.pop();
            }
            Component::Normal(n) => out.push(n),
            Component::Prefix(_) => return None,
        }
    }
    Some(out)
}

fn trace() -> bool {
    static T: OnceLock<bool> = OnceLock::new();
    *T.get_or_init(|| std::env::var_os("WASMDEV_TRACE_PROC").is_some())
}

fn mem_read(c: &mut Caller<'_, WorkloadState>, ptr: i32, len: i32) -> wasmtime::Result<Vec<u8>> {
    let Some(Extern::Memory(mem)) = c.get_export("memory") else {
        wasmtime::bail!("module exports no memory");
    };
    let mut buf = vec![0u8; len as u32 as usize];
    mem.read(&c, ptr as u32 as usize, &mut buf)?;
    Ok(buf)
}

fn mem_write_i32(c: &mut Caller<'_, WorkloadState>, ptr: i32, v: i32) -> wasmtime::Result<()> {
    let Some(Extern::Memory(mem)) = c.get_export("memory") else {
        wasmtime::bail!("module exports no memory");
    };
    mem.write(c, ptr as u32 as usize, &v.to_le_bytes())?;
    Ok(())
}

/// Split a buffer of NUL-terminated strings.
fn split_nul(b: &[u8]) -> Result<Vec<String>, i32> {
    let mut v = Vec::new();
    if b.is_empty() {
        return Ok(v);
    }
    let b = b.strip_suffix(&[0]).unwrap_or(b);
    for s in b.split(|&c| c == 0) {
        v.push(String::from_utf8(s.to_vec()).map_err(|_| EINVAL)?);
    }
    Ok(v)
}

/// Unix-style wait status: exited -> code << 8; killed -> SIGKILL (9);
/// host failure (trap, bad module) -> SIGABRT (6).
fn wait_status(st: &crate::exec::Status) -> i32 {
    match st.state {
        "exited" => (st.exit_code.unwrap_or(0) & 0xff) << 8,
        "killed" | "timeout" => 9,
        _ => 6,
    }
}

pub fn add_to_linker(linker: &mut Linker<WorkloadState>) -> Result<()> {
    // spawn(path, argv, env, dir, stdin_fd, stdout_fd, stderr_fd, *pid, *exit_fd) -> errno
    // argv/env: concatenated NUL-terminated strings. fds: caller fds, -1 = /dev/null.
    linker.func_wrap(
        "wasmdev_proc",
        "spawn",
        |mut c: Caller<'_, WorkloadState>,
         path_p: i32,
         path_l: i32,
         argv_p: i32,
         argv_l: i32,
         env_p: i32,
         env_l: i32,
         dir_p: i32,
         dir_l: i32,
         fd0: i32,
         fd1: i32,
         fd2: i32,
         pid_out: i32,
         exitfd_out: i32|
         -> wasmtime::Result<i32> {
            let path = String::from_utf8(mem_read(&mut c, path_p, path_l)?).unwrap_or_default();
            let argv = mem_read(&mut c, argv_p, argv_l)?;
            let env = mem_read(&mut c, env_p, env_l)?;
            let dir = String::from_utf8(mem_read(&mut c, dir_p, dir_l)?).unwrap_or_default();
            match spawn(c.data_mut(), &path, &argv, &env, &dir, [fd0, fd1, fd2]) {
                Ok((pid, exitfd)) => {
                    mem_write_i32(&mut c, pid_out, pid)?;
                    mem_write_i32(&mut c, exitfd_out, exitfd as i32)?;
                    Ok(0)
                }
                Err(e) => Ok(e),
            }
        },
    )?;

    // wait(pid, nohang, *status) -> errno. EAGAIN if nohang and still
    // running. Reaps the child on success. The blocking form stalls the
    // whole guest; use it only after the exit fd reported EOF.
    linker.func_wrap_async(
        "wasmdev_proc",
        "wait",
        |mut c: Caller<'_, WorkloadState>, (pid, nohang, status_out): (i32, i32, i32)| {
            Box::new(async move {
                let Some(proc) = c.data().proc.as_ref() else { return Ok(ECHILD) };
                let Some(job) = proc.children.get(&pid).cloned() else { return Ok(ECHILD) };
                let st = loop {
                    let st = job.status();
                    if st.done {
                        break st;
                    }
                    if nohang != 0 {
                        return Ok(EAGAIN);
                    }
                    tokio::time::sleep(std::time::Duration::from_millis(1)).await;
                };
                let proc = c.data_mut().proc.as_mut().unwrap();
                proc.children.remove(&pid);
                proc.exec.release(pid as i64 - PID_BASE);
                mem_write_i32(&mut c, status_out, wait_status(&st))?;
                Ok(0)
            })
        },
    )?;

    // kill(pid, signal) -> errno. Any signal terminates the child.
    linker.func_wrap("wasmdev_proc", "kill", |c: Caller<'_, WorkloadState>, pid: i32, _sig: i32| {
        let Some(proc) = c.data().proc.as_ref() else { return Ok(ESRCH) };
        if !proc.children.contains_key(&pid) {
            return Ok(ESRCH);
        }
        proc.exec.kill(pid as i64 - PID_BASE);
        Ok(0)
    })?;

    // pipe(*fds[2]) -> errno. fds[0] read end, fds[1] write end (both are
    // ends of a Unix stream socket pair; non-blocking-capable, pollable).
    linker.func_wrap("wasmdev_proc", "pipe", |mut c: Caller<'_, WorkloadState>, fds_out: i32| {
        let Ok((r, w)) = UnixStream::pair() else { return Ok(EMFILE) };
        // A pipe is one-directional.
        let _ = r.shutdown(std::net::Shutdown::Write);
        let _ = w.shutdown(std::net::Shutdown::Read);
        let wasi = &mut c.data_mut().wasi;
        let (Ok(rfd), Ok(wfd)) = (wasi.wasmdev_push_unix(r), wasi.wasmdev_push_unix(w)) else {
            return Ok(EMFILE);
        };
        mem_write_i32(&mut c, fds_out, rfd as i32)?;
        mem_write_i32(&mut c, fds_out + 4, wfd as i32)?;
        Ok(0)
    })?;

    // open_null(write, *fd) -> errno. A real /dev/null.
    linker.func_wrap("wasmdev_proc", "open_null", |mut c: Caller<'_, WorkloadState>, write: i32, fd_out: i32| {
        let f = std::fs::OpenOptions::new().read(true).write(write != 0).open("/dev/null");
        let Ok(f) = f else { return Ok(EIO) };
        let Ok(fd) = c.data_mut().wasi.wasmdev_push_file(f, true, write != 0) else { return Ok(EMFILE) };
        mem_write_i32(&mut c, fd_out, fd as i32)?;
        Ok(0)
    })?;
    Ok(())
}

fn spawn(st: &mut WorkloadState, path: &str, argv: &[u8], env: &[u8], dir: &str, fds: [i32; 3]) -> Result<(i32, u32), i32> {
    let Some(proc) = st.proc.as_ref() else { return Err(ENOEXEC) };
    if proc.depth >= MAX_DEPTH || proc.children.len() >= MAX_CHILDREN {
        return Err(EAGAIN);
    }
    let module = proc.resolve(path)?;
    if !module.is_file() {
        return Err(EACCES);
    }
    let component = match crate::cache::is_component_file(&module) {
        Ok(c) => c,
        Err(_) => return Err(ENOEXEC),
    };
    let args = split_nul(argv)?;
    let mut envm = BTreeMap::new();
    for kv in split_nul(env)? {
        if let Some((k, v)) = kv.split_once('=') {
            envm.insert(k.to_string(), v.to_string());
        }
    }
    if !dir.is_empty() {
        let d = proc.resolve(dir)?;
        if !d.is_dir() {
            return Err(ENOENT);
        }
        envm.insert("PWD".into(), normalize(dir).unwrap().to_string_lossy().into_owned());
    }
    // Map the caller's fds to host objects for the child.
    let mut stdio: [Stdio; 3] = [Stdio::Null, Stdio::Null, Stdio::Null];
    for (i, &fd) in fds.iter().enumerate() {
        if fd < 0 {
            continue;
        }
        let h = st.wasi.wasmdev_host_fd(fd as u32).ok_or(EBADF)?;
        let proc = st.proc.as_ref().unwrap();
        stdio[i] = match h {
            HostFd::Stdin => proc.stdio[0].try_clone().map_err(|_| EMFILE)?,
            HostFd::Stdout => proc.stdio[1].try_clone().map_err(|_| EMFILE)?,
            HostFd::Stderr => proc.stdio[2].try_clone().map_err(|_| EMFILE)?,
            HostFd::File(f) => Stdio::File(f),
            HostFd::Socket(s) => Stdio::Socket(s),
        };
    }
    let (exit_guest, exit_host) = UnixStream::pair().map_err(|_| EMFILE)?;
    let _ = exit_guest.shutdown(std::net::Shutdown::Write);
    let exitfd = st.wasi.wasmdev_push_unix(exit_guest).map_err(|_| EMFILE)?;
    let proc = st.proc.as_mut().unwrap();
    let p = Prepared {
        module: module.clone(),
        component,
        precompile_only: false,
        args,
        env: envm,
        mounts: proc.mounts.clone(),
        stdin: None,
        stdout: None,
        stderr: None,
        timeout: None,
        memory_bytes: proc.memory_bytes,
        listener: None,
        stdio: Some(stdio),
        exit_notify: Some(exit_host),
        depth: proc.depth + 1,
        trace: trace().then(|| path.to_string()),
    };
    let (h, job) = proc.exec.start_prepared(p);
    let pid = (h + PID_BASE) as i32;
    proc.children.insert(pid, job);
    Ok((pid, exitfd))
}
