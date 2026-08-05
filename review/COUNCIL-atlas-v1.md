# Council pass 1 — GPT-5.6 Sol on the category atlas and the constructions section

Cold read, read-only sandbox, high reasoning. Auditor had node, quint, Lean 4 with
mathlib, python and git, and was instructed to demand evidence and to run rather
than reason. Target: sec:construct and sec:cat:* only. Exit 0.

---

# Cold-read audit

One BLOCKING defect, eight MAJOR defects, three MINOR defects, and no NITs. No files were edited.

## BLOCKING

### 1. The checker and all category arithmetic use a different admissibility predicate from the paper’s corrected algebra

**Files:** [paper/atlas.tex:1081](/root/defiformal/paper/atlas.tex:1081), [paper/atlas.tex:1122](/root/defiformal/paper/atlas.tex:1122), [formal/v3/construct.mjs:27](/root/defiformal/formal/v3/construct.mjs:27), [formal/v3/construct.mjs:35](/root/defiformal/formal/v3/construct.mjs:35), [formal/v2/tables.mjs:79](/root/defiformal/formal/v2/tables.mjs:79), [formal/v2/tables.mjs:127](/root/defiformal/formal/v2/tables.mjs:127), [formal/v2/tables.mjs:150](/root/defiformal/formal/v2/tables.mjs:150)

**Text/code at issue:**

> “\(X\) is sound when \(X\in\Adm\).”

> “\(3{,}930\) are sound … exactly \(60\) … are minimal.”

```js
// construct.mjs
import { PARSED_NEW, ... } from "../v2/tables.mjs";
export const openRequirements = X => PARSED_NEW.flatMap(...)
```

Against:

```js
// tables.mjs
export function admissible(S, parts = false) {
  const f = gammaOpen(S), ...
}
export const gammaOpen = S => {
  for (const [id, subs, terms] of LSTAR) ...
}
```

**What is wrong:** `formal/v2/tables.mjs::admissible`, the repository’s exported corrected predicate, uses `LSTAR`. The construction checker instead reimplements closure using raw `PARSED_NEW`. These are not extensionally equivalent. Consequently:

- the published \(3{,}930/60\) construction counts are for the checker’s private predicate, not \(\Adm\);
- the correct `tables.mjs::admissible` counts on the stated 16-element universe are \(4{,}545\) sound and \(88\) minimal;
- all 88 have size 6 and distinct canonical forms;
- the 109 category checks also import the checker predicate, so passing them does not cure the fork;
- under `tables.mjs::admissible`, the category sampling changes from 61 eligible protocols and 185 failures to 65 and 201. Direct target claims such as “Fluid satisfies,” “Aster is rejected,” and “only Derive satisfies” change truth value.

**Evidence run:**

```text
$ node --input-type=module [exact enumeration of all 65,536 U16 subsets]
{
  universe: 'Sh,Ix,Rb,Pl,Ct,Ex,Tp,At,Li,Ad,Sl,Bs,Wq,Rd,Im,Ps',
  subsets: 65536,
  Lstar: { sound: 4545, minimal: 88, sizes: [ 6 ], distinctCanonical: 88 },
  checker: { sound: 3930, minimal: 60 },
  predicateDisagreements: { LstarOnly: 657, checkerOnly: 18 }
}
```

Concrete disagreements:

```text
Sh,Pl,Ct,Ex,Li
  LSTAR: false
  checker: true

Rb,Pl,Ct,Ex,Ad
  LSTAR: true
  checker: false
```

Recomputing the category composition universe with the exported predicate:

```text
{
  eligible: 65,
  pairs: 2080,
  failures: 201,
  within: 1,
  across: 200,
  FlEndpoint: 189
}
Fluid       REJECTED
Aster       13 incompatible partners
Rysk V12    0 incompatible partners
Hegic       0 incompatible partners
Aevo        7 incompatible partners
```

The independent Quint finite model agreed:

```text
$ quint run /dev/stdin --main=CountAudit --step=auditStep \
    --invariant=lstarHasPaperCounts --max-samples=100000 \
    --max-steps=1 --backend=rust --verbosity=1
[violation] ... seed 0xcabbdc5a0ea17c3d

$ quint run /dev/stdin --main=CountAudit --step=auditStep \
    --invariant=lstarHasRecomputedCounts ...
[ok] No violation found ... seed 0x10fd205e6156af7e
```

The successful Quint run is supporting evidence rather than symbolic proof; the independent Node loop exhaustively evaluated all 65,536 sets. `quint verify` could not start because it attempted to create a temporary file under the read-only `/tmp`.

The self-test does not enumerate the \(3{,}930/60\) measurement:

```text
$ node formal/v3/selftest.mjs
22 passed, 0 failed
```

Inspection of [formal/v3/selftest.mjs:13](/root/defiformal/formal/v3/selftest.mjs:13)–[76](/root/defiformal/formal/v3/selftest.mjs:76) confirms that neither count is asserted.

