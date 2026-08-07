# COUNCIL BRIEF — design the blind table sprint

You are a member of an advisory council. Your task is **design**, not execution and
not review. You will produce one independent proposal. You will not see the other
members' proposals. Consensus is taken afterwards by the architect, and **your
dissent will be preserved verbatim rather than averaged away** — so state it.

---

## 0. Council contract

Adapted from the Foreman Council operator contract:

- **Independent proposals.** You are proposing blind to your colleagues. Do not
  hedge toward an imagined middle; propose what you actually think is right.
- **Dissent is actionable.** If you believe the sprint as scoped is wrong, say so
  in a `## DISSENT` section with the specific defect and what you would do instead.
  A recorded dissent forces a design round; it is not overridden by majority.
- **Typed abstention is valid.** If your area cannot reach a verdict on the
  evidence supplied, write `## ABSTAIN: insufficient_evidence` and state exactly
  what evidence would resolve it. Abstention is respectable; a manufactured
  verdict is not.
- **Stay in your lane.** Propose within your assigned surface. Where you must
  depend on another surface, state the dependency as an interface requirement
  rather than designing it yourself.

---

## 1. The goal of the sprint you are designing

**Produce a single executable experimental protocol** that assigns, under strict
information barriers, two tables over the 58 DeFi mechanism elements:

- **`ar : E → C* × C*`** — an arity: input and output port colours, over a fixed
  9-colour set.
- **`ℓ : E → 𝒫(H)`** — a live-set: the settlement horizons at which the element's
  effect is observable, over a 5-chain `H = (h₀ intra-transaction < h₁ intra-block
  < h₂ epoch/batch < h₃ challenge window < h₄ governance timelock)`.

...such that the results bear **decisively and pre-registerably** on:

- **C1 (coverage)** — every corpus application is constructible from the primitives;
- **P1 (composition totality)** — composition is closed by construction of the carrier.

## 2. The required outcome — the artifact

One markdown document containing, at minimum:

1. **Information barriers.** Precisely what each assigner may and may not see,
   and the mechanism that enforces it. Be concrete: name the files.
2. **The assignment instrument.** The coding manual an assigner follows to turn
   an element definition into a row. Decision rules, tie-breaks, and what to do
   with an element whose definition underdetermines its row.
3. **Reliability plan.** How many independent assigners, on what overlap, and
   which agreement statistic — with the threshold below which the instrument is
   judged unreliable and the run discarded.
4. **Pre-registered hypotheses and verdict thresholds**, fixed before any data is
   seen, including the direction of each prediction.
5. **The analysis procedure** — mechanical, so the architect can execute it
   without judgement calls that could bias the result.
6. **Falsification conditions** — what result kills the structure.
7. **Threats to validity**, and the mitigation for each.

Be concrete enough that the architect can execute it without asking you questions.
Target **900–1,500 words**. Precision over completeness.

---

## 3. Why this step (the dependency argument you are working within)

The three targets — completeness, composition, construction — are statements
quantified over the signature `Σ = (E, C, λ, ar, H, ℓ, Π)`.

- "Constructible" is defined as *admits a complete well-typed wiring over `Σ`*.
  That definition's clauses quantify over `ar`, `λ` and `ℓ`.
- Therefore with `ar` and `ℓ` unassigned, *constructible* has **no extension**:
  C1 is not unproved, it is **not a proposition**.
- Composability is *same colour, co-live horizons, linearity budget respected* —
  no `ar`, no `ℓ`, no conditions, and totality is vacuous.
- The synthesis CSP's variables **are** the ports.

So the tables are not inputs to the theory. They **are** the signature. This sprint
is the minimal act that turns the programme into a mathematical object.

## 4. Why blind — the failure being guarded against

The prior effort's characteristic failure was **instruments fitted to their
target**. On its own record: the consumer table `C` was fitted to deployed
practice; replacing it with the principled object (the true order-theoretic
residual) produced an operator fixing **13 of 72 real protocols** against **25 of
84 synthetic corruptions** — separation **−0.117**, *anti-correlated with reality*.
The fitted table scored 71 of 72 precisely because it had been shaped by the
answers.

