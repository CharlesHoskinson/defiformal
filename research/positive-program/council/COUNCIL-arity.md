# Council proposal — the arity table `ar` and its retrodiction test (T6)

## 0. Verdict in one paragraph

The arity surface is executable in two days, but **not as specified**, and I bring three
findings from the primary data that the sprint must absorb before it starts. (i) The
`15` vs `18` arc discrepancy is **closed**: `18` counts every singleton requirement
term; `15` excludes the three singletons that sit inside an `[ext]`-marked term
(`Tr→Sv`, `Xf→Xm`, `Up→Tg`). Both are correct readings of the same table; neither is a
recount error. (ii) `formal-data.tex:87` gives `L4 : Pf → (Ex)(Ct)(Li)(Ad|Sl|Bs)` —
**four** terms — while `STRUCTURE-DEFINITIONS.md:91`, citing that very line, transcribes
**three**, `(Ex)(Ct)(Li|Ad|Sl|Bs)`. The transcription is wrong, and it is not cosmetic:
it deletes the arc `Pf→Li` and it is the arc the standing venue prediction rests on.
(iii) The literal test I was handed — `D′` from unique inhabitants — is **provably
near-vacuous at 9 colours over 58 elements** and must be replaced by a graded form. On
the barrier I dissent from the brief's premise: the assigner must not see any projection
of the requirement table, because every projection that preserves port structure
preserves most of `D`. Ports come from the element's own definition and its own Quint
spec, under symbol redaction. My scoreable dissent is at the end: the standing venue
prediction is **not scoreable and, on its nearest true reading, is already known true
with no contrast case**.

## 1. Design

**1.1 The barrier (the crux).** There is no safe projection of the requirement table.
`D` is exactly `{(s,t) : s ∈ subjects(row), some term of row = {t}}`. Any view that
hands an assigner the number and colour of a row's terms hands them term cardinality,
and cardinality-one *is* the arc. Withholding only the identity of `t` still leaks
`|D|` and every source vertex. Therefore:

> **The arity assigner never sees `formal-data.tex`, `STRUCTURE-DEFINITIONS.md`, the
> seven `requirements/*.md`, the warrant table, the prohibition table, or any
> application spec.**

This is not a loss. `ar` is a property of an element, not of the table; the retrodiction
claim is precisely that typing elements *independently* regenerates the recorded rows.

**1.2 The packet.** For each element `e`, the packet-builder emits
`packets/<e>.md` containing exactly four fields:

1. `symbol` — the two-letter code, **relabelled** to an opaque token `E01…E58` by a
   sealed permutation (so an assigner cannot key on `Ct`/`Li` memory of the paper);
2. `name` — the English name verbatim from the elements table;
3. `definition` — the element's prose definition from `STRUCTURE-DEFINITIONS.md`,
   **with every other element name and symbol replaced by `⟨other⟩`**;
4. `spec` — the element's own Quint model text (`quint-models/L*/`), with every
   identifier that names another element replaced by `⟨other⟩`, and all `import` /
   `instance` lines stripped.

**Withheld:** group `G01–G16` (leaks the `ρ = 23/24` prediction, which is a
single-group claim about requirement terms), stratum `0–4` (leaks the `ℓ` surface),
and all cross-element references. Enforcement is a redaction script plus a
`grep -F -f element-names.txt packets/` gate that must return empty before assignment
opens.

**1.3 The instrument.** Two independent questions per element, answered in order.

*In-ports* — "what must be supplied from outside for this element's rule to evaluate?"
List each quantity the element **reads but does not write**; colour each by the tree
below, first match wins; then apply the **polarity collapse**: `P,V,M,I` are classical,
so repeated reads of one classical colour collapse to **one** port; `A,K,K*,Q` are
linear, so repeats stay **distinct** ports; `U` is affine, so **at most one** `U` port.
Cap at five; record overflow.

*Out-ports* — "what does this element make available to another that did not exist
before?" Same tree, applied to what is written. Up to two outputs, marked
primary/secondary; **primary only** feeds the primary analysis.

*Colour tree (ordered, first match wins).* `A` change in who holds value · `K` creates a
claim held by this element's counterparty · `K*` creates an obligation owed by it ·
`P` a number read as a rate or valuation · `V` a boolean/decision that gates another
element · `U` a permission, role or capability · `Q` a bound or quota consumed by use ·
`M` an attested statement about another context · `I` a monotone shared bookkeeping
scalar · otherwise `?`.

*Underdetermination.* No source outside the packet may be consulted. If the packet does
not decide, write `?` with a one-line reason. **`?` is a first-class outcome, not a
failure to be avoided** — the 15 empty requirement rows predict that many elements are
thinly recorded, and the `?` rate is the measurement of that.

