# GR-ORD — Order-theoretic algebra of DeFi composition

Lens: lattices, closure operators, Galois connections, Formal Concept Analysis
(Horn fragment only; disjunctive conclusions sit outside).

---

## 1. Signature, carrier, operations, laws

### Signature

- **Sort** `E`: the 58 mechanism symbols of `viz/src/data.ts` with
  `status ≠ "limit"` (the row `CSM` is excluded; it is declared a non-element).
- **Constants**: one constant symbol per element
  `Sh, Ix, Rb, Cp, Wg, St, Cl, Pm, Ob, Rf, Ba, In, Ag, Fl, Pl, Im, Cd, Uc, Ft,
  Ct, Li, Ad, Sl, Bs, Pf, Op, Tr, Cv, Py, Sv, Dp, Ex, Tp, Oa, At, Sr, Ep, Wq,
  Em, Fd, Tg, Up, Gp, Au, Gs, Xm, Xf, Rl, Of, Rd, Ps, As, Aw, Sb, Sd, Fz, Rs, Vl`.
- **No ports, no asset indices, no strategy sort.** (Choice stated in §3 Q1.)

### Carrier

\[
\mathcal{C} \;=\; \mathcal{P}(E)
\]

Finite subsets of the 58-symbol vocabulary. A protocol (or blind case) is an
element of \(\mathcal{C}\). Observation map is the one fixed in BRIEF §2
(reachable net-payoff outcomes); this algebra classifies only membership
structure against the law/hazard table and does not re-derive ⟦·⟧.

**One-sorted choice (Q1).** The carrier stays one-sorted: sets of element
symbols. Strategies (Yearn / Steakhouse vault policies) are **out of scope** —
they are policies over terms, not terms (VERDICT.md). A second sort for
strategies is not added here; naming them as elements would be a category error.
Asset-indexed instances `(e,a)` for reflexivity are also not added (Q5).

### Operations

| Op | Definition | On closed sets | On ADMISSIBLE sets |
|---|---|---|---|
| \(\cup\) (join candidate) | set union | **join**: \(A \vee B = A \cup B\) | not total; can arm hazards or open L19b |
| \(\cap\) | set intersection | **not** meet | not meet |
| \(\wedge\) (meet) | \(\mathrm{cl}^\downarrow(A \cap B)\): largest closed subset of \(A \cap B\) | well-defined complete-lattice meet | N/A (ADMISSIBLE is not a lattice) |
| \(\mathrm{cl}\) | law-closure under the 25 fireable laws + **L19b** (minimal closed supersets; branching on disjuncts) | idempotent extensive monotone (Moore family) | — |
| \(\bot\) | \(\emptyset\) | closed, ADMISSIBLE | yes |
| \(\top_{\mathrm{cl}}\) | \(E\) (full vocabulary) | closed | not hazard-free |

### Laws of the operations (proved / fixed from FINDINGS.md §14)

**L-C1 (union-closure of closed sets).** If \(A,B\) are closed under the fireable
laws (monotone satisfaction + firing distributes over union), then \(A \cup B\)
is closed. *Proof sketch:* a law fires on \(A \cup B\) iff it fires on \(A\) or
on \(B\); each non-external term satisfied in \(A\) or \(B\) remains satisfied in
the union. Hence join of closed sets is union.

**L-C2 (complete lattice of closed sets).** The family of closed sets contains
\(\emptyset\) and \(E\), is closed under arbitrary unions, and therefore forms a
complete lattice under \(\subseteq\) with
\[
A \vee B = A \cup B, \qquad
A \wedge B = \bigcup\{\, C \text{ closed} : C \subseteq A \cap B \,\}.
\]
Meet is **not** intersection. Witness (FINDINGS.md, reproduced):
\[
\{Xm,Xf,Of,Bs\} \;\cap\; \{Xm,Xf,Of,Sl\} \;=\; \{Xm,Xf,Of\},
\]
which fails L19's term `(Bs|Sl)` (each operand uses a different disjunct).

**L-C3 (closure operator).** The map sending \(X\) to the intersection of all
closed supersets of \(X\) (equivalently, the join of all minimal closed
completions) is a finitary closure operator in the Moore / Galois sense:
extensive, monotone, idempotent. The 25 fireable laws (plus L19b) define it.

