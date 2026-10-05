# Lens: api

**Question:** is this contract (HTTP endpoints, events, public functions/types consumed by
other code) clear, consistent, validated at the edge, and safe to change without breaking
existing clients?

**Applies to:** controllers/handlers, DTOs, OpenAPI specs, events/messages, public library
APIs, and frontend API clients. If the target changes no contract, answer `N/A` and stop.

## Checks
Blocking unless marked *(optional)*.

- **API-1 Backward compatibility.** No removed or renamed fields, endpoints or enum values,
  no changed types or meaning, no new required fields, without a versioning/deprecation path.
  Any break is reported, even if intended: the global standard says to ask first.
- **API-2 Validation at the edge.** Every input (body, path, query, headers, messages) is
  validated before reaching business logic: types, required, ranges, lengths, formats.
- **API-3 Status codes and errors.** Correct semantics (200/201/204, 400 validation,
  401 unauthenticated, 403 forbidden, 404, 409 conflict, 422 if the project uses it, 5xx only
  for server faults) and one consistent error body shape across endpoints. No stack traces or
  internal messages in responses.
- **API-4 No internals leaked.** Persistence entities, internal IDs that shouldn't be public,
  or fields the caller doesn't need are not exposed; DTOs are explicit.
- **API-5 Authorization per endpoint.** Every new endpoint states who may call it, and
  resource-level checks exist (user A can't read user B's resource by changing an ID).
- **API-6 Consistency.** Naming, casing, pagination shape, date format (ISO-8601 with zone),
  money format and ID types match the rest of the API.
- **API-7 Safe methods.** GET has no side effects; PUT/DELETE are idempotent; non-idempotent
  POSTs that clients may retry accept an idempotency key (see RES-3).
- **API-8 Client in sync.** If the backend contract changed, the frontend/mobile types and
  API client changed with it (or the finding says what's out of sync).
- **API-9 Documentation** *(optional)*: OpenAPI/Swagger annotations or the project's API doc
  updated; examples for new endpoints.

## Stack notes
- **Java/Spring:** records + Bean Validation (`@Valid`, `@NotNull`, `@Size`...) on request
  DTOs; `@RestControllerAdvice` with one error shape; `ResponseEntity` codes explicit;
  springdoc annotations if the project uses Swagger.
- **Go:** decode with `DisallowUnknownFields` when strictness is wanted; validate before
  calling the domain; consistent error JSON.
- **TS/React, Vue, React Native:** API types live in one place per feature and match the
  backend; responses validated with zod (if the project uses it) at the client edge.
- **Rust:** serde with explicit `rename_all`, `deny_unknown_fields` where appropriate.

## Evidence
Each finding: `file:line`, which client breaks or what invalid input gets through
("removing `region` from `LoginResponse` breaks the web client, which reads it in AuthContext").
