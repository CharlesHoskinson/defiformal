// Round five, blocker 6: the instantiated mathematical object is absent from the
// submitted documents. The notation caption says element symbols "are listed in
// full in the supplement"; neither document contains a single element name, so
// no witness mentioning L1, X2, Ct or Fl can be checked by a reader.
//
// Generate the appendix from the tables the scripts read, so the publication
// carries the object its proofs are about.
import { writeFileSync } from "node:fs";
import * as T from "/root/DefiElements/formal/v2/tables.mjs";

const esc = s => String(s)
  .replace(/\\/g, "\\textbackslash{}")
  .replace(/([&%$#_{}])/g, "\\$1")
  .replace(/\^/g, "\\textasciicircum{}")
  .replace(/~/g, "\\textasciitilde{}");

const L = [];
L.push("\\section{The instantiated vocabulary and constraints}\\label{sec:formaldata}");
L.push("");
L.push("Every witness in the article names elements and clause identifiers from the");
L.push("tables below. They are reproduced here in full so that a reader can check a");
L.push("witness without the repository. These are the tables the checking scripts");
L.push("read; nothing is restated by hand.");
L.push("");

// --- elements -----------------------------------------------------------------
const els = T.MECH.map(m => T.ELEMS[m]).filter(Boolean);
L.push(`\\subsection{Elements (${els.length})}`);
L.push("");
L.push("\\begin{longtable}{llll}");
L.push("\\toprule");
L.push("symbol & name & group & stratum\\\\");
L.push("\\midrule\\endhead");
for (const e of els)
  L.push(`$${esc(e.sym)}$ & ${esc(e.name)} & ${esc(e.group ?? "")} & ${esc(e.stratum ?? "")}\\\\`);
L.push("\\bottomrule");
L.push("\\end{longtable}");
L.push("");

// --- requirements -------------------------------------------------------------
L.push(`\\subsection{Requirements: the recorded rows (${T.PARSED_NEW.length})}`);
L.push("");
L.push("Each row reads: if any subject is present, then every term must be satisfied,");
L.push("a term being satisfied when one of its alternatives is present.");
L.push("");
L.push("\\begin{longtable}{lll}");
L.push("\\toprule");
L.push("id & subjects & terms\\\\");
L.push("\\midrule\\endhead");
for (const l of T.PARSED_NEW) {
  const terms = l.terms
    .map(t => (t.external ? "[ext] " : "") + "(" + t.alts.join("$\\mid$") + ")")
    .join(" ");
  L.push(`$${esc(l.id)}$ & ${esc(l.subjects.join(", "))} & ${terms}\\\\`);
}
L.push("\\bottomrule");
L.push("\\end{longtable}");
L.push("");

// --- warrants -----------------------------------------------------------------
const cons = Object.entries(T.CONSUME);
L.push(`\\subsection{Warrants: the consumer relation (${cons.length} elements)}`);
L.push("");
L.push("An element present with no consumer among the listed elements is unwarranted.");
L.push("");
L.push("\\begin{longtable}{ll}");
L.push("\\toprule");
L.push("element & consumers\\\\");
L.push("\\midrule\\endhead");
for (const [e, cs] of cons.sort())
  L.push(`$${esc(e)}$ & ${esc((cs ?? []).join(", "))}\\\\`);
L.push("\\bottomrule");
L.push("\\end{longtable}");
L.push("");

// --- prohibitions -------------------------------------------------------------
const haz = T.HAZ ?? [];
L.push(`\\subsection{Prohibitions: the listed rows (${haz.length})}`);
L.push("");
L.push("\\begin{longtable}{lll}");
L.push("\\toprule");
L.push("id & class & forbidden configuration\\\\");
L.push("\\midrule\\endhead");
for (const h of haz)
  L.push(`$${esc(h.id)}$ & ${esc(h.cls ?? "")} & ${esc(h.combo ?? "")}\\\\`);
L.push("\\bottomrule");
L.push("\\end{longtable}");
L.push("");
L.push("The conditional rows evaluated by the operational predicate are $X2$, $X18$,");
L.push("$X19^{*}$, $X21$ and $X11a^{*}$; their polarities are classified in");
L.push("the article, in the proposition on the third clause class.");
L.push("");

const out = L.join("\n") + "\n";
writeFileSync("/root/defiformal/paper/formal-data.tex", out);
console.log(`wrote paper/formal-data.tex: ${els.length} elements, ` +
            `${T.PARSED_NEW.length} requirement rows, ${cons.length} warrant entries, ` +
            `${haz.length} prohibition rows, ${out.length} bytes`);