**Fix:** make `construct.mjs`, `claims.mjs`, and the pair harness call the single exported `tables.mjs::admissible` implementation. Add exact regression assertions for 4,545 and 88. Then regenerate every rejection, compatibility, construction, and category statement. If raw `PARSED_NEW` is intended instead, the paper must redefine \(\Adm\) accordingly and reconcile that reversal with the corrected \(L^\star\) formal model.

## MAJOR

### 2. The category boundaries are editorial, contrary to the claimed sampling frame

**Files:** [paper/atlas.tex:1171](/root/defiformal/paper/atlas.tex:1171), [paper/atlas.tex:1699](/root/defiformal/paper/atlas.tex:1699), [corpus50/lanes/lane1-dex-lending-cdp-lsd.json:3](/root/defiformal/corpus50/lanes/lane1-dex-lending-cdp-lsd.json:3), [corpus50/lanes/lane2-perps-yield-bridges-intents.json:3](/root/defiformal/corpus50/lanes/lane2-perps-yield-bridges-intents.json:3)

**Sentence at issue:**

> “They are DefiLlama’s and rwa.xyz’s own tags.”

This is contradicted both by the research record and by the target itself:

> “The category is the residual of the sampling frame … together with two large protocols its lane could not file elsewhere.”

The lane records explicitly merge `Liquid Staking`, `Restaking`, and `Liquid Restaking`; merge `Yield` and `Yield Aggregator`; add Ethena’s `Basis Trading` classification to CDP; and create the residual prediction/other category.

This matters because the paper’s 182-cross/3-within statistic is conditional on these editorial boundaries.

**Fix:** publish the source-tag-to-paper-category mapping, call the partition editorial, and recompute within/across failures under native tags and plausible alternative placements.

---

### 3. Protocol-behaviour claims have no claim-level citations or access dates

**Files:** [paper/atlas.tex:1271](/root/defiformal/paper/atlas.tex:1271), [paper/atlas.tex:1463](/root/defiformal/paper/atlas.tex:1463), [paper/atlas.tex:1604](/root/defiformal/paper/atlas.tex:1604)

Examples include:

> “Uniswap v4, PancakeSwap Infinity and Fluid each build their differentiation on [hooks].”

> “Steakhouse … [has] a named party with discretionary authority over other people’s deposits.”

> “No obligor … no claim perfection or bankruptcy remoteness …”

These are empirical protocol claims, not consequences of the algebra. There is no `\cite`, URL, or access-date marker anywhere in the twelve category sections.

**Evidence run:**

```text
$ sed -n '1237,1735p' paper/atlas.tex |
    rg '\cite|https?://|20[0-9]{2}-[0-9]{2}-[0-9]{2}'
NO citation, URL, or access-date marker in category sections
```

The underlying residue strings are not a traceable evidence ledger either:

```text
$ python3 [scan corpus50/lanes/*.json residue entries]
{'residue_items': 324, 'with_url': 0, 'with_access_date': 2}
```

The lane-level `source` fields provide generic websites and snapshot dates, but not which source supports each behavioral assertion.

**Fix:** add per-claim citations with access dates, or a protocol evidence ledger mapping every element/residue assertion to a URL, accessed date, and quoted or pinpointed source, then cite that ledger from each section.

---

### 4. Proposition `prop:neither` contains a non sequitur about search

**File:** [paper/atlas.tex:1094](/root/defiformal/paper/atlas.tex:1094)

**Sentence at issue:**

> “\(\Adm\) is closed neither upward nor downward, so a minimal construction cannot be found by growing from below or by shrinking from above.”

The two non-closure facts do not imply impossibility of either search direction. They only invalidate a greedy algorithm that assumes admissibility is preserved monotonically. Increasing-cardinality enumeration, backtracking growth, or deletion search that rechecks admissibility can still find minimal constructions.

Both witnesses themselves are correct under the exported predicate:

```text
Cp,Sh,Fl       true
Cp,Sh,Fl,Pl    false; 3 open terms; X2
Aw,Xf,At       true
Aw,Xf          false; X19*
```

Quint independently violated both closure invariants over 100,000 samples:

```text
upwardClosureWitness   [violation] seed 0x9a600916c141963a
downwardClosureWitness [violation] seed 0xb6659ecf89f524f8
```

Thus the premise is established; the algorithmic conclusion is not.

**Fix:** say that no *monotonicity-based greedy search without backtracking* is justified. Do not state search impossibility.

---

### 5. The proof confuses a clutter with its downward-closed model class

**File:** [paper/atlas.tex:1105](/root/defiformal/paper/atlas.tex:1105), fixed definition at [paper/atlas.tex:218](/root/defiformal/paper/atlas.tex:218)

**Sentence at issue:**

> “the listed clutter \(\Haz\) alone is downward closed, being purely negative.”

By definition, \(\Haz\) is an antichain of minimal forbidden sets. It is not downward closed: a proper subset of a listed prohibition generally is not itself a listed prohibition. What is downward closed is the model class \(\mathcal H=\mathcal M(\Haz)\).

Quint directly refuted downward closure of the clutter and accepted the corresponding model-class predicate:

```text
clutterItselfDownward [violation] seed 0x2811c4d39494eaee
x2ModelClassDownward  [ok] No violation found, 100000 samples
```

