# Adversarial audit -- claim structure of /root/DefiElements

Audited: paper/atlas.tex, algebra/THEOREM-LEDGER.md, algebra/MODEL.md,
algebra/PLAIN-ENGLISH.md, algebra/REQUIREMENTS.md, formal/v2/FINDINGS-V2.md,
plus algebra/BRIEF.md, algebra/THEOREMS.md, corpus50/VERDICT.md,
corpus50/lanes/*.json, formal/v2/tables.mjs, viz/src/data.ts (source of
truth for the hazard table) where claims needed to be checked against data.

Session note: paper/atlas.tex was being actively edited while this audit
ran -- it grew from 567 to 636 lines between the first and a later read
(mtimes: atlas.tex 1785882871, ~3 min before audit tooling was invoked;
REQUIREMENTS.md 1785880334, older). Citations below are to the version at
mtime 1785882871. Ordering by mtime shows the authorship chain: VERDICT ->
BRIEF -> THEOREMS -> PLAIN-ENGLISH -> MODEL/THEOREM-LEDGER (same timestamp) ->
REQUIREMENTS -> FINDINGS-V2 -> atlas.tex. This matters for C3 below:
corrections made in the newest document (atlas.tex, FINDINGS-V2.md) were not
back-ported to older ones.

---

## SEVERITY 1 -- CRITICAL

### F1. atlas.tex Repair section reintroduces a council-refuted hazard as if it were a genuine table entry

atlas.tex lines 595-596, Measurement (meas:clutter), "The prohibition table is
smaller than it appears":

> "Of the 20 recorded prohibition rows, only 3 are enforced positive element
> sets, namely Fl+Xm, Fl+Au+Rl and Fl+Cp+Cl+Pl+Cd."

I extracted the actual 20-row hazard table from viz/src/data.ts (which
formal/v2/tables.mjs reads directly) and ran the same symbol-extraction the
codebase itself uses (HAZ_PROJ in tables.mjs). Result: only one row, X2,
yields a genuine positive multi-symbol set -- Fl+Cp+Cl+Pl+Cd. No row among
X1-X19 (X11a/X11b counted separately = 20 rows) mentions both Fl and Xm, or
both Au and Rl. The pairs Fl+Xm and Fl+Au+Rl are not in the recorded
prohibition table at all.

They are, instead, the two "unlisted hazard" witnesses that BRIEF.md section
4b and THEOREMS.md describe as discovered by brute-force search precisely
because they are absent from the 20 written rows ("Fl,Xm is closed under all
25 fireable laws, arms none of the 20 hazard rows... Second witness of the
same shape: Fl,Au,Rl" -- BRIEF.md, around lines 132-136).

Worse: the flat Fl+Xm membership hazard is explicitly REFUTED in
THEOREM-LEDGER.md:

> R1: "Fl,Xm as a flat membership hazard -- our model checker's prize" |
> Flags Aave v3. ... Evidence beats provenance. The narrowing Fl and
> (Xf or Rl or Of) survives.
> R8: "Fl,Xm dies because it fires on Aave v3" | It dies on warrant ... but
> the atomic-scope family is sharpened, not killed ... There IS an unlisted
> hazard family; it is not the flat pair.

So the newest document in the project, in a section building a worked example
of blocker duality (Isbell / Edmonds-Fulkerson) and Seymour's identity on
"the genuine 3-member clutter," treats as one of its three ground-truth data
points a hazard that (a) is not in the hand-written table it claims to
summarize, and (b) was explicitly killed by the project's own council as a
false positive against a live protocol. The downstream numbers in the same
measurement (|b(Haz)| = 9, b(b(Haz)) = Haz, and "the maximal hazard-free sets
are exactly the complements of b(Haz)") are computed from this wrong ground
truth. The abstract theorem (blocker duality itself) is untouched -- it is a
classical result -- but its application here is built on a data error,
uncorrected anywhere in the paper.

This is exactly the calibration pattern ("called a hazard derived
search-free when it was read back from hand-written input") recurring in a
different, more severe form: this time the wrong set itself, not just its
derivation method, is misattributed to the formal table.

Severity: critical. It is in the newest document, in a numbered Measurement,
feeding a Theorem-and-Corollary worked example, and directly contradicts a
REFUTED entry in the project's own ledger.

### F2. "Identical decomposition" claims are false against the corpus data that supposedly supports them -- calibration bug #5, still live

corpus50/decomp-contract.md lines 24-25 define the field precisely: "If two
protocols in a category decompose identically, say so" -> structured as
identical_decompositions: [[A,B]], meaning the recorded "elements" arrays are
asserted equal. I checked every identical_decompositions entry across all
three lane files against the elements arrays recorded in the same JSON
objects:

| Claimed pair | Elements sets | Identical? |
| --- | --- | --- |
| Aave V3 / SparkLend | 17 vs 12, Spark is a proper subset of Aave | correctly labeled elsewhere as subset, not identity |
| ApeX / edgeX (/ Lighter) | differ: Tg vs Gp; Lighter adds Wq, Ad | FALSE |
| Yearn / Beefy (/ CIAN) | Yearn has Wq, Tg, Sr extra | FALSE |
| WBTC / Coinbase / BTCB | six elements each for WBTC and Coinbase, five for BTCB, and no two of the three sets match | FALSE |
| LiquidMesh / KyberSwap | both a single element, Ag | true |
| Binance Wallet / OKX DEX | both two elements, Rf and Ag | true |
| USYC / BUIDL | 8 vs 10 elements, 4 non-overlapping | FALSE |
| Derive / Aevo | differ by one element and term order | FALSE |
| USDT / USD1 | both the same five elements | true |
| USDC / PYUSD | 9 vs 7 elements, USDC has two extra | FALSE |

7 of 10 checkable claims are false; the JSON's own identical_decompositions
field is wrong at the data-generation layer, not just in later prose.

This same false claim then propagates upward, worded as fact, unhedged:

- corpus50/VERDICT.md lines 47-53: "The top three bridges by TVL -- WBTC,
  Coinbase, Binance BTC, $17.8B combined -- decompose to an identical five
  symbols... USDT = USD1, USDC = PYUSD, USYC = BUIDL ... ApeX = edgeX =
  Lighter, Yearn = Beefy = CIAN" (using the equivalence symbol throughout).
- algebra/BRIEF.md lines 77-78: "USDT = USD1, USDC = PYUSD, USYC = BUIDL,
  SparkLend is a subset of Aave V3, and the top three bridges by TVL
  ($17.8B) share an identical five symbols."
- algebra/THEOREMS.md lines 141-142, obligation C5: "USDT = USD1, USDC =
  PYUSD, USYC = BUIDL, and the top three bridges by TVL share five symbols."
- algebra/PLAIN-ENGLISH.md lines 103-105: "The biggest bridges are
  indistinguishable from each other" -- a strengthening beyond even "share
  five symbols" into full indistinguishability, which is false: WBTC and
  Coinbase each carry a sixth, non-shared differentiator symbol (Tg vs Up).

Only the USDT-USD1 instance (and the two order-flow pairs) survive scrutiny;
these happen to be the ones later treated as load-bearing theorems (P6/P7 in
the ledger, which I did NOT find fault with -- the USDT/USD1 claim is real
and reproducible). But the bridge and USDC/PYUSD and USYC/BUIDL claims, used
in the same breath and with the same rhetorical weight, are not. A reader
cannot tell from any of these four documents which equivalence claims are
real and which are corpus artifacts nobody checked against the elements
field sitting right next to the claim.

Severity: critical. This is calibration failure mode #5 exactly ("repeated
the top three bridges decompose identically from an agent's prose -- 7 of
10 such claims were false against the actual data"), and it is still
standing, unretracted, in four separate documents including one
(THEOREMS.md, obligation C5) that is cited as a mandatory acceptance
criterion.

---

## SEVERITY 2 -- HIGH

### F3. C3 target -- retraction is thorough in the newest documents but was never back-ported to REQUIREMENTS.md, which still states the retracted claim as fact

atlas.tex lines 329-338, Remark (rem:retraction):

> "An earlier measurement on a 10-element sublattice appeared to derive the
> atomic-scope prohibition on seed Fl,Xm without being told it. That reading
> was wrong, in two ways. First, the exclusion is one unit-propagation step
> from a prohibition already written by hand: the procedure was re-reading
> its own input. Second, the apparently strong scores on seeds such as Pl
> and Uc were an artefact of vocabulary truncation..."

formal/v2/FINDINGS-V2.md lines 899-901 (F10) independently confirms this in
detail: "Every one of the 61 exclusions is produced by a flat negative ban
that is literally a clause of the input... KK deriving it on seed Fl,Xm is
one unit propagation away from reading it."

But algebra/REQUIREMENTS.md lines 44-49 (R1b), unedited since before this
retraction was written (file mtimes: REQUIREMENTS.md 1785880334, older than
FINDINGS-V2.md 1785881571, older than atlas.tex 1785882871), still says,
presented as a current requirement on any candidate foundation:

> "on seed Fl,Xm the KK upper bound excludes Xf, Rl, Of -- which is X21,
> derived search-free rather than found by enumerating 5,038,954 subsets."

This is precisely the retracted reading, word for word (same seed, same
excluded set, same "search-free" framing), still asserted as settled fact in
a document explicitly designed to be "a fixed standard" candidates are
judged against. No note, no strikethrough, no forward pointer to the
retraction. Anyone auditing a candidate foundation against R1b today would
judge it by a standard the project's own newest work says is wrong twice
over: a circular derivation, plus a truncation artifact.

### F4. C5 target -- THEOREM-LEDGER.md's own PROVED entry is contradicted by its own REFUTED entry, uncorrected

THEOREM-LEDGER.md line 19 (PROVED table), P2:

> "The definite fragment (8 laws) has height 1 ... a completely distributive
> lattice with join = Cn(union), meet = intersection. | OP-LOG | machine-
> checked over 3,140 closed sets; assoc/comm/idem/absorption/distributivity
> all hold"

THEOREM-LEDGER.md line 43 (REFUTED/DEAD table), R9, in the same file:

> "OP-LOG's definite fragment is 8 rules over 3,140 closed sets | It is 16
> rules, and two of OP-LOG's eight (Rs to Vl, Ad to Li) appear in no law
> text. The lattice has about 2.2 times ten to the 15 elements; 3,140 was a
> corpus sample, not the lattice. Height-1 itself is independently
> confirmed."

R9 directly refutes the premise P2 is built on: the rule count, and --
critically -- whether "3,140 closed sets" is anything close to exhaustive
for a lattice later admitted to be many orders of magnitude larger. P2
remains listed under PROVED with its original, now-contradicted evidence
line, unedited. THEOREMS.md's S2 handles the same underlying claim more
carefully (marked CONTESTED, not proved), so the correct, hedged status
exists elsewhere in the project -- it just never overwrote P2. This is
exactly C5's question, "are any marked PROVED that are only measured?", with
an added twist: this one is marked PROVED and separately refuted, in the
same ledger, and neither entry references the other.

---

## SEVERITY 3 -- MEDIUM

### F5. C1/C4 targets -- the paper's self-declared "more serious finding" is absent from the ledger, the model doc, and the plain-English doc

atlas.tex line 311 introduces the section "The positive theory does not
bind" by saying "This section concerns the content, and is the more serious
finding." meas:ablation58 (lines 321-327): the 79 positive
closure/warrant/grounding clauses exclude zero elements across all 72 real
protocol completions; all 61 real exclusions trace to two hand-written
prohibitions.

I searched THEOREM-LEDGER.md, MODEL.md, and PLAIN-ENGLISH.md for any mention
of this result, "vacuous," "completion lattice," or "ablation58": zero hits
in all three. The ledger's own charter (THEOREM-LEDGER.md lines 5-6) says
"this file is the running score and nothing may be dropped from it," yet it
is missing this result plus the Structure theorem (invariance, the Tarski
complete-lattice corollary), the convex-geometry section, and the entire
Repair/blocker-duality section -- i.e. most of the paper's back half. This
looks like simple staleness (the ledger predates these sections
chronologically) rather than a contradiction, but it means the ledger
currently fails its own stated invariant.

Compounding this: MODEL.md section 6 ("the visualization") and
PLAIN-ENGLISH.md ("the second half is the valuable one... what am I
carrying that nothing justifies?") continue to promote warrant's value in
unqualified terms without the caveat that, per the newest measurement,
warrant's completion-constraining power (as opposed to its discrimination
power, a different, real, and correctly-reported 1.8x figure) is empirically
nil on real protocols at full scale. These are genuinely different
questions -- discriminate a whole candidate versus constrain a partial one
-- so this is not a direct contradiction, but a lay reader of
PLAIN-ENGLISH.md, the document explicitly aimed at non-technical readers,
has no way to learn that the "positive theory" half of the model does not do
the completion/repair work the same document implies it might.

### F6. Checked and found NOT to be violations, for calibration

- C1, complete-lattice scope creep: not found. atlas.tex's cor:tarski result
  is correctly and repeatedly scoped away from the full admissible set in the
  same section, and FINDINGS-V2.md is equally careful. The new
  convex-geometry conjecture is also explicitly scoped away from the full
  atlas.
- Warrant contribution, 1.8x vs 4.46x vs 10.83x: consistently corrected
  across MODEL.md, THEOREM-LEDGER.md (P3), PLAIN-ENGLISH.md, and
  FINDINGS-V2.md. This is calibration item 3 and it is not still live -- the
  correction is uniform and appears to have already been applied everywhere
  I checked.
- Parser-bug retraction, calibration item 1, and "two implementations
  agree," item 2: both correctly and consistently recorded, R4, R5, P14,
  with no stale re-assertions found elsewhere.
- Terra / USDT-USD1 party-sort claims, P5 through P8: FINDINGS-V2.md is
  explicitly honest about scope, stating plainly that the instance-level
  backs edges are hand-entered and there is no asset-annotated corpus to
  derive them from, and PLAIN-ENGLISH.md / MODEL.md do not overclaim beyond
  that scope. No violation found here despite this being adjacent to
  calibration item 6's territory.

---

## Summary ranking

1. F1, critical -- atlas.tex's Repair section treats a council-refuted,
   not-in-the-table hazard, the flat Fl,Xm pair, as one of only three
   genuine hazard-table entries, in a Theorem-and-Corollary worked example.
2. F2, critical -- "identical decomposition" claims (bridges, USDC/PYUSD,
   USYC/BUIDL, ApeX/edgeX/Lighter, Yearn/Beefy/CIAN) are false against the
   corpus's own elements data in 7 of 10 checked instances, and still stand
   unhedged in VERDICT.md, BRIEF.md, THEOREMS.md (a mandatory obligation,
   C5), and partially in PLAIN-ENGLISH.md.
3. F3, high -- REQUIREMENTS.md still states the retracted "derived
   search-free" claim as a live requirement; the retraction in atlas.tex and
   FINDINGS-V2.md never propagated back.
4. F4, high -- THEOREM-LEDGER.md's P2, marked PROVED, is contradicted by its
   own R9 entry, marked REFUTED; never reconciled.
5. F5, medium -- the ledger, model doc, and plain-English doc omit the
   paper's own "more serious finding" (the positive theory excludes
   nothing), violating the ledger's "nothing may be dropped" charter.
