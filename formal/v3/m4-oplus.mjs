// cor:oplusclosed -- "R n W is closed under (+). Composition therefore fails to preserve
// admissibility only once prohibitions are imposed."
// PLUS: attribute the composition failures to the exact condition that fires.
import * as L from "./lib.mjs";
import * as T from "../v2/tables.mjs";

console.log("=== cor:oplusclosed + failure attribution ===\n");

// (+) = Gamma(X u Y). With model classes there is no Gamma; on members of R the union is
// already a model, so (+) = union. Check that directly.
let n = 0, fail = 0;
const pool = L.sample(L.inRW, 2500, 0.2, 5);
for (let i = 0; i < pool.length; i++) for (let j = i + 1; j < Math.min(pool.length, i + 40); j++) {
  n++; if (!L.inRW(L.uni(pool[i], pool[j]))) fail++;
}
console.log(`(+)-closure of R n W: ${n} pairs, ${fail} failures`);

// --- now: admissible x admissible -> is the union admissible? attribute every failure.
const apool = L.sample(L.adm, 2500, 0.2, 9);
console.log(`\nadmissible pool: ${apool.length}`);
const tally = new Map(), soleTally = new Map();
let an = 0, af = 0, byClosure = 0, byWarrant = 0, byGround = 0, byHazard = 0;
for (let i = 0; i < apool.length; i++) for (let j = i + 1; j < Math.min(apool.length, i + 40); j++) {
  const U = L.uni(apool[i], apool[j]);
  an++;
  const [ok, parts] = T.admissible(U, true);
  if (ok) continue;
  af++;
  if (parts.closure.length) byClosure++;
  if (parts.warrant.length) byWarrant++;
  if (parts.ground) byGround++;
  if (parts.hazard.length) byHazard++;
  for (const h of parts.hazard) tally.set(h, (tally.get(h) || 0) + 1);
  if (parts.hazard.length === 1) soleTally.set(parts.hazard[0], (soleTally.get(parts.hazard[0]) || 0) + 1);
}
console.log(`pairs ${an}; union not admissible: ${af} (${(100 * af / an).toFixed(1)}%)`);
console.log(`  attributable to REQUIREMENTS (closure clauses) : ${byClosure}`);
console.log(`  attributable to WARRANTS                       : ${byWarrant}`);
console.log(`  attributable to GROUNDING                      : ${byGround}`);
console.log(`  attributable to PROHIBITIONS (bansCond)        : ${byHazard}`);
console.log(`  prohibition rows fired (with multiplicity):`);
for (const [k, v] of [...tally].sort((a, b) => b[1] - a[1])) console.log(`      ${k.padEnd(8)} ${v}`);
console.log(`  failures where that row was the SOLE cause:`);
for (const [k, v] of [...soleTally].sort((a, b) => b[1] - a[1])) console.log(`      ${k.padEnd(8)} ${v}`);

// --- clause polarity of every bansCond row, decided by inspection of the shipped predicate
console.log(`\npolarity of the shipped bansCond rows (paper calls all of these 'prohibitions'):`);
const rows = [
  ["X11a*", "Uc & !(Aw & At)", "Uc -> Aw ; Uc -> At", "DUAL-HORN (a requirement written negatively): union-closed"],
  ["X19*", "Aw & Xf & !(At|Fz|Xm)", "!Aw v !Xf v At v Fz v Xm", "MIXED: >=2 positive so not Horn, >=2 negative so not dual-Horn"],
  ["X2", "Fl & (Cp|Cl) & (Pl|Cd|Im)", "!Fl v !c v !d  for each c,d", "PURELY NEGATIVE (Horn): a genuine prohibition"],
  ["X18", "Oa & Li & !(Ex|Tp)", "!Oa v !Li v Ex v Tp", "MIXED: >=2 positive so not Horn, >=2 negative so not dual-Horn"],
  ["X21", "Fl & (Xf|Rl|Of)", "!Fl v !Xf ; !Fl v !Rl ; !Fl v !Of", "PURELY NEGATIVE (Horn): a genuine prohibition"],
];
for (const r of rows) console.log(`  ${r[0].padEnd(7)} ${r[1].padEnd(26)} => ${r[2].padEnd(34)} ${r[3]}`);
console.log(`  listed HAZ_PROJ rows (from the 20-row table), eligible by >=2 named elements and no negation word:`);
for (const h of T.HAZ_PROJ) console.log(`      ${h.id.padEnd(7)} named=[${h.named.join(",")}]  combo="${h.combo}"`);

// --- per-row union-closure test: which rows can EVER break union closure?
console.log(`\nper-row: does the model class of this row alone fail union-closure? (sampled)`);
const singleTests = {
  "X11a*": S => S.has("Uc") && !(S.has("Aw") && S.has("At")),
  "X19*": S => S.has("Aw") && S.has("Xf") && !["At", "Fz", "Xm"].some(x => S.has(x)),
  "X2": S => S.has("Fl") && ["Cp", "Cl"].some(x => S.has(x)) && ["Pl", "Cd", "Im"].some(x => S.has(x)),
  "X18": S => S.has("Oa") && S.has("Li") && !["Ex", "Tp"].some(x => S.has(x)),
  "X21": S => S.has("Fl") && ["Xf", "Rl", "Of"].some(x => S.has(x)),
};
for (const h of T.HAZ_PROJ) singleTests[h.id] = S => h.named.every(e => S.has(e));
for (const [id, viol] of Object.entries(singleTests)) {
  const ok = S => !viol(S);
  const p = L.sample(ok, 400, 0.25, 42);
  let bad = 0, m = 0;
  for (let i = 0; i < p.length; i++) for (let j = i + 1; j < p.length; j++) { m++; if (!ok(L.uni(p[i], p[j]))) bad++; }
  console.log(`   ${id.padEnd(8)} union-closure failures ${String(bad).padStart(6)} / ${m}`);
}
