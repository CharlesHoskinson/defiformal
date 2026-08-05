# Council proposal — measurement and inter-rater reliability

## 0. Verdict in one paragraph

The sprint is executable in two days and can produce a defensible instrument, but
only if three things hold that the prior effort did not. (1) The set-valued
judgements must be **decomposed into the smallest independently-codable decisions**
before anyone codes anything: `ℓ` becomes five binary items on a chain, not one
32-way subset choice, and `ar` is scored as *bags* of colours, not sequences.
(2) Underdetermination gets an **explicit code with a closed reason list and a
restricted-disjunction option** — never a forced choice, because a forced choice
manufactures agreement out of shared default and puts a guess in the majority of
cells (15/29 requirement rows are empty). (3) Every downstream number is reported
**twice**: complete-case, and with `?` cells filled adversarially against the
hypothesis. That last rule is what retires the 16.3-point adjudication swing — it
pre-registers *both arms* of the adjudication instead of picking one after seeing
the outcome. My gate is Krippendorff's α with a set-difference metric, judged on
the bootstrap lower bound against Krippendorff's own 0.667/0.800 standard. I
dissent on one point, in §DISSENT, and it is load-bearing: three assigners from one
model family have correlated error, and every agreement statistic in existence
assumes error is independent.

## 1. Design

### 1.1 Unit of analysis

Not the element. **406 cells**, over 58 elements:

| family | cells/elt | value space | why |
|---|---|---|---|
| `ar`-in | 1 | multiset over `C∪{?}` | port *order* is construct-irrelevant |
| `ar`-out | 1 | multiset over `C∪{?}` | idem |
| `ℓ`-h₀…h₄ | 5 | {live, not-live, ?} | one binary item per horizon |

`ar` is `C* × C*` in the signature, but Definitions 7–8 match ports **by colour**
under a linearity budget; nothing reads port index. Scoring order would inject
construct-irrelevant variance and deflate α for no reason (Messick). Assigners
therefore emit an unordered bag; the architect canonicalises to a sequence
post-hoc by the fixed order `A,K,K*,Q,P,V,U,M,I`.

### 1.2 The coding manual

**Source ladder (mandatory, in order, stop at first hit).** Two assigners must
consult the same evidence in the same order or agreement measures nothing.
1. The element's non-empty requirement row in the redacted `blind-requirements.md`.
2. The element's state variables and actions in the redacted Quint extracts.
3. The element's name line in `blind-elements.md` (symbol + name only).
4. STOP. Group and stratum are not sources. The corpus specs, protocol names,
   prohibition rows, `X21`, and the failure list are forbidden.

**Colour key (forced discrimination order, not a rubric).** A list of nine glosses
invites free association; a key forces the same cuts in the same sequence.
- Q1 *Does transferring this wire decrement the sender?* If yes → Q2. If no → Q3.
- Q2 (linear family) fungible bearer value redeemable outside this protocol → `A`;
  pro-rata or fixed right **against this protocol's pool** → `K`; obligation to
  deliver, held by an obligor → `K*`; consumable envelope that caps or refills a
  rate/amount → `Q`.
- Q3 *May it be read repeatedly with no state change?* numeric valuation carrying
  provenance → `P`; boolean predicate on state → `V`; attested fact naming a
  source domain → `M`; monotone accumulator → `I`.
- Q4 Otherwise: permission to act held by a party → `U`.

**Tie-break, when two branches fire:** `A > K > K* > Q > M > I > P > V > U`.
This is deliberately biased **against** the hypotheses. A false-classical
assignment silently licenses duplication and therefore inflates constructibility;
a false-linear assignment only rejects wirings. The instrument must err in the
direction that makes C1 harder.

