# Council proposal — the link to the completeness theorem

*Surface: does this experiment actually bear on C1–C4?*
All numbers below marked **[measured]** were computed during this audit against
`/root/DefiElements/expansion/*/specs/*.json` (60 apps) and
`/root/DefiElements/paper/formal-data.tex`. Scripts were throwaway; the queries are
restated so they can be re-run.

---

## 0. Verdict in one paragraph

The dependency argument is **valid but weaker than it is being used as**. It proves
that *some* assignment of `ar` and `ℓ` is sufficient to give `constructible` an
extension. It does not prove minimality — Definition 7 is *local*, so a partial
assignment gives C1 an extension on a sub-corpus, and I quantify that below. Worse,
it does not notice that the assignment space contains a **trivialising point**:
`ar(e) = ( ; )` and `ℓ(e) = H` for all `e` makes every wiring complete, every
composition legal, and C1 true and worthless. The dependency argument therefore
licenses the sprint but supplies no reason to believe its output will be
informative. On the tests: **T6 splits into two halves that behave completely
differently** — T6a (`D′ ⊇ D`) bears on *no* completeness clause and is at serious
risk of being **analytically true**, because `ar` is to be seeded from the same 29
requirement rows that `D` is derived from; T6b (72 sets wire totally) bears on a
strict, one-sided **surrogate** of C1 which I will call C1⁻ (support-wireability),
and which drops `β` entirely. **T3 bears on none of C1, C2, C3.** It measures the
*magnitude of the C4 violation*, and it is being reported as confirmation of P1,
which is marked `[imm]` and cannot be confirmed by any experiment. So the questioner's
suspicion is two-thirds right: **the sprint as scoped can refute C1 and cannot
confirm it, cannot touch C2, and its second test is a conservativity measurement
wearing a composition-theorem label.** I dissent, and I specify the third test.

---

## 1. Design — what I would add

### 1.1 The gap in the dependency argument (named)

The argument is: Def. 7's clauses quantify over `ar`, `λ`, `ℓ`; `λ` is fixed by
Def. 2; therefore `ar` and `ℓ` are exactly the free parameters, therefore C1 is not
a proposition. The scoping is genuinely well-chosen — `Π` does *not* occur in
Def. 7, so C1 really does become statable at the end of this sprint and not before.
That much I endorse without reservation. Three gaps:

**Gap A — sufficiency is not minimality.** Def. 7's clauses are conditions on
*matched pairs inside one construction*. Therefore `constructible(b)` depends only on
`ar↾supp(b)` and `ℓ↾supp(b)`. C1 is **sub-corpus-localisable**: a partial assignment
on `E₀ ⊆ E` makes C1 a proposition for exactly `{b : supp(b) ⊆ E₀}`. This is not
hypothetical. **[measured]** taking `E₀` = union of the supports of the ten largest
corpus applications gives `|E₀| = 39` and makes C1 statable and decidable for **31 of
60** applications; `|E₀| = 42` reaches 42 of 60; `|E₀| = 33` (top five) reaches 18.
So a partial assignment is real and it is cheaper.

**It is nevertheless the wrong economy, and the reason is directional.** The
sub-corpus `{b : supp(b) ⊆ E₀}` for frequency-greedy `E₀` is precisely the population
of *small, simple* applications — **[measured]** `|supp|` ranges 2–18, mean 9.75, and
a 25-element `E₀` captures only 13 apps, all short. Confirming C1 there is confirming
it where it was never in doubt. **Partial assignment is a valid cheap refuter and an
invalid cheap confirmer.** Since 58 rows is an afternoon and 42 rows is most of an
afternoon, the saving does not pay for losing the confirmatory direction. *Assign all
58.* But stratify the analysis by `|supp|`, so a refutation localises and a
confirmation cannot be carried by the easy tail.

**Gap B — the trivialising point.** C1 as a second-order statement — `∃(ar,ℓ). ∀b.
constructible(b)` — is a perfectly good proposition *today*, over a finite space, and
it is **true**, witnessed by the empty arity. This is Post's `P = {⊤}` degeneracy
reappearing one level up: the prior effort guarded against a degenerate *primitive
set* and this sprint has no guard against a degenerate *signature*. Coverage is
monotone-decreasing in linear port count; an assigner who is unsure and writes fewer
ports makes C1 easier, and "unsure" is the modal case given that **[measured]** 15 of
29 requirement rows are empty. **The sprint must report coverage jointly with a
tightness statistic and must have a negative control.** Coverage without a control is
the 71-of-72 number all over again.

