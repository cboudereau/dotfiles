# Rust specifics

## Design rules

- Model absence with `Option`, failure with `Result`. No sentinel values.
- Prefer newtypes for domain identifiers and value objects over bare primitives.

## Before running anything

1. Check for a `Makefile` or `justfile`: some projects define their own build, test, and check flows. Use them.
2. Check `rust-toolchain.toml` for the expected toolchain.
3. Check `Cargo.toml` for `[workspace]`: use `--workspace`, and `-p <crate>` to scope to what changed.
4. Check `clippy.toml` and `.cargo/config.toml` for project lint settings.

## Fast feedback loop

`cargo check` type-checks without code generation: seconds instead of minutes.

- After **each file edit**, run `cargo check -p <crate>` before editing another file.
- Never run `cargo test` or `cargo build` on code that has not passed `cargo check`.
- If `cargo check` fails, fix it before moving on.

## Commands

```bash
cargo check -p <crate>                                  # after each edit
cargo test --workspace                                  # unit + integration
cargo nextest run --workspace --no-fail-fast            # if the project uses nextest
cargo test --doc --workspace                            # nextest does not run doc tests
cargo clippy --workspace --all-targets -- -D warnings   # lint
cargo fmt --all -- --check                              # format check
cargo build --release                                   # release build
```

## Coverage

Produce a Cobertura report so it reads the same as other stacks:

```bash
cargo tarpaulin --workspace --out xml                     # coverage/cobertura.xml
cargo llvm-cov --workspace --cobertura --output-path cobertura.xml
```

Read it to find uncovered lines and branches in the touched files; the
[`software-engineer`](SKILL.md) skill describes how to use it.
