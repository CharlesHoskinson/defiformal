# FINDINGS-V2 — the atlas remodelled against the corrected theory

Built from scratch under `formal/v2/`. Nothing is inherited from `formal/atlas.qnt`,
`formal/analyze.mjs` or `formal/probe.mjs`; the only shared input is the atlas data
itself (`viz/src/data.ts`, `corpus50/lanes/*.json`, `algebra/blind-test-set.json`).

## What was modelled

| file | what it is |
|---|---|
| `tables.mjs` | independent re-extraction of 58 elements / 29 laws / 20 hazards from `viz/src/data.ts`, with **both** parsers side by side so the fix is measurable; the corrected law system `L*`; the 27 warrant rows; the four operator blocks; the corpus split |
| `atlas2.qnt` | the Quint model: corrected term semantics, `Γ` (requirement-closure), `Δ` (warrant interior as a genuine kernel operator `Δ(S) = S ∖ unwarranted(S)`), polarity, the T2 congruence fragment, and a **second sort** of `(element, asset)` instances with a `backs` relation |
| `f1.mjs` … `f7b.mjs` | the enumerations Quint cannot do at scale |

**Division of labour, stated honestly.** Quint carries the *semantics* and every
qualitative claim (the parser fix, the four congruence failures, the polarity split,
the reflexivity control, `Uc`). The *quantitative* claims — the ablation, the
closed-set counts, the multi-million-subset hazard search, the size of the congruence
fragment — are in a JavaScript harness, because they are 10^6–10^7-point enumerations
and Quint's evaluator is orders of magnitude too slow for them. Every number below
names the file and the command that produced it.

```
$ quint test --main=atlas2_test --match="Test$" atlas2.qnt
  atlas2_test
    ok parserFixTest            ok flXmDeadTest             ok notJoinClosedTest
    ok notMeetClosedTest        ok notUpClosedTest          ok notDownClosedTest
    ok compositionIsMonoidTest  ok congruenceFragmentTest   ok fragmentExcludesFlTest
    ok terraCycleTest           ok forgetfulKernelTest      ok ucRealizableTest
    ok gammaUnionClosedTest     ok deltaUnionClosedTest     ok banPolarityTest
  15 passing (182ms)
```

quint 0.32.0. `quint verify` (Apalache) was **not** run: the properties here are
properties of a *family of sets*, not of a transition system. The old model's framing
as an assembly automaton is what made bounded model checking necessary; exhaustive
enumeration over the same bound subsumes it and is complete where a trace-depth bound
was not. Where a bound is used it is stated as a bound.

---

## F1 — the ablation. Reproduces exactly. The stated mechanism does not.

```
$ node f1.mjs
=== F1: blocks alone (independent re-implementation) ===
G (closure)    {"real":65,"ro":"0.903","other":31,"oo":"0.369","ratio":"2.45"}
D (warrant)    {"real":71,"ro":"0.986","other":35,"oo":"0.417","ratio":"2.37"}
Ban+Cond       {"real":72,"ro":"1.000","other":64,"oo":"0.762","ratio":"1.31"}
Ground         {"real":72,"ro":"1.000","other":72,"oo":"0.857","ratio":"1.17"}
G AND D        {"real":65,"ro":"0.903","other":17,"oo":"0.202","ratio":"4.46"}
=== drop one ===
without G (closure)    ratio 3.77      without D (warrant)    ratio 3.99
without Ban+Cond       ratio 4.74      without Ground         ratio 9.48
all four               {"real":65,"ro":"0.903","other":7,"oo":"0.083","ratio":"10.83"}
```

Every cell of OP-ORD section 5's ablation table reproduces to the digit: 2.45 / 2.37 /
1.31 / 1.17, drop-one 3.77 / 3.99 / 4.74 / 9.48, all-four **10.83x**, 65/72 and 7/84.
So does the 72/84 split and the seven-name false-reject list. **Confirmed.**

**But the interpretation attached to it is wrong in a way that matters.** MODEL.md
section 1 presents the result as *closure 2.45 x warrant 2.37 -> both 10.83*. That row
is not in the report's own table, and it is not true:

```
G AND D                                                      ratio 4.46
ratio(G)*ratio(D) if the two were independent              = 5.79
negatives: G rejects 53, D rejects 49, both 35, expected-if-independent 30.9
```

