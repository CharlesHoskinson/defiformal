# Council proposal — the computational consequences of the tables

*All figures recomputed from `/root/DefiElements/paper/formal-data.tex` and the 60 specs; scripts in
`scratchpad/measure{,2,3}.py`.*

## 0. Verdict in one paragraph

Assigning `ar` is safe, and my own framing of the risk was **backwards**. I predicted a degenerate
low-arity table would look tractable; I measured the opposite. A constant table (`(A)→(A)` for all
58) gives the **worst** width of anything tested — per-application min-fill p50 10, p95 16, max 18 —
because with one colour every port matches every port and the wire graph goes complete. Width is
therefore a *sound* detector of the under-constrained degeneracy. The real degenerate confirm sits
on the **over**-constrained side (a paranoid `ar` where nothing composes: p95 11, low width, C1
vacuously false), and only feasibility and coverage catch it. Separately: the element-level budget
of 12 does not survive filling the empty rows with margin (simulated p95 = 12, exactly at budget),
and the global 58-element port instance is out of reach under every `ℓ` (54–67 unscoped, 43–57 at
interval-2, 12–20 at point-`ℓ`). Per-application constructibility — what C1 actually asserts — is
comfortably tractable (p95 ≤ 8). One algorithmic change is mandatory: **route linearity to bipartite
matching, not bucket elimination**, or cost rises from 4×10⁵ to ≈2×10¹¹ operations. Under that
change the post-`ar` system is *cheaper* than today's. `ℓ` helps strongly and should be a measured
headline, not a side effect.

## 1. Design

### 1.1 Baseline `G₀`, stated exactly so it can be frozen

Vertices = the 58 elements. Per requirement row `(S, T₁…T_k)`: a clique over `S`, and edges `s–a`
for every `s ∈ S`, `a ∈ t ∈ T`. **Disjunctive terms are stars, not cliques** — load-bearing, and it
must be fixed before any table is seen:

| encoding | V (non-isolated) | E | ω | min-fill width |
|---|---|---|---|---|
| star (**I specify this one**) | 35 | 78 | 6 | 6 |
| clique | 35 | 92 | 9 | 8 |

My previously reported (35, 88, ω 6, width 8) is the clique variant with prohibition edges partly
folded in. `ω = 6 ⟹ tw ≥ 5`; min-fill `⟹ tw ≤ 8`. Freeze star-encoded, prohibition edges included,
restricted to requirement vertices, with a committed hash.

### 1.2 What `ar` does to the graph — the construction

`ar(e) = (in(e), out(e))`, `a(e) = |in(e)| + |out(e)|`. Per application (element multiset `M` from
`construction[]`), build the **port graph `G₁`**:

- **Vertices**: one per port occurrence, `N = Σ_{e∈M} a(e)`.
- **Element clique**: `In(e) ∪ Out(e)` — internal coherence. This is vertex blow-up.
- **Wire edges**: `p–q` iff opposite polarity, `colour(p) = colour(q)`, `ℓ(e_p) ∩ ℓ(e_q) ≠ ∅`.
- **Linearity**: exactly-one over the `c`-ports for each linear `c ∈ {A, K, K*, Q}` —
  **do not put this in the primal graph** (§1.4).

Blow-up gives `tw(G₁) ≤ max_t Σ_{v∈B_t} a(v) − 1 ≤ A·(tw(G₀)+1) − 1`, and `tw(G₁) ≥ A − 1` from the
element clique. The upper bound is useless in practice (`A·9 − 1 ≤ 12 ⟹ A ≤ 1.4`) because it assumes
every cross-element port pair is constrained; colour matching kills ~8/9 of them. The operative
bound is §1.3.

### 1.3 The `ℓ`-induced path decomposition — the real bound, and the arity ceiling

If `ℓ(e)` is an **interval** of the 5-chain, then `B_h = {ports of e : h ∈ ℓ(e)}` over `h₀…h₄` is a
valid **path decomposition**: every wire has some `h` in the intersection, every element occupies a
contiguous subpath. Hence, exactly:

> **`tw(G₁) ≤ pw(G₁) ≤ max_h Σ_{e : h ∈ ℓ(e)} a(e) − 1`.**

`ℓ` supplies its own certificate of tractability. With `L = max_h n_h` over the 60 applications
(p50 4, p90 6, p95 6, max 7), the budget holds whenever `ā·L ≤ 13`: `ā = 2.0` passes 59/60 apps,
`2.5` passes 50/60, `3.0` passes 36/60, `4.0` passes 25/60.

Measured (not bounded) per-application min-fill on `G₁`, 9 colours with realistic skew, 120 draws each:

| ā | no `ℓ` (p50/p95/max) | interval-2 `ℓ` | point `ℓ` |
|---|---|---|---|
| 2.0 | 3 / 7 / 9 | 2 / 5 / 9 | 2 / 3 / 3 |
| 2.5 | 4 / 9 / 12 | 3 / 6 / 7 | 3 / 4 / 4 |
| 3.0 | 5 / **12** / 16 | 4 / 8 / 14 | 3 / 5 / 8 |
| 3.5 | 7 / 16 / 20 | 4 / 10 / 12 | 4 / 5 / 8 |
| 4.0 | 9 / 19 / 22 | 6 / 13 / 16 | 4 / 6 / 8 |

**Maximum tolerable mean arity against the budget of 12 at p95: `ā ≤ 3.0` unscoped, `ā ≤ 3.5` under
interval-2 `ℓ`, `ā ≤ 6` under point `ℓ`.** Peak arity turns out nearly irrelevant: holding `ā = 3.0`
under interval-2 `ℓ` and varying the cap `A ∈ {4,6,8,10,12}` moves p95 only from 7 to 9. **The
control variable is arity mass per live-set, not peak arity.** Cap `A ≤ 8` for tail control; enforce
**`ā ≤ 3.5`** as the real gate.

### 1.4 The mandatory algorithmic change

Bucket elimination on `G₁` costs `n·d^(w+1)`. A 10-element instance has `N ≈ 30` ports; the dominant
colour holds ≈7, so `d ≈ 8`; at `w = 8` that is `30·8⁹ ≈ 4×10⁹` per application, **≈2.4×10¹¹ over
60** — six orders above the current 4×10⁵. Elimination is dead.

Instead **factor by colour**. With element coherence read as "every in-port bound", wiring
decomposes into 9 independent subproblems: a bipartite matching per linear colour (`A, K, K*, Q`),
matching-with-slack for affine `U`, per-port reachability for classical `P, V, M, I`. Hopcroft–Karp
on ≤7×7 is ~180 operations; ×9 colours ×60 applications **≈10⁵ — below the current 4×10⁵.**
Assigning `ar` makes the system *cheaper*, provided linearity never enters the primal graph.
Acyclicity is the only residual coupling, and W5 predicts `ℓ` discharges it free.

### 1.5 The certificate — 𝒞 revised

`𝒞 = (X, μ, ρ, δ, ν)` **survives `ar` but is incomplete by one component**: as stated it makes
acyclicity a *computation* (Kahn) rather than a *check*. Add a topological rank `τ : μ → ℕ`:

> **𝒞′ = (μ, X, ρ, δ, ν, τ)**

| clause | check | cost |
|---|---|---|
| `ρ` well-formed | `ρ` on `e`'s ports equals `ar(e)` — table lookup | `O(N)` |
| `X` well-typed | `ρ(p) = ρ(q)` per wire | `O(m)` |
| `δ` valid | `δ(p,q) ∈ ℓ(e_p) ∩ ℓ(e_q)`; `ℓ` as a 5-bit mask ⇒ one `AND` | `O(m)` |
| `ν` valid | degree per port: linear exactly 1, `U` ≤ 1, classical free | `O(N+m)` |
| completeness | every in-port wired or marked boundary | `O(N)` |
| `τ` acyclic | `τ(e_p) < τ(e_q)` per wire | `O(m)` |

