// Round 5, finding 1: the closure proposition's H witness is false.
// It says {Cd,Cp,Fl,Im,Pl,St,Uc,Wg} and {Bs,Cd,Cl,Sl,Uc,Wg} lie in H.
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
import { inH, inR, inW, adm } from "/root/defiformal/formal/v3/lib.mjs";

const S = a => new Set(a);
const A = S(["Cd", "Cp", "Fl", "Im", "Pl", "St", "Uc", "Wg"]);
const B = S(["Bs", "Cd", "Cl", "Sl", "Uc", "Wg"]);

for (const [n, X] of [["A", A], ["B", B]]) {
  console.log(`${n} = {${[...X].sort()}}`);
  console.log(`   inH = ${inH(X)}   armed = ${T.bansCond(X).join(",") || "(none)"}`);
}
const cap = new Set([...A].filter(x => B.has(x)));
console.log(`\nA n B = {${[...cap].sort()}}   inH = ${inH(cap)}   armed = ${T.bansCond(cap).join(",") || "(none)"}`);
console.log(`\nthe paper's claim "both lie in H" is ${inH(A) && inH(B) ? "TRUE" : "FALSE"}`);

// the reviewer's suggested replacement
const P = S(["Fl", "Cp"]), Q = S(["Pl"]);
console.log(`\nreviewer's suggestion:`);
for (const [n, X] of [["{Fl,Cp}", P], ["{Pl}", Q]])
  console.log(`   ${n.padEnd(9)} inH = ${inH(X)}  armed = ${T.bansCond(X).join(",") || "(none)"}`);
const u = new Set([...P, ...Q]);
console.log(`   union {${[...u].sort()}} inH = ${inH(u)}  armed = ${T.bansCond(u).join(",") || "(none)"}`);
console.log(`   valid H non-union-closure witness: ${inH(P) && inH(Q) && !inH(u)}`);