**L-C4 (ADMISSIBLE is not a lattice).** Hazard-freedom is downward-closed;
closure is union-closed; their conjunction is neither.
Witness: \(\{Xm,Xf\}\) and \(\{Aw\}\) can each be legal under baseline closure +
reference hazards, while \(\{Xm,Xf,Aw\}\) is exactly the X19 shape. Under this
algebra L19b folds that case into the requirement lattice
(\(\{Xm,Xf\}\) is no longer closed until `Aw` is present), restoring
union-closure for that one prohibition. Residual non-compositionality remains
for every hazard that stays an external filter (only X2 is membership-evaluable
under the reference `armedHazards`, plus the new X21).

**L-C5 (associativity / commutativity / idempotence of \(\cup\)).** Immediate from
set theory: \((A \cup B) \cup C = A \cup (B \cup C)\), \(A \cup B = B \cup A\),
\(A \cup A = A\). Identity for \(\cup\) is \(\emptyset\). Absorption
\(A \cup (A \wedge B) = A\) holds on the closed-set lattice; the dual
\(A \wedge (A \vee B) = A\) holds because \(A \subseteq A \cup B\) and \(A\) is
already closed.

---

## 2. Validity predicate and complexity

### Definition

Let `FIREABLE` be the 25 laws with at least one element subject under the
reference parser of `viz/src/laws.ts` (subjects split on `|`, terms on `+`,
alts on `|`, isotope braces stripped, non-symbols dropped; external terms
auto-satisfied).

Add one law:

- **L19b:** `Xf → Aw`
  (Option (b) from FINDINGS.md final recommendation: promote hazard X19 from a
  negated unevaluable filter into a positive requirement.)

Add one hazard:

- **X21:** `Fl` co-present with any G12 symbol (`Xm`, `Xf`, `Rl`, `Of`).
  Atomic flash liquidity may not share a flat element-set with a cross-domain
  element (FINDINGS.md §12.1; the 21st hazard).

**Deliberate non-additions:**

- **X11a / L11a-prime:** not added. L3 already forces
  `Uc → Aw + At + (Bs|Tr) + obligor`. Any set closed under L3 that contains `Uc`
  already has `Aw`, `At`, and a collateral/backstop disjunct. The residual words
  “reputation” / “obligor” are external prose and cannot be decided from
  membership either as hazard or as law. **X11a is already subsumed by L3 for
  closed sets; promoting it is a no-op.**
- **`{Au, Gs}` stratum inversion:** not a classification hazard. It is an atlas
  table defect (L21 assigns `Gs` at S3 requiring `Au` at S4), not a financial
  exclusion. Stratum stays asserted with that one known erratum (Q4).

Reference hazards: only rules with ≥2 named element symbols and no negation
word in the combo text are evaluated (`armedHazards` in `laws.ts`). On the
current table that set is exactly **{X2}**. (X3, X5–X10, X13, X15–X17 are
prose under that engine; they are not silently re-interpreted.)

\[
\begin{align*}
\mathrm{closed}_{L19b}(X)
  &\iff \text{every fireable law and L19b that fires on } X \text{ has all non-external terms satisfied}\\
\mathrm{hazard\text{-}free}_{X21}(X)
  &\iff \mathrm{armedHazards}(X)=\emptyset \;\land\; \neg\mathrm{X21}(X)\\
\mathrm{ADMISSIBLE}(X)
  &\iff \mathrm{closed}_{L19b}(X) \;\land\; \mathrm{hazard\text{-}free}_{X21}(X)\\
\mathrm{INADMISSIBLE}(X)
  &\iff \neg\mathrm{ADMISSIBLE}(X)
\end{align*}
\]

### Complexity

**Class P.** Checking a fixed set \(X\) needs no fixpoint iteration:

- Build a hash set of \(X\): \(O(|X|)\).
- For each of \(L \le 26\) laws, scan subjects and terms:  
  \(O\bigl(L \cdot (s + t \cdot a)\bigr)\) with \(s,t,a\) bounded by the fixed
  law table (small constants: at most a few subjects/terms/alts per law).
- For reference hazards: scan 20 rows, extract named symbols, test membership.
- X21: constant-time check of `Fl` against the 4 G12 symbols.