The latter invariant internally quantified over the finite powerset of the X2 universe, but the successful random run is still reported as exploration, not symbolic proof.

**Fix:** replace `\Haz` with `\mathcal H=\mathcal M(\Haz)`.

---

### 6. `cor:notthe` overgeneralizes one restricted finite instance

**File:** [paper/atlas.tex:1127](/root/defiformal/paper/atlas.tex:1127)

**Sentences at issue:**

> “There is no such thing as the construction of an application.”

> “the alternatives are exactly the choices left open by the disjunctive terms”

The measurement establishes non-uniqueness for one pooled-lending obligation set. It proves that construction is not unique *in general*; it does not prove that every application has multiple constructions. “Application” is not a formal type in the Quint model, so the universal reading cannot even be stated with the supplied formal vocabulary.

The local universe is adequately pinned down: the six displayed alternative sets contain exactly the listed 16 elements. The defect is extrapolation, not an unstated value of 16.

The “exactly the choices” rationale is also false under the definitions. A construction may contain an element outside every obligation alternative, and minimality does not require every element to be justified. Exact search found minimal constructions containing outside support elements, for example:

```text
Cp,Ct,Li,Pl,Sh,Tp,Wq
Cp,Ct,Ix,Li,Pl,Tp,Wq
Cp,Ct,Li,Pl,Rb,Tp,Wq
Ad,Cp,Ct,Pl,Sh,Tp,Wq
```

These do not invalidate the count “of those” 16-element subsets, but they invalidate treating that restricted list as all minimal constructions allowed by Definitions 7–8.

**Fix:** state: “There is no unique construction in general; this \(U\)-restricted pooled-lending instance has 88 under \(L^\star\).” Either require every element of a construction to be justified, or explicitly distinguish obligation alternatives from admissibility-support elements.

---

### 7. The claimed capital/resolution relationship is not measured

**Files:** [paper/atlas.tex:1458](/root/defiformal/paper/atlas.tex:1458), [paper/atlas.tex:1693](/root/defiformal/paper/atlas.tex:1693), [paper/atlas.tex:1738](/root/defiformal/paper/atlas.tex:1738)

**Sentences at issue:**

> “the category that holds the third largest capital”

> “the vocabulary’s resolution is inversely correlated with capital”

> “The footprint is smallest where the capital is largest”

No definition of “resolution,” comparable capital variable, universe, or correlation statistic is supplied. The corpus mixes TVL, circulating supply, and several kinds of volume. Line 1740 then mixes category footprint with mean per-protocol set size.

`claims.mjs` has no capital or correlation computation.

**Fix:** define a resolution statistic and one comparable capital measure, publish the twelve observations, report the correlation and sensitivity to alternative metrics. Otherwise label these as qualitative conjectures or delete them.

---

### 8. The validator admits evidence-defective and structurally malformed specifications

**Files:** [formal/v3/validate.mjs:12](/root/defiformal/formal/v3/validate.mjs:12), [formal/v3/validate.mjs:37](/root/defiformal/formal/v3/validate.mjs:37), [formal/v3/construct.mjs:188](/root/defiformal/formal/v3/construct.mjs:188)

Access date and research-record source are warnings, while `construct.mjs` discards all warnings. Category is only checked as a nonempty string. Obligation IDs need not be strings, and duplicate alternatives inside an obligation are accepted.

**Evidence run:**

```text
$ node --input-type=module -e '[validate and verify a malformed spec]'
{
  "app": "Demo",
  "ok": true,
  "err": [],
  "warn": [
    "obligation 17: evidence has no access date",
    "only 1 obligations: a top-five application should state more of what it does",
    "no source field pointing at the research record"
  ]
}
{
  "verdict": "COMPLETE",
  "covered": 1
}
```

That accepted spec also used category `made-up-category`, numeric ID `17`, and alternatives `["Sh","Sh"]`.

**Fix:** promote missing access date and missing research-record source to errors; validate category and ID types; reject duplicate alternatives; and make the construction CLI print or reject every validator warning.

---

### 9. The Lean formalization is weaker than the prose claim

**Files:** [paper/atlas.tex:894](/root/defiformal/paper/atlas.tex:894), [paper/atlas.tex:759](/root/defiformal/paper/atlas.tex:759), [lean/Defialgebra/ConvexGeometry.lean:505](/root/defiformal/lean/Defialgebra/ConvexGeometry.lean:505), [lean/Defialgebra/Polarity.lean:195](/root/defiformal/lean/Defialgebra/Polarity.lean:195)

**Sentence at issue:**

> “Lemma polarity, Theorem closure, Corollary lattice, Theorem convex and Theorem excomp are formalised in Lean 4.”

The main algebraic identity of `thm:excomp` is formalized, but the theorem’s claim that it is “computable in time linear in \(|ex(A)|+|ex(B)|\)” is not. The Lean declaration is an equality of `Finset`s; it contains no algorithm, cost model, or complexity bound.

Likewise, the negative halves of `thm:closure` are generic `Fin 3` counterexamples showing that dual-Horn and purely negative classes *need not* have the opposite closure property. They do not formalize that the paper’s actual \(\mathcal R,\mathcal W,\mathcal H\) fail those properties. The prose’s caveat that the atlas is not formalized partially acknowledges this, but it is incompatible with claiming the entire named theorem is formalized.

