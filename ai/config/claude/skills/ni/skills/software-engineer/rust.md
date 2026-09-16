# Rust specifics

Load the [`rust-build`](../rust-build/SKILL.md) skill for the commands.

- After **each file edit**, run `cargo check -p <crate>` before editing another file.
  It type-checks in seconds; `cargo build` and `cargo test` take minutes.
- Only run `cargo test` after `cargo check` passes.
- Model absence with `Option`, failure with `Result`. No sentinel values.
- Prefer newtypes for domain identifiers and value objects over bare primitives.
