---
name: retrospective
description: Review the journal after an epic or a group of epics of one project and propose changes to agents, skills, the workflow and the project lead's prompts. Use when the user invokes /retrospective <project> <epic[,epic]> or asks for a retrospective or post-mortem of finished work. Suggest-only: it writes one report and edits nothing else.
---

# Retrospective

Agents remember nothing between sessions; what they learn lives only in their written instructions. This procedure turns the journal (`journal/README.md`) into concrete, evidenced changes to those instructions, and into feedback on the project lead's own prompts. It never applies a change.

Usage: `/retrospective <project> [epics]`, where `<project>` is the folder name under `projects/` (the board has the same name). Stop if the project is not in `projects.conf`, or `projects/<project>/` or `boards/<project>/` is missing; say which. The kanban tool and the journal sit at the root of the PM HQ `main` worktree; every path and command below is relative to it (`kanban/kanban.mjs`, `journal/`).

**Where to run it.** PM HQ is a bare clone with worktrees. The kanban UI saves tickets, uncommitted, in the PM HQ `main` worktree, and a session worktree holds only the committed copy, so the board there is stale. Run every command from PM HQ `main`: `container=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")`, then `cd "$container/main"`. Leave uncommitted changes there alone; the lead saves them from the UI.

## Who does what

- **The coordinating session** (you were invoked as `/retrospective <epics>`): resolve the scope (step 1), then start the `retrospective` agent with a brief that names the project, the epic IDs and says to follow this file. Do not do the analysis yourself, and run no other agent beside it.
- **The `retrospective` agent**: steps 2 to 9.

## Steps

1. **Scope.** Epic IDs come from the arguments after the project (`T-090` or `T-090,T-095`). With none given, list closed epics (`node kanban/kanban.mjs list <project> --type epic --lane done`) and ask which. Dates (`--since`, `--until`) are the fallback when agents did not tag the epic.
2. **Digest.** `node kanban/kanban.mjs journal retro <epics>` writes `journal/retrospectives/<label>.digest.md` and prints its path and entry count. If it reports no entries, stop and say so: the epic was not tagged or nothing was logged.
3. **Read the digest in full.** It is short by design. Read the raw entries (`kanban.mjs journal show <ID>`) only when a row lacks the evidence a proposal needs.
4. **Read before proposing.** For each target you will propose a change to, read the current text of that agent definition, skill or document by section (`grep -n '^#'`, then `Read` with `offset` and `limit`). A proposal that quotes text that is not there is invalid.
5. **Check history first.** In the digest, read **Declined** and **Effect of earlier changes** before writing anything. Never propose a declined idea again. If an applied change shows "seen again", the change failed: propose a stronger or different one and say why the first did not work.
6. **Decide what becomes a proposal.** A proposal needs one of: two or more entries on the same target and theme from different runs; any `correction` with source `user`; a `review-finding` theme that recurs. Everything else goes on the watch list, not into a proposal.
7. **Write each proposal as one exact change:** the file, the section, the current text quoted, and the replacement text. "Consider adding" is not a proposal. Prefer, in this order: a mechanical check (checker rule, script, hook) over prose; tightening or replacing an existing rule over adding one; the smallest change that removes the cause. State which entry IDs it rests on and what it prevents. Propose deleting a rule when entries show it caused friction or was ignored without harm. Say when friction looks specific to a model.
8. **Cross-cutting and planning.** Themes in more than one target, and `workflow` entries, become proposals for `AGENTS.md`, `CONTINUE.md`, the contracts or the tooling. `plan-issue` entries become planning feedback for the orchestrator on how to split the next epic. A change to an approved decision, a stage requirement or contract semantics is not a proposal: list it under "Needs the project lead".
9. **Prompt coaching.** From the coaching table and the user corrections, find gaps that recur in the project lead's own instructions (unstated acceptance criteria, ambiguous scope, a constraint not mentioned, a choice left to guess). For each, quote the instruction if the evidence has it, say what was missing, and give a rewrite. If two gaps share a type, propose a reusable brief checklist instead of a reminder.
10. **Write the report** to `journal/retrospectives/retrospective-<label>.md` (the label is the digest's file name without `.digest.md`), in the format below. Write no other file. Do not change any entry's status; the project lead does that.
11. **Log your own step** to the journal (`--target skill:retrospective`), as every agent does.

## Report format

Front matter with a one-line `description`, then these sections in order. Every table has an `ID` first column.

| ID | Section | Content |
|----|---------|---------|
| S1 | `## Summary` | Three to six lines: what cost the most rework, what went well, how many entries and proposals |
| S2 | `## Proposals` | A table (`ID` P1, P2 ..., target, file and section, entry IDs, what it prevents, priority), then one `### P<n>` block per proposal with `Current:` (quoted) and `Replace with:` text |
| S3 | `## Cross-cutting proposals` | Same shape, ids X1, X2 ... |
| S4 | `## Planning feedback` | What the orchestrator should do differently when splitting the next epic |
| S5 | `## Prompt coaching` | Each gap with the quoted instruction, what was missing, a rewrite; any proposed brief checklist |
| S6 | `## Effect of earlier changes` | Per applied change: seen again or not, and what that means |
| S7 | `## Keep doing` | The wins, so they are not edited away |
| S8 | `## Watch list` | Single-occurrence items to count next time, with entry IDs |
| S9 | `## Needs the project lead` | Decision changes, contract edits, anything outside suggest-only |

## Done

Your final message (at most about 250 words): the report path; entries read and proposals written (by target); the three highest-priority proposals one line each; every item that needs the project lead. No tables.
