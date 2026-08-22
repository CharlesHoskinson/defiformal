/* Merge an authored paper.json into a category's obligation specs.
 *
 *   node merge-paper.mjs <slug>
 *
 * The lane writes C:\defiformal-work\<slug>\paper.json, a map from the exact
 * `app` string to {title,label,blurb,witnessReason,residueNote}. This copies it
 * onto the specs, refusing any app it cannot match, so a name typo fails loudly
 * instead of emitting a subsection with no prose.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const slug = process.argv[2];
if (!slug) { console.error("usage: node merge-paper.mjs <slug>"); process.exit(2); }

const src = `/mnt/c/defiformal-work/${slug}/paper.json`;
const dir = `${REPO_ROOT}/expansion/${slug}/specs`;
if (!fs.existsSync(src)) { console.error(`no paper.json for ${slug}`); process.exit(2); }
if (!fs.existsSync(dir)) { console.error(`no specs dir for ${slug}`); process.exit(2); }

const P = JSON.parse(fs.readFileSync(src, "utf8"));
const files = fs.readdirSync(dir).filter(f => f.endsWith(".json"));
const apps = new Set();
let n = 0, bad = 0;

for (const f of files) {
  const p = path.join(dir, f);
  const spec = JSON.parse(fs.readFileSync(p, "utf8"));
  apps.add(spec.app);
  const a = P[spec.app];
  if (!a) { console.error(`  NO PROSE for ${JSON.stringify(spec.app)}`); bad++; continue; }
  for (const k of ["title", "label", "blurb", "witnessReason", "residueNote"])
    if (!a[k] || !String(a[k]).trim()) { console.error(`  ${spec.app}: missing ${k}`); bad++; }
  const norm = s => String(s).replace(/\s+/g, " ").trim();
  spec.paper = { title: norm(a.title), label: norm(a.label),
    blurb: norm(a.blurb), witnessReason: norm(a.witnessReason), residueNote: norm(a.residueNote) };
  /* a number in the prose is a defect: the emitter supplies every figure */
  for (const k of ["blurb", "witnessReason", "residueNote"]) {
    /* standards and version names carry digits and are not figures */
    const stripped = spec.paper[k]
      .replace(/\b(ERC|EIP|BIP|SLIP|CIP|RFC|ISAE|UCC|SEC|CEA)[- ]?\d+[A-Za-z-]*/gi, "")
      .replace(/\bv\d+(\.\d+)*\b/gi, "")
      .replace(/\b(secp|sha|keccak|blake)\d+\b/gi, "");
    const m = stripped.match(/\b\d[\d,.]*\b/g);
    if (m) console.error(`  warn ${spec.app}.${k}: contains ${m.join(", ")} - the emitter supplies figures`);
  }
  fs.writeFileSync(p, JSON.stringify(spec, null, 2));
  n++;
  console.log(`  ${f} <- ${spec.app}`);
}

for (const k of Object.keys(P)) if (!apps.has(k))
  { console.error(`  paper.json has an app no spec uses: ${JSON.stringify(k)}`); bad++; }

console.log(`${n} specs updated, ${bad} problem(s)`);
process.exit(bad ? 1 : 0);
