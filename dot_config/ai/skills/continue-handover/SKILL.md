---
name: continue-handover
description: Start of a session for a project managed by PM HQ. Reads what /handover wrote, checks the repositories and the board, and reports a plan for the top READY ticket without starting it. Use when the user invokes /continue-handover <project> or says to continue from the last session.
---

# Continue from a handover

Usage: `/continue-handover <project>`, where `<project>` is the folder name under `projects/` (the board has the same name). This is the reading half of `/handover`. It reads, checks and reports. It does not start a ticket, move anything, edit files, commit or push. The runner (`node kanban/runner.mjs start <project>`) takes tickets from READY; this skill only reports where things stand.

Run from a PM HQ worktree; paths are relative to its root. `container=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")`; the project clones are under `$container/main/projects/<project>/`.

## 0. Resolve

Stop if `<project>` is not in `projects.conf`, `projects/<project>/` is missing, or `boards/<project>/` is missing. Say which.

## 1. Read, in this order

1. `projects/<project>/SESSION-HANDOVER.md`
2. `projects/<project>/CONTINUE.md`
3. `projects/<project>/AGENTS.md`
4. `node kanban/kanban.mjs show <project> doing checking ready review blocked`, then `node kanban/runner.mjs status <project>`
5. The top READY ticket: `node kanban/kanban.mjs next <project>`, then `node kanban/kanban.mjs ticket <project> T-nnn`, then `node kanban/kanban.mjs scenario <ID>` for each scenario on it.
6. `projects/<project>/APPROVALS.md` and `APPROVED-DECISIONS.md`

Where the handover and `CONTINUE.md` disagree, the handover wins; note the disagreement. Skip `ARCHIVE-*.md`. Read contracts, plan and reports only if the ticket needs them.

## 2. Check (run commands; do not trust the handover's claims)

- **Open work**: `git worktree list` and `git status --short` in PM HQ and in `$container/main/projects/<project>/.bare`; `git branch --no-merged main` and unpushed commits for each. List every worktree other than `main`, every unmerged branch and every uncommitted file.
- **DOING and Checking lanes**: these are the runner's. If it is not running and they hold tickets, report them (log lines, worktree, last run outcome); the runner resumes them on its next start. Never take one over by hand.
- **Dependencies**: `node kanban/kanban.mjs deps <project> T-nnn`; every `depends_on` must be in review or done.
- **Waiting items**: any blocked ticket, pending approval or "Waiting on the project lead" item in the handover that blocks or changes the READY ticket.
- **Handover freshness**: the handover's commit hashes match `git log` in both repos.

## 3. Report

Stop here. Report in this order, under about 200 words:

1. The top READY ticket (ID, title) and whether the runner can start it: yes, or the blockers (an open dependency, no `agent`, a cap).
2. Problems first: the runner stopped with tickets in DOING or Checking, open worktrees or unmerged branches, unsatisfied dependencies, items waiting on the project lead, stale handover.
3. What needs the lead: blocked tickets with their decision, a release that is ready, tickets to create or split.
4. At most one question, only for a decision that is the lead's. Never move a ticket or start work.
