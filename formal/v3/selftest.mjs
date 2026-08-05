/* v3 self-test: the checker must reproduce the paper's published numbers on the
 * corpus before it is trusted on a construction that is not in the corpus. */
import { verify, loadCorpus, admissibility, asSet, ex, oplus, cn } from "./construct.mjs";

const corpus = loadCorpus();
let pass = 0, fail = 0;
const check = (name, got, want) => {
  const ok = JSON.stringify(got) === JSON.stringify(want);
  console.log(`${ok ? "ok  " : "FAIL"} ${name}: got ${JSON.stringify(got)}${ok ? "" : ` want ${JSON.stringify(want)}`}`);
  ok ? pass++ : fail++;
};

check("corpus size", corpus.length, 72);
const adm = corpus.filter(p => admissibility(asSet(p.syms)).admissible === true);
const reqwar = corpus.filter(p => {
  const a = admissibility(asSet(p.syms));
  return a.req.length === 0 && a.war.length === 0;
});
check("satisfy requirements and warrants", reqwar.length, 61);
check("compress under ex()", corpus.filter(p => ex(asSet(p.syms)).length < p.syms.length).length, 29);

/* pairwise composition over the 61, as pairs.mjs computes it */
let pairs = 0, fails = 0;
for (let i = 0; i < reqwar.length; i++) for (let j = i + 1; j < reqwar.length; j++) {
  pairs++;
  const U = new Set([...reqwar[i].syms, ...reqwar[j].syms]);
  const a = admissibility(U);
  if (!a.admissible) fails++;
}
check("pairs", pairs, 1830);
check("failing pairs", fails, 185);

/* the paper's worked example: Uniswap (+) Aave covers X2 */
const uni = corpus.find(p => p.name === "Uniswap"), aave = corpus.find(p => p.name === "Aave V3");
check("Uniswap (+) Aave arms X2", admissibility(oplus(asSet(uni.syms), asSet(aave.syms))).haz.includes("X2"), true);
check("Uniswap alone arms nothing", admissibility(asSet(uni.syms)).haz, []);
check("Aave alone arms nothing", admissibility(asSet(aave.syms)).haz, []);

/* the perps signature: six venues derive exactly {Ct,Ex,Li} */
const perps = ["Hyperliquid", "ApeX Protocol (ApeX Omni)", "Aster", "Lighter", "edgeX", "GMX V2 Perps"];
for (const n of perps) {
  const p = corpus.find(x => x.name === n);
  check(`${n} derives Ct,Ex,Li`, p.syms.filter(e => !ex(asSet(p.syms)).includes(e)), ["Ct", "Ex", "Li"]);
}
const jup = corpus.find(p => p.name === "Jupiter Perpetual Exchange");
check("Jupiter derives nothing", jup.syms.filter(e => !ex(asSet(jup.syms)).includes(e)), []);

/* the checker's own machinery, on a construction that is not in the corpus */
const spec = {
  app: "self-test: a minimal pooled lending market",
  category: "test",
  construction: ["Pl", "Sh", "Ct", "Ex", "Li", "Wq"],
  functionalObligations: [
    { id: "F1", text: "depositors hold a pro-rata claim on the pool", elements: ["Sh"] },
    { id: "F2", text: "borrowers post collateral tested against a threshold", elements: ["Ct"] },
    { id: "F3", text: "the threshold is evaluated against an external price", elements: ["Ex"] },
    { id: "F4", text: "third parties are paid to close unhealthy positions", elements: ["Li"] },
    { id: "F5", text: "lending is pooled rather than peer to peer", elements: ["Pl"] },
    { id: "F6", text: "withdrawal is queued when the pool is illiquid", elements: ["Wq"] },
    { id: "F7", text: "the borrow rate rises with utilisation", elements: [] },
  ],
};
const v = verify(spec, corpus);
check("test construction admissible", v.admissible, true);
check("test construction verdict", v.verdict, "PARTIAL");
check("test construction residue is the rate", v.obligationsUncovered.map(o => o.id), ["F7"]);
check("test construction derives Ct", v.derived, ["Ct"]);
check("no unjustified elements", v.unjustifiedElements, []);

/* an inadmissible construction must be caught */
const bad = verify({ app: "self-test: flash + amm + credit", category: "test",
  construction: ["Fl", "Cp", "Pl", "Sh", "Ct", "Ex", "Li"], functionalObligations: [] }, null);
check("X2 caught", bad.armedProhibitions, ["X2"]);
check("verdict inadmissible", bad.verdict, "INADMISSIBLE");

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
