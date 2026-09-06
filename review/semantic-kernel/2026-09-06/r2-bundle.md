# Targeted second review: semantic-kernel pilot

Evaluate the revised candidate against the initial pilot design and the R1 findings below.
Grok R1 passed. Fable R1 passed spec compliance and requested concrete implementation/evidence fixes.
Do not infer approval from either result. Independently check whether the changes resolve each finding
and introduce a concrete regression. This is source analysis; do not run builds, edit files, spawn
agents or fetch external information. If the native CLI offloads this prompt, read the supplied bundle
only. Return spec compliance, implementation quality, any remaining severity-ranked findings, and
what your source review did not establish. Keep the response focused on unresolved actionable issues.

Changes: accepted policy-overgrant check and post-state witnesses (the pilot does not claim to enforce
protocol transition shape); isolated zero-price test and positive-price control; seven source mutations
covering all22 current check-based contracts; input hashes/HEAD/dirty-state binding with clean source
replay after commit; corrected Audit command/liquidity docstring and explicit manual disclosure policy.
The parent compared all51 named source theorem declarations, printed declarations and fresh axiom
output for exact set equality. Full typed IR/capability lifecycle/composition/fidelity remain future work.


## R1 Fable findings
**Spec compliance:** pass. The pilot delivers what the design asks for at the stated scope. All three reference examples run through one generic `Transition` and `check`, the accounting, authority, locality and frame results are proved from `execute_ok_iff` without hidden premises beyond the supplied policy and environment, the required refusal classes are present, and no proof uses `sorry`, custom axioms or `native_decide`. The migration documents keep historical results as evidence and list the remaining corpus, IR, composition, certificate and fidelity work.

**Implementation quality:** changes requested. No proved statement is wrong. The requested changes are small and targeted. The main one is that the fixture policy grants Alice capabilities that let the generic checker accept a vault drain, unbacked share issuance, and debt erasure, and neither a test nor the README makes that limit visible.

**Findings**

1. **Medium. Fixture policy over-grants, and the limit is undisclosed.** `lean/DefiKernel/Examples.lean:23` grants every actor debit authority on all of its own cells, including its debt cell, and grants Alice unconditional debit authority on vault and pool USD plus supply authority on shares and debt. By my reading of `check`, these transitions are accepted against `initial`:

   ```lean
   -- drains vault USD with no share burn
   transfer .alice .vault .alice (Quantity.ofNat 20)
   -- mints shares with no deposit
   { actor := .alice, effect := pulse (.alice, .share) 100,
     supplyChange := fun a ↦ if a = .share then 100 else 0,
     writes := {(.alice, .share)}, guard := fun _ _ ↦ true }
   -- erases the debt token with no repayment
   { actor := .alice, effect := pulse (.alice, .debt) (-2),
     supplyChange := fun a ↦ if a = .debt then -2 else 0,
     writes := {(.alice, .debt)}, guard := fun _ _ ↦ true }
   ```

   Each passes guard, net-debit authority, supply authority, nonnegativity, accounting and footprint. Impact: the collateral guard in `borrow` and the rate formula in `withdraw` are not what gates Alice's access to pool or vault USD, and the "obligation token" wording in the README suggests more than the fixture enforces. The only unauthorized-debit refusals test the actor-not-owner branch. The theorems remain true, since `execute_authority` is stated relative to the supplied policy. Proposed correction, minimum: add accepted-witness theorems for the three cases above under a name such as `policy_overgrant_accepted`, and add one README sentence stating that the fixture policy does not bind capabilities to transition shape. Better: bind vault/pool debit and share/debt supply authority to a transition-kind tag, remove self-debit of `.debt`, and add three refusal examples. The second option can wait for the capability work in package 2 if the first is done now.

2. **Low. Mutation evidence is not bound to the candidate.** The recipe reads the live working tree at an absolute path and `mutation-results.json` records hashes only of the generated mutants, not of the three input files or the commit. Whether the recipe and results are committed under the review directory cannot be seen here. The mutants also cover only the first fourteen acceptance theorems and none of the `execute` or multi-step checks. Proposed correction: record the input SHA-256 values and commit id in the results, store recipe and results under `review/semantic-kernel/2026-09-06/`, and extend the lift to every `check`-based theorem.

3. **Low. The zero-price refusal does not isolate its conjunct.** `lean/DefiKernel/Acceptance.lean:30` refuses because the collateral bound fails at price zero with two units of existing debt. Removing `0 < oracle.price` from the guard leaves every listed check passing. Proposed correction: add a zero-debt fixture and a zero-amount borrow at price zero, where only the price conjunct fails, or drop the conjunct with a comment stating it is implied.

4. **Low. Documentation mismatches.** `lean/README.md:8` tells the reader to run `Acceptance.lean`, which prints nothing. The observed verification ran `Audit.lean`, which is the file that prints the checks and axioms. The docstring at `lean/DefiKernel/Acceptance.lean:59` says twenty shares cannot be redeemed, but the test withdraws eleven. The `#print axioms` list in `Audit.lean` is hand-maintained, so a new theorem would be silently omitted from disclosure. Proposed correction: point the README at `Audit.lean`, fix the docstring, and add a note or count check for the disclosure list.

5. **Informational. Asset-indexed quantities give no checked unit discipline.** `deposit` converts a USD amount into shares by discarding the index on `Quantity`. Nothing claims otherwise, but the design's dimensioned quantities remain open. Likewise `Oracle.now` sits in the same declared record as `observedAt`, so staleness is relative to a supplied clock. The README already bounds oracle fields as declared inputs.

**Evidence limits**

- I did not run the build, the audit or the mutation recipe. The exit codes, the twenty-five runtime results and the forty-three axiom lines are taken from the bundle.
- The bundle contains no diff, so I cannot confirm that `Defialgebra/` proofs are unchanged or that the supplied files match commit `150c2acc`.
- The progress ledger, the supersession notices on older roadmaps, the source proposal and the review records are not in the bundle. My assessment of the migration record covers only the design, plan, claim disposition, README and AGENTS files.
- The `decide +kernel` proofs depend on kernel reduction of mathlib rationals and the hand-written `Fintype` instances. I accept them on the reported green build only.
- Process claims, such as writing acceptance statements before implementations, cannot be assessed from source.


## Verification
{
  "full_build_exit": 0,
  "full_build_jobs": 988,
  "fresh_audit_exit": 0,
  "runtime_checks": "33/33",
  "named_theorems": 51,
  "disclosures_cover_every_named_pilot_theorem": true,
  "axioms": [
    "Classical.choice",
    "Quot.sound",
    "propext"
  ],
  "mutation_control": "22/22",
  "mutants_discriminated": "7/7",
  "mutation_input_sources_match_candidate": true
}

## FILE AGENTS.md

1: # Working instructions
2: 
3: The user approved the semantic-kernel pivot on 2026-09-06. Read
4: `docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
5: `docs/research/semantic-kernel-progress.md` before continuing work.
6: 
7: - The new migration supersedes the old publication-first runstate and the
8:   positive-program primitive-basis mandate. Historical documents remain
9:   evidence, not instructions to pursue a withdrawn objective.
10: - Use GPT-6 for implementation through the stock Codex harness. Have Grok and
11:   Fable independently check substantive results. Invoke their native CLIs
12:   directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
13:   label its response Grok or Fable.
14: - Record the exact reviewed revision, requested/reported model identity,
15:   result, findings, and fixes. An unavailable reviewer is an open review, not
16:   an approval. Review is advisory evidence, not a mathematical proof.
17: - Preserve existing proofs and negative results. Put new kernel work in a
18:   separate namespace. Do not change a historical theorem statement to make a
19:   new claim pass.
20: - Read `.claude/skills/defi-footguns/SKILL.md` and
21:   `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
22:   Empty checks are blocked. Keep proof, bounded execution, measurement and
23:   unchecked assumptions distinct, with exact input and tool identities.
24: - Lean is the mathematical authority. Any executable IR or Quint abstraction
25:   needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
26:   in accepted kernel proofs.
27: - Preserve the original corpus and versioned source evidence. Do not silently
28:   relabel development examples as untouched holdouts.
29: - User authorization to execute this migration is already present. Resolve
30:   routine implementation details without repeatedly requesting approval.


## FILE docs/superpowers/specs/2026-09-06-semantic-kernel-design.md

