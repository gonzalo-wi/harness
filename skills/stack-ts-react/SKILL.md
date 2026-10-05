---
name: stack-ts-react
description: TypeScript and React web rules. Use it whenever you write, change or review web frontend .ts or .tsx files, or their tests.
---

# TypeScript + React

## TypeScript
- `strict` always. No `any`; if you don't know the type, use `unknown` and narrow it.
- No `as` to silence the compiler and no `@ts-ignore`. If one is needed, explain why in a comment.
- Explicit domain types; validate external data at the edge (e.g. zod if the project already uses it).
- Discriminated unions for states (`{ status: 'loading' } | { status: 'error'; error: E } | ...`).

## Structure
- Respect the project's structure. If it's feature-based (`features/<name>/{api,hooks,components,pages,types}`),
  new code goes in its feature; shared code only when two or more features use it.
- API calls in the `api/`/`services/` layer with the project's client; never mixed with UI.

## React
- Function components. Logic goes in hooks or pure modules; the component renders.
- Minimal state: whatever can be derived is derived. Don't duplicate server state in `useState`.
- `useEffect` only to sync with something external, not to derive state.
- Server data with the project's library (TanStack Query, etc.), not hand-rolled fetch in effects.
- Forms with the project's library (e.g. React Hook Form + zod) if it has one.
- Accessibility: semantic elements, labels on inputs, keyboard-manageable focus.
- Small components; typed props; no deep prop drilling (more than 3 levels: context or composition).
- UI text in the product's language (usually Spanish).

## Tests
- Vitest/Jest + React Testing Library. Test visible behavior (roles, text), not implementation.
- Pure logic with unit tests without rendering.

## Before closing a task
- `tsc --noEmit` clean, lint clean, tests green.
- ⚠️ Ask before adding dependencies.
