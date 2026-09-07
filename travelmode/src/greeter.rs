//! greetd. Travel mode wants no greeter on the next boot, and it gets there by
//! `disable` alone.
//!
//! Never `stop greetd` from anywhere that can run while a session is live:
//! greetd's session worker holds the PAM handle for the logged-in user, so on
//! SIGTERM pam_systemd releases the logind session and logind tears down the
//! session scope with Hyprland inside it. Confirmed on 2026-09-07: greeter
//! stopped at 00:41:56, `Session 3 logged out` in the same second.

use anyhow::Result;

use crate::sys::{self, Ctx};

pub const GREETER: &str = "greetd.service";

pub struct State {
    pub enabled: String,
    pub active: String,
}

impl State {
    pub fn is_active(&self) -> bool {
        self.active == "active"
    }
}

pub fn state() -> State {
    let one = |args: &[&str]| {
        sys::capture("systemctl", args)
            .unwrap_or_default()
            .trim()
            .to_string()
    };
    State {
        enabled: one(&["is-enabled", GREETER]),
        active: one(&["is-active", GREETER]),
    }
}

pub fn disable(ctx: &Ctx) -> Result<()> {
    ctx.run("systemctl", &["disable", GREETER])
}

pub fn enable(ctx: &Ctx) -> Result<()> {
    ctx.run("systemctl", &["enable", GREETER])
}

/// Starting greetd is safe for a live session, but it jumps the screen to VT1
/// (`vt: Specific(1), switch: true`), so the caller decides when to do it.
pub fn start(ctx: &Ctx) -> Result<()> {
    ctx.run("systemctl", &["start", "--no-block", GREETER])
}

/// The id of a live graphical session, if any - somebody is sitting at the
/// machine and would have the screen pulled out from under them.
pub fn graphical_session() -> Option<String> {
    let sessions = sys::capture("loginctl", &["list-sessions", "--no-legend"]).ok()?;
    sessions.lines().find_map(|line| {
        let id = line.split_whitespace().next()?;
        let ty = sys::capture("loginctl", &["show-session", id, "-p", "Type", "--value"]).ok()?;
        matches!(ty.trim(), "wayland" | "x11" | "mir").then(|| id.to_string())
    })
}
