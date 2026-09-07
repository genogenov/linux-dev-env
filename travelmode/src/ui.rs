//! Terminal output: colours when it is a terminal, plain text when piped.

use std::io::IsTerminal;
use std::sync::OnceLock;

fn colour() -> bool {
    static ON: OnceLock<bool> = OnceLock::new();
    *ON.get_or_init(|| std::env::var_os("NO_COLOR").is_none() && std::io::stdout().is_terminal())
}

fn paint(code: &str, text: &str) -> String {
    if colour() {
        format!("\x1b[{code}m{text}\x1b[0m")
    } else {
        text.to_string()
    }
}

pub fn bold(t: &str) -> String {
    paint("1", t)
}
pub fn green(t: &str) -> String {
    paint("1;32", t)
}
pub fn red(t: &str) -> String {
    paint("1;31", t)
}
pub fn dim(t: &str) -> String {
    paint("2", t)
}

/// A step that is being performed.
pub fn step(msg: &str) {
    println!("{} {}", paint("1;34", "::"), msg);
}

/// A step that was skipped on purpose, with the reason.
pub fn skip(msg: &str) {
    println!("{} {}", paint("1;33", "::"), msg);
}

pub fn warn(msg: &str) {
    eprintln!("{} {}", red("!!"), msg);
}

pub fn dry(cmd: &str) {
    println!("{} {}", paint("1;35", "++"), dim(cmd));
}

/// One aligned `label   value` line of `travelmode status`.
pub fn field(label: &str, value: &str) {
    println!("  {:<13} {}", dim(label), value);
}
