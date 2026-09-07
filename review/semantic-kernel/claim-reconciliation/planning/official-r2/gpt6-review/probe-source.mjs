import * as T from '/home/charl/defiformal/formal/v2/tables.mjs';
import * as L from '/home/charl/defiformal/formal/v3/lib.mjs';
const candidates = [
 ['X', ['Cl','Cp','Fd','Fl','Sh','Tg','Tp']],
 ['Y', ['Bs','Cd','Ct','Em','Ex','Fd','Fl','Gp','Im','Ix','Li','Pl','Rb','Sl','Tg','Up','Xm']]
];
console.log(JSON.stringify({symbols:Object.values(T.ELEMS), mechanisms:T.MECH,
 lstar:T.LSTAR, parsed:T.PARSED_NEW,
 candidates:candidates.map(([label,x])=>{const s=new Set(x);return {label,items:x,
 adm:L.adm(s),requirements:L.inR(s),warrants:L.inW(s),hazards:L.inH(s),grounded:L.grounded(s),
 open:L.openReq(s),unwarranted:T.unwarranted(s),bans:T.bansCond(s)}}),
 union_bans:T.bansCond(new Set(candidates.flatMap(x=>x[1])))
}));