**Liveness key (five binary items).** For each hᵢ ask one fixed question: *is the
element's effect observable to a party other than the caller at this horizon?*
h₀ effect complete and visible before the transaction returns; h₁ requires other
transactions in the same block; h₂ requires an epoch/batch boundary; h₃ requires a
dispute or challenge period to elapse; h₄ requires a governance timelock. Each is
yes / no / `?` independently. Non-convex answers are permitted and are *recorded*
(see §3.4) — forcing convexity would hide the most informative disagreements.

**Underdetermination — explicit code, and I defend it.** The alternative
(forced choice) fails in the exact way that sank the prior effort: two coders
lacking evidence converge on the same modal guess, α goes up, and the datum is
fabricated. Worse, guessed ports are *matchable* ports, so forced choice pushes
coverage upward — the bias runs toward the claim. The explicit code's failure mode
(a holed table, C1 unprovable) is an honest null and is itself measurable. So:
- `?` requires one reason tag from a closed list: `no-source`, `two-way`,
  `source-conflict`.
- `two-way` is **not** recorded as `?` but as a restricted disjunction, e.g.
  `{A,K}` — partial information, scored with partial credit by MASI.
- Pre-registered outcome: the undetermined rate itself, reported per family.

### 1.3 Assigners and overlap

**Three assigners, 100% overlap, all 58 elements.** Three, not two: with two, every
disagreement needs an adjudicator, and adjudication is precisely where
outcome-aware bias entered last time. With three, majority resolves mechanically
and no human sees an outcome. 100%, not a sample: Krippendorff's minimum-N logic
would demand a subsample larger than the population here, and *the prior effort's
named defect was a missing overlap sample* — a partial one re-opens the same
objection for zero saving. Plus a **10-element intra-rater retest** at 24h with
shuffled presentation order, to separate assigner noise from manual ambiguity.

**Four decoy elements** with plausible fabricated names are shuffled into the 58.
An assigner who confidently fills complete rows for decoys is keying off names, not
sources — and would do so *in agreement with the other two*. Disqualification rule:
fewer than 3 of 4 decoys coded `?`/`no-source` ⇒ that assigner's entire run is
discarded and re-run. This is the only check in the design that can catch
correlated error, which α structurally cannot.

## 2. Pre-registered hypotheses and thresholds

