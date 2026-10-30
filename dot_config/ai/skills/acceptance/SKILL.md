---
name: acceptance
description: Check tickets in the Review lane against their acceptance criteria. Use when the user invokes /acceptance <project> [T-nnn] or says a ticket has been moved to Review. Runs the acceptance-reviewer agent, which records "Agreed" in the ticket's Acceptance section when every criterion is met, or records the gaps as a blocker. It never moves a ticket and never approves one.
---

# Acceptance

A ticket moved into Review claims its `## Acceptance` criteria are met. This procedure checks the claim by hand, for tickets the runner did not take through Checking (where `acceptance-reviewer` is already the last gate). It approves nothing and moves no ticket: tickets reach Done only through a release the project lead approves (`node kanban/runner.mjs release <board> --approve <id>`).

Usage: `/acceptance <project> [T-nnn[,T-nnn]]`, where `<project>` is the folder name under `projects/` (the board has the same name). Stop if the project is not in `projects.conf`, or `projects/<project>/` or `boards/<project>/` is missing; say which. With no IDs, handle every ticket waiting in Review.

**Where to run it.** PM HQ is a bare clone with worktrees. The kanban UI saves tickets, uncommitted, in the PM HQ `main` worktree, and a session worktree holds only the committed copy, so the board there is stale. Run every command from PM HQ `main`: `container=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")`, then `cd "$container/main"`. Leave other uncommitted changes there alone; the lead saves them from the UI.

## Who does what

- **The coordinating session** (invoked as `/acceptance`): steps 1 and 2. It judges no ticket itself.
- **The `acceptance-reviewer` agent**, one per ticket, one after another: steps 3 to 6.

## Steps

1. **List what is waiting.** `node kanban/kanban.mjs show <project> review`. A ticket is waiting while its `## Acceptance` has no `### Acceptance notes` entry dated after its latest `moved … → review` Log line. If IDs were given, use those and refuse any not in Review (say its lane). If nothing is waiting, say "Nothing in Review needs acceptance." and stop.
2. **Start the agent** for each ticket with a brief naming the project, the ticket ID and this file.
3. **Read the ticket:** `node kanban/kanban.mjs ticket <project> T-nnn`. List each criterion in `## Acceptance` (checkbox and "Done when" lines). For an epic, judge its own criteria and that every dependency is Done; do not re-judge the children.
4. **Check each criterion** against evidence gathered yourself, never the ticket's own claims. Verdict per criterion: met, not met, cannot verify. Only all "met" passes.
5. **All met:** `node kanban/kanban.mjs acceptance <project> T-nnn agreed`. It appends `- <date> acceptance-reviewer: Agreed.` under `### Acceptance notes` (creating the heading after the criteria if absent) and ticks every open `- [ ]` criterion. It changes nothing else and gives no reasons. Leave the ticket in Review.
6. **Any not met or cannot verify:**
   1. Write the blocker text to stdin: `## What is blocked`, `### Cause` (the unmet criteria), `### Impact`, `### Options` (include fixing, and rewriting or waiving a criterion), `### Recommendation` (one option), `### Decision needed`. It may hold no other `##` heading and no `---` line, and stops at 20,000 characters.
   2. Record it: `node kanban/kanban.mjs acceptance <project> T-nnn not-agreed --gap "<criterion>: <why it is not met, with evidence>" [--gap ...] --blocker -`. One `--gap` per unmet criterion, each one line of at most 500 characters. It appends `- <date> acceptance-reviewer: Not agreed.` with the gaps as sub-bullets, leaves the checkboxes open, and replaces `## Blocker`.
   3. Do not move it. Report the ticket as not agreed, with a one-sentence `why` and `proposal`, so the project lead can move it to Blocked (or the runner does, for its own tickets).

   Never edit the ticket file by hand and never run `kanban.mjs move`; the `acceptance` command refuses a ticket outside Checking and Review.
7. **Report** one line per ticket: ID, Agreed or Not agreed, and the unmet criteria with the `why` and `proposal` for each not-agreed ticket. Say the changes are uncommitted in PM HQ `main` for the lead to save from the UI. Do nothing else.
