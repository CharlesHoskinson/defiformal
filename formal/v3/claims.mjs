/* Every assertion the category sections make, restated as a computation.
 *
 * Invariant 1 of the run is that no number enters the paper that was not
 * computed. This is the enforcement: each claim below names the section it
 * comes from and recomputes it from corpus50/lanes through the v2 tables. If a
 * table changes, the claim fails here before a reader finds it.
 *
 *   node claims.mjs            # PASS/FAIL per claim
 *   node claims.mjs -v         # also print what each computed
 */
import { PARSED_NEW, MECH, CONSUME, ELEMS, bansCond, ungrounded } from "../v2/tables.mjs";
import { asSet, ex, admissibility, loadCorpus } from "./construct.mjs";

const V = process.argv.includes("-v");
const P = loadCorpus();
const sat = X => admissibility(X).req.length === 0;
const warr = X => admissibility(X).war.length === 0;
const ok = P.filter(p => { const S = asSet(p.syms); return sat(S) && warr(S); });
const byName = new Map(P.map(p => [p.name, p]));
const cat = c => P.filter(p => p.cat === c);
const foot = c => [...new Set(cat(c).flatMap(p => p.syms))].sort();
const core = c => foot(c).filter(e => cat(c).every(p => p.syms.includes(e)));
const exclusive = c => foot(c).filter(e => !P.some(p => p.cat !== c && p.syms.includes(e)));
const sizes = c => cat(c).map(p => p.syms.length).sort((a, b) => a - b);

/* pairwise composition over the 61 */
const failsWith = new Map(ok.map(p => [p.name, []]));
const failPairs = [];
for (let i = 0; i < ok.length; i++) for (let j = i + 1; j < ok.length; j++) {
  const U = new Set([...asSet(ok[i].syms), ...asSet(ok[j].syms)]);
  const a = admissibility(U);
  if (!a.admissible) {
    failPairs.push({ a: ok[i], b: ok[j], why: [...new Set([...(a.req.length ? ["req"] : []), ...(a.war.length ? ["warrant"] : []), ...a.haz])] });
    failsWith.get(ok[i].name).push(ok[j]); failsWith.get(ok[j].name).push(ok[i]);
  }
}
const nfail = n => (failsWith.get(n) ?? []).length;
const partners = n => (failsWith.get(n) ?? []).map(p => p.name).sort();

const C = {
  dex: "Spot DEX / AMM", lend: "Lending", cdp: "CDP / collateral-backed stablecoins",
  lsd: "Liquid staking & restaking", perp: "Perpetuals / derivatives",
  yield: "Yield / vaults / aggregators", bridge: "Bridges / cross-domain",
  intent: "Intents / aggregation / order flow", rwa: "RWA / tokenised treasuries & private credit",
  opt: "Options / structured products", fiat: "Reserve-backed / fiat stablecoin issuers",
  pred: "Prediction markets & other (uncategorized large protocols)",
};

let pass = 0, fail = 0;
const eq = (where, claim, got, want) => {
  const good = JSON.stringify(got) === JSON.stringify(want);
  good ? pass++ : fail++;
  if (!good) console.log(`FAIL [${where}] ${claim}\n       got  ${JSON.stringify(got)}\n       want ${JSON.stringify(want)}`);
  else if (V) console.log(`ok   [${where}] ${claim} = ${JSON.stringify(got)}`);
  else pass === pass && process.stdout.write("");
};

/* ---- lead-in */
eq("atlas", "elements used by the corpus", new Set(P.flatMap(p => p.syms)).size, 54);
eq("atlas", "elements unused", MECH.filter(e => !P.some(p => p.syms.includes(e))), ["Wg", "Cv", "Sb", "Sd"]);
eq("atlas", "Up carried by", P.filter(p => p.syms.includes("Up")).length, 49);
eq("atlas", "Gp carried by", P.filter(p => p.syms.includes("Gp")).length, 48);
eq("atlas", "Up spans categories", new Set(P.filter(p => p.syms.includes("Up")).map(p => p.cat)).size, 11);
eq("atlas", "Gp spans categories", new Set(P.filter(p => p.syms.includes("Gp")).map(p => p.cat)).size, 11);
eq("atlas", "Fl carriers among the 61", ok.filter(p => p.syms.includes("Fl")).map(p => p.name).sort(),
  ["Aave V3", "CIAN Yield Layer", "CoW Swap", "Morpho", "PancakeSwap", "SparkLend", "Uniswap"]);
