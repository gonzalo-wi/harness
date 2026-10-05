---
name: stack-vue
description: Vue 3 rules (TypeScript, Vite, Pinia, Tailwind). Use it whenever you write, change or review .vue files or the TypeScript of a Vue app, or its tests.
---

# Vue 3 + TypeScript

The TypeScript rules of `stack-ts-react` apply (strict, no `any`, no `as` to silence the
compiler, discriminated unions for states, validate external data at the edge).

## Components
- `<script setup lang="ts">` and the Composition API. No Options API in new code.
- Typed props and emits: `defineProps<{...}>()`, `defineEmits<{...}>()`; `withDefaults` for defaults.
- Logic goes in composables (`useXxx` in `composables/`) or pure modules; the component renders.
- Derived state with `computed`, never a `watch` that copies into a `ref`.
  `watch`/`watchEffect` only to sync with something external.
- Don't destructure `props` or a reactive object without `toRefs`/`storeToRefs`: you lose reactivity.
- `v-for` always with a stable `:key` (never the index if the list changes); never `v-if` and `v-for` on the same element.
- Small components; deep prop drilling (more than 3 levels) → `provide/inject` or a store.

## Data and state
- HTTP calls in `services/` (one API client, interceptors for auth/401); components and
  composables don't call `fetch`/`axios` directly.
- Server data with the project's library (TanStack Query for Vue, etc.) if it has one; if not,
  a composable that exposes `data`, `error` and `loading` and handles all three.
- Global state with Pinia (setup stores), only what's truly global; the rest stays local.
- Don't change endpoint names or contracts the backend defines.

## UI
- Tailwind with the project's tokens (brand colors in `tailwind.config`); no hardcoded hex values.
- Loading, empty and error states always visible.
- Accessibility: semantic elements, labels on inputs, keyboard-manageable focus.
- UI text in the product's language (usually Spanish).

## Tests
- Vitest + Vue Test Utils (or Testing Library). Test visible behavior, not implementation.
- Composables and pure logic with unit tests without mounting.

## Before closing a task
- `vue-tsc --noEmit` clean, lint clean, tests green.
- If there are visual changes, say exactly what to check in the browser.
- ⚠️ Ask before adding dependencies.
