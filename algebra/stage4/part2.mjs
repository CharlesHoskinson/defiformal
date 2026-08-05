import fs from 'node:fs';
const T = JSON.parse(fs.readFileSync('tagged.json', 'utf8'));

// ---- LEGAL sub-split, hand-assigned in the order the LEGAL items appear ----
// A = dependence on a named off-chain PARTY (custodian/obligor/attester) -> party sort
// B = a legal instrument, register of record, jurisdiction or contract term -> no sort helps
const LEGAL_SUB = ['A','A','A','B','A','B','A','B','A','A','B','A','A','A','A','B',
                   'A','A','B','A','B','B','B','B','B','A','B','A','B','B','B','B','B','B','B'];
const legal = T.filter(t => t.g === 'LEGAL');
if (legal.length !== LEGAL_SUB.length) throw new Error('LEGAL sub-split length ' + legal.length);
legal.forEach((t, i) => { t.sub = LEGAL_SUB[i]; });
const legalA = legal.filter(t => t.sub === 'A').length;
const legalB = legal.filter(t => t.sub === 'B').length;
console.log(`LEGAL split: A(named off-chain party) = ${legalA}   B(instrument/register/jurisdiction) = ${legalB}`);
console.log('  LEGAL-A categories:', [...new Set(legal.filter(t=>t.sub==='A').map(t=>t.category.slice(0,2)))].sort().join(','));
console.log('  LEGAL-B categories:', [...new Set(legal.filter(t=>t.sub==='B').map(t=>t.category.slice(0,2)))].sort().join(','));

// ---- which sort does each (c) group need ----
const partySortGroups = ['PARTY', 'FLOW'];
const partySort = T.filter(t => partySortGroups.includes(t.g)).length + legalA;
const assetSort = T.filter(t => t.g === 'DOMAIN').length;
console.log(`\n(c) decomposes: party sort ${partySort} | asset/domain sort ${assetSort} | legal register ${legalB}` +
  `  total ${partySort + assetSort + legalB}`);

// ---- groups whose (a)/(b) repair PRESUPPOSES a party sort ----
const dependent = T.filter(t => ['MANDATE', 'ADJUD'].includes(t.g)).length;
console.log(`(a)-repairs presupposing the party sort: MANDATE+ADJUD = ${dependent}`);
console.log(`=> items turning on a party sort, directly or as prerequisite: ${partySort + dependent}` +
  ` = ${((partySort + dependent) / 385 * 100).toFixed(1)}% of 385`);

// ---- MANDATE: which envelope parts are named ----
const mand = T.filter(t => t.g === 'MANDATE');
const rx = {
  cap:    /\bcap|ceiling|maximum|max |limit|no more than|not exceed|up to|floor|bounded|allowance|fraction|at most/i,
  rate:   /cooldown|step|per-caller interval|refill|regenerat|slope|rate limit|rate-limit|delay|effect block|queue|timelock/i,
  domain: /whitelist|registered|enumerated|named vault|allowlist|only .*(strategy|markets|identifiers|actions)|per \(caller|selector/i,
  revoke: /revocab|revoke|revocation|cancel|veto|remove the (agent|role)/i,
};
const parts = { cap: 0, rate: 0, domain: 0, revoke: 0 };
let none = 0;
for (const t of mand) {
  let hit = 0;
  for (const k of Object.keys(rx)) if (rx[k].test(t.text)) { parts[k]++; hit++; }
  if (hit === 0) none++;
}
console.log(`\nMANDATE n=${mand.length}: cap ${parts.cap} | rate-or-delay ${parts.rate} | domain ${parts.domain}` +
  ` | REVOCATION ${parts.revoke} | no envelope part at all ${none}`);
// where does revocation live instead?
const revElsewhere = T.filter(t => t.g !== 'MANDATE' && /veto|may cancel|revocab|revocation/i.test(t.text));
console.log('revocation named OUTSIDE the mandate items:', revElsewhere.length,
  revElsewhere.map(t => t.category.slice(0,2) + '/' + t.app.split(' ')[0] + '[' + t.g + ']').join(' '));

// ---- the four stage-1 convergences, re-measured on the stage-3 residue ----
const conv = { 'bounded delegate mandate': 'MANDATE', 'containment between protocols': 'LEVEL',
               'the holder, not the facility': 'PARTY', 'discharge by construction': 'CONSTR' };
console.log('\n=== stage-1 convergences re-measured on the 385 ===');
for (const [name, g] of Object.entries(conv)) {
  const it = T.filter(t => t.g === g);
  const cats = [...new Set(it.map(t => t.category))].sort();
  const apps = [...new Set(it.map(t => t.app))];
  console.log(`${name.padEnd(32)} n=${String(it.length).padStart(3)}  cats=${cats.length} (${cats.map(c=>c.slice(0,2)).join(',')})  apps=${apps.length}/35`);
}

// ---- ranking device ----
const REPAIR = { PARTY:'c', MANDATE:'a', ADJUD:'a', LEVEL:'d', LEGAL:'c', DOMAIN:'c',
                 CONSTR:'b', TRUST:'a', LOSS:'a', INSTR:'a', FLOW:'c', QUANT:'b', OPAQUE:'b' };
// results damaged, out of the five named ones:
// R1 polarity/Horn split | R2 union-closure & lattice | R3 convex geometry & minimal generators
// R4 linear composition on canonical forms | R5 compatibility graph & perfection
const DAMAGE = {
  PARTY:   ['R5'],
  MANDATE: [],
  CONSTR:  ['R3','R4'],
  LEVEL:   ['R2','R3','R4','R5'],
  DOMAIN:  ['R3','R4','R5'],
  LEGAL:   ['R2','R3','R4','R5'],
  TRUST:   [],
  LOSS:    [],
  INSTR:   [],
  ADJUD:   ['R5'],
  FLOW:    ['R5'],
  QUANT:   ['R1','R2','R3','R4','R5'],
  OPAQUE:  ['R2'],
};
// one relation seen across categories (convergent) vs a family of distinct gaps
const CONVERGENT = { PARTY:1, MANDATE:1, CONSTR:1, LEVEL:1, DOMAIN:1, LEGAL:1, ADJUD:1,
                     FLOW:1, QUANT:1, OPAQUE:1, TRUST:0, LOSS:0, INSTR:0 };

const rows = [];
for (const g of Object.keys(REPAIR)) {
  const it = T.filter(t => t.g === g);
  const cats = new Set(it.map(t => t.category)).size;
  const apps = new Set(it.map(t => t.app)).size;
  const dmg = DAMAGE[g].length;
  const ev = cats * (CONVERGENT[g] ? 2 : 1);
  rows.push({ g, n: it.length, cats, apps, repair: REPAIR[g], conv: CONVERGENT[g],
              dmg, damaged: DAMAGE[g].join('/') || '-', score: +(ev / (1 + dmg)).toFixed(2) });
}
rows.sort((a, b) => b.score - a.score || b.n - a.n);
console.log('\n=== RANK (evidence = cats x convergence-flag; damage = named results broken) ===');
console.log('rk group     n  cats apps rep conv dmg  score  damaged');
rows.forEach((r, i) => console.log(
  `${String(i+1).padStart(2)} ${r.g.padEnd(8)} ${String(r.n).padStart(3)} ${String(r.cats).padStart(4)}` +
  ` ${String(r.apps).padStart(4)}   ${r.repair}    ${r.conv}   ${r.dmg}  ${String(r.score).padStart(5)}  ${r.damaged}`));