eq("atlas", "failing pairs", failPairs.length, 185);
eq("atlas", "failing pairs with an Fl endpoint",
  failPairs.filter(f => f.a.syms.includes("Fl") || f.b.syms.includes("Fl")).length, 180);
eq("atlas", "the 5 remaining all have Spark Savings as an endpoint",
  failPairs.filter(f => !(f.a.syms.includes("Fl") || f.b.syms.includes("Fl")))
    .every(f => f.a.name.startsWith("Spark Savings") || f.b.name.startsWith("Spark Savings")), true);
eq("atlas", "X21 incidences", failPairs.filter(f => f.why.includes("X21")).length, 147);
eq("atlas", "X2 incidences", failPairs.filter(f => f.why.includes("X2")).length, 37);
eq("atlas", "X19* incidences", failPairs.filter(f => f.why.includes("X19*")).length, 6);
{ const a = byName.get("Maple"), b = byName.get("Maple Finance (syrupUSDC / syrupUSDT + institutional pools)");
  const inter = a.syms.filter(s => b.syms.includes(s)), uni = new Set([...a.syms, ...b.syms]);
  eq("atlas", "Maple decompositions agree on n of m", [inter.length, uni.size], [11, 18]); }
{ const a = byName.get("Steakhouse Financial"), b = byName.get("Steakhouse Financial (Risk Curators)");
  const inter = a.syms.filter(s => b.syms.includes(s)), uni = new Set([...a.syms, ...b.syms]);
  eq("atlas", "Steakhouse decompositions agree on n of m", [inter.length, uni.size], [5, 10]); }

/* ---- spot exchange */
eq("dex", "footprint", foot(C.dex).length, 16);
eq("dex", "exclusive", exclusive(C.dex), ["Cp", "St"]);
eq("dex", "core", core(C.dex), ["Sh"]);
eq("dex", "sizes", sizes(C.dex), [6, 7, 7, 8, 9]);
eq("dex", "compressing members", cat(C.dex).filter(p => ex(asSet(p.syms)).length < p.syms.length).map(p => p.name), ["Fluid"]);
eq("dex", "Uniswap incompatible partners", nfail("Uniswap"), 31);
eq("dex", "PancakeSwap incompatible partners", nfail("PancakeSwap"), 31);
eq("dex", "Fluid incompatible partners", nfail("Fluid"), 7);
eq("dex", "Curve composes with everything", nfail("Curve"), 0);
eq("dex", "Raydium fails only against the three Fl-carrying lending markets",
  partners("Raydium"), ["Aave V3", "Morpho", "SparkLend"]);
eq("dex", "Curve carries none of Fl, Cp, Cl",
  ["Fl", "Cp", "Cl"].filter(e => byName.get("Curve").syms.includes(e)), []);

/* ---- lending */
eq("lend", "footprint", foot(C.lend).length, 24);
eq("lend", "no exclusive element", exclusive(C.lend), []);
eq("lend", "core", core(C.lend), ["Ct", "Em", "Ex", "Gp", "Ix", "Li", "Pl"]);
eq("lend", "every member compresses", cat(C.lend).every(p => ex(asSet(p.syms)).length < p.syms.length), true);
eq("lend", "every member drops Ct", cat(C.lend).every(p => !ex(asSet(p.syms)).includes("Ct")), true);
eq("lend", "SparkLend is a proper subset of Aave, smaller by 5",
  byName.get("Aave V3").syms.length - byName.get("SparkLend").syms.length, 5);
