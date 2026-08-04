import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH.slice();
function cl(S){const X=new Set(S);let g=true;while(g){g=false;for(const law of T.PARSED_NEW){if(!law.subjects.some(s=>X.has(s)))continue;
  for(const t of law.terms){if(t.external||t.alts.length!==1)continue;if(!X.has(t.alts[0])){X.add(t.alts[0]);g=true;}}}}return X;}
const eq=(a,b)=>a.size===b.size&&[...a].every(x=>b.has(x));
const closed=new Map(); const add=S=>{const c=cl(S);closed.set([...c].sort().join(","),c);};
add([]); for(const a of E) add([a]); for(const a of E) for(const b of E) if(a<b) add([a,b]);
console.log("closed sets:",closed.size);
const sizes={}; for(const A of closed.values()) sizes[A.size]=(sizes[A.size]||0)+1;
console.log("size histogram:",JSON.stringify(sizes));
console.log("closed sets with |A|>8 (SKIPPED by antiexchange.mjs generator test):",[...closed.values()].filter(A=>A.size>8).length);

// CORRECTED: subset-MINIMAL generators, not minimum-CARDINALITY generators
let uMin=0,mMin=0,uCard=0,mCard=0; const ex=[];
for(const A of closed.values()){ if(A.size===0) continue;
  const arr=[...A]; const gens=[];
  for(let mask=1;mask<(1<<arr.length);mask++){const G=arr.filter((_,i)=>mask&(1<<i)); if(eq(cl(G),A)) gens.push(G);}
  const minCard=Math.min(...gens.map(g=>g.length));
  const byCard=gens.filter(g=>g.length===minCard);
  const gsets=gens.map(g=>new Set(g));
  const subsetMinimal=gens.filter((g,i)=>!gsets.some((h,j)=>j!==i&&h.size<g.length&&[...h].every(x=>g.includes(x))));
  if(byCard.length===1)uCard++;else mCard++;
  if(subsetMinimal.length===1)uMin++;else {mMin++; if(ex.length<5)ex.push([arr.sort().join(","),subsetMinimal.map(g=>g.join("+"))]);}
}
console.log(`\nminimum-CARDINALITY generator unique: ${uCard}  non-unique: ${mCard}   <-- what antiexchange.mjs measures`);
console.log(`subset-MINIMAL generator unique:     ${uMin}  non-unique: ${mMin}   <-- what a convex geometry actually asserts`);
for(const e of ex) console.log("   multi:",e[0],"->",JSON.stringify(e[1]));

// ---- CLUTTER (meas:clutter)
console.log("\n=== meas:clutter ===");
console.log("recorded prohibition rows |HAZ| =", T.HAZ.length);
const named = T.HAZ.map(h=>({id:h.id, combo:h.combo, named:[...new Set((h.combo.match(/\b[A-Z][a-z]{1,2}\b/g)||[]).filter(x=>T.SYMS.has(x)))]}));
console.log("rows naming 0 elements:", named.filter(h=>h.named.length===0).map(h=>h.id).join(",")," count=",named.filter(h=>h.named.length===0).length);
console.log("rows naming 1 element :", named.filter(h=>h.named.length===1).map(h=>h.id).join(","), " count=",named.filter(h=>h.named.length===1).length);
console.log("rows naming >=2       :", named.filter(h=>h.named.length>=2).map(h=>h.id+"{"+h.named.join(",")+"}").join(" | "));
console.log("HAZ_PROJ eligible (>=2 named AND no negation word):", T.HAZ_PROJ.map(h=>h.id+"{"+h.named.join(",")+"}").join(" | "));
console.log("is {Fl,Xm} a recorded row?", named.some(h=>h.named.length===2&&h.named.includes("Fl")&&h.named.includes("Xm")));
console.log("is {Fl,Au,Rl} a recorded row?", named.some(h=>h.named.includes("Fl")&&h.named.includes("Au")&&h.named.includes("Rl")));

// blocker of the papers 3-member clutter
const C=[["Fl","Xm"],["Fl","Au","Rl"],["Fl","Cp","Cl","Pl","Cd"]];
const G=[...new Set(C.flat())]; console.log("ground of the clutter:",G.join(","),"size",G.length);
const covers=[]; for(let m=1;m<(1<<G.length);m++){const S=G.filter((_,i)=>m&(1<<i));
  if(C.every(c=>c.some(e=>S.includes(e)))) covers.push(S);}
const minimalCovers=covers.filter((s,i)=>!covers.some((t,j)=>j!==i&&t.length<s.length&&t.every(x=>s.includes(x))));
console.log("|b(Haz)| =",minimalCovers.length, JSON.stringify(minimalCovers));
const bb=[]; for(let m=1;m<(1<<G.length);m++){const S=G.filter((_,i)=>m&(1<<i));
  if(minimalCovers.every(c=>c.some(e=>S.includes(e)))) bb.push(S);}
const bbMin=bb.filter((s,i)=>!bb.some((t,j)=>j!==i&&t.length<s.length&&t.every(x=>s.includes(x))));
console.log("b(b(Haz)) =",JSON.stringify(bbMin.map(s=>s.sort())), " equals Haz?", JSON.stringify(bbMin.map(s=>s.slice().sort().join(",")).sort())===JSON.stringify(C.map(s=>s.slice().sort().join(",")).sort()));
// is the actually-ENFORCED ban family an antichain containing these?
console.log("\nenforced bans as minimal forbidden sets (from f10 CNF / bansCond):");
console.log("  X21 -> {Fl,Xf},{Fl,Rl},{Fl,Of}   X2 -> {Fl,c,p} for c in {Cp,Cl}, p in {Pl,Cd,Im}");
console.log("  => {Fl,Au,Rl} STRICTLY CONTAINS {Fl,Rl}; {Fl,Cp,Cl,Pl,Cd} STRICTLY CONTAINS {Fl,Cp,Pl}");
console.log("  => the papers 3-member family is NOT an antichain of minimal forbidden sets of the enforced theory");