**Gap C — `ar` may not be a function.** `INSIGHT-L1 §6` records that `Li` has three
distinct state machines across Aave / Comet / Maple, `Ix` four, `Cp` three. If one
symbol carries several genuine arities, `ar : E → C* × C*` is ill-defined and the
assigner must choose. Union-of-ports makes wiring *harder*; intersection makes it
*easier*. **The tie-break moves the verdict, so it must be pre-registered and the
sensitivity reported both ways.** The instrument brief anticipates *thin* definitions
and not *overloaded* ones; this is the larger hazard.

### 1.2 The barrier defect that voids T6a

`Definition 3` says `ar` is "not new fieldwork — seed from the 29 requirement rows,
which already encode it." `D` is the digraph *of those same 29 rows*. If `ar` is read
off the rows, then `D′ ⊇ D` is not retrodiction; it is a re-encoding, and it will
succeed for the same reason a translation preserves meaning. The same objection
retires the `23/24 single-group` corroboration, which is also measured on the rows.

**This is a forced choice and the council must make it explicitly:**

- **(i)** seed `ar` from the 29 rows — cheap, and **T6a carries zero evidential
  weight and must be struck from the pre-registration**; or
- **(ii)** assign `ar` from element *definitions only*, with the 29 requirement rows
  and `formal-data.tex:84–125` behind the barrier — T6a becomes real retrodiction,
  cost rises but stays inside two days for 58 rows.

Take **(ii)**. Option (i) is exactly the fitted-instrument failure recurring inside
the test designed to detect it.

### 1.3 The missing third test — T8, and it is the one that matters

Neither T3 nor T6 gives direct evidence for C1, for the reason below (§1.4). The
computation that does is PO-STR-6, and it is buildable now.

**T8 — Generation from the eight families, with a corruption control.**

1. **Extract a dataflow graph per Quint spec.** For each of the 57 `.qnt` files,
   nodes = `val`/`def`/`action`/`var` declarations, edges = name references. Prefer
   `quint parse --out ir.json`; fall back to a name-reference scan (files are ~140
   lines). Element-blind, so it can be written **during** the blind window.
2. **Label nodes with primitive families.** The map already exists and is
   pre-Σ: `INSIGHT-L*.md §5` names families against Quint definitions
   (`cpAmountOut`, `sharesFromAssets`, `presentFromScaled`, `isHealthy`, …). Unlabelled
   nodes are **residue**.
3. **Type the edges** using `ar` of the labelling family and check Def. 7 clauses
   (colour agreement, linearity, co-liveness via `ℓ`, boundary closure).
4. **Verdict per spec:** `generated` iff every node carries a family label and the
   graph is a complete well-typed wiring; else `residue-k`.
5. **The control, which is the whole point.** Run the identical pipeline on mutants:
   (m1) swap two edges; (m2) delete a conservation invariant; (m3) duplicate a
   linear-coloured value. 5 mutants per spec = 285 corrupt graphs. Report
   `sep = P(generated | real) − P(generated | mutant)`.

This is the direct successor of the experiment the prior effort has on record as
`−0.117`, and reproducing that number under `Σ` is the single most valuable
computation in the programme, because it is the one measurement the programme
already knows how to fail.

**Can it run inside the sprint?** Steps 1, 2 and 5 are element-blind and must be
written *before* the tables exist — which makes pre-registration free rather than
costly. Step 3 runs in an hour once `ar` and `ℓ` land. **Yes, inside the sprint,
provided the pipeline is built in parallel with the assignment rather than after it.**
That is a scheduling requirement, not a scope increase.

### 1.4 Clause-by-clause mapping (the answer asked for)

| test | C1 coverage | C2 separation | C3 Beth | C4 conservativity | P1 totality |
|---|---|---|---|---|---|
| **T6a** `D′ ⊇ D` | **none** — instrument validity only, and analytic under seeding (i) | none | none | none | none |
| **T6b** 72 sets wire | **partial, one-sided** — tests C1⁻ only | none (see §1.5) | none | none | weak local witness |
| **T3** dissolution | **none** | none | none | **adverse** — it *is* the C4 measurement | **none** — P1 is `[imm]` |
| **T8** (proposed) | **direct**, with control | none | none | none | supports |

**Why T6b is not C1.** C1 requires, for each `b ∈ Ref`, a diagram `D` with
`β⟦colim D⟧ = b`. T6b asks only whether the *recorded support set* admits some
complete wiring. A wiring with the right support and the wrong behaviour passes T6b
and fails C1. `β` — the independent trace semantics — is what the 57 Quint specs
supply and what T6b does not consult. So T6b decides:

