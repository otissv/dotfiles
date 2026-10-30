# architecture-deepening — setup

For people setting the skill up. The agent follows `SKILL.md`.

## Install

1. Install `code-guidelines` first. This skill uses its log script, its config and its distil step.
2. Copy this folder next to it, so `architecture-deepening/` and `code-guidelines/` share a parent (`~/.claude/skills/` or `<project>/.claude/skills/`).
3. Set `checks` in `.refactor/config.json`. Without a test command, gate G6 fails for every candidate unless the agent can write tests, and nothing is verified.

## What you get from a run

- **One local branch per applied candidate,** `refactor/deepen-<slug>`, with characterisation tests committed first, then the change. Nothing is pushed.
- **`.refactor/log/<run>.jsonl` and `.refactor/reports/<run>.md`,** uncommitted in your checkout. They hold every candidate (applied, reverted, or not applied with the gate that stopped it), every change, the alternatives considered, and before/after metrics.
- **Lessons** for the implementer agent, through the shared distil step.

## Reviewing

1. Read the report, then review each branch.
2. If you reject a branch, record it so the skill learns: ask the agent to mark that candidate `rejected` with your reason (`refactor-log.mjs outcome`), then run distil. Gate G9 then stops it from trying the same change again.

## Tuning

| To | Change |
|---|---|
| Apply more or fewer candidates | `maxCandidatesPerRun` |
| Allow bigger changes | `maxFilesPerCandidate` |
| Keep it out of some paths | `excludePaths` |
| Change what counts as a pattern or when not to apply it | `.refactor/patterns.local.md` |
| Change the gates themselves | Edit `gates.md` in the skill |

The report's "not-applied" counts by gate show which gate is stopping the most. Use that in retrospectives to decide whether a gate is too strict.

## Reference

The approach follows aihero's `improve-codebase-architecture` and `codebase-design` skills: the vocabulary, the deletion test, strength badges and designing the interface twice. Those skills hand the decision to a person. This one replaces that step with the gates in `gates.md` and applies the changes. The text here is written fresh, not copied.
