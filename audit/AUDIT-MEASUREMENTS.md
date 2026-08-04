# Adversarial audit of the 12 `measurement` items in `paper/atlas.tex`

Auditor brief: refute. Every figure below was re-derived from `formal/v2/tables.mjs`
(the atlas tables + the scored operators) rather than read back from a report,
except where explicitly noted as "traced only to prose".

Repo state at audit: HEAD moved during the audit from `8681fd1` to `45501a1`
(`paper+formal: the definite fragment is a convex geometry`), which added
`meas:antiexchange` and `meas:unique`. Both are covered.

Audit scripts written (all under `audit/`, none modify the repo):
`a1-invariance.mjs`, `a2-residual.mjs`, `a3-break.mjs`, `a4-confirm.mjs`,
`a5-gen-clutter.mjs`, `a6-final.mjs`, `a7-cnf.mjs`, `a8-access.mjs`,
plus `f11-rerun.out` and `audit/arity/` (isolated re-run of the arity census).

---

## Severity 1 — INVALIDATES A HEADLINE CLAIM

### S1. Gamma-invariance of Delta is FALSE on the actual operators. `meas:invariance` is refuted, and with it the empirical support for Corollary `cor:tarski`.

The paper's only structure theorem rests on `thm:invariance` plus a measurement
claimed to verify it "on the actual operators at 100% in four independent tests".

**Counterexample, minimal, verified directly (`audit/a4-confirm.mjs`):**

    X = {Ct, Op, Tp}
      gammaOpen(X)          = []                 -> X is in Fix(Gamma)
      unwarranted(X)        = ["Tp"]
      Delta^omega(X)        = {Ct, Op}
      gammaOpen(Delta X)    = [["L1a","Ex|Tp|At|Oa|Sv|Cl|Cp|St|Wg"]]   -> NOT in Fix(Gamma)

Cause: `Op` fires L1a, whose only witness in `X` is `Tp`; `Tp`'s warrant row is
`["Cp","Cl","St","Wg","Pm","Ob"]`, which does not contain `Op`. So `Delta` strips
the last witness of an obligation `Op` itself raised.

**Not an isolated case.** Exhaustive over every nonempty subset of size <= 4 of
the 58-element vocabulary: 224,025 members of `Fix(Gamma)`, **116 invariance
failures**. Random search over the full 58 at p=0.12: 128,123 `Fix(Gamma)` hits,
260 failures (0.203%). Further witnesses: `{Sh,Ix,Op,Tp}`, `{Ct,Ft,Op,Tp}`,
`{Ag,Ct,Dp,Ft,Im,Rf,Sl,Tp}`.

**Why the measurement reported 100%: the test universe excludes exactly the
failures.** `f11.mjs` runs the scored test over `U20 = {Fl,Xm,Xf,Rl,Of,Bs,Sl,Au,
Gs,Uc,Aw,At,Cp,Cl,Pl,Cd,Ix,Sh,Ct,Li}`. Every element implicated in a residual
violation — `Tp, Op, Im, Pf, Ex, Ad, Rb, Sv` — is absent from `U20`. Re-running
the *identical* test on a 20-element universe centred on those elements
(`audit/a3-break.mjs`):

| universe | scored closure condition preserved by Delta |
|---|---|
| `U20` as shipped in `f11.mjs` | 92,880 / 92,880 = **100.000%** (reproduces) |
| `U20-B` = `{Pl,Im,Cd,Pf,Op,Ct,Li,Ad,Sl,Bs,Sh,Ix,Rb,Tp,Ex,Sv,Cl,Cp,Tr,Ob}` | 418,622 / 429,240 = **97.526%** (10,618 failures) |
| `U20-C` = `{Py,Ep,Rd,Sh,Ix,Rb,Of,Xm,Xf,Sl,Bs,Rl,Au,Gs,In,Uc,Aw,At,Ft,Ct}` | 140,050 / 140,050 = 100.000% |

### S1b. The theorem's hypothesis is false for the actual tables, so the paper's stated *reason* for invariance is wrong.

`thm:invariance` is conditional on `C` being the residual of `R`, and the
"maintenance hazard" remark asserts invariance "holds *because* `C` was derived
as the residual of `R`". Direct check (`audit/a2-residual.mjs`) of the residual
property — for every law `(subjects S, term T)` and every `e` in `T`, every
`s` in `S` must lie in `CONSUME[e]`:

