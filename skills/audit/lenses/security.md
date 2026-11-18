# Lens: security

**Question:** can someone read, change or trigger something they shouldn't through this change,
and does it handle credentials and untrusted input safely?

**Applies to:** authentication and sessions, authorization checks, endpoints and handlers, anything
that builds queries, commands, paths or HTML from input, file uploads, webhooks and callbacks,
outbound calls to URLs that come from input, secrets and config, and dependencies added or bumped.
If the target touches none of these, answer `N/A` and stop.

## Checks
Blocking unless marked *(optional)*.

- **SEC-1 Authorization per resource.** Every read or write checks that the caller may act on THAT
  resource, not only that they're logged in: changing an ID in the path, body or query must not
  reach another user's or another tenant's data. The check lives server-side, never only in the UI.
- **SEC-2 Authentication and sessions.** Tokens are verified (signature, expiry, audience/issuer);
  short-lived access tokens with refresh; logout and password change invalidate what they should;
  passwords hashed with a slow algorithm (argon2id, bcrypt, scrypt); login and code-verification
  endpoints are rate limited.
- **SEC-3 Injection.** No SQL, shell, LDAP, template or path built by concatenating input:
  parameterized queries, argument arrays instead of shell strings, paths resolved and checked
  against a base folder. Output to HTML is escaped by the framework, no raw HTML from input.
- **SEC-4 Secrets.** No credentials, tokens or keys in code, tests, fixtures, logs, error messages,
  frontend bundles (`VITE_*`, `EXPO_PUBLIC_*`, `NEXT_PUBLIC_*`) or commits. They come from the
  environment or a secret manager.
- **SEC-5 Webhooks and callbacks.** Signature or shared secret verified before doing anything,
  replay protection (timestamp or event ID), processed idempotently so the same event twice doesn't
  apply twice.
- **SEC-6 Sensitive data exposure.** Responses, logs and analytics don't carry more personal data
  than needed (documents, phones, addresses, balances); errors don't reveal stack traces, queries
  or whether an account exists when that matters.
- **SEC-7 Outbound requests.** URLs built from input are restricted to an allowlist of hosts
  (no SSRF to internal addresses or cloud metadata); timeouts set; TLS verification never disabled.
- **SEC-8 Uploads and files.** Size and type limits checked server-side, stored outside the web
  root with generated names, never executed or served with a type the user chose.
- **SEC-9 Mass assignment.** Request DTOs are explicit: a client can't set fields like `role`,
  `tenant_id`, `owner_id`, `balance` or `status` by adding them to the body.
- **SEC-10 Dependencies** *(optional)*: new or bumped dependencies are maintained and free of known
  vulnerabilities (`govulncheck`, `npm audit`, `cargo audit`, OWASP dependency-check).

## Stack notes
- **Go:** `database/sql`/pgx/sqlc parameters, never `fmt.Sprintf` into SQL; `exec.Command` with
  separate args; `filepath.Clean` + prefix check against the base dir; `crypto/subtle` for
  constant-time comparisons of tokens and signatures.
- **Java/Spring:** Spring Security method or request rules per endpoint plus resource ownership
  checks in the service; JPA parameters or named queries, never string-built JPQL; records as DTOs.
- **TS/React, Vue, React Native:** never `dangerouslySetInnerHTML` / `v-html` with input; tokens in
  `expo-secure-store` or httpOnly cookies, not localStorage/AsyncStorage; nothing secret in the bundle.
- **Rust:** sqlx/diesel parameters; `std::process::Command` args; no `unsafe` in input handling.

## Evidence
Each finding: `file:line`, who can do what they shouldn't, and how ("a driver of tenant A can call
`GET /clientes/{id}` with an ID of tenant B: the query filters by id only, not by tenant").
