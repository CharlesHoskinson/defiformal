# Referee B — report on *An Algebra of Mechanism Composition*

**Remit:** reproduce the numbers; check that claims match evidence.
**Method:** every figure below was re-derived either by rerunning the authors' scripts or by an
independent reimplementation reading `viz/src/data.ts` and `corpus50/lanes/*.json` directly
(`/tmp/ref.py`, `/tmp/lstar.py`, written for this review and not derived from `formal/v2/tables.mjs`).
Lean was rebuilt from scratch and `#print axioms` run on every declaration.

**Recommendation: major revision.**

---

## A. What reproduces exactly

These are confirmations and they matter. I re-derived each independently.

| Item | Claim | Re-derived | Verdict |
|---|---|---|---|
| `meas:arity` | 93 clauses, widest 34 literals, 20.4% bijunctive | 93 clauses; width histogram peaks 27(×21) and 34(×1); 19/93 = 20.43% | **exact** |
| `meas:closureprops` | "Exhaustively over all 179,864,061 pairs", 68,058 / 0 | pool = 18,966 ℛ-members of size ≤3; C(18966,2)+18966 = 179,864,061 exactly; genuinely enumerative | **exact, and the "exhaustive" label is honest** |
| `meas:pairs` | 61 of 72; 1,830 pairs; 1,645 (90%); 185 fail; all from a conditional prohibition; 3 also arm a hazard row | 61/72; 1,830 = C(61,2); 1,645 (89.9%); 185; attribution `bansCond` 182, `bansCond+listedHaz` 3 | **exact** |
| `prop:crosscat` | 182 cross-category, 3 same | 182 / 3 | **exact** |
| `prop:hostile` | Uniswap, PancakeSwap 31; Aave, Morpho, SparkLend 26; CIAN, CoW 23; Spark Savings 12 | all eight identical | **exact** |
| `ex:uniaave` | Uniswap ⊇{Cp,Cl,Fl}, Aave ⊇{Pl,Cd,Fl}, union ⊇ X2, neither alone | verified; also verified under the *disjunctive* reading of X2 | **exact** |
| `prop:fibres` | 4 collision classes, unchanged by compression | USDT/USD1, LiquidMesh/KyberSwap, Binance Wallet/OKX DEX, Jupiter/1inch; 4 groups before and after | **exact** |
| `ex:comp` | ex(Aave)=16, ex(Uniswap)=7, 38 elements untouched | 16, 7; union = 20 distinct; 58−20 = 38 | **exact** |
| `meas:access` | four 16-element grounds, 4,580 admissible, 20 inaccessible, witness {Ex,Op} | 240+1488+1079+1773 = 4,580; 1+1+1+17 = 20; witness confirmed; exhaustive over 2¹⁶ per ground | **exact** |
| `meas:clutter` | 20 rows; exactly one (X2) a positive element set; nine name no element; one antichain failure | 20 rows; one eligible (X2); nine with no named element (X3,X5,X6,X7,X8,X12,X14,X16,X17); {Uc} ⊂ {At,Aw,Uc} is the X11b/X11a containment | **exact** |
| Preliminaries | \|ℰ\|=58, \|𝒲\|=27, 72 protocols, 12 categories | 59 syms − 1 `limit` = 58; `CONSUME` has 27 keys; 72 protocols; 12 categories | **exact** |
| Intro | "largest single asset … five mechanisms, of which three are approximations" | Tether USDT = {Ps,Rd,At,Fz,Up}; `forced` = [Ps,Rd,Fz] | **exact** |
| `meas:vacuous` | 0 of 18 seed-instances exact, slack 1–58 | 18 instances, slack range 1–58 | **exact** (this was previously mis-stated as 1–39 and has been corrected) |
| Lean | builds clean, no `sorry`, standard axioms | `lake build` → "Build completed successfully (734 jobs)", exit 0; zero `sorry`/`sorryAx`/`admit`/`native_decide`/`axiom`; every declaration ⊆ `[propext, Classical.choice, Quot.sound]`; `aft_obstruction` needs none | **exact** |