Total: \(O(|X| + |laws|\cdot|terms|\cdot|alts| + |hazards|)\), linear in input
set size and fixed table size. No SAT, no exponential completion search for
classification.

---

## 3. Answers to BRIEF §6

### Q1. What is the carrier?

**Sets of symbols over the 58-element vocabulary** — one sort, \(\mathcal{P}(E)\).

Strategies are out of scope (not elements; not protocols). The algebra
classifies mechanism-sets only. VERDICT.md's yield finding is accepted and
bound as a scope cut, not papered over with a fake element.

### Q2. Is composition a join? Lattice? Closure operator?

- **Composition of element-sets is union.** On the family of *law-closed* sets,
  union is the lattice join (L-C1–L-C2). The laws induce a **closure operator**
  in the Moore/Galois sense (L-C3).
- **Meet is not intersection** (disjunctive terms).
- **ADMISSIBLE is not compositional and not a lattice** (L-C4). L19b repairs
  one join-destroying hazard by folding it into the requirement lattice; X2 and
  X21 remain external filters and can still break joins.

### Q3. Are the 58 elements independent? Redundant generators?

**Recipe A — formal context from real protocols (FCA attribute extents).**

- Objects \(G\): 12 protocols from `viz/src/protocols.ts` + 72 from
  `corpus50/lanes/*.json` = **84 raw**, **83 after name-dedup** (sole collision:
  `Aave v3` / `Aave V3`; richer corpus row kept). Attributes \(M = E\) (58).
- **Mutual implications** \(\mathrm{Ext}(m)=\mathrm{Ext}(m_2)\) with nonempty
  extent: **none**.
  - **Type-level empirically redundant generators: none.**
  - This is the opposite of the *instance* non-injectivity in BRIEF §4.2
    (USDT≡USD1 as protocol rows). At the **element-type** level the corpus does
    not collapse any pair of the 58 symbols.
- **Ungrounded** (\(\mathrm{Ext}(m)=\emptyset\)): **`Wg`, `Cv`, `Sb`, `Sd`**.
  No empirical evidence either way; they never appear in the 83 objects.
- **Strict implications** \(\mathrm{Ext}(m)\subsetneq\mathrm{Ext}(m_2)\) with
  \(m\) in ≥2 objects (interesting ≤15, Up/Gp-as-universal-sink filtered):

  | implication | support(m) | support(m₂) | vs written laws |
  |---|---:|---:|---|
  | Li ⇒ Ct | 27 | 33 | L1 requires Ct from Li's co-subjects, not from Li alone; empirical is stronger |
  | Pf ⇒ Li | 10 | 27 | **duplicates L4** (`Pf → … + Li + …`) |
  | Pf ⇒ Ct | 10 | 33 | **duplicates L1/L4** |
  | Pf ⇒ Ex | 10 | 38 | **duplicates L4** |
  | Fz ⇒ At | 9 | 19 | not a written unit law |
  | Fz ⇒ Rd | 9 | 21 | not a written unit law |
  | Cd ⇒ Li | 8 | 27 | L1 multi-term allows Li\|Ad\|Sl\|Bs; empirical forces Li |
  | Cd ⇒ Ct | 8 | 33 | **duplicates L1** |
  | Im ⇒ Ct | 7 | 33 | **duplicates L1** |
  | Im ⇒ Tg | 7 | 31 | not a written law (governance habit) |
  | Rb ⇒ Ex | 7 | 38 | not a written law |
  | Vl ⇒ Bs | 6 | 17 | not a written law |
  | Vl ⇒ Wq | 6 | 18 | not a written law |
  | Tr ⇒ Sh | 6 | 45 | not a written law |
  | Pm ⇒ Li, Ct, Ex, Sh | 4 | … | partial L1/L4 family by co-occurrence |

  Empirical implications that already sit in the written unit Horn fragment are
  marked above; the rest are corpus regularities, not law redundancy.

**Recipe B — Horn unit basis of the 25 fireable laws.**

Parser identical to `laws.ts`. Extract every term with `alts.length === 1`
(true unit implication subject→alt), expanding disjunctive subjects.