`Γ ∧ Δ` is **4.46x**, *below* the independence product of 5.79x — the two adjoints are
positively correlated on the negatives (they reject 35 of the same 84 where
independence predicts 31), so together they are **sub**-multiplicative, not
super-multiplicative. The jump from 4.46x to 10.83x is contributed entirely by
`Ban+Cond` (1.31x alone) and `Ground` (1.17x alone) — the two blocks the report itself
dismisses as weak. They are weak alone and strong last, because the negatives that
survive both adjoints are disproportionately hazard-armed.

The honest restatement: **the headline number is real; the "two adjoints" story is not
what produces it.** Warrant is worth about 1.8x on top of closure (2.45 -> 4.46), and
the remaining 2.4x is the hazard and grounding filter. Warrant is still the single
largest addition in the council's work and still the right idea. It is not the 4.4x
the model claims for it.

Three secondary results:

- **P14 reproduces on the exact number it cites.** `L15` alone rejects **25 of 72**
  live protocols under the old parser and **0 of 72** corrected. Whole-corpus closure
  goes **30/72 -> 61/72** (the ledger's "6/12 -> 9/12" is a 12-case pilot; on all 72
  the effect is larger). L6 4->0, L7 2->0, L8 9->0, L14 0->0.
- **The bug was doing discriminating work.** Reference closure scores 2.33x with the
  bug and **1.98x without it** (`real 61/72, other 36/84`). Fixing the parser makes the
  reference engine *worse* as a classifier while making it correct. No claim of the
  form "the corrected engine discriminates better" may be sourced to the fix; it all
  comes from `Δ` and the hazards.
- **Robustness.** 2000 bootstrap resamples of the 156-case split: median 11.17x, 95%
  interval **[6.03, 26.83]**. 10.83x is not a fluke of one draw, but the interval's
  lower end sits on OP-ORD's own uncalibrated estimate of 6.88x.

---

## F2 — the definite fragment. Height 1 confirmed; "3,140 closed sets" refuted; two of the eight rules are not in the atlas.

```
$ node f2.mjs
=== F2.1 definite fragment derived from the corrected 29 laws ===
rules: 16
  L1: Pl->Ct  L1: Im->Ct  L1: Cd->Ct  L1: Pf->Ct  L1: Op->Ct
  L3: Uc->Aw  L3: Uc->At  L4: Pf->Ex  L4: Pf->Ct  L4: Pf->Li
  L5: Py->Ep  L5: Py->Rd  L19: Of->Xm L19: Of->Xf L20: Rl->Au L21: Gs->Au
bodies: Cd Gs Im Of Op Pf Pl Py Rl Uc
heads : At Au Aw Ct Ep Ex Li Rd Xf Xm
HEIGHT 1 (bodies and heads disjoint)? true
```

**Height 1 is confirmed independently** — I extracted the definite fragment
mechanically from the corrected 29 laws rather than taking OP-LOG's list. Bodies and
heads are disjoint, so `Cn` is one-pass and closed sets are exactly the up-sets of a
poset. Every lattice law holds with zero counterexamples on both fragments:

```
OP-LOG 8-rule fragment: 2025 closed subsets of the 14 constrained atoms (x 2^40 free)
  counterexamples: {"joinClosed":0,"meetClosed":0,"assoc":0,"absorb":0,"distrib":0}
corrected-29-law definite fragment: 4000 closed subsets of 20 constrained atoms (x 2^34)
  counterexamples: {"joinClosed":0,"meetClosed":0,"assoc":0,"absorb":0,"distrib":0}
```

This was never in doubt: up-sets of *any* finite poset form a completely distributive
lattice with meet = intersection. P2 is a theorem, not a measurement, and the 3,140
machine checks confirm an identity that could not have failed. Three things about the
stated version are wrong:

1. **The fragment is 16 rules, not 8.** OP-LOG omits ten definite productions the atlas
   does contain: `Pl->Ct`, `Im->Ct`, `Cd->Ct`, `Pf->Ct`, `Op->Ct` (L1), `Uc->At` (L3),
   `Pf->Ex`, `Pf->Ct`, `Pf->Li` (L4), `Rl->Au` (L20).
2. **Two of its eight are not derivable from the atlas at all.** `R34: Rs->Vl` and
   `C15: Ad->Li` appear in no law text. They are OP-LOG's own additions, presented as
   mechanical extraction.