The §"Which protocols compose" section is, on the numbers, the most solid part of the paper.
Every figure in `meas:pairs`, `prop:crosscat`, `prop:hostile` and `ex:uniaave` reproduced to the
digit on first attempt. Say so in the response letter; I want it on record that I checked.

---

## B. Major findings

### B1. `prop:perps` is false as a universal statement. The counterexample was excluded from the list. **Major.**

The paper asserts: *"For every perpetual futures venue in the corpus — Hyperliquid, ApeX, Aster,
Lighter, edgeX, GMX v2, Derive and Aevo — the canonical form omits exactly {Ct, Ex, Li}."*

The corpus category `Perpetuals / derivatives` contains **seven** protocols, not eight:

```
Hyperliquid                  14 -> 11   dropped: Ct,Ex,Li
ApeX Protocol (ApeX Omni)    12 ->  9   dropped: Ct,Ex,Li
Aster                        11 ->  8   dropped: Ct,Ex,Li
Lighter                      13 -> 10   dropped: Ct,Ex,Li
edgeX                        12 ->  9   dropped: Ct,Ex,Li
Jupiter Perpetual Exchange    8 ->  8   dropped: (nothing)      <-- omitted from the paper
GMX V2 Perps                 13 -> 10   dropped: Ct,Ex,Li
```

The paper's list of "eight" **drops Jupiter Perpetual Exchange** — a perpetual venue, in the
perpetuals category, holding `Ct`, `Ex` and `Li` — and **imports Derive and Aevo from
`Options / structured products`** to restore the count. Jupiter Perps carries `Pm` rather than
`Pf`, so no arc reaches `Ct`, `Ex` or `Li`: its canonical form is its full element set and it omits
*nothing*.

The following remark is therefore false where it is strongest: *"no perpetual venue in the corpus
chooses to have a collateral test, an oracle, or an incentivised liquidator … and the eight venues
agree on this to the symbol."* One venue in the corpus chooses all three.

This is the exact failure mode the submission has been warned about: a universal quantifier over a
category, evidenced by an enumeration that silently substitutes members.

**Fix.** Either (a) restate as an existential over the seven-of-eight that do agree and name
Jupiter Perps as the exception with its explanation (`Pm`-priced, no `Pf`), or (b) restate the
quantifier over "venues whose decomposition contains `Pf`", which is the actual hypothesis doing
the work, and say so. Do not re-scope the category to preserve the count.

### B2. "Ct … is a primitive in none" is refuted by three corpus members. **Major.**

The remark after `prop:ct`: *"it is a consequence in every protocol that has it, and a primitive in
none."* Recomputed over all 28 corpus protocols containing `Ct`, it is ≼-maximal — i.e. a
primitive generator — in three:

```
PRIMITIVE  Jupiter Perpetual Exchange   [Perpetuals / derivatives]
PRIMITIVE  CIAN Yield Layer             [Yield / vaults / aggregators]
PRIMITIVE  Kalshi                       [Prediction markets & other]
```

