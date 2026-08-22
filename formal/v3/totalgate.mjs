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
const SELF_ROOT = path.resolve(HERE, "..", "..");
const REPO = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
// A stale DEFIFORMAL_ROOT would otherwise redirect the check to a different tree
// than the one just typeset, silently and with no provenance in the output.
if (REPO !== SELF_ROOT) console.error(`totalgate: NOTE - checking ${REPO} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);
const ROOT = path.join(REPO, "expansion");
const TEXPATH = path.join(REPO, "paper", "atlas.tex");

let slugs;
try {
  slugs = fs.readdirSync(ROOT).filter(d => /^\d\d-/.test(d));
} catch (e) {
  blocked(`cannot read expansion root ${ROOT}: ${e.code || e.message}`);
}
if (!slugs.length) blocked(`no NN-* category slugs under ${ROOT}`);

// Reading the corpus is never a statement about the manuscript. EVERY read and
// parse below is a blocked-check candidate: an unguarded throw exits 1, which is
// the "a headline total disagrees" code. Guarding only readdir left the original
// defect alive one directory deeper.
const readJson = (fp, what) => {
  let raw;
  try {
    raw = fs.readFileSync(fp, "utf8");
  } catch (e) {
    blocked(`cannot read ${what} ${fp}: ${e.code || e.message}`);
  }
  let v;
  try {
    v = JSON.parse(raw);
  } catch (e) {
    blocked(`cannot parse ${what} ${fp}: ${e.message}`);
  }
  // Valid JSON `null` is not a parse failure, so the guard above lets it past
  // and the next property access throws a TypeError -- node exits 1, which is
  // the "manuscript is wrong" code. The contract has to hold at the type, not
  // just at the parse.
  if (v === null || typeof v !== "object") {
    blocked(`${what} ${fp} is ${v === null ? "null" : typeof v}, not an object or array`);
  }
  return v;
};

let tot = 0, cov = 0, inad = 0, assigned = 0, approx = 0;
for (const slug of slugs) {
  const vp = path.join(ROOT, slug, "verdicts.json");
  // existsSync returns false when the slug DIRECTORY is unreadable, so an
  // EACCES here used to be silently skipped -- the slug's obligations vanished
  // from the totals and the short total was then reported as a disagreement.
  // Absent is a skip; unreadable is a blocked check.
  const sdir = path.join(ROOT, slug);
  let st;
  try { st = fs.statSync(sdir); } catch (e) { blocked(`cannot stat slug ${slug}: ${e.code || e.message}`); }
  // Four quadrants, all explicit. Deciding by NAME before stat'ing conflated
  // two of them: a renamed category DIRECTORY (02-lending.bak) was dropped as
  // if it were an editor dropping, its obligations vanished, and the short
  // total was blamed on the manuscript.
  const dropping = /\.(bak|tmp|orig|save|swp|rej)$/i.test(slug) || /~$/.test(slug);
  if (st.isDirectory() && dropping) {
    // an archived copy of a category, or a category someone renamed. Counting it
    // may double-count; ignoring it may drop a category. The gate cannot tell.
    blocked(`slug ${slug} is a directory with a backup suffix; cannot tell an archive from a category`);
  }
  if (!st.isDirectory() && !dropping) {
    blocked(`slug ${slug} is not a directory; cannot tell a stray file from a clobbered category`);
  }
  if (!st.isDirectory() && dropping) continue;   // an editor dropping; never a category
  try {
    fs.accessSync(sdir, fs.constants.R_OK | fs.constants.X_OK);
  } catch (e) {
    blocked(`cannot enter slug ${slug}: ${e.code || e.message}`);
  }
  // Every category slug in this corpus carries a verdicts.json (12 of 12,
  // measured). A missing one is a corpus defect, not a category that legitimately
  // has no verdicts -- and skipping it drops that slug's obligations, so the
  // short total is then compared and blamed on the manuscript. Deleting one
  // produced exit 1 and "3 total(s) out of step" before this guard.
  if (!fs.existsSync(vp)) {
    blocked(`slug ${slug} has no verdicts.json; its obligations cannot be counted`);
  }
  const verdicts = readJson(vp, "verdicts");
  if (!Array.isArray(verdicts)) blocked(`${vp} is not an array of verdicts`);
  for (const v of verdicts) {
    if (v === null || typeof v !== "object") blocked(`${vp} holds a ${v === null ? "null" : typeof v} verdict`);
    if (!Number.isFinite(v.obligationsTotal) || !Number.isFinite(v.obligationsCovered)) {
      blocked(`${vp} has a non-numeric obligation count`);
    }
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
  for (const f of specs) {
    const spec = readJson(path.join(sd, f), "spec");
    const obs = spec.functionalObligations;
    if (!Array.isArray(obs)) blocked(`${path.join(sd, f)} has no functionalObligations array`);
    for (const o of obs) {
      if (o === null || typeof o !== "object") blocked(`${path.join(sd, f)} holds a null obligation`);
      if (!(o.elements || []).length) continue;
      assigned++;
      if (/approx|forced|partial|stretch/i.test(o.note || "")) approx++;
    }
  }
}
if (!Number.isFinite(tot) || !Number.isFinite(cov)) {
  blocked("a verdict carried a non-numeric obligation count; totals are not computable");
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
