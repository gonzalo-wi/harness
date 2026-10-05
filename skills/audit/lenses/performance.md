# Lens: performance

**Question:** does this code do work proportional to what's needed, or does it waste time,
queries, memory or renders in a way that will hurt at real data sizes?

**Rule zero — evidence first.** Only report what you can justify: a query count, an
algorithmic complexity tied to a realistic data size, a measured number, or a well-known
anti-pattern on a hot path. No micro-optimizations, no "this could be faster". If nothing
qualifies, say `No findings` — that's a valid result.

## Checks
Blocking unless marked *(optional)*.

- **PERF-1 N+1.** No query (or HTTP call) inside a loop over results. Use joins, fetch joins,
  `IN (...)` batches, DataLoader-style batching, or a bulk endpoint.
- **PERF-2 Unbounded reads.** Lists that grow with users/data are paginated (and the page
  size is capped server-side). No `findAll()` / `SELECT *` without limit on growing tables.
- **PERF-3 Indexes.** New filters, joins, sorts or unique checks on large tables have a
  matching index (or the finding says which one is missing).
- **PERF-4 Algorithmic complexity.** No O(n²) over collections that can be large (nested
  `find`/`filter`/`includes` inside loops → use a Map/Set).
- **PERF-5 Repeated work.** The same expensive call or computation isn't repeated per item or
  per render when it could be done once (hoist, memoize, cache with a clear invalidation).
- **PERF-6 Over-fetching.** Endpoints and queries return what the caller uses, not entire
  entity graphs (DTO projections, selected columns, no lazy-loading during serialization).
- **PERF-7 Frontend rendering.** No state updates that re-render large trees on every
  keystroke; long lists are virtualized; expensive derived values are memoized; no effects
  that trigger render loops.
- **PERF-8 Payload and bundle** *(optional)*: big dependencies imported for one function,
  non-lazy routes, unoptimized images.
- **PERF-9 Caching** *(optional)*: obvious cache opportunities for read-heavy, rarely-changing
  data — always with the invalidation story spelled out.

## Stack notes
- **Java/Spring/JPA:** watch `@OneToMany`/`@ManyToOne` lazy loads inside loops or in
  mappers (classic N+1); prefer `JOIN FETCH`/`@EntityGraph` or DTO projections; `Pageable`
  on list endpoints; `@Transactional(readOnly = true)` on reads.
- **Go:** preallocate slices when the size is known; avoid `[]byte`↔`string` conversions in hot
  loops; `rows.Close()` and reuse of prepared statements.
- **TS/React:** stable keys; `useMemo`/`useCallback` only where profiling or list props
  justify it; TanStack Query `select`/`staleTime` instead of refetch storms.
- **Vue:** `computed` over methods in templates; `v-memo`/`shallowRef` for large lists or
  objects; no deep watchers on big structures.
- **React Native:** `FlatList`/`FlashList` with `keyExtractor`, `getItemLayout` when possible;
  no heavy work on the JS thread during animations.
- **Rust:** avoid needless `clone()` in hot paths; iterators over index loops; `Vec::with_capacity`.

## Evidence
Each finding: `file:line`, the cost ("1 + N queries; with 500 projects that's 501 queries per
page load"), and the fix direction.
