import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH.slice().sort(); const has=s=>E.includes(s);
const W=[]; const push=(w,src)=>W.push([w,src]);
for(const [id,subs,terms] of T.LSTAR) for(const s of subs){ if(!has(s))continue;
  for(const t of terms) push(1+t.filter(has).length,"closure/"+id); }
for(const e of Object.keys(T.CONSUME)){ if(!has(e))continue; push(1+T.CONSUME[e].filter(has).length,"warrant/"+e); }
for(const h of T.HAZ_PROJ) push(h.named.filter(has).length,"listed/"+h.id);
push(2,"ban");push(2,"ban");push(5,"ban");
for(const c of ["Cp","Cl"]) for(const p of ["Pl","Cd","Im"]) push(3,"ban");
push(4,"ban"); for(const z of ["Xf","Rl","Of"]) push(2,"ban");
const RISKG=new Set(["G05","G06","G07","G13","G16"]);
const LOW=E.filter(s=>T.ELEMS[s].stratum<=2).length;
for(const s of E) if(RISKG.has(T.ELEMS[s].group)) push(1+LOW,"ground");
console.log("total CNF clauses:",W.length);
const h={}; for(const [w] of W) h[w]=(h[w]||0)+1;
console.log("width histogram:",JSON.stringify(Object.fromEntries(Object.entries(h).sort((a,b)=>a[0]-b[0]))));
console.log("bijunctive (width<=2):",W.filter(x=>x[0]<=2).length,"/",W.length,"=",(100*W.filter(x=>x[0]<=2).length/W.length).toFixed(1)+"%");
console.log("widest:",Math.max(...W.map(x=>x[0])),"->",W.filter(x=>x[0]===Math.max(...W.map(y=>y[0]))).map(x=>x[1]).join(","));
// slack range from f11 rerun
import fs from "node:fs";
const out=fs.readFileSync("/root/DefiElements/audit/f11-rerun.out","utf8").split("\n");
const sl=[];
for(const l of out){ const m=l.match(/^  \{.*\}\s+\d+\s+\{.*\}\s+\w+\s+\d+\s+\d+\s+(\d+)\s*$/); if(m) sl.push(+m[1]); }
console.log("\n10/20-element slack values:",JSON.stringify(sl));
const sl58=[...out.join("\n").matchAll(/slack vs observed UB=(\d+)/g)].map(m=>+m[1]);
console.log("58-element slack values:",JSON.stringify(sl58));
const all=[...sl,...sl58];
console.log("ALL",all.length,"seed-instances; slack range",Math.min(...all),"--",Math.max(...all)," paper says 1--39");