The no-`sorry` and axiom claims are correct:

```text
$ export PATH=/root/.elan/bin:$PATH
$ cd lean
$ lake build
Build completed successfully (734 jobs).

$ lake env lean Axioms.lean
'Defialgebra.ConvexGeometry.ex_reachCl_union_ex'
  depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.thm_convex'
  depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.completeLattice'
  depends on axioms: [propext, Classical.choice, Quot.sound]
```

A source scan found no `sorry`, `admit`, or custom `axiom` declaration in `lean/Defialgebra`.

**Fix:** qualify the section to list precisely the formalized fragments, or formalize the complexity claim and the instance-specific negative closure witnesses.

## MINOR

### 10. Yield’s “second smallest” ranking is false

**Files:** [paper/atlas.tex:1458](/root/defiformal/paper/atlas.tex:1458), [formal/v3/claims.mjs:153](/root/defiformal/formal/v3/claims.mjs:153)

**Sentence at issue:**

> “mean \(8.0\) — the second smallest of the twelve”

The mean 8.0 is correct; its rank is not. Five categories have smaller means:

```text
2.750 intents
5.571 bridges
6.400 reserve-backed stablecoins
6.400 prediction
7.400 spot exchange
8.000 yield
```

Yield is sixth-smallest, treating the tie at 6.4 conventionally. `claims.mjs` checks only `mean == 8.0`, which is why all 109 checks pass.

**Fix:** replace “second” with “sixth,” or remove the rank; add a rank assertion to the harness.

---

### 11. The claim that every category reports canonical-form behavior is false

**File:** [paper/atlas.tex:1179](/root/defiformal/paper/atlas.tex:1179)

**Sentence at issue:**

> “Each section reports the same four things … what the canonical form … does to it”

Yield, bridges, RWA, options, and prediction do not provide a category-level canonical-form report. Yet the computation contains material facts: Pendle/Huma/Steakhouse compress in yield; Across compresses among bridges; Maple Finance in RWA; four option protocols compress; and Polymarket plus Steakhouse Risk Curators compress in prediction.

**Fix:** add a uniform canonical-form row to every category, including an explicit “none compress” where applicable.

---

### 12. No sensitivity analysis is reported for candidate-status elements

**Files:** [paper/atlas.tex:1179](/root/defiformal/paper/atlas.tex:1179), [paper/atlas.tex:1704](/root/defiformal/paper/atlas.tex:1704)

Footprint and exclusivity comparisons treat candidate elements as ordinary settled vocabulary, even where the prose mentions their candidate status. Removing the ten candidate symbols leaves pair failures unchanged but materially changes most footprints:

```text
candidate symbols: Dp,Fd,Fz,Gs,Of,Rl,Rs,Sd,Sv,Vl

as encoded:
  used=54
  footprints: DEX 16, CDP 25, LSD 19, bridge 17,
              RWA 24, options 20, fiat 10, prediction 20

candidate symbols removed:
  used=45
  footprints: DEX 15, CDP 22, LSD 16, bridge 15,
              RWA 21, options 19, fiat 8, prediction 16
```

**Fix:** report a core-only/candidate-inclusive sensitivity table, especially before interpreting cross-category footprint differences.

## NIT

No NIT findings. The defects found are substantive.

## Checks that survived attack

The supplied raw-predicate harnesses are internally reproducible:

```text
$ node formal/v2/pairs.mjs
61/72
1830 pairs
185 failures
3 within, 182 across

$ node formal/v2/canonical.mjs
15 arcs
29/72 compressing

$ node formal/v2/antiexchange.mjs
22585 anti-exchange premises
VIOLATIONS: 0
1696 unique minimal generators; 0 non-unique

$ node formal/v3/claims.mjs -v
109 claims verified, 0 failed
```

Independent raw-predicate recomputation confirmed the advertised 180/5 split:

```text
eligible=61 pairs=1830 failures=185 Fl_endpoint=180 non_Fl=5
WBETH + Spark Savings: X19*
EigenLayer + Spark Savings: X19*
Spark Savings + DFlow: X19*
Spark Savings + Kalshi: X19*
Spark Savings + Polymarket: X19*
```

All reported category footprint sizes, exclusive elements, common cores, per-protocol partner counts, and residue counts were reproduced from the lane arrays under that same raw predicate. The options/prediction qualification of `meas:nosafe` is correct under it.

Conditional on repairing the predicate fork, `construct.mjs`’s deletion-local minimality test uses the right baseline. Its compositional search exhausts distinct corpus combinations through \(k\le3\), and the CLI explicitly reports that bound; it does not claim absence beyond three.

## Verdict

(A) and (B) are not sound enough to support sixty application subsections. The central certification artefact computes a different \(\Adm\) from the corrected formal predicate, changing the headline construction count from \(3{,}930/60\) to \(4{,}545/88\) and changing multiple category admissions and partner counts. Even after that blocker is repaired, the category taxonomy is misdescribed, protocol claims lack traceable evidence, the construction corollary overgeneralizes its one instance, and the Lean claim exceeds what was formalized. Building sixty subsections now would multiply an identified predicate error and an unauditable evidence chain.
tokens used
413,449
# Cold-read audit

