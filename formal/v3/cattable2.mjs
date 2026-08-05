/* Two tables replacing the twenty-four repeated per-category measurements:
 * one for the footprint, one for composition. Every column computed. */
import fs from "node:fs";
import path from "node:path";
import { asSet, admissibility, loadCorpus } from "/root/defiformal/formal/v3/construct.mjs";

const NAME = {
  "01-spot-exchange": ["Spot exchange", "Spot DEX / AMM"],
  "02-lending": ["Lending", "Lending"],
  "03-cdp-stablecoins": ["CDP stablecoins", "CDP / collateral-backed stablecoins"],
  "04-liquid-staking": ["Liquid staking", "Liquid staking & restaking"],
  "05-perpetuals": ["Perpetual futures", "Perpetuals / derivatives"],
  "06-yield-vaults": ["Yield vaults", "Yield / vaults / aggregators"],
  "07-bridges": ["Bridges", "Bridges / cross-domain"],
  "08-intents": ["Intents", "Intents / aggregation / order flow"],
  "09-rwa": ["Real-world assets", "RWA / tokenised treasuries & private credit"],
  "10-options": ["Options", "Options / structured products"],
  "11-fiat-stablecoins": ["Reserve-backed stablecoins", "Reserve-backed / fiat stablecoin issuers"],
  "12-prediction": ["Prediction markets", "Prediction markets & other (uncategorized large protocols)"],
};

const P = loadCorpus();
const ok = P.filter(p => { const a = admissibility(asSet(p.syms)); return !a.req.length && !a.war.length; });
const fails = new Map(ok.map(p => [p.name, 0]));
let within = {};
for (let i = 0; i < ok.length; i++) for (let j = i + 1; j < ok.length; j++) {
  const U = new Set([...asSet(ok[i].syms), ...asSet(ok[j].syms)]);
  if (admissibility(U).admissible) continue;
  fails.set(ok[i].name, fails.get(ok[i].name) + 1);
  fails.set(ok[j].name, fails.get(ok[j].name) + 1);
  if (ok[i].cat === ok[j].cat) within[ok[i].cat] = (within[ok[i].cat] ?? 0) + 1;
}

const esc = s => s.replace(/&/g, "\\&");
const A = [], B = [];
for (const [slug, [short, cat]] of Object.entries(NAME)) {
  const mem = P.filter(p => p.cat === cat);
  const foot = [...new Set(mem.flatMap(p => p.syms))].sort();
  const elsewhere = new Set(P.filter(p => p.cat !== cat).flatMap(p => p.syms));
  const excl = foot.filter(e => !elsewhere.has(e));
  const core = foot.filter(e => mem.every(p => p.syms.includes(e)));
  const memOk = mem.filter(p => fails.has(p.name));
  const uni = memOk.filter(p => fails.get(p.name) === 0).length;
  const range = memOk.length
    ? `${Math.min(...memOk.map(p => fails.get(p.name)))}--${Math.max(...memOk.map(p => fails.get(p.name)))}`
    : "---";
  A.push(`${esc(short)} & ${foot.length} & ${excl.length ? "$" + excl.join(",") + "$" : "---"} & ${core.length ? "$" + core.join(",") + "$" : "---"} \\\\`);
  B.push(`${esc(short)} & ${memOk.length}/${mem.length} & ${range} & ${uni} & ${within[cat] ?? 0} \\\\`);
}

console.log(`\\begin{table}[t]\\centering\\small
\\begin{tabular}{lrll}
\\toprule
category & footprint & exclusive to it & in every member \\\\
\\midrule
${A.join("\n")}
\\bottomrule
\\end{tabular}
\\caption{Footprints. \\emph{Footprint} is the number of distinct elements the
category's members use; \\emph{exclusive} are those used by no member of any
other category; \\emph{in every member} are those every member carries.}
\\label{tab:footprints}
\\end{table}

\\begin{table}[t]\\centering\\small
\\begin{tabular}{lrrrr}
\\toprule
category & satisfying & incompatible partners & universal & within-category \\\\
\\midrule
${B.join("\n")}
\\bottomrule
\\end{tabular}
\\caption{Composition. \\emph{Satisfying} counts members meeting the requirements
and warrants, the others being excluded from the pairwise test;
\\emph{incompatible partners} is the range over those members, out of the $60$
others; \\emph{universal} counts members compatible with every other protocol;
\\emph{within-category} counts failing pairs drawn from the category itself.}
\\label{tab:composition}
\\end{table}`);
