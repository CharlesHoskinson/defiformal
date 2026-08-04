import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const key=s=>[...s].sort().join(",");
const grounds=[
 ["Pl","Im","Cd","Pf","Op","Uc","Py","Tr","Xf","Sb","Sd","In","Ex","Up","Aw","Au"],
 ["Op","Uc","Py","Tr","Xf","Sb","Sd","In","Ex","Up","Aw","Au","Xm","Of","Rl","Gs"],
 ["Fl","Xm","Au","Rl","Cp","Cl","Pl","Cd","Fz","Xf","Aw","Im","Pf","Op","Ex","Tp"],
 ["Pl","Li","Ad","Sl","Bs","Fl","Xm","Au","Rl","Ct","Im","Sh","Oa","Uc","Aw","At"]];
let tot=0, totFail=0;
for(const G of grounds){
  const ADM=[]; for(let m=0;m<(1<<16);m++){const S=new Set(G.filter((_,i)=>m&(1<<i))); if(T.admissible(S)) ADM.push(S);}
  const K=new Set(ADM.map(key));
  let fail=0, w=null;
  for(const S of ADM){ if(S.size===0) continue;
    if(![...S].some(e=>K.has(key(new Set([...S].filter(x=>x!==e)))))){fail++; if(!w)w=key(S);} }
  const uc=(()=>{for(let i=0;i<ADM.length;i++)for(let j=i;j<ADM.length;j++) if(!K.has(key(new Set([...ADM[i],...ADM[j]])))) return false; return true;})();
  const ic=(()=>{for(let i=0;i<ADM.length;i++)for(let j=i;j<ADM.length;j++) if(!K.has(key(new Set([...ADM[i]].raw||[...ADM[i]].filter(x=>ADM[j].has(x)))))) return false; return true;})();
  console.log(`ground ${G.slice(0,4).join(" ")}...: |Adm| = ${ADM.length}  empty-adm=${K.has("")}  inaccessible=${fail}${w?" e.g. "+w:""}  union-closed=${uc}  cap-closed=${ic}`);
  tot+=ADM.length; totFail+=fail;
}
console.log(`TOTAL |Adm| over the four grounds = ${tot}   (cfp-2 claims 8240)   inaccessible = ${totFail}`);