eq("lend", "Compound v3 is a proper subset of Aave",
  byName.get("Compound V3").syms.every(s => byName.get("Aave V3").syms.includes(s)), true);
eq("lend", "JustLend is a proper subset of Maple, smaller by 7",
  byName.get("Maple").syms.length - byName.get("JustLend V1").syms.length, 7);
eq("lend", "Maple leaves the Bs|Tr term open",
  admissibility(asSet(byName.get("Maple").syms)).req.map(r => `${r.law}:${r.term.join("|")}`), ["L3:Bs|Tr"]);
eq("lend", "Aave, Morpho, SparkLend have 26 each",
  ["Aave V3", "Morpho", "SparkLend"].map(nfail), [26, 26, 26]);
eq("lend", "JustLend and Compound have 2 each", ["JustLend V1", "Compound V3"].map(nfail), [2, 2]);

/* ---- cdp */
eq("cdp", "footprint", foot(C.cdp).length, 25);
eq("cdp", "exclusive", exclusive(C.cdp), ["As"]);
eq("cdp", "no common core", core(C.cdp), []);
eq("cdp", "five of six drop exactly Ct",
  cat(C.cdp).filter(p => p.syms.filter(e => !ex(asSet(p.syms)).includes(e)).join() === "Ct").length, 5);
eq("cdp", "Ethena is the exception and carries no Cd",
  [ex(asSet(byName.get("Ethena (USDe / sUSDe)").syms)).length, byName.get("Ethena (USDe / sUSDe)").syms.includes("Cd")], [16, false]);
eq("cdp", "Sky, Ethena, USDD, crvUSD have 7 each",
  ["Sky (Sky Lending, ex-MakerDAO)", "Ethena (USDe / sUSDe)", "USDD", "crvUSD"].map(nfail), [7, 7, 7, 7]);

/* ---- liquid staking */
eq("lsd", "footprint", foot(C.lsd).length, 19);
eq("lsd", "exclusive", exclusive(C.lsd), ["Rs"]);
eq("lsd", "no common core", core(C.lsd), []);
eq("lsd", "nothing compresses", cat(C.lsd).filter(p => ex(asSet(p.syms)).length < p.syms.length).length, 0);
eq("lsd", "two failing pairs, both X19* against Spark Savings",
  failPairs.filter(f => f.a.cat === C.lsd || f.b.cat === C.lsd).map(f => f.why.join("+")), ["X19*", "X19*"]);
eq("lsd", "three universally composable",
  cat(C.lsd).filter(p => failsWith.has(p.name) && nfail(p.name) === 0).length, 3);

/* ---- perpetuals */
eq("perp", "footprint", foot(C.perp).length, 20);
eq("perp", "exclusive", exclusive(C.perp), ["Ad", "Pm"]);
eq("perp", "core", core(C.perp), ["Ct", "Ex", "Li", "Sh"]);
eq("perp", "Aster leaves the Ad|Sl|Bs term open",
  admissibility(asSet(byName.get("Aster").syms)).req.map(r => `${r.law}:${r.term.join("|")}`), ["L4:Ad|Sl|Bs"]);
eq("perp", "the four with 7 are exactly those carrying Xf",
  cat(C.perp).filter(p => failsWith.has(p.name) && nfail(p.name) === 7).map(p => p.syms.includes("Xf")), [true, true, true, true]);
eq("perp", "GMX has 2, Jupiter 0", [nfail("GMX V2 Perps"), nfail("Jupiter Perpetual Exchange")], [2, 0]);
eq("perp", "no perpetual-machinery element appears in any failure of this category",
  failPairs.filter(f => f.a.cat === C.perp || f.b.cat === C.perp).every(f => f.why.every(w => ["X2", "X21", "X19*"].includes(w))), true);