* against `PARSED_NEW` (the parsed law table): **30 pairs satisfy it, 33 violate it.**
* against `LSTAR` (the scored law system): 34 violating pairs, including
  `L1a: Pf demands Sv but consumers(Sv) omits Pf`,
  `L1d: Pl/Im/Cd/Pf demand Li but consumers(Li) = [Ct]`,
  `L19: Of demands Sl but consumers(Sl) omits Of`,
  `L5: Py demands Rb but consumers(Rb) omits Py`.

`C` is not the residual of `R`. Wherever invariance does hold it holds by
redundancy in the tables (e.g. `L1c` forces `Ct`, which happens to be `Li`'s only
consumer), not by construction. The maintenance-invariant remark is unsupported.

### S1c. Test 1 of `meas:invariance` (160/160) is 100% vacuous.

`audit/a2-residual.mjs`: over the 160 Galois closures sampled, `Delta` removes
nothing from **any** of them — `Delta = identity` in 160/160 cases. The test
cannot fail, and contributes zero evidence. (By contrast the Cn tests are
genuinely non-trivial: `Delta` moves on 45.2% of the 58-element sample, 43.6% of
the 160,000 exhaustive closures, and 41.9% of the 92,880 scored sets. Those
figures are worth stating in the paper; the 160/160 is not.)

### S2. `meas:access` (8,240/8,240 accessible) does not reproduce and is FALSE.

The paper: "Every admissible set admits an admissible construction order from
`empty`: verified 8,240/8,240 across four 16-element ground sets. Formally, for
every admissible `X != empty` there is `e` in `X` with `X \ {e}` admissible."

**Counterexample, verified (`audit/a8-access.mjs`):**

    admissible({Ex,Op}) = true   [closure [], warrant [], hazard [], ground false]
    admissible({Ex})    = false  [warrant: Ex unwarranted]
    admissible({Op})    = false  [closure L1a open; Op unwarranted; ungrounded]

`{Ex,Op}` is admissible with no admissible predecessor. Re-deriving the four
16-element grounds named in `algebra/research/cfp-2-clutters-repair.md` §5.3
against `tables.admissible()`:

| ground (first 4 symbols) | claimed \|Adm\| | re-derived \|Adm\| | inaccessible |
|---|---|---|---|
| `Pl Im Cd Pf ...` | 64 | **240** | 1 |
| `Op Uc Py Tr ...` | 480 | **1488** | 1 |
| `Fl Xm Au Rl ...` | 656 | **1079** | 1 |
| `Pl Li Ad Sl ...` | 7040 | **1773** | 17 |
| total | **8240** | **4580** | **20** |

Not one of the four counts matches, the total is off by 3,660, and there are 20
inaccessible admissible sets, not zero. Full witness list:
`{Ex,Op}`, `{Bs,Sh,Sl}`, `{Bs,Oa,Sl}`, `{Ad,Ct,Im,Oa}`, `{Ct,Im,Oa,Sl}`,
`{Bs,Ct,Im,Oa}`, `{Ad,Ct,Oa,Pl,Sh}`, `{Ct,Oa,Pl,Sh,Sl}`, `{Bs,Ct,Oa,Pl,Sh}`,
`{Aw,Bs,Sl}`, `{At,Bs,Sl}`, `{At,Ct,Im,Li}`, `{Ad,At,Ct,Im}`, `{At,Ct,Im,Sl}`,
`{At,Bs,Ct,Im}`, `{Ad,At,Ct,Pl,Sh}`, `{At,Ct,Pl,Sh,Sl}`, `{At,Bs,Ct,Pl,Sh}`.

**Provenance:** `8240` occurs in exactly two places in the repo — a prose table
in `algebra/research/cfp-2-clutters-repair.md:451` and a *comment* in
`formal/v2/antiexchange.mjs:4`. There is no script and no output file. This is
the documented failure mode: an agent-authored markdown table promoted to a
`measurement` environment. (The four counts may have been produced under an older
admissibility definition; either way the paper asserts it of the current one, and
the formal statement it makes is refuted.)

---

## Severity 2 — WEAKENS A CLAIM

### S3. `meas:arity` censuses a different clause system from the one every other measurement uses.

`audit/arity/` reproduces `algebra/arity.ts` exactly: 34 element-expressible
clauses, 31 requirement + 3 prohibition, 17 bijunctive (50%), widest 5 literals,
widest = `L1: Pl -> Li|Ad|Sl|Bs`. **The arithmetic is confirmed.**

