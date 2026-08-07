# Why the blind table sprint is the next step — the dependency argument

The claim to be established: *assigning `ar` and `ℓ` blind is not preparatory
work for the paper; it is the construction of the paper's signature, and no
theorem in the programme can be stated without it.*

---

## 1. What the paper must prove

| # | Target | Formal content |
|---|---|---|
| G1 | **Completeness** | Every application in `Ref` is constructible from `P` (clause C1), with separation (C2), Beth independence (C3), conservativity (C4) |
| G2 | **Composition** | The class of constructions is closed under `⊗`, by construction of the carrier |
| G3 | **Construction** | Synthesis of a construction from a specification, with a checkable certificate |

## 2. The dependency chain

**Step 1.** G1 asserts that each application is *constructible*. That word is not
primitive; it is defined. Definition 7 fixes it: an application is constructible
when it admits a **complete well-typed wiring** over `Σ`.

**Step 2.** Definition 7 has four clauses. Clause (Colour) quantifies over `ar`.
Clause (Linearity) quantifies over `λ`. Clause (Scope) quantifies over `ℓ`.
Clause (Closure) quantifies over `λ` again.

**Step 3.** Therefore, with `ar` and `ℓ` unassigned, the predicate *constructible*
has **no extension**. C1 is not unproved, and not false. It is **not a
proposition** — there is no fact of the matter about whether a protocol satisfies
a predicate whose defining data has not been written down.

**Step 4.** The same holds for G2. Definition 8 defines composability as *same
colour, co-live horizons, linearity budget respected*. Property P1 (totality) says
these conditions are checkable pointwise and preserved by matching. Without `ar`
and `ℓ` there are no conditions to check, and P1 is vacuously true of nothing.

**Step 5.** The same holds for G3. The synthesis CSP's variables **are** the ports.
Synthesis measured `5 ≤ tw ≤ 8` on the *present* tables; the treewidth of the
enriched system is a function of `ar`. There are no variables until `ar` exists.

**Conclusion.** `ar` and `ℓ` are not inputs to the theory. They **are** the
signature `Σ`, and all three targets are statements quantified over `Σ`. Writing
them is the minimal act that turns the programme from a proposal into a
mathematical object. Everything else in the queue — PO-STR-6, T7, the Lean
development — is downstream of them and cannot begin.

---

## 3. Why *blind*, specifically

Steps 1–5 establish that the tables must be written. They do not establish that
they must be written blind. That argument is separate and it is about the
**credibility** of the result rather than its statability.

**3.1 The prior paper's characteristic failure was instruments fitted to their
target.** The clearest instance is on the record in its own §12: the consumer
table `C` was *fitted to deployed practice*. When it was replaced by the
principled object — the true order-theoretic residual of the requirement relation
— the resulting operator fixed **13 of 72 real protocols** against **25 of 84
synthetic corruptions**, a separation of **−0.117**. It was *anti-correlated with
reality*: it rejected real designs more readily than deliberate corruptions.

That is the diagnostic signature of an instrument fitted to the thing it measures.
The fitted table looked excellent (71 of 72) precisely because it had been shaped
by the answers.

**3.2 Two further symptoms of the same disease are on the record.** Coverage moves
**16.3 percentage points** depending on whether an approximate fit counts as a fit
— an adjudication the coders made while looking at the outcome. And inter-rater
reliability was **never established**; the paper says so plainly, and says every
per-application statement should be read subject to that.

**3.3 The specific exposure here.** Sheaf theory's 82.4% dissolution figure was
computed *after* seeing `X21` and the failure list. As it stands, a referee is
entitled to say: *you assigned live-sets that make the failures go away, then
reported that the failures went away.* They would be right, and the finding would
not survive review.

**3.4 What blinding buys.** If `ℓ` is assigned from each element's definition
alone — never seeing a protocol, a prohibition row, or a failing pair — and
dissolution still lands ≥70%, the number is a **prediction with a pre-registered
threshold**, not a fit. The same for `ar`: assigned without sight of `D`, the
relation `D′ ⊇ D` becomes retrodiction of a structure the assigner could not see.

**3.5 The sharpest available evidence is a blind retrodiction already on record as
a prediction.** Category theory predicted, before any table exists, that the six
order-book perpetuals venues drop exactly `{Ct, Ex, Li}` because `Pf`'s `V`, `P`
and `K*` ports are singleton-inhabited, while Jupiter carries `Pm` and declares
none of those ports. If a blind colouring reproduces that split without being told
the measurement exists, the structure is doing real work. If it does not, we have
falsified cheaply.

---

## 4. What each outcome buys

**Confirm** (`D′ ⊇ D` acyclic; ≥70% dissolution; GYO residue ≤ 5):
- Tier 1 of the enrichment stack is bought and justified.
- The ports-vs-scope design conflict resolves on evidence rather than taste.
- C1 becomes **checkable**, because 57 typechecked Quint specs already encode the
  state machines — PO-STR-6 becomes a days-scale computation rather than a hope.
- G2 becomes a theorem about a concrete `Σ` instead of a definition.

**Refute** (<40% dissolution, or any arc of `D` contradicted):
- The structure is wrong, and we know it after roughly two days of table work
  rather than after building a paper on it.
- The failure localises: a contradicted arc names the specific colour assignment
  that is wrong, and a low dissolution rate names scope as the wrong axis.

**Either way the cost is bounded and the information is decisive.** That is the
property the prior effort never had: it accumulated measurements that could not
come out wrong, and so learned little from any of them.

---

## 5. The one-line version

> The three theorems are quantified over `Σ`. `ar` and `ℓ` are `Σ`. Until they are
> written, the paper has no subject; and unless they are written blind, its
> headline number is a fit rather than a finding.
