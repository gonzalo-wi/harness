# Lens: observability

**Question:** if this breaks in production at 3 a.m., can someone figure out what happened,
to whom, and why — from logs, errors and metrics alone, without reproducing it?

**Applies to:** backend code, jobs, integrations, and client-side error handling. Pure UI
markup or pure functions with no failure modes: answer `N/A` and stop.

## Checks
Blocking unless marked *(optional)*.

- **OBS-1 Errors carry context.** Logged/propagated errors say what was being done and with
  which identifiers (`"charging order 123 for user 45: gateway timeout"`), and keep the cause
  (stack trace / wrapped error). No `log.error(e.getMessage())` that drops the stack.
- **OBS-2 No sensitive data in logs.** No passwords, tokens, API keys, full card numbers,
  documents or personal data in logs, error messages or analytics events. Identifiers yes,
  payloads no.
- **OBS-3 Right level.** `error` = someone must act; `warn` = degraded but handled; `info` =
  business events worth knowing; `debug` = details. No errors logged as info, no expected
  validation failures logged as error, no per-request noise at info.
- **OBS-4 Log once.** An error is logged where it's handled, not at every layer it passes
  through (no log-and-rethrow chains producing 4 copies).
- **OBS-5 Correlation.** Requests carry a request/correlation ID through logs (MDC, context
  logger, header propagation to downstream calls) so one request's story can be followed.
- **OBS-6 Structured logs.** Key-value / structured fields (or the project's logger format),
  not string concatenation that can't be searched.
- **OBS-7 Client errors are reported.** Frontend/mobile errors that the user hits reach the
  project's error reporting (Sentry or similar) if it has one; error boundaries exist.
- **OBS-8 Business signals** *(optional)*: important flows (payments, sign-ups, bookings)
  emit a metric or an explicit info log on success and failure.
- **OBS-9 Health** *(optional)*: services expose health/readiness checks that reflect their
  real dependencies.

## Stack notes
- **Java/Spring:** SLF4J with placeholders (`log.error("charging order {}", id, ex)`, the
  exception as last argument); MDC for request ID; `@RestControllerAdvice` logs once;
  Actuator health if the project uses it.
- **Go:** `log/slog` (or the project's logger) with attributes; wrap with `%w` and log at the
  edge; request ID in `context`.
- **TS/React, Vue:** no `console.log` left in production code; error boundary
  (React) / `app.config.errorHandler` (Vue); API client interceptor reports unexpected errors.
- **React Native:** crash/error reporting configured; no PII in breadcrumbs.
- **Rust:** `tracing` with spans and fields if the project uses it; errors with context
  (`anyhow::Context`).

## Evidence
Each finding: `file:line` and what an on-call person would be missing ("this logs 'error' with
no order ID and no stack trace; you can't tell which order failed").