One BLOCKING defect, eight MAJOR defects, three MINOR defects, and no NITs. No files were edited.

## BLOCKING

### 1. The checker and all category arithmetic use a different admissibility predicate from the paper’s corrected algebra

**Files:** [paper/atlas.tex:1081](/root/defiformal/paper/atlas.tex:1081), [paper/atlas.tex:1122](/root/defiformal/paper/atlas.tex:1122), [formal/v3/construct.mjs:27](/root/defiformal/formal/v3/construct.mjs:27), [formal/v3/construct.mjs:35](/root/defiformal/formal/v3/construct.mjs:35), [formal/v2/tables.mjs:79](/root/defiformal/formal/v2/tables.mjs:79), [formal/v2/tables.mjs:127](/root/defiformal/formal/v2/tables.mjs:127), [formal/v2/tables.mjs:150](/root/defiformal/formal/v2/tables.mjs:150)

**Text/code at issue:**

> “\(X\) is sound when \(X\in\Adm\).”

> “\(3{,}930\) are sound … exactly \(60\) … are minimal.”

```js
// construct.mjs
import { PARSED_NEW, ... } from "../v2/tables.mjs";
export const openRequirements = X => PARSED_NEW.flatMap(...)
```

Against:

```js
// tables.mjs
export function admissible(S, parts = false) {
  const f = gammaOpen(S), ...
}
export const gammaOpen = S => {
  for (const [id, subs, terms] of LSTAR) ...
}
```

**What is wrong:** `formal/v2/tables.mjs::admissible`, the repository’s exported corrected predicate, uses `LSTAR`. The construction checker instead reimplements closure using raw `PARSED_NEW`. These are not extensionally equivalent. Consequently:

- the published \(3{,}930/60\) construction counts are for the checker’s private predicate, not \(\Adm\);
- the correct `tables.mjs::admissible` counts on the stated 16-element universe are \(4{,}545\) sound and \(88\) minimal;
- all 88 have size 6 and distinct canonical forms;
- the 109 category checks also import the checker predicate, so passing them does not cure the fork;
- under `tables.mjs::admissible`, the category sampling changes from 61 eligible protocols and 185 failures to 65 and 201. Direct target claims such as “Fluid satisfies,” “Aster is rejected,” and “only Derive satisfies” change truth value.

**Evidence run:**

```text
$ node --input-type=module [exact enumeration of all 65,536 U16 subsets]
{
  universe: 'Sh,Ix,Rb,Pl,Ct,Ex,Tp,At,Li,Ad,Sl,Bs,Wq,Rd,Im,Ps',
  subsets: 65536,
  Lstar: { sound: 4545, minimal: 88, sizes: [ 6 ], distinctCanonical: 88 },
  checker: { sound: 3930, minimal: 60 },
  predicateDisagreements: { LstarOnly: 657, checkerOnly: 18 }
}
```

Concrete disagreements:

```text
Sh,Pl,Ct,Ex,Li
  LSTAR: false
  checker: true

Rb,Pl,Ct,Ex,Ad
  LSTAR: true
  checker: false
```

Recomputing the category composition universe with the exported predicate:

```text
{
  eligible: 65,
  pairs: 2080,
  failures: 201,
  within: 1,
  across: 200,
  FlEndpoint: 189
}
Fluid       REJECTED
Aster       13 incompatible partners
Rysk V12    0 incompatible partners
Hegic       0 incompatible partners
Aevo        7 incompatible partners
```

The independent Quint finite model agreed:

```text
$ quint run /dev/stdin --main=CountAudit --step=auditStep \
    --invariant=lstarHasPaperCounts --max-samples=100000 \
    --max-steps=1 --backend=rust --verbosity=1
[violation] ... seed 0xcabbdc5a0ea17c3d

$ quint run /dev/stdin --main=CountAudit --step=auditStep \
    --invariant=lstarHasRecomputedCounts ...
[ok] No violation found ... seed 0x10fd205e6156af7e
```

The successful Quint run is supporting evidence rather than symbolic proof; the independent Node loop exhaustively evaluated all 65,536 sets. `quint verify` could not start because it attempted to create a temporary file under the read-only `/tmp`.

The self-test does not enumerate the \(3{,}930/60\) measurement:

```text
$ node formal/v3/selftest.mjs
22 passed, 0 failed
```

Inspection of [formal/v3/selftest.mjs:13](/root/defiformal/formal/v3/selftest.mjs:13)–[76](/root/defiformal/formal/v3/selftest.mjs:76) confirms that neither count is asserted.

**Fix:** make `construct.mjs`, `claims.mjs`, and the pair harness call the single exported `tables.mjs::admissible` implementation. Add exact regression assertions for 4,545 and 88. Then regenerate every rejection, compatibility, construction, and category statement. If raw `PARSED_NEW` is intended instead, the paper must redefine \(\Adm\) accordingly and reconcile that reversal with the corrected \(L^\star\) formal model.

