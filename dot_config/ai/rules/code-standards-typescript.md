---
description: TypeScript and general code standards — types, structure, error handling, naming
globs: src/**/*.{ts,tsx}
alwaysApply: true
---

## TypeScript

- Use TypeScript for all new code; enable strict mode
- Define explicit return types for functions
- Use proper type narrowing; avoid `any` — use generics instead
- No non-null assertions (`!`)
- Use `as` casts only when unavoidable (never `as any`)
- Implement proper type guards when necessary

## Validation & Type Derivation

- Use `zod` schemas as the source of truth for validated data shapes
- Do not duplicate runtime schemas with separate hand-maintained TypeScript interfaces or types
- Derive TypeScript types from schemas with `z.infer<typeof schema>` instead of redefining the same shape
- Derive operation-specific schemas from a canonical base schema with `omit()`, `pick()`, `partial()`, and `extend()`
- When one type or schema is a narrower/specialized version of another, derive it from the parent shape instead of copying fields
- Keep validation rules close to the field definition so runtime validation and compile-time types stay aligned

## Code Structure

- Early returns to reduce nesting
- Single-responsibility functions; max ~30 lines per function; max ~400 lines per file
- Use meaningful, descriptive, human-readable names
- Group related code together; follow proper import ordering
- `const` in loop iterations; prefer `for...of` / `for...in` over `forEach` and `educe`
- Avoid chaining array methods (e.g. `map().filter()`)
- Use utility functions from `src/lib` before reaching for external libraries
- MUST NOT: fallbacks, demo or legacy code.

## Variables & Constants

- `UPPER_CASE` for constants; avoid magic numbers; use enums for constant sets
- Implement proper immutability and scoping

## Error Handling

- Use custom error classes for different error types
- Implement proper `try/catch`; handle all possible error scenarios
- Provide meaningful error messages with proper context in logs
- Use type-safe error handling; implement proper error boundaries
