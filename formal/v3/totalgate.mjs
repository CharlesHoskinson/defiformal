/* Every headline total in the article must equal what the verdicts say.
 * Round 2 found 45.5 against 45.3, 573 against 570, and 686 against 689,
 * because three forced fits were withdrawn and the prose was not regenerated.
 * This makes that class of drift a build failure.
 *
 * Exit codes are a contract with paper/build.sh:
 *   0  every total agrees, over a non-empty corpus
 *   1  a total disagrees -- act on the manuscript
 *   3  the check could not run -- act on the environment. Never reported as 1.
 * An empty corpus is exit 3, not exit 0 and not exit 1: with tot === 0 the
 * percentages are NaN, every `has` test fails, and the gate would otherwise
 * announce a totals disagreement it never measured. */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const blocked = (msg) => {
  console.error(`totalgate: BLOCKED - ${msg}`);
  process.exit(3);
};

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = process.env.DEFIFORMAL_ROOT || path.resolve(HERE, "..", "..");
const ROOT = path.join(REPO, "expansion");
const TEXPATH = path.join(REPO, "paper", "atlas.tex");

let slugs;
try {
  slugs = fs.readdirSync(ROOT).filter(d => /^\d\d-/.test(d));
} catch (e) {
  blocked(`cannot read expansion root ${ROOT}: ${e.code || e.message}`);
}
if (!slugs.length) blocked(`no NN-* category slugs under ${ROOT}`);

let tot = 0, cov = 0, inad = 0, assigned = 0, approx = 0;
for (const slug of slugs) {
  const vp = path.join(ROOT, slug, "verdicts.json");
  if (!fs.existsSync(vp)) continue;
  for (const v of JSON.parse(fs.readFileSync(vp, "utf8"))) {
    tot += v.obligationsTotal; cov += v.obligationsCovered;
    if (v.verdict === "INADMISSIBLE") inad++;
  }
  const sd = path.join(ROOT, slug, "specs");
  let specs;
  try {
    specs = fs.readdirSync(sd).filter(f => f.endsWith(".json"));
  } catch (e) {
    blocked(`cannot read specs for ${slug}: ${e.code || e.message}`);
  }
  for (const f of specs)
    for (const o of JSON.parse(fs.readFileSync(path.join(sd, f), "utf8")).functionalObligations) {
      if (!(o.elements || []).length) continue;
      assigned++;
      if (/approx|forced|partial|stretch/i.test(o.note || "")) approx++;
    }
}
if (tot === 0) blocked(`examined ${slugs.length} slug(s) but 0 obligations - nothing to check`);

const res = tot - cov, pct = (100 * cov / tot).toFixed(1);
const strict = (100 * (cov - approx) / tot).toFixed(1);

let tex;
try {
  tex = fs.readFileSync(TEXPATH, "utf8");
} catch (e) {
  blocked(`cannot read ${TEXPATH}: ${e.code || e.message}`);
}
const has = t => tex.includes(t);
const gp = n => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, "{,}");

let bad = 0;
const must = [
  [`obligations total ${tot}`, has(`$${gp(tot)}$`)],
  [`residue total ${res}`,     has(`$${res}$`) || has(`$${gp(res)}$`)],
  [`coverage ${pct}%`,         has(`$${pct}\\%$`)],
  [`strict coverage ${strict}%`, has(`$${strict}\\%$`)],
];
for (const [what, ok] of must) {
  console.log(`${ok ? "ok  " : "FAIL"} ${what}`);
  if (!ok) bad++;
}
/* stale values that must NOT appear */
for (const stale of ["45.5\\%", "$573$", "$686$", "28.8\\%"]) {
  const present = tex.includes(stale);
  console.log(`${present ? "FAIL" : "ok  "} stale value ${stale} absent`);
  if (present) bad++;
}
console.log(bad ? `\n${bad} total(s) out of step with the verdicts` : "\nall headline totals agree with the verdicts");
process.exit(bad ? 1 : 0);
