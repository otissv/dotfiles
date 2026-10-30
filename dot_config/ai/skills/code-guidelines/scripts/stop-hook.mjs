#!/usr/bin/env node
// Claude Code Stop hook: when the turn's changed files still match a code-guidelines rule,
// block the stop once and ask the agent to run the code-guidelines skill on them.
// Findings already logged as skipped, suggested, reverted or rejected are ignored (--new-only),
// so a deliberate skip never blocks again. Exits 0 (allow stop) on anything unexpected.

import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

let input = {};
try {
  input = JSON.parse(readFileSync(0, "utf8") || "{}");
} catch {
  process.exit(0);
}
// Already continuing because of a Stop hook: never block twice in a row.
if (input.stop_hook_active) process.exit(0);
if (input.cwd) process.chdir(input.cwd);

const scan = join(fileURLToPath(new URL(".", import.meta.url)), "scan.mjs");
const r = spawnSync("node", [scan, "--mode", "turn", "--new-only"], { encoding: "utf8" });
if (r.status !== 0) process.exit(0);

let result;
try {
  result = JSON.parse(r.stdout);
} catch {
  process.exit(0);
}
if (!result.remaining) process.exit(0);

const list = result.findings
  .slice(0, 20)
  .map((f) => `- ${f.file}:${f.line} ${f.guideline} (${f.autofix})`)
  .join("\n");
const more = result.remaining > 20 ? `\n- ...and ${result.remaining - 20} more` : "";
process.stderr.write(
  `code-guidelines: ${result.remaining} finding(s) in files changed this turn:\n${list}${more}\n` +
    `Run the code-guidelines skill in turn mode on these before finishing. ` +
    `Log any finding you decide not to fix as a skipped decision so it is not raised again.\n`,
);
process.exit(2);