But `arity.ts` reads the *raw* `LAWS` table in `viz/src/data.ts`, whereas every
other measurement (`meas:vacuous58`, `meas:ablation58`, `meas:frag`,
`meas:invariance` test 4) uses `LSTAR`, the hand-corrected law system in
`tables.mjs`. Both happen to yield 31 clauses, and the paper juxtaposes them as
if they were the same 31 ("31 requirement" in `meas:arity`, "31 closure" in
`meas:ablation58`). **They are not: 12 of the 31 differ** (`audit/a6-final.mjs`).

| | `arity.ts` (censused) | `LSTAR` / the f10 CNF (used) |
|---|---|---|
| L1a term for `Pl` | `Ex\|Tp\|At` (3 alts) | `Ex\|Tp\|At\|Oa\|Sv\|Cl\|Cp\|St\|Wg` (9 alts) |
| L2 exit term | dropped as prose | `Sl\|Ad\|Bs\|Tr\|Cv\|Wq\|Rd\|Ps\|Sv\|Im\|Of` (11 alts) |
| widest closure clause | **5 literals** | **12 literals** |
| bijunctive closure clauses | 16 / 31 | 13 / 31 |
| widest clause in the whole 93-clause CNF | n/a | **34 literals** (`warrant/Ex`) |
| bijunctive across the whole CNF | n/a | **19 / 93 = 20.4%** |

So "the widest has 5 literals" and "a 50% fragment is [median-closed]" are true of
a clause set that appears nowhere else in the paper. Of the system actually
scored, the widest clause has 34 literals and 20.4% is bijunctive. The
conclusion ("the system is not median-closed") survives a fortiori; the
quantities do not.

Minor, in the same measurement: `arity.ts` drops 54 of 85 `(subject, term)` pairs
as prose or mixed. Only 4 of the 54 are mixed (`L6 (Sv|mechanical trigger)`,
`L7 Rd|Ps|liquidation capacity`, `L8 Xm|named custodian...`, `L15 Tg|bounded
emergency process`), and all four are narrow, so the mixed-term drop does **not**
materially bias the bijunctive fraction upward — I checked for this and it is not
the problem. The problem is the source table, not the filter. Note also that
`L7`'s `Rd|Ps` is discarded by `arity.ts` but retained by `LSTAR` as
`Cd -> Rd|Ps|Li|Ad|Sl|Bs`, i.e. the two systems disagree on the same law.

### S4. `meas:clutter` attributes two derived objects to the recorded prohibition table.

The paper: "Of the 20 recorded prohibition rows, only 3 are enforced positive
element sets, namely `{Fl,Xm}`, `{Fl,Au,Rl}` and `{Fl,Cp,Cl,Pl,Cd}`."

Re-derived from `data.ts HAZARDS` (`audit/a5-gen-clutter.mjs`):

* `|HAZ| = 20`. **Confirmed.**
* Rows naming no element: `X3,X5,X6,X7,X8,X12,X14,X16,X17` = **9. Confirmed.**
* Rows naming exactly one element: 8 (`X1,X4,X9,X10,X11b,X13,X15,X18`).
* Rows naming >= 2 elements: **`X2{Fl,Cp,Cl,Pl,Cd}`, `X11a{Uc,Aw,At}`, `X19{Xf,Aw}`.**
* `{Fl,Xm}` is a recorded row: **false**. `{Fl,Au,Rl}` is a recorded row: **false**.

Two of the three sets named in the measurement are not prohibition rows at all.
They are the minimal atomic-scope-break witnesses derived in
`formal/FINDINGS.md` §12.1 and later folded into the invented hazard `X21`/`X20`
(which does not exist in the 20-row table either). Of the 20 recorded rows, the
ones with a >= 2-element positive projection are `X2`, `X11a`, `X19` — and only
`X2` survives the negation-word filter (`f10.out`: `HAZ_PROJ eligible = 1`,
`listed: 1` clause in the CNF).

The blocker arithmetic *for the family as stated* is correct: `|b(Haz)| = 9`
(`{Fl}` plus the 8 products `{Xm} x {Au,Rl} x {Cp,Cl,Pl,Cd}`), `b(b(Haz)) = Haz`
holds, ground set = 8 elements. **Confirmed.** But the family is not the clutter
of the theory that is actually enforced: under `bansCond`/the f10 CNF, `X21` is
`{Fl,Xf},{Fl,Rl},{Fl,Of}` and `X2` is six triples `{Fl,c,p}`. Against those,
`{Fl,Au,Rl}` strictly contains `{Fl,Rl}` and `{Fl,Cp,Cl,Pl,Cd}` strictly contains
`{Fl,Cp,Pl}` — so the stated "genuine 3-member clutter" is not an antichain of
minimal forbidden sets, and the real blocker has **3** members, not 9.

