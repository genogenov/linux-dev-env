//! Running external commands. Every state change on the machine goes through
//! here so that `--dry-run` can show it instead of doing it.

use anyhow::{bail, Context, Result};
use std::process::{Command, Stdio};

use crate::ui;

#[derive(Clone, Copy)]
pub struct Ctx {
    pub dry_run: bool,
}

impl Ctx {
    /// Run a command that changes system state. Failure aborts the caller.
    pub fn run(&self, prog: &str, args: &[&str]) -> Result<()> {
        if self.dry_run {
            ui::dry(&format!("{prog} {}", args.join(" ")));
            return Ok(());
        }
        let status = Command::new(prog)
            .args(args)
            .stdout(Stdio::null())
            .status()
            .with_context(|| format!("could not execute `{prog}`"))?;
        if !status.success() {
            bail!("`{prog} {}` failed with {status}", args.join(" "));
        }
        Ok(())
    }

    /// Run a best-effort tweak: a failure is reported but never aborts, so one
    /// broken wifi profile can not leave travel mode half-applied.
    pub fn try_run(&self, prog: &str, args: &[&str]) -> bool {
        match self.run(prog, args) {
            Ok(()) => true,
            Err(e) => {
                ui::warn(&format!("{e}"));
                false
            }
        }
    }
}

/// Run a read-only command and capture stdout. Always runs, dry-run included.
pub fn capture(prog: &str, args: &[&str]) -> Result<String> {
    let out = Command::new(prog)
        .args(args)
        .stderr(Stdio::null())
        .output()
        .with_context(|| format!("could not execute `{prog}`"))?;
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// Same, but a non-zero exit or a missing binary is just "no answer".
pub fn capture_opt(prog: &str, args: &[&str]) -> Option<String> {
    capture(prog, args).ok().filter(|s| !s.trim().is_empty())
}

/// Effective uid, read from /proc so the tool stays dependency-free.
pub fn euid() -> u32 {
    std::fs::read_to_string("/proc/self/status")
        .ok()
        .and_then(|s| {
            s.lines()
                .find(|l| l.starts_with("Uid:"))
                .and_then(|l| l.split_whitespace().nth(2)?.parse().ok())
        })
        .unwrap_or(u32::MAX)
}

/// A dry run only prints, so it needs no privileges.
pub fn require_root(ctx: &Ctx, action: &str) -> Result<()> {
    if !ctx.dry_run && euid() != 0 {
        bail!("`travelmode {action}` changes system units - run it with sudo");
    }
    Ok(())
}
