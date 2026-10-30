# Deepening patterns

One entry per pattern. The id is used as `guideline` in the change log, so lessons and false positives work the same way as in `code-guidelines`. A project can add or override patterns in `.refactor/patterns.local.md` (same ids override).

---

## scattered-concept

One concept is spread across several modules, and you cannot understand it without opening most of them. Callers each assemble the pieces.

- **Signs:** the same sequence of calls repeated in two or more callers; files that change together in most commits (co-change); a bug fix that needed edits in several places.
- **Deepening:** gather the concept behind one module whose interface is the operation callers actually want. Callers call that instead.
- **Do not apply when:**
  - The pieces belong to different bounded contexts (gate G4).
  - The callers' sequences differ in ways that matter; unifying them needs flags or modes on the new interface.

## leaky-seam

Callers depend on the module's internals: they must call things in a set order, handle its internal error types, or set up state it should own.

- **Signs:** comments like "must call X before Y"; callers catching and translating the module's low-level errors; callers reaching into its fields or sub-modules.
- **Deepening:** move the ordering, setup and error translation behind the interface, so the interface states what callers need and nothing else.
- **Do not apply when:**
  - The ordering is a real choice that callers make differently (it is part of the domain, not an internal detail).
  - Changing the error types would change a public interface or wire format (gate G3).

## pass-through-module

A module whose interface mirrors the one beneath it. The deletion test makes complexity disappear.

- **Signs:** every function forwards to one function of another module with the same arguments; a layer (service, manager, helper) with one method per method of the layer below.
- **Deepening:** remove the layer; callers use the module beneath, or the layer absorbs real work from its callers so it earns its interface.
- **Do not apply when:**
  - It is the seam for a second adapter, or tests substitute it.
  - It translates between two vocabularies (domain terms on top of a storage or transport interface): that is real work.
  - It is a public interface (gate G3).

## hypothetical-seam

An interface or abstraction with exactly one adapter and no concrete need for a second.

- **Signs:** `interface Foo` with one `FooImpl`; a factory or registry with one entry; dependency injection of something no test replaces.
- **Deepening:** collapse the interface into the concrete module. If tests need a substitute, use the dependency category's test strategy instead.
- **Do not apply when:**
  - A second adapter exists in tests, or one is planned in an open ticket or ADR.
  - The seam sits at a bounded-context boundary or a true-external dependency.

## test-only-extraction

Small pure functions were pulled out to make them testable, while the bugs live in how callers combine them.

- **Signs:** many tiny exported helpers with thorough unit tests, and callers with untested glue between them; bug fixes land in the callers, not the helpers.
- **Deepening:** fold the helpers back behind one module that does the whole job, and move the tests to that module's interface.
- **Do not apply when:**
  - Several unrelated callers use the helpers independently (they are a real shared module).
  - The helpers are part of a public interface (gate G3).