1: # DeFi semantic kernel: approved migration design
2: 
3: Approved by Charles Hoskinson on 2026-09-06: save the assessed plan and begin
4: execution, using GPT-6 implementation and Grok/Fable review through the stock
5: GPT harness. Do not use Foreman. Base: local commit `8ae0bbf`, 22 commits ahead
6: of the observed GitHub main `25a13c6`. Preserve those local commits.
7: 
8: ## Objective
9: 
10: Establish conditional preservation of financial properties under composition.
11: Separate the empirical ontology, verified financial libraries, typed open
12: transition semantics, and chain/runtime adapters. Environment assumptions cross
13: all layers. A primitive count is not the research objective.
14: 
15: The supplied proposal is preserved verbatim in
16: `../../research/2026-09-06-defi-source-plan.md`. Its external citation tokens and
17: two sandbox attachment links are unresolved source material, not verified
18: references. The assessment below refines that proposal and governs execution.
19: 
20: ## Seven work packages
21: 
22: 1. **Research mandate and claims.** Supersede both the positive-program roadmap
23:    and the August AFT roadmap. Update the README and working instructions.
24:    Preserve historical claims with explicit corrections: withdraw the Q/Sigma
25:    semantic split and four-primitive objective; distinguish syntactic
26:    independence from semantic minimality; correct Delta terminology and the
27:    unsupported inference from clause polarity to absence of a lattice. Audit
28:    the paper's claim sites before changing published theorem statements.
29: 2. **Kernel specification.** Define typed identities, dimensioned quantities,
30:    exact arithmetic, transitions, guards/refusals, observations, footprints,
31:    capabilities, claims, and assumptions. Define operational composition modes
32:    separately. Lean is the mathematical authority. Executable IR and any Quint
33:    abstractions must have stated correspondence to it.
34: 3. **Corpus normalization.** Preserve all historical rows. Introduce
35:    organization/product/version/deployment identities, source revisions,
36:    chain identity, faceted labels, graph relationships, ambiguity, and residue.
37:    Split bundled products and versions. Independent annotations and their
38:    adjudication rules are required. Recover or reconstruct the proposal's
39:    missing CSV and JSON Schema; recover its external references.
40: 4. **Verification path.** Replace keyword certification with checks of typed
41:    semantics, footprints, authority, accounting, interfaces, library proof
42:    instantiation, assumptions, and source correspondence. Bind evidence to
43:    exact inputs and tool versions. Distinguish proved, bounded, measured,
44:    refuted, and unchecked obligations. Retain useful existing failure-reporting
45:    and fidelity infrastructure, including refused behavior.
46: 5. **Metatheory.** Prove initialization and preservation for typing, asset
47:    accounting, authority and locality; then composition, claim lifecycle and
48:    conservative extension. Generalize Interface.lean and Nary.lean without
49:    broadening their historical claims. Assume-guarantee rules need causal or
50:    inductive premises and initialization, not circular implication alone.
51:    Frame predicates must depend only on the protected footprint.
52: 6. **Financial libraries and fidelity.** Port exact arithmetic, concentrated
53:    liquidity, Curve iteration, ordered redemption, loss allocation, transient
54:    accounting, asynchronous messages, margin/funding, and conditional claims.
55:    Pin reference implementations and observations. Use differential execution,
56:    characteristic mutations, and selected concrete refinement proofs.
57: 7. **Generalization and publication.** Freeze the kernel before evaluating
58:    untouched holdouts. Cases already used to design the kernel are development
59:    challenges, not untouched holdouts. Track new kernel concepts separately
60:    from new libraries, coverage, assumptions, and verification effort. Rewrite
61:    the paper around demonstrated results; adapt visualization after the schema
62:    settles. Moriarty, Compact, ZKIR and runtime proofs remain adapter work until
63:    verified interfaces exist.
64: 
65: ## First executable increment
66: 
67: Build a deliberately scoped Lean pilot, not the complete future IR. Use one
68: generic transition representation for a transfer, a fixed-rate vault
69: deposit/withdrawal, and an oracle-dependent collateralized borrow. These are
70: reference examples, not assertions of ERC-20/ERC-4626/deployed credit fidelity.
71: 
72: The core records actor, state updates, asset-indexed effects, authority checks,
73: and declared environment input. Financial formulas and protocol guards live in
74: example definitions. Require successful and refused examples, generic
75: accounting/locality results, and negative cases that actually violate the
76: proposed checks. A proof of an implication must not be advertised as automatic
77: inference of its hypotheses. Ordinary Lean proof terms are the pilot evidence;
78: no serialized third-party certificate checker is claimed in this increment.
79: 
80: Pilot numeric domain is explicit exact mathematical arithmetic, with
81: nonnegative balances and guarded debits. Machine-width arithmetic and chain
82: rounding require later refinement. No market truth, generic solvency, liveness,
83: deployed-contract correspondence, or full composition theorem is claimed.
84: 
85: ## Acceptance and execution
86: 
87: - Preserve source proposal and this design; save a milestone ledger.
88: - Build the existing Lean baseline before edits.
89: - Add the pilot in a fresh namespace and Lake target without altering old proofs.
90: - Check proofs with Lean, with no `sorry`, custom axioms, or `native_decide`.
91: - Include live positive/negative examples: unauthorized debit, insufficient
92:   funds, unbalanced effects, wrong-asset accounting, and rejected credit inputs.
93: - Independently review the exact candidate with Grok and Fable; record model,
94:   input identity, raw result, findings, and remediation. Use direct native CLI
95:   processes launched by Codex, not Foreman. Initial review plus one targeted
96:   re-review; additional review requires a concrete unresolved finding.
97: - Keep the remaining seven-package work visible. Completing this increment
98:   does not complete the full migration or its first three-example fidelity gate.
99: 
100: The first useful milestone is three executable models, checked initial
101: preservation proofs, and broken variants rejected by the appropriate check.
102: Calendar estimates are provisional; acceptance conditions govern progress.


## FILE lean/README.md

1: # DeFi formal developments
2: 
3: Run from this directory:
4: 
5: ```sh
6: lake build                  # historical algebra and new kernel pilot
7: lake build DefiKernel       # pilot, including its acceptance declarations
8: lake env lean DefiKernel/Audit.lean  # fresh runtime output and axiom disclosure
9: ```
10: 
11: Use the versions pinned in `lean-toolchain` and `lake-manifest.json`.
12: For a fresh dependency checkout, `lake exe cache get` obtains the mathlib cache.
13: 
14: `Defialgebra/` retains the historical mathematical results and counterexamples.
15: `DefiKernel/` is the first executable increment of the
16: [approved migration](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).
17: The [progress ledger](../docs/research/semantic-kernel-progress.md) records the
18: observed verification and independent review status.
19: 
20: ## Pilot scope
21: 
22: - Four account identities and four asset identities; exact rational quantities.
23: - A generic checker for guards, net-debit and supply authority, nonnegative
24:   balances, asset-wise accounting, and write footprints.
25: - Transfer, a vault with a fixed exchange rate, and collateralized borrowing
26:   using a declared oracle observation, all through the same transition type.
27: - Lean proofs relating successful execution to its checks, accounting and
28:   locality, plus a frame lemma with an explicit predicate-dependency premise.
29: - Concrete accepted/refused examples and deliberately broken transitions.
30: 
31: The supplied policy is a trust assumption. It does not authenticate callers or
32: implement capability issuance/revocation. In particular, the fixture grants
33: permissions without binding them to transition shape: it accepts a vault drain
34: without share burn, share issuance without a deposit, and debt erasure without
35: repayment. Accepted counterexamples make this boundary explicit. The generic
36: accounting and policy-relative authority theorems still hold for those effects;
37: the fixture is not a safe policy for a financial application.
38: 
39: Oracle feed and timestamp fields are
40: declared inputs; checking them does not establish provenance or market truth.
41: Debt is represented as a distinct nonnegative obligation token in the reference
42: example. This is not a general party/claim lifecycle model.
43: 
44: The pilot accepts Lean functions for guards and effects. It is not yet a closed,
45: serialized IR or a checker for untrusted external proof packages. It does not
46: prove general operational composition, intermediate-effect authority,
47: machine-width arithmetic refinement, deployed-contract correspondence,
48: economic solvency, or asynchronous liveness. These remain migration obligations.
49: 
50: Lean proof terms are the current evidence format. Concrete acceptance theorems
51: check their stated examples; they do not establish corpus-wide adequacy.
52: `Audit.lean` maintains an explicit axiom-disclosure list. When adding or removing
53: a theorem, update that list and compare it against all named pilot theorem
54: declarations before reporting complete disclosure. The recorded count applies
55: only to the exact audited source snapshot.


## FILE lean/lakefile.toml

1: name = "defialgebra"
2: version = "0.1.0"
3: keywords = ["math"]
4: defaultTargets = ["Defialgebra", "DefiKernel"]
5: 
6: [leanOptions]
7: pp.unicode.fun = true # pretty-prints `fun a ↦ b`
8: relaxedAutoImplicit = false
9: weak.linter.mathlibStandardSet = true
10: maxSynthPendingDepth = 3
11: 
12: [[require]]
13: name = "mathlib"
14: scope = "leanprover-community"
15: rev = "v4.33.0-rc2"
16: 
17: [[lean_lib]]
18: name = "Defialgebra"
19: 
20: [[lean_lib]]
21: name = "DefiKernel"


## FILE lean/lean-toolchain

1: leanprover/lean4:v4.33.0-rc2


## FILE lean/DefiKernel.lean

1: import DefiKernel.Audit
2: 
3: /-! Entry point for the bounded semantic kernel, reference models, and checked regressions. -/


## FILE lean/DefiKernel/Core.lean

