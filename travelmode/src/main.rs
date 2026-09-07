//! travelmode - arm or disarm "the laptop stays home and stays reachable".
//!
//! Travel mode is three reversible facts about the machine:
//!   * a systemd-inhibit holding off sleep and the lid switch (stay-awake.service)
//!   * wifi power saving off, so the card stays associated while nobody is there
//!   * greetd disabled, so a reboot comes back without a greeter in the way
//!
//! `idle` is deliberately left out of the inhibitor: hypridle should still dim,
//! lock and blank the screen while the machine is awake and alone.

mod greeter;
mod sys;
mod ui;
mod unit;
mod wifi;

use anyhow::Result;
use clap::{Parser, Subcommand};

use sys::Ctx;

#[derive(Parser)]
#[command(
    name = "travelmode",
    about = "Keep this machine awake and reachable while you are away",
    version
)]
struct Cli {
    /// Print what would change instead of changing it
    #[arg(long, short = 'n', global = true)]
    dry_run: bool,

    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Arm travel mode: block sleep, pin wifi awake, no greeter on boot
    On,
    /// Disarm travel mode and put the machine back the way it lives at home
    Off {
        /// Start greetd even if a graphical session is live (jumps to VT1)
        #[arg(long)]
        start_greeter: bool,
    },
    /// Show what is currently armed
    Status,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let ctx = Ctx {
        dry_run: cli.dry_run,
    };

    match cli.command {
        Command::On => arm(&ctx),
        Command::Off { start_greeter } => disarm(&ctx, start_greeter),
        Command::Status => {
            status();
            Ok(())
        }
    }
}

fn arm(ctx: &Ctx) -> Result<()> {
    sys::require_root(ctx, "on")?;

    ui::step(&format!("disabling {} (not stopping it)", greeter::GREETER));
    greeter::disable(ctx)?;

    let (done, total) = wifi::hold_awake(ctx);
    ui::step(&format!(
        "wifi powersave off ({done}/{total} profiles, live association too)"
    ));

    ui::step(&format!("{} enabled and started", unit::UNIT));
    unit::arm(ctx)?;

    println!();
    status();
    Ok(())
}

fn disarm(ctx: &Ctx, force_greeter: bool) -> Result<()> {
    sys::require_root(ctx, "off")?;

    ui::step(&format!("{} stopped and disabled", unit::UNIT));
    unit::disarm(ctx)?;

    let (done, total) = wifi::restore(ctx);
    ui::step(&format!(
        "wifi powersave back to NetworkManager's default ({done}/{total} profiles)"
    ));

    ui::step(&format!("{} enabled", greeter::GREETER));
    greeter::enable(ctx)?;

    match greeter::graphical_session() {
        Some(id) if !force_greeter => ui::skip(format!(
            "not starting the greeter: session {id} is live and starting greetd \
             switches the screen to VT1. It comes up on the next boot, or run \
             `travelmode off --start-greeter`."
        )
        .as_str()),
        _ => {
            ui::step("starting the greeter");
            greeter::start(ctx)?;
        }
    }

    println!();
    status();
    Ok(())
}

fn status() {
    let u = unit::state();
    let g = greeter::state();

    let headline = if u.armed() {
        ui::green("ARMED")
    } else {
        ui::bold("off")
    };
    println!("  {:<13} {}", ui::dim("travel mode"), headline);

    let pid = u
        .main_pid
        .map(|p| format!("  pid {p}"))
        .unwrap_or_default();
    let file_state = if u.file_state.is_empty() {
        "not installed".into()
    } else {
        u.file_state.clone()
    };
    ui::field(
        "stay-awake",
        &format!("{}, {}{}", u.active_state, file_state, ui::dim(&pid)),
    );

    if let Some(what) = u.inhibits() {
        ui::field("inhibiting", &what.replace(':', ", "));
    }

    ui::field("greetd", &format!("{}, {}", g.enabled, g.active));

    for d in wifi::devices() {
        let live = wifi::live_powersave(&d).unwrap_or_else(|| "unknown".into());
        ui::field("wifi", &format!("{d}  power_save {live}"));
    }

    // Things that are true but easy to miss, and each one has bitten before.
    if u.armed() && !u.enabled() {
        ui::warn("stay-awake is running but not enabled - the next boot will not be in travel mode");
    }
    if !u.armed() && u.enabled() {
        ui::warn("stay-awake is enabled but not running - the next boot will re-arm travel mode");
    }
    if u.needs_reload {
        ui::warn("systemd has not reloaded the unit: what is running is not what is on disk (`systemctl daemon-reload`)");
    }
    if std::path::Path::new(unit::LEGACY_DROPIN_DIR).exists() {
        ui::warn(&format!(
            "leftover {} - travel mode's side effects live in this tool now, that drop-in should go",
            unit::LEGACY_DROPIN_DIR
        ));
    }
    if u.armed() && g.is_active() {
        ui::warn("greetd is running while travel mode is armed - a reboot would land on the greeter");
    }
}