## MAJOR

### 2. The category boundaries are editorial, contrary to the claimed sampling frame

**Files:** [paper/atlas.tex:1171](/root/defiformal/paper/atlas.tex:1171), [paper/atlas.tex:1699](/root/defiformal/paper/atlas.tex:1699), [corpus50/lanes/lane1-dex-lending-cdp-lsd.json:3](/root/defiformal/corpus50/lanes/lane1-dex-lending-cdp-lsd.json:3), [corpus50/lanes/lane2-perps-yield-bridges-intents.json:3](/root/defiformal/corpus50/lanes/lane2-perps-yield-bridges-intents.json:3)

**Sentence at issue:**

> “They are DefiLlama’s and rwa.xyz’s own tags.”

This is contradicted both by the research record and by the target itself:

> “The category is the residual of the sampling frame … together with two large protocols its lane could not file elsewhere.”

The lane records explicitly merge `Liquid Staking`, `Restaking`, and `Liquid Restaking`; merge `Yield` and `Yield Aggregator`; add Ethena’s `Basis Trading` classification to CDP; and create the residual prediction/other category.

This matters because the paper’s 182-cross/3-within statistic is conditional on these editorial boundaries.

**Fix:** publish the source-tag-to-paper-category mapping, call the partition editorial, and recompute within/across failures under native tags and plausible alternative placements.

---

### 3. Protocol-behaviour claims have no claim-level citations or access dates

**Files:** [paper/atlas.tex:1271](/root/defiformal/paper/atlas.tex:1271), [paper/atlas.tex:1463](/root/defiformal/paper/atlas.tex:1463), [paper/atlas.tex:1604](/root/defiformal/paper/atlas.tex:1604)

Examples include:

> “Uniswap v4, PancakeSwap Infinity and Fluid each build their differentiation on [hooks].”

> “Steakhouse … [has] a named party with discretionary authority over other people’s deposits.”

> “No obligor … no claim perfection or bankruptcy remoteness …”

These are empirical protocol claims, not consequences of the algebra. There is no `\cite`, URL, or access-date marker anywhere in the twelve category sections.

**Evidence run:**

```text
$ sed -n '1237,1735p' paper/atlas.tex |
    rg '\cite|https?://|20[0-9]{2}-[0-9]{2}-[0-9]{2}'
NO citation, URL, or access-date marker in category sections
```

The underlying residue strings are not a traceable evidence ledger either:

```text
$ python3 [scan corpus50/lanes/*.json residue entries]
{'residue_items': 324, 'with_url': 0, 'with_access_date': 2}
```

The lane-level `source` fields provide generic websites and snapshot dates, but not which source supports each behavioral assertion.

**Fix:** add per-claim citations with access dates, or a protocol evidence ledger mapping every element/residue assertion to a URL, accessed date, and quoted or pinpointed source, then cite that ledger from each section.

---

### 4. Proposition `prop:neither` contains a non sequitur about search

**File:** [paper/atlas.tex:1094](/root/defiformal/paper/atlas.tex:1094)

**Sentence at issue:**

> “\(\Adm\) is closed neither upward nor downward, so a minimal construction cannot be found by growing from below or by shrinking from above.”

The two non-closure facts do not imply impossibility of either search direction. They only invalidate a greedy algorithm that assumes admissibility is preserved monotonically. Increasing-cardinality enumeration, backtracking growth, or deletion search that rechecks admissibility can still find minimal constructions.

Both witnesses themselves are correct under the exported predicate:

```text
Cp,Sh,Fl       true
Cp,Sh,Fl,Pl    false; 3 open terms; X2
Aw,Xf,At       true
Aw,Xf          false; X19*
```

Quint independently violated both closure invariants over 100,000 samples:

```text
upwardClosureWitness   [violation] seed 0x9a600916c141963a
downwardClosureWitness [violation] seed 0xb6659ecf89f524f8
```

Thus the premise is established; the algorithmic conclusion is not.

**Fix:** say that no *monotonicity-based greedy search without backtracking* is justified. Do not state search impossibility.

---

### 5. The proof confuses a clutter with its downward-closed model class

**File:** [paper/atlas.tex:1105](/root/defiformal/paper/atlas.tex:1105), fixed definition at [paper/atlas.tex:218](/root/defiformal/paper/atlas.tex:218)

**Sentence at issue:**

> “the listed clutter \(\Haz\) alone is downward closed, being purely negative.”

By definition, \(\Haz\) is an antichain of minimal forbidden sets. It is not downward closed: a proper subset of a listed prohibition generally is not itself a listed prohibition. What is downward closed is the model class \(\mathcal H=\mathcal M(\Haz)\).

Quint directly refuted downward closure of the clutter and accepted the corresponding model-class predicate:

```text
clutterItselfDownward [violation] seed 0x2811c4d39494eaee
x2ModelClassDownward  [ok] No violation found, 100000 samples
```

The latter invariant internally quantified over the finite powerset of the X2 universe, but the successful random run is still reported as exploration, not symbolic proof.

**Fix:** replace `\Haz` with `\mathcal H=\mathcal M(\Haz)`.