3. **3,140 is not the size of the lattice.**
   ```
   OP-LOG 8-rule fragment:  TOTAL Cn-closed subsets of the 54-atom signature
                            = 2,226,511,046,246,400        (= 2025 x 2^40)
   corrected-29-law fragment = 901,943,132,160,000         (= 52500 x 2^34)
   ```
   The lattice has about 2.2x10^15 elements. 3,140 is the number of distinct closed sets
   *reachable from the corpus* — a sample reported as an exhaustive verification. The
   verification is valid; the completeness claim attached to it is not.

**And the fragment decides almost nothing.**

```
=== F2.5 does the definite fragment alone separate real from synthetic? ===
definite fragment alone: real 69/72=0.958 other 48/84=0.571 ratio 1.68
```

1.68x — below the reference engine. The well-behaved lattice lives exactly where the
discrimination is not. That is consistent with MODEL.md section 4c's design advice
(work in the definite fragment, filter outside it) but it prices that advice: the
inside is nearly content-free, and everything that distinguishes a real protocol from
a plausible fake happens in the outer filter.

---

## F3 — the unlisted-hazard search, re-run corrected. Something survives.

Same three candidate-hazard families as the old run (`formal/probe.mjs`), same
vocabulary (all 58 elements), but with the corrected parser, the warrant condition, and
— new — the corpus test that killed `{Fl,Xm}` applied to *every* witness rather than to
one.

```
$ node f3b.mjs 5
=== EXHAUSTIVE, all subsets of the 58-element vocabulary of size <= 5  (619s) ===
enumerated: 5038954  ADMISSIBLE: 744590

stratumInversion: 7650 admissible violating sets, 1 minimal
  fire on >=1 of the 72 live protocols (DEAD, the R1 test): 1
  SURVIVING candidate unlisted hazards (zero live hits): 0
    killed: {Au,Gs} <- Polymarket

atomicScopeBreak: 2151 admissible violating sets, 81 minimal
  fire on >=1 of the 72 live protocols (DEAD, the R1 test): 3
  SURVIVING candidate unlisted hazards (zero live hits): 78
    [["Sh","In","Fl","Xm"],["Sh","Fl","Tg","Xm"],["Sh","Fl","Up","Xm"],["Sh","Fl","Gp","Xm"],
     ["Sh","Fl","Xm","Sb"],["Sh","Fl","Xm","Rs"],["Sh","Fl","Xm","Vl"],["Ix","In","Fl","Xm"],
     ["Rb","Cp","Fl","Xm","Vl"],["Cp","Fl","Sl","Xm","Vl"],["Cp","Fl","Ep","Xm","Vl"], ...]
    killed: {Ix,Fl,Tg,Xm} <- Aave V3

inexpressible: 650396 admissible violating sets, 377 minimal
  fire on >=1 of the 72 live protocols (DEAD, the R1 test): 82
  SURVIVING candidate unlisted hazards (zero live hits): 295
    killed: {Sh,Fl,Ct,Ex} <- Morpho, CIAN Yield Layer
```

The K=4 run is in `f3_k4.out` and agrees on every minimal witness it can see
(456,838 subsets, 83,497 admissible, same three families, same kills).

and the old prizes individually:

```
 {Fl,Xm}:    closesOld=true closesNew=true ADMISSIBLE=false {"warrant":["Fl","Xm"]}
 {Fl,Au,Rl}: closesOld=true closesNew=true ADMISSIBLE=false {"warrant":["Fl"],"hazard":["X21"]}
 {Au,Gs}:    closesOld=true closesNew=true ADMISSIBLE=true  {}
```

**Three results.**

1. **`{Fl,Xm}` dies, and it dies on `Δ`, not on a hazard.** Neither `Fl` nor `Xm` has
   anything to be for in that pair. The warrant condition would have killed the old
   model's prize finding on the day it was found, with nobody needing to notice Aave.
   This is the cleanest single demonstration that the missing half of the specification
   was load-bearing.
2. **`{Au,Gs}` — the stratum inversion — is still fully admissible under the corrected
   model, and is dead for the other reason: Polymarket has both.** The old model's
   second headline finding fails the same corpus test that killed the first. Both
   prizes are gone; one to the warrant operator, one to the corpus.