**1.4 Reliability.** Three assigners, all 58 elements, no overlap sampling. Statistics:
Krippendorff's α (nominal) on primary out-colour; Krippendorff's α with the **MASI**
distance (Passonneau 2006) on the in-port colour multiset. Floors: α_out ≥ 0.67,
α_MASI ≥ 0.60 — Krippendorff's tentative-conclusions threshold. Below either, **the
instrument is unreliable and the run is discarded without scoring**. Disagreements are
adjudicated by majority; three-way splits become `?`. The adjudicator is a fourth agent
who has also never seen `D`.

**1.5 Memorization probe (mandatory).** Assigners are language models that may have read
this repository. After sealing their rows, each is asked, in a fresh context, to state
the definite-requirement digraph. Any assigner reconstructing **> 30%** of `D₁₈` has all
their rows discarded and is replaced. Without this control the whole barrier is
decorative.

## 2. Pre-registered hypotheses and thresholds

Fix, before assignment opens and by SHA-256 commitment: `D₁₈` (all 18 singleton arcs)
as **primary**, `D₁₅` (excluding `[ext]`-marked) as the sensitivity target, and the
adjudication that `formal-data.tex:87` — the four-term `L4` — is authoritative.

Define over `ar`:

- **Admissibility** `A = {(s,t) : ∃c ∈ in(s), out(t) = c}` — a *necessary* condition.
- **Forced** `F_k = {(s,t) : ∃c ∈ in(s), out(t) = c, |inhab(c)| ≤ k}`; `F₁` is the `D′`
  of the brief.
- The claim is the **sandwich `F₁ ⊆ D ⊆ A`**, not `D′ ⊇ D`. The brief's containment is
  the wrong direction for the forced digraph and the right one for admissibility: `A`
  over-generates and must *contain* `D`; `F₁` under-generates and must be *contained in*
  `D`. Equality `D′ = D` is unreachable unless colours are as fine as elements — which
  would be the fitting failure the sprint exists to prevent.

**H1 (soundness, primary).** `recall_A = |D₁₈ ∩ A| / 18 = 1.00`. Pass at 1.00; 0.85–0.99
records the named violating arcs as defects; **< 0.85 falsifies the arity reading.**

**H2 (informativeness, primary).** Score each ordered pair by
`w(s,t) = max{1/|inhab(c)| : c ∈ in(s), out(t) = c}` (0 if none) and take **AUC** against
`D₁₈` over all 3,306 ordered pairs. Pass ≥ 0.80; weak 0.65–0.80; **fail < 0.65.**

**H3 (significance).** Label-permutation test (Fisher randomization; Good, *Permutation,
Parametric and Bootstrap Tests*): permute out-colours across the 58 elements preserving
the colour multiset, hold in-ports fixed, `B = 10,000`, recompute AUC. **One-sided
p < 0.01.** Also report Fisher's exact test on the 2×2 table (pair ∈ A) × (pair ∈ D₁₈).

**H4 (negative control).** Build 18 corrupted arcs by retargeting each real arc to a
uniformly-drawn non-target. Report `separation = recall_A(real) − recall_A(corrupt)`.
**Pass ≥ 0.30.** This directly answers the prior effort's `−0.117`.

**H5 (precision of the forced reading, secondary).** `|F₁ ∩ D₁₈| / |F₁|` ≥ 0.70,
**reported only if `|F₁| ≥ 5`.**

**Power conditions, checked on `ar` alone before `D` is unsealed.**
*PC1:* `F₁` has power only if ≥ 3 colours have `|inhab(c)| = 1`. With 58 elements over
9 colours the mean is 6.4 and I expect **PC1 to fail** — `Ct` and `Oa` both emit `V`;
`Aw`, `Au`, `Gp`, `Tg` all emit `U`. Say so now rather than discover it.
*PC2:* `A` has power only if the Herfindahl index `Σ|inhab(c)|² / 58² ≤ 0.25`
(effective colour count ≥ 4) **and** `|A| / 3306 ≤ 0.40`. If PC2 fails, the run is
declared **underpowered** and reports no verdict on C1/P1 — an honest null, not a fail.

## 3. Analysis procedure

Strictly ordered; each step hash-committed before the next opens.

1. Adjudicate `L4`; freeze `D₁₈`, `D₁₅`; hash and seal (architect, not assigners).
2. Build and gate packets; hash.
3. Three assigners produce `rows/<assigner>/<token>.json`; hash on submission.
4. Memorization probe; discard and replace as needed.
5. Compute α_out, α_MASI. Below floor → **stop, discard the run.**
6. Un-permute tokens. Compute `inhab`, `A`, `F_k`. Check PC1, PC2. Underpowered → stop.
7. **Only now unseal `D`.** Compute H1–H5 against `D₁₈`, then `D₁₅`.
8. If a verdict flips between `D₁₈` and `D₁₅`, report **ABSTAIN** on that sub-claim and
   name the three `[ext]` arcs as the cause.

## 4. Falsification conditions

