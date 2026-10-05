---
name: stack-java
description: Java and Spring Boot rules (Maven/Gradle). Use it whenever you write, change or review .java files, pom.xml, build.gradle, application.properties/yml or Java tests.
---

# Java + Spring Boot

## Structure
- Existing project: keep its structure (usually controller → service (interface + impl) →
  mapper → repository → model). New code goes in the matching layer and package.
- New project: hexagonal.
  - `domain/`: entities, value objects and domain services. No Spring, JPA or Jackson annotations.
  - `application/`: use cases and ports (`port/in`, `port/out`).
  - `infrastructure/` (or `adapter/`): controllers, JPA repositories, HTTP clients, messaging.
- In either case: JPA entities are never exposed by the API; map them to DTOs.
- If the project has ArchUnit, respect its rules; if not, don't add it without asking.

## Code
- Constructor injection (no `@Autowired` on fields). `final` fields.
- Records for DTOs and immutable value objects.
- `Optional` only as a return type, never as a parameter or field.
- Own domain exceptions; no empty `catch (Exception e)` and no `e.printStackTrace()`.
- Logging with SLF4J (`log.error("context", ex)`), never `System.out`.
- Time is injected with `java.time.Clock`. No `LocalDateTime.now()` in business logic.
- Validation at the edge (DTOs with Bean Validation); invariants in the domain.
- No business logic in controllers. Long entity-building blocks go to private `build*` methods.

## Spring
- Credentials and secrets via `${ENV_VAR:default}` in `application.properties`; never in plain text.
- `spring.jpa.open-in-view=false` and `spring.jpa.show-sql=false`.
- Every read-only service method carries `@Transactional(readOnly = true)`; writes use `@Transactional`.
- CORS allowed origins come from a property (e.g. `app.cors.allowed-origins`), not hardcoded.
- Security default-deny (`anyRequest().authenticated()`); 401 = not authenticated, 403 = not allowed.
- A `@RestControllerAdvice` translates exceptions to HTTP responses and logs them with SLF4J.
- Schema changes with migrations (Flyway/Liquibase) if the project uses them; never `ddl-auto=update` in prod.

## Tests
- JUnit 5 + AssertJ. Domain/service logic with pure unit tests (no Spring context).
- Mockito only for outgoing ports/repositories. `@SpringBootTest` only for integration tests;
  prefer slices (`@WebMvcTest`, `@DataJpaTest`).
- Descriptive names: `shouldRejectPolicyWhenCoverageExpired`.

## Before closing a task
- Compiles, tests green, the project's formatter (Spotless/Checkstyle) clean.
- ⚠️ Ask before adding dependencies to `pom.xml` / `build.gradle`.
