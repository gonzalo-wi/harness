---
name: stack-go
description: Go rules. Use it whenever you write, change or review .go files, go.mod or Go tests.
---

# Go

## Structure
Existing project: keep its layout. New project: hexagonal.
- `internal/domain/`: entities and business rules. No infrastructure imports.
- `internal/ports/` (or interfaces inside the domain): what the domain needs from the world.
- `internal/adapters/`: HTTP, DB, queues, external clients. They implement the ports.
- `cmd/<app>/`: wiring and `main`. The only place that knows every piece.
- Interfaces are defined where they're consumed, not where they're implemented. Small (1-3 methods).

## Code
- Errors: `fmt.Errorf("doing x: %w", err)`. Never `_ = err` or `panic` in business logic.
  Domain errors as values (`var ErrNotFound = errors.New(...)`) and `errors.Is/As`.
- `context.Context` as the first parameter of anything doing I/O. Never stored in structs.
- Time is injected (`func(now time.Time)` or a `Clock` interface). No `time.Now()` in the domain.
- No mutable global state and no `init()` with side effects.
- Concurrency: whoever starts a goroutine is responsible for it ending. Prefer `errgroup` over WaitGroup + hand-made channels.
- Short, clear names; no `utils`, `common` or `helpers` packages.

## Tests
- Table-driven with `t.Run`. External `_test` package to test the public API.
- Hand-written fakes for ports; generated mocks only if the project already uses them.
- `go test ./... -race` when there's concurrency.

## Before closing a task
- `gofmt` / `goimports` applied, `go vet ./...` clean, the project's linter clean, tests green.
- ⚠️ Ask before adding a new module to `go.mod`.
