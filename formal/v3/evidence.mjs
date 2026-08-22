/* Round 2, finding 10: the supplement makes highly specific claims and cites
 * nothing in the document. Emit the evidence beside each obligation.
 *
 * Every obligation already carries a source; the emitter simply never printed
 * it. This adds a per-application evidence list to the supplement, so the
 * claims are checkable from the publication rather than from a repository. */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const ROOT = `${REPO_ROOT}/expansion`;
const esc = s => String(s)
  .replace(/\\/g, "\\textbackslash{}")
  .replace(/([&%$#_{}])/g, "\\$1")
  .replace(/~/g, "\\textasciitilde{}")
  .replace(/\^/g, "\\textasciicircum{}");

const out = ["\\section{Evidence}\\label{sec:evidence}", "",
  "Each obligation recorded in this supplement carries a source. The sources are",
  "listed here by application, in the order the obligations appear, with the",
  "access date on which each was consulted. A source consulted for several",
  "obligations of one application is listed once.", ""];

let total = 0, uniq = new Set();
for (const slug of fs.readdirSync(ROOT).filter(d => /^\d\d-/.test(d)).sort()) {
  const sd = path.join(ROOT, slug, "specs");
  if (!fs.existsSync(sd)) continue;
  for (const f of fs.readdirSync(sd).filter(f => f.endsWith(".json")).sort()) {
    const spec = JSON.parse(fs.readFileSync(path.join(sd, f), "utf8"));
    const seen = new Set(), rows = [];
    for (const o of spec.functionalObligations || []) {
      for (const u of (o.evidence || "").match(/https?:\/\/[^\s)\]<>"']+/g) || []) {
        const url = u.replace(/[.,;]+$/, "");
        if (seen.has(url)) continue;
        seen.add(url); uniq.add(url);
        const d = (o.evidence.match(/\b20\d{2}-\d{2}-\d{2}\b/) || ["n.d."])[0];
        rows.push(`\\item \\texttt{${esc(url)}} (${d})`);
      }
    }
    if (!rows.length) continue;
    total += rows.length;
    out.push(`\\subsection*{${esc(spec.paper?.title ?? spec.app)}}`);
    out.push("\\begin{itemize}\\setlength{\\itemsep}{0pt}\\small");
    out.push(...rows);
    out.push("\\end{itemize}", "");
  }
}
fs.writeFileSync(`${REPO_ROOT}/formal/v3/evidence.tex`, out.join("\n"));
console.error(`evidence section: ${total} references, ${uniq.size} distinct sources`);