---

### 6. `cor:notthe` overgeneralizes one restricted finite instance

**File:** [paper/atlas.tex:1127](/root/defiformal/paper/atlas.tex:1127)

**Sentences at issue:**

> “There is no such thing as the construction of an application.”

> “the alternatives are exactly the choices left open by the disjunctive terms”

The measurement establishes non-uniqueness for one pooled-lending obligation set. It proves that construction is not unique *in general*; it does not prove that every application has multiple constructions. “Application” is not a formal type in the Quint model, so the universal reading cannot even be stated with the supplied formal vocabulary.

The local universe is adequately pinned down: the six displayed alternative sets contain exactly the listed 16 elements. The defect is extrapolation, not an unstated value of 16.

The “exactly the choices” rationale is also false under the definitions. A construction may contain an element outside every obligation alternative, and minimality does not require every element to be justified. Exact search found minimal constructions containing outside support elements, for example:

```text
Cp,Ct,Li,Pl,Sh,Tp,Wq
Cp,Ct,Ix,Li,Pl,Tp,Wq
Cp,Ct,Li,Pl,Rb,Tp,Wq
Ad,Cp,Ct,Pl,Sh,Tp,Wq
```

These do not invalidate the count “of those” 16-element subsets, but they invalidate treating that restricted list as all minimal constructions allowed by Definitions 7–8.

**Fix:** state: “There is no unique construction in general; this \(U\)-restricted pooled-lending instance has 88 under \(L^\star\).” Either require every element of a construction to be justified, or explicitly distinguish obligation alternatives from admissibility-support elements.

---

### 7. The claimed capital/resolution relationship is not measured

**Files:** [paper/atlas.tex:1458](/root/defiformal/paper/atlas.tex:1458), [paper/atlas.tex:1693](/root/defiformal/paper/atlas.tex:1693), [paper/atlas.tex:1738](/root/defiformal/paper/atlas.tex:1738)

**Sentences at issue:**

> “the category that holds the third largest capital”

> “the vocabulary’s resolution is inversely correlated with capital”

> “The footprint is smallest where the capital is largest”

No definition of “resolution,” comparable capital variable, universe, or correlation statistic is supplied. The corpus mixes TVL, circulating supply, and several kinds of volume. Line 1740 then mixes category footprint with mean per-protocol set size.

`claims.mjs` has no capital or correlation computation.

**Fix:** define a resolution statistic and one comparable capital measure, publish the twelve observations, report the correlation and sensitivity to alternative metrics. Otherwise label these as qualitative conjectures or delete them.

---

### 8. The validator admits evidence-defective and structurally malformed specifications

**Files:** [formal/v3/validate.mjs:12](/root/defiformal/formal/v3/validate.mjs:12), [formal/v3/validate.mjs:37](/root/defiformal/formal/v3/validate.mjs:37), [formal/v3/construct.mjs:188](/root/defiformal/formal/v3/construct.mjs:188)

Access date and research-record source are warnings, while `construct.mjs` discards all warnings. Category is only checked as a nonempty string. Obligation IDs need not be strings, and duplicate alternatives inside an obligation are accepted.

**Evidence run:**

```text
$ node --input-type=module -e '[validate and verify a malformed spec]'
{
  "app": "Demo",
  "ok": true,
  "err": [],
  "warn": [
    "obligation 17: evidence has no access date",
    "only 1 obligations: a top-five application should state more of what it does",
    "no source field pointing at the research record"
  ]
}
{
  "verdict": "COMPLETE",
  "covered": 1
}
```

That accepted spec also used category `made-up-category`, numeric ID `17`, and alternatives `["Sh","Sh"]`.

**Fix:** promote missing access date and missing research-record source to errors; validate category and ID types; reject duplicate alternatives; and make the construction CLI print or reject every validator warning.

---

### 9. The Lean formalization is weaker than the prose claim

**Files:** [paper/atlas.tex:894](/root/defiformal/paper/atlas.tex:894), [paper/atlas.tex:759](/root/defiformal/paper/atlas.tex:759), [lean/Defialgebra/ConvexGeometry.lean:505](/root/defiformal/lean/Defialgebra/ConvexGeometry.lean:505), [lean/Defialgebra/Polarity.lean:195](/root/defiformal/lean/Defialgebra/Polarity.lean:195)

**Sentence at issue:**

> “Lemma polarity, Theorem closure, Corollary lattice, Theorem convex and Theorem excomp are formalised in Lean 4.”

The main algebraic identity of `thm:excomp` is formalized, but the theorem’s claim that it is “computable in time linear in \(|ex(A)|+|ex(B)|\)” is not. The Lean declaration is an equality of `Finset`s; it contains no algorithm, cost model, or complexity bound.

Likewise, the negative halves of `thm:closure` are generic `Fin 3` counterexamples showing that dual-Horn and purely negative classes *need not* have the opposite closure property. They do not formalize that the paper’s actual \(\mathcal R,\mathcal W,\mathcal H\) fail those properties. The prose’s caveat that the atlas is not formalized partially acknowledges this, but it is incompatible with claiming the entire named theorem is formalized.