**Total `O(N + m)`, linear in construction size. Confirmed.** Keep `ρ` though it is redundant given
`ar` and `μ`, so the checker never trusts the table it validates. **If `ℓ` is horizon-monotone,
`τ = min ℓ(e)` and the sixth component is free** — W5 is exactly the test of whether `τ` is
redundant, and if it confirms, `𝒞` stands unmodified.

## 2. Pre-registered hypotheses and thresholds

- **W1 — baseline freeze (no prediction).** `G₀` = 35 / 78 / ω 6 / width 6. Record before any table
  exists; later disagreement invalidates the run.
- **W2 — PO-SYN-7, filling the empty rows. Direction: UP.** Filling the **52** empty `[ext]()` slots
  raises element-level min-fill from 6 to **median 10, p95 12** (400 trials: min 8, p50 10, p90 11,
  p95 12, max 13). *Confirm* ∈ [8,13]; *refute* ≥ 15 (blow-out) or ≤ 6 (vacuous fills). Encoding is
  not the driver: clique 10.5 vs star 10.3.
- **W3 — port width per application. Direction: within budget.** p95 ≤ 12 and median ≤ 6. *Confirm*
  if ≤ 12 on ≥ 57/60. *Refute* if p95 ≥ 16 or > 6/60 exceed 12.
- **W4 — `ℓ` decomposes. Direction: DOWN; headline result.** Width under the assigned `ℓ` is below
  all-live width by **≥ 30% at median and ≥ 25% at p95**. Reference at `ā = 3.0`: p95 12 → 8
  (interval-2), 12 → 5 (point). *Refute* if reduction < 10% or negative.
- **W5 — `ℓ` is the topological order; acyclicity free. Direction: high.** ≥ **90%** of admissible
  wires are horizon-non-decreasing. *Refute* < 70%.
- **W6 — global synthesis stays hard (negative pre-registration).** All-58 port width **≥ 12 under
  every `ℓ`** — measured 54–67 unscoped, 43–57 interval-2, 12–20 point. Do **not** claim global
  tractability; an observation < 12 requires an independent recount before reporting.

### 2.B The anti-degeneracy gate — my most important contribution

The premise I was handed ("a near-constant `ar` keeps width low and looks tractable") is **false**,
and I have the measurement. The two degeneracies behave oppositely:

| table | σ | per-app width p50/p95/max | C1 | P1 |
|---|---|---|---|---|
| **degenerate** — all `(A)→(A)` | 0.00 | **10 / 16 / 18** | trivially true | trivially true |
| realistic — 9 colours, ā 3 | ≈0.85 | 5 / 12 / 16 | at issue | at issue |
| **paranoid** — unique colour pair/element | ≈0.99 | 5 / 11 / 11 | vacuously **false** | vacuously true |

Width falsifies the under-constrained degeneracy but **not** the over-constrained one. The joint
condition, all five clauses required:

> **CONFIRM(PO-SYN-7) ⟺**
> **(G1) width:** per-app `G₁` min-fill ≤ 12 on ≥ 57/60; **and**
> **(G2) selectivity band:** `σ = 1 − Σ_c p_c q_c ∈ [0.60, 0.95]`, `p_c, q_c` the in/out colour
>   shares. `< 0.60` under-constrained; `> 0.95` paranoid. (Uniform over 9 gives 0.889; over 5,
>   0.800; over 2, 0.500.) **and**
> **(G3) feasibility — non-vacuity of C1:** every in-port in ≥ 57/60 applications has ≥ 1 admissible
>   producer. A table where nothing composes is refuted, not confirmed. **and**
> **(G4) row diversity:** `H(ar) ≥ 3.5 bits` over the 58 (≈11 effective rows — `ar` must be finer
>   than the 16 groups `λ` already gives); no single row covers > 25%; `ā ∈ [2.0, 3.5]`; `A ≤ 8`.
>   **and**
> **(G5) the permutation null — decisive.** Build `ar₀` by permuting the assigned rows uniformly
>   across the 58. This preserves `σ`, `H(ar)`, `ā`, `A` exactly and varies only the row-to-element
>   pairing. The real table must beat ≥ 95% of 1,000 permutations on the retrodiction targets
>   (D-arc recovery, the order-book `{Ct, Ex, Li}` drop, `ρ = 0.958`). **A constant or near-constant
>   table is permutation-invariant, so its p-value is exactly 1.0 and it fails automatically.** G5
>   subsumes G2 and G4, which remain as a cheap pre-screen.