- Raw unit implications: **19** (multiset).
- Unique by `subject→alt`: **18** (duplicate: `Pf→Ct` appears in both L1 and L4;
  L4's copy dropped as duplicate).
- Redundant under the remaining unique units: **1** —
  **`Of → Xm` (L19)**, entailed by `Of → Xf` (L19) then `Xf → Xm` (L8).
- **Minimal unit Horn basis size: 17** implications:

  ```
  Pl→Ct, Im→Ct, Cd→Ct, Pf→Ct, Op→Ct   (L1)
  Uc→Aw, Uc→At                         (L3)
  Pf→Ex, Pf→Li                         (L4)
  Py→Ep, Py→Rd                         (L5)
  Tr→Sv                                (L6; prose alt "mechanical trigger" dropped by parser)
  Xf→Xm                                (L8; prose custodian alt dropped)
  Up→Tg                                (L15; prose emergency alt dropped)
  Of→Xf                                (L19)
  Rl→Au                                (L20)
  Gs→Au                                (L21)
  ```

- **Laws contributing ≥1 non-redundant unit (keep for Horn fragment):**  
  L1, L3, L4, L5, L6, L8, L15, L19, L20, L21 — **10 laws**.
- **Laws contributing only redundant units:** none after dedup
  (L19 still contributes non-redundant `Of→Xf`).
- **Laws with no singleton terms at all** (entire element-expressible content is
  multi-way disjunction or pure external prose) — permanently outside the
  Horn/DG unit analysis:

  L2, L7, L9, L10, L11, L12, L13, L16, L17, L18, L22, L24, L27, L28, L29
  — **15 fireable laws**.

- **Unfireable (prose / conjunctive subjects):** L14, L23, L25, L26 — **4**.

**Scope choice, not oversight:** a literal Duquenne–Guigues base over the 29
laws-as-written is undefined because intents of an FCA context are
intersection-closed and disjunctive conclusions (e.g. `(Bs|Sl)`,
`(Ex|Tp|At)`) are not Horn. Recipe B analyses only the unit-Horn fragment;
the 15+4 laws above **cannot enter** that basis. Minimal unit basis **17** vs
written law count **29**.

**Concrete answer for Q3:** the 58 elements are **empirically independent as
type-level generators** (no mutual Ext equality). There is **no smaller
generating set forced by the corpus**. Flag, do not delete:

- ungrounded (never observed): `Wg`, `Cv`, `Sb`, `Sd`;
- unit-redundant law term (not a redundant element): `Of→Xm` under L19;
- duplicate law text: `Pf→Ct` written twice (L1 and L4).

### Q4. Is stratum derivable as rank?

**No. Stratum stays asserted.** FINDINGS.md Q10: topological rank (choice or
strict) agrees with hand stratum on **3/58** elements, all trivially rank 0
(`Sh`, `Ix`, `Rb`). Rank range 0–2 vs stratum 0–4; 45 elements have no outgoing
element-expressible requirement. **One genuine inversion:**
`L21: Gs(S3) → Au(S4)`. Concept lattices are not graded; this algebra does not
treat stratum as lattice level. The inversion is an atlas erratum, not an
ADMISSIBLE hazard.

### Q5. Terra reflexivity — which relation is a cycle?

Over element types, **none**. FINDINGS.md Q13: the full law-derived requirement
relation (subject → every alternative of every expressible term) is a **DAG
with no self-loops**; every restriction is acyclic. Terra's element set has a
single internal edge `Pl → {Ex,Ix}`.

The collapse is a 2-cycle only on a richer carrier:
\[
(As, UST) \xrightarrow{\mathrm{backs}} (Rd, LUNA) \xrightarrow{\mathrm{backs}} (As, UST).
\]

**Position for this algebra:** the carrier remains \(\mathcal{P}(E)\) (sets of
symbols). The `(element, asset)` sort and `backs` relation are **future work**,
not part of GR-ORD. Consequence stated plainly: **this algebra cannot express
the mechanism that killed Terra.** That is a hard bound on one-sorted element
sets, not a temporary omission to be papered over in the validity predicate.

---

## 4. What was added and what was cut

### Added

| id | form | justification |
|---|---|---|
| **L19b** | `Xf → Aw` | FINDINGS Option (b): restore union-closure for X19; fix permission-laundering polarity |
| **X21** | `Fl` ⊥ G12 | FINDINGS §12.1 complete minimal atomic-scope witnesses `{Fl,Xm}`, `{Fl,Au,Rl}` |

### Not added (explicit)

- L11a-prime / X11a-as-law: subsumed by L3 for closed sets.
- `{Au,Gs}` as hazard: table defect, not finance.
- Strategy sort, asset-index sort: scope cuts (§3 Q1, Q5).
- No elements deleted from the 58.

### Cut from the analysis scope (not from the vocabulary file)

- 4 unfireable laws (never fire from membership).
- 15 fireable laws with no unit Horn content (external/disjunctive only) —
  they still run in `ADMISSIBLE` via the reference engine (external terms
  auto-satisfy), but they contribute nothing to the DG-style unit basis.

---

## 5. Self-assessed discrimination on the blind set

Blind set: **156** cases (`algebra/blind-test-set.json`; note field still says
“144”, count is 156). Ground truth unknown.

| predicate | ADMISSIBLE count | rate |
|---|---:|---:|
| **GR-ORD** (`closed_{L19b}` ∧ hazard-free with X21) | **39** | **25.0%** |
| Baseline (25-law closure ∧ reference `armedHazards` only) | **44** | **28.2%** |

Tightening breakdown relative to baseline (5 extra rejections):

- **L19b** opens 4 baseline-closed cases that have `Xf` without `Aw`.
- **X21** rejects 1 baseline-closed case with `Fl` + a G12 symbol.
- (Reference `armedHazards` alone already rejected 1 case via X2 in both
  predicates; 111 cases fail ordinary law closure under both.)

**Why L19b + X21 should improve discrimination without seeing the key:**

1. **L19b** targets a known join-destroying, polarity-bugged structural failure
   (permissioned claim bridged to an un-gated destination). Real bridges with
   destination allowlists keep `Aw`; synthetic “bridge without gate” corruptions
   should fail. Cost: any real protocol that truly bridges a restricted claim
   with no destination `Aw` is also rejected — that is the intended financial
   judgment, not collateral damage.
2. **X21** targets the only async-impossible element co-composed with
   cross-domain machinery — exhaustively minimal at size ≤5, absent from the
   written 20 hazards. Flash-loan + bridge composites that the baseline green-
   lights are false negatives of the old table.
3. Combined rejection rate moves 28.2% → 25.0% ADMISSIBLE. The baseline's own
   published discrimination (≈50% real / ≈15% noise) already lives mostly in
   law closure (111/156 open). L19b/X21 only cut the residual closed-and-
   reference-safe band, which is exactly where FINDINGS proved unlisted
   hazards hide.

No claim is made about the exact discrimination ratio vs the hidden key; the
directional argument is that both additions reject shapes independently known
to be unsafe or unscoped, without widening the accept set.

---

## 6. What breaks (order-theoretic lens)

1. **Meet ≠ intersection.** Never assume “two legal protocols share a legal
   common part.” The shared elements of two closed sets can be open
   (disjunctive satisfaction by different alts). Users must compute
   \(\mathrm{cl}^\downarrow(A \cap B)\), not \(A \cap B\).

2. **Validity is not a lattice join.** Even with L19b restoring one hazard to
   the requirement side, X2 and X21 (and every prose hazard the engine cannot
   see) remain external filters. \(A,B\) ADMISSIBLE does not imply
   \(A \cup B\) ADMISSIBLE.

3. **No type-level redundancy does not fix instance non-injectivity.** USDT and
   USD1 still map to the same point in \(\mathcal{P}(E)\). The algebra cannot
   separate them; the missing generator is off-chain obligor / register of
   record, not another mechanism symbol.

4. **Stratum is not a rank function** on this lattice. Do not grade concepts by
   S0–S4 and expect agreement with law depth.

5. **Terra is invisible.** One-sorted element sets cannot host the `backs`
   2-cycle. Anyone using this algebra as a death detector for reflexive stables
   will get a silent false negative.

6. **Horn DG basis is a fragment.** Optimizing the 17 unit implications does
   not reduce the 15 disjunctive/external fireable laws or the 4 unfireable
   ones. Reporting “17 vs 29” without that scope sentence would be a lie.

---

*GR-ORD deliverables: `algebra/reports/GR-ORD.md`, `algebra/verdicts/GR-ORD.json`
(156 verdicts). Engine scratch: `tmp/gr-ord-scratch/run.mjs`.*