The no-`sorry` and axiom claims are correct:

```text
$ export PATH=/root/.elan/bin:$PATH
$ cd lean
$ lake build
Build completed successfully (734 jobs).

$ lake env lean Axioms.lean
'Defialgebra.ConvexGeometry.ex_reachCl_union_ex'
  depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.thm_convex'
  depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.completeLattice'
  depends on axioms: [propext, Classical.choice, Quot.sound]
```

A source scan found no `sorry`, `admit`, or custom `axiom` declaration in `lean/Defialgebra`.

**Fix:** qualify the section to list precisely the formalized fragments, or formalize the complexity claim and the instance-specific negative closure witnesses.

## MINOR

### 10. Yield’s “second smallest” ranking is false

**Files:** [paper/atlas.tex:1458](/root/defiformal/paper/atlas.tex:1458), [formal/v3/claims.mjs:153](/root/defiformal/formal/v3/claims.mjs:153)

**Sentence at issue:**

> “mean \(8.0\) — the second smallest of the twelve”

The mean 8.0 is correct; its rank is not. Five categories have smaller means:

```text
2.750 intents
5.571 bridges
6.400 reserve-backed stablecoins
6.400 prediction
7.400 spot exchange
8.000 yield
```

Yield is sixth-smallest, treating the tie at 6.4 conventionally. `claims.mjs` checks only `mean == 8.0`, which is why all 109 checks pass.

**Fix:** replace “second” with “sixth,” or remove the rank; add a rank assertion to the harness.

---

### 11. The claim that every category reports canonical-form behavior is false

**File:** [paper/atlas.tex:1179](/root/defiformal/paper/atlas.tex:1179)

**Sentence at issue:**

> “Each section reports the same four things … what the canonical form … does to it”

Yield, bridges, RWA, options, and prediction do not provide a category-level canonical-form report. Yet the computation contains material facts: Pendle/Huma/Steakhouse compress in yield; Across compresses among bridges; Maple Finance in RWA; four option protocols compress; and Polymarket plus Steakhouse Risk Curators compress in prediction.

**Fix:** add a uniform canonical-form row to every category, including an explicit “none compress” where applicable.

---

### 12. No sensitivity analysis is reported for candidate-status elements

**Files:** [paper/atlas.tex:1179](/root/defiformal/paper/atlas.tex:1179), [paper/atlas.tex:1704](/root/defiformal/paper/atlas.tex:1704)

Footprint and exclusivity comparisons treat candidate elements as ordinary settled vocabulary, even where the prose mentions their candidate status. Removing the ten candidate symbols leaves pair failures unchanged but materially changes most footprints:

```text
candidate symbols: Dp,Fd,Fz,Gs,Of,Rl,Rs,Sd,Sv,Vl

as encoded:
  used=54
  footprints: DEX 16, CDP 25, LSD 19, bridge 17,
              RWA 24, options 20, fiat 10, prediction 20

candidate symbols removed:
  used=45
  footprints: DEX 15, CDP 22, LSD 16, bridge 15,
              RWA 21, options 19, fiat 8, prediction 16
```

**Fix:** report a core-only/candidate-inclusive sensitivity table, especially before interpreting cross-category footprint differences.

## NIT

No NIT findings. The defects found are substantive.

## Checks that survived attack

The supplied raw-predicate harnesses are internally reproducible:

```text
$ node formal/v2/pairs.mjs
61/72
1830 pairs
185 failures
3 within, 182 across

$ node formal/v2/canonical.mjs
15 arcs
29/72 compressing

$ node formal/v2/antiexchange.mjs
22585 anti-exchange premises
VIOLATIONS: 0
1696 unique minimal generators; 0 non-unique

$ node formal/v3/claims.mjs -v
109 claims verified, 0 failed
```

Independent raw-predicate recomputation confirmed the advertised 180/5 split:

```text
eligible=61 pairs=1830 failures=185 Fl_endpoint=180 non_Fl=5
WBETH + Spark Savings: X19*
EigenLayer + Spark Savings: X19*
Spark Savings + DFlow: X19*
Spark Savings + Kalshi: X19*
Spark Savings + Polymarket: X19*
```

All reported category footprint sizes, exclusive elements, common cores, per-protocol partner counts, and residue counts were reproduced from the lane arrays under that same raw predicate. The options/prediction qualification of `meas:nosafe` is correct under it.

Conditional on repairing the predicate fork, `construct.mjs`’s deletion-local minimality test uses the right baseline. Its compositional search exhausts distinct corpus combinations through \(k\le3\), and the CLI explicitly reports that bound; it does not claim absence beyond three.

## Verdict

(A) and (B) are not sound enough to support sixty application subsections. The central certification artefact computes a different \(\Adm\) from the corrected formal predicate, changing the headline construction count from \(3{,}930/60\) to \(4{,}545/88\) and changing multiple category admissions and partner counts. Even after that blocker is repaired, the category taxonomy is misdescribed, protocol claims lack traceable evidence, the construction corollary overgeneralizes its one instance, and the Lean claim exceeds what was formalized. Building sixty subsections now would multiply an identified predicate error and an unauditable evidence chain.