`recall_A < 0.85` — some recorded definite requirement is colour-inadmissible; the
9-colour arity reading of the requirement table is wrong. · `AUC < 0.65` or `p ≥ 0.01` —
`ar` carries no more information about `D` than a colour-multiset shuffle; the arity
table is not doing work. · `separation < 0.30` — `ar` cannot tell real requirements from
corruptions, the exact prior failure. · `α` below floor, or `? > 20%` of primary
out-ports — the *instrument* is refuted, the theory untouched; report as such, do not
launder an instrument failure into a theory result.

## 5. Threats to validity and mitigations

**Domain-knowledge leak.** An assigner who knows DeFi infers `Pf→Ct` without the table.
This is not leakage of `D`; it is the retrodiction hypothesis. But it does mean H1 alone
cannot distinguish "the table is real structure" from "the table is common sense" —
which is why H4's negative control, not H1, carries the evidential weight.
**Circular colour provenance.** The 9 colours were extracted from the Quint specs the
assigners read. Mitigate by giving colours as fixed definitions with worked examples
drawn from *outside* the corpus, and never showing the extraction rationale.
**Small `D`.** 18 arcs gives wide intervals; report exact-test CIs and never a bare point
separation. **Redaction failure.** The `grep -F` gate is the only thing standing between
this design and the prior effort's failure mode; it must gate the run, not warn.
**Two divergent copies of `L4`.** Already the second silent transcription error found in
this corpus; run a full diff of `STRUCTURE-DEFINITIONS.md` against `formal-data.tex`
before starting, not just row `L4`.

## 6. Interface requirements on other surfaces

**Packet-builder surface** must implement §1.2 including the symbol permutation and the
`grep -F` gate, and must own the sealed token map. **The `ℓ` surface** must not require
the arity assigner to see stratum; if it does, the two assignments must be made by
disjoint agents. **Adjudication surface** must close `L4` and freeze `D₁₈`/`D₁₅` before
step 3, and must be disjoint from every assigner. **Venue-mapping surface** must produce
each application's element multiset blind to `ar` — but see the dissent: for the standing
prediction that mapping already exists in the corpus and is fatal to it.

## 7. What I would cut if we had one day instead of two

Keep: the barrier, the redaction gate, the memorization probe, H1, H4, the permutation
test, the PC2 check. Cut: the third assigner (two plus adjudicator; report α with the
caveat), the `D₁₅` sensitivity pass (report `D₁₈` only and flag it), the `F_k` curve
(report `F₁` and AUC only), and the multi-output secondary colour (primary only). I
would **not** cut the negative control — without H4 this sprint reproduces the exact
methodological failure it was convened to fix.

## DISSENT

**The standing venue prediction is not a prediction.** I checked it against the
machine-readable corpus rather than against the brief.

- `Pm` (oracle-priced inventory curve) appears in **0 of the 60 specs**. There is no
  `Pm`-carrying application in the corpus at all.
- The Jupiter that *is* in the corpus (`expansion/08-intents/specs/jupiter.json`) has
  construction `{Ag, Aw, Gs, In}` — no `Pm`, no `Pf`, no `Ct`, no `Ex`, no `Li`. It is
  the aggregator, not Jupiter Perps. **The contrast case does not exist.**
- There are **five** order-book perpetuals venues, not six (ApeX, Aster, edgeX,
  Hyperliquid, Lighter); the seven `Ob ∧ Pf` venues include two options venues (Aevo,
  Derive). "Six" matches nothing.
- **All seven `Ob ∧ Pf` venues carry all of `{Ct, Ex, Li}`.** Base rates: `Ct` 24/60,
  `Ex` 25/60, `Li` 17/60. So on the reading "these three are required and present" the
  prediction is already known true, with **zero variance and no negative case** — one
  `grep` reads it off. On the reading "these three are dropped" it is already known
  **false** for all seven. Either way it cannot discriminate.

This is the fitted-instrument failure recurring inside the sprint's own pre-registration:
a corpus regularity, visible without any blind assignment, promoted to a standing
prediction. Scoring it would manufacture a confirmation.

**What I would do instead.** Delete it, and replace it with a prediction that has a
negative case and is unreadable in advance: *for every application in the 60-spec
corpus, every arc of `D₁₈` whose source is in that application's construction has its
target also in that construction.* Base rate makes this genuinely at risk — `Ad` is
6/60, `Bs` 10/60, `Sv` 8/60, `Rl` 1/60 — and it is scored mechanically with no assigner
involvement, because the constructions are already recorded and `D₁₈` is sealed. Set the
threshold at ≥ 0.90 of source-present arcs closing, pre-registered, with the per-arc
failures named.

**Second dissent, on scope.** My surface bears on neither C1 nor P1 as the brief claims.
`F₁ ⊆ D ⊆ A` is a *well-definedness certificate for `Σ`* — evidence that `ar` is
coherent with the recorded requirements. C1 quantifies over applications and no
application is touched by this test. P1 the brief itself says is "closed **by
construction** of the carrier" — a tautology cannot be empirically confirmed, and a
sprint that reports P1 as confirmed is reporting nothing. Rename the deliverable
accordingly, or the headline will overclaim in exactly the way this sprint was convened
to stop.
