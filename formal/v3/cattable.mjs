/* The category-level table the article keeps in place of sixty profiles.
 * Every column is computed from the verdicts. */
import fs from "node:fs";
import path from "node:path";

const root = "/root/defiformal/expansion";
const NAME = {
  "01-spot-exchange": "Spot exchange", "02-lending": "Lending",
  "03-cdp-stablecoins": "Collateralised-debt stablecoins",
  "04-liquid-staking": "Liquid staking", "05-perpetuals": "Perpetual futures",
  "06-yield-vaults": "Yield vaults", "07-bridges": "Bridges",
  "08-intents": "Intents and aggregation", "09-rwa": "Tokenised real-world assets",
  "10-options": "Options", "11-fiat-stablecoins": "Reserve-backed stablecoins",
  "12-prediction": "Prediction markets",
};

const rows = [];
let T = 0, C = 0, P = 0, I = 0;
for (const slug of Object.keys(NAME)) {
  const V = JSON.parse(fs.readFileSync(path.join(root, slug, "verdicts.json"), "utf8"));
  const tot = V.reduce((a, v) => a + v.obligationsTotal, 0);
  const cov = V.reduce((a, v) => a + v.obligationsCovered, 0);
  const els = new Set(V.flatMap(v => v.construction));
  const part = V.filter(v => v.verdict === "PARTIAL").length;
  const inad = V.filter(v => v.verdict === "INADMISSIBLE").length;
  T += tot; C += cov; P += part; I += inad;
  rows.push({ name: NAME[slug], els: els.size, tot, cov, res: tot - cov,
              pct: (100 * cov / tot).toFixed(1), part, inad });
}

const L = [];
L.push("\\begin{table}[t]");
L.push("\\centering\\small");
L.push("\\begin{tabular}{lrrrrr}");
L.push("\\toprule");
L.push("category & elements & obligations & discharged & residue & inadmissible \\\\");
L.push("\\midrule");
for (const r of rows)
  L.push(`${r.name} & ${r.els} & ${r.tot} & ${r.cov} & ${r.res} & ${r.inad} \\\\`);
L.push("\\midrule");
L.push(`total & --- & ${T} & ${C} & ${T - C} & ${I} \\\\`);
L.push("\\bottomrule");
L.push("\\end{tabular}");
L.push("\\caption{The twelve categories. \\emph{Elements} counts the distinct");
L.push("elements the five constructions of the category use; \\emph{obligations}");
L.push("counts the recorded obligations of its five applications;");
L.push("\\emph{inadmissible} counts constructions that leave a requirement term");
L.push("open or arm a prohibition. Coverage in the sense of");
L.push("Remark~\\ref{rem:coverage} runs from " +
       Math.min(...rows.map(r => +r.pct)).toFixed(1) + "\\% to " +
       Math.max(...rows.map(r => +r.pct)).toFixed(1) + "\\%.}");
L.push("\\label{tab:categories}");
L.push("\\end{table}");
console.log(L.join("\n"));
console.error(`totals: ${T} obligations, ${C} discharged, ${T-C} residue, ${P} partial, ${I} inadmissible`);
