---
name: approvals
description: Check the project lead's blocker approvals for one project. Use when the user invokes /approvals <project> or says they have approved blocked tickets. Reads each approved ticket and reports which approvals the runner will act on and which it cannot; moves nothing, since the runner returns approved tickets to ready.
---

# Approvals

The project lead approves a blocked ticket in the kanban UI, which adds a `blocker_approval` (`by`, `at`, `decision`) to the ticket. The runner turns those approvals into board state: it moves each approved ticket from Blocked to Ready with the approval in the Log, on its next pass (or its next start, if it is not running). This procedure only checks that each approval is one the runner can act on, so the lead hears about a bad one now rather than after a wait. It moves no ticket, does no ticket work, starts no agent, and edits no notes.

Usage: `/approvals <project>`, where `<project>` is the folder name under `projects/` (the board has the same name). Stop if the project is not in `projects.conf`, or `projects/<project>/` or `boards/<project>/` is missing; say which. Handle every pending approval in one run.

**Where to run it.** PM HQ is a bare clone with worktrees. The kanban UI saves tickets, uncommitted, in the PM HQ `main` worktree, and a session worktree holds only the committed copy, so the board there is stale. Run every command from PM HQ `main`: `container=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")`, then `cd "$container/main"`. Leave uncommitted changes there alone; the lead saves them from the UI. All commands below are relative to PM HQ `main`.

## Steps

1. **List what is waiting.** `node kanban/kanban.mjs approvals <project>` (add `--json` for the `why` and `proposal` text). A ticket is pending while it is in the Blocked lane and has an approval; moving it out is what marks it handled. If nothing is waiting, also run `node kanban/kanban.mjs approvals <project> --lane ready,doing,backlog`: an approval on a ticket outside Blocked is not pending, so report it (ID, lane, decision) and do not move it. If there is none either, say "No approvals waiting." and stop.
2. **Read each ticket** in the order listed: `node kanban/kanban.mjs ticket <project> T-nnn`. Read `## What is blocked` with its `###` parts (Cause, Impact, Options, Recommendation, Decision needed), the `why` and `proposal` fields, and the approval's `decision`.
3. **Decide whether the runner can act on the approval.**
   - The `decision` approves an option that exists under `### Options`, or approves the Recommendation (for example `option A, approved`): the runner will move it to Ready.
   - The `decision` rejects, defers, asks a question, or names no option that exists: the runner will leave it in Blocked. Say what the lead needs to change.
   - The approval needs work the runner cannot do (a ticket split, a new ticket, a changed criterion): say so; that work happens in a planning session, in the UI or by hand.
4. **Do nothing else.** Never run `kanban.mjs move`, start the ticket, write code, change the ticket's notes, or run another agent.
5. **Report** in plain language: the approvals the runner will act on (ID, decision), then those it cannot, each with the reason and what the lead should change.
