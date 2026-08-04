// Au and Gs together (the L21 stratum inversion) is a documented atlas erratum
// (formal/FINDINGS.md Q10/Q12.2), not a financial hazard. Not enforced.
// X11a / X11b are not separately enforced. X11a (Uc with no Aw, At, collateral
// or reputation), read with its own stated non-reversed polarity, can never arm
// on any set that is already closed(), because L3 already forces Aw AND At to
// both be present whenever Uc is present in a closed set. X11a is logically
// subsumed by L3, not an independent constraint. X11b requires weak
// underwriting, which is not membership-checkable. GP-LOG ruling (per BRIEF.md
// section 4b item on Uc unrealizability): Uc IS realizable under this algebra;
// the unrealizable finding in FINDINGS.md is an artifact of a different,
// reversed-polarity reading of X11a, which this algebra does not adopt.

export const ELEMENTS = `Sh Ix Rb Cp Wg St Cl Pm Ob Rf Ba In Ag Fl Pl Im Cd Uc Ft Ct Li Ad Sl Bs Pf Op Tr
Cv Py Sv Dp Ex Tp Oa At Sr Ep Wq Em Fd Tg Up Gp Au Gs Xm Xf Rl Of Rd Ps As Aw Sb
Sd Fz Rs Vl`.split(/\s+/);

if (ELEMENTS.length !== 58) {
  throw new Error(`Expected 58 elements, found ${ELEMENTS.length}`);
}

export const LAWS = [
  ['L1', '(Pl|Im|Cd|Pf|Op) -> (Ex|Tp|At) + Ct + (Li|Ad|Sl|Bs)'],
  ['L2', 'Pl -> (Sh|Ix) + exit-liquidity'],
  ['L3', 'Uc -> Aw + At{subject=borrower-financials} + (Bs|Tr) + obligor'],
  ['L4', 'Pf -> Ex + Ct + Li + (Ad|Sl|Bs)'],
  ['L5', 'Py -> (Sh|Ix|Rb) + Ep + Rd'],
  ['L6', 'Tr -> (Sv | mechanical trigger) + declared seniority + dispute forum + recovery-timing assumption'],
  ['L7', 'Cd -> Rd | Ps | liquidation capacity'],
  ['L8', 'Xf -> Xm | named custodian, plus a global claim ledger'],
  ['L9', 'Xf -> debit(source) = credit(destination)'],
  ['L10', 'Sb -> proof verifier + nullifier set'],
  ['L11', 'Sd -> credential source + verifier + revocation'],
  ['L12', 'In -> signed constraints + settlement verifier + (solver|fallback) + timeout'],
  ['L13', 'Ex -> freshness validation; Gp preferred for high-value obligations'],
  ['L14', 'illiquid backing -> Wq | bounded liquidity reserve'],
  ['L15', 'Up -> Tg | bounded emergency process'],
  ['L16', 'Aw -> transfer-time enforcement where eligibility follows the holder'],
  ['L17', 'Au -> bounded scope + revocation + expiry + nonce/domain separation'],
  ['L18', 'Xm -> explicit finality + chain/domain binding + replay protection'],
  ['L19', 'Of -> Xm + Xf + (Bs|Sl) + timeout'],
  ['L20', 'Rl -> Au + single-spend + expiry + fulfillment proof + release'],
  ['L21', 'Gs -> Au + metering + fee settlement'],
  ['L22', 'Rs -> attributed slash condition + non-reflexive capital + loss waterfall'],
  ['L23', 'Sq -> Xm + independent settlement finality'],
  ['L24', '(In|Rf|Ba) -> an explicit informational edge with a catalog tag'],
  ['L25', 'wrapped cross-domain collateral -> haircut + cap + independent exit'],
  ['L26', 'Aw + Xf -> destination-enforced eligibility + revocation propagation + jurisdictional binding'],
  ['L27', 'At -> named attester + independence + stated assurance + staleness bound + recourse'],
  ['L28', 'Fz -> named authority + enumerated triggers + appeal path + holder disclosure'],
  ['L29', '(In|Ba|Rf|Of) -> a declared surplus-allocation rule naming the residual claimant'],
];

if (LAWS.length !== 29) {
  throw new Error(`Expected 29 laws, found ${LAWS.length}`);
}

export const HAZARDS = [
  ['X1', 'As + reflexive junior token, with no hard redemption or exogenous capital'],
  ['X2', 'Fl* + manipulable Cp/Cl price + Pl/Cd, where manipulation cost < position value'],
  ['X3', 'Protocol token as collateral AND oracle market AND backstop'],
  ['X4', 'Rb into a balance-invariant ledger with no adapter'],
  ['X5', 'Illiquid backing + uncapped instant par redemption'],
  ['X6', 'Borrowable voting power + immediate execution'],
  ['X7', 'Cross-domain mint whose verifier is present but unproven correct'],
  ['X8', 'Shared collateral across nominally isolated markets'],
  ['X9', 'Up with immediate single-key control'],
  ['X10', 'Pm with a stale reference and unrestricted inventory'],
  ['X11a', 'Uc with no Aw, At, collateral or reputation'],
  ['X11b', 'Uc with all of them and weak underwriting'],
  ['X12', 'Lock-mint wrapped asset as canonical collateral whose value at risk exceeds the bridge economic security'],
  ['X13', 'External-validator Xm securing value exceeding slashable stake'],
  ['X14', 'Exclusive market structure plus a price-improvement claim with no named benchmark'],
  ['X15', 'Rs securing a bridge mostly with assets issued by that bridge'],
  ['X16', 'Unbounded delegated authority, or unlimited token approvals'],
  ['X17', 'Passive protocol-token reserve backing protocol-token collateral'],
  ['X18', 'Oa as sole truth for high-frequency liquidation'],
  ['X19', 'Restricted claim bridged via Xf into a representation with no destination-side Aw'],
];

