# Lens: resilience

**Question:** when a dependency is slow, down, or answers garbage, does this code fail in a
controlled, recoverable way, without corrupting data or taking the rest of the system down?

**Applies to:** calls to other services, DBs, queues, files, the network, scheduled jobs,
and the client side of all that (web/mobile). If the target has none of that, answer
`N/A — no external dependencies in scope` and stop.

## Checks
Blocking unless marked *(optional)*.

- **RES-1 Timeouts.** Every outgoing call (HTTP, DB, queue, gRPC) has an explicit timeout,
  shorter than the caller's own timeout. No library defaults that mean "wait forever".
- **RES-2 Retries done right.** Retries only on transient errors (timeouts, 5xx, 429,
  connection reset), never on 4xx or validation errors. Bounded attempts, exponential
  backoff with jitter, honoring `Retry-After`. No retries stacked at several layers.
- **RES-3 Idempotency.** Anything retried, or triggered by a user who may double-click or
  a message that may be delivered twice, is idempotent (idempotency key, upsert, unique
  constraint, or a state check).
- **RES-4 Partial failure.** Multi-step operations don't leave half-written state: one
  transaction, or an outbox/compensation, or an explicit and recoverable intermediate state.
  No remote calls inside an open DB transaction.
- **RES-5 Errors are handled where they can be acted on.** No swallowed errors, no generic
  catch that turns every failure into the same 500. The user/caller gets a distinguishable
  outcome (retry later vs. fix your input vs. not found).
- **RES-6 Degradation.** A non-critical dependency being down doesn't break the critical path
  (fallback, cached value, feature hidden, clear message).
- **RES-7 Bounded resources.** Pools, queues, concurrency and in-memory buffers have limits;
  no unbounded fan-out (`Promise.all` over user-sized lists, a goroutine per item, etc.).
- **RES-8 Cleanup.** Connections, files, streams, subscriptions and timers are released on
  every path, including errors and cancellation.
- **RES-9 Circuit breaking** *(optional)*: hot paths to a flaky dependency stop calling it
  for a while after repeated failures.
- **RES-10 Startup and config** *(optional)*: missing or invalid config fails fast at startup
  with a clear message, not on the first request.

## Stack notes
- **Java/Spring:** timeouts on `RestClient`/`WebClient`/`RestTemplate` (connect + read) and
  on the JDBC pool (`connectionTimeout`); Resilience4j only if the project already uses it.
  `@Transactional` methods don't call remote services. `@Retryable` only on idempotent methods.
- **Go:** every I/O takes a `context.Context` with deadline; `http.Client{Timeout: ...}`,
  never `http.DefaultClient` for outgoing calls; `defer resp.Body.Close()`.
- **TS/React, Vue:** fetch/axios with timeout (`AbortController`/`timeout`); TanStack Query
  retry only for idempotent queries, not mutations; loading/error/retry UI for every request;
  cancel requests on unmount/route change.
- **React Native:** assume offline: NetInfo-aware flows, queued or blocked mutations with a
  clear message, no infinite spinners; secure storage survives app kills.
- **Rust:** timeouts via `tokio::time::timeout` or client config; no `unwrap()` on I/O results.

## Evidence
Each finding points to `file:line` and names the concrete failure: "if X is down for 30 s,
this request hangs the worker forever" — not "could be more resilient".