### S5. `meas:width` is a Monte-Carlo on synthetic random clause sets, not a measurement of this vocabulary, and no code for it exists.

`0.925 / 0.710 / 0.655 / 0.684` and the `0.75 -> 0.13` union-closure drop occur in
exactly one place in the repo: a prose table at
`algebra/research/cfp-1-common-fixpoints.md:401-404`. The surrounding text (§5.4)
states: *"I generated atlases of your exact clause shape ... on `2^8`, and
measured (`verify3.py`)"*. **`verify3.py` does not exist anywhere in the repo**
(`find` for `verify*.py` returns only `algebra/solvers/GP-LOG/verify.mjs`, an
unrelated file). Neither does `verify2.py`, cited for the 94.5%/25,600-seed figure
in the same document.

The paper's own status convention says a Measurement is "established
computationally against the corpus or by exhaustive enumeration, with the
instance and bound stated". This one is neither: it is randomly generated
8-element atlases, the instance is not stated, and the generating code is absent.
It should not be a `measurement`.

**And its concluding sentence is false on its own numbers.** `meas:width`:
"The observed 59% lies in the `w in [2,4]` band." The band it cites is
`0.710 / 0.655 / 0.684`, whose minimum is 0.655. **0.59 < 0.655**, so 59% lies
*below* the band, not in it. Separately, the quantity being compared is wrong:
the synthetic column is `Pr[union of two admissible sets is admissible]`, whose
measured value on the actual corpus is **90.3%** (`f67b.out:4`), not 59%. The
59% is a *certification-by-F* rate — a different quantity entirely.

### S6. `meas:vacuous`: the slack range is wrong, and half the measurement is untraceable.

* "exact in 0 of 18 seed-instances" — **confirmed**: 4 (10-element) + 8
  (20-element) + 6 (58-element) = 18, exact in none.
* "`x_inf = top` on every seed at 10, 20 and 58 elements" — **confirmed**.
* "slack 1--39" — **wrong**. Extracted from the rerun (`audit/a7-cnf.mjs`):
  10/20-element slacks `[1,1,3,1,2,2,20,2,20,1,1,1]`, 58-element slacks
  `[58,9,14,39,34,34]`. **Range is 1--58, not 1--39.** The 58 is seed `{Of}`,
  where the observed upper bound is empty; if that instance is excluded the paper
  should say so, and it would then also have to drop to 17 seed-instances.
* "On synthetic operators of the present shape the iteration was sound 2000/2000
  and exact 2000/2000 with zero slack" — traces only to a prose cell in
  `algebra/research/cfp-1-common-fixpoints.md:450`. No script, no output file.

### S7. `meas:invariance`'s "231,773 distinct closures" is not a reproducible quantity.

`f11.mjs` builds its 58-element sample from `200,000` draws of
`Math.random() < 0.25` with no seed. Re-runs (`audit/f11-rerun.out`, `a2`):

| run | distinct Cn-closures |
|---|---|
| committed `f11.out` | 231,773 |
| audit re-run 1 | 231,771 |
| audit re-run 2 | 231,767 |

The figure is the size of a random sample, not a property of the system, and the
paper quotes it to six significant figures as if it were determinate. (The
*ratio* — 100% — is stable across re-runs; only the denominator is noise.)

### S8. `meas:frag` silently switches universes and omits the base rate.

* `|F|/|Adm| = 0.478` and `[11026, 23055)` — **confirmed** against `f467.out`:
  `|F| = 11026`, `|Adm| = 23055`, `11026/23055 = 0.4783`. But `|Adm| = 23055` is
  computed over the **20-element** test universe `2^U`, not over `2^El` with
  `|El| = 58` as the paper's `Adm` is defined. Nothing in `meas:frag` says so.
* "certifies 59% of live protocol pairs with no errors" — **confirmed** against
  `f67b.out`: `1225 (58.9%), of which wrong: 0`, over 2,080 pairs of the 65
  admissible live decompositions. This figure *is* over the 58-element corpus.
  So the two numbers in one sentence come from two different ground sets.
* Omitted, and material: `f67b.out` also records that **1,879 of the 2,080 live
  pairs (90.3%) already have an admissible union**. The fragment certifies 1,225
  of those 1,879 — i.e. 59% is well *below* the base rate of successful
  composition, and the fragment's value is soundness (0 false certifications),
  not coverage. As written the 59% reads as a success rate.