> **C1⁻ (support-wireability).** For every `b`, `supp(b)` admits at least one
> complete well-typed wiring over `Σ`.

C1⁻ is *necessary* for C1 and, per Gap B, *trivially satisfiable*. Therefore **T6b
can refute C1 and cannot confirm it.** Refutation-only is respectable; mislabelling
it is not. Note also the quantifier mismatch: C1 is universal, so the pre-registered
`≥80% of 72 sets wire totally` is compatible with C1 being **false on 20% of the
corpus**. Any non-wireable application must produce a repair or an R2-style
exclusion certificate (an invariant holding of every primitive and violated by `b`),
or the 80% threshold is the prior work's 16.3-point adjudication under a new name.

### 1.5 C2 — the sprint cannot advance it, and not for the stated reason

The council's position is "C2 is false today because USDT/USD1 collide, and becomes
true with `Π`". Checked against the machine-readable corpus, **most of that is not
what the data says.** **[measured]**, over the 60 specs:

| named class | symmetric difference of supports | Jaccard | collides? |
|---|---|---|---|
| Tether USDT / USD1 | `{Au, Xf, Xm}` | 0.667 | **no** |
| LiquidMesh / KyberSwap | 7 elements | 0.222 | **no** |
| Binance Wallet / OKX DEX | 6 elements | 0.250 | **no** |
| Jupiter / 1inch | — | — | **1inch is not in the 60-app corpus** |

There is **exactly one** support collision in the whole corpus, and it is not on the
list: **Circle USDC vs World Liberty Financial USD1**, both with the identical
9-element support `{At, Au, Aw, Fz, Gp, Rd, Up, Xf, Xm}`.

Two consequences, both directive.

**(a) The C2 refuters that justify `Π` are not reproducible from the current
artifacts.** Three of four have already split on support alone. Before `Π` is bought
on the strength of "four known collision classes", those classes must be re-derived
from a stated population, or the argument for `Π` is resting on a number nobody can
re-run. That is a cheap, immediate task and I would do it before the sprint.

**(b) `ar` alone splits nothing, and the obstruction is not `Π`.** USDC and USD1 have
*identical supports*, hence identical port multisets under any `ar`, since `ar` is a
function of the element. They can only be split by a different **wiring** `w` — and
`w` is per-application data that the corpus does not record and this sprint does not
produce. **The sprint assigns `Σ`, which is element-indexed. C2 needs
application-indexed data.** Adding `Π` does not change this: `Π` is also
element-indexed (a parameter on colours `U`, `K`). It would split USDC/USD1 only if
the two are recorded as having different party shapes, which requires the same
per-application fieldwork. So the honest statement is: **C2 is blocked on `w`, not on
`Π`, and no assignment over `E` alone can unblock it.** T8's dataflow graphs are the
first artifact in the programme that would actually contain `w`.

---

## 2. Pre-registered hypotheses and thresholds

Fixed before any table is seen.

- **H1 (C1⁻, refutation-directed).** ≥ 55 of 60 corpus supports admit a complete
  wiring. *Stratified*: report separately for `|supp| ≤ 9` and `|supp| ≥ 10`.
  Refuted if any application with `|supp| ≥ 10` is non-wireable **and** no exclusion
  certificate is produced.
- **H2 (non-degeneracy gate, and it is a gate).** Mean linear-coloured input ports
  per element ≥ 1.0, and ≥ 40 of 58 elements carry at least one linear port.
  **If H2 fails, H1 is void regardless of its value** and the run is discarded.
- **H3 (T8 separation).** `sep = P(generated | real) − P(generated | mutant) ≥ 0.40`.
  Prior baseline on record: `−0.117`. **`sep ≤ 0` refutes the structure outright**
  and is the strongest falsifier in the sprint.
- **H4 (T8 generation).** ≥ 40 of 57 specs `generated`; no family found by ≥ 3 lanes
  appears as residue.
- **H5 (T6a, only under barrier (ii)).** `D′ ⊇ D` on ≥ 90% of arcs, acyclic. Struck
  entirely under barrier (i).
- **H6 (`ar` sensitivity).** Coverage under union-`ar` and intersection-`ar` differs
  by ≤ 10 points. A larger gap means the verdict is carried by the tie-break rule and
  must be reported as such.