3. **The atomic-scope family is not dead. It is sharpened.** 78 of the 81 minimal
   witnesses survive at size <= 5: admissible under `Γ* ∧ Δ ∧ Ban ∧ Cond ∧ Ground`,
   arming no listed hazard, and instantiated by **none** of the 72 live protocols. Every
   one has the shape

   > `{ w_Fl , Fl , Xm , w_Xm }` (plus at size 5 a second warrant) with `w_Fl` in
   > `{Sh, Ix, Rb, Cp, Cl, St, Wg, Pm, Ag}` — a warrant for the flash facility — and
   > `w_Xm` in `{In, Sb, Rs, Vl, Tg, Up, Gp}` — a warrant for cross-domain messaging

   and they are separated from the *dead* ones by exactly which warrant `Xm` gets:
   `{Ix,Fl,Tg,Xm}` is Aave V3 and dies; `{Sh,In,Fl,Xm}` is no live protocol and
   survives. So the correct reading is neither "flash meets a domain boundary" (too
   broad — Aave) nor `Fl ∧ (Xf|Rl|Of)` (X21, already listed) but the narrower **"a
   warranted flash facility co-present with cross-domain messaging that is itself
   warranted by an intent, a proof system, a stake or a queue"** — the cases where the
   message the flash loan races is one the protocol is obliged to honour.

**The bound, stated as a bound.** The table above is complete for all **5,038,954**
subsets of size <= 5 over the full 58-element vocabulary — the same bound as the old
run, so the two are directly comparable. **Nothing is claimed above size 5.** A minimal
unlisted hazard needing six co-present elements would not be found.

**A caveat that applies to all of it.** "Zero live hits" means zero hits in 72
decompositions. That is exactly the evidence standard that overturned `{Fl,Xm}` (R1),
and it is weak: a test against a corpus of 72, not a proof of unbuildability. The right
claim is *"no protocol in the corpus does this"*, never *"this cannot be built"*.

---

## F4 — the congruence refutation. Reproduced on all four closures; the K4 distinction holds.

Exhaustive over the full `2^20` of OP-ORD's own 20-element test universe, not a sample:

```
$ node f467.mjs
test universe: Fl Xm Xf Rl Of Bs Sl Au Gs Uc Aw At Cp Cl Pl Cd Ix Sh Ct Li
|2^U| = 1048576, |Adm| = 23055
=== F4: is Adm closed under join / meet / up / down? ===
{"join":1866616,"meet":6036158,"up":100150,"down":93218}
  join: ["Au,Rl,Xm", "Au,Cp,Fl"] -> "Au,Cp,Fl,Rl,Xm"        (X21 arms)
  meet: ["Au,Rl,Xm", "Aw,Sl,Xf,Xm"] -> "Xm"                 (Xm unwarranted)
  up:   [""] +Fl
  down: ["Xf,Xm"] -Xf
  attribution of union failures (2000 sampled):
    {"hazard:X19*":597, "hazard:X21":1092, "hazard:X19*/X21":311}
```

Confirmed: `Adm` is closed under **none** of join, meet, up-set or down-set. My
witnesses differ from OP-LOG's (different carrier, different law system) but all four
failures are real and reproduce independently.

**The attribution is the new content.** *Every* union failure sampled is `X19*`, `X21`,
or both — a hazard row, never `Γ` and never `Δ`. That is P1's polarity theorem made
quantitative on this carrier: the dual-Horn half (requirements, warrants, grounding) is
union-closed exactly as predicted, and 100% of the damage comes from the Horn half.

**The K4 distinction, kept separate as instructed.** `⊕ = ∪` is total, associative,
commutative and idempotent with identity `∅`, so *observational equivalence* is
preserved by composition by construction — that is GP-CAT's theorem
(`compositionIsMonoidTest`, passes). What fails is *admissibility*
(`notJoinClosedTest`, passes). Both are separately named tests in `atlas2.qnt` so the
two can never be conflated again. Nowhere in this document does "congruence" appear
without "for admissibility" or "for observational equivalence" attached.

**Bonus — T1', the non-commutation obstruction, enumerated as MODEL.md asks:**

```
$ node f67b.mjs
Delta(gamma(X)) != gamma(Delta(X)) on 385880 of 1048576 sets (36.80%)
  witness: X={Rl}   Delta(gamma X)={Au,Rl}   gamma(Delta X)={}
```

The obstruction is **not** a thin exception list. Over a third of the test universe
distinguishes the two orders, with a one-element witness. `γ` then `Δ` and `Δ` then `γ`
are materially different operators, and any tool composing them must declare an order.
T1' as posed ("converts a structural impossibility into a bounded list of exceptions")
does not survive: the list is 37% of the space.

---

## F5 — reflexivity, with the control. Holds.

