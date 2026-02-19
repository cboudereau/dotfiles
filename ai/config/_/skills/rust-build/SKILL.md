---
name: rust-build
description: "Build, test, and check Rust projects using cargo and related tooling. Use when the user asks to build, compile, run tests, lint, or format a Rust project, or when working with Cargo.toml, Cargo.lock, or rust-toolchain.toml files."
---
# Build and test Rust

## When to use
- User asks to "build", "compile", or "check" a Rust project
- User asks to run Rust tests or unit tests
- User mentions "cargo build", "cargo test", "cargo clippy", or "cargo fmt"
- User references a `Cargo.toml`, `Cargo.lock`, or `rust-toolchain.toml` file
- User mentions "CI" in context of a Rust project

## Decision logic
1. Find the `Cargo.toml` at the workspace root
2. Read it to determine the project structure:
   - If it contains `[workspace]` with `members` → **workspace** project (use `--workspace` flags)
   - If it is a single `[package]` → **single crate** project
3. Check for a `Makefile` or `justfile` — some projects define custom build/test/check workflows
4. Check for `rust-toolchain.toml` to determine the expected Rust toolchain version
5. Use the appropriate build, test, and check commands below

## Build

```bash
cargo build
```

For release builds:
```bash
cargo build --release
```

## Test

### Unit tests
```bash
cargo test --workspace
```

If the project uses [cargo-nextest](https://nexte.st/) (preferred for large workspaces):
```bash
cargo nextest run --workspace --no-fail-fast
```

### Doc tests
cargo-nextest does not support doc tests, run them separately:
```bash
cargo test --doc --workspace
```

### Integration tests
Integration tests are typically behind feature flags or in a separate test target. Check the project's `Cargo.toml` and `CONTRIBUTING.md` for specifics:
```bash
cargo test --test integration
```

### Running a specific test
```bash
cargo test test_name
```

## Check and Lint

### Clippy (linter)
```bash
cargo clippy --workspace --all-targets -- -D warnings
```

Some projects define custom clippy configuration in `clippy.toml` or via `rustflags` in `.cargo/config.toml`. Always check these files first.

### Format check
```bash
cargo fmt --all -- --check
```

### Format fix
```bash
cargo fmt --all
```

## Code coverage

Use [cargo-tarpaulin](https://github.com/xd009642/tarpaulin) or [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov) for cobertura-compatible coverage:

```bash
cargo tarpaulin --workspace --out xml
```

Or with cargo-llvm-cov:
```bash
cargo llvm-cov --workspace --codecov --output-path codecov.json
```