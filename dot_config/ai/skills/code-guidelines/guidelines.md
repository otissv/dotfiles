# Guidelines

One entry per smell. The `id` is used by ast-grep rules, the change log and lessons. Examples are TypeScript unless noted; the guideline applies to any language.

**Source** says what finds it:
- `rule` — a bundled ast-grep rule (`rules/<lang>/<id>.yml`).
- `linter:<tool>/<rule>` — the project's linter, when the project uses it.
- `agent` — your judgment.

When more than one source is listed, use the first one the project has, and fall back to `agent`.

A project can add or override entries in `.refactor/guidelines.local.md` (same format, same ids override).

---

## inline-constant-thunk

A function with no parameters that only returns a literal. Replace it with the value and change `f()` to `f` at every call site.

- **Source:** `rule` (ts, js, py)
- **Bad:** `const retries = () => 3; ... for (let i = 0; i < retries(); i++)`
- **Good:** `const retries = 3; ... for (let i = 0; i < retries; i++)`
- **Do not apply when:**
  - It is exported or part of a public interface.
  - It is passed or stored as a function anywhere (callback, map of handlers, default prop, DI token, `useState(() => ...)`), or compared by identity.
  - It is a method, or overrides or implements one.
  - It is a deliberate seam: tests replace it, or a second implementation exists.
  - The literal is a mutable object or array and callers rely on getting a fresh one each call.

## needless-intermediate-variable

A variable assigned and immediately returned, with no other use. Return the expression.

- **Source:** `linter:ruff/RET504`, `rule` (ts, js)
- **Bad:** `const total = sum(items); return total;`
- **Good:** `return sum(items);`
- **Do not apply when:**
  - The name documents something the expression does not (a long or unclear expression, a unit, a domain term).
  - It sits there for debugging that the project keeps (a logged or breakpointed value).
  - The type annotation on the variable narrows or checks the type and the function has no return type.

## needless-wrapper

A function that only forwards its own arguments, unchanged and in order, to another function. Call the inner function directly.

- **Source:** `rule` (ts, js) reports candidates; `agent` decides
- **Bad:** `function save(user) { return repo.save(user); }`
- **Good:** call `repo.save(user)` at the call sites, and delete `save`.
- **Do not apply when:**
  - It is exported or part of a public interface.
  - It binds `this`, fixes the arity (`arr.map(x => parseInt(x))` is not a wrapper), narrows types, or adapts an interface.
  - It is a seam with a second adapter, or tests replace it.
  - It names a domain concept the inner call does not (`approveInvoice` wrapping `setStatus`): that is vocabulary, not a wrapper. Leave it to `architecture-deepening`.

## return-condition-directly

`if (c) return true; return false;` and its variants. Return the condition.

- **Source:** `linter:ruff/SIM103`, `linter:biome/noUselessTernary` (ternary form), `rule` (ts, js) for the `if` form
- **Bad:** `if (user.active) { return true; } return false;`
- **Good:** `return user.active;`
- **Note:** the rule's automatic fix writes `return Boolean(c);`, which is always equivalent. Where the type checker shows `c` is already boolean, drop the `Boolean()` and log that as its own change.
- **Do not apply when:**
  - The condition is not boolean and the function promises a boolean. Use `Boolean(c)` (or `bool(c)`) instead of returning `c`; if you cannot tell the type, leave it and log a suggestion.

## else-after-return

An `else` after a branch that always returns, throws, breaks or continues. Drop the `else` and unindent.

- **Source:** `linter:biome/noUselessElse`, `linter:eslint/no-else-return`, `linter:ruff/RET505`, `agent`
- **Do not apply when:**
  - The two branches are symmetric cases of equal weight and the project style prefers that shape (look at nearby code).

## dead-code

Unused variables, imports, parameters of private functions, unreachable code, and private functions with no callers. Delete them.

- **Source:** `linter:tsc/noUnusedLocals`, `linter:biome/noUnusedVariables`, `linter:biome/noUnusedImports`, `linter:ruff/F401`, `linter:ruff/F841`, `agent`
- **Do not apply when:**
  - It is exported, or reached by reflection, string lookup, framework convention (route files, decorators, `__all__`, plugin registries) or code generation.
  - An import is there for its side effects.
  - A parameter is required by an interface or callback signature.

## needless-async

An `async` function with no `await` that returns a plain value. Remove `async` only if no caller relies on a promise.

- **Source:** `linter:biome/useAwait`, `linter:eslint/require-await`, `agent`
- **Do not apply when:**
  - It implements an interface or callback type that requires a promise.
  - Any caller uses `.then`, `await` on it in a way the type checker does not cover, or it is exported.
  - Removing `async` would turn a thrown error into a synchronous throw that callers do not catch.

## redundant-boolean-literal

Comparing with or casting to a boolean literal: `x === true`, `!!x` in a boolean context, `x ? true : false`.

- **Source:** `linter:biome/noExtraBooleanCast`, `linter:biome/noUselessTernary`, `linter:ruff/SIM210`, `agent`
- **Do not apply when:**
  - `x` can be a non-boolean (`=== true` is then a real check, not noise).

## speculative-parameter

A parameter or option that every caller passes the same value for, or never passes, on a private function. Inline the value and drop the parameter.

- **Source:** `agent`
- **Do not apply when:**
  - The function is exported or part of a public interface.
  - Tests pass a different value (it is a real seam for testing).
  - A pending change in the same branch or ticket uses it.

## nested-conditional

Conditionals nested three or more levels deep, or nested ternaries. Flatten with early returns or extract a well-named predicate.

- **Source:** `linter:biome/noNestedTernary`, `agent`
- **Do not apply when:**
  - Flattening needs duplicated conditions or changes evaluation order of side effects.

---

## Log-only ids

Not smells. Used in the change log for supporting work.

| id | Use |
|---|---|
| `characterisation-tests` | Tests added to pin behaviour before a cleanup |
| `new-rule` | An ast-grep rule added by the distil step |