Modelled in Quint as a genuine second sort — `Inst = {e: Elem, a: str}` — with
`backs := reads ; over^-1` a relation on instances, plus the forgetful functor
`U : Proto -> Set[Elem]`.

```
run terraCycleTest = all {
  assert(hasCycle(TERRA)),          // (As,UST) -> (Rd,LUNA) -> (As,UST)
  assert(not(hasCycle(CRVUSD)))     // (As,crvUSD) -> (Ct,ETH) -> (Ex,ETH), terminates
}
ok terraCycleTest passed 1 test(s)
ok forgetfulKernelTest passed 1 test(s)
```

Terra is a 2-cycle over `(element, asset)`; crvUSD, with an overlapping element set, is
not — its backing chain terminates in an asset the protocol does not issue. **The
control is the entire content**: any relation can be drawn with a cycle in it, and the
fact that the same construction applied to a comparable protocol yields none is what
makes it a result. `forgetfulKernelTest` then exhibits the cycle vanishing under `U`,
which is P8 made executable.

A note on the first version of this test, which passed for the wrong reason: my
`hasCycle` was reflexive (`reach` included its own seed), so *every* protocol had a
"cycle" and crvUSD failed the control. The control caught it. Had I asserted only
Terra, the model would have shipped with a vacuous positive.

**What this is not.** The instance-level `backs` edges are hand-entered from protocol
descriptions; there is no asset-annotated corpus to derive them from. F5 confirms the
two-sorted carrier *can express* the distinction and that the distinction *is* present
in these two protocols. It does not show the annotation is derivable at scale, and
until `At{subject=...}` is promoted from a display string to an index across the corpus
(OP-ORD section 3.5) it is not.

---

## F6 / T2 — the congruence fragment. A characterisation, proved, plus a bound.

**Construction.** Exactly four conditions in `Adm` fail to be preserved by union, and
F4's attribution shows they are the only ones. Two are prohibitions (`X2`, `X21`),
downward-closed, both triggered by `Fl`. Two are requirements with **conjunctive
antecedents** (`X19*: Aw ∧ Xf -> At|Fz|Xm`, `X18: Oa ∧ Li -> Ex|Tp`). Replace each
conjunctive row by its two *single-atom strengthenings*, and delete `Fl`:

```
F  =  { X in Adm :  Fl not in X,
                    Aw in X => X ∩ {At,Fz,Xm} nonempty,
                    Xf in X => X ∩ {At,Fz,Xm} nonempty,
                    Oa in X => X ∩ {Ex,Tp} nonempty,
                    Li in X => X ∩ {Ex,Tp} nonempty }
```

**Proof.** Every defining row of `F` now has a single-atom antecedent and a positive
disjunctive head. Such a row fires on `A ∪ B` iff it fires on `A` or on `B`, where it
was already satisfied, and a satisfied disjunctive head stays satisfied in any superset.
So `F` is union-closed, and `⊕` is a congruence for admissibility on `F`. QED

**Verification, exhaustive over `2^20`:**

```
|F| (Adm ∩ split-antecedent ∩ Fl-free) = 11026   (47.8% of Adm)
union counterexamples inside F: 0
=> F is closed under union, so (+) IS a congruence for admissibility on F.
intersection counterexamples inside F: 29603810
```

**Three things established, one not.**

1. `⊕` **is** a congruence for admissibility on `F`, and `F` is **47.8% of `Adm`**.
   Zero counterexamples in about 61M ordered pairs.
2. `F` is a **join-semilattice, not a sublattice.** It is massively not closed under
   intersection (29.6M failures), because outside the definite fragment meet is not
   intersection, and deleting a warrant-providing element de-warrants what it supported.
   **T2 as posed ("the largest sublattice on which ⊕ is a congruence") has the wrong
   shape: the object that exists is the largest union-closed subfamily. Demanding meets
   as well throws almost all of it away.**
3. The practical number, which is what T2 was for:
   ```
   $ node f67b.mjs
   65/72 admissible; 50 of those lie in the congruence fragment F
   admissible but OUTSIDE F: Uniswap, PancakeSwap, Aave V3, Morpho, SparkLend,
     Binance staked ETH (WBETH), EigenCloud (EigenLayer), Aster, Spark Savings,
     CIAN Yield Layer, DFlow, CoW Swap, Maple Finance, Kalshi, Polymarket
   pairs of admissible live protocols: 2080; union admissible for 1879 (90.3%)
   certified a priori by F (no re-analysis needed): 1225 (58.9%), of which wrong: 0
   ```
   **59% of live protocol pairs compose without re-analysis, certified by a linear-time
   membership test applied to each side separately, with zero false certifications.**
   That is the integrator-facing statement T2 asked for.
