/* Reject a malformed construction spec before it reaches the checker.
 * A spec that fails here is a defect in the lane that wrote it, not a finding. */
import { MECH } from "../v2/tables.mjs";
import fs from "node:fs";

const E = new Set(MECH);
const URL_RE = /https?:\/\/[^\s)\]]+/;
const DATE_RE = /\b20\d{2}-\d{2}-\d{2}\b/;

export function validate(spec, file) {
  const err = [], warn = [];
  const need = (k, t) => { if (typeof spec[k] !== t || (t === "string" && !spec[k].trim())) err.push(`missing or empty ${k}`); };
  need("app", "string"); need("category", "string");
  if (!Array.isArray(spec.construction)) err.push("construction must be an array");
  else {
    const bad = spec.construction.filter(e => !E.has(e));
    if (bad.length) err.push(`not elements of the 58: ${bad.join(",")}`);
    if (new Set(spec.construction).size !== spec.construction.length) err.push("construction has duplicates");
    if (!spec.construction.length) err.push("construction is empty");
  }
  const O = spec.functionalObligations;
  if (!Array.isArray(O) || !O.length) err.push("functionalObligations must be a non-empty array");
  else {
    const ids = new Set();
    for (const [i, o] of O.entries()) {
      const at = `obligation ${o.id ?? `#${i}`}`;
      if (!o.id) err.push(`${at}: no id`);
      else if (ids.has(o.id)) err.push(`${at}: duplicate id`);
      else ids.add(o.id);
      if (!o.text || o.text.trim().length < 20) err.push(`${at}: text must state one thing the application does`);
      if (!Array.isArray(o.elements)) err.push(`${at}: elements must be an array (empty array means residue)`);
      else {
        const bad = o.elements.filter(e => !E.has(e));
        if (bad.length) err.push(`${at}: not elements of the 58: ${bad.join(",")} - residue is an empty array, never an invented symbol`);
      }
      const ev = o.evidence ?? "";
      if (!URL_RE.test(ev)) err.push(`${at}: evidence must carry a URL`);
      else if (!DATE_RE.test(ev)) warn.push(`${at}: evidence has no access date`);
    }
    if (O.every(o => (o.elements ?? []).length === 0)) warn.push("every obligation is residue: check the lane did not give up");
    if (O.length < 5) warn.push(`only ${O.length} obligations: a top-five application should state more of what it does`);
  }
  if (!spec.source) warn.push("no source field pointing at the research record");
  return { file, app: spec.app, ok: err.length === 0, err, warn };
}

function main() {
  const dir = process.argv[2];
  if (!dir) { console.error("usage: node validate.mjs <dir-of-specs.json>"); process.exit(2); }
  let bad = 0, n = 0;
  for (const f of fs.readdirSync(dir).sort()) {
    if (!f.endsWith(".json")) continue;
    let d;
    try { d = JSON.parse(fs.readFileSync(`${dir}/${f}`, "utf8")); }
    catch (e) { console.log(`FAIL ${f}: not valid JSON - ${e.message}`); bad++; n++; continue; }
    for (const s of Array.isArray(d) ? d : [d]) {
      n++;
      const r = validate(s, f);
      if (!r.ok) { bad++; console.log(`FAIL ${f} [${r.app}]`); for (const e of r.err) console.log(`   ${e}`); }
      else console.log(`ok   ${f} [${r.app}] ${(s.functionalObligations ?? []).length} obligations, ${(s.functionalObligations ?? []).filter(o => !(o.elements ?? []).length).length} residue`);
      for (const w of r.warn) console.log(`   warn: ${w}`);
    }
  }
  // Zero specs examined is not zero specs rejected, and "0 specs, 0 rejected"
  // reads as a result, so it is not printed at all. Exit 3 = could not check.
  if (n === 0) {
    console.error(`BLOCKED - no specs found in ${dir}; nothing was validated`);
    process.exit(3);
  }
  console.log(`\n${n} specs, ${bad} rejected`);
  process.exit(bad ? 1 : 0);
}
if (import.meta.url === `file://${process.argv[1]}`) main();
