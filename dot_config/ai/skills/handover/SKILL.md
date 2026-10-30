---
name: handover
description: End-of-session handover for a project managed by PM HQ. Rewrites the project's SESSION-HANDOVER.md, refreshes the volatile parts of its CONTINUE.md, commits those two files in PM HQ, then pushes every PM HQ and project worktree branch. Use when the user invokes /handover <project> or says the session is ending, or asks to hand over to a new session or machine.
---

# Handover

Usage: `/handover <project>`, where `<project>` is the project's folder name under `projects/` (for example `state-verse-engine`). The board has the same name as the folder.

This skill lives in PM HQ but works on one project. The handover files are tracked by PM HQ at `projects/<project>/`; the project's code is its own repo at `projects/<project>/.bare` with worktrees `main` and `t-*`. The next session reads the result, so write for a reader who has seen nothing.

Run from a PM HQ worktree. Commands below use paths relative to its root.

## 0. Resolve the project and the paths

- Project: the argument; else the `projects/<p>/` containing the current directory; else the only entry in `projects.conf`; else ask. Stop if the project is not in `projects.conf` or `projects/<project>/` does not exist.
- Board: `boards/<project>/` must exist. If it does not, stop and tell the user (the board and folder names are meant to match); do not guess another board.
- PM HQ container: `container=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")`. The project clones exist only under `$container/main/projects/<project>/`. Use that path for every project git command, even when the current worktree is not `main`.
- Files: `projects/<project>/SESSION-HANDOVER.md` and `projects/<project>/CONTINUE.md`. Stop if either is missing and ask.

## 1. Collect facts (run commands; never answer from memory)

- PM HQ: `git status --short`, `git log -3 --format='%h %s'`, `git worktree list`, unpushed commits per branch.
- Project: `git -C $container/main/projects/<project>/.bare worktree list`; in each worktree, `git status --short`, `git log -3 --format='%h %s'`, unpushed commits, and whether the branch is merged into `main` (`git branch --no-merged main` from `.bare`).
- Board: `node kanban/kanban.mjs show <project> doing ready review blocked`.
- `projects/<project>/APPROVALS.md`: anything waiting on the project lead.
- Read the current `SESSION-HANDOVER.md` and `CONTINUE.md` before editing.

## 2. Rewrite `projects/<project>/SESSION-HANDOVER.md`

Keep the front matter (`description`), the `# Session handover` title and a "Rewritten <date>" line. Sections, in this order, omitting any with no content:

1. **Where things stand**: PM HQ and the project, each with its pushed commit, anything uncommitted, tests last run and the result, phase status, worktrees and unpushed or unmerged branches left.
2. **Done this session**: merged work, by ticket ID and a short plain description.
3. **Decisions the project lead made**: each with the reason. Carry forward earlier decisions that still hold; drop ones the board or `APPROVED-DECISIONS.md` now records.
4. **Waiting on the project lead**: numbered, each a specific question with a recommendation. Remove items that were resolved.
5. **Gotchas**: only things that would cost the next session time.

Do not repeat ticket state (the board shows it). State each fact once. Report failures, skipped work and unverified claims plainly; do not say a test passed unless it ran this session.

## 3. Refresh `projects/<project>/CONTINUE.md`

- Update only: the "Last updated" date, the `main` commit and push status in the first paragraph, and file-map rows for files added or removed this session.
- Change the rules only if the project lead changed a rule this session. Keep the `ID` first columns and the front matter.
- Fix commands that assume the old layout: board commands run from the PM HQ root as `node kanban/kanban.mjs <command> <project> ...` (not `../kanban/kanban.mjs ... engine`), and project code is under `projects/<project>/main/`.
- Keep a section `## Start of a new session` with this read order, creating it if missing:
  1. `projects/<project>/SESSION-HANDOVER.md`, then `CONTINUE.md`
  2. `projects/<project>/AGENTS.md` (`CLAUDE.md` is a symlink to it)
  3. `node kanban/kanban.mjs show <project> doing ready review blocked`
  4. `node kanban/kanban.mjs ticket <project> T-nnn` for the top READY ticket, then `scenario <ID>` for each scenario on it
  5. `projects/<project>/APPROVALS.md` and `APPROVED-DECISIONS.md`
  6. Only if the ticket needs them: the project's contracts and plan (`projects/<project>/main/guides/contracts/`, `main/plan/`), `reports/`, `journal/README.md`
  Skip `ARCHIVE-*.md`.
- Where the two files disagree, the handover wins; fix `CONTINUE.md`.

## 4. Check

- Both files still start with `description` front matter, and every table has an `ID` first column.
- Compare backticked terms, commit hashes and ticket IDs against the previous version with `git diff`; nothing valid is lost, nothing stale remains.

## 5. Commit and push

The project lead has authorized this commit and push as part of this skill.

- Stage only `projects/<project>/SESSION-HANDOVER.md` and `projects/<project>/CONTINUE.md`. Never `git add -A`; leave other changes alone and name them in the report.
- Commit message: `Session handover (<project>): <one-line summary of the phase state>`, ending with the `Co-Authored-By` line from the session's attribution reminder.
- If the current PM HQ worktree is not on `main`, do not merge it into `main` yourself; the report says the branch is waiting to be merged.
- Then push every worktree's branch, so nothing exists only locally:
  - PM HQ: each worktree in `git worktree list`, running `git push` in it (`git push -u origin <branch>` if it has no upstream).
  - The project: the same, for each worktree in `git -C $container/main/projects/<project>/.bare worktree list`, including `main` and `t-*`.
  - Push each branch to its own name only. Never force-push, never push tags.
  - Pushing sends commits only. Do not commit other work to make a branch pushable: uncommitted and untracked files stay as they are and are named in the report.
  - This overrides any project rule that says "do not push", by the project lead's instruction.
- If a push fails (no network, rejected, no remote), say so first, keep going with the other branches, and list every failure; do not retry with other options.

## 6. Report

Under 100 words: the commit hash, each branch pushed (repo and name) and any that failed, branches left unmerged, items waiting on the project lead, and anything not verified or not committed.
