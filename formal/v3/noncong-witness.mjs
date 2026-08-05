// The witness for thm:noncong, from the corpus lanes where the named
// decompositions actually live.
import fs from "node:fs";
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
import { adm, inR, inW, inH, grounded } from "/root/defiformal/formal/v3/lib.mjs";

const CORPUS = [];
for (const f of fs.readdirSync("/root/DefiElements/corpus50/lanes")) {
  const d = JSON.parse(fs.readFileSync(`/root/DefiElements/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    CORPUS.push({ name: p.name, els: p.elements ?? p.mechanisms ?? [] });
}
console.log("corpus protocols:", CORPUS.length);

const pick = n => CORPUS.find(r => r.name.toLowerCase().startsWith(n.toLowerCase()));
const U = pick("Uniswap"), A = pick("Aave");
if (!U || !A) {
  console.log("names sample:", CORPUS.slice(0, 12).map(r => r.name).join(" | "));
  process.exit(2);
}

const show = (lab, r) => {
  const X = new Set(r.els);
  console.log(`${lab} = D(${r.name})   |.| = ${X.size}`);
  console.log(`   {${[...X].sort().join(",")}}`);
  console.log(`   R=${inR(X)} W=${inW(X)} H=${inH(X)} grounded=${grounded(X)} -> admissible=${adm(X)}`);
  return X;
};
const X = show("X", U);
const Y = show("Y", A);

const cup = new Set([...X, ...Y]);
console.log(`\nX u Y   |.| = ${cup.size}`);
console.log(`   R=${inR(cup)} W=${inW(cup)} H=${inH(cup)} grounded=${grounded(cup)} -> admissible=${adm(cup)}`);
console.log(`   armed prohibitions: ${T.bansCond(cup).join(",") || "(none)"}`);

console.log(`\nwitness valid: ${adm(X) && adm(Y) && !adm(cup)}`);