/* ---- yield */
eq("yield", "footprint", foot(C.yield).length, 23);
eq("yield", "exclusive", exclusive(C.yield), ["Py"]);
eq("yield", "core", core(C.yield), ["Ix"]);
eq("yield", "mean size 8.0", +(sizes(C.yield).reduce((a, b) => a + b, 0) / 8).toFixed(1), 8);
eq("yield", "Steakhouse leaves the loss term open",
  admissibility(asSet(byName.get("Steakhouse Financial").syms)).req.map(r => `${r.law}:${r.term.join("|")}`), ["L1:Li|Ad|Sl|Bs"]);
eq("yield", "CIAN 23, Spark Savings 12", [nfail("CIAN Yield Layer"), nfail("Spark Savings (sUSDS / Sky Savings Rate)")], [23, 12]);
eq("yield", "CIAN is the only member carrying Fl", cat(C.yield).filter(p => p.syms.includes("Fl")).map(p => p.name), ["CIAN Yield Layer"]);

/* ---- bridges */
eq("bridge", "footprint", foot(C.bridge).length, 17);
eq("bridge", "exclusive", exclusive(C.bridge), ["Of"]);
eq("bridge", "core", core(C.bridge), ["Xf"]);
eq("bridge", "mean size 5.6", +(sizes(C.bridge).reduce((a, b) => a + b, 0) / 7).toFixed(1), 5.6);
eq("bridge", "WBTC set", byName.get("WBTC").syms, ["At", "Aw", "Gp", "Rd", "Tg", "Xf"]);
eq("bridge", "Coinbase set", byName.get("Coinbase Bridge (cbBTC and other wrapped assets)").syms, ["At", "Aw", "Gp", "Rd", "Up", "Xf"]);
eq("bridge", "BTCB set", byName.get("Binance Bitcoin (BTCB)").syms, ["At", "Aw", "Gp", "Rd", "Xf"]);
eq("bridge", "none of the three carries Xm",
  ["WBTC", "Coinbase Bridge (cbBTC and other wrapped assets)", "Binance Bitcoin (BTCB)"].some(n => byName.get(n).syms.includes("Xm")), false);
eq("bridge", "Across has four open requirement terms",
  admissibility(asSet(byName.get("Across").syms)).req.length, 4);
eq("bridge", "each of the six admissible bridges has exactly 7",
  cat(C.bridge).filter(p => failsWith.has(p.name)).map(p => nfail(p.name)), [7, 7, 7, 7, 7, 7]);

/* ---- intents */
eq("intent", "footprint is the smallest of the twelve",
  Math.min(...Object.values(C).map(c => foot(c).length)), foot(C.intent).length);
eq("intent", "footprint", foot(C.intent).length, 8);
eq("intent", "exclusive", exclusive(C.intent), ["Ba"]);
eq("intent", "core", core(C.intent), ["Ag"]);
eq("intent", "sizes", sizes(C.intent), [1, 1, 2, 2, 3, 3, 3, 7]);
eq("intent", "two members reduce to {Ag}", cat(C.intent).filter(p => p.syms.join() === "Ag").length, 2);
eq("intent", "all eight admissible", cat(C.intent).filter(p => failsWith.has(p.name)).length, 8);
eq("intent", "CoW 23, DFlow 1, rest 0",
  [nfail("CoW Swap"), nfail("DFlow"), cat(C.intent).filter(p => nfail(p.name) === 0).length], [23, 1, 6]);
{ let n = 0; const m = cat(C.intent);
  for (const a of m) for (const b of m) if (a !== b && a.syms.length < b.syms.length && a.syms.every(s => b.syms.includes(s))) n++;
  eq("intent", "ordered containment pairs", n, 22); }

/* ---- rwa */
eq("rwa", "footprint", foot(C.rwa).length, 24);
eq("rwa", "no exclusive element", exclusive(C.rwa), []);
eq("rwa", "core", core(C.rwa), ["Aw", "Gp", "Sh", "Up"]);
eq("rwa", "Maple Finance leaves the price term open",
  admissibility(asSet(byName.get("Maple Finance (syrupUSDC / syrupUSDT + institutional pools)").syms)).req.map(r => `${r.law}:${r.term.join("|")}`), ["L1:Ex|Tp|At"]);
