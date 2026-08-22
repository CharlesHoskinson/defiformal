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
// A needle matched anywhere in a 151 KB document is not a check of the claim.
// Scope each one to the block that makes it: a coverage figure that only
// matches because the same digits appear in an unrelated sentence is a silent
// pass, and grok constructed exactly that (approx driven to 0, strict becomes
// "45.3", satisfied by the coverage literal eleven lines above).
// A LaTeX comment is never typeset, so it cannot carry a claim -- but a
// first-match search finds it anyway. Strip comments before any claim matching.
// `%` is only a comment when not escaped as `\%`.
// Backslash PARITY, not the single preceding character. An even number of
// backslashes before % leaves the % live, so `\\%` (a table row's line break
// followed by a comment) starts a real comment while `\%` is a literal percent.
// Consume the pairs inside the match so both cases resolve correctly.
const visible = tex
  .replace(/(^|[^\\])((?:\\\\)*)%.*$/gm, "$1$2");

// Which branch of a TeX conditional is typeset cannot be decided without running
// TeX. Stripping `\iffalse ... \fi` closed one pole and left its dual open
// (`\iftrue $690$ \else $689$ \fi` typesets 690 while a matcher sees 689), and
// enumerating the rest -- \ifnum, \ifx, \ifcase, any \newif or package
// conditional -- is the same mistake repeated. The gate refuses to guess
// instead: a conditional anywhere in a claim region means the gate cannot know
// what the reader sees, and that is a blocked check.
const CONDITIONAL = /\\(if[a-zA-Z@]*|else|fi)\b/;
const noConditional = (region, what) => {
  const m = region.match(CONDITIONAL);
  if (m) {
    blocked(`a TeX conditional (${m[0]}) appears in ${what}; the gate cannot know ` +
            `which branch is typeset and will not guess`);
  }
  return region;
};
const block = (label, env) => {
  const hits = visible.split(`\\label{${label}}`).length - 1;
  if (hits === 0) blocked(`atlas.tex has no \\label{${label}}; the claim site is gone`);
  // Same rule the sibling matchers enforce: two claim sites means the gate
  // cannot tell which one the reader sees.
  if (hits > 1) blocked(`atlas.tex defines \\label{${label}} ${hits} times; the gate ` +
                        `cannot tell which environment is the claim site`);
  const at = visible.indexOf(`\\label{${label}}`);
  // The label can sit anywhere inside its environment -- near the top of a
  // measurement, but inside the CAPTION of a table, below the tabular body.
  // Bound the block by the environment, not by the label's position.
  const start = visible.lastIndexOf(`\\begin{${env}}`, at);
  if (start < 0) blocked(`\\label{${label}} is not inside a \\begin{${env}}`);
  const end = visible.indexOf(`\\end{${env}}`, at);
  if (end < 0) blocked(`\\label{${label}} is not closed by \\end{${env}}`);
  return noConditional(visible.slice(start, end), `\\label{${label}}'s environment`);
};
const COVSENS = block("meas:covsens", "measurement");
const CATTAB  = block("tab:categories", "table");
// `has` keeps its whole-document meaning ONLY for the stale-value blacklist,
// where "absent anywhere" is exactly the property wanted.
const has = t => tex.includes(t);
// The same figure appears two ways: `$1{,}259$` in prose, bare `1259` in a
// table cell. Match the NUMBER within the claim blocks, in either form, with a
// boundary so 689 does not match 6890 and 45.3 does not match 145.3.
// EVERY block that states the figure must state the same one. Accepting it in
// either block let a prose edit pass while the table still agreed -- the paper
// would be internally inconsistent and the gate would call it fine.
const numRe = (n) => {
  const esc = (x) => x.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`(^|[^0-9.,{])(\\$?${esc(gp(n))}\\$?|\\$?${esc(String(n))}\\$?)([^0-9.,}]|$)`);
};
const claimsNumIn = (n, blocks) => blocks.every(b => numRe(n).test(b));

