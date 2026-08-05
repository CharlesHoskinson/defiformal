/* Generate the application subsections from the checker's own output.
 *
 * Invariant 1 of the run is that no number enters the paper that was not
 * computed. The strongest form of that is not discipline but architecture: the
 * numbers in the subsections are emitted from verdicts.json, so a claim and its
 * computation cannot drift apart. Prose is authored; every figure is generated.
 *
 *   node emit-tex.mjs <specs-dir> <verdicts.json> > subsections.tex
 */
import fs from "node:fs";

const esc = s => String(s)
  .replace(/\\/g, "\\textbackslash{}")
  .replace(/([&%$#_{}])/g, "\\$1")
  .replace(/~/g, "\\textasciitilde{}")
  .replace(/\^/g, "\\textasciicircum{}");

const set = a => a.length ? `\\{${a.join(",")}\\}` : "\\emptyset";
const num = n => n.toLocaleString("en-US").replace(/,/g, "{,}");

function admissibilityClause(v) {
  if (v.admissible) return v.armedProhibitions.length
    ? `It is admissible.` : `It is admissible: no requirement term is open, every element is warranted, and it arms no prohibition.`;
  const bits = [];
  if (v.openRequirementTerms.length)
    bits.push(`it leaves ${v.openRequirementTerms.length === 1 ? "the requirement term" : "the requirement terms"} ${v.openRequirementTerms.map(t => { const [law, alts] = t.split(":"); return `$${esc(law)}\\!:\\!${(alts ?? "").split("|").map(esc).join("{\\mid}")}$`; }).join(", ")} open`);
  if (v.unwarrantedElements.length)
    bits.push(`${set(v.unwarrantedElements)} ${v.unwarrantedElements.length === 1 ? "has" : "have"} no consumer present`);
  if (v.armedProhibitions.length)
    bits.push(`it arms ${v.armedProhibitions.map(h => `$${esc(h)}$`).join(", ")}`);
  if (v.ungrounded) bits.push(`it is ungrounded`);
  return `It is not admissible: ${bits.join("; ")}.`;
}

function compositionClause(v) {
  const c = v.composition;
  if (!c) return "";
  if (c.exactFound) {
    const h = c.exact[0];
    return ` Over the corpus it is reached exactly by ${h.parts.map(p => esc(p)).join(" $\\oplus$ ")}${c.exactFound > 1 ? `, one of ${num(c.exactFound)} such decompositions at $k \\le 3$` : ""}.`;
  }
  return ` No composite of at most three corpus protocols equals it; ${c.containedCount === 0
    ? "no corpus protocol is contained in it"
    : `${num(c.containedCount)} corpus ${c.containedCount === 1 ? "protocol is" : "protocols are"} contained in it, and together they supply every element except ${set(c.notSuppliedByAnyContainedProtocol)}`}.`;
}

function subsection(spec, v) {
  const p = spec.paper ?? {};
  const label = p.label ?? `${spec.category}:${(spec.app || "").toLowerCase().replace(/[^a-z0-9]+/g, "")}`;
  const uncovered = v.obligationsUncovered;
  const L = [];
  L.push(`\\subsection{${esc(p.title ?? spec.app)}}\\label{sub:${label}}`);
  L.push("");
  if (p.blurb) { L.push(p.blurb.trim()); L.push(""); }
  L.push(`\\begin{measurement}[Construction]\\label{meas:${label}}`);
  L.push(`The construction $X = ${set(v.construction)}$ has canonical form`);
  L.push(`$\\mathrm{ex}(X) = ${set(v.canonicalForm)}$${v.derived.length ? `, deriving ${set(v.derived)} rather than choosing ${v.derived.length === 1 ? "it" : "them"}` : ", so every element is primitive in it"}.`);
  L.push(`${admissibilityClause(v)} It discharges ${num(v.obligationsCovered)} of the ${num(v.obligationsTotal)} recorded obligations; ${uncovered.length === 0 ? "none is residue" : `${num(uncovered.length)} ${uncovered.length === 1 ? "is" : "are"} residue`}.${compositionClause(v)}`);
  if (v.unjustifiedElements.length)
    L.push(`Elements carried that discharge no recorded obligation: ${set(v.unjustifiedElements)}.`);
  if (v.minimality.checked && !v.minimality.minimal)
    L.push(`It is not minimal: ${set(v.minimality.redundant)} can be removed with every obligation still covered and admissibility intact.`);
  L.push(`\\end{measurement}`);
  L.push("");
  if (uncovered.length) {
    L.push(`\\begin{remark}[What the construction cannot say]`);
    L.push(`${num(uncovered.length)} obligation${uncovered.length === 1 ? "" : "s"} of ${esc(spec.app)} ${uncovered.length === 1 ? "has" : "have"} no element:`);
    L.push(`\\begin{itemize}`);
    for (const o of uncovered) L.push(`  \\item ${esc(o.text)}`);
    L.push(`\\end{itemize}`);
    if (p.residueNote) L.push(p.residueNote.trim());
    L.push(`\\end{remark}`);
    L.push("");
  }
  if (p.witnessReason) {
    L.push(`\\begin{remark}[Why this witness]`);
    L.push(p.witnessReason.trim());
    L.push(`\\end{remark}`);
    L.push("");
  }
  return L.join("\n");
}

function main() {
  const [dir, verdictsPath] = process.argv.slice(2);
  if (!dir || !verdictsPath) { console.error("usage: node emit-tex.mjs <specs-dir> <verdicts.json>"); process.exit(2); }
  const verdicts = JSON.parse(fs.readFileSync(verdictsPath, "utf8"));
  const byApp = new Map(verdicts.map(v => [v.app, v]));
  const specs = [];
  for (const f of fs.readdirSync(dir).sort()) if (f.endsWith(".json") && !f.startsWith("verdicts")) {
    const d = JSON.parse(fs.readFileSync(`${dir}/${f}`, "utf8"));
    for (const s of Array.isArray(d) ? d : [d]) specs.push(s);
  }
  let missing = 0;
  for (const s of specs) {
    const v = byApp.get(s.app);
    if (!v) { console.error(`% NO VERDICT for ${s.app} - run construct.mjs first`); missing++; continue; }
    console.log(subsection(s, v));
  }
  if (missing) { console.error(`${missing} spec(s) had no verdict; the emitted file is incomplete`); process.exit(1); }
}
if (import.meta.url === `file://${process.argv[1]}`) main();