- **H7 (C4 retraction audit).** For every prior failing pair now unstatable, a
  disposition in `{corrected-with-witness, re-derived-under-Σ, withdrawn}`. Threshold
  is not a number: **`withdrawn` must be reported as an open empirical prediction,
  not as a dissolution.**

---

## 3. Analysis procedure

1. Run H2 first, on the tables alone, before any outcome is computed. Gate.
2. Run the T8 pipeline (written during the blind window) on real specs, then on
   mutants, in one batch. Report `sep` before reporting generation rate.
3. Run C1⁻ over the 60 supports, stratified by `|supp|`, under both tie-break rules.
4. Run the retraction audit of §4 below.
5. Run T6a only if barrier (ii) held; verify by checking the assigners' access log.
6. Report C2 as **not addressed**. Do not report wiring-based separation from this
   sprint; there is no `w`.

## 4. Conservativity (C4) — my real answer

**The question as posed is a category error, and saying so is the answer.**

Conservativity of `σ : Σ_flat → Σ` requires `Th' ⊇ σ(Th_flat)` — it is a property of
an **extension**. What happens to `X21` is not extension. `P3` says that if
`ℓ(e) ∩ ℓ(e′) = ∅` the two are *unrelatable*, so `σ(X21)` is **not a `Σ`-sentence at
all**; the axiom has no image. The move decomposes into two:

- `σ_enrich : Σ_flat → Σ`, adding colours, ports and horizons. This **is**
  conservative — every flat model (a subset of `E`) expands to a `Σ`-structure by
  taking the empty wiring. But it is conservative *because it adds no constraint*, so
  the conservativity result buys nothing.
- `ρ : Th'_0 ⇝ Th'`, deleting `X21` and every prohibition whose arms are not co-live.
  This is a **theory contraction** in the AGM sense. Contractions are never
  conservative and conservativity is undefined for them.

So: **not a conservativity violation, and not automatically a correction.** The
correct test is a **retraction audit**, and it has three exits per retracted pair:
(i) a deployed positive witness showing the prohibition was wrong; (ii) a
re-derivation of the hazard as a `Σ`-sentence; (iii) explicit withdrawal, which is a
**falsifiable prediction that those pairs are jointly deployable**.

I ran the corpus half of this. **[measured]**, over the 60 apps:

- `Fl` occurs in **5** apps; `Xf` in **25**; `Rl` in **1**; `Of` in **0**.
- `X21` arms **159 of 1,770** pairs — consistent with the recorded 147/185, and the
  mechanism is now visible: **`X21`'s dominance of the failure count is a base-rate
  artifact.** `Xf` sits in 42% of applications; *any* co-presence prohibition with one
  arm at that frequency arms ~150 pairs mechanically. The 82.4% headline is measuring
  the removal of one high-base-rate row, not the depth of the scope insight.
- Exactly **one** deployed application contains `Fl` together with an `X21` arm:
  **Uniswap** (`Fl` + `Xf`). That is a genuine exit (i): a real, functioning protocol
  contradicts `X21` as an unqualified co-presence prohibition, **and the witness is
  independent of `ℓ`** — it does not beg the question the way the 82.4% does.

**Therefore my answer.** The `X21` retraction is a **correction on exit (i) for one
pair, and a withdrawal on exit (iii) for the other ~146.** We may claim continuity
with the prior results — we are not repudiating them, because the flat theory's
verdict on the corrected pair was refuted by deployed evidence the flat theory could
not represent. We may **not** claim that 82.4% of composition failures dissolved. The
honest sentence is:

> *One prohibition, responsible for ~80% of recorded failures by base-rate, is
> refuted by a deployed counterexample and is unstatable under `Σ`. The 146 further
> pairs it armed become unconstrained, which is a prediction we now owe evidence for,
> not a result we may bank.*

And the hazard to state plainly: **losing the vocabulary to express a constraint is
not the same as showing the constraint false.** That is exactly the `P = {⊤}` failure
mode at the theory level, and C4 is the only clause that guards against it. The
retraction audit is therefore not optional bookkeeping; it is the C4 obligation
(PO-STR-5 / PO-MOD-8) in the only executable form it has.

---

## 5. Falsification conditions

- `sep ≤ 0` on T8 → the structure is anti-correlated with reality, as the consumer
  table `C` was. **Kills it.**
- H2 fails → the signature is degenerate; every downstream number is void.
- Any application with `|supp| ≥ 10` non-wireable with no exclusion certificate →
  C1 is false on the corpus.
- Any recurrent (≥3 lane) primitive family lands as T8 residue → the eight families
  do not generate, PO-STR-6 fails.
