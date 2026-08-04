/* EXHAUSTIVE. The definite closure has only 15 arcs on 58 elements; 38 elements
 * are ISOLATED (no in-arc, no out-arc). Since cl(A u X) = cl(A) u cl(X), the
 * closure factors over {active} x {isolated}, and a closed set is
 * (closed subset of the 20 active elements) u (arbitrary subset of the 38).
 * So enumerating all closed subsets of the 20 active elements, and letting x,y
 * range over ALL 58, is a COMPLETE check over the entire 2^58 lattice.
 * This file verifies the factorisation rather than assuming it.
 */
import { PARSED_NEW, MECH } from "./tables.mjs";
const E = MECH.slice();
function cl(S) {
  const X = new Set(S); let grew = true;
  while (grew) { grew = false;
    for (const law of PARSED_NEW) { if (!law.subjects.some(s => X.has(s))) continue;
      for (const t of law.terms) { if (t.external || t.alts.length !== 1) continue;
        if (!X.has(t.alts[0])) { X.add(t.alts[0]); grew = true; } } } }
  return X;
}
const R = new Map(E.map(e => [e, cl([e])]));               // cl of each singleton
const SRC = E.filter(e => R.get(e).size > 1);              // has an out-arc
const TGT = E.filter(e => E.some(s => s !== e && R.get(s).has(e)));
const ACT = [...new Set([...SRC, ...TGT])].sort();
const ISO = E.filter(e => !ACT.includes(e));
console.log(`sources=${SRC.length} ${SRC.join(",")}`);
console.log(`targets=${TGT.length} ${TGT.join(",")}`);
console.log(`source n target = ${SRC.filter(s=>TGT.includes(s)).length}  -> DAG depth = ${SRC.filter(s=>TGT.includes(s)).length===0?1:">1"}`);
console.log(`active=${ACT.length}  isolated=${ISO.length}`);

// (i) verify additivity cl(A u B) = cl(A) u cl(B) on 100k random pairs
let seed=42; const rnd=()=>(seed=(seed*1103515245+12345)&0x7fffffff)/0x7fffffff;
const rs=k=>{const s=new Set();while(s.size<k)s.add(E[Math.floor(rnd()*E.length)]);return [...s];};
let addBad=0;
for(let i=0;i<100000;i++){const A=rs(1+Math.floor(rnd()*10)),B=rs(1+Math.floor(rnd()*10));
  const l=cl([...A,...B]); const r=new Set([...cl(A),...cl(B)]);
  if(l.size!==r.size||[...l].some(x=>!r.has(x)))addBad++;}
console.log(`\nadditivity cl(AuB)=cl(A)ucl(B): 100000/${100000} tested, failures=${addBad}`);

// (ii) EXHAUSTIVE anti-exchange over every closed subset of the 20 active elements
const n=ACT.length; let closedCount=0, premises=0, viol=[];
for(let m=0;m<(1<<n);m++){
  const A=[]; for(let i=0;i<n;i++) if(m&(1<<i)) A.push(ACT[i]);
  const c=cl(A); if(c.size!==A.length) continue;            // not closed
  closedCount++;
  const As=new Set(A);
  const out=E.filter(e=>!As.has(e));
  for(const x of out) for(const y of out){ if(x===y)continue;
    if(!cl([...A,y]).has(x)) continue; premises++;
    if(cl([...A,x]).has(y)) viol.push({A:A.join(","),x,y}); }
}
console.log(`closed subsets of the active 20: ${closedCount}`);
console.log(`EXHAUSTIVE premise instances: ${premises}   VIOLATIONS: ${viol.length}`);
if(viol.length) for(const v of viol.slice(0,10)) console.log("   ***",v);

// (iii) size of the full closed-set lattice over all 58
let total=0n;
for(let m=0;m<(1<<n);m++){const A=[];for(let i=0;i<n;i++) if(m&(1<<i))A.push(ACT[i]);
  const c=cl(A); if(c.size===A.length) total++;}
console.log(`\nTOTAL closed sets in the full lattice = ${total} * 2^${ISO.length} = ${BigInt(total)*(2n**BigInt(ISO.length))}`);
console.log(`(the published bound of 1,697 covers ${(1697/Number(BigInt(total)*(2n**BigInt(ISO.length))))*100} % of it)`);