4. **Maximality is NOT established.** `F` is a lower bound. The upper-bound probe —
   `Adm` members participating in *no* bad union with any admissible set at all —
   returns 69 of 23,055, and `F` is not a subset of that, so the two bounds do not meet:
   the maximum union-closed subfamily lies in `[11026, 23055)`. Computing it exactly is
   a maximum-union-closed-subfamily problem on 23,055 points and I did not attempt it.
   **This is a bound, not a result.**

Note what `F` costs: it excludes Uniswap, Aave V3 and Morpho, because they carry `Fl`.
The composability guarantee is real, and it is precisely unavailable for the three
protocols an integrator is most likely to want to compose with.

---

## F7 — does `Uc` survive? Yes. Both live instances are admitted.

```
$ node f7b.mjs
universe: Uc Aw At Ct Ft Ep Sv Tr Fz Bs Sh Ix Rb Ex Cp Xf Xm Rd Ps Py
|2^U|=1048576 |Adm|=248918 |Adm containing Uc|=52692
smallest admissible Uc witnesses: [At,Aw,Ft,Uc] [At,Aw,Ct,Ft,Uc] [At,Aw,Ep,Ft,Uc] ...
under the INVERTED X11a projection: |Adm|=196226, containing Uc = 0

live Uc protocols under the corrected model:
  Maple {At Aw Ct Em Ex Ft Gp Ix Li Pl Sh Sv Tg Uc Up Wq}: admissible=true
  Huma Finance V2 {At Aw Bs Ep Ft Ix Sh Tr Uc Wq}: admissible=true
```

**P12 confirmed.** With `X11a` read as written (all named elements present = armed),
the count of admissible sets containing `Uc` is **exactly zero** — the projection bug,
reproduced. With the polarity corrected to `X11a*` (`Uc => Aw ∧ At`), `Uc` has
**52,692** admissible completions in this universe, minimal witness `{Uc, Aw, At, Ft}`,
and both live undercollateralised-credit protocols in the corpus are admitted. The
five-of-nine council ruling stands. The Quint test `ucRealizableTest` carries the same
claim on a Maple-shaped set.

**A methodological warning attached to this finding.** My first F7 run used OP-ORD's own
20-element test universe and returned **0** admissible `Uc` sets — which reads exactly
like a confirmation of the old bug. It is an artifact: `L3`'s fourth term
`(Sv|Ft|Fz|Ep|Tr)` has no member in that universe, so `Uc` is unsatisfiable there for
reasons that have nothing to do with polarity. Both runs are on disk (`f467.out`,
`f7b.out`). **A "zero completions" result over a bounded universe is worthless unless
you first check the universe contains the vocabulary the rule needs** — which is
precisely the shape of the original X11a bug, reproduced by accident while testing for
it.

---

---

## F8 — the Approximation Fixpoint Theory gate. **The gate does NOT clear.**

Asked in a follow-up: can `A(x,y)` be defined from `Γ` and `Δ` that is monotone in the
precision order `≤_p`? If yes, AFT's three semantics and the splitting theorem come
free and F6 is answered by citation. Answered explicitly, as requested.

### F8.1 — the two ingredients, measured

```
$ node f8.mjs
over 517880 sampled pairs a<=b:  Cn monotone violations 0,  Delta monotone violations 0
Cn extensive? true  Delta contractive? true
Cn idempotent? true  Delta idempotent? false
```

Both operators are `⊆`-**monotone**, with zero violations. `Cn` is extensive and
idempotent; `Δ` is contractive and monotone but **not idempotent**.

> **Correction to MODEL.md §2.** It states that `Δ` is "an interior operator —
> contractive, monotone, idempotent". The one-pass `Δ(X) = X ∖ {unwarranted}` that
> OP-ORD defines and that every score in this project is computed from is **not
> idempotent**: stripping an unwarranted dependent can de-warrant another one. The
> kernel operator is `Δ^∞`, the iterate. Admissibility is unaffected — `Δ(X) = X` and
> `Δ^∞(X) = X` are equivalent, which is what OP-ORD §1.3 actually says — but the
> operator called `Δ` in MODEL.md is not the kernel operator it is claimed to be.

