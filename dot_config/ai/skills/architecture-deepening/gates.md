# Gates and rubrics

The agent applies a candidate only if every gate passes. Check gates in order and stop at the first that fails; log it as `"gate": "<id>: <one-line reason>"`. A gate you cannot answer from the code fails.

Numbers come from `.refactor/config.json`.

## Strength

| Strength | Criteria |
|---|---|
| `Strong` | The deletion test clearly gathers complexity behind a smaller interface, **and** there is evidence of real friction: two or more callers repeat the same work, or the files co-changed in at least 3 commits in the last 90 days, or a bug fix in that period touched several of them. |
| `Worth exploring` | The deletion test points the right way, but the payoff depends on where the code is going, or the evidence is a single caller or a single commit. |
| `Speculative` | Anything weaker. |

## Gates

| Id | Gate | Passes when |
|---|---|---|
| G1 | Strength | The candidate's strength is at least `minStrength` (default `Strong`; order: `Speculative` < `Worth exploring` < `Strong`). |
| G2 | Pattern conditions | None of the pattern's **Do not apply when** conditions hold (`patterns.md`, plus `.refactor/patterns.local.md`). |
| G3 | Public interface unchanged | No change to anything outside the repo depends on: package entry-point exports, published types, HTTP/RPC routes and payloads, event and message formats, database schema, CLI flags, config keys, environment variables. Internal interfaces may change. |
| G4 | One bounded context | Every touched file is in one bounded context (from the context map or glossary; without one, one top-level package or app). Changes across a context boundary are logged, never applied. |
| G5 | Size | The change touches at most `maxFilesPerCandidate` files, tests excluded. |
| G6 | Testable through the interface | Existing tests exercise the behaviour, or tests can be written through the new interface before the change, using the dependency category's strategy (`vocabulary.md`). |
| G7 | No hypothetical seam | The change adds no seam with a single adapter. |
| G8 | No overlap | It touches no file that a higher-ranked candidate in this run touches. |
| G9 | Not tried before | The log has no `reverted` or `rejected` decision for the same pattern on the same module, unless the user said to retry. |
| G10 | Not excluded | No touched file is generated, vendored, or in a path the user or `config.json` excluded. |

## Ranking

Among candidates that pass, apply in this order, up to `maxCandidatesPerRun`:

1. Most callers that stop repeating work.
2. Most co-change commits removed (files that will no longer need to change together).
3. Fewest files touched.

## Interface rubric

Used in step 6 to choose between the designs. Pick the design that does best on the first point; use later points only to break ties.

1. **Covers every current caller** without flags or modes added only to serve one caller.
2. **Least to learn:** fewest items in the interface (functions, parameters, types, invariants, error modes).
3. **Locality:** each rule the module enforces lives in one place.
4. **Tests through the interface only:** no test needs to reach past it.
5. **Project terms:** names come from the glossary and the domain.
6. **Smallest diff** from the current code.
