// "The two differ on 675 of the 65,536 subsets" -- differ in WHAT? Test both
// readings before calling the paper wrong.
import * as T from "../v2/tables.mjs";

const UNIV = ["Sh", "Ix", "Rb", "Pl", "Ct", "Ex", "Tp", "At",
              "Li", "Ad", "Sl", "Bs", "Wq", "Rd", "Im", "Ps"];

const inR_L = X => T.gammaOpen(X).length === 0;
const inR_P = X => !T.PARSED_NEW.some(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a))));
const inW = X => T.unwarranted(X).length === 0;
const inH = X => T.bansCond(X).length === 0;
const grounded = X => !T.ungrounded(X);

const admL = X => inR_L(X) && inW(X) && inH(X) && grounded(X);
const admP = X => inR_P(X) && inW(X) && inH(X) && grounded(X);
const rwL = X => inR_L(X) && inW(X);
const rwP = X => inR_P(X) && inW(X);

let dR = 0, dAdm = 0, dRW = 0;
for (let m = 0; m < (1 << UNIV.length); m++) {
  const X = new Set();
  for (let i = 0; i < UNIV.length; i++) if (m & (1 << i)) X.add(UNIV[i]);
  if (inR_L(X) !== inR_P(X)) dR++;
  if (admL(X) !== admP(X)) dAdm++;
  if (rwL(X) !== rwP(X)) dRW++;
}
console.log("over the 65,536 subsets of the 16-element universe:");
console.log("  differ in R membership    :", dR.toLocaleString("en-US"));
console.log("  differ in R n W membership:", dRW.toLocaleString("en-US"));
console.log("  differ in Admf membership :", dAdm.toLocaleString("en-US"));
console.log("\npaper states 675");
for (const [label, v] of [["R", dR], ["RnW", dRW], ["Admf", dAdm]])
  if (v === 675) console.log("  -> reproduces under the", label, "reading");
if (![dR, dRW, dAdm].includes(675))
  console.log("  -> no reading reproduces 675");
