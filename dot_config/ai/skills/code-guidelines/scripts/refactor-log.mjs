#!/usr/bin/env node
// Shared change log for the code-guidelines and architecture-deepening skills.
// Run from the project root. State lives in .refactor/ (see README.md).
//
//   new-run  --skill <name> [--scope <text>]          start a run, print its id
//   add      --run <id> --json '<entry>' | --json -   append an entry (JSON on stdin with -)
//   outcome  --run <id> --id <entry id> --outcome <kept|reverted|rejected|skipped|suggested> --reason <text>
//   report   --run <id>                               write .refactor/reports/<id>.md
//   distil                                            print lessons / rules / false positives / stale lessons
//   sweep    --base <ref>                             mark kept candidate branches rejected when deleted or left unmerged
//
// Each run has its own file, .refactor/log/<run>.jsonl, so runs in separate worktrees never conflict.

import { execFileSync } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { randomBytes } from "node:crypto";

const ROOT = ".refactor";
const LOG_DIR = join(ROOT, "log");
const REPORT_DIR = join(ROOT, "reports");
const KINDS = ["change", "decision"];
const OUTCOMES = ["kept", "reverted", "rejected", "skipped", "suggested", "not-applied"];
const STRENGTHS = ["Speculative", "Worth exploring", "Strong"];
const DEFAULT_CONFIG = {
  minStrength: "Strong",
  branchStaleDays: 30,
  lessonThreshold: 3,
  maxLessons: 30,
  staleAfterRuns: 10,
  implementerTrailer: { key: "Agent", value: "implementer" },
  uncommittedIsImplementer: true,
  maxFilesPerCandidate: 8,
  maxCandidatesPerRun: 3,
  excludePaths: [],
  disabledRules: [],
  checks: { typecheck: "", lint: "", test: "" },
};

function fail(msg) {
  console.error(`refactor-log: ${msg}`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith("--")) fail(`unexpected argument ${a}`);
    const next = argv[i + 1];
    if (next === undefined || next.startsWith("--")) args[a.slice(2)] = true;
    else args[a.slice(2)] = argv[++i];
  }
  return args;
}

function need(args, ...keys) {
  for (const k of keys) if (typeof args[k] !== "string") fail(`--${k} is required`);
}

export function loadConfig() {
  const path = join(ROOT, "config.json");
  if (!existsSync(path)) return structuredClone(DEFAULT_CONFIG);
  const cfg = JSON.parse(readFileSync(path, "utf8"));
  if (cfg.minStrength !== undefined && !STRENGTHS.includes(cfg.minStrength)) fail(`config.minStrength must be one of ${STRENGTHS.join(", ")}`);
  return { ...DEFAULT_CONFIG, ...cfg, checks: { ...DEFAULT_CONFIG.checks, ...cfg.checks } };
}

