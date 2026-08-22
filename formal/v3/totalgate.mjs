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
// The denominator the specs walk actually visited. Every guard before this one
// was count-based -- zero versus non-zero -- which says nothing about four
// files of five. A totals gate that will not state how many things it counted
// cannot know it counted them all, so this number is checked against the
// manuscript alongside the other totals.
let specFiles = 0, slugsCounted = 0, verdictRecords = 0, obligationItems = 0;
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
  // `[]` IS an array, so the type check above passes and the loop below runs
  // zero times: tot/cov silently omit this slug while approx still counts its
  // specs, and the comparison proceeds on a short total.
  if (!verdicts.length) blocked(`${vp} is empty; this category's obligations cannot be counted`);
  verdictRecords += verdicts.length;
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
  // A MISSING specs/ throws ENOENT above and blocks. A present-but-empty one,
  // or one whose *.json were renamed, took the other branch: zero iterations,
  // so `approx` came up short while tot/cov stayed complete, and the strict
  // percentage was compared to atlas.tex. Measured: emptying 04-liquid-staking
  // gave `FAIL strict coverage 29.5%` against the paper's 29.0%, exit 1, and
  // BUILD FAILED: a headline total disagrees. Same lie, the other walk.
  // 12 of 12 slugs carry spec JSON, the same standard used for verdicts.json.
  if (!specs.length) {
    blocked(`slug ${slug} has no *.json under specs/; its assignments cannot be counted`);
  }
  slugsCounted++;
  specFiles += specs.length;
  for (const f of specs) {
    const spec = readJson(path.join(sd, f), "spec");
    const obs = spec.functionalObligations;
    if (!Array.isArray(obs)) blocked(`${path.join(sd, f)} has no functionalObligations array`);
    // Same shape again: `[]` passes the type check, the loop runs zero times,
    // the file is counted but its assignments are not. One slug produces a
    // FAIL-blame; ALL sixty produce a SILENT PASS -- the gate reporting that
    // every total agrees while having measured no assignment at all.
    // validate.mjs already rejects an empty FO array; this gate did not consult it.
    if (!obs.length) blocked(`${path.join(sd, f)} has an empty functionalObligations array`);
    obligationItems += obs.length;
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

// The denominator is a completeness question, not a manuscript question. Four
// spec files of five left the zero-file guard silent, shortened `approx`, and
// published a strict-coverage disagreement about a corpus the gate had not
// finished reading. A short walk means the measurement could not be completed:
// exit 3, act on the environment -- never exit 1, which blames the manuscript.
// The two independent sources must agree before anything is compared to the
// manuscript. This needs no hardcoded corpus size: verdicts/ and specs/ each
// carry the same two quantities, and a walk that came up short on either side
// shows up as a disagreement between them rather than as a disagreement with
// the paper. Truncating a verdicts array moves `tot`; making every obligation
// residue moves `assigned`. Both now block instead of publishing.
if (tot !== obligationItems) {
  blocked(`verdicts report ${tot} obligations but specs hold ${obligationItems} items; ` +
          `the corpus is internally inconsistent and the totals cannot be trusted`);
}
if (cov !== assigned) {
  blocked(`verdicts report ${cov} covered but specs hold ${assigned} assigned; ` +
          `the corpus is internally inconsistent and the coverage cannot be trusted`);
}
if (verdictRecords !== specFiles) {
  blocked(`walked ${verdictRecords} verdict records against ${specFiles} spec files; ` +
          `one app is described in only one of the two`);
}

const EXPECT_CATEGORIES = 12, EXPECT_SPEC_FILES = 60;
if (slugsCounted !== EXPECT_CATEGORIES) {
  blocked(`walked ${slugsCounted} categories, expected ${EXPECT_CATEGORIES}; the corpus is incomplete`);
}
if (specFiles !== EXPECT_SPEC_FILES) {
  blocked(`walked ${specFiles} spec files, expected ${EXPECT_SPEC_FILES}; the corpus is incomplete`);
}
console.log(`ok   walked ${slugsCounted} categories, ${specFiles} spec files, ` +
            `${verdictRecords} verdict records, ${obligationItems} obligation items`);
console.log(`ok   the two sources agree: ${tot} obligations, ${cov} covered`);

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
