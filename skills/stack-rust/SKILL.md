---
name: stack-rust
description: Rust rules. Use it whenever you write, change or review .rs files, Cargo.toml or Rust tests.
---

# Rust

- Errors: `thiserror` in libraries, `anyhow` in binaries (if the project already uses them). Add context when propagating.
- No `unwrap()`/`expect()` outside tests and invariants documented with a comment.
- Ownership: prefer borrows (`&T`, `&str`, `&[T]`) in parameters; clone only when needed and cheap or explicit.
- Domain with strong types (newtypes, enums) instead of loose `String`/`i64`.
- `unsafe` forbidden unless explicitly asked, with a `// SAFETY:` comment.
- Traits as ports; implementations in adapters (same hexagonal idea) in new projects;
  existing projects keep their structure.
- Async: don't block the runtime; blocking I/O in `spawn_blocking`.

## Tests
- Unit tests in `mod tests` next to the code; integration tests in `tests/`.

## Before closing a task
- `cargo fmt`, `cargo clippy -- -D warnings` and `cargo test` clean.
- ⚠️ Ask before adding crates.