Any informativeness clause failing yields **VOID (degenerate instrument)** — neither confirm nor
refute. A degenerate table must not buy a confirm by being trivial, nor a refute by being trivially
wide.

### 2.C The deletion-versus-dissolution guard

`ℓ` lowers width partly by *deleting constraints*, and the 82.4% dissolution headline is exposed to
exactly this. Measured on `G₀`: **point-`ℓ` deletes 39.7%** of requirement edges (47/78 within-
horizon); **interval-2 `ℓ` deletes 11.5%** (69/78 survive). Pre-register: report the blind `ℓ`'s
edge-deletion rate *beside* its dissolution rate. **If dissolution ≤ deletion + 10 percentage
points, `ℓ` is an eraser, not a decomposer**, and W4 is null however the width moved. On this
evidence I direct the instrument toward **mean `|ℓ(e)| ≈ 2`**: it keeps 88.5% of recorded
constraints and still gives per-app p95 width 8 at `ā = 3`.

## 3. Analysis procedure

Mechanical, in order; steps 1–2 run **before** any assigner starts. Every step is a fixed-seed
script; no threshold is set after step 3.

1. Build and freeze `G₀` (§1.1). Record V, E, ω, min-fill width, elimination order; commit the hash.
2. Close the 15-vs-18 D-arc discrepancy on the frozen `G₀`. No density figure until closed.
3. Receive the sealed tables. Compute `ā`, `A`, `H(ar)`, `σ`, row-share histogram. Evaluate G2–G4.
   **If any fails, stop, record VOID, compute no widths.**
4. Per application: read `construction[]`, build `G₁`, run min-fill (tie-break: lowest fill, then
   lowest degree, then lexicographic port key). Evaluate W3.
5. Repeat step 4 with all elements all-live. Paired difference = W4. Alongside, compute the
   `ℓ`-induced edge-deletion rate on `G₀` and apply §2.C.
6. Horizon-monotone fraction of admissible wires ⇒ W5.
7. All-58 instance width under the assigned `ℓ` ⇒ W6.
8. 1,000 row permutations ⇒ G5 p-value.
9. Fill empty rows per the instrument, recompute element-level width ⇒ W2.

## 4. Falsification conditions

- **Kills tractability:** per-app `G₁` width > 12 on more than 6 of 60, or p95 ≥ 16. The encoding is
  then wrong, not merely expensive.
- **Kills the instrument:** any of G2–G5 fails ⇒ VOID; tables are re-drawn, not re-scored.
- **Kills the `ℓ` claim:** W4 reduction < 10%, **or** dissolution ≤ deletion + 10pp.
- **Kills the linear certificate:** W5 < 70% ⇒ acyclicity is not free; `τ` must be searched and
  `𝒞′` stops being `O(m)`.
- **Kills the empty-row programme:** W2 ≥ 15 ⇒ filling the 15 blind rows is its own change, not
  bookkeeping.

## 5. Threats to validity and mitigations

