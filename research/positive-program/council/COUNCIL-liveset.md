# Council proposal — the live-set table `ℓ` and its dissolution test (T3)

## 0. Verdict in one paragraph

`ℓ` is testable in two days on three conditions. **Live-sets must be intervals, not arbitrary
subsets** — intervals on a line are a Helly family, so pairwise co-liveness implies global
co-liveness, the only thing licensing a table of *pairwise* failures as the whole obstruction
story; arbitrary subsets manufacture contextuality that is pure coding freedom. **Stratum and
group are both withheld** — group is a near-perfect proxy for stratum (G05/G06→3, G08→2,
G12→4), so handing over group hands over the answer through another column. Stratum instead
becomes a *second, independent* quantity compared against `ℓ`: convergent validity, or
withdrawal of the paper's "stratum reads as the horizon chain" claim. That comparison is worth
more than the input. **82.4% is retired, not re-tested** — its population does not parse
(1,711 = C(59,2), not C(60,2) = 1,770) and it was computed after `X21` was in hand. I
pre-register a different number, derived from the prohibition table in advance, and I
pre-register the **survivor** as well as the dissolutions. A retrofit dissolves everything; a
theory names what stays.

## 1. Design

### 1.1 Carrier and assignment protocol

`ℓ(e)` is a **non-empty closed interval `[lo,hi]` of `H`**: two integers in `0..4`, `lo ≤ hi`.
Fifteen admissible values, not thirty-one. Defense, in order of weight:

1. **Helly.** Intervals on a chain are Helly of dimension 1: pairwise intersection ⟹ common
   point. So `⋂ᵢ ℓ(eᵢ) ≠ ∅` is decidable from pairs and the Abramsky–Brandenburger global
   section exists automatically. The corpus data *is* pairwise (1,830 pairs); without Helly the
   pairwise test is not a test of the k-ary claim. With arbitrary subsets,
   `{h₀,h₂},{h₀,h₄},{h₂,h₄}` pairwise intersect with empty meet — artifact, not obstruction.
2. **Semantics.** A gapped live-set asserts an effect observable, then not, then observable
   again. No definition in `STRUCTURE-DEFINITIONS.md` supplies such a mechanism.
3. **Direction of the favour.** Intervals do not flatter the hypothesis: two random intervals
   on a 5-chain are disjoint w.p. 70/225 = 0.311; two random non-empty subsets, 180/961 = 0.187.
   Intervals dissolve *more* by chance — hence the null must be drawn from the same 15-value
   space, which is exactly why this choice moves the null distribution.

**Escape hatch, capped.** An assigner may emit `NONINTERVAL` + subset + one sentence; primary
analysis takes the convex hull. If **>6 of 58 elements** are flagged by ≥2 assigners, the
interval constraint is refuted, the primary reruns on subsets against the subset-null, and that
is stated in the abstract.

**Default under underdetermination: `[h₀,h₄]`.** Maximally conservative — a full-chain element
co-lives with everything and dissolves nothing, so thin definitions *cost* dissolution power
rather than manufacturing it and there is no tie-break to game. Instrument wording: *"If the
definition does not say when the effect stops being observable, write `[0,4]`. Guessing is
worse than abstaining."*

### 1.2 The barrier — the crux

**Decision: stratum and group are inputs to nothing; they are a second, independent quantity.**

The assigner sees one artifact, passed **inline in the prompt with no filesystem access to the
repository** — that, not directory permissions, is the enforcement mechanism:

- `blind/liveset/PACK/elements-blind.jsonl` — 58 lines `{"id":"E##","name":…,"definition":…}`,
  randomized order, **opaque IDs** (real symbols absent: a model that has read the atlas
  recalls `Fl`).
- `blind/liveset/INSTRUMENT-ELL.md` — §1.1 as a one-page manual.

Withheld: `paper/formal-data.tex`, `paper/atlas.tex`, all of `algebra/`, the prohibition rows,
`X21`, the failing-pair lists, `ar`, this document. `scrub_defs.py` strips other element
symbols, `G0#–G1#` tags, stratum digits, `L##`/`X##` ids, and the literal chain wording
(intra-transaction / intra-block / epoch / challenge window / governance timelock). A **leakage
audit** by a fourth model — "does any line reveal a 5-level ordinal grade?" — must return zero
hits; transcript committed. `SEALED/id-map.json` is hashed into the pre-registration and opened
only after all responses exist.