- Coverage differs by >10 points between union-`ar` and intersection-`ar` → the
  verdict is an artifact of the coding manual.
- Any `X21`-retracted pair for which a `Σ`-sentence re-derives the hazard **and** the
  live-sets say the arms are not co-live → `ℓ` and the hazard analysis disagree; the
  horizon reading of `stratum` is wrong.

## 6. Threats to validity and mitigations

| threat | mitigation |
|---|---|
| **Analytic T6a** (seeding from the rows it retrodicts) | Barrier (ii): rows behind the barrier; verify by access log; else strike T6a |
| **Signature degeneracy** | H2 gate, evaluated before any outcome |
| **Coverage without control** | T8 mutation control; report `sep` before generation rate |
| **`ar` ill-defined on overloaded symbols** | Pre-register union tie-break; report intersection sensitivity (H6) |
| **Easy-tail confirmation** | Stratify all coverage by `\|supp\|` |
| **`β` circularity** | `β` = Quint dataflow graphs; ledgers record code-vs-profile *disagreements*, which is positive evidence of independence — cite `INSIGHT-L*.md §9` in the write-up |
| **Analysis written after the data** | T8 steps 1, 2, 5 are element-blind and must be committed before assignment begins; commit hash is the pre-registration |
| **C2 refuters unverifiable** | Re-derive the four classes from a stated population before citing them |

## 7. Interface requirements on other surfaces

1. **Barrier surface.** `ar` assigners must not see `formal-data.tex:84–125` (the 29
   rows), the prohibition table, `D`, or any failure list. `ℓ` assigners must not see
   any protocol or prohibition row. Enforce by serving a redacted definitions file;
   log every file opened.
2. **Instrument surface.** The coding manual must give a rule for **overloaded**
   elements, not only thin ones, and it must be the union rule.
3. **Analysis surface.** Commit the T8 pipeline before assignment starts.
4. **Reliability surface.** Report agreement on `ar` **separately for linear-colour
   ports**, since H2 and coverage both hinge on those and a good overall κ can hide
   disagreement exactly there.

## 8. What I would cut if we had one day instead of two

Cut **T3** and cut **T6a**. Keep the `ℓ` assignment (T8 step 3 needs it), but do not
compute or report dissolution — it bears on no clause and it is the number most
likely to be misreported. Keep the H2 gate, C1⁻ stratified, and T8 with the mutation
control. **T8 with its control is worth more than T3 and T6 combined**, because it is
the only computation in the set that can come out wrong in a way we would believe.

---

## DISSENT

**The sprint as scoped does not bear decisively on the completeness theorem, and one
of its two tests bears on none of its four clauses.**

Specifically: T3 measures the size of a theory contraction and is labelled a
confirmation of a property (`P1`) that is marked `[imm]` and cannot be confirmed by
measurement. T6a is analytic under the sprint's own cost-saving assumption. T6b tests
a surrogate of C1 that drops `β`, is one-sided, and is trivially satisfiable by a
degenerate table against which the sprint has no guard. C2 is not merely
"not advanced by this sprint" — it is **structurally out of reach of any assignment
over `E`**, because the live refuter (`Circle USDC` / `USD1`, identical 9-element
support — **[measured]**, and *not* the pair the council names) is separable only by
per-application wiring data that no table over 58 elements contains.

**What would make it decisive**, in priority order:

1. **Add T8** (§1.3) with the mutation control. Element-blind pipeline committed
   before assignment. This is the only direct C1 evidence available and it fits in
   the sprint.
2. **Add the H2 non-degeneracy gate** (§2), evaluated before any outcome. Without it
   a null result and a triumph are indistinguishable.
3. **Move to barrier (ii)** — `ar` from definitions, 29 rows behind the barrier — or
   strike T6a from the pre-registration. Do not do both halves of (i) and claim T6a.
4. **Replace "dissolution" with the retraction audit** (§4). Report *one corrected
   with a deployed witness, ~146 withdrawn as an open prediction*. Do not publish
   82.4% as a dissolution figure; it is a base-rate artifact of `Xf` appearing in 42%
   of the corpus.
5. **Before buying `Π`, re-derive the four collision classes.** Three of the four do
   not collide in the current machine-readable corpus.

I do not dissent from writing the tables. Writing them is right and the dependency
argument is right that nothing downstream can begin without them. I dissent from the
claim that writing them, plus T3 and T6, constitutes a decisive experiment on the
theorem. It constitutes a decisive experiment on **C1⁻**, one-sided, and an
unlabelled measurement of **C4**.
