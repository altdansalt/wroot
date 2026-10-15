//! wasmdev patch: descriptor-table helpers for the host's process-spawn
//! capability (`wasmdev_proc` imports, see host/src/proc.rs).
//!
//! The host needs to (a) export a guest fd as a host object so it can become
//! a child process's stdin/stdout/stderr, and (b) insert new descriptors into
//! a guest's table: pipe ends and process "exit fds" (both are Unix stream
//! sockets, so Go's netpoller can wait on them through `poll_oneoff`) and a
//! `/dev/null` file.

use super::{BlockingMode, Descriptor, File, ResourceExt, WasiP1Ctx, socket};
use crate::filesystem::{self, OpenMode};
use crate::FsPerms;
use std::os::fd::OwnedFd;
use std::os::unix::net::UnixStream;

/// What a guest fd refers to, as far as a child process is concerned.
pub enum HostFd {
    /// The guest's own stdin/stdout/stderr (whatever the embedder gave it).
    Stdin,
    Stdout,
    Stderr,
    /// A regular file (or device) opened through the guest's preopens.
    File(std::fs::File),
    /// A socket: a pipe end, an accepted TCP connection, ...
    Socket(OwnedFd),
}

impl WasiP1Ctx {
    /// Duplicate the host object behind guest fd `fd`. `None` = bad fd or a
    /// kind that cannot be handed to a child (directories, listeners).
    pub fn wasmdev_host_fd(&mut self, fd: u32) -> Option<HostFd> {
        let t = self.transact().ok()?;
        match t.descriptors.used.get(&fd)? {
            Descriptor::Stdin { .. } => Some(HostFd::Stdin),
            Descriptor::Stdout { .. } => Some(HostFd::Stdout),
            Descriptor::Stderr { .. } => Some(HostFd::Stderr),
            Descriptor::File(File { fd: res, .. }) => {
                let res = res.borrowed();
                match t.view.table.get(&res).ok()? {
                    filesystem::Descriptor::File(f) => f.file.try_clone().ok().map(HostFd::File),
                    filesystem::Descriptor::Dir(_) => None,
                }
            }
            Descriptor::Socket(s) if !s.is_listener() => {
                use std::os::fd::{AsRawFd, BorrowedFd};
                // SAFETY: the fd is owned by `s`, which outlives this borrow.
                let fd = unsafe { BorrowedFd::borrow_raw(s.inner.get_ref().as_raw_fd()) };
                fd.try_clone_to_owned().ok().map(HostFd::Socket)
            }
            _ => None,
        }
    }

    /// Insert one end of a Unix stream socket pair (guest-visible blocking
    /// mode; Go switches it to non-blocking and polls it).
    pub fn wasmdev_push_unix(&mut self, s: UnixStream) -> std::io::Result<u32> {
        let sock = socket::Socket::new(socket::SockKind::Unix(s), false)?;
        let mut t = self.transact().map_err(|_| std::io::Error::other("wasi ctx"))?;
        t.descriptors
            .push(Descriptor::Socket(sock))
            .map_err(|_| std::io::Error::from_raw_os_error(24))
    }

    /// Insert an already-open host file (used for `/dev/null`).
    pub fn wasmdev_push_file(&mut self, f: std::fs::File, read: bool, write: bool) -> std::io::Result<u32> {
        let mut mode = OpenMode::empty();
        if read {
            mode |= OpenMode::READ;
        }
        if write {
            mode |= OpenMode::WRITE;
        }
        let perms = if write { FsPerms::ReadWrite } else { FsPerms::ReadOnly };
        let file = filesystem::File::new(f, perms, mode, true);
        let res = self
            .table
            .push(filesystem::Descriptor::File(file))
            .map_err(std::io::Error::other)?;
        let mut t = self.transact().map_err(|_| std::io::Error::other("wasi ctx"))?;
        t.descriptors
            .push(Descriptor::File(File {
                fd: res,
                position: Default::default(),
                append: false,
                blocking_mode: BlockingMode::Blocking,
            }))
            .map_err(|_| std::io::Error::from_raw_os_error(24))
    }
}