eq("rwa", "USYC composes with everything and carries no Xf",
  [nfail("Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)"),
   byName.get("Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)").syms.includes("Xf")], [0, false]);

/* ---- options */
eq("opt", "footprint", foot(C.opt).length, 20);
eq("opt", "exclusive", exclusive(C.opt), ["Op"]);
eq("opt", "core", core(C.opt), ["Gp", "Op", "Sh", "Up"]);
eq("opt", "only Derive is admissible", cat(C.opt).filter(p => failsWith.has(p.name)).map(p => p.name), ["Derive (formerly Lyra V2)"]);
eq("opt", "Derive has 7 incompatible partners", nfail("Derive (formerly Lyra V2)"), 7);
eq("opt", "the four rejections and their open terms",
  ["Rysk V12", "Hegic", "Aevo (Ribbon Finance lineage)", "Panoptic V2"]
    .map(n => admissibility(asSet(byName.get(n).syms)).req.map(r => `${r.law}:${r.term.join("|")}`).join(" ")),
  ["L1:Li|Ad|Sl|Bs", "L1:Ct L1:Li|Ad|Sl|Bs", "L4:Ad|Sl|Bs", "L1:Ex|Tp|At"]);

/* ---- fiat stablecoins */
eq("fiat", "footprint", foot(C.fiat).length, 10);
eq("fiat", "no exclusive element", exclusive(C.fiat), []);
eq("fiat", "core", core(C.fiat), ["At", "Fz", "Ps", "Rd", "Up"]);
eq("fiat", "footprint groups", [...new Set(foot(C.fiat).map(e => ELEMS[e].group))].sort(),
  ["G08", "G10", "G11", "G12", "G13", "G14"]);
eq("fiat", "no element from accounting through risk transfer",
  foot(C.fiat).filter(e => ["G01", "G02", "G03", "G04", "G05", "G06", "G07"].includes(ELEMS[e].group)), []);
eq("fiat", "USDT and USD1 are identical",
  byName.get("Tether USDT").syms.join() === byName.get("World Liberty Financial USD1").syms.join(), true);
eq("fiat", "PYUSD is a proper subset of USDC",
  byName.get("PayPal USD (PYUSD)").syms.every(s => byName.get("Circle USDC").syms.includes(s)), true);
eq("fiat", "USDC and PYUSD have 7 each, the other three 0",
  [nfail("Circle USDC"), nfail("PayPal USD (PYUSD)"), cat(C.fiat).filter(p => nfail(p.name) === 0).length], [7, 7, 3]);

/* ---- prediction */
eq("pred", "footprint", foot(C.pred).length, 20);
eq("pred", "exclusive", exclusive(C.pred), ["Au", "Gs", "Rl"]);
eq("pred", "no common core", core(C.pred), []);
eq("pred", "Kalshi decomposes to three symbols", byName.get("Kalshi").syms, ["Aw", "Ct", "Rd"]);
eq("pred", "Azuro is the only rejected protocol carrying an unwarranted element",
  P.filter(p => admissibility(asSet(p.syms)).war.length).map(p => p.name), ["Azuro"]);
eq("pred", "Azuro's unwarranted element", admissibility(asSet(byName.get("Azuro").syms)).war, ["Rl"]);
eq("pred", "Grove 7, Kalshi 1, Polymarket 1",
  [nfail("Grove Finance (Onchain Capital Allocator)"), nfail("Kalshi"), nfail("Polymarket")], [7, 1, 1]);
eq("pred", "Kalshi and Polymarket fail only against Spark Savings by X19*",
  [...partners("Kalshi"), ...partners("Polymarket")].map(n => n.startsWith("Spark Savings")), [true, true]);

console.log(`\n${pass} claims verified, ${fail} failed`);
process.exit(fail ? 1 : 0);
