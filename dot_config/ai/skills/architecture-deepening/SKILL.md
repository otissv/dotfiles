---
name: architecture-deepening
description: Ignore this skill if ast-grep is not installed (`ast-grep --version` fails); it needs code-guidelines, which needs ast-grep. Find shallow modules and leaky seams, decide which to deepen using fixed gates, and make the changes - one candidate per worktree and local branch, verified by tests. Logs every candidate and change to .refactor/ (shared with code-guidelines) and writes a report for retrospectives. Use when asked to improve or deepen the codebase architecture, or before a large refactor. Needs the code-guidelines skill installed next to it.
---

# Architecture deepening

Survey for deepening opportunities, decide automatically with `gates.md`, apply the ones that pass, log everything.

- `<skill>` is this skill's directory. `<cg>` is the `code-guidelines` skill next to it (`<skill>/../code-guidelines`); stop if it is missing.
- `LOG` means `node <cg>/scripts/refactor-log.mjs`.
- Read `vocabulary.md`, `patterns.md` and `gates.md` before starting. Use their terms exactly.

## Rules

- Only `gates.md` decides. If a gate cannot be answered from the code, it fails.
- Never change the code in the current checkout. Every candidate is applied in its own worktree on a local branch `refactor/deepen-<slug>`.
- Do not push, open PRs or merge. The user reviews and merges each branch.
- Log from the current checkout only, so blame sees the original code and all logs land in one place.

## Workflow

1. **Prepare.**
   - The current checkout must have no uncommitted changes to tracked files; if it does, stop and tell the user.
   - Read `.refactor/config.json` (create it as the `code-guidelines` README says if missing), `.refactor/lessons.md`, and the false positives from `LOG distil` for any pattern id.
   - Start a run: `LOG new-run --skill architecture-deepening --scope "<area or 'churn'>"` → run id `R`.
2. **Scope.** If the user named an area, use it. Otherwise list the most-changed paths of the last 90 days:
   `git log --since=90.days --name-only --format= | grep -v '^$' | sort | uniq -c | sort -rn | head -40`
   and group them by directory. Skip generated, vendored and test-fixture paths.
3. **Context.** Read, if present: the project glossary (`GLOSSARY.md`, `plan/glossary.md`, `CONTEXT.md`), ADRs (`docs/adr/`), and any context map naming bounded contexts. Name candidates in the project's own terms.
4. **Survey.** Explore the scoped areas, in parallel where you can (one Explore subagent per area). For each area return candidates as: pattern id, files, the module's interface today, its callers, and the evidence (repeated caller code, co-change counts from git, bug-fix commits).
5. **Score.** For each candidate:
   - Run the deletion test (`vocabulary.md`) and write the result in one sentence.
   - Give it a strength (`gates.md`).
   - Check every gate in order and stop at the first that fails.
   - Log it: `LOG add --run R --json '{"kind":"decision","candidate":"<name>","guideline":"<pattern id>","file":"<main file>","line":<line of its definition>,"source":"agent","strength":"<strength>","why":"<deletion test result>","outcome":"not-applied","gate":"<G-id: reason>"}'` for a failed gate. Candidates that pass every gate are logged when they finish (step 8).
6. **Design the interface twice.** For each passing candidate, produce two or three different interfaces (in parallel subagents if available: one minimal, one shaped by the callers, one in the project's domain terms). Pick one with the interface rubric in `gates.md`. Keep one line per rejected design for `alternatives`.
7. **Apply.** Apply candidates in rank order, at most `maxCandidatesPerRun`, each with a subagent in an isolated worktree (Agent tool, `isolation: "worktree"`). Give the subagent: the candidate, the chosen interface, the dependency category and test strategy (`vocabulary.md`), the config `checks`, and this contract:
   - Rename the branch to `refactor/deepen-<slug>`.
   - First write tests through the new interface that pin current behaviour, and commit them.
   - Make the change. Commit with a message naming the candidate and pattern id.
   - Run every `checks` command, then the `code-guidelines` skill in `diff` mode against the base branch, and fix what it reports.
   - If a check still fails after a real attempt, discard all changes (`git reset --hard <base>`) so the worktree is cleaned up.
   - Return JSON: `{"status":"done"|"failed","branch","failedCheck","changes":[{"file","line","before","after","why"}],"tests":[...],"metrics":{"filesTouched","interfaceItems":[before,after],"callers":[before,after]}}`, with `line` numbers taken from the base commit.
8. **Log the results** in the current checkout:
   - Each returned change: `LOG add --run R --json '{"kind":"change","candidate":"<name>","guideline":"<pattern id>","source":"agent",...}'`. For a failed candidate, add `"outcome":"reverted"`.
   - The tests: one `change` with `"guideline":"characterisation-tests"`.
   - The candidate: one `decision` as in step 5, with `"outcome":"kept"` (branch ready) or `"reverted"` (with `"reason":"<failedCheck>"`), plus `"branch"`, `"tip"` (the branch head sha), `"metrics"` and `"alternatives"`.
   - Glossary terms you added or sharpened (in the worktree): a `change` with `"guideline":"glossary"`.
9. **Report.** `LOG report --run R`. Leave the log and report uncommitted in the current checkout and say so; the user decides where they are committed.
10. **Sweep.** `LOG sweep --base <default branch>` closes earlier runs' kept candidates. A branch whose `tip` is in the base branch stays `kept`; one that is deleted, or unmerged for `branchStaleDays`, becomes `rejected`. Run it before Distil so rejections feed the false positives and gate G9.
11. **Distil.** Follow the Distil section of `<cg>/SKILL.md`. Pattern ids count like guideline ids, once per candidate.
12. **Tell the user** in under 150 words: branches ready for review, candidates reverted and why, candidates not applied (count by gate, and by strength), the report path, branches the sweep rejected, and lessons added.

## Re-running

Candidates already logged as `not-applied` are only re-scored if the code they name changed since that run. Candidates logged `reverted` or `rejected` are skipped by gate G9 until the user says otherwise.