| threat | mitigation |
|---|---|
| **Encoding freedom** — star vs clique moves width 6→8, ω 6→9; an analyst could pick post hoc | Freeze in step 1 with a committed hash. I specify star. |
| **My priors are not the assigners' table** — all p95 figures assume Gaussian arity, skewed 9-colour draw | Simulation sets *thresholds*, not results. Step 4 uses the real table; if real `σ` is outside [0.60, 0.95] the calibration is void and G2 catches it. |
| **min-fill is a heuristic upper bound** — could report 13 where truth is 11 | Report min-fill *and* ω (exact lower bound). Instances are ≤ 40 vertices; anything landing in [12,15] gets exact treewidth (QuickBB / positive-instance driven) before a refute is declared. |
| **`ℓ` lowering width by deletion** | §2.C, mandatory paired reporting. |
| **82.4% was computed non-blind** | Reference value only; never a threshold. W4's thresholds are relative reductions fixed here. |
| **Global-vs-per-app conflation** — 54–67 vs ≤ 8; a reader could quote either | W6 pre-registers the negative. Every width claim carries its scope. |
| **Multiplicity** — `construction[]` read as a set, but an application may instantiate an element twice | Pre-register the set reading. Any spec showing multiplicity is recorded out-of-scope, never silently deduplicated. |

## 6. Interface requirements on other surfaces

1. **Instrument:** the manual must emit `ar` with `ā ∈ [2.0, 3.5]`, `A ≤ 8`, as a *construction rule
   the assigner follows* — a filter applied after seeing rows is a fitted instrument.
2. **Instrument:** `ℓ(e)` must be an **interval** of the chain, mean `|ℓ| ≈ 2`. Gappy live-sets
   destroy the path decomposition of §1.3 and I lose every bound here; tell me and I re-derive.
3. **Reliability:** report agreement on `a(e)` (the integer) separately from agreement on colours.
   Width depends only on arity; high arity agreement with low colour agreement leaves W3 standing
   and G2 failing.
4. **Barriers:** assigners must not see `construction[]` — the width prediction is computed from it,
   so seeing it lets an assigner tune arity to the budget.
5. **Synthesis:** implement the colour-factored matching solver of §1.4. If the pipeline insists on
   elimination over the port graph, W3 is irrelevant: the cost is 2×10¹¹ regardless.

## 7. What I would cut if we had one day instead of two

**Keep**, in order: G5 (the permutation null), W3, W4, §2.C. That is the whole scientific content,
and all four are single scripts over the frozen `G₀` and the 60 specs.

**Cut**: W2 (its prediction is recorded here and checkable later), W6 (answer already known and
negative), the exact-treewidth escalation, and the arity-vs-colour reliability split.

**Do not cut** G2–G4: three lines of arithmetic, and the pre-screen that prevents a wasted
permutation run.

## DISSENT

**One defect, and it is in the framing I was given.** The brief and my own `PO-SYN-7` both assume
*low width is evidence of a healthy structure*. It is not. I measured the constant table at p95
width **16** and the paranoid table at p95 **11** — the paranoid table, under which **nothing
composes and C1 is vacuously false**, is the more tractable-*looking* of the two, and more so than
the realistic table (p95 12) as well. Width is anti-correlated with informativeness at the top of
the range. Any protocol reporting width as a health indicator without the selectivity band and the
feasibility check will therefore **reward the table that says nothing composes**. That is
structurally the prior effort's fitted-consumer-table error — an instrument scoring well because it
was shaped away from the thing measured — arriving by a different door. G2 and G3 are not optional
hardening; without them the width result is worse than no result, because it points the wrong way.

**Second, smaller dissent.** The budget of 12 was set on the element graph and does not survive
contact with its own roadmap: the simulated fill of the 52 empty `[ext]()` slots puts p95 at exactly
12, with zero margin, *before* `ar` is assigned. Carrying the same number to the port graph is a
coincidence, not a derivation. Restate it as **two** budgets — element-level ≤ 13, port-level
per-application ≤ 12, global explicitly unbudgeted — and record that now, before the tables land,
rather than discovering the collision mid-sprint.
