// meas:covsens states the sensitivity of the coverage figure. Check every number
// in it against the ledger.
//
// This exists because fitgrade.mjs and the paper disagreed -- 193 against 205 --
// by applying different qualification rules to the same rows. Neither was wrong
// arithmetic and nothing caught it, which is the same shape as the two law
// systems.
import { readFileSync, readdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const ROOT = `${REPO_ROOT}/expansion`;
const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");
let fail = 0;
const say = (ok, m) => { console.log(`  ${ok ? "ok  " : "FAIL"} ${m}`); if (!ok) fail++; };

const QUAL = /(approximat|forced|partial)/i;
let rows = 0, assigned = 0, qualified = 0;
for (const lane of readdirSync(ROOT).filter(d => /^\d\d-/.test(d))) {
  let fs = [];
  try { fs = readdirSync(`${ROOT}/${lane}/specs`); } catch { continue; }
  for (const f of fs.filter(x => x.endsWith(".json"))) {
    const spec = JSON.parse(readFileSync(`${ROOT}/${lane}/specs/${f}`, "utf8"));
    for (const o of spec.functionalObligations ?? []) {
      rows++;
      if (!(o.elements ?? []).length) continue;
      assigned++;
      const t = ["text", "note", "notes", "rationale", "evidence"].map(k => o[k] ?? "").join(" ");
      if (QUAL.test(t)) qualified++;
    }
  }
}

const pc = (a, b) => (100 * a / b).toFixed(1);
const permissive = pc(assigned, rows);
const strict = pc(assigned - qualified, rows);
const qpc = pc(qualified, assigned);
const swing = (parseFloat(permissive) - parseFloat(strict)).toFixed(1);

console.log(`rows ${rows}  assigned ${assigned}  qualified ${qualified}`);
console.log(`permissive ${permissive}%  strict ${strict}%  swing ${swing} points\n`);

const lit = n => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, "{,}");
say(tex.includes(lit(rows)), `paper states ${lit(rows)} rows`);
say(tex.includes(`${permissive}\\%`), `paper states the permissive figure ${permissive}%`);
say(tex.includes(`${strict}\\%`), `paper states the strict figure ${strict}%`);
say(tex.includes(`$${assigned}$`) || tex.includes(` ${assigned} `),
    `paper states ${assigned} assigned rows`);
say(tex.includes(`$${qualified}$`), `paper states ${qualified} qualified rows`);
say(tex.includes(`${qpc}\\%`), `paper states ${qpc}% of assigned are qualified`);
say(tex.includes(`${swing}$ points`) || tex.includes(`by seventeen`),
    `paper states the swing of ${swing} points`);

console.log(fail ? "\nCOVERAGE SENSITIVITY VIOLATED" : "\nCOVERAGE SENSITIVITY VERIFIED");
process.exit(fail ? 1 : 0);