`prop:ct` itself — restricted to lending and CDP — survives, but the surrounding claim, which is
the one the paper puts weight on ("A taxonomy that lists it beside genuinely independent mechanisms
overstates its status"), does not. **Fix:** restrict the remark to protocols containing a member of
{Pl, Im, Cd, Pf, Op}, and record the three exceptions.

### B3. `meas:compress`'s "13 arcs" is wrong under both law tables, and contradicts `cor:ourconvex`. **Major.**

`meas:compress`: *"The specialization poset has 13 arcs and exactly 10 non-maximal elements. Of the
72 protocols, 29 have a strictly smaller canonical form."*

`cor:ourconvex`, four pages earlier: *"D has 15 arcs"*. The "Honest scale" remark: *"D has 15 arcs
on 58 vertices."* The paper states two different arc counts for the same digraph.

There are two law tables in the repository and **13 belongs to neither of them correctly**:

| table | arcs (multiplicity) | arcs (distinct) | non-maximal elements | protocols compressed |
|---|---|---|---|---|
| `PARSED_NEW` (raw `data.ts`) | 16 | **15** | **10** | **29** / 72 |
| `LSTAR` (the paper's "corrected law system L\*") | **13** | 12 | 8 | 28 / 72 |

So `meas:compress` is a chimera: **13** is L\*'s *multiplicity* count (its distinct count is 12),
while **10** and **29** in the same sentence are `PARSED_NEW` figures. No single computation
produces that sentence. **Fix:** state 15 distinct arcs (raw parse) and name the extraction
explicitly at both sites.

### B4. §"Applying the canonical form" is not robust to the choice of law table, and the paper never says which it used. **Major.**

Under L\* — which the repository labels *the corrected law system* — the arcs `Op→Ct`, `Pf→Ex` and
`Pf→Li` do not exist. Recomputing §`sec:apply` under L\*:

```
Hyperliquid   14 -> 13  dropped: {Ct}      (paper: {Ct,Ex,Li})
GMX V2 Perps  13 -> 12  dropped: {Ct}
Derive        14 -> 13  dropped: {Ct}
Ct now primitive in: Jupiter Perps, CIAN, Rysk V12, Kalshi
```

The headline result of §`sec:apply` — that the eight venues agree on `{Ct, Ex, Li}` "to the symbol"
— collapses to `{Ct}` under the paper's own corrected table, and `prop:ct` acquires a fourth
counterexample (Rysk V12). The entire applied section rests on an extraction the repository
elsewhere describes as superseded, and the paper does not disclose the choice. **Fix:** state which
table §`sec:apply` uses, justify it, and report the L\* figures as a robustness check.

### B5. §`sec:cfp` remark (iii) inverts the two numbers it exists to disambiguate. **Major.**

The remark asserts: *"The reported 59% of live protocol pairs is the density of G⊕ restricted to the
72 corpus protocols, not a property of any fragment. The two numbers measure different things and
should not be conflated."*

`formal/v2/f67b.out`, the sole provenance:

```
65/72 admissible; 50 of those lie in the congruence fragment F
pairs of admissible live protocols: 2080; union admissible for 1879 (90.3%)
certified a priori by F (no re-analysis needed): 1225 (58.9%), of which wrong: 0
```

58.9% **is** a property of the fragment F — the a-priori certification rate. The edge density of
G⊕ on the corpus is **90.3%** (and 90.0% on the 61-protocol base of `meas:pairs`). The remark
states the opposite of what the evidence says, and it is precisely the remark added to prevent this
conflation. **Fix:** 59% is F's certification rate; the density is 90%. Note also that 59% is
computed on a 65-protocol base and 90% on a 61-protocol base — say so, or the two are not
commensurable.

### B6. The stored output backing `meas:frag` is a crashed run. **Major (traceability).**

`meas:frag`'s figures `0.478` and `[11026, 23055)` trace only to `formal/v2/f467.out` and
`audit/AUDIT-MEASUREMENTS.md`. `f467.out` **terminates in an uncaught exception**:

```
F subset of safe? false
TypeError: Cannot read properties of undefined (reading 'group')
    at ungrounded (tables.mjs:148:39)
    at admissible (tables.mjs:151:68)
    at f467.mjs:89
```

Two problems. First, a measurement in a submitted paper is evidenced by a stored output whose run
aborted. Second, the line printed immediately before the crash — `F subset of safe? false` — is in
apparent tension with the §`sec:cfp` remark that *"Our measured fragment … is a join-semilattice
and hence ⊕-closed"*. **Fix:** rerun to completion, commit the clean output, and reconcile or
withdraw the ⊕-closure claim about F.

### B7. Two "measurement" figures do not reproduce; one is a sample presented as exact. **Major.**

`meas:latticeconf`: *"Over 175,230 pairs from ℛ∩𝒲 there are 0 union-closure violations … 51,917
pairs have X∩Y ∉ ℛ∩𝒲."*

The pair count 175,230 reproduces exactly, because it is fixed by the sampling *scheme* (pool 3,000,
window 60) — it is **3.9% of C(3000,2)**, i.e. a windowed sample, and the paper does not say so.
The intersection count does not reproduce: `formal/v3/m2.out` gives **50,223 / 50,611 / 50,276** on
seeds 1–3. 51,917 is a seed-specific statistic printed as though exact.

Same defect in `cor:oplusclosed`: 96,720 is pool 2,500 × window 40, not C(n,2) for any n. This is
stated as a **Corollary**, whose only cited evidence is a sample — a direct violation of the
paper's own status conventions ("Corollary — proved"). It *is* a corollary of union-closure; prove
it that way and drop the number, or demote it to a measurement and label it sampled.

### B8. `cor:ourconvex` derives an "all 2⁵⁸ subsets" claim from evidence that is 92% random sampling. **Major.**

*"Cn coincides with reachability in D (checked on 21,712 seeds)."* `formal/v2/digraph.mjs` builds
those seeds as 58 singletons + 1,653 pairs + **20,000 random seeds**. The conclusion "on all 2⁵⁸
subsets" is licensed by `thm:convex`, which is legitimate; but the *hypothesis* of that theorem —
`Cn` = reachability — is asserted from a sample and the reader cannot tell. `formal/v3/m5.out` does
this properly (exhaustive over all 32,567 seeds of size ≤3, 0 mismatches). **Fix:** cite the v3
exhaustive figure, which is both stronger and honest.

### B9. Three figures rest on a generator the repository itself records as degenerate. **Major.**

`formal/v2/FINDINGS-CONVEX.md` records the defect and the instruction: *"the same LCG idiom appears
elsewhere in `formal/v2` and should be replaced there too."* It was not. The idiom

```js
const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
```

loses low bits above 2⁵³ and cycles. Confirmed by direct rerun: 14,469 distinct values in 200,000
draws at seed 7 (reproducing the recorded figure), 16,403 at seed 12345 (pre-period 5,937, cycle
10,466), 12,678 at seed 999331. Surviving load-bearing users:

- **`meas:tradeoff`** (`+0.569`, `−0.117`, `71/72`, `35/84`, `25/84`, "rejects 82%"). The entire
  84-set synthetic negative corpus is emitted by `algebra/negcorpus.ts:33` from the degenerate
  stream. The RANDOM control family — the thing that makes the separation score mean anything — is
  drawn from ~10⁴ reachable states, not 2³¹. This is the paper's central §`sec:tradeoff` result and
  its control is compromised.
- **The "Method" remark** (`305,272 sets`, `3,938 certificates`, `9,600 completions`,
  `3.15 seconds`). 305,272 = 1,024 + 300,000 + 72×59 exactly, but the 300,000 collapse to **24,976
  distinct** subsets — each re-tested ~12×. "Validated against an independent implementation on
  305,272 sets" overstates coverage by an order of magnitude. Worse, at `f10.mjs:325` the same
  generator is passed *into the SAT solver* as its model-choice RNG, so the 9,600 "sampled
  admissible completions" are a small periodic slice of the completion space, not 9,600 draws.

**Fix.** Replace with the seeded mulberry32 harness already present in `formal/v3/`, rerun, and
report distinct-set counts alongside draw counts. Until then `meas:tradeoff` should not be cited.

### B10. `meas:width` has no producing code in the repository. **Major (traceability).**

The rates `0.925, 0.710, 0.655, 0.684` and the `0.75 → 0.13` union-closure fall trace to no script
and no output file; `audit/AUDIT-MEASUREMENTS.md` records that the cited `verify3.py` is absent
from the repo. The paper does label the measurement "indicative only", which is the right instinct,
but an indicative figure still needs a script. **Fix:** commit the generator or delete the
measurement — `remark[Corrected]` and `prop:twoeffects` do not depend on it.

### B11. The abstract asserts a claim the paper's own body refutes. **Major.**

Abstract and introduction: *"prohibitions are Horn, destroy that closure, and are **the sole
obstruction** to admissibility inheriting it."*

`meas:whereitfails`, five pages later: *"23% is due to mixed-polarity clauses"*, and `prop:mixed`
states these are *"neither Horn nor dual-Horn, and are preserved by neither union nor
intersection."* The repository's own `formal/v3/VERIFICATION.md` marks the sole-obstruction claim
**REFUTED**, identifying `X19*` and `X18` as mixed-polarity rows that break ∪-closure and are not
prohibitions. The body was corrected; the abstract was not. **Fix:** "non-dual-Horn clauses are the
sole obstruction, of which prohibitions are one species".

---

## C. Minor findings

**C1.** `meas:whereitfails`'s three shares are 27.8% + 57% + 23% = **107.8%**. They are row-firing
counts *with multiplicity* (`m4.out`: X2 2,747; X21 5,679; X19\*+X18 2,306, of 9,883), so a failure
can be counted twice. The word "a further" asserts a disjointness that does not hold. Either report
the sole-cause figures (2,100 / 4,955 / 2,008) or say explicitly that the shares overlap.

**C2.** The 9,883 failures of `meas:whereitfails` and the 96,720 pairs of `cor:oplusclosed` come
from the same sampled admissible pool of 2,500 (`m4-oplus.mjs`). Neither is labelled sampled.

**C3.** `prop:ct` says "every lending and collateralised-debt protocol in the corpus" and lists
fifteen. The corpus has **twelve** Lending + CDP protocols, one of which (Ethena) contains no `Ct`
at all — so the claim is vacuous there and should say so. Four of the fifteen named (Fluid,
Steakhouse, Rysk, Panoptic) are in DEX, Yield and Options categories respectively. The list is
neither the category nor the property; pick one.

**C4.** "Maple" and "Steakhouse" each denote **two distinct corpus entries** (`Maple` in Lending
and `Maple Finance (syrupUSDC…)` in RWA; `Steakhouse Financial` in Yield and
`Steakhouse Financial (Risk Curators)` in Prediction/other). In a section whose whole point is
statements about *named* systems, the names must disambiguate.

**C5.** `ex:comp` calls it "Uniswap v3". The corpus entry is `Uniswap`, decomposed from aggregated
V2+V3+V4 TVL, and §`sec:pairs` calls the same object "Uniswap". Use one name.

**C6.** `ex:uniaave`: *"which is exactly the recorded prohibition X2"*. The recorded X2 row reads
`Fl* + manipulable Cp/Cl price + Pl/Cd, where manipulation cost < position value` — a *disjunctive*
pattern with an unmodelled economic side condition, not the five-element conjunction
{Fl,Cp,Cl,Pl,Cd}. `meas:clutter`'s description of X2 as "a positive element set" inherits the same
over-reading. The conclusion survives (I checked the disjunctive reading: neither protocol arms X2
alone), but "exactly" is wrong, and the count "one of only three such pairs" is computed under the
strict conjunction and so is a lower bound.

**C7.** `meas:access` reproduces (4,580 / 20), but `audit/AUDIT-MEASUREMENTS.md` records the
provenance chain as **REFUTED** — the source claimed 8,240 and had "no generating code". The paper
prints the corrected number against uncorrected provenance. Cite `audit/a8-access.mjs`.

**C8.** The directory is `corpus50/`; the corpus is 72 protocols. Cosmetic, but it invites exactly
the truncation suspicion this submission can least afford.

---

## D. Editorial

**D1. The Lean development is entirely unclaimed in the paper.** `grep -c "Lean" paper/atlas.tex`
returns **0**; so do `mathlib`, `formalis*`, `machine-check*`, `proof assistant`. Meanwhile
`lean/` contains 1,118 lines, 63 proof-carrying declarations, builds clean with zero `sorry` and
clean axioms. This is a real asset being thrown away. But note before citing it: the atlas itself
is **not** in Lean — there is no 58-element vocabulary, no ℛ/𝒲/ℋ. `lem:polarity` is proved by
*defining* `reqClause s T := ⟨T, {s}⟩` and observing `card {s} ≤ 1`; the empirical content (that the
recorded rows have that shape) is unformalised, and `meas:whereitfails` concedes two rows do not.
`thm:closure`'s negative halves are formalised as existentials over `Fin 3`, not as statements about
the paper's model classes. `Obstruction.lean`'s `Adm Γ Δ` is unrelated to the paper's `Adm`. If you
cite the Lean, cite it at this strength and no higher. `ex_reachCl_union_ex` is the one place the
Lean is genuinely *stronger* than the paper.

**D2.** `formal/v3/VERIFICATION.md` is stale: its summary table marks `prop:joinmeet` and
`thm:excomp` as refuted/incomplete, but the submitted `atlas.tex` has already absorbed both
corrections. A referee reading the artefact will hit the stale verdicts first. Regenerate it.

**D3.** The two headline applied sections have **no committed output file**. `canonical.mjs`
(§`sec:apply`) and `pairs.mjs` (§`sec:pairs`) both print to stdout and neither `canonical.out` nor
`pairs.out` exists. Both rerun cleanly and reproduce — I verified — but that is luck, not
provenance. Commit the outputs.

**D4.** `lean/Axioms.lean` was swept into commit `a6c91b5` by a concurrent auto-committer during
this review and is scratch. `git rm` it.

---

## E. Recommendation

**Major revision.**

The paper is unusual among submissions of its kind in that most of its arithmetic is correct. I
re-derived fourteen figures independently and every one of them held: the CNF widths, the exhaustive
size-≤3 enumeration, the entire §"Which protocols compose" section including all eight
composition-hostility ranks and the Uniswap/Aave witness, the clutter table, the accessibility
counterexample, the vocabulary and corpus cardinalities, and a clean Lean build with clean axioms.
The `179,864,061`-pair enumeration is genuinely exhaustive and correctly labelled, which is the
single most important thing I was asked to check and which the paper gets right.

What forces major revision is not arithmetic but **the fit between claims and evidence, and it
fails in the same direction every time**. `prop:perps` states a universal over a category and
supports it with a list that drops the one member of that category which refutes it. The remark on
`Ct` states "a primitive in none" against three counterexamples. `meas:compress` reports an arc
count from one law table beside two figures from another, and §`sec:apply`'s headline result
collapses from `{Ct,Ex,Li}` to `{Ct}` under the table the repository itself calls corrected. The
abstract still carries a sole-obstruction claim the body and the artefact both refute. Remark (iii)
of §`sec:cfp`, added specifically to stop two numbers being conflated, states each as the other.
`meas:frag` is evidenced by a crashed output file. And the central §`sec:tradeoff` separation score
is computed against a synthetic control drawn from a generator the authors themselves documented as
degenerate and then did not replace.

None of these is a rounding error. Each is a claim strengthened past what the computation supports,
and in every case the weaker true statement is available and still interesting: seven of eight perp
venues agreeing on `{Ct,Ex,Li}` is a good result; `Ct` derived wherever a credit primitive is
present is a good result; a 90% pairwise composition rate with 182 of 185 failures cross-category is
a very good result. The paper does not need the overreach.

I would accept a revision that: (i) fixes B1–B5 and B11 by weakening the statements to what the
corpus supports; (ii) reruns `meas:tradeoff` and the Method remark on the seeded harness already
sitting in `formal/v3/`, reporting distinct-draw counts (B9); (iii) labels `meas:latticeconf`,
`cor:oplusclosed` and `meas:whereitfails` as sampled, or replaces them with the v3 exhaustive
figures (B7, B8, C2); (iv) commits or deletes `meas:width` and repairs `f467.out` (B6, B10); and
(v) either cites the Lean at the strength D1 describes or removes it from the artefact.

I do not recommend reject: the theory is sound, the negative results are reported as results, and
§"Which protocols compose" is genuinely load-bearing and genuinely reproducible. But the authors
should assume I will re-derive every number again, including the ones I confirmed above.