* The interval `[11026, 23055)` is correct but near-vacuous: the upper end is
  simply `|Adm|`, and `f467.out` already shows `Adm` has 1,866,616 join failures.

---

## Severity 3 — COSMETIC / HYGIENE

### S8b. `X21` — the rule doing 32/72 of all the work — is not a prohibition of the vocabulary, and `meas:ablation58` and `meas:clutter` are computed against two different executable models.

`viz/src/data.ts` records hazard rows `X1`..`X19` (with `X11a`/`X11b`) = 20 rows.
**There is no `X21`.** It exists only as hand-coded JS at `tables.mjs:145`:
`if (S.has("Fl") && has(S,"Xf","Rl","Of")) o.push("X21")`. `meas:ablation58`
correctly calls it "hand-written", but `meas:clutter` then asserts that the
enforced prohibition clutter has exactly 3 members, none of which mentions `Xf`
or `Of` — i.e. the clutter measurement omits the rule responsible for 32 of the
72 seeds' exclusions. The two sets `{Fl,Xm}` and `{Fl,Au,Rl}` that `meas:clutter`
does name are hard-coded in a *different* model,
`algebra/solvers/GP-LOG/model.mjs:188-197` (`xl1Forbidden`, `xl2Forbidden`),
sourced from `formal/FINDINGS.md` Q12.1. So `meas:ablation58` and `meas:clutter`
describe two different admissibility models and the paper presents them as one.

### S9. Committed evidence files do not match the committed scripts.

* `formal/v2/f11.out` lines 50-51 duplicate lines 48-49 (`seed {Pl}` and
  `seed {Cd}` at 58 elements appear twice). The loop in `f11.mjs` iterates over
  six seeds and my re-run emits six lines. The committed `.out` was edited or
  concatenated by hand and is not the output of the committed script.
* `formal/v2/f467.out` **ends in an uncaught `TypeError`** at `f467.mjs:89`
  (`ELEMS[e].group` on an undefined element, because `p.syms` is not filtered
  through `T.SYMS`). Everything from `// coverage on the corpus` onward — the
  live-protocol and live-pair coverage block — never ran. The pair figure was
  later recovered by `f67b.mjs`, so no number is lost, but a committed output
  file that terminates in a crash should not be cited as evidence.
* `FINDINGS-V2.md:946-947` quotes `total DPLL calls this run: 45467` where the
  committed `f10.out:270` says `46067`. The narrative was written against an
  earlier run than the committed output.
* **`algebra/arity.ts` cannot run as committed.** It does
  `import { LAWS, HAZARDS, ELEMENTS } from "./data.ts"`, and `algebra/data.ts`
  does not exist (`ls` fails; the table lives at `viz/src/data.ts`). I had to
  stage a copy in `audit/arity/` to reproduce `meas:arity` at all. A measurement
  whose script does not execute from a clean checkout is not reproducible
  evidence.
* `remark[Method]`'s "Total cost 3.15 seconds" is presented as the cost of the
  72-seed measurement. `FINDINGS-V2.md:946` annotates the same figure as
  "entire f10.mjs: validation + **88 seeds** + soundness + attribution".

### S10. `meas:unique` measures the wrong property (though the number happens to survive).

`antiexchange.mjs` computes `minimal = gens.filter(g => g.length === minSize)` —
generating sets of **minimum cardinality**, not subset-minimal (irredundant)
generators. A convex geometry asserts the latter. I implemented the correct test
(`audit/a5-gen-clutter.mjs`): on this data both give **1,696 unique, 0
non-unique**, so the reported number stands. The test is nonetheless not testing
what the surrounding definition says. Also confirmed: the `A.size > 8` guard in
that loop skips nothing here (max closed-set size is 7).

`meas:antiexchange` reproduces exactly: 1,697 closed sets (size histogram
`{0:1, 1:48, 2:1134, 3:292, 4:147, 5:67, 6:5, 7:3}`), 22,585 premises, 0
violations. Note that anti-exchange for a *definite* closure is an immediate
consequence of `prop:dag` (acyclicity): `x in Cn(A+y)` and `y in Cn(A+x)` would
require a cycle. The measurement is redundant with a proposition already in the
paper.

### S11. Labelling errors in `meas:invariance`.

