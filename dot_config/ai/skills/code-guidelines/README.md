# code-guidelines — setup

For people setting the skill up. The agent follows `SKILL.md`.

## Install

1. Copy this folder to `~/.claude/skills/code-guidelines/` (all projects) or `<project>/.claude/skills/code-guidelines/`.
2. Install ast-grep: `pnpm i -g @ast-grep/cli`, `brew install ast-grep` or `cargo install ast-grep`. In PM HQ, `bootstrap.sh` asks before running the pnpm install. Node 20+ runs the scripts.
3. Check the Biome / ESLint / Ruff rule names in `guidelines.md` against the versions your projects use (`biome explain <rule>`, `ruff rule <code>`); names move between releases.

## Project state: `.refactor/`

Commit this folder. It is shared with the `architecture-deepening` skill.

| Path | What |
|---|---|
| `config.json` | Settings, below |
| `log/<run>.jsonl` | One file per run: a `run` line, then `entry` and `outcome` lines. Never edit by hand; use `refactor-log.mjs`. |
| `reports/<run>.md` | Report per run, generated from its log |
| `lessons.md` | Lessons for the implementer agent, written by the distil step |
| `guidelines.local.md` | Project additions and overrides to `guidelines.md` (same ids override) |
| `rules/<lang>/*.yml` | Project ast-grep rules added by the distil step |
| `sgconfig.yml` | Created by `scan.mjs` when `rules/` exists |

### `config.json` defaults

```json
{
  "minStrength": "Strong",
  "branchStaleDays": 30,
  "lessonThreshold": 3,
  "maxLessons": 30,
  "staleAfterRuns": 10,
  "implementerTrailer": { "key": "Agent", "value": "implementer" },
  "uncommittedIsImplementer": true,
  "maxFilesPerCandidate": 8,
  "maxCandidatesPerRun": 3,
  "excludePaths": [],
  "disabledRules": [],
  "checks": { "typecheck": "", "lint": "", "test": "" }
}
```

- `minStrength`: lowest strength `architecture-deepening` applies (`Strong`, `Worth exploring` or `Speculative`). Lower it to `Worth exploring` only after at least 3 deepening branches have been merged with none reverted.
- `branchStaleDays`: an unmerged `refactor/deepen-*` branch older than this is marked `rejected` by `refactor-log.mjs sweep`.
- `lessonThreshold`: kept changes on implementer code before a guideline becomes a lesson.
- `staleAfterRuns`: a lesson with no matching change in this many recent runs is dropped.
- `implementerTrailer`: commit trailer that marks the implementer agent's commits.
- `uncommittedIsImplementer`: in `turn` mode, uncommitted lines count as the implementer's.
- `maxFilesPerCandidate`, `maxCandidatesPerRun`, `excludePaths`: used by `architecture-deepening` (gates G5 and G10, ranking).
- `disabledRules`: rule ids (`inline-constant-thunk.ts`) or guideline ids to ignore.
- `checks`: commands run after changes. Empty means not run.

### Log entry fields

| Field | Required | Notes |
|---|---|---|
| `kind` | yes | `change` (code was edited) or `decision` (candidate or finding not acted on) |
| `guideline` | yes | Guideline id, deepening pattern id, or a log-only id |
| `source` | yes | `rule:<id>`, `linter:<tool>/<rule>`, `agent` |
| `why` | yes | One sentence |
| `file`, `line` | changes | `line` in the file before the change |
| `before`, `after` | changes | Short snippet or summary |
| `outcome` | no | Default `kept` for changes, `suggested` for decisions |
| `candidate`, `gate`, `alternatives` | no | Used by `architecture-deepening` |
| `origin` | auto | `{commit, agent}` from git blame and the commit trailer |

## Making the implementer agent learn

1. **Load the lessons.** Add to the project's `CLAUDE.md` (or the implementer skill):
   ```
   Before writing code, read .refactor/lessons.md and follow every lesson in it.
   ```
2. **Mark its commits.** The implementer adds the trailer to every commit message:
   ```
   Agent: implementer
   ```
   Without it, `origin.agent` stays empty and no lessons are produced (except from uncommitted code in `turn` mode).

## End-of-turn check (Stop hook)

Add to `.claude/settings.json` in the project (adjust the path if the skill lives in the project):

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "node ~/.claude/skills/code-guidelines/scripts/stop-hook.mjs" }] }
    ]
  }
}
```

It blocks the end of a turn once when changed files still match a rule, and never blocks twice in a row.

## Before-merge check (CI)

Rules only, on the files the branch changed. Fails on any finding not already logged as a decision:

```bash
node <skill>/scripts/scan.mjs --mode diff --base origin/main --new-only | node -e 'const r=JSON.parse(require("fs").readFileSync(0,"utf8"));if(r.remaining){console.log(JSON.stringify(r.findings,null,2));process.exit(1)}'
```

Run the project's linter, typecheck and tests as their own CI steps. Because `--mode diff` only scans changed files, old code does not fail the build while a cleanup is in progress.

## Cleaning up an existing project

1. **Baseline:** `node <skill>/scripts/scan.mjs --mode path --path .` and look at `byGuideline`.
2. **Then, one module at a time:** ask the agent to run the code-guidelines skill in `path` mode on that directory. It writes characterisation tests where coverage is thin, commits one guideline per commit, and does not push.