Two further symptoms: coverage moves **16.3 points** on an adjudication the coders
made while seeing the outcome; and **inter-rater reliability was never
established** — the paper says so and says every per-application claim should be
read subject to it.

**The live exposure.** The current headline — that scoping dissolves **82.4%** of
composition failures — was computed *after* seeing the clause `X21` and the failure
list. A referee may fairly say: *you assigned live-sets that make the failures go
away, then reported that they went away.* Blinding is what converts that number
into a prediction.

---

## 5. Evidence base you may rely on

**The 58 elements** each carry a name, a group `G01–G16`, and a stratum `0–4`
(`/root/DefiElements/paper/formal-data.tex`). The stratum column is being *read as*
the horizon chain `H`.

**The 9 colours**, fixed empirically from 57 typechecked Quint specifications built
from protocol source: `A` asset, `K` claim, `K*` liability, `P` price, `V` verdict,
`U` authority, `Q` capacity, `M` message, `I` index. Polarity: `A,K,K*,Q` linear;
`P,V,M,I` classical; `U` affine.

**The 29 requirement rows already encode arity.** `L4 : Pf → (Ex)(Ct)(Li|Ad|Sl|Bs)`
is three typed input ports of colours `P`, `V`, `K*`. Independently, **23 of 24**
non-empty requirement terms lie inside a single `G01–G16` group.

**The targets the blind tables will be scored against** (assigners must not see
these; you as designer may):
- `D`, the definite-requirement digraph: paper states **15 arcs**, an independent
  recount gives **18**. The discrepancy is unresolved and must be closed before any
  density figure is trusted.
- The recorded composition failures: 185 of 1,830 pairs on the 72-decomposition
  population; 119 of 1,711 on the 60-construction population.
- A standing prediction: the six order-book perpetuals venues drop exactly
  `{Ct, Ex, Li}`, while Jupiter (carrying `Pm`) drops none.
- A standing prediction: single-group rate `ρ = 23/24 = 0.958`.
- Reference (non-blind) dissolution: **82.4%**, GYO residue 4 → 3 hyperedges.

**Known limits.** 15 of 29 requirement rows are entirely empty `[ext] ()`; 9 of 20
prohibitions are prose; `X21`, credited with 147 of 185 failures, appears nowhere
in the published table. Assigners will therefore face elements whose recorded
definition is thin — your instrument must say what to do then.

**Corpus artifacts available:** 60 machine-readable specs at
`/root/DefiElements/expansion/*/specs/*.json`; 57 Quint specs at
`/root/DefiElements/quint-models/L*/`; six insight ledgers at
`/root/DefiElements/research/positive-program/insights/`; the seven requirement
documents at `.../requirements/`; the definitions at
`.../consolidated/STRUCTURE-DEFINITIONS.md`.

---

## 6. Constraints on your proposal

- **Days, not months.** The sprint must complete in ~2 days of work. A design
  requiring a month is a refusal; say so as dissent instead.
- **No result may depend on an assigner having seen the scoring target.** If your
  design needs an assigner to see a protocol, justify it explicitly and quarantine
  that assignment from the pre-registered outcome.
- **Mechanical analysis.** The architect executes the analysis; it must not require
  interpretive judgement that could move the verdict.
- **Name real methodology.** Cite actual instruments, statistics and standards by
  name. Invented methodology is worthless here.
- **The sprint may be judged insufficient.** If you believe the design cannot
  deliver a decisive verdict on C1/P1, dissent and say what would.

## 7. Output

Write to the exact absolute path given at the end of your instructions, using this
skeleton:

```markdown
# Council proposal — <your surface>
## 0. Verdict in one paragraph
## 1. Design
## 2. Pre-registered hypotheses and thresholds
## 3. Analysis procedure
## 4. Falsification conditions
## 5. Threats to validity and mitigations
## 6. Interface requirements on other surfaces
## 7. What I would cut if we had one day instead of two
## DISSENT  (or)  ## ABSTAIN: insufficient_evidence
```
