/* Leak diagnostic.
 *
 * OP-ORD disclosed it: the brief mandates reading corpus50/lanes/*.json, and
 * the blind set's REAL cases are drawn from exactly those files. So a model can
 * recover the positive half of the key by set-matching, without any algebra.
 *
 * That strategy has a signature. A pure set-matcher answers ADMISSIBLE iff the
 * set appears verbatim in a lane file, which gives it 100% on REAL and 0% on
 * every synthetic family - including KNOCKOUT, because removing one symbol
 * makes the set fail to match. A perfect knockout score is therefore NOT
 * evidence of reading the laws. It is what the cheapest possible cheat scores.
 *
 * This computes each model's agreement with that oracle. High agreement is not
 * proof of cheating - a good algebra also accepts real protocols - but the two
 * are only separable on the families the oracle cannot reach: HYBRID, and any
 * REAL case a model rejects.
 */
import fs from "node:fs";
const A = "/root/DefiElements/algebra";

const key = JSON.parse(fs.readFileSync(`${A}/blind-test-KEY.json`, "utf8")).key;
const blind = JSON.parse(fs.readFileSync(`${A}/blind-test-set.json`, "utf8")).cases;
const byId = new Map(blind.map((c) => [c.id, [...c.elements].sort().join(",")]));

// every element set appearing verbatim in a lane file
const lane = new Set();
for (const f of fs.readdirSync(`${A}/../corpus50/lanes`)) {
  const d = JSON.parse(fs.readFileSync(`${A}/../corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    lane.add([...new Set(p.elements)].sort().join(","));
}

// the oracle a cheater would use
const oracle = new Map(key.map((k) => [k.id, lane.has(byId.get(k.id)) ? "A" : "I"]));
const oracleReal = key.filter((k) => k.label === "REAL" && oracle.get(k.id) === "A").length;

console.log(`lane sets: ${lane.size} | set-match oracle recovers ${oracleReal}/${key.filter(k=>k.label==="REAL").length} REAL cases`);
console.log("");
console.log("model      agree-w/-cheat  HYBRID-acc  REAL-rejected   read");
console.log("-".repeat(64));

for (const f of fs.readdirSync(`${A}/verdicts`).filter((f) => f.endsWith(".json")).sort()) {
  const id = f.replace(/\.json$/, "");
  const raw = JSON.parse(fs.readFileSync(`${A}/verdicts/${f}`, "utf8"));
  const list = Array.isArray(raw) ? raw : raw.verdicts ?? raw.cases ?? raw.results;
  const v = new Map(list.map((x) => [x.id ?? x.case, String(x.verdict ?? x.result ?? "").toUpperCase().startsWith("A") ? "A" : "I"]));

  let agree = 0, n = 0, hybN = 0, hybA = 0, realRej = 0;
  for (const k of key) {
    const mine = v.get(k.id); if (!mine) continue;
    n++; if (mine === oracle.get(k.id)) agree++;
    if (k.label === "HYBRID") { hybN++; if (mine === "A") hybA++; }
    if (k.label === "REAL" && mine === "I") realRej++;
  }
  const ag = agree / n;
  // a model is "reading" if it departs from the oracle in BOTH directions
  const read = (hybA > 0 || realRej > 0) ? (ag < 0.9 ? "yes" : "weak") : "NO - oracle-shaped";
  console.log(
    `${id.padEnd(10)} ${`${Math.round(ag * 100)}%`.padStart(13)} ${`${Math.round(100 * hybA / (hybN||1))}%`.padStart(11)} ${String(realRej).padStart(14)}   ${read}`
  );
}
console.log("-".repeat(64));
console.log("agree-w/-cheat = agreement with a pure set-matcher, which needs no algebra at all.");
console.log("A model at ~100% agreement has not demonstrated anything the lane files did not give it.");
