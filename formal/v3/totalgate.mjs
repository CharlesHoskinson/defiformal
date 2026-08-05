/* Every headline total in the article must equal what the verdicts say.
 * Round 2 found 45.5 against 45.3, 573 against 570, and 686 against 689,
 * because three forced fits were withdrawn and the prose was not regenerated.
 * This makes that class of drift a build failure. */
import fs from "node:fs";
import path from "node:path";

const ROOT = "/root/defiformal/expansion";
let tot = 0, cov = 0, inad = 0, assigned = 0, approx = 0;
for (const slug of fs.readdirSync(ROOT).filter(d => /^\d\d-/.test(d))) {
  const vp = path.join(ROOT, slug, "verdicts.json");
  if (!fs.existsSync(vp)) continue;
  for (const v of JSON.parse(fs.readFileSync(vp, "utf8"))) {
    tot += v.obligationsTotal; cov += v.obligationsCovered;
    if (v.verdict === "INADMISSIBLE") inad++;
  }
  const sd = path.join(ROOT, slug, "specs");
  for (const f of fs.readdirSync(sd).filter(f => f.endsWith(".json")))
    for (const o of JSON.parse(fs.readFileSync(path.join(sd, f), "utf8")).functionalObligations) {
      if (!(o.elements || []).length) continue;
      assigned++;
      if (/approx|forced|partial|stretch/i.test(o.note || "")) approx++;
    }
}
const res = tot - cov, pct = (100 * cov / tot).toFixed(1);
const strict = (100 * (cov - approx) / tot).toFixed(1);

const tex = fs.readFileSync("/root/defiformal/paper/atlas.tex", "utf8");
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