if (HAZARDS.length !== 20) {
  throw new Error(`Expected 20 hazards, found ${HAZARDS.length}`);
}

const elementSet = new Set(ELEMENTS);

export function bare(text) {
  return text.replace(/\{[^}]*\}/g, '').replace(/[()]/g, '').trim();
}

export function parseLaw([id, rule]) {
  const arrow = rule.indexOf('->');
  const lhs = rule.slice(0, arrow);
  const rhs = rule.slice(arrow + 2);
  const subjects = lhs
    .split('|')
    .map(bare)
    .filter((symbol) => elementSet.has(symbol));
  const terms = rhs.split('+').map((chunk) => {
    const alts = chunk
      .split('|')
      .map(bare)
      .filter((symbol) => elementSet.has(symbol));
    return { alts, external: alts.length === 0 };
  });
  return { id, rule, subjects, terms };
}

export const parsedLaws = LAWS.map(parseLaw);

const l15 = parsedLaws.find(({ id }) => id === 'L15');
if (!l15 || l15.terms.length !== 1 || l15.terms[0].alts.join(',') !== 'Tg') {
  throw new Error('Unexpected generic parse for L15 promotion');
}
// P1: bounded emergency process is formalized as Gp; FINDINGS.md shows L15 otherwise fails to discriminate live from dead protocols.
l15.terms[0].alts = ['Tg', 'Gp'];
l15.terms[0].external = false;

const l8 = parsedLaws.find(({ id }) => id === 'L8');
if (!l8 || l8.terms[0].alts.join(',') !== 'Xm') {
  throw new Error('Unexpected generic parse for L8 promotion');
}
// P2: named custodian is formalized as At; corpus50/VERDICT.md identifies attestation as the missing custodial-bridge formalization.
l8.terms[0].alts = ['Xm', 'At'];
l8.terms[0].external = false;

export const fireableLaws = parsedLaws.filter(({ subjects }) => subjects.length > 0);
if (fireableLaws.length !== 25) {
  throw new Error(`Expected 25 fireable laws, found ${fireableLaws.length}`);
}

function uniqueNamedSymbols(combo) {
  const named = [];
  const seen = new Set();
  for (const match of combo.matchAll(/\b[A-Z][a-z]{1,2}\b/g)) {
    const symbol = match[0];
    if (elementSet.has(symbol) && !seen.has(symbol)) {
      seen.add(symbol);
      named.push(symbol);
    }
  }
  return named;
}

export const parsedHazards = HAZARDS.map(([id, combo]) => {
  const named = uniqueNamedSymbols(combo);
  const evaluable = named.length >= 2 && !/\b(no|without|absent|lacking|missing|never)\b/i.test(combo);
  return { id, combo, named, evaluable };
});

export const evaluableHazards = parsedHazards.filter(({ evaluable }) => evaluable);
if (evaluableHazards.length !== 1 || evaluableHazards[0].id !== 'X2') {
  throw new Error(`Expected only X2 to be evaluable, found ${evaluableHazards.map(({ id }) => id).join(',')}`);
}
console.log(`Evaluable hazards: ${evaluableHazards.length} (${evaluableHazards[0].id})`);

function asSet(presentSymbols) {
  return presentSymbols instanceof Set ? presentSymbols : new Set(presentSymbols);
}

export function evaluate(presentSymbols) {
  const present = asSet(presentSymbols);
  const fired = [];
  const openLaws = [];
  for (const law of fireableLaws) {
    if (!law.subjects.some((symbol) => present.has(symbol))) continue;
    fired.push(law.id);
    const satisfied = law.terms.every(
      (term) => term.external || term.alts.some((symbol) => present.has(symbol)),
    );
    if (!satisfied) openLaws.push(law.id);
  }
  return { fired, openLaws };
}

export function closed(presentSymbols) {
  const { fired, openLaws } = evaluate(presentSymbols);
  return { ok: openLaws.length === 0, fired, openLaws };
}

export function armedHazards(presentSymbols) {
  const present = asSet(presentSymbols);
  return evaluableHazards
    .filter(({ named }) => named.every((symbol) => present.has(symbol)))
    .map(({ id }) => id);
}

// XL1/XL2 are the two minimal atomic-flash-liquidity-cross-domain witnesses from exhaustive size <= 5 search in FINDINGS.md Q12.1.
export function xl1Forbidden(presentSymbols) {
  const present = asSet(presentSymbols);
  return present.has('Fl') && present.has('Xm');
}

export function xl2Forbidden(presentSymbols) {
  const present = asSet(presentSymbols);
  return present.has('Fl') && present.has('Au') && present.has('Rl');
}

// LN1 is the FINDINGS.md X19 repair: a restricted/gated cross-domain claim requires destination-side eligibility enforcement.
export function ln1Holds(presentSymbols) {
  const present = asSet(presentSymbols);
  return !(present.has('Fz') && present.has('Xf')) || present.has('Aw');
}

export function admissible(presentSymbols) {
  const closure = closed(presentSymbols);
  const armed = armedHazards(presentSymbols);
  const reasons = closure.openLaws.map((id) => `open:${id}`);
  if (armed.includes('X2')) reasons.push('X2');
  if (xl1Forbidden(presentSymbols)) reasons.push('XL1');
  if (xl2Forbidden(presentSymbols)) reasons.push('XL2');
  if (!ln1Holds(presentSymbols)) reasons.push('LN1');
  return { ok: reasons.length === 0, reasons };
}
