#!/usr/bin/env node
// Claude Code status line. Receives session JSON on stdin, prints multi-line status.
// Built to mirror a 3-part layout: model+limits / project summary / per-file git changes.
const { execSync } = require("child_process");

// ---- read stdin ----
let raw = "";
try { raw = require("fs").readFileSync(0, "utf8"); } catch {}
let d = {};
try { d = JSON.parse(raw); } catch {}

// ---- ansi helpers ----
const e = (c, s) => `\x1b[${c}m${s}\x1b[0m`;
const c256 = (n, s) => e(`38;5;${n}`, s);
const AMBER = 214, CYAN = 44, GREEN = 78, RED = 203, GRAY = 244, WHITE = 252, MAGENTA = 176;
const amber = (s) => c256(AMBER, s);
const gray = (s) => c256(GRAY, s);
const pctColor = (p) => c256(p < 50 ? GREEN : p < 80 ? AMBER : RED, `${p}%`);

// ---- time formatting (local) ----
const pad = (n) => String(n).padStart(2, "0");
const hm = (ts) => { const t = new Date(ts * 1000); return `${pad(t.getHours())}:${pad(t.getMinutes())}`; };
const mdhm = (ts) => { const t = new Date(ts * 1000); return `${pad(t.getMonth() + 1)}/${pad(t.getDate())} ${pad(t.getHours())}:${pad(t.getMinutes())}`; };
const nowSec = () => Math.floor(Date.now() / 1000);

// ---- line 1: model + context + rate limits ----
const model = d.model?.display_name || "Claude";
const effort = d.effort?.level || "";
const cw = d.context_window || {};
const ctxPct = cw.used_percentage ?? 0;
const is1M = (cw.context_window_size || 0) >= 1000000;
const rl = d.rate_limits || {};
const five = rl.five_hour || {};
const week = rl.seven_day || {};

let line1 = amber(model);
if (is1M) line1 += " " + gray("(1M context)");
if (effort) line1 += " " + amber(effort);
line1 += " " + pctColor(ctxPct);
if (five.used_percentage != null) {
  line1 += " " + amber("[5]") + pctColor(five.used_percentage);
  if (five.resets_at) line1 += " " + amber(hm(five.resets_at));
}
if (week.used_percentage != null) {
  line1 += " " + amber("[W]") + pctColor(week.used_percentage);
  if (week.resets_at) line1 += " " + amber(mdhm(week.resets_at));
}

// ---- git context ----
const cwd = d.workspace?.current_dir || d.cwd || process.cwd();
const git = (cmd) => {
  try { return execSync(`git ${cmd}`, { cwd, stdio: ["ignore", "pipe", "ignore"] }).toString(); }
  catch { return null; }
};
const root = (git("rev-parse --show-toplevel") || "").trim();
const isRepo = !!root;
const branch = isRepo ? (git("rev-parse --abbrev-ref HEAD") || "").trim() : "";

// ---- line 2: project summary ----
const dirBase = cwd.split("/").filter(Boolean).pop() || cwd;
const cost = d.cost || {};
const added = cost.total_lines_added ?? 0;
const removed = cost.total_lines_removed ?? 0;
const costUsd = cost.total_cost_usd ?? 0;
// "72.0h" -> hours until weekly limit reset (only hours-value derivable from JSON).
// To change this metric, edit the `hrs` line below.
const hrs = week.resets_at ? Math.max(0, (week.resets_at - nowSec()) / 3600).toFixed(1) : null;

let line2 = c256(CYAN, dirBase);
if (branch) line2 += gray(" · ") + amber(branch);
line2 += " " + c256(GREEN, `+${added}`) + (removed > 0 ? c256(RED, `-${removed}`) : gray(`-${removed}`));
line2 += " " + c256(GREEN, `$${costUsd.toFixed(1)}`);
if (hrs != null) line2 += " " + gray(`${hrs}h`);

const out = [line1, line2];

// ---- per-file git changes (all changed files) ----
if (isRepo) {
  // working-tree vs HEAD numstat: added/removed per path (staged + unstaged combined)
  const numstat = {};
  for (const ln of (git("diff --numstat HEAD") || "").split("\n")) {
    const m = ln.match(/^(\S+)\t(\S+)\t(.+)$/);
    if (m) numstat[m[3]] = { a: m[1], r: m[2] };
  }
  const rows = [];
  for (const ln of (git("status --porcelain") || "").split("\n")) {
    if (!ln.trim()) continue;
    const xy = ln.slice(0, 2);
    let p = ln.slice(3);
    if (p.includes(" -> ")) p = p.split(" -> ")[1]; // renames
    const ns = numstat[p] || {};
    let total = "?";
    try { total = execSync(`wc -l < ${JSON.stringify(root + "/" + p)}`, { stdio: ["ignore", "pipe", "ignore"] }).toString().trim(); } catch {}
    rows.push({ xy, a: ns.a ?? "-", r: ns.r ?? "-", total, p });
  }
  for (const row of rows) {
    const add = row.a === "-" ? gray("  -") : c256(GREEN, `+${row.a}`);
    const rem = row.r === "-" ? gray("  -") : c256(RED, `-${row.r}`);
    const line =
      c256(AMBER, row.xy) + " " +
      add + " ".repeat(Math.max(1, 5 - String(row.a).length)) +
      rem + " ".repeat(Math.max(1, 5 - String(row.r).length)) +
      gray(`${row.total}L`) + " " +
      c256(WHITE, row.p);
    out.push(line);
  }
}

process.stdout.write(out.join("\n"));