### 1.3 Reliability

**Three assigners, full 58-element overlap, cross-vendor** (Claude Opus, GPT-5.6 via
`codex exec`, Grok 4.5), independent sessions. Three sessions of one model do not evidence
independence; three vendors do. ~2 hours.

Statistic: **Krippendorff's α, ordinal difference function, on `lo` and `hi` separately**;
Fleiss' κ over the 15-value nominal space as harsh secondary; mean Jaccard reported. Threshold:
`α_lo ≥ 0.67` **and** `α_hi ≥ 0.67` (Krippendorff's tenability floor) to proceed — below
either, **the run is discarded and no dissolution figure is reported at all**. `α ≥ 0.80` is
"reliable". Consensus `ℓ* = [median(lo), median(hi)]`; medians are monotone and each assigner
has `lo ≤ hi`, so `ℓ*` is always valid. No adjudication step exists, so none can be made while
looking at the outcome — the prior effort's 16.3-point failure mode is structurally unavailable.

### 1.4 The null — specified before unsealing

- **N1 (primary), label permutation.** Permute the 58 consensus intervals across the 58
  elements; multiset preserved exactly, only the element↔horizon pairing destroyed. 10,000
  draws, seed 20260805. Fisher–Pitman exact-conditional test; primary because the alternative
  *is* "the pairing carries information".
- **N2, matched random intervals.** i.i.d. from the empirical marginal interval distribution.
- **N3, within-stratum permutation** (uses the sealed key). If `ℓ` adds nothing beyond stratum,
  N3 reproduces the observed value. This isolates the increment of `ℓ` over the column it is
  accused of copying.

`score_ell.py` and `null_ell.py` are written, run end-to-end on a synthetic `ℓ`, and
**SHA-256'd into `PREREG.sha256` before any response file is opened.**

**Effect size to beat (N1):** one-sided `p < 0.001`; observed above the 99.9th null percentile;
**and raw margin `D_obs − median(D_null) ≥ 25 pp`**; and `(D_obs − mean_null)/sd_null ≥ 3`. The
margin clause answers the challenge directly: if the null median lands near 75%, the claim is
dead regardless of `p`. N3 at `p < 0.05`; failing N3 while passing N1 is reported as
*"`ℓ` is a re-derivation of stratum"* — a real negative, not a footnote.

### 1.5 Scoring population — pre-registered

**Primary: 72-decomposition / 61-protocol — 1,830 pairs, 185 failures** (`atlas.tex`,
`meas:whereitfails`: 147 arm `X21`, 37 arm `X2`, 6 arm `X19*`). It is the published headline so
a verdict moves the actual claim; its breakdown is referee-auditable without re-derivation; and
the 60-construction population is arithmetically inconsistent (1,711 = C(59,2), while 60
constructions give 1,770). I will not pre-register on a population whose cardinality does not
parse. The 60-construction run is an unweighted secondary, reported only after the architect
states whether it is 59 or 60.

### 1.6 The residue, mechanically

Given `ℓ*` and construction `S ⊆ E`:

1. Conditional row `X` has antecedent terms `T₁…T_k` (disjunctions); witnesses are tuples
   `(e₁∈T₁∩S, …, e_k∈T_k∩S)`.
2. `X` is **armed at `h`** iff some witness tuple has `h ∈ ⋂ᵢ ℓ*(eᵢ)` — with intervals,
   `maxᵢ loᵢ ≤ minᵢ hiᵢ`, O(∏|Tᵢ|). `X` is **dissolved** iff every tuple has empty meet.
3. A failing pair is **dissolved** iff every row it armed is dissolved. `D = |dissolved|/185`.
4. **Hypergraph `𝓗(ℓ*)`: vertices are `(e,h)` pairs, not elements.** For each surviving row and
   each maximal co-live band `B`, one hyperedge `{(e,h) : e ∈ ⋃ᵢ Tᵢ∩S, h ∈ ℓ*(e) ∩ B}`.
   Element-vertices would make residue growth impossible and the refutation condition vacuous;
   `(e,h)` vertices make growth reachable, because wide live-sets split rows into several bands.
5. **GYO / Graham reduction** to fixpoint: delete any vertex in exactly one hyperedge; delete
   any hyperedge contained in another. **`R(ℓ*)` = hyperedges remaining.** `R = 0` ⟺ α-acyclic
   ⟺ (Vorob'ev) every locally consistent family extends globally ⟺ no obstruction. Surviving
   hyperedges *name* the obstruction. Baseline `R₀` uses `ℓ ≡ [h₀,h₄]` everywhere; reference
   `R₀ = 4`.

**Residue growth is a reachable refutation.** `R(ℓ*) > R₀` means scoping *created* obstruction,
which happens precisely when the conservative default is taken often enough that rows fan out
into multiple bands. That is my instrument's honest failure mode and I want it live.

## 2. Pre-registered hypotheses and thresholds

Directions fixed; Holm–Bonferroni at family α = 0.05 across H1–H5.

- **H1 (aggregate).** `D ≥ 0.70`, point prediction `D ≈ 0.795`. Derivation from the prohibition
  table alone, stated now: `X21` = `Fl` co-present with `Xf`/`Rl`/`Of`; if `Fl` is
  intra-transaction and cross-domain elements are not, all 147 `X21` pairs dissolve →
  147/185 = 0.795. I do **not** predict 82.4%.
- **H2a.** `ℓ*(Fl) = [h₀,h₀]`.
- **H2b.** `lo(ℓ*(Xf)) ≥ 2`, `lo(ℓ*(Rl)) ≥ 2`, `lo(ℓ*(Of)) ≥ 2`.
- **H2c — load-bearing.** `ℓ*(Fl) ∩ ℓ*(Cp) ≠ ∅` **and** `ℓ*(Fl) ∩ ℓ*(Cl) ≠ ∅`, so the 37 `X2`
  pairs **survive**. I predict a non-dissolution on the same element driving the dissolutions.
  H2a is arguably pretraining common knowledge; H2c is not, and it is what separates theory
  from fit.
- **H3 (residue).** `R(ℓ*) = 3`, residual `{Fl@h₀-band, {Cp,Cl}, {Pl,Cd}}`; accepted at `≤ 3`.
- **H4 (convergent validity, no direction assumed).** Spearman `ρ(lo(ℓ*), stratum)` and
  quadratic-weighted κ, with CIs. `ρ ≥ 0.6` supports "stratum reads as the horizon chain";
  `ρ < 0.3` **requires withdrawing that reading from the paper**. Either way, a deliverable.
- **H5 (null).** N1 as in §1.4.

## 3. Analysis procedure

1. Freeze `PREREG-ELL.md`, `score_ell.py`, `null_ell.py`; write `PREREG.sha256`; record it in
   `council/COUNCIL-LOG.md`; commit. **No later edit to these three is valid.**
2. Build + scrub the pack; run the leakage audit; commit the transcript.
3. Run three assigners → `RESP/ell-A{1,2,3}.jsonl`.
4. Compute reliability. **If α fails, stop; report only the reliability failure.**
5. Form `ℓ*` by coordinatewise median. Unseal `id-map.json`.
6. `score_ell.py` → `D`, per-row dissolution counts, `R(ℓ*)`, `R₀`, H2a–H2c booleans, H4.
7. `null_ell.py` → N1/N2/N3 distributions, percentiles, margins, `p`.
8. Emit one table: every pre-registered threshold beside its observed value and PASS/FAIL. No
   prose between step 7 and this table.

## 4. Falsification conditions

Any one kills the live-set structure:

- `D < 0.70` on the 185 population.
- `D_obs − median(D_null,N1) < 25 pp`, or `p ≥ 0.001` — random pairings dissolve as well as the
  assigned one, and 82.4% meant nothing.
- `R(ℓ*) ≥ 4` — residue did not shrink, or grew.
- **H2c fails while H1 passes** — everything dissolved, including what should not have. This is
  the retrofit signature and falsifies *harder* than a low `D`, because it shows the instrument
  has no discriminating content. I would rather see `D = 0.79` with `X2` surviving than `D = 0.99`.
- N3 not beaten at `p < 0.05` — `ℓ` is stratum wearing a hat.
- Krippendorff `α < 0.67` — no verdict at all; the instrument is not an instrument.

## 5. Threats to validity and mitigations

| Threat | Mitigation |
|---|---|
| Definitions were written by people who saw stratum; residual leakage. | `scrub_defs.py` + independent leakage audit. H4 is the diagnostic: a suspiciously perfect `ρ` is itself leakage evidence, reported as such. |
| Conservative `[0,4]` default inflates widths, growing `R`. | Accepted — correct direction of risk. Width distribution reported. |
| Assigners know "flash loans are atomic" from pretraining. | Domain knowledge is what `ℓ` should encode, not answer-key leakage — but it makes H2a cheap, so H2a is reported separately and H2c carries the load. |
| Pairwise scoring cannot see higher-order obstruction. | Exactly what the interval constraint buys (§1.1). If the escape-hatch cap breaks, the pairwise inference is void and must be flagged. |
| Cross-vendor assigners share pretraining corpora. | Unresolvable in two days; report `α` noting independence is vendor-level, not causal. |
| Multiplicity across H1–H5. | Holm–Bonferroni, family α = 0.05. |
| Conditional-row inventory inconsistent: `formal-data.tex` names five (`X2, X18, X19*, X21, X11a*`), `algebra/reports/OP-CAT.md` four (`X1, X2, X18, X21`). | Compute `R₀` and `D` under **both**, report both; architect closes it (§6). |

## 6. Interface requirements on other surfaces

1. **Arity surface** assigns over the *same* blinded pack and opaque IDs, so `ar` and `ℓ` join
   on `id` without a second unblinding.
2. **Composition-predicate owner** exposes `composable(e1, e2, ar, ℓ) -> bool` with both tables
   as explicit arguments. N1 permutes `ℓ` holding `ar` fixed; if the predicate closes over its
   tables, the permutation test cannot be run at all.
3. **Prohibition surface** delivers `TARGET/prohibitions-conditional.json` with explicit
   term-lists, and closes the four-vs-five conditional-row discrepancy.
4. **Digraph surface** closes 15-vs-18 arcs before any density figure.
5. **Population owner** states whether the second population is 59 or 60 constructions.

## 7. What I would cut if we had one day instead of two

Keep: opaque-ID blinding, the interval constraint, the `[0,4]` default, H2a/H2b/H2c, N1, the
residue. Cut: N2 and N3 (state the stratum-increment question is unresolved — do not fake it);
the third assigner (two, cross-vendor, α unchanged); the 60-construction secondary; the
non-interval sensitivity arm (hard-constrain, report flag count as a limitation). Do **not** cut
the leakage audit or the pre-commit hash; they are what the exercise is for.

## DISSENT

**1. `ℓ` cannot bear on C1, and pretending otherwise repeats the original error.** `ℓ` only
*removes* co-liveness constraints, so its effect on constructibility is monotone upward:
coverage after scoping is weakly greater than before, by construction, for *any* `ℓ` including
a random one. A coverage gain attributable to `ℓ` carries zero bits. I decline to pre-register
`ℓ` against C1 and ask that this refusal be recorded rather than averaged with proposals that
accept the C1 tasking. `ℓ`'s targets are P1 (H1/H2/H3/H5) and the stratum question (H4);
coverage belongs to `ar` and the wiring predicate.

**2. Retire 82.4%.** Landing near it again would read as confirmation while being confounded
twice — the population does not parse, and the original was computed after `X21` was in hand. A
*different* pre-registered number (0.795, floor 0.70) derived from the prohibition table in
advance is worth more than recovering the old one, and is the only version a referee cannot
call a retrofit. If the architect insists on 82.4% as the headline, record this verbatim.

**3. The stratum decision is not negotiable within my surface.** If consensus hands the assigner
group or stratum, `ℓ` stops being an independent measurement and H4 evaporates. I would then
withdraw H1 and H3 as well, because the dissolution figure would restate a column assigned by
coders who had seen the corpus — the exact failure blinding was convened to fix.
