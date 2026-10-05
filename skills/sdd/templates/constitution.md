# Constitution — <Project>

Non-negotiable principles. Every spec, plan and task must comply with them.
(These are examples to adapt.)

1. **The spec rules**: nothing is implemented unless it's in the active spec. If a decision is missing, stop and ask.
2. **Architecture**: <the one the project has; e.g. layered controller → service → repository, or hexagonal where the domain doesn't import infrastructure>.
3. **Testable logic**: business logic does no I/O; time and external dependencies are injected.
4. **Tests are the gate**: `<test command>` green before moving on. Deleting or skipping tests is forbidden.
5. **Sacred data**: schema or format changes come with a migration and backward compatibility.
6. **Language**: code, docs and specs in English; UI in the product's language.

## Required audit lenses
<!-- Lenses /sdd-validate always runs (see /audit). Delete the ones that don't apply. -->
- resilience: <when; e.g. any spec that adds or changes an external integration>
- api: <when; e.g. any spec that changes an endpoint or DTO>
- performance: <when; e.g. any list or report over growing data>
- observability: <when; e.g. any new backend flow>