* The fourth test is described as "the scored **admissibility** predicate". It is
  `Gcond(X) = gammaOpen(X).length === 0`, i.e. the scored **closure condition**
  only. Warrants, prohibitions and grounding play no part. (`f11.mjs` itself
  labels it "the SCORED closure condition ... (L*)".)
* "four **independent** tests": tests 2 and 3 use the same operator `Cn`, and
  test 3's universe is a subset of test 2's. All four share the same `Delta`.
  At most two are independent.
* "`Cn` *exhaustively* over `2^20` (160,000 closed sets)" — this one is **clean**.
  I verified (`audit/a1-invariance.mjs`) that all 1,048,576 subsets are
  enumerated, that the `[...C].every(e => U20.includes(e))` filter discards
  **zero** of them, that the 160,000 distinct closures reproduce exactly, and
  that `Delta` is non-trivial on 69,824 (43.6%) of them. The concern that the
  filter hid escaping closures is unfounded. The concern in S1 — that `U20`
  itself is unrepresentative — is the real one.

---

## Figures confirmed exactly

Re-derived and matching to the digit:

| claim | source | verdict |
|---|---|---|
| `\|El\| = 58`, `\|War\| = 27` | `tables.mjs` `MECH`, `CONSUME` | exact |
| `meas:notidem` (Delta not idempotent) | 18,053 witnesses in 200k random sets | confirmed |
| 93 clauses = 31 closure + 27 warrant + 21 grounding + 14 negative | `f10.out` `{closure:31, warrant:27, listed:1, ban:13, ground:21}`; 1+13 = 14 | **exact** |
| 79 positive = 31+27+21 | arithmetic on the above | **exact** |
| 3,553 candidate slots; 61 exclusions | `sum(cand)` and `sum(exc)` over `f10-rows.json`, 72 rows | **exact** |
| 37 of 72 seeds at top | `f10-rows.json`, `exc == 0` count | **exact** |
| min 0.0 / p25 0.0 / median 0.0 / p75 2.1 / max 12.2 / mean 1.8 | `f10.out` | exact |
| X21 32/72, X2 8/72; positive fragment excludes 0 | `f10.out` Parts G and J | exact |
| 3,938 inclusion certificates; 9,600 sampled completions | `f10.out` Part F | exact |
| 305,272 differential-test sets, 0 mismatches | `f10.out` | exact |
| 3.15 s total cost | `f10.time` (`WALL 3.15 s`) | exact |
| 34 / 31 / 3 / 17 bijunctive / widest 5 | `arity.ts` re-run in a clean dir | reproduces (but see S3) |
| 160,000 closed sets, exhaustive over `2^20`, 100% | `audit/a1` | **exact, and genuinely exhaustive** |
| 92,880 scored sets, 100% *on `U20`* | `audit/a3` | reproduces (but see S1) |
| `\|b(Haz)\| = 9`, `b(b(Haz)) = Haz`, 8 elements | `audit/a5` | exact for the family as stated (see S4) |
| 1,697 closed sets, 22,585 premises, 0 violations, 1,696/1,696 | `audit/a5` | exact |
| `\|F\| = 11026`, `\|Adm\| = 23055`, 47.8%, 58.9% -> 59% | `f467.out`, `f67b.out` | exact (see S8) |
| 18 seed-instances, exact in 0 | `audit/a7` | exact |

---

## Summary table

| item | verdict |
|---|---|
| `meas:invariance` | **REFUTED** — false on the actual operators; 116 counterexamples at size <= 4; test 1 vacuous; test 3 clean |
| `meas:access` | **REFUTED** — 4,580 not 8,240; 20 inaccessible sets; witness `{Ex,Op}`; no generating code |
| `meas:width` | untraceable to code; synthetic, not a measurement of this vocabulary |
| `meas:arity` | reproduces, but censuses a clause system used nowhere else (widest 5 vs 34; 50% vs 20.4% bijunctive) |
| `meas:clutter` | 2 of 3 named sets are not recorded rows; blocker arithmetic correct for the wrong family |
| `meas:vacuous` | slack range 1--58 not 1--39; synthetic half untraceable |
| `meas:frag` | numbers exact; two different ground sets in one sentence; base rate (90.3%) omitted |
| `meas:vacuous58` | **fully confirmed** |
| `meas:ablation58` | **fully confirmed** — the clause arithmetic is exactly right |
| `meas:notidem` | confirmed |
| `meas:antiexchange` | confirmed (redundant with `prop:dag`) |
| `meas:unique` | number confirmed; script tests minimum-cardinality, not subset-minimal, generators |
