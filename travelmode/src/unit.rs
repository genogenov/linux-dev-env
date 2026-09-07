//! The stay-awake unit: a plain systemd-inhibit holder. All of travel mode's
//! reversible side effects live in this tool, not in the unit, so a restart of
//! the inhibitor never flaps wifi or the greeter.

use anyhow::Result;

use crate::sys::{self, Ctx};

pub const UNIT: &str = "stay-awake.service";

/// The old design carried these side effects as ExecStartPre/ExecStopPost.
pub const LEGACY_DROPIN_DIR: &str = "/etc/systemd/system/stay-awake.service.d";

pub struct State {
    pub active_state: String,
    pub file_state: String,
    pub main_pid: Option<u32>,
    pub needs_reload: bool,
}

impl State {
    pub fn armed(&self) -> bool {
        self.active_state == "active"
    }
    pub fn enabled(&self) -> bool {
        self.file_state == "enabled"
    }
    /// What the running inhibitor actually blocks, read from its command line -
    /// the unit on disk can have been edited since it started.
    pub fn inhibits(&self) -> Option<String> {
        let pid = self.main_pid?;
        let raw = std::fs::read_to_string(format!("/proc/{pid}/cmdline")).ok()?;
        raw.split('\0')
            .find_map(|a| a.strip_prefix("--what=").map(str::to_string))
    }
}

pub fn state() -> State {
    let out = sys::capture(
        "systemctl",
        &[
            "show",
            UNIT,
            "-p",
            "ActiveState",
            "-p",
            "UnitFileState",
            "-p",
            "MainPID",
            "-p",
            "NeedDaemonReload",
        ],
    )
    .unwrap_or_default();

    let get = |key: &str| -> String {
        out.lines()
            .find_map(|l| l.strip_prefix(key)?.strip_prefix('='))
            .unwrap_or_default()
            .to_string()
    };

    State {
        active_state: get("ActiveState"),
        file_state: get("UnitFileState"),
        main_pid: get("MainPID").parse().ok().filter(|p| *p != 0),
        needs_reload: get("NeedDaemonReload") == "yes",
    }
}

/// Enable so the next boot re-arms, and start now. One verb, both effects.
pub fn arm(ctx: &Ctx) -> Result<()> {
    ctx.run("systemctl", &["enable", "--now", UNIT])
}

/// Disable so the next boot stays out of travel mode, and stop now. `stop`
/// alone would let the next boot silently re-arm.
pub fn disarm(ctx: &Ctx) -> Result<()> {
    ctx.run("systemctl", &["disable", "--now", UNIT])
}