### F8.2 — the answer: **NO**

`≤_p` is `(x,y) ≤_p (x',y')` iff `x ⊆ x'` and `y' ⊆ y`. So `≤_p`-monotonicity of
`A = (A₁, A₂)` requires

- `A₁` **monotone** in `x` and **antitone** in `y`
- `A₂` **antitone** in `x` and **monotone** in `y`

**Theorem.** No `A` built from `Γ` and `Δ` by composition and lattice operations is a
non-trivial `≤_p`-monotone approximator.

*Proof.* `Γ` and `Δ` are both `⊆`-monotone (F8.1, zero violations over 517,880 sampled
comparable pairs, and both are monotone by construction: `Cn` because it is a Galois
closure, `Δ` because `e ∈ Δ(S)` and `S ⊆ T` gives `C(e) ∩ T ⊇ C(e) ∩ S ≠ ∅`). Neither is
constant. An antitone slot cannot be filled by a monotone non-constant map, or by any
composition or lattice combination of monotone maps. So `Γ` may appear only in `A₁`
applied to `x`, and `Δ` only in `A₂` applied to `y`. Hence `A₁ = f(x)`, `A₂ = g(y)`:
`A` is a **componentwise product operator**. ∎

The canonical candidate, checked:

```
A(x,y) = (Cn(x), Delta(y)):
  <=_p-monotone:  MONOTONE            (by the proof above; the random sample was
                                       degenerate - only 3 of 200000 draws were
                                       <=_p-comparable - so this rests on the proof)
  CONSISTENT (x<=y => A1<=A2): 197538 violations in 328860 sampled consistent pairs
                                                          -> NOT consistent
  EXACT on the diagonal:  47760 of 50000 have Cn(x) != Delta(x)   -> NOT exact
  coordinates interact?   A1 ignores y and A2 ignores x  -> NO
```

So `A` is `≤_p`-monotone and **useless**: it is not consistent (60% of consistent input
pairs produce a pair whose "lower bound" is not below its "upper bound", so the interval
reading is meaningless), it is not exact (it approximates no operator `O`, because
`Γ(x)` and `Δ(x)` are different sets for 96% of `x`), and its coordinates never
interact, so its Kripke–Kleene and well-founded fixpoints are just
`(lfp Cn, gfp Δ)` computed independently.

**And this is the same failure as the bilattice refutation, not a different one.** The
componentwise-product conclusion is exactly Avron Thm 3.3's `L ⊙ R` — pairs with no
constraint that the coordinates agree, blind to the diagonal where validity lives. The
follow-up's two corrections turn out to be one correction: *`Γ` and `Δ` are two
different monotone operators, not the lower and upper estimate of one, and every
two-sided formalism that assumes otherwise collapses to a product.*

**What would clear the gate.** `≤_p`-monotonicity needs an antitone ingredient, and the
theory has exactly one: the **hazard fragment**, which is Horn / downward-closed. A
coupled approximator of the form `A₁(x,y) = Cn(x)` guarded by `banFree(y)` is antitone
in `y` and legitimate. That is a live construction and it is worth building — but note
what it says: **the AFT coupling has to run through the hazards, not through the two
adjoints.** That is independently what F4's attribution found — 100% of the union
failures are `X19*` / `X21`, never `Γ` and never `Δ`. Two methods, one answer: the
interesting structure is in the prohibitions, not in the adjunction.

(Caveat on the ban measurement: `bansCond` in this model bundles the pure prohibitions
`X2`/`X21` — genuinely downward-closed — with the conditional rows `X11a*`/`X19*`/`X18`,
which are requirements and are not. The run reports 57,002 of 3,495,260 single-element
extensions turning an illegal set legal, and all of them are the conditional rows. Only
`X2`/`X21` supply the antitone ingredient.)

### F8.4 — is "composition preserves validity" the same as stratifiability? **No.**

```
  row                                          antecedent-lvls head-lvls stratified? union-closed?
  Gamma L*  (single-atom antecedent)           [0]             [0]       true        true
  Delta     (single-atom antecedent)           [0]             [0]       true        true
  X11a*     (single-atom antecedent)           [0]             [1]       true        true
  X19*      (CONJUNCTIVE antecedent)           [1,1]           [1,0]     false       false
  X18       (CONJUNCTIVE antecedent)           [0,1]           [1,0]     false       false
```

(Levels from the height-1 definite poset of F2: bodies at 0, heads at 1.)

