//! wasmdev patch: minimal WASIp1 socket support for host-preopened TCP
//! listeners and the connections accepted from them.
//!
//! Upstream wasmtime-wasi (>= 47) dropped the legacy `wasi-common` p1
//! implementation, and its p2-backed p1 adapter returns `ENOTSOCK` for all
//! `sock_*` calls. Programs built for wasip1 (Go's `net.FileListener`, Rust's
//! `TcpListener::from_raw_fd`) need exactly this subset:
//!
//! * `sock_accept` on a preopened listener (only way to get a socket in p1),
//! * `fd_read`/`fd_write`/`sock_recv`/`sock_send`/`sock_shutdown`/`fd_close`
//!   on the accepted stream,
//! * `fd_fdstat_get`/`fd_fdstat_set_flags` (filetype + NONBLOCK emulation),
//! * `poll_oneoff` FD_READ/FD_WRITE readiness (Go's netpoller).
//!
//! The OS socket is always non-blocking; the guest-visible NONBLOCK flag is
//! emulated: in "blocking" mode we await readiness on the tokio reactor,
//! which keeps the wasmtime async call cancellable (kill/timeout).

use super::types;
use std::io::{self, Read, Write};
use std::net::{Shutdown, TcpListener, TcpStream};
use std::os::fd::{AsRawFd, RawFd};
use std::sync::Arc;
use tokio::io::Interest;
use tokio::io::unix::AsyncFd;

#[derive(Debug)]
pub(super) enum SockKind {
    Listener(TcpListener),
    Stream(TcpStream),
}

impl AsRawFd for SockKind {
    fn as_raw_fd(&self) -> RawFd {
        match self {
            SockKind::Listener(l) => l.as_raw_fd(),
            SockKind::Stream(s) => s.as_raw_fd(),
        }
    }
}

#[derive(Debug, Clone)]
pub(super) struct Socket {
    pub(super) inner: Arc<AsyncFd<SockKind>>,
    /// Guest-visible NONBLOCK flag.
    pub(super) nonblocking: bool,
}

impl Socket {
    pub(super) fn new(kind: SockKind, nonblocking: bool) -> io::Result<Socket> {
        match &kind {
            SockKind::Listener(l) => l.set_nonblocking(true)?,
            SockKind::Stream(s) => {
                s.set_nonblocking(true)?;
                // Match native Go/most runtimes: wasip1 guests cannot call
                // setsockopt, and Nagle + delayed ACK adds ~40-80ms stalls
                // to small request/response exchanges.
                s.set_nodelay(true)?;
            }
        }
        #[allow(deprecated)]
        let inner = crate::runtime::with_ambient_tokio_runtime(|| AsyncFd::new(kind))?;
        Ok(Socket {
            inner: Arc::new(inner),
            nonblocking,
        })
    }

    pub(super) fn is_listener(&self) -> bool {
        matches!(self.inner.get_ref(), SockKind::Listener(_))
    }

    async fn io<R>(
        &self,
        interest: Interest,
        mut f: impl FnMut(&SockKind) -> io::Result<R>,
    ) -> io::Result<R> {
        if self.nonblocking {
            return self.inner.try_io(interest, |k| f(k));
        }
        loop {
            let mut guard = self.inner.ready(interest).await?;
            match guard.try_io(|fd| f(fd.get_ref())) {
                Ok(r) => return r,
                Err(_would_block) => continue,
            }
        }
    }

    pub(super) async fn accept(&self) -> io::Result<TcpStream> {
        self.io(Interest::READABLE, |k| match k {
            SockKind::Listener(l) => l.accept().map(|(s, _)| s),
            SockKind::Stream(_) => Err(io::Error::from_raw_os_error(libc_einval())),
        })
        .await
    }

    pub(super) async fn read(&self, buf: &mut [u8]) -> io::Result<usize> {
        self.io(Interest::READABLE, |k| match k {
            SockKind::Stream(s) => {
                let mut s: &TcpStream = s;
                s.read(buf)
            }
            SockKind::Listener(_) => Err(io::Error::from(io::ErrorKind::NotConnected)),
        })
        .await
    }

    pub(super) async fn write(&self, buf: &[u8]) -> io::Result<usize> {
        self.io(Interest::WRITABLE, |k| match k {
            SockKind::Stream(s) => {
                let mut s: &TcpStream = s;
                s.write(buf)
            }
            SockKind::Listener(_) => Err(io::Error::from(io::ErrorKind::NotConnected)),
        })
        .await
    }

    pub(super) fn shutdown(&self, how: Shutdown) -> io::Result<()> {
        match self.inner.get_ref() {
            SockKind::Stream(s) => s.shutdown(how),
            SockKind::Listener(_) => Err(io::Error::from(io::ErrorKind::NotConnected)),
        }
    }
}

fn libc_einval() -> i32 {
    22
}

/// A `Pollable` used by `poll_oneoff` to wait for socket readiness.
pub(super) struct SocketReady {
    pub(super) sock: Arc<AsyncFd<SockKind>>,
    pub(super) interest: Interest,
}

#[async_trait::async_trait]
impl wasmtime_wasi_io::poll::Pollable for SocketReady {
    async fn ready(&mut self) {
        // Leave readiness set: the guest has not consumed it yet. It is
        // cleared by `try_io` when an operation hits EWOULDBLOCK.
        let _ = self.sock.ready(self.interest).await;
    }
}

pub(super) fn errno(e: io::Error) -> types::Error {
    use io::ErrorKind as K;
    let errno = match e.kind() {
        K::WouldBlock => types::Errno::Again,
        K::Interrupted => types::Errno::Intr,
        K::ConnectionReset => types::Errno::Connreset,
        K::ConnectionAborted => types::Errno::Connaborted,
        K::BrokenPipe => types::Errno::Pipe,
        K::NotConnected => types::Errno::Notconn,
        K::InvalidInput => types::Errno::Inval,
        K::OutOfMemory => types::Errno::Nomem,
        _ => match e.raw_os_error() {
            Some(22) => types::Errno::Inval,
            Some(24) | Some(23) => types::Errno::Nfile,
            _ => types::Errno::Io,
        },
    };
    errno.into()
}

pub(super) fn stream_fdstat(sock: &Socket) -> types::Fdstat {
    let rights = types::Rights::FD_READ
        | types::Rights::FD_WRITE
        | types::Rights::FD_FDSTAT_SET_FLAGS
        | types::Rights::POLL_FD_READWRITE
        | types::Rights::SOCK_SHUTDOWN
        | types::Rights::SOCK_ACCEPT
        | types::Rights::FD_FILESTAT_GET;
    types::Fdstat {
        fs_filetype: types::Filetype::SocketStream,
        fs_flags: if sock.nonblocking {
            types::Fdflags::NONBLOCK
        } else {
            types::Fdflags::empty()
        },
        fs_rights_base: rights,
        fs_rights_inheriting: rights,
    }
}
