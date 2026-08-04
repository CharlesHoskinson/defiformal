import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E = T.MECH; const key = S => [...S].sort().join(","); const D = T.DeltaInf;

// ---- HYPOTHESIS OF THM 4.x: C is the residual of R, i.e.
//      for every law (subjects S, term Tj) and every e in Tj: every s in S is in CONSUME[e].
console.log("=== residual hypothesis vs LSTAR (the scored law system) ===");
let ok=0, bad=0; const badrows=[];
for (const [id, subs, terms] of T.LSTAR)
  for (const t of terms) for (const e of t) for (const s of subs) {
    const c = T.CONSUME[e];
    if (c && c.includes(s)) ok++;
    else { bad++; if (badrows.length<40) badrows.push(`${id}: subject ${s} demands term containing ${e}, but ${e} ${c?"'s consumers":"has NO warrant row"} ${c?"= ["+c.join(",")+"] (missing "+s+")":""}`); }
  }
console.log(`pairs satisfying residual: ${ok}, VIOLATING: ${bad}`);
for (const b of badrows) console.log("  X", b);

console.log("\n=== residual hypothesis vs PARSED_NEW (the parsed law table) ===");
let ok2=0, bad2=0; const bad2rows=[];
for (const law of T.PARSED_NEW) for (const s of law.subjects) for (const t of law.terms) {
  if (t.external) continue;
  for (const e of t.alts) {
    const c = T.CONSUME[e];
    if (c && c.includes(s)) ok2++;
    else { bad2++; if (bad2rows.length<60) bad2rows.push(`${law.id}: ${s} -> term alt ${e}; consumers(${e})=${c?c.join(","):"NONE"}`); }
  }
}
console.log(`pairs satisfying residual: ${ok2}, VIOLATING: ${bad2}`);
for (const b of bad2rows) console.log("  X", b);

// ---- non-triviality of tests 1,2,4
const OB=[]; const RAISE=new Map(E.map(e=>[e,new Set()]));
for (const law of T.PARSED_NEW) law.terms.forEach((t,j)=>{ if(t.external) return; const id=law.id+"#"+j; OB.push(id);
  for (const s of law.subjects) if (RAISE.has(s)) RAISE.get(s).add(id); });
const alpha = X => { const N=new Set(); for (const e of X) for (const o of RAISE.get(e)||[]) N.add(o); return N; };
const beta = N => new Set(E.filter(e => [...RAISE.get(e)].every(o => N.has(o))));
const gamma = X => beta(alpha(X));
const DEF=[]; for (const law of T.PARSED_NEW) for (const s of law.subjects) for (const t of law.terms)
  if (!t.external && t.alts.length===1 && t.alts[0]!==s) DEF.push([s,t.alts[0]]);
const Cn = X => { const Y=new Set(X); let ch=true; while(ch){ch=false; for(const[b,h]of DEF) if(Y.has(b)&&!Y.has(h)){Y.add(h);ch=true;}} return Y; };

function* sampleAll58(){
  for (let i=0;i<E.length;i++){ yield new Set([E[i]]);
    for (let j=i+1;j<E.length;j++){ yield new Set([E[i],E[j]]);
      for (let k=j+1;k<E.length;k++) yield new Set([E[i],E[j],E[k]]); } }
  for (const p of T.lanes) yield new Set(p.syms.filter(s=>T.SYMS.has(s)));
  for (let r=0;r<200000;r++) yield new Set(E.filter(()=>Math.random()<0.25));
}
function nontriv(name,G){
  const seen=new Map(); for (const X of sampleAll58()){ const C=G(X); seen.set(key(C),C); }
  let moved=0, held=0;
  for (const C of seen.values()){ const d=D(C); if(d.size!==C.size) moved++; if(key(G(d))===key(d)) held++; }
  console.log(`\n${name}: |sampled Fix| = ${seen.size}; Delta moved on ${moved} (${(100*moved/seen.size).toFixed(2)}%); invariance held ${held}/${seen.size}`);
  console.log(`   VACUOUS (Delta = id) cases: ${seen.size-moved}`);
}
nontriv("TEST1 gamma (Galois)", gamma);
nontriv("TEST2 Cn over 58 (random sample)", Cn);

// TEST4: scored closure condition over 2^20
const U20=["Fl","Xm","Xf","Rl","Of","Bs","Sl","Au","Gs","Uc","Aw","At","Cp","Cl","Pl","Cd","Ix","Sh","Ct","Li"];
const setOf20=m=>new Set(U20.filter((_,i)=>m&(1<<i)));
const Gcond=X=>T.gammaOpen(X).length===0;
let tot=0,moved4=0,held4=0;
for(let m=0;m<(1<<20);m++){ const X=setOf20(m); if(!Gcond(X)) continue; tot++;
  const d=D(X); if(d.size!==X.size) moved4++; if(Gcond(d)) held4++; }
console.log(`\nTEST4 scored closure condition over 2^20: tot=${tot}, Delta moved on ${moved4} (${(100*moved4/tot).toFixed(2)}%), held ${held4}/${tot}`);
console.log(`   VACUOUS cases: ${tot-moved4}`);
// how many LSTAR laws can even fire inside U20?
const fired=new Set(); for(const [id,subs] of T.LSTAR) if (subs.some(s=>U20.includes(s))) fired.add(id);
console.log("   LSTAR laws whose subject can appear in U20:", [...fired].join(","), " of", T.LSTAR.length, "laws");