On this theory's five row shapes the two properties **agree** — which looks like
confirmation. It is not. They agree by an accident of which atoms happen to sit at
which level, and they are logically independent properties:

- **stratifiability** is a property of the *dependency graph* — does the value on
  stratum `i` depend only on strata `⪯ i`;
- **union-closure** is a property of the *antecedent arity* — a row fires on `A ∪ B`
  iff it fires on `A` or on `B`, which needs a single-atom antecedent (F6's proof).

The witness, run:

```
=== F8.6 the clean witness: stratified but not union-closed ===
  levels: Pl=0 Of=0 Ct=1  -> stratified: true
  row({Pl}) = true  row({Of}) = true  row({Pl,Of}) = false
  => stratified AND not union-closed. The two properties are independent.
```

`Pl ∧ Of → Ct` has every antecedent atom strictly below its head, so it is perfectly
stratified in the sense of Vennekens Def 3.3, and it is not union-closed. Thm 3.5's
*iff* is an iff about **fixpoints of a stratified operator**, not about **union-closure
of a model class**, and the two do not translate.

And the fragment does not come out of stratification either:

```
=== F8.5 ===
|Adm| = 23055, |F| = 11026, |Adm restricted to the stratified subtheory| = 23055
```

Every row of the theory is stratified under the height-1 level map, so the stratified
subtheory *is the whole theory* and `F` is a proper subset of it — 47.8%. Stratification
does not recover `F`, does not restrict `Adm` at all here, and answers nothing about
composition.

### F8.3 — the two carried corrections, discharged

1. **Bilattices were not modelled**, and F8.2 now gives an independent reason not to:
   any two-sided structure built from `Γ` and `Δ` is componentwise, which is Avron's
   representation theorem arriving by a different road.
2. **No ASP encoding was used, and no requirement is encoded as a definite rule.** `Γ`
   in `tables.mjs` and `atlas2.qnt` evaluates a term as *satisfied iff at least one
   alternative is present* — which is choice-rule semantics (`{a;b;c} :- body.` plus a
   constraint that one be chosen), not `a :- b`. That is precisely why `Γ` comes out
   union-closed in F4's attribution. The trap was not entered.

### F8 verdict

**A clean no.** AFT gives nothing here from `Γ` and `Δ`; the resemblance is cosmetic
and it is cosmetic for the same reason bilattices are refuted. F6 stands as proved in
its own right — union-closure by single-atom antecedent, verified with zero
counterexamples over `2^20`, with maximality still open in `[11026, 23055)`. The one
salvageable idea is an approximator coupled through the *hazard* fragment, which is a
new construction rather than an inherited theorem, and which F4's attribution
independently says is where the structure actually is.

---

## What this could not do

- **`quint verify` (Apalache) was not run**, by design (see above). No symbolic result
  is offered above the enumeration bounds.
- **F3 is complete to size 5** (5,038,954 subsets), matching the old run's bound. Nothing above size 5.
- **T2 maximality is open**, bounded to `[11026, 23055)` on a 20-element universe. AFT does not close it (F8).
- **`Δ` is calibrated.** OP-ORD disclosed that the 27 warrant rows were tuned against the
  same 72 positives they are scored on. I re-used the rows verbatim, so F1's 10.83x
  inherits that calibration entirely; the bootstrap interval measures sampling noise,
  not out-of-sample performance. The only honest out-of-sample estimate on record
  remains OP-ORD's own 6.88x.
- **The 72-protocol corpus is the only falsifier available**, for F3 and for R1 alike.
  It is 72 protocols.
- **Nothing outside `/root/DefiElements/formal/v2/` was modified.**

---

## The single most surprising thing

**The ablation reproduces to the digit and the story attached to it does not.**

`Γ ∧ Δ` — the two adjoints, the closure and the kernel, the "half-specification"
argument that reframes the entire model — is **4.46x**, which is *less* than the 5.79x
you would get if the two blocks were statistically independent. They overlap: on the 84
synthetic protocols they reject 35 of the same cases where independence predicts 31.
The two halves of the specification are not complementary. They are correlated, and the
second half adds about 1.8x to the first.

The 10.83x is real, and more than half of it comes from `Ban+Cond` and `Ground` — the
blocks scoring 1.31x and 1.17x alone, which MODEL.md never mentions and OP-ORD's own
prose dismisses. "Neither half works, the product does" is true of *four* blocks, not
two, and the two that carry it are the two nobody argued for.
