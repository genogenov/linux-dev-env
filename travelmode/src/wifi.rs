//! Wifi power saving. The card must stay associated while the laptop sits at
//! home unattended, otherwise the SSH-over-WireGuard route it exists for dies
//! between pings.
//!
//! Both halves are needed: `nmcli connection modify` persists the setting into
//! the profile for the next connect, and `iw dev` changes the association that
//! is up right now - `nmcli modify` alone does not touch it.

use crate::sys::{self, Ctx};

/// nmcli's wifi.powersave values.
const DISABLE: &str = "2";
const USE_DEFAULT: &str = "0";

/// `nmcli -t` escapes field separators; undo that for the one field we read.
fn unescape(s: &str) -> String {
    s.replace("\\:", ":").replace("\\\\", "\\")
}

/// Wifi connection profiles, by name. Asking `TYPE,NAME` (not `NAME,TYPE`)
/// keeps the name last, so a colon inside it can not be mistaken for the
/// separator.
pub fn profiles() -> Vec<String> {
    sys::capture("nmcli", &["-t", "-f", "TYPE,NAME", "connection", "show"])
        .unwrap_or_default()
        .lines()
        .filter_map(|l| l.strip_prefix("802-11-wireless:"))
        .map(unescape)
        .collect()
}

/// Wifi devices, excluding the p2p pseudo-devices NetworkManager reports.
pub fn devices() -> Vec<String> {
    sys::capture("nmcli", &["-t", "-f", "TYPE,DEVICE", "device", "status"])
        .unwrap_or_default()
        .lines()
        .filter_map(|l| l.strip_prefix("wifi:"))
        .map(unescape)
        .collect()
}

/// Live power_save state of a device, as `iw` reports it ("on" / "off").
pub fn live_powersave(dev: &str) -> Option<String> {
    let out = sys::capture_opt("iw", &["dev", dev, "get", "power_save"])?;
    out.split(':').nth(1).map(|v| v.trim().to_string())
}

fn apply(ctx: &Ctx, nm_value: &str, iw_value: &str) -> (usize, usize) {
    let profiles = profiles();
    let mut done = 0;
    for p in &profiles {
        if ctx.try_run(
            "nmcli",
            &["connection", "modify", p, "wifi.powersave", nm_value],
        ) {
            done += 1;
        }
    }
    for d in devices() {
        ctx.try_run("iw", &["dev", &d, "set", "power_save", iw_value]);
    }
    (done, profiles.len())
}

/// Travel mode: powersave off, in the profiles and on the live association.
pub fn hold_awake(ctx: &Ctx) -> (usize, usize) {
    apply(ctx, DISABLE, "off")
}

/// Home again: hand the decision back to NetworkManager's default.
pub fn restore(ctx: &Ctx) -> (usize, usize) {
    apply(ctx, USE_DEFAULT, "on")
}