function git(...a) {
  try {
    return execFileSync("git", a, { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
  } catch {
    return null;
  }
}

// Who wrote this line, from the working tree. Uncommitted lines get commit "uncommitted".
export function origin(file, line, cfg) {
  if (!file || !line) return null;
  const uncommitted = { commit: "uncommitted", agent: cfg.uncommittedIsImplementer ? cfg.implementerTrailer.value : null };
  const out = git("blame", "--porcelain", "-L", `${line},${line}`, "--", file);
  if (!out) {
    // blame fails on untracked files; those lines are uncommitted work.
    const tracked = git("ls-files", "--error-unmatch", "--", file) !== null;
    return !tracked && existsSync(file) && git("rev-parse", "--git-dir") !== null ? uncommitted : null;
  }
  const commit = out.split("\n")[0].split(" ")[0];
  if (/^0+$/.test(commit)) return uncommitted;
  const trailer = git("log", "-1", `--format=%(trailers:key=${cfg.implementerTrailer.key},valueonly)`, commit);
  return { commit: commit.slice(0, 12), agent: trailer ? trailer.split("\n")[0].trim() : null };
}

function runFile(run) {
  if (!/^[\w.-]+$/.test(run)) fail(`bad run id ${run}`);
  return join(LOG_DIR, `${run}.jsonl`);
}

function readRun(run) {
  const path = runFile(run);
  if (!existsSync(path)) fail(`no log for run ${run}`);
  return readFileSync(path, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l));
}

// Fold outcome lines into their entries. Returns { meta, entries }.
function fold(lines) {
  const meta = lines.find((l) => l.type === "run");
  const entries = new Map();
  for (const l of lines) {
    if (l.type === "entry") entries.set(l.id, { ...l });
    if (l.type === "outcome") {
      const e = entries.get(l.ref);
      if (e) Object.assign(e, { outcome: l.outcome, reason: l.reason, outcomeDate: l.date });
    }
  }
  return { meta, entries: [...entries.values()] };
}

function allRuns() {
  if (!existsSync(LOG_DIR)) return [];
  return readdirSync(LOG_DIR)
    .filter((f) => f.endsWith(".jsonl"))
    .map((f) => fold(readRun(f.slice(0, -6))))
    .filter((r) => r.meta)
    .sort((a, b) => a.meta.date.localeCompare(b.meta.date));
}

function cmdNewRun(args) {
  need(args, "skill");
  mkdirSync(LOG_DIR, { recursive: true });
  const now = new Date();
  const run = `${now.toISOString().slice(0, 10)}-${args.skill}-${randomBytes(3).toString("hex")}`;
  const head = git("rev-parse", "--short=12", "HEAD");
  const branch = git("rev-parse", "--abbrev-ref", "HEAD");
  writeFileSync(runFile(run), JSON.stringify({ type: "run", run, skill: args.skill, scope: args.scope ?? "", date: now.toISOString(), head, branch }) + "\n");
  console.log(run);
}

function cmdAdd(args) {
  need(args, "run");
  const raw = args.json === "-" || args.json === undefined ? readFileSync(0, "utf8") : args.json;
  let e;
  try {
    e = JSON.parse(raw);
  } catch (err) {
    fail(`--json is not valid JSON: ${err.message}`);
  }
  const lines = readRun(args.run);
  const cfg = loadConfig();
  if (!KINDS.includes(e.kind)) fail(`kind must be one of ${KINDS.join(", ")}`);
  for (const k of ["guideline", "source", "why"]) if (!e[k]) fail(`entry needs "${k}"`);
  if (e.kind === "change" && (!e.file || e.before === undefined || e.after === undefined)) fail(`a change needs "file", "before" and "after"`);
  if (e.outcome && !OUTCOMES.includes(e.outcome)) fail(`outcome must be one of ${OUTCOMES.join(", ")}`);
  const n = lines.filter((l) => l.type === "entry").length + 1;
  const entry = {
    type: "entry",
    id: `${args.run}#${n}`,
    run: args.run,
    date: new Date().toISOString(),
    ...e,
    outcome: e.outcome ?? (e.kind === "change" ? "kept" : "suggested"),
    origin: e.origin ?? origin(e.file, e.line, cfg),
  };
  appendFileSync(runFile(args.run), JSON.stringify(entry) + "\n");
  console.log(entry.id);
}

function cmdOutcome(args) {
  need(args, "run", "id", "outcome", "reason");
  if (!OUTCOMES.includes(args.outcome)) fail(`outcome must be one of ${OUTCOMES.join(", ")}`);
  const lines = readRun(args.run);
  if (!lines.some((l) => l.type === "entry" && l.id === args.id)) fail(`no entry ${args.id} in run ${args.run}`);
  appendFileSync(runFile(args.run), JSON.stringify({ type: "outcome", ref: args.id, outcome: args.outcome, reason: args.reason, date: new Date().toISOString() }) + "\n");
  console.log(`${args.id} -> ${args.outcome}`);
}

const cell = (s) => String(s ?? "").replace(/\|/g, "\\|").replace(/\n/g, " ");
const code = (s) => (s ? `\`${cell(s).slice(0, 80)}\`` : "");

function cmdReport(args) {
  need(args, "run");
  const { meta, entries } = fold(readRun(args.run));
  const count = (o) => entries.filter((e) => e.outcome === o).length;
  const out = [
    `# Refactor report — ${meta.run}`,
    "",
    `- **Skill:** ${meta.skill}`,
    `- **Scope:** ${meta.scope || "(not given)"}`,
    `- **Started:** ${meta.date} on \`${meta.branch}\` at \`${meta.head}\``,
    `- **Outcomes:** ${OUTCOMES.map((o) => `${o} ${count(o)}`).join(", ")}`,
    "",
  ];
  const decisions = entries.filter((e) => e.kind === "decision");
  const changes = entries.filter((e) => e.kind === "change");
  if (decisions.length) {
    out.push("## Decisions", "", "| Id | Candidate / guideline | Outcome | Gate / reason | Why | Alternatives | Details |", "|---|---|---|---|---|---|---|");
    for (const e of decisions) {
      // metrics: { "callers": [before, after], ... }
      const metrics = Object.entries(e.metrics ?? {}).map(([k, v]) => `${k} ${Array.isArray(v) ? v.join("→") : v}`);
      const details = [e.strength, e.branch && `\`${e.branch}\``, ...metrics].filter(Boolean).join("; ");
      const gate = [e.gate, e.reason].filter(Boolean).join(": ");
      out.push(`| ${e.id.split("#")[1]} | ${cell(e.candidate ? `${e.candidate} (${e.guideline})` : e.guideline)} | ${e.outcome} | ${cell(gate)} | ${cell(e.why)} | ${cell((e.alternatives ?? []).join("; "))} | ${cell(details)} |`);
    }
    out.push("");
  }
  if (changes.length) {
    out.push("## Changes", "", "| Id | Where | Guideline | Source | Before → after | Why | Origin | Outcome |", "|---|---|---|---|---|---|---|---|");
    for (const e of changes) {
      const where = e.line ? `${e.file}:${e.line}` : e.file;
      const from = e.origin ? `${e.origin.commit}${e.origin.agent ? ` (${e.origin.agent})` : ""}` : "";
      const outcome = e.reason ? `${e.outcome}: ${cell(e.reason)}` : e.outcome;
      out.push(`| ${e.id.split("#")[1]} | ${cell(where)} | ${e.guideline} | ${cell(e.source)} | ${code(e.before)} → ${code(e.after)} | ${cell(e.why)} | ${from} | ${outcome} |`);
    }
    out.push("");
  }
  if (!entries.length) out.push("No changes or decisions were logged.", "");
  mkdirSync(REPORT_DIR, { recursive: true });
  const path = join(REPORT_DIR, `${meta.run}.md`);
  writeFileSync(path, out.join("\n"));
  console.log(path);
}

// Close earlier runs' kept candidates whose branch was deleted or left unmerged: the user rejected them.
function cmdSweep(args) {
  need(args, "base");
  const cfg = loadConfig();
  const rejected = [];
  for (const r of allRuns()) {
    for (const e of r.entries) {
      if (e.kind !== "decision" || !e.candidate || e.outcome !== "kept" || !e.branch || !e.tip) continue;
      if (git("merge-base", "--is-ancestor", e.tip, args.base) !== null) continue; // merged
      const exists = git("rev-parse", "--verify", `refs/heads/${e.branch}`) !== null;
      // A squash or rebase merge changes the sha; `git cherry` still sees the patches as applied.
      if (exists && !(git("cherry", args.base, e.branch) ?? "+").split("\n").some((l) => l.startsWith("+"))) continue;
      const ageDays = (Date.now() - new Date(r.meta.date)) / 864e5;
      if (exists && ageDays < cfg.branchStaleDays) continue;
      const reason = exists ? `unmerged after ${Math.floor(ageDays)} days` : "branch deleted without merging";
      cmdOutcome({ run: r.meta.run, id: e.id, outcome: "rejected", reason });
      rejected.push(e.id);
    }
  }
  console.log(JSON.stringify({ rejected }));
}

function lessonIds() {
  const path = join(ROOT, "lessons.md");
  if (!existsSync(path)) return [];
  return [...readFileSync(path, "utf8").matchAll(/^- \[([\w.-]+)\]/gm)].map((m) => m[1]);
}

function projectRuleGuidelines() {
  // Guidelines that already have a rule, bundled or project-local.
  const ids = new Set();
  const skillRules = new URL("../rules/", import.meta.url).pathname;
  for (const dir of [skillRules, join(ROOT, "rules")]) {
    if (!existsSync(dir)) continue;
    for (const sub of readdirSync(dir, { recursive: true })) {
      if (!String(sub).endsWith(".yml")) continue;
      const text = readFileSync(join(dir, String(sub)), "utf8");
      for (const m of text.matchAll(/^\s*guideline:\s*([\w.-]+)/gm)) ids.add(m[1]);
    }
  }
  return ids;
}

function cmdDistil() {
  const cfg = loadConfig();
  const runs = allRuns();
  const entries = runs.flatMap((r) => r.entries.map((e) => ({ ...e, runDate: r.meta.date })));
  const isImpl = (e) => e.origin?.agent === cfg.implementerTrailer.value;
  // One count per occurrence: line-level changes count themselves; an architecture candidate counts once,
  // through its decision entry (kept/reverted/rejected), not once per change made for it.
  const LOG_ONLY = ["characterisation-tests", "new-rule", "glossary"];
  const smells = entries.filter(
    (e) =>
      !LOG_ONLY.includes(e.guideline) &&
      ((e.kind === "change" && !e.candidate) || (e.kind === "decision" && e.candidate && ["kept", "reverted", "rejected"].includes(e.outcome))),
  );
  const implKept = smells.filter((e) => isImpl(e) && e.outcome === "kept");

  const byGuideline = (list) => list.reduce((m, e) => m.set(e.guideline, [...(m.get(e.guideline) ?? []), e]), new Map());
  const lessons = lessonIds();
  const ruled = projectRuleGuidelines();
  const sample = (list) => list.slice(-3).map((e) => ({ id: e.id, file: e.file, line: e.line, before: e.before, after: e.after }));

  const newLessons = [...byGuideline(implKept)]
    .filter(([g, list]) => list.length >= cfg.lessonThreshold && !lessons.includes(g))
    .map(([guideline, list]) => ({ guideline, count: list.length, examples: sample(list) }));

  const ruleCandidates = [...new Set([...lessons, ...newLessons.map((l) => l.guideline)])]
    .filter((g) => !ruled.has(g))
    .map((guideline) => ({ guideline, examples: sample(implKept.filter((e) => e.guideline === guideline)) }));

  const falsePositives = [...byGuideline(smells.filter((e) => e.outcome === "reverted" || e.outcome === "rejected"))].map(([guideline, list]) => ({
    guideline,
    count: list.length,
    cases: list.slice(-5).map((e) => ({ id: e.id, file: e.file, line: e.line, before: e.before, after: e.after, reason: e.reason })),
  }));

  const recentRuns = new Set(runs.slice(-cfg.staleAfterRuns).map((r) => r.meta.run));
  const staleLessons =
    runs.length < cfg.staleAfterRuns ? [] : lessons.filter((g) => !implKept.some((e) => e.guideline === g && recentRuns.has(e.run)));

  console.log(JSON.stringify({ runs: runs.length, lessonCount: lessons.length, maxLessons: cfg.maxLessons, newLessons, ruleCandidates, falsePositives, staleLessons }, null, 2));
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [cmd, ...rest] = process.argv.slice(2);
  const commands = { "new-run": cmdNewRun, add: cmdAdd, outcome: cmdOutcome, report: cmdReport, distil: cmdDistil, sweep: cmdSweep };
  if (!commands[cmd]) fail(`usage: refactor-log.mjs <${Object.keys(commands).join("|")}> [options]`);
  commands[cmd](parseArgs(rest));
}
