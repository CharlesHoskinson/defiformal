import { LSTAR, CONSUME, DEPENDENT, gammaOpen, Delta1, DeltaInf, SYMS, MECH } from "/root/DefiElements/formal/v2/tables.mjs";

const closed = S => gammaOpen(S).length === 0;

// ---- A. residual check: is CONSUME[e] >= {s : s demands a term containing e}?
console.log("== A. residual violations (s demands term containing e, but s not in CONSUME[e]) ==");
let viol = 0, checked = 0;
const violRows = [];
for (const [id, subs, terms] of LSTAR)
  for (const t of terms)
    for (const e of t) {
      if (!CONSUME[e]) continue;
      for (const s of subs) {
        checked++;
        if (!CONSUME[e].includes(s)) { viol++; violRows.push(`${id}: subject ${s} demands term [${t.join("|")}] containing ${e}, but ${s} NOT in CONSUME[${e}]=[${CONSUME[e].join(",")}]`); }
      }
    }
console.log(`checked ${checked} (s,e) pairs; violations: ${viol}`);
for (const r of violRows) console.log("  " + r);

// ---- also the reverse: is CONSUME purely R^-1 or bigger?
let extra = 0;
const demandedBy = {};
for (const [id, subs, terms] of LSTAR) for (const t of terms) for (const e of t) { (demandedBy[e] ??= new Set()); subs.forEach(s => demandedBy[e].add(s)); }
console.log("\n== A2. CONSUME rows vs R^-1 ==");
for (const e of Object.keys(CONSUME)) {
  const rinv = demandedBy[e] ? [...demandedBy[e]] : [];
  const surplus = CONSUME[e].filter(s => !rinv.includes(s));
  const missing = rinv.filter(s => !CONSUME[e].includes(s));
  extra += surplus.length;
  console.log(`  ${e}: |C|=${CONSUME[e].length} |R^-1|=${rinv.length} surplus=${surplus.length} missing=[${missing.join(",")}]`);
}
console.log(`total surplus (in C, not in R^-1): ${extra}`);
