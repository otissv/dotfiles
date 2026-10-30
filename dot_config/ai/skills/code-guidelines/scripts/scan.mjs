#!/usr/bin/env node
// Run the code-guidelines ast-grep rules on the files in scope and print findings as JSON.
// Run from the project root.
//
//   --mode turn                 uncommitted and untracked files
//   --mode diff --base <ref>    files changed since the merge base with <ref>, plus uncommitted
//   --mode path --path <dir>    everything under <dir>
//   --apply-safe --run <id>     log, then apply, findings whose rule has metadata.autofix: safe
//   --new-only                  drop findings already logged as skipped, suggested, reverted or rejected
//
// Uses AST_GREP_BIN, else `ast-grep`, else `sg` (only if it is ast-grep).
// Bundled rules come from ../sgconfig.yml; project rules from .refactor/rules/ (ignored if absent).
// Rules listed in .refactor/config.json "disabledRules" (rule ids or guideline ids) are dropped.

import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const here = fileURLToPath(new URL(".", import.meta.url));
const BUNDLED = join(here, "..", "sgconfig.yml");
const LOG = join(here, "refactor-log.mjs");
const PROJECT_RULES = join(".refactor", "rules");
const PROJECT_CONFIG = join(".refactor", "sgconfig.yml");

function fail(msg) {
  console.error(`scan: ${msg}`);
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

function lines(cmd, ...a) {
  const r = spawnSync(cmd, a, { encoding: "utf8" });
  if (r.status !== 0) fail(`${cmd} ${a.join(" ")} failed: ${r.stderr.trim()}`);
  return r.stdout.split("\n").map((s) => s.trim()).filter(Boolean);
}

export function findBinary() {
  const candidates = [process.env.AST_GREP_BIN, "ast-grep", "sg"].filter(Boolean);
  for (const bin of candidates) {
    const r = spawnSync(bin, ["--version"], { encoding: "utf8" });
    if (r.status === 0 && /ast-grep/i.test(r.stdout)) return bin;
  }
  return null;
}

function filesInScope(args) {
  const untracked = () => lines("git", "ls-files", "--others", "--exclude-standard");
  let files;
  if (args.mode === "turn") files = [...lines("git", "diff", "--name-only", "HEAD"), ...untracked()];
  else if (args.mode === "diff") {
    if (typeof args.base !== "string") fail("--mode diff needs --base <ref>");
    files = [...lines("git", "diff", "--name-only", `${args.base}...HEAD`), ...lines("git", "diff", "--name-only", "HEAD"), ...untracked()];
  } else if (args.mode === "path") {
    if (typeof args.path !== "string") fail("--mode path needs --path <dir>");
    if (!existsSync(args.path)) fail(`no such path ${args.path}`);
    files = [args.path];
  } else fail("--mode must be turn, diff or path");
  return [...new Set(files)].filter((f) => existsSync(f) && !f.startsWith(".refactor/"));
}

function configs() {
  const list = [BUNDLED];
  if (existsSync(PROJECT_RULES)) {
    if (!existsSync(PROJECT_CONFIG)) writeFileSync(PROJECT_CONFIG, "# Project rules added by the code-guidelines distil step.\nruleDirs:\n  - rules\nlanguageGlobs:\n  tsx: [\"*.js\", \"*.jsx\", \"*.mjs\", \"*.cjs\"]\n");
    list.push(PROJECT_CONFIG);
  }
  return list;
}

function runScan(bin, config, files, extra = []) {
  const r = spawnSync(bin, ["scan", "-c", config, ...extra, ...files], { encoding: "utf8", maxBuffer: 256 * 1024 * 1024 });
  if (r.error) fail(r.error.message);
  if (r.status !== 0 && !r.stdout.trim() && r.stderr.trim()) fail(r.stderr.trim());
  return r.stdout;
}

function loadJson(path, fallback) {
  return existsSync(path) ? JSON.parse(readFileSync(path, "utf8")) : fallback;
}

// Findings already decided against, keyed by file + guideline + matched text.
function decidedKeys() {
  const dir = join(".refactor", "log");
  const keys = new Set();
  if (!existsSync(dir)) return keys;
  const ignore = new Set(["skipped", "suggested", "reverted", "rejected"]);
  for (const f of readdirSync(dir).filter((f) => f.endsWith(".jsonl"))) {
    const entries = new Map();
    for (const l of readFileSync(join(dir, f), "utf8").split("\n").filter(Boolean).map((s) => JSON.parse(s))) {
      if (l.type === "entry") entries.set(l.id, { ...l });
      if (l.type === "outcome" && entries.has(l.ref)) entries.get(l.ref).outcome = l.outcome;
    }
    for (const e of entries.values()) if (ignore.has(e.outcome) && e.before) keys.add(`${e.file}\0${e.guideline}\0${e.before}`);
  }
  return keys;
}

const args = parseArgs(process.argv.slice(2));
const bin = findBinary();
if (!bin) fail("ast-grep is not installed (npm i -g @ast-grep/cli, brew install ast-grep, or cargo install ast-grep)");
const files = filesInScope(args);
const cfg = loadJson(join(".refactor", "config.json"), {});
const disabled = new Set(cfg.disabledRules ?? []);

let findings = [];
const ruleConfig = new Map();
if (files.length) {
  for (const config of configs()) {
    const out = runScan(bin, config, files, ["--json=stream", "--include-metadata"]);
    for (const line of out.split("\n").filter(Boolean)) {
      const m = JSON.parse(line);
      const guideline = m.metadata?.guideline ?? m.ruleId.replace(/\.[^.]+$/, "");
      if (disabled.has(m.ruleId) || disabled.has(guideline)) continue;
      ruleConfig.set(m.ruleId, config);
      findings.push({
        rule: m.ruleId,
        guideline,
        autofix: m.metadata?.autofix ?? "none",
        file: m.file,
        line: m.range.start.line + 1,
        text: m.text,
        replacement: m.replacement ?? null,
        message: m.message,
      });
    }
  }
}

if (args["new-only"]) {
  const keys = decidedKeys();
  findings = findings.filter((f) => !keys.has(`${f.file}\0${f.guideline}\0${f.text}`));
}

const applied = [];
if (args["apply-safe"]) {
  if (typeof args.run !== "string") fail("--apply-safe needs --run <id>");
  const safe = findings.filter((f) => f.autofix === "safe" && f.replacement !== null);
  // Log every change before applying, so blame sees the original lines.
  for (const f of safe) {
    const entry = { kind: "change", file: f.file, line: f.line, guideline: f.guideline, source: `rule:${f.rule}`, before: f.text, after: f.replacement, why: f.message };
    applied.push({ ...f, id: execFileSync("node", [LOG, "add", "--run", args.run, "--json", JSON.stringify(entry)], { encoding: "utf8" }).trim() });
  }
  const byConfig = new Map();
  for (const f of safe) byConfig.set(ruleConfig.get(f.rule), new Set([...(byConfig.get(ruleConfig.get(f.rule)) ?? []), f.rule]));
  for (const [config, rules] of byConfig) {
    const escaped = [...rules].map((r) => r.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
    runScan(bin, config, [...new Set(safe.map((f) => f.file))], ["--filter", `^(${escaped.join("|")})$`, "--update-all"]);
  }
  findings = findings.filter((f) => !safe.includes(f));
}

const byGuideline = {};
for (const f of findings) byGuideline[f.guideline] = (byGuideline[f.guideline] ?? 0) + 1;
console.log(JSON.stringify({ mode: args.mode, filesScanned: files.length, applied: applied.map(({ id, file, line, guideline }) => ({ id, file, line, guideline })), remaining: findings.length, byGuideline, findings }, null, 2));