// The total row is a ROW: cells carry meaning by position. Testing that each
// number occurs somewhere in the table let the cells be permuted -- including
// into an arithmetically impossible order -- while every check said ok.
const TOTAL_ROW = (() => {
  const rows = CATTAB.match(/^\s*total\s*&[^\\]*\\\\/gm);
  if (!rows || !rows.length) {
    blocked("tab:categories has no `total & ...` row; the gate cannot read the totals row");
  }
  // The same ambiguity rule. First-match resolution let a second total row --
  // hidden where the reader never sees it -- stand in for the typeset one.
  if (rows.length > 1) {
    blocked(`tab:categories has ${rows.length} \`total & ...\` rows; the gate cannot ` +
            `tell which one is typeset`);
  }
  const cells = rows[0].replace(/\\\\\s*$/, "").split("&").map(c => c.trim());
  return cells;
})();
// total & --- & obligations & covered & residue & inadmissible
const cellIs = (idx, n) => {
  if (TOTAL_ROW.length < 6) {
    blocked(`the total row has ${TOTAL_ROW.length} cells, expected 6: ${TOTAL_ROW.join(" & ")}`);
  }
  const want = String(n), got = TOTAL_ROW[idx];
  return got === want || got === gp(n) || got === `$${want}$` || got === `$${gp(n)}$`;
};
// A percentage must appear in the SENTENCE that asserts it, not merely in the
// same block. `meas:covsens` states both the pooled coverage and the strict
// figure; matching either one anywhere in the block let a mutated strict value
// be satisfied by the coverage literal eleven lines above -- a silent PASS.
const claimsPctAt = (v, contextRe) => {
  const esc = String(v).replace(".", "\\.");
  const all = COVSENS.match(new RegExp(contextRe.source, contextRe.flags.includes("g")
    ? contextRe.flags : contextRe.flags + "g"));
  if (!all || !all.length) {
    blocked(`atlas.tex no longer states this figure where the gate expects it: ${contextRe}`);
  }
  if (all.length > 1) {
    blocked(`atlas.tex states this claim ${all.length} times; the gate cannot tell ` +
            `which one is typeset: ${contextRe}`);
  }
  return new RegExp(`(^|[^0-9.])${esc}\\\\%`).test(all[0]);
};
// Bounded windows, not sentence-terminated: the figures contain dots
// ($45.3\%$), so a [^.] window closes before the number it is meant to capture.
// "Pooling all $1{,}259$ rows gives $45.3\%$; ..."
const COVERAGE_CLAIM = /Pooling all[\s\S]{0,60}rows gives[\s\S]{0,40}/;
// "Counting those as residue gives\n$29.0\%$, a swing of ..."
const STRICT_CLAIM   = /Counting those as residue gives[\s\S]{0,40}/;
// The residue total is claimed twice: bare in the tab:categories total row, and
// in the sentence opening sec:extend. Requiring only the table meant a prose
// edit shipped an internally inconsistent paper at exit 0 -- the mirror of the
// defect the whole-document search had.
const RESIDUE_CLAIM  = /The sixty constructions leave[\s\S]{0,40}/;
// "The ledgers hold 1{,}259 obligations across 60 applications" -- a third site
// for the flagship total, outside both meas:covsens and tab:categories. Found by
// counting visible occurrences mechanically after hand enumeration missed it twice.
const LEDGERS_CLAIM  = /The ledgers hold[\s\S]{0,40}/;
// "and $29.0\%$ is the strict one" -- a second site for the strict figure, in
// the remark following the measurement, outside COVSENS.
const STRICT_REMARK  = /is the strict one/;
const claimsPctAnywhereAt = (v, contextRe) => {
  const esc = String(v).replace(".", "\\.");
  const all = visible.match(new RegExp(contextRe.source, "g"));
  if (!all || !all.length) {
    blocked(`atlas.tex no longer states this figure where the gate expects it: ${contextRe}`);
  }
  if (all.length > 1) {
    blocked(`atlas.tex states this claim ${all.length} times; the gate cannot tell ` +
            `which one is typeset: ${contextRe}`);
  }
  // the remark states the figure just before the phrase, so widen backwards
  const at = visible.indexOf(all[0]);
  // A 40-character lookbehind admits a decoy: a stale $29.0\%$ sitting just
  // before a changed claim satisfied the match. Take only the LAST percentage
  // before the phrase, which is the one the sentence is about.
  const before = noConditional(visible.slice(Math.max(0, at - 40), at),
                              `the text preceding ${contextRe}`);
  const pcts = before.match(/[0-9]+\.[0-9]+\\%/g);
  if (!pcts || !pcts.length) {
    blocked(`no percentage precedes the claim phrase: ${contextRe}`);
  }
  const window = pcts[pcts.length - 1];
  return new RegExp(`(^|[^0-9.])${esc}\\\\%`).test(window);
};
const claimsNumAt = (n, contextRe) => {
  // Search the VISIBLE text, and require the claim to be unique. A first-match
  // search let a decoy -- in a comment, or simply earlier in the body -- stand
  // in for the sentence that actually prints. Two candidates means the gate
  // cannot tell which one the reader sees, and that is a blocked check.
  const all = visible.match(new RegExp(contextRe.source, contextRe.flags.includes("g")
    ? contextRe.flags : contextRe.flags + "g"));
  if (!all || !all.length) {
    blocked(`atlas.tex no longer states this figure where the gate expects it: ${contextRe}`);
  }
  if (all.length > 1) {
    blocked(`atlas.tex states this claim ${all.length} times; the gate cannot tell ` +
            `which one is typeset: ${contextRe}`);
  }
  return numRe(n).test(noConditional(all[0], `the claim matched by ${contextRe}`));
};
const gp = n => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, "{,}");

let bad = 0;
const must = [
  // tot is stated twice: in meas:covsens and in the tab:categories total row.
  // res is stated in the table only.
  [`obligations total ${tot}`,   cellIs(2, tot) && claimsNumIn(tot, [COVSENS]) && claimsNumAt(tot, LEDGERS_CLAIM)],
  [`residue total ${res}`,       cellIs(4, res) && claimsNumAt(res, RESIDUE_CLAIM)],
  // The other two cells of the same total row. They were accumulated and never
  // compared, while the gate printed "all headline totals agree" -- vouching for
  // a row of which it had measured half.
  [`covered total ${cov}`,       cellIs(3, cov) && claimsNumIn(cov, [COVSENS])],
  [`inadmissible total ${inad}`, cellIs(5, inad)],
  // Each of these occurs exactly ONCE in visible text, so the every-site rule
  // applies cleanly. They were unregistered, not unregisterable -- the register
  // overstated the limit by generalising from `inad`'s six collisions.
  [`approximate-fit rows ${approx}`, claimsNumIn(approx, [COVSENS])],
  [`approximate share ${(100 * approx / cov).toFixed(1)}%`,
                                 claimsPctAt((100 * approx / cov).toFixed(1), /Of the[\s\S]{0,120}/)],
  [`coverage ${pct}%`,           claimsPctAt(pct, COVERAGE_CLAIM)],
  [`strict coverage ${strict}%`, claimsPctAt(strict, STRICT_CLAIM) && claimsPctAnywhereAt(strict, STRICT_REMARK)],
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