1: import Mathlib.Data.Rat.Defs
2: import Mathlib.Algebra.BigOperators.Group.Finset.Basic
3: import Mathlib.Data.Fintype.Prod
4: import Mathlib.Tactic.Linarith
5: 
6: /-!
7: A finite reference ledger with exact rational arithmetic. Asset indices distinguish units;
8: nonnegative quantities and states exclude negative holdings. Effects are signed changes.
9: Authority policy and environment inputs are supplied assumptions, not authenticated facts.
10: Authority checks concern net debits, not intermediate execution traces.
11: Only write locality is checked: this pilot does not track reads or prove composition.
12: -/
13: namespace DefiKernel
14: 
15: inductive Account where
16:   | alice | bob | vault | pool
17:   deriving DecidableEq, Repr
18: 
19: inductive Asset where
20:   | usd | share | collateral | debt
21:   deriving DecidableEq, Repr
22: 
23: instance : Fintype Account := ⟨{.alice, .bob, .vault, .pool}, by
24:   intro x; cases x <;> simp⟩
25: 
26: instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
27:   intro x; cases x <;> simp⟩
28: 
29: abbrev Cell := Account × Asset
30: 
31: /-- Exact nonnegative quantity in the unit of asset `a`. -/
32: structure Quantity (a : Asset) where
33:   amount : ℚ
34:   nonneg : 0 ≤ amount
35: 
36: def Quantity.ofNat {a : Asset} (n : ℕ) : Quantity a := ⟨n, by positivity⟩
37: 
38: /-- Debt is a separate nonnegative obligation token, not a negative cash balance. -/
39: structure State where
40:   balance : Cell → ℚ
41:   nonneg : ∀ c, 0 ≤ balance c
42: 
43: /-- External capability policy. Permission to debit and to change supply are separate. -/
44: structure Policy where
45:   debit : Account → Cell → Bool
46:   supply : Account → Asset → Bool
47: 
48: /-- A proposal with explicit net effects, per-asset issuance/burn, and write footprint. -/
49: structure Transition (Env : Type) where
50:   actor : Account
51:   effect : Cell → ℚ
52:   supplyChange : Asset → ℚ
53:   writes : Finset Cell
54:   guard : State → Env → Bool
55: 
56: inductive Refusal where
57:   | guard | unauthorizedDebit | unauthorizedSupply | insufficientFunds | accounting | footprint
58:   deriving DecidableEq, Repr
59: 
60: def DebitAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
61:   ∀ c, t.effect c < 0 → p.debit t.actor c = true
62: 
63: def SupplyAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
64:   ∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true
65: 
66: def NonnegativeUpdate {E : Type} (s : State) (t : Transition E) : Prop :=
67:   ∀ c, 0 ≤ s.balance c + t.effect c
68: 
69: def Accounted {E : Type} (t : Transition E) : Prop :=
70:   ∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a
71: 
72: def Local {E : Type} (t : Transition E) : Prop :=
73:   ∀ c, c ∉ t.writes → t.effect c = 0
74: 
75: instance {E : Type} (p : Policy) (t : Transition E) : Decidable (DebitAuthorized p t) :=
76:   inferInstanceAs (Decidable (∀ c, t.effect c < 0 → p.debit t.actor c = true))
77: instance {E : Type} (p : Policy) (t : Transition E) : Decidable (SupplyAuthorized p t) :=
78:   inferInstanceAs (Decidable (∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true))
79: instance {E : Type} (s : State) (t : Transition E) : Decidable (NonnegativeUpdate s t) :=
80:   inferInstanceAs (Decidable (∀ c, 0 ≤ s.balance c + t.effect c))
81: instance {E : Type} (t : Transition E) : Decidable (Accounted t) :=
82:   inferInstanceAs (Decidable (∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a))
83: instance {E : Type} (t : Transition E) : Decidable (Local t) :=
84:   inferInstanceAs (Decidable (∀ c, c ∉ t.writes → t.effect c = 0))
85: 
86: /-- Checks actual finite effects. The first failing check determines the refusal reason. -/
87: def check {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
88:     Option Refusal :=
89:   if t.guard s env = false then some .guard
90:   else if ¬ DebitAuthorized p t then some .unauthorizedDebit
91:   else if ¬ SupplyAuthorized p t then some .unauthorizedSupply
92:   else if ¬ NonnegativeUpdate s t then some .insufficientFunds
93:   else if ¬ Accounted t then some .accounting
94:   else if ¬ Local t then some .footprint
95:   else none
96: 
97: /-- The explicit conjunction checked by `check`; no inference of external truth is claimed. -/
98: def Valid {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) : Prop :=
99:   t.guard s env = true ∧ DebitAuthorized p t ∧ SupplyAuthorized p t ∧
100:     NonnegativeUpdate s t ∧ Accounted t ∧ Local t
101: 
102: theorem check_eq_none_iff {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
103:     check p env t s = none ↔ Valid p env t s := by
104:   by_cases hg : t.guard s env = true
105:   · by_cases hd : DebitAuthorized p t <;>
106:       by_cases hs : SupplyAuthorized p t <;>
107:       by_cases hn : NonnegativeUpdate s t <;>
108:       by_cases ha : Accounted t <;>
109:       by_cases hl : Local t <;> simp [check, Valid, hg, hd, hs, hn, ha, hl]
110:   · have hf : t.guard s env = false := Bool.eq_false_iff.mpr hg
111:     simp [check, Valid, hf]
112: 
113: /-- Apply a checked effect; its nonnegativity proof constructs the resulting state. -/
114: def applyEffect {E : Type} (s : State) (t : Transition E) (h : NonnegativeUpdate s t) : State :=
115:   ⟨fun c ↦ s.balance c + t.effect c, h⟩
116: 
117: /-- Refusal has no post-state; successful execution constructs a nonnegative state. -/
118: def execute {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
119:     Except Refusal State :=
120:   match h : check p env t s with
121:   | some reason => .error reason
122:   | none => .ok (applyEffect s t ((check_eq_none_iff p env t s).mp h).2.2.2.1)
123: 
124: def total (s : State) (a : Asset) : ℚ := ∑ owner, s.balance (owner, a)
125: 
126: /-- Accounting is asset-wise and includes explicit authorized issuance or burn. -/
127: theorem applyEffect_accounting {E : Type} (s : State) (t : Transition E)
128:     (h : NonnegativeUpdate s t) (ha : Accounted t) (a : Asset) :
129:     total (applyEffect s t h) a = total s a + t.supplyChange a := by
130:   simp only [total, applyEffect, Finset.sum_add_distrib, ha a]
131: 
132: theorem applyEffect_locality {E : Type} (s : State) (t : Transition E)
133:     (h : NonnegativeUpdate s t) (hl : Local t) (c : Cell) (hc : c ∉ t.writes) :
134:     (applyEffect s t h).balance c = s.balance c := by
135:   simp [applyEffect, hl c hc]
136: 
137: /-- A framed predicate must explicitly depend only on observations outside the write set. -/
138: theorem applyEffect_frame {E : Type} (s : State) (t : Transition E)
139:     (h : NonnegativeUpdate s t) (hl : Local t) (P : State → Prop)
140:     (depends : ∀ s₁ s₂ : State,
141:       (∀ c, c ∉ t.writes → s₁.balance c = s₂.balance c) → (P s₁ ↔ P s₂))
142:     (hp : P s) : P (applyEffect s t h) := by
143:   apply (depends s (applyEffect s t h) ?_).mp hp
144:   intro c hc
145:   exact (applyEffect_locality s t h hl c hc).symm
146: 
147: /-- Success entails the checks and the precise state update, linking execution to the proofs. -/
148: theorem execute_ok_iff {E : Type} (p : Policy) (env : E) (t : Transition E)
149:     (s s' : State) : execute p env t s = .ok s' ↔
150:       ∃ h : Valid p env t s, applyEffect s t h.2.2.2.1 = s' := by
151:   unfold execute
152:   split
153:   next reason he =>
154:     simp only [reduceCtorEq, false_iff, not_exists]
155:     intro hv
156:     have hn := (check_eq_none_iff p env t s).mpr hv
157:     simp [he] at hn
158:   next he =>
159:     constructor
160:     · intro hs
161:       exact ⟨(check_eq_none_iff p env t s).mp he, Except.ok.inj hs⟩
162:     · rintro ⟨hv, rfl⟩
163:       rfl
164: 
165: /-- Every accepted net debit has the supplied policy's authority.
166: Identity authentication is external. -/
167: theorem execute_authority {E : Type} (p : Policy) (env : E) (t : Transition E)
168:     (s s' : State) (h : execute p env t s = .ok s') :
169:     DebitAuthorized p t ∧ SupplyAuthorized p t := by
170:   obtain ⟨hv, _⟩ := (execute_ok_iff p env t s s').mp h
171:   exact ⟨hv.2.1, hv.2.2.1⟩
172: 
173: theorem execute_accounting {E : Type} (p : Policy) (env : E) (t : Transition E)
174:     (s s' : State) (h : execute p env t s = .ok s') (a : Asset) :
175:     total s' a = total s a + t.supplyChange a := by
176:   obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
177:   exact applyEffect_accounting s t hv.2.2.2.1 hv.2.2.2.2.1 a
178: 
179: theorem execute_locality {E : Type} (p : Policy) (env : E) (t : Transition E)
180:     (s s' : State) (h : execute p env t s = .ok s') (c : Cell) (hc : c ∉ t.writes) :
181:     s'.balance c = s.balance c := by
182:   obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
183:   exact applyEffect_locality s t hv.2.2.2.1 hv.2.2.2.2.2 c hc
184: 
185: end DefiKernel


## FILE lean/DefiKernel/Examples.lean

1: import DefiKernel.Core
2: import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
3: import Mathlib.Tactic.NormNum
4: 
5: /-!
6: Reference models, not deployed protocol specifications. The finite universe has four accounts
7: and four assets. Arithmetic is unbounded exact rational arithmetic, without machine rounding.
8: The fixed vault rate is two USD units per share. Credit records a nonnegative debt token and
9: uses declared locked collateral; oracle identity, age and price bounds do not prove market truth.
10: -/
11: namespace DefiKernel.Examples
12: 
13: /-- A signed effect on exactly one asset/account cell. -/
14: def pulse (target : Cell) (amount : ℚ) (c : Cell) : ℚ :=
15:   if c = target then amount else 0
16: 
17: /-- Net movement handles self-transfers by cancellation. -/
18: def move (asset : Asset) (src dst : Account) (amount : ℚ) (c : Cell) : ℚ :=
19:   pulse (dst, asset) amount c - pulse (src, asset) amount c
20: 
21: /-- Alice has explicit vault/pool USD debit and share/debt supply capabilities in this fixture.
22: This policy is an input assumption; the kernel does not authenticate or derive the grant.
23: Grants are not bound to transition shape: accepted counterexamples below drain the vault,
24: issue unbacked shares, and burn debt without repayment. This is not a protocol access policy. -/
25: def policy : Policy where
26:   debit actor c := decide (actor = c.1 ∨
27:     (actor = .alice ∧ (c = (.vault, .usd) ∨ c = (.pool, .usd))))
28:   supply actor asset := decide (actor = .alice ∧ (asset = .share ∨ asset = .debt))
29: 
30: /-- A single nonnegative initial ledger, including ten units of declared locked collateral. -/
31: def initial : State where
32:   balance c := match c with
33:     | (.alice, .usd) => 10
34:     | (.alice, .share) => 4
35:     | (.alice, .collateral) => 10
36:     | (.alice, .debt) => 2
37:     | (.vault, .usd) => 20
38:     | (.pool, .usd) => 100
39:     | _ => 0
40:   nonneg c := by rcases c with ⟨owner, asset⟩; cases owner <;> cases asset <;> norm_num
41: 
42: /-- A USD transfer. Zero and self-transfers are permitted; only net debits require authority. -/
43: def transfer (actor src dst : Account) (q : Quantity .usd) : Transition Unit where
44:   actor := actor
45:   effect := move .usd src dst q.amount
46:   supplyChange := fun _ ↦ 0
47:   writes := {(src, .usd), (dst, .usd)}
48:   guard := fun _ _ ↦ true
49: 
50: /-- Deposit USD and mint shares at the exact fixed rate two USD per share. -/
51: def deposit (q : Quantity .usd) : Transition Unit where
52:   actor := .alice
53:   effect := fun c ↦ move .usd .alice .vault q.amount c + pulse (.alice, .share) (q.amount / 2) c
54:   supplyChange := fun a ↦ if a = .share then q.amount / 2 else 0
55:   writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
56:   guard := fun _ _ ↦ true
57: 
58: /-- Burn shares and withdraw USD at the same fixed rate. Liquidity and shares are checked. -/
59: def withdraw (q : Quantity .share) : Transition Unit where
60:   actor := .alice
61:   effect := fun c ↦ move .usd .vault .alice (2 * q.amount) c - pulse (.alice, .share) q.amount c
62:   supplyChange := fun a ↦ if a = .share then -q.amount else 0
63:   writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
64:   guard := fun _ _ ↦ true
65: 
66: /-- Declared oracle observation: feed identifier and timestamps are not authenticated here.
67: Price has the declared unit USD per collateral unit. Debt is denominated in USD units. -/
68: structure Oracle where
69:   feed : ℕ
70:   price : ℚ
71:   observedAt : ℕ
72:   now : ℕ
73:   deriving Repr
74: 
75: /-- Borrow USD and mint an equal USD-denominated debt obligation. The reference guard requires
76: feed 7, positive price, age at most five, no future timestamp, and 200% collateralization using
77: that declared price and the pre-state's declared locked collateral. No market solvency claim. -/
78: def borrow (q : Quantity .usd) : Transition Oracle where
79:   actor := .alice
80:   effect := fun c ↦ move .usd .pool .alice q.amount c + pulse (.alice, .debt) q.amount c
81:   supplyChange := fun a ↦ if a = .debt then q.amount else 0
82:   writes := {(.alice, .usd), (.pool, .usd), (.alice, .debt)}
83:   guard := fun s oracle ↦ decide (oracle.feed = 7 ∧ 0 < oracle.price ∧
84:     oracle.observedAt ≤ oracle.now ∧ oracle.now ≤ oracle.observedAt + 5 ∧
85:     2 * (s.balance (.alice, .debt) + q.amount) ≤
86:       s.balance (.alice, .collateral) * oracle.price)
87: 
88: def fresh : Oracle := ⟨7, 2, 98, 100⟩
89: def stale : Oracle := ⟨7, 2, 90, 100⟩
90: def zeroPrice : Oracle := ⟨7, 0, 98, 100⟩
91: def future : Oracle := ⟨7, 2, 101, 100⟩
92: 
93: /-- Broken effects, not a bad proof premise: one USD is debited but two are credited. -/
94: def unbalanced : Transition Unit :=
95:   { transfer .alice .alice .bob (Quantity.ofNat 1) with
96:     effect := fun c ↦ pulse (.bob, .usd) 2 c - pulse (.alice, .usd) 1 c }
97: 
98: /-- Scalar deltas cancel, but one USD cannot account for a share. -/
99: def wrongAsset : Transition Unit :=
100:   { transfer .alice .alice .bob (Quantity.ofNat 1) with
101:     effect := fun c ↦ pulse (.bob, .share) 1 c - pulse (.alice, .usd) 1 c
102:     writes := {(.alice, .usd), (.bob, .share)} }
103: 
104: /-- Balanced and authorized, but omits a cell that really changes. -/
105: def wrongFootprint : Transition Unit :=
106:   { transfer .alice .alice .bob (Quantity.ofNat 1) with writes := {(.alice, .usd)} }
107: 
108: /-- Correctly balanced issuance with no grant to change share supply. -/
109: def unauthorizedIssue : Transition Unit where
110:   actor := .bob
111:   effect := pulse (.bob, .share) 1
112:   supplyChange := fun a ↦ if a = .share then 1 else 0
113:   writes := {(.bob, .share)}
114:   guard := fun _ _ ↦ true
115: 
116: /-- Counterexample fixture isolates vault liquidity from share ownership. -/
117: def richShares : State where
118:   balance c := if c = (.alice, .share) then 20 else initial.balance c
119:   nonneg c := by
120:     split
121:     · norm_num
122:     · exact initial.nonneg c
123: 
124: /-- Accepted policy counterexample: no share burn accompanies this vault debit. -/
125: def policyVaultDrain : Transition Unit := transfer .alice .vault .alice (Quantity.ofNat 20)
126: 
127: /-- Accepted policy counterexample: supply permission alone does not require a deposit. -/
128: def policyUnbackedIssue : Transition Unit where
129:   actor := .alice
130:   effect := pulse (.alice, .share) 100
131:   supplyChange := fun a ↦ if a = .share then 100 else 0
132:   writes := {(.alice, .share)}
133:   guard := fun _ _ ↦ true
134: 
135: /-- Accepted policy counterexample: the owner may burn debt without repayment. -/
136: def policyDebtBurn : Transition Unit where
137:   actor := .alice
138:   effect := pulse (.alice, .debt) (-2)
139:   supplyChange := fun a ↦ if a = .debt then -2 else 0
140:   writes := {(.alice, .debt)}
141:   guard := fun _ _ ↦ true
142: 
143: /-- Zero debt isolates the positive-price conjunct when the requested borrow is also zero. -/
144: def zeroDebt : State where
145:   balance c := if c = (.alice, .debt) then 0 else initial.balance c
146:   nonneg c := by
147:     split
148:     · norm_num
149:     · exact initial.nonneg c
150: 
151: /-- Constructor accounting holds for every amount, independently of execution guards. -/
152: theorem transfer_accounted (actor src dst : Account) (q : Quantity .usd) :
153:     Accounted (transfer actor src dst q) := by
154:   intro a
155:   cases src <;> cases dst <;> cases a <;>
156:     simp [transfer, move, pulse]
157: 
158: theorem deposit_accounted (q : Quantity .usd) : Accounted (deposit q) := by
159:   intro a
160:   cases a <;> simp [deposit, move, pulse]
161: 
162: theorem withdraw_accounted (q : Quantity .share) : Accounted (withdraw q) := by
163:   intro a
164:   cases a <;> simp [withdraw, move, pulse]
165: 
166: theorem borrow_accounted (q : Quantity .usd) : Accounted (borrow q) := by
167:   intro a
168:   cases a <;> simp [borrow, move, pulse]
169: 
170: /-- Executable observation preserves the refusal reason. -/
171: def observe (result : Except Refusal State) (cells : List Cell) : Except Refusal (List ℚ) :=
172:   result.map (fun s ↦ cells.map s.balance)
173: 
174: /-- Explicit complete finite observation domain, in stable display order. -/
175: def allCells : List Cell :=
176:   ([.alice, .bob, .vault, .pool] : List Account).flatMap fun owner ↦
177:     ([.usd, .share, .collateral, .debt] : List Asset).map fun asset ↦ (owner, asset)
178: 
179: theorem allCells_complete (c : Cell) : c ∈ allCells := by
180:   rcases c with ⟨owner, asset⟩
181:   cases owner <;> cases asset <;> decide
182: 
183: /-- Accepted borrowing preserves the example's declared-price collateral bound in its post-state.
184: This is conditional on the guard and on the external meaning of price and locked collateral. -/
185: theorem borrow_declared_collateral_bound (p : Policy) (oracle : Oracle) (q : Quantity .usd)
186:     (s s' : State) (h : execute p oracle (borrow q) s = .ok s') :
187:     2 * s'.balance (.alice, .debt) ≤ s'.balance (.alice, .collateral) * oracle.price := by
188:   obtain ⟨hv, rfl⟩ := (execute_ok_iff p oracle (borrow q) s s').mp h
189:   have hg := hv.1
190:   simp only [borrow, decide_eq_true_eq] at hg
191:   simpa [applyEffect, borrow, move, pulse] using hg.2.2.2.2
192: 
193: end DefiKernel.Examples


## FILE lean/DefiKernel/Acceptance.lean

1: import DefiKernel.Examples
2: 
3: /-! Concrete behavior contracts for the bounded reference examples. -/
4: namespace DefiKernel
5: open Examples
6: 
7: theorem transfer_accept : check policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial =
8:     none := by decide +kernel
9: 
10: theorem transfer_unauthorized :
11:     check policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial =
12:       some .unauthorizedDebit := by decide +kernel
13: 
14: theorem transfer_insufficient :
15:     check policy () (transfer .alice .alice .bob (Quantity.ofNat 11)) initial =
16:       some .insufficientFunds := by decide +kernel
17: 
18: theorem deposit_accept :
19:     check policy () (deposit (Quantity.ofNat 4)) initial = none := by decide +kernel
20: 
21: theorem withdraw_accept :
22:     check policy () (withdraw (Quantity.ofNat 2)) initial = none := by decide +kernel
23: 
24: theorem borrow_accept :
25:     check policy fresh (borrow (Quantity.ofNat 3)) initial = none := by decide +kernel
26: 
27: theorem stale_oracle_refused :
28:     check policy stale (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel
29: 
30: theorem zero_price_refused :
31:     check policy zeroPrice (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel
32: 
33: theorem future_oracle_refused :
34:     check policy future (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel
35: 
36: theorem excess_credit_refused :
37:     check policy fresh (borrow (Quantity.ofNat 9)) initial = some .guard := by decide +kernel
38: 
39: theorem unbalanced_refused :
40:     check policy () unbalanced initial = some .accounting := by decide +kernel
41: 
42: theorem wrong_asset_refused :
43:     check policy () wrongAsset initial = some .accounting := by decide +kernel
44: 
45: theorem wrong_footprint_refused :
46:     check policy () wrongFootprint initial = some .footprint := by decide +kernel
47: 
48: theorem unauthorized_issue_refused :
49:     check policy () unauthorizedIssue initial = some .unauthorizedSupply := by decide +kernel
50: 
51: theorem wrong_feed_refused :
52:     check policy { fresh with feed := 8 } (borrow (Quantity.ofNat 3)) initial =
53:       some .guard := by decide +kernel
54: 
55: theorem insufficient_shares_refused :
56:     check policy () (withdraw (Quantity.ofNat 5)) initial =
57:       some .insufficientFunds := by decide +kernel
58: 
59: /-- Twenty USD cannot redeem the requested eleven shares, despite twenty shares being held. -/
60: theorem insufficient_vault_liquidity_refused :
61:     check policy () (withdraw (Quantity.ofNat 11)) richShares =
62:       some .insufficientFunds := by decide +kernel
63: 
64: /-- Zero debt and zero borrowing make the collateral inequality true even at price zero. -/
65: theorem isolated_zero_price_refused :
66:     check policy zeroPrice (borrow (Quantity.ofNat 0)) zeroDebt = some .guard := by decide +kernel
67: 
68: theorem zero_borrow_positive_price_accept :
69:     check policy fresh (borrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel
70: 
71: /-- Accepted counterexamples expose grants that are not bound to transition shape. -/
72: theorem policy_overgrant_vault_drain_accepted :
73:     check policy () policyVaultDrain initial = none := by decide +kernel
74: 
75: theorem policy_overgrant_unbacked_issue_accepted :
76:     check policy () policyUnbackedIssue initial = none := by decide +kernel
77: 
78: theorem policy_overgrant_debt_burn_accepted :
79:     check policy () policyDebtBurn initial = none := by decide +kernel
80: 
81: theorem transfer_post :
82:     observe (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
83:       [(.alice, .usd), (.bob, .usd)] = .ok [7, 3] := by decide +kernel
84: 
85: theorem deposit_post :
86:     observe (execute policy () (deposit (Quantity.ofNat 4)) initial)
87:       [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [6, 24, 6] := by decide +kernel
88: 
89: theorem withdraw_post :
90:     observe (execute policy () (withdraw (Quantity.ofNat 2)) initial)
91:       [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [14, 16, 2] := by decide +kernel
92: 
93: theorem borrow_post :
94:     observe (execute policy fresh (borrow (Quantity.ofNat 3)) initial)
95:       [(.alice, .usd), (.pool, .usd), (.alice, .debt), (.alice, .collateral)] =
96:       .ok [13, 97, 5, 10] := by decide +kernel
97: 
98: /-- Observable round trip across every cell, not just the deposited asset. -/
99: theorem vault_round_trip :
100:     observe (do
101:       let s ← execute policy () (deposit (Quantity.ofNat 4)) initial
102:       execute policy () (withdraw (Quantity.ofNat 2)) s) allCells =
103:       .ok (allCells.map initial.balance) := by decide +kernel
104: 
105: /-- Two borrows update debt; a third is refused using that updated debt. -/
106: theorem repeated_borrow_refused :
107:     observe (do
108:       let s₁ ← execute policy fresh (borrow (Quantity.ofNat 3)) initial
109:       let s₂ ← execute policy fresh (borrow (Quantity.ofNat 3)) s₁
110:       execute policy fresh (borrow (Quantity.ofNat 3)) s₂) [(.alice, .debt)] =
111:       .error .guard := by decide +kernel
112: 
113: theorem unauthorized_execute_refused :
114:     observe (execute policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial)
115:       allCells = .error .unauthorizedDebit := by decide +kernel
116: 
117: /-- A too-large self-transfer is still a no-op under the documented net-effect semantics. -/
118: theorem self_transfer_noop :
119:     observe (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial)
120:       allCells = .ok (allCells.map initial.balance) := by decide +kernel
121: 
122: /-- The vault loses its twenty USD while Alice's share balance is unchanged. -/
123: theorem policy_overgrant_vault_drain_post :
124:     observe (execute policy () policyVaultDrain initial)
125:       [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [30, 0, 4] := by decide +kernel
126: 
127: /-- One hundred shares appear without any USD deposit. -/
128: theorem policy_overgrant_unbacked_issue_post :
129:     observe (execute policy () policyUnbackedIssue initial)
130:       [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [10, 20, 104] := by decide +kernel
131: 
132: /-- Debt disappears without any USD repayment to the pool. -/
133: theorem policy_overgrant_debt_burn_post :
134:     observe (execute policy () policyDebtBurn initial)
135:       [(.alice, .usd), (.pool, .usd), (.alice, .debt)] = .ok [10, 100, 0] := by decide +kernel
136: 
137: /-- This defective effect defeats scalar accounting while violating asset accounting. -/
138: theorem wrong_asset_scalar_cancels :
139:     (∑ a, ∑ owner, wrongAsset.effect (owner, a)) = 0 := by decide +kernel
140: 
141: theorem wrong_asset_not_accounted : ¬ Accounted wrongAsset := by decide +kernel
142: 
143: theorem unbalanced_not_accounted : ¬ Accounted unbalanced := by decide +kernel
144: 
145: theorem missing_footprint_changes_balance :
146:     (.bob, .usd) ∉ wrongFootprint.writes ∧ wrongFootprint.effect (.bob, .usd) = 1 :=
147:   by decide +kernel
148: 
149: end DefiKernel


## FILE lean/DefiKernel/Audit.lean

1: import DefiKernel.Acceptance
2: 
3: /-! Executable finite checks and axiom disclosure for this exact pilot. -/
4: namespace DefiKernel.Audit
5: open Examples
6: 
7: private def unitCase (t : Transition Unit) (expected : Option Refusal) : Bool :=
8:   decide (check policy () t initial = expected)
9: 
10: private def oracleCase (oracle : Oracle) (q : ℕ) (expected : Option Refusal) : Bool :=
11:   decide (check policy oracle (borrow (Quantity.ofNat q)) initial = expected)
12: 
13: /-- Finite regression cases; these do not measure protocol coverage or exhaustive behavior. -/
14: def runtimeChecks : List (String × Bool) := [
15:   ("transfer accepted", unitCase (transfer .alice .alice .bob (Quantity.ofNat 3)) none),
16:   ("unauthorized debit", unitCase (transfer .bob .alice .bob (Quantity.ofNat 3))
17:     (some .unauthorizedDebit)),
18:   ("insufficient funds", unitCase (transfer .alice .alice .bob (Quantity.ofNat 11))
19:     (some .insufficientFunds)),
20:   ("deposit accepted", unitCase (deposit (Quantity.ofNat 4)) none),
21:   ("withdraw accepted", unitCase (withdraw (Quantity.ofNat 2)) none),
22:   ("insufficient shares", unitCase (withdraw (Quantity.ofNat 5)) (some .insufficientFunds)),
23:   ("insufficient vault liquidity", decide (check policy () (withdraw (Quantity.ofNat 11))
24:     richShares = some .insufficientFunds)),
25:   ("borrow accepted", oracleCase fresh 3 none),
26:   ("stale oracle", oracleCase stale 3 (some .guard)),
27:   ("zero price", oracleCase zeroPrice 3 (some .guard)),
28:   ("isolated zero price", decide (check policy zeroPrice (borrow (Quantity.ofNat 0))
29:     zeroDebt = some .guard)),
30:   ("zero borrow positive price", decide (check policy fresh (borrow (Quantity.ofNat 0))
31:     zeroDebt = none)),
32:   ("policy overgrant vault drain accepted", unitCase policyVaultDrain none),
33:   ("policy overgrant unbacked issue accepted", unitCase policyUnbackedIssue none),
34:   ("policy overgrant debt burn accepted", unitCase policyDebtBurn none),
35:   ("policy overgrant vault drain post-state", decide (observe
36:     (execute policy () policyVaultDrain initial)
37:     [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [30, 0, 4])),
38:   ("policy overgrant unbacked issue post-state", decide (observe
39:     (execute policy () policyUnbackedIssue initial)
40:     [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [10, 20, 104])),
41:   ("policy overgrant debt burn post-state", decide (observe
42:     (execute policy () policyDebtBurn initial)
43:     [(.alice, .usd), (.pool, .usd), (.alice, .debt)] = .ok [10, 100, 0])),
44:   ("future oracle", oracleCase future 3 (some .guard)),
45:   ("wrong feed", oracleCase { fresh with feed := 8 } 3 (some .guard)),
46:   ("excess credit", oracleCase fresh 9 (some .guard)),
47:   ("unbalanced effects", unitCase unbalanced (some .accounting)),
48:   ("wrong asset", unitCase wrongAsset (some .accounting)),
49:   ("wrong footprint", unitCase wrongFootprint (some .footprint)),
50:   ("unauthorized supply", unitCase unauthorizedIssue (some .unauthorizedSupply)),
51:   ("transfer post-state", decide (observe
52:     (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
53:     [(.alice, .usd), (.bob, .usd)] = .ok [7, 3])),
54:   ("deposit post-state", decide (observe (execute policy () (deposit (Quantity.ofNat 4)) initial)
55:     [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [6, 24, 6])),
56:   ("withdraw post-state", decide (observe (execute policy () (withdraw (Quantity.ofNat 2)) initial)
57:     [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [14, 16, 2])),
58:   ("borrow post-state", decide (observe (execute policy fresh (borrow (Quantity.ofNat 3)) initial)
59:     [(.alice, .usd), (.pool, .usd), (.alice, .debt), (.alice, .collateral)] = .ok [13, 97, 5, 10])),
60:   ("vault round trip", decide (observe (do
61:     let s ← execute policy () (deposit (Quantity.ofNat 4)) initial
62:     execute policy () (withdraw (Quantity.ofNat 2)) s) allCells =
63:     .ok (allCells.map initial.balance))),
64:   ("repeated borrow refused", decide (observe (do
65:     let s₁ ← execute policy fresh (borrow (Quantity.ofNat 3)) initial
66:     let s₂ ← execute policy fresh (borrow (Quantity.ofNat 3)) s₁
67:     execute policy fresh (borrow (Quantity.ofNat 3)) s₂) [(.alice, .debt)] = .error .guard)),
68:   ("refused execution", decide (observe
69:     (execute policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells =
70:     .error .unauthorizedDebit)),
71:   ("self-transfer net no-op", decide (observe
72:     (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial) allCells =
73:     .ok (allCells.map initial.balance)))]
74: 
75: #eval show IO Unit from do
76:   if runtimeChecks.isEmpty then throw (IO.userError "No runtime checks were collected")
77:   for (name, passed) in runtimeChecks do
78:     IO.println s!"{name}: {passed}"
79:     if !passed then throw (IO.userError s!"Runtime check failed: {name}")
80:   IO.println s!"Runtime checks passed: {runtimeChecks.length}/{runtimeChecks.length}"
81: 
82: end DefiKernel.Audit
83: 
84: #print axioms DefiKernel.check_eq_none_iff
85: #print axioms DefiKernel.applyEffect_accounting
86: #print axioms DefiKernel.applyEffect_locality
87: #print axioms DefiKernel.applyEffect_frame
88: #print axioms DefiKernel.execute_ok_iff
89: #print axioms DefiKernel.execute_authority
90: #print axioms DefiKernel.execute_accounting
91: #print axioms DefiKernel.execute_locality
92: #print axioms DefiKernel.Examples.transfer_accounted
93: #print axioms DefiKernel.Examples.deposit_accounted
94: #print axioms DefiKernel.Examples.withdraw_accounted
95: #print axioms DefiKernel.Examples.borrow_accounted
96: #print axioms DefiKernel.Examples.allCells_complete
97: #print axioms DefiKernel.Examples.borrow_declared_collateral_bound
98: #print axioms DefiKernel.transfer_accept
99: #print axioms DefiKernel.transfer_unauthorized
100: #print axioms DefiKernel.transfer_insufficient
101: #print axioms DefiKernel.deposit_accept
102: #print axioms DefiKernel.withdraw_accept
103: #print axioms DefiKernel.borrow_accept
104: #print axioms DefiKernel.stale_oracle_refused
105: #print axioms DefiKernel.zero_price_refused
106: #print axioms DefiKernel.future_oracle_refused
107: #print axioms DefiKernel.excess_credit_refused
108: #print axioms DefiKernel.unbalanced_refused
109: #print axioms DefiKernel.wrong_asset_refused
110: #print axioms DefiKernel.wrong_footprint_refused
111: #print axioms DefiKernel.unauthorized_issue_refused
112: #print axioms DefiKernel.wrong_feed_refused
113: #print axioms DefiKernel.insufficient_shares_refused
114: #print axioms DefiKernel.insufficient_vault_liquidity_refused
115: #print axioms DefiKernel.isolated_zero_price_refused
116: #print axioms DefiKernel.zero_borrow_positive_price_accept
117: #print axioms DefiKernel.policy_overgrant_vault_drain_accepted
118: #print axioms DefiKernel.policy_overgrant_unbacked_issue_accepted
119: #print axioms DefiKernel.policy_overgrant_debt_burn_accepted
120: #print axioms DefiKernel.transfer_post
121: #print axioms DefiKernel.deposit_post
122: #print axioms DefiKernel.withdraw_post
123: #print axioms DefiKernel.borrow_post
124: #print axioms DefiKernel.vault_round_trip
125: #print axioms DefiKernel.repeated_borrow_refused
126: #print axioms DefiKernel.unauthorized_execute_refused
127: #print axioms DefiKernel.self_transfer_noop
128: #print axioms DefiKernel.policy_overgrant_vault_drain_post
129: #print axioms DefiKernel.policy_overgrant_unbacked_issue_post
130: #print axioms DefiKernel.policy_overgrant_debt_burn_post
131: #print axioms DefiKernel.wrong_asset_scalar_cancels
132: #print axioms DefiKernel.wrong_asset_not_accounted
133: #print axioms DefiKernel.unbalanced_not_accounted
134: #print axioms DefiKernel.missing_footprint_changes_balance


## FILE review/semantic-kernel/2026-09-06/check-mutations.py

1: #!/usr/bin/env python3
2: """Exercise source-lift mutations of the bounded check API.
3: 
4: All check-based Acceptance contracts are included; execute and sequence tests are
5: excluded explicitly. No repository writes. A clean or dirty source snapshot is
6: identified by input hashes, HEAD, and captured git status, never by HEAD alone.
7: """
8: import argparse
9: import hashlib
10: import json
11: from pathlib import Path
12: import re
13: import subprocess
14: 
15: parser = argparse.ArgumentParser(description=__doc__)
16: parser.add_argument('--repo', type=Path, required=True, help='Repository containing lean/')
17: parser.add_argument('--output', type=Path, required=True, help='Directory for generated sources/logs')
18: args = parser.parse_args()
19: repo = args.repo.resolve()
20: root = repo / 'lean'
21: out = args.output.resolve()
22: out.mkdir(parents=True, exist_ok=True)
23: 
24: def git(*args):
25:     return subprocess.check_output(['git', *args], cwd=repo, text=True).rstrip('\n')
26: 
27: def digest(data):
28:     return hashlib.sha256(data).hexdigest()
29: 
30: input_paths = ['lean/DefiKernel/Core.lean', 'lean/DefiKernel/Examples.lean',
31:                'lean/DefiKernel/Acceptance.lean']
32: input_bytes = {name: (repo / name).read_bytes() for name in input_paths}
33: core, examples, acceptance = [input_bytes[name].decode() for name in input_paths]
34: status = git('status', '--porcelain=v1', '--untracked-files=all')
35: source_status = git('status', '--porcelain=v1', '--untracked-files=all', '--', *input_paths)
36: metadata = {
37:     'schema': 'defikernel-source-lift-mutations/v2',
38:     'repo': str(repo),
39:     'git_head_at_capture': git('rev-parse', 'HEAD'),
40:     'working_tree_status_at_capture': status,
41:     'working_tree_dirty_at_capture': bool(status),
42:     'input_source_status_at_capture': source_status,
43:     'input_sources_dirty_at_capture': bool(source_status),
44:     'inputs': {name: digest(data) for name, data in input_bytes.items()},
45:     'recipe_sha256': digest(Path(__file__).read_bytes()),
46:     'toolchain': (root / 'lean-toolchain').read_text().strip(),
47:     'lakefile_sha256': digest((root / 'lakefile.toml').read_bytes()),
48:     'lake_manifest_sha256': digest((root / 'lake-manifest.json').read_bytes()),
49:     'scope': 'All check-based Acceptance theorems; no execute or sequence source mutation',
50: }
51: markers = [('/-- The explicit conjunction checked by `check`', core),
52:            ('/-- Constructor accounting holds', examples),
53:            ('theorem transfer_post :', acceptance)]
54: for marker, source in markers:
55:     assert source.count(marker) == 1, marker
56: parts = [core.split(markers[0][0])[0] + '\nend DefiKernel\n',
57:          examples.split(markers[1][0])[0] + '\nend DefiKernel.Examples\n',
58:          acceptance.split(markers[2][0])[0] + '\nend DefiKernel\n']
59: pattern = r'^theorem (\w+)\s*:(.*?)\s*:=\s*by decide \+kernel'
60: contracts = re.findall(pattern, parts[2], re.S | re.M)
61: all_contracts = re.findall(pattern, acceptance, re.S | re.M)
62: all_check_contracts = [(name, prop) for name, prop in all_contracts
63:                        if prop.strip().startswith('check ')]
64: assert contracts == all_check_contracts, 'Some check contracts fall outside the captured prefix'
65: assert len(contracts) == len(re.findall(r'^theorem ', parts[2], re.M))
66: assert len(contracts) >= 22, 'Incomplete expected check contract suite'
67: metadata['contract_names'] = [name for name, _ in contracts]
68: metadata['contract_count'] = len(contracts)
69: imports = sorted(set(line for s in parts for line in s.splitlines()
70:                      if line.startswith('import ') and 'DefiKernel' not in line))
71: body = '\n'.join('\n'.join(line for line in s.splitlines()
72:                            if not line.startswith('import ')) for s in parts)
73: assert body.count('def check ') == 1
74: runtime = '\nnamespace DefiKernel\nopen Examples\n'
75: for name, proposition in contracts:
76:     runtime += '#eval IO.println ("MUTATION_RUNTIME ' + name + ' " ++ toString (decide ('
77:     runtime += proposition + ')))\n'
78: runtime += 'end DefiKernel\n'
79: lift = '\n'.join(imports) + '\n' + body + runtime
80: mutations = {
81:     'control': None,
82:     'guard': ('if t.guard s env = false then', 'if False then'),
83:     'debit': ('else if ¬ DebitAuthorized p t then', 'else if False then'),
84:     'supply': ('else if ¬ SupplyAuthorized p t then', 'else if False then'),
85:     'nonnegative': ('else if ¬ NonnegativeUpdate s t then', 'else if False then'),
86:     'accounting': ('else if ¬ Accounted t then', 'else if False then'),
87:     'footprint': ('else if ¬ Local t then', 'else if False then'),
88:     'positive_price_only': ('oracle.feed = 7 ∧ 0 < oracle.price ∧', 'oracle.feed = 7 ∧'),
89: }
90: metadata['mutations'] = mutations
91: results = []
92: for name, mutation in mutations.items():
93:     content = lift
94:     if mutation:
95:         old, new = mutation
96:         assert content.count(old) == 1
97:         content = content.replace(old, new)
98:     path = out / (name + '.lean')
99:     path.write_text(content)
100:     command = ['lake', 'env', 'lean', str(path)]
101:     run = subprocess.run(command, cwd=root, text=True, capture_output=True)
102:     output = run.stdout + run.stderr
103:     (out / (name + '.log')).write_text(output)
104:     observed = re.findall(r'^MUTATION_RUNTIME (\w+) (true|false)$', output, re.M)
105:     assert [key for key, _ in observed] == metadata['contract_names'], output
106:     false_names = [key for key, value in observed if value == 'false']
107:     row = {'name': name, 'source_sha256': digest(content.encode()), 'command': command,
108:            'exit': run.returncode, 'expected_exit': 0 if name == 'control' else 1,
109:            'runtime_count': len(observed), 'runtime_false': false_names,
110:            'errors': re.findall(r'^.*error:.*$', output, re.M)}
111:     results.append(row)
112:     print(json.dumps(row), flush=True)
113:     assert run.returncode == row['expected_exit'], row
114:     if name == 'control':
115:         assert not false_names, row
116:     else:
117:         assert false_names, 'A compiler error alone is not a mutant discrimination'
118:     if name == 'positive_price_only':
119:         assert false_names == ['isolated_zero_price_refused'], row
120: for name, data in input_bytes.items():
121:     assert (repo / name).read_bytes() == data, 'Input changed during mutation run: ' + name
122: metadata['input_hashes_unchanged_after_run'] = True
123: metadata['results'] = results
124: (out / 'results.json').write_text(json.dumps(metadata, indent=2) + '\n')
125: print(f'Control: {len(contracts)}/{len(contracts)} true; source mutants discriminated: 7/7')


## EVIDENCE r2-mutation-results.json
{
  "schema": "defikernel-source-lift-mutations/v2",
  "repo": "/home/charl/defiformal",
  "git_head_at_capture": "9e9a2bfe6a3c85785fd3fb845bba6c7765481e22",
  "working_tree_status_at_capture": " M docs/research/semantic-kernel-progress.md\n M docs/superpowers/plans/2026-09-06-semantic-kernel-pivot.md\n?? review/semantic-kernel/2026-09-06/IMPLEMENTATION.md\n?? review/semantic-kernel/2026-09-06/full-build.log\n?? review/semantic-kernel/2026-09-06/implementation-source-manifest.json\n?? review/semantic-kernel/2026-09-06/mutation-results.json\n?? review/semantic-kernel/2026-09-06/original-mutation-recipe.py\n?? review/semantic-kernel/2026-09-06/pilot-audit.log\n?? review/semantic-kernel/2026-09-06/r1-bundle.md\n?? review/semantic-kernel/2026-09-06/r1-fable-review.md\n?? review/semantic-kernel/2026-09-06/r1-fable.invocation.json\n?? review/semantic-kernel/2026-09-06/r1-fable.json\n?? review/semantic-kernel/2026-09-06/r1-fable.stderr\n?? review/semantic-kernel/2026-09-06/r1-grok-review.md\n?? review/semantic-kernel/2026-09-06/r1-grok.invocation.json\n?? review/semantic-kernel/2026-09-06/r1-grok.json\n?? review/semantic-kernel/2026-09-06/r1-grok.stderr\n?? review/semantic-kernel/2026-09-06/r1-manifest.json",
  "working_tree_dirty_at_capture": true,
  "input_source_status_at_capture": "",
  "input_sources_dirty_at_capture": false,
  "inputs": {
    "lean/DefiKernel/Core.lean": "767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d",
    "lean/DefiKernel/Examples.lean": "3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28",
    "lean/DefiKernel/Acceptance.lean": "9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11"
  },
  "recipe_sha256": "02f063a7de35272ac471131c8b2d1abcd6f6ad175587d4f91d37d00714b30e9a",
  "toolchain": "leanprover/lean4:v4.33.0-rc2",
  "lakefile_sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
  "lake_manifest_sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
  "scope": "All check-based Acceptance theorems; no execute or sequence source mutation",
  "contract_names": [
    "transfer_accept",
    "transfer_unauthorized",
    "transfer_insufficient",
    "deposit_accept",
    "withdraw_accept",
    "borrow_accept",
    "stale_oracle_refused",
    "zero_price_refused",
    "future_oracle_refused",
    "excess_credit_refused",
    "unbalanced_refused",
    "wrong_asset_refused",
    "wrong_footprint_refused",
    "unauthorized_issue_refused",
    "wrong_feed_refused",
    "insufficient_shares_refused",
    "insufficient_vault_liquidity_refused",
    "isolated_zero_price_refused",
    "zero_borrow_positive_price_accept",
    "policy_overgrant_vault_drain_accepted",
    "policy_overgrant_unbacked_issue_accepted",
    "policy_overgrant_debt_burn_accepted"
  ],
  "contract_count": 22,
  "mutations": {
    "control": null,
    "guard": [
      "if t.guard s env = false then",
      "if False then"
    ],
    "debit": [
      "else if \u00ac DebitAuthorized p t then",
      "else if False then"
    ],
    "supply": [
      "else if \u00ac SupplyAuthorized p t then",
      "else if False then"
    ],
    "nonnegative": [
      "else if \u00ac NonnegativeUpdate s t then",
      "else if False then"
    ],
    "accounting": [
      "else if \u00ac Accounted t then",
      "else if False then"
    ],
    "footprint": [
      "else if \u00ac Local t then",
      "else if False then"
    ],
    "positive_price_only": [
      "oracle.feed = 7 \u2227 0 < oracle.price \u2227",
      "oracle.feed = 7 \u2227"
    ]
  },
  "input_hashes_unchanged_after_run": true,
  "results": [
    {
      "name": "control",
      "source_sha256": "404942f19d8c009915b0add8650970ae486e6249f616e2085b9f5a278b0c8bbd",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/control.lean"
      ],
      "exit": 0,
      "expected_exit": 0,
      "runtime_count": 22,
      "runtime_false": [],
      "errors": []
    },
    {
      "name": "guard",
      "source_sha256": "f9af965d3eb426bef7a8f51066ae61088f874bbac9ec5d78ba43b2facf3dc357",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/guard.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "stale_oracle_refused",
        "zero_price_refused",
        "future_oracle_refused",
        "excess_credit_refused",
        "wrong_feed_refused",
        "isolated_zero_price_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/guard.lean:276:79: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/guard.lean:279:83: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/guard.lean:282:80: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/guard.lean:285:79: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/guard.lean:301:24: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/guard.lean:314:84: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "debit",
      "source_sha256": "1f3d7b4531f3f8b36425ec9e967838dc97a1f869d45dc0acffe8b41aeef20abb",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/debit.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "transfer_unauthorized"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/debit.lean:260:36: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "supply",
      "source_sha256": "fffb34bf561dc2d59d83c44f9a34962047b9bf5a5ff1ed6b25560181767e6ea8",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/supply.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "unauthorized_issue_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/supply.lean:297:79: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "nonnegative",
      "source_sha256": "4eec0554be508a5652c6318b6b412e02295ba7a4804dc41a521b817265ad9d02",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/nonnegative.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "transfer_insufficient",
        "insufficient_shares_refused",
        "insufficient_vault_liquidity_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/nonnegative.lean:264:36: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/nonnegative.lean:305:36: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/nonnegative.lean:310:36: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "accounting",
      "source_sha256": "65b08b36077c25c53d90c645a163f688770126609913957cb0becfa0911ff97e",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/accounting.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "unbalanced_refused",
        "wrong_asset_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/accounting.lean:288:64: error: Tactic `decide` failed for proposition",
        "/tmp/defiformal-parent-r2-mutations/accounting.lean:291:64: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "footprint",
      "source_sha256": "3ffc726509299ba1d5fd36edb5c963168e10c845ab695966b19dfeb576583b08",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/footprint.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "wrong_footprint_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/footprint.lean:294:67: error: Tactic `decide` failed for proposition"
      ]
    },
    {
      "name": "positive_price_only",
      "source_sha256": "95f157e44f09659238713c8b21da37c0c97c473c4039d14efdcfcc23581583a8",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-parent-r2-mutations/positive_price_only.lean"
      ],
      "exit": 1,
      "expected_exit": 1,
      "runtime_count": 22,
      "runtime_false": [
        "isolated_zero_price_refused"
      ],
      "errors": [
        "/tmp/defiformal-parent-r2-mutations/positive_price_only.lean:314:84: error: Tactic `decide` failed for proposition"
      ]
    }
  ]
}


## Exact revision diff
diff --git a/lean/DefiKernel/Acceptance.lean b/lean/DefiKernel/Acceptance.lean
index df1ae57..978ef09 100644
--- a/lean/DefiKernel/Acceptance.lean
+++ b/lean/DefiKernel/Acceptance.lean
@@ -56,11 +56,28 @@ theorem insufficient_shares_refused :
     check policy () (withdraw (Quantity.ofNat 5)) initial =
       some .insufficientFunds := by decide +kernel
 
-/-- Twenty USD of vault liquidity cannot redeem all twenty fixture shares. -/
+/-- Twenty USD cannot redeem the requested eleven shares, despite twenty shares being held. -/
 theorem insufficient_vault_liquidity_refused :
     check policy () (withdraw (Quantity.ofNat 11)) richShares =
       some .insufficientFunds := by decide +kernel
 
+/-- Zero debt and zero borrowing make the collateral inequality true even at price zero. -/
+theorem isolated_zero_price_refused :
+    check policy zeroPrice (borrow (Quantity.ofNat 0)) zeroDebt = some .guard := by decide +kernel
+
+theorem zero_borrow_positive_price_accept :
+    check policy fresh (borrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel
+
+/-- Accepted counterexamples expose grants that are not bound to transition shape. -/
+theorem policy_overgrant_vault_drain_accepted :
+    check policy () policyVaultDrain initial = none := by decide +kernel
+
+theorem policy_overgrant_unbacked_issue_accepted :
+    check policy () policyUnbackedIssue initial = none := by decide +kernel
+
+theorem policy_overgrant_debt_burn_accepted :
+    check policy () policyDebtBurn initial = none := by decide +kernel
+
 theorem transfer_post :
     observe (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
       [(.alice, .usd), (.bob, .usd)] = .ok [7, 3] := by decide +kernel
@@ -102,6 +119,21 @@ theorem self_transfer_noop :
     observe (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial)
       allCells = .ok (allCells.map initial.balance) := by decide +kernel
 
+/-- The vault loses its twenty USD while Alice's share balance is unchanged. -/
+theorem policy_overgrant_vault_drain_post :
+    observe (execute policy () policyVaultDrain initial)
+      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [30, 0, 4] := by decide +kernel
+
+/-- One hundred shares appear without any USD deposit. -/
+theorem policy_overgrant_unbacked_issue_post :
+    observe (execute policy () policyUnbackedIssue initial)
+      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [10, 20, 104] := by decide +kernel
+
+/-- Debt disappears without any USD repayment to the pool. -/
+theorem policy_overgrant_debt_burn_post :
+    observe (execute policy () policyDebtBurn initial)
+      [(.alice, .usd), (.pool, .usd), (.alice, .debt)] = .ok [10, 100, 0] := by decide +kernel
+
 /-- This defective effect defeats scalar accounting while violating asset accounting. -/
 theorem wrong_asset_scalar_cancels :
     (∑ a, ∑ owner, wrongAsset.effect (owner, a)) = 0 := by decide +kernel
diff --git a/lean/DefiKernel/Audit.lean b/lean/DefiKernel/Audit.lean
index f16bebf..bff3318 100644
--- a/lean/DefiKernel/Audit.lean
+++ b/lean/DefiKernel/Audit.lean
@@ -25,6 +25,22 @@ def runtimeChecks : List (String × Bool) := [
   ("borrow accepted", oracleCase fresh 3 none),
   ("stale oracle", oracleCase stale 3 (some .guard)),
   ("zero price", oracleCase zeroPrice 3 (some .guard)),
+  ("isolated zero price", decide (check policy zeroPrice (borrow (Quantity.ofNat 0))
+    zeroDebt = some .guard)),
+  ("zero borrow positive price", decide (check policy fresh (borrow (Quantity.ofNat 0))
+    zeroDebt = none)),
+  ("policy overgrant vault drain accepted", unitCase policyVaultDrain none),
+  ("policy overgrant unbacked issue accepted", unitCase policyUnbackedIssue none),
+  ("policy overgrant debt burn accepted", unitCase policyDebtBurn none),
+  ("policy overgrant vault drain post-state", decide (observe
+    (execute policy () policyVaultDrain initial)
+    [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [30, 0, 4])),
+  ("policy overgrant unbacked issue post-state", decide (observe
+    (execute policy () policyUnbackedIssue initial)
+    [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [10, 20, 104])),
+  ("policy overgrant debt burn post-state", decide (observe
+    (execute policy () policyDebtBurn initial)
+    [(.alice, .usd), (.pool, .usd), (.alice, .debt)] = .ok [10, 100, 0])),
   ("future oracle", oracleCase future 3 (some .guard)),
   ("wrong feed", oracleCase { fresh with feed := 8 } 3 (some .guard)),
   ("excess credit", oracleCase fresh 9 (some .guard)),
@@ -96,6 +112,11 @@ end DefiKernel.Audit
 #print axioms DefiKernel.wrong_feed_refused
 #print axioms DefiKernel.insufficient_shares_refused
 #print axioms DefiKernel.insufficient_vault_liquidity_refused
+#print axioms DefiKernel.isolated_zero_price_refused
+#print axioms DefiKernel.zero_borrow_positive_price_accept
+#print axioms DefiKernel.policy_overgrant_vault_drain_accepted
+#print axioms DefiKernel.policy_overgrant_unbacked_issue_accepted
+#print axioms DefiKernel.policy_overgrant_debt_burn_accepted
 #print axioms DefiKernel.transfer_post
 #print axioms DefiKernel.deposit_post
 #print axioms DefiKernel.withdraw_post
@@ -104,6 +125,9 @@ end DefiKernel.Audit
 #print axioms DefiKernel.repeated_borrow_refused
 #print axioms DefiKernel.unauthorized_execute_refused
 #print axioms DefiKernel.self_transfer_noop
+#print axioms DefiKernel.policy_overgrant_vault_drain_post
+#print axioms DefiKernel.policy_overgrant_unbacked_issue_post
+#print axioms DefiKernel.policy_overgrant_debt_burn_post
 #print axioms DefiKernel.wrong_asset_scalar_cancels
 #print axioms DefiKernel.wrong_asset_not_accounted
 #print axioms DefiKernel.unbalanced_not_accounted
diff --git a/lean/DefiKernel/Examples.lean b/lean/DefiKernel/Examples.lean
index c249898..6e9aa73 100644
--- a/lean/DefiKernel/Examples.lean
+++ b/lean/DefiKernel/Examples.lean
@@ -19,7 +19,9 @@ def move (asset : Asset) (src dst : Account) (amount : ℚ) (c : Cell) : ℚ :=
   pulse (dst, asset) amount c - pulse (src, asset) amount c
 
 /-- Alice has explicit vault/pool USD debit and share/debt supply capabilities in this fixture.
-This policy is an input assumption; the kernel does not authenticate or derive the grant. -/
+This policy is an input assumption; the kernel does not authenticate or derive the grant.
+Grants are not bound to transition shape: accepted counterexamples below drain the vault,
+issue unbacked shares, and burn debt without repayment. This is not a protocol access policy. -/
 def policy : Policy where
   debit actor c := decide (actor = c.1 ∨
     (actor = .alice ∧ (c = (.vault, .usd) ∨ c = (.pool, .usd))))
@@ -111,6 +113,41 @@ def unauthorizedIssue : Transition Unit where
   writes := {(.bob, .share)}
   guard := fun _ _ ↦ true
 
+/-- Counterexample fixture isolates vault liquidity from share ownership. -/
+def richShares : State where
+  balance c := if c = (.alice, .share) then 20 else initial.balance c
+  nonneg c := by
+    split
+    · norm_num
+    · exact initial.nonneg c
+
+/-- Accepted policy counterexample: no share burn accompanies this vault debit. -/
+def policyVaultDrain : Transition Unit := transfer .alice .vault .alice (Quantity.ofNat 20)
+
+/-- Accepted policy counterexample: supply permission alone does not require a deposit. -/
+def policyUnbackedIssue : Transition Unit where
+  actor := .alice
+  effect := pulse (.alice, .share) 100
+  supplyChange := fun a ↦ if a = .share then 100 else 0
+  writes := {(.alice, .share)}
+  guard := fun _ _ ↦ true
+
+/-- Accepted policy counterexample: the owner may burn debt without repayment. -/
+def policyDebtBurn : Transition Unit where
+  actor := .alice
+  effect := pulse (.alice, .debt) (-2)
+  supplyChange := fun a ↦ if a = .debt then -2 else 0
+  writes := {(.alice, .debt)}
+  guard := fun _ _ ↦ true
+
+/-- Zero debt isolates the positive-price conjunct when the requested borrow is also zero. -/
+def zeroDebt : State where
+  balance c := if c = (.alice, .debt) then 0 else initial.balance c
+  nonneg c := by
+    split
+    · norm_num
+    · exact initial.nonneg c
+
 /-- Constructor accounting holds for every amount, independently of execution guards. -/
 theorem transfer_accounted (actor src dst : Account) (q : Quantity .usd) :
     Accounted (transfer actor src dst q) := by
@@ -143,14 +180,6 @@ theorem allCells_complete (c : Cell) : c ∈ allCells := by
   rcases c with ⟨owner, asset⟩
   cases owner <;> cases asset <;> decide
 
-/-- Counterexample fixture isolates vault liquidity from share ownership. -/
-def richShares : State where
-  balance c := if c = (.alice, .share) then 20 else initial.balance c
-  nonneg c := by
-    split
-    · norm_num
-    · exact initial.nonneg c
-
 /-- Accepted borrowing preserves the example's declared-price collateral bound in its post-state.
 This is conditional on the guard and on the external meaning of price and locked collateral. -/
 theorem borrow_declared_collateral_bound (p : Policy) (oracle : Oracle) (q : Quantity .usd)
diff --git a/lean/README.md b/lean/README.md
index adcd7c5..e69cd54 100644
--- a/lean/README.md
+++ b/lean/README.md
@@ -5,7 +5,7 @@ Run from this directory:
 ```sh
 lake build                  # historical algebra and new kernel pilot
 lake build DefiKernel       # pilot, including its acceptance declarations
-lake env lean DefiKernel/Acceptance.lean
+lake env lean DefiKernel/Audit.lean  # fresh runtime output and axiom disclosure
 ```
 
 Use the versions pinned in `lean-toolchain` and `lake-manifest.json`.
@@ -29,7 +29,14 @@ observed verification and independent review status.
 - Concrete accepted/refused examples and deliberately broken transitions.
 
 The supplied policy is a trust assumption. It does not authenticate callers or
-implement capability issuance/revocation. Oracle feed and timestamp fields are
+implement capability issuance/revocation. In particular, the fixture grants
+permissions without binding them to transition shape: it accepts a vault drain
+without share burn, share issuance without a deposit, and debt erasure without
+repayment. Accepted counterexamples make this boundary explicit. The generic
+accounting and policy-relative authority theorems still hold for those effects;
+the fixture is not a safe policy for a financial application.
+
+Oracle feed and timestamp fields are
 declared inputs; checking them does not establish provenance or market truth.
 Debt is represented as a distinct nonnegative obligation token in the reference
 example. This is not a general party/claim lifecycle model.
@@ -42,3 +49,7 @@ economic solvency, or asynchronous liveness. These remain migration obligations.
 
 Lean proof terms are the current evidence format. Concrete acceptance theorems
 check their stated examples; they do not establish corpus-wide adequacy.
+`Audit.lean` maintains an explicit axiom-disclosure list. When adding or removing
+a theorem, update that list and compare it against all named pilot theorem
+declarations before reporting complete disclosure. The recorded count applies
+only to the exact audited source snapshot.
diff --git a/review/semantic-kernel/2026-09-06/check-mutations.py b/review/semantic-kernel/2026-09-06/check-mutations.py
new file mode 100644
index 0000000..450dfd4
--- /dev/null
+++ b/review/semantic-kernel/2026-09-06/check-mutations.py
@@ -0,0 +1,125 @@
+#!/usr/bin/env python3
+"""Exercise source-lift mutations of the bounded check API.
+
+All check-based Acceptance contracts are included; execute and sequence tests are
+excluded explicitly. No repository writes. A clean or dirty source snapshot is
+identified by input hashes, HEAD, and captured git status, never by HEAD alone.
+"""
+import argparse
+import hashlib
+import json
+from pathlib import Path
+import re
+import subprocess
+
+parser = argparse.ArgumentParser(description=__doc__)
+parser.add_argument('--repo', type=Path, required=True, help='Repository containing lean/')
+parser.add_argument('--output', type=Path, required=True, help='Directory for generated sources/logs')
+args = parser.parse_args()
+repo = args.repo.resolve()
+root = repo / 'lean'
+out = args.output.resolve()
+out.mkdir(parents=True, exist_ok=True)
+
+def git(*args):
+    return subprocess.check_output(['git', *args], cwd=repo, text=True).rstrip('\n')
+
+def digest(data):
+    return hashlib.sha256(data).hexdigest()
+
+input_paths = ['lean/DefiKernel/Core.lean', 'lean/DefiKernel/Examples.lean',
+               'lean/DefiKernel/Acceptance.lean']
+input_bytes = {name: (repo / name).read_bytes() for name in input_paths}
+core, examples, acceptance = [input_bytes[name].decode() for name in input_paths]
+status = git('status', '--porcelain=v1', '--untracked-files=all')
+source_status = git('status', '--porcelain=v1', '--untracked-files=all', '--', *input_paths)
+metadata = {
+    'schema': 'defikernel-source-lift-mutations/v2',
+    'repo': str(repo),
+    'git_head_at_capture': git('rev-parse', 'HEAD'),
+    'working_tree_status_at_capture': status,
+    'working_tree_dirty_at_capture': bool(status),
+    'input_source_status_at_capture': source_status,
+    'input_sources_dirty_at_capture': bool(source_status),
+    'inputs': {name: digest(data) for name, data in input_bytes.items()},
+    'recipe_sha256': digest(Path(__file__).read_bytes()),
+    'toolchain': (root / 'lean-toolchain').read_text().strip(),
+    'lakefile_sha256': digest((root / 'lakefile.toml').read_bytes()),
+    'lake_manifest_sha256': digest((root / 'lake-manifest.json').read_bytes()),
+    'scope': 'All check-based Acceptance theorems; no execute or sequence source mutation',
+}
+markers = [('/-- The explicit conjunction checked by `check`', core),
+           ('/-- Constructor accounting holds', examples),
+           ('theorem transfer_post :', acceptance)]
+for marker, source in markers:
+    assert source.count(marker) == 1, marker
+parts = [core.split(markers[0][0])[0] + '\nend DefiKernel\n',
+         examples.split(markers[1][0])[0] + '\nend DefiKernel.Examples\n',
+         acceptance.split(markers[2][0])[0] + '\nend DefiKernel\n']
+pattern = r'^theorem (\w+)\s*:(.*?)\s*:=\s*by decide \+kernel'
+contracts = re.findall(pattern, parts[2], re.S | re.M)
+all_contracts = re.findall(pattern, acceptance, re.S | re.M)
+all_check_contracts = [(name, prop) for name, prop in all_contracts
+                       if prop.strip().startswith('check ')]
+assert contracts == all_check_contracts, 'Some check contracts fall outside the captured prefix'
+assert len(contracts) == len(re.findall(r'^theorem ', parts[2], re.M))
+assert len(contracts) >= 22, 'Incomplete expected check contract suite'
+metadata['contract_names'] = [name for name, _ in contracts]
+metadata['contract_count'] = len(contracts)
+imports = sorted(set(line for s in parts for line in s.splitlines()
+                     if line.startswith('import ') and 'DefiKernel' not in line))
+body = '\n'.join('\n'.join(line for line in s.splitlines()
+                           if not line.startswith('import ')) for s in parts)
+assert body.count('def check ') == 1
+runtime = '\nnamespace DefiKernel\nopen Examples\n'
+for name, proposition in contracts:
+    runtime += '#eval IO.println ("MUTATION_RUNTIME ' + name + ' " ++ toString (decide ('
+    runtime += proposition + ')))\n'
+runtime += 'end DefiKernel\n'
+lift = '\n'.join(imports) + '\n' + body + runtime
+mutations = {
+    'control': None,
+    'guard': ('if t.guard s env = false then', 'if False then'),
+    'debit': ('else if ¬ DebitAuthorized p t then', 'else if False then'),
+    'supply': ('else if ¬ SupplyAuthorized p t then', 'else if False then'),
+    'nonnegative': ('else if ¬ NonnegativeUpdate s t then', 'else if False then'),
+    'accounting': ('else if ¬ Accounted t then', 'else if False then'),
+    'footprint': ('else if ¬ Local t then', 'else if False then'),
+    'positive_price_only': ('oracle.feed = 7 ∧ 0 < oracle.price ∧', 'oracle.feed = 7 ∧'),
+}
+metadata['mutations'] = mutations
+results = []
+for name, mutation in mutations.items():
+    content = lift
+    if mutation:
+        old, new = mutation
+        assert content.count(old) == 1
+        content = content.replace(old, new)
+    path = out / (name + '.lean')
+    path.write_text(content)
+    command = ['lake', 'env', 'lean', str(path)]
+    run = subprocess.run(command, cwd=root, text=True, capture_output=True)
+    output = run.stdout + run.stderr
+    (out / (name + '.log')).write_text(output)
+    observed = re.findall(r'^MUTATION_RUNTIME (\w+) (true|false)$', output, re.M)
+    assert [key for key, _ in observed] == metadata['contract_names'], output
+    false_names = [key for key, value in observed if value == 'false']
+    row = {'name': name, 'source_sha256': digest(content.encode()), 'command': command,
+           'exit': run.returncode, 'expected_exit': 0 if name == 'control' else 1,
+           'runtime_count': len(observed), 'runtime_false': false_names,
+           'errors': re.findall(r'^.*error:.*$', output, re.M)}
+    results.append(row)
+    print(json.dumps(row), flush=True)
+    assert run.returncode == row['expected_exit'], row
+    if name == 'control':
+        assert not false_names, row
+    else:
+        assert false_names, 'A compiler error alone is not a mutant discrimination'
+    if name == 'positive_price_only':
+        assert false_names == ['isolated_zero_price_refused'], row
+for name, data in input_bytes.items():
+    assert (repo / name).read_bytes() == data, 'Input changed during mutation run: ' + name
+metadata['input_hashes_unchanged_after_run'] = True
+metadata['results'] = results
+(out / 'results.json').write_text(json.dumps(metadata, indent=2) + '\n')
+print(f'Control: {len(contracts)}/{len(contracts)} true; source mutants discriminated: 7/7')


## Candidate/source binding manifest
{
  "candidate_commit": "9e9a2bfe6a3c85785fd3fb845bba6c7765481e22",
  "previous_candidate": "150c2accb31700d2c7267eb8152b02d36c815605",
  "reviewed_files": {
    "AGENTS.md": "8648a6f91d00c75ccf8ad2198428f7cd7e55323204cec9af6f53e6d4972edb7b",
    "docs/superpowers/specs/2026-09-06-semantic-kernel-design.md": "9549bec37f76a16b42c8d2ad2c4305fd5f9568ffb1413cd79e218a978f99613a",
    "lean/README.md": "e7d3d131ec8a411d3dfcec0b608a23adabacc3f84b123f36b9b9b44441a0f4c8",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/DefiKernel.lean": "3d183700381dc42b3ccea34037d56f4a4dffff5b086ad558d1d97a3b128c83fa",
    "lean/DefiKernel/Core.lean": "767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d",
    "lean/DefiKernel/Examples.lean": "3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28",
    "lean/DefiKernel/Acceptance.lean": "9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11",
    "lean/DefiKernel/Audit.lean": "7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400",
    "review/semantic-kernel/2026-09-06/check-mutations.py": "02f063a7de35272ac471131c8b2d1abcd6f6ad175587d4f91d37d00714b30e9a"
  },
  "verification": {
    "full_build_exit": 0,
    "full_build_jobs": 988,
    "fresh_audit_exit": 0,
    "runtime_checks": "33/33",
    "named_theorems": 51,
    "disclosures_cover_every_named_pilot_theorem": true,
    "axioms": [
      "Classical.choice",
      "Quot.sound",
      "propext"
    ],
    "mutation_control": "22/22",
    "mutants_discriminated": "7/7",
    "mutation_input_sources_match_candidate": true
  },
  "evidence_files": {
    "r2-pilot-audit.log": "61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63",
    "r2-full-build.log": "8a3da9ba295abc8ea7133c01f46eeb39552ab81ba494f81684d46cbb89884b6a",
    "r2-mutation-results.json": "6cdda9c9294f89bb9670c3a33cec4b636b9d696289ad2d9444f94f1ca9598c24",
    "R2-IMPLEMENTATION.md": "efd844b9f606d0e014fb6027226aebf55022244c6669cb79c5170cf854297e9b"
  }
}