Statistic: **Krippendorff's α**, everywhere. Not Cohen's κ — it handles neither
>2 raters, nor set-valued units, nor missing data, and we have all three. Not
Fleiss' κ — the h₃/h₄ items will be heavily skewed and κ collapses under skew
(Feinstein & Cicchetti's high-agreement/low-kappa paradox). Metrics:

- **`ar`-in, `ar`-out**: α with Passonneau's **MASI** distance on multisets,
  δ = 1 − J·M. Plus ordinal α on port *degree* (|in|, |out|) reported separately —
  degree disagreement and colour-at-agreed-degree disagreement are different
  defects and must not be pooled.
- **`ℓ` per horizon**: binary-nominal α per hᵢ, plus **Gwet's AC1** per hᵢ as the
  prevalence-robust companion.
- **`ℓ` as a set**: MASI α; *and* ordinal α on the interval endpoints
  (min ℓ, max ℓ) separately.

All α with **1,000-resample bootstrap CIs over units**; judge on the lower bound.

**Thresholds — Krippendorff (2004, §11.4), the only standard with decision
content.** α ≥ 0.800 = conclusions without qualification; 0.667 ≤ α < 0.800 =
tentative conclusions only. Landis & Koch's "substantial" band is a *descriptive*
label for κ and was never a decision rule; we do not use it as a gate.

- **Gate G1:** lower CI bound of α ≥ **0.667** for each of ar-in, ar-out, ℓ-MASI,
  ℓ-pooled-binary. Below this on any family, that family fails.
- **Gate G2:** point α ≥ **0.800** for `ℓ`. `ℓ` carries the headline (the 82.4%
  dissolution is a live-set claim) and must be unqualified.
- **`ar` is pre-registered as tentative-band by design.** With 15/29 rows empty I
  expect 0.667 ≤ α_ar < 0.800; that is declared *now* so that landing there is not
  spun as a pass.
- **Prevalence-degenerate escape (pre-registered, to stop a post-hoc call):** a
  horizon with α < 0.667 but raw agreement ≥ 0.90 **and** AC1 ≥ 0.80 is labelled
  prevalence-degenerate, reported as such, and excluded from the pooled figure —
  it does not fail the run. Any other pattern fails.

**Validity predictions (directional, fixed now):**
- **H-V1 convergent:** the blind `ar` reproduces the order-theory lane's
  independent single-group rate — fraction of non-empty requirement terms with a
  constant blind colour **≥ 0.85** (against their ρ = 0.958).
- **H-V2 discriminant, two-sided:** Spearman ρ(min ℓ(e), stratum(e)) ∈ **[0.50,
  0.95]**. Assigners never see stratum. Below 0.50, `ℓ` is not measuring settlement
  time. **At or above 0.95, `ℓ` is stratum relabelled and the sheaf contribution is
  a rename** — that tail is a failure too, and it is the sharpest test here.
- **H-V3 nuisance:** no significant association between assigned colour and group
  ordinal or name length (χ², α=0.05). A hit means an assigner shortcut via G-group.
- **H-V4 disagreement/collapse:** ≥ 3 of {`Vl`, `Op`, `Xf`, `Xm`} land in the top
  12 of the disagreement ranking (§3.4).

## 3. Analysis procedure

**3.1 Fusion (mechanical, no judgement).** Per cell: majority of 3 wins. All three
distinct ⇒ cell becomes `?`. Restricted disjunctions intersect where the
intersection is non-empty, else `?`. No adjudicator, ever.

**3.2 Reliability.** Compute α (bootstrap LB) and AC1 per §2 on the *unfused*
three-way data, before fusion, before any downstream analysis. Publish the table.
Apply G1/G2. Nothing downstream runs until the gates are evaluated and recorded.

**3.3 Two-arm reporting — mandatory for every downstream number.** Arm A
complete-case (`?` cells dropped, N reported). Arm B adversarial fill: every `?`
resolved to the value **least favourable to the hypothesis under test** (for C1,
the colour that fails to match; for `ℓ`, not-live). A coverage or dissolution
claim is reported as established only if it survives **Arm B**. The gap A−B is
reported as the *adjudication sensitivity*, the direct successor to the prior
16.3 points, now bounded in advance rather than chosen after.

**3.4 Disagreement ledger.** For every element, d(e) = mean pairwise MASI distance
across the three assigners, plus the distinct-code count and the reason tags. Rank
all 58 by d(e) descending; publish the full ranked table as a first-class artifact.
Top decile = the **collapse-candidate list**, evaluated against H-V4. Additionally
flag every element where the three assigners agree on endpoints but disagree on
interior horizons: that is non-convex liveness, a signature of a symbol covering
two mechanisms at different settlement times. Disagreement is never discarded; it
is an output.

**3.5 On gate failure.** **Exactly one** repair-and-rerun cycle. The manual may be
revised only in hypothesis-neutral ways (sharpen the key's discrimination order,
add worked examples, disambiguate glosses); the diff is logged. Mechanical
anti-fitting check: apply the revised rules to run 1's disagreement cells and
verify the revision does not move them systematically toward *more ports* or *more
co-live* (sign test, p > 0.05). Re-run with fresh assigners. A second failure ends
it: both tables are reported **not established**, C1 and P1 un-adjudicated, and the
82.4% figure withdrawn. Unlimited manual revision is instrument-fitting — the
original sin — so the cap is hard.

## 4. Falsification conditions

- α lower bound < 0.667 on `ℓ` twice ⇒ the live-set construct is not codeable from
  the recorded definitions; `ℓ` is unmeasured and P3/the dissolution claim die.
- H-V2 lands ≥ 0.95 ⇒ `ℓ` is stratum renamed; the sheaf component adds nothing and
  should be deleted from Σ rather than defended.
- Any Arm-B result that reverses its Arm-A sign ⇒ that claim was an artifact of
  the underdetermination adjudication, not of the data.
- `?` rate > 40% in either `ar` family ⇒ the corpus does not determine the
  signature; C1 remains not-a-proposition and the honest report says so.
- H-V1 < 0.60 ⇒ the blind coders are not measuring the same thing the requirement
  rows encode; the "29 rows already are arity" claim fails.

## 5. Threats to validity and mitigations

| threat | mitigation |
|---|---|
| **Correlated error across assigners** (dominant threat; α assumes independence) | ≥2 model families (§DISSENT) + decoy elements + H-V1/H-V2 external anchors |
| Shared-default agreement on thin rows | `?` code + reason tags + `?`-rate as pre-registered outcome |
| Skew inflating disagreement on h₃/h₄ | AC1 companion + pre-registered degeneracy escape |
| Order variance polluting `ar` α | bag-valued coding, canonicalise post-hoc |
| Assigner shortcut via group | group column redacted; H-V3 nuisance test |
| Stratum leakage destroying H-V2 | stratum column redacted from `blind-elements.md` |
| Manual drift across the two days | intra-rater 24h retest on 10 elements |
| Reliable-but-wrong construct | H-V1 convergent + H-V2 two-sided discriminant + decoys |

## 6. Interface requirements on other surfaces

**Barriers surface must deliver, before any coding:** `blind-elements.md` —
symbol + name only, **group and stratum columns removed** (stratum leakage
invalidates H-V2), with 4 decoys interleaved; `blind-requirements.md` — the 29
rows with subjects, **no prohibition rows, no `X21`, no warrants/consumer table**;
`blind-quint-extracts/` — state variables and action signatures only, protocol
names scrubbed. Three assigner processes with no shared scratch and no sight of
one another's output.
**Hypothesis surface** must accept two-arm reporting for every number downstream of
a `?` cell.
**Analysis surface** executes §3.1–3.4 mechanically and may not edit cell values.

## 7. What I would cut if we had one day instead of two

Cut: intra-rater retest; separate degree-α (fold into MASI); H-V3 nuisance test;
the repair-rerun cycle (a day-one failure is simply a failure). **Do not cut:**
three assigners, 100% overlap, the five-binary decomposition of `ℓ`, bootstrap
lower bounds, the decoys, and two-arm adversarial reporting. The last two are the
cheapest items in the design and are exactly the two the prior effort most needed.

## DISSENT

**Three assigners drawn from one model family do not constitute three raters.**
Every agreement statistic named above — α, AC1, all of them — estimates
reliability under the assumption that rater errors are independent. Same model,
same prompt, same training distribution ⇒ errors are strongly correlated, and a
high α then measures **prompt determinism**, not construct reliability. It is
worse than uninformative: it is confidently wrong in the direction of the
hypothesis, because correlated hallucination fills exactly the thin rows where
evidence is absent, and fills them agreeably.

Requirement: the three assigners must span **at least two distinct model
families** — the environment already has `codex-implementer` (GPT) and
`grok-implementer` (Grok) lanes alongside Claude, so this costs nothing but
wiring. Report **between-family α separately from within-family α**; the
between-family figure is the one that goes in the paper. I expect within-family α
to exceed between-family α by a wide margin, and that gap is itself the most
honest thing this sprint can produce.

If cross-family assignment is not done, I dissent from reporting α as *inter-rater
reliability* at all. It should be labelled "instrument determinism (single model
family)", and reliability should be reported as **not established** — which is
precisely the status the prior effort already had, meaning the sprint would have
bought nothing on my surface.

Secondary dissent, minor: do not let `ar` be scored against the 0.800 line and
then narrated as a pass at 0.72. It is pre-registered here as a tentative-band
family. Publish it in that band or not at all.
