# GP-ORD — Order-theoretic composition algebra

## 1. Signature, carrier, operations, and laws

### Signature and carrier

Let `E` be the 58 core and candidate mechanism symbols in `viz/src/data.ts`. The `CSM` row is excluded because its status is `limit` and its definition says that it is not an element. The working carrier is the Boolean lattice `P(E)`, ordered by subset. It is single-sorted and bounded to on-chain mechanism sets. External requirements remain residue, and strategies, assets, ports, counterparties, and settlement domains are not carrier coordinates.

The signature used for classification consists of set union `∨`, the closure-kernel meet `∧*` on law-satisfying sets, the interior operator `int`, and the validity predicate `V`. The observation map fixed in `BRIEF.md` is not replaced: this artifact classifies syntactic element sets and makes no claim that the map from protocols to sets is injective.

### Composition on `P(E)`

Composition is join:

`A ∨ B := A ∪ B`.

Direct set algebra proves all requested monoid laws:

- Commutativity: `A ∪ B = B ∪ A` because membership in either side means membership in `A` or `B`.
- Associativity: `(A ∪ B) ∪ C = A ∪ (B ∪ C)` because both sides contain exactly the elements in at least one of `A,B,C`.
- Idempotence: `A ∪ A = A`.
- Identity: `A ∪ ∅ = A`.

Let `C ⊆ P(E)` be the family of sets closed under the reference law semantics. As proved in `BRIEF.md` §4b and `formal/FINDINGS.md` Q14, `C` contains `∅` and is closed under unions. Intersection is not its meet: the given witness is

`{Xm,Xf,Of,Bs} ∩ {Xm,Xf,Of,Sl} = {Xm,Xf,Of}`,

and the intersection leaves L19's `(Bs|Sl)` term unsatisfied. Instead define

`A ∧* B :=` the largest closed subset of `A ∩ B`.

This is well-defined because the union of all closed subsets of `A ∩ B` is closed and remains inside the intersection. Absorption follows directly. Since `A ∧* B ⊆ A`, `A ∪ (A ∧* B) = A`. Also `A ∩ (A ∪ B) = A`; because `A` is itself closed and is the largest closed subset of itself, `A ∧* (A ∪ B) = A`. Thus `(C,⊆,∪,∧*)` is a bounded lattice.

The full 58-element vocabulary was checked with the reused evaluation semantics. It fires all 25 fireable laws—25 of the 29 rows—and all 25 fired laws are satisfied. L14, L23, L25, and L26 have no element-expressible subject under the reference parser and do not fire. Therefore the full vocabulary is closed and is the top of `C`; `∅` is the bottom. The full vocabulary is not valid after hazards are added: among other things, it arms X2 and the atomic-scope rule.

### Kernel/closure duality

`C` is a **kernel system**, the order-theoretic dual of a Moore system: it is union-closed and contains `∅`, whereas a Moore/closure system is intersection-closed and contains `E`. Its canonical interior operator is

`int(X) := ⋃ { c ∈ C : c ⊆ X }`.

This operator is deflationary because every member of the union lies inside `X`. It is monotone because `X ⊆ Y` implies that every closed subset counted for `X` is also counted for `Y`. The union defining `int(X)` is closed, so it is itself one of the closed subsets counted when applying `int` again; deflationarity gives the reverse inclusion. Hence `int(int(X)) = int(X)`. The council's meet is exactly `A ∧* B = int(A ∩ B)`.

Define `C* := {E \ S : S ∈ C}`. De Morgan's law converts arbitrary unions in `C` into intersections in `C*`, and `E = E \ ∅` belongs to `C*`. Thus `C*` is a genuine Moore/closure system dual to `C` by complementation.

This distinction reconciles the two FCA statements. Plain FCA over “closed sets × elements” is structurally wrong as the algebra because `C` is a kernel system, not an intersection-closed intent system. FCA is nevertheless a legitimate audit tool either over the complemented Moore system `C*` or over genuine object/attribute observations such as protocols × elements from `viz/src/protocols.ts` or `corpus50`; ordinary FCA intents there are intersection-closed. That is compatible with `BRIEF.md` §5b: FCA cannot be the raw disjunctive algebra, but it can audit redundancy.

## 2. Validity predicate and complexity

For a submitted symbol set `S`, `V(S)` is true exactly when all of the following checks pass.

1. **Signature.** Every symbol is in `E`. An unknown or contested symbol rejects the entire case immediately; no later check is evaluated for that case.
2. **Law closure.** The 29 `LAWS` rows are parsed from `data.ts`: split at `→`, split left alternatives on `|`, split right terms on `+`, split alternatives on `|`, and remove parentheses and isotope braces. A law fires when any parsed subject is present. Every non-external term must have at least one present alternative; external terms are automatically satisfied and remain residue. Exactly 25 laws are fireable. `S` must satisfy every fired law.
3. **Written hazards.** For each of the 20 `HAZARDS` rows, extract distinct `/\b[A-Z][a-z]{1,2}\b/` tokens and filter them to `E`. A row with fewer than two surviving symbols is skipped. A non-negated row with at least two symbols arms exactly when all named symbols are present. Negated rows are skipped except for the two explicit rulings below.
   - Corrected X11a arms exactly when `Uc ∈ S` and `Aw,At,Bs,Tr ∉ S`.
   - X19 is always residue. “Restricted claim” is an asset-instance property that membership cannot decide. Turning it into blanket `Xf`-without-`Aw` rejection would false-reject ordinary permissionless bridges, so the promotion cost is too high.
4. **Atomic scope.** The added 21st rule, called X21 in the generator signatures, arms exactly when `Fl ∈ S` and `S ∩ {Xm,Xf,Rl,Of} ≠ ∅`.
5. **No stratum pseudo-hazard.** `{Au,Gs}` is not checked. It is an atlas erratum, not a financial hazard.

The hazard parser found only three rows at the two-symbol threshold: X2 names `Fl,Cp,Cl,Pl,Cd`; X11a names `Uc,Aw,At`; X19 names `Xf,Aw`. X2 is the only generic positive-membership check. X11a and X19 are the only threshold-reaching negated rows and are handled by their exceptions, so no row remains for the generic negation skip. Negated X1, X4, and X14 fall below the threshold. X5 has zero named symbols and does not match the negation regex. All remaining rows also fall below the two-symbol threshold.

Corrected X11a is redundant after closure. If a closed set contains `Uc`, L3 forces `Aw`, `At`, and one of `Bs` or `Tr` (plus external obligor residue). This contradicts every way X11a can arm. Computation confirms that X11a armed on **zero** blind cases that passed closure. It armed on four open cases, always alongside L3 failure. The table's reversed polarity was therefore the bug, not `Uc`: after correction and closure, `Uc` is realizable and remains in the vocabulary.

The predicate is decidable in time linear in `|S|` plus the fixed schema size: 25 fireable laws with at most five terms, 20 hazard rows, and one atomic rule. For this fixed 58-symbol artifact that is `O(1)` in practice. An unrestricted feature model or propositional theory can be SAT-hard in general, but this is the fixed, bounded, Horn-like-with-disjunctive-head structure diagnosed in `BRIEF.md` §5b as “a propositional theory over 58 atoms—cheap and decidable”; no general SAT search is required for one classification.

## 3. Answers to `BRIEF.md` §6

### 1. What is the carrier?

The classification carrier is `P(E)`, the sets of the 58 admitted mechanism symbols. It is not a multiset, syntax tree, port graph, asset-indexed instance model, or strategy sort. This choice implements the required classifier but deliberately excludes the richer objects identified by the corpus.

### 2. Is composition a join, is there a lattice, and are the laws a Galois closure?

Composition is union and hence join in `P(E)` and in the closed-set suborder. Closed sets form the bounded lattice proved in §1, with meet `int(A ∩ B)`. Valid sets do not form that lattice because adding hazards can destroy join.

The law-satisfying family is not itself a Moore closure system and its canonical operator is an **interior** operator, not a closure operator: the laws give the kernel system `C`. Complementation yields the Moore system `C*`, where ordinary closure/Galois language is legitimate. This is the exact order-theoretic answer rather than treating raw intersections as closed.

### 3. Are the 58 elements independent?

No. Equality of `SUBJ`, `REQ`, and `HAZ` signatures produces five non-singleton classes. X21 is included in `HAZ` for `Fl,Xm,Xf,Rl,Of`; corrected X11a is included for the symbols actually named by its row; X19 is excluded as residue. The keeper is listed first and every later member is a redundant-generator candidate.

| class | keeper | redundant candidates | editorial distinction |
|---|---|---|---|
| `{Sh,Ix}` | `Sh` — Pro-rata share accounting | `Ix` — Index-based accrual | Same G01 and S0, but different domain meanings. |
| `{Cp,Cl}` | `Cp` — Constant-product invariant | `Cl` — Concentrated liquidity | Same G02 and S1, but different pool mechanisms. |
| `{Wg,St,Pm,Ob,Ag,Ft,Cv,Dp,Oa,Sr,Em,Fd,Gp,As,Vl}` | `Wg` — Weighted-geometric invariant | `St` Stable-hybrid invariant; `Pm` Oracle-priced inventory curve; `Ob` On-chain order book; `Ag` Aggregation & routing; `Ft` Fixed-term debt; `Cv` Mutual cover pool; `Dp` Directional position & hedge maintenance; `Oa` Optimistic assertion oracle; `Sr` Streaming accrual; `Em` Protocol-funded emissions; `Fd` Surplus & fee distribution; `Gp` Guardian or pause; `As` Algorithmic supply adjustment; `Vl` Staking & validator lifecycle | Members span G02, G03, G04, G05, G07–G11, G13, and G16 and strata S1–S4: law-redundant but editorially distinct. |
| `{Rf,Ba}` | `Rf` — Request for quote | `Ba` — Batch-auction clearing | Same G03 but S1 versus S2: law-redundant but editorially distinct. |
| `{Im,Op}` | `Im` — Isolated lending market | `Op` — Option payoff | G05 versus G07, both S3: law-redundant but editorially distinct. |

The suggested triples do not survive the exact signature test. `Rb` is not a clone of `Sh/Ix` because `Rb` occurs in L5 but not L2. `Li,Ad,Sl,Bs` have distinct requirement and hazard roles. `Ex,Tp,At` have distinct subject and hazard roles. The computed equivalence is sound—members of every reported class are interchangeable to these parsed law/hazard signatures—but not necessarily complete. It is not a Duquenne–Guigues minimum and does not cross the disjunctive-Horn wall already established in `BRIEF.md` §5b.

### 4. Is stratum derivable?

No. `formal/FINDINGS.md` Q10 reports only 3/58 matches, all trivial `0=0`, with derived rank range 0–2 versus asserted strata 0–4; 45 elements are requirement-terminal. Stratum must remain asserted. The ruling is to correct `Gs` from S3 to S4 to remove the sole L21 inversion; this is cosmetic and does not change `V` or mutate `data.ts`.

### 5. In what relation is Terra's collapse a cycle?

`formal/FINDINGS.md` Q13 establishes that the full element requirement relation is a DAG with no self-loops, so no restriction to an element subset can contain a requirement cycle. Terra's cycle exists only on the richer carrier of `(element, asset)` instances under `backs`, where solvency of one instance depends on the market value of the other asset: `(As,UST) backs (Rd,LUNA) backs (As,UST)`. The classifier's `P(E)` carrier cannot express this relation.

X1 does not rescue the element-set classifier: its only extracted symbol is `As`, so it is below the two-symbol threshold. Terra's exact set `{As,Rd,Ex,Pl,Ix,Em}` is nevertheless **INADMISSIBLE**, because it fails L1 by omitting `Ct` and every alternative in `(Li|Ad|Sl|Bs)`; it is written-hazard-free and atomic-scope-clean. The minimally relevant closed completion `{As,Rd,Ex,Pl,Ix,Em,Ct,Li}` is **ADMISSIBLE** even though it retains the Terra-shaped asset reflexivity. That completed witness demonstrates the structural blind spot without contradicting the reference closure result.

### Position against prior art

Versus interface automata and assume-guarantee contracts, this artifact has no ports and therefore no local assumption/guarantee boundary on which to compose compatibility. Its `meet*` must be recomputed globally as the interior of an intersection against the whole closure system. That is the concrete cost of the “composition of sets without ports” problem identified in `BRIEF.md` §5b; the richer local conjunction, quotient, and refinement operations do not transfer to this carrier.

Versus FCA, `C` is a kernel system rather than an intent/closure system, so FCA is wrong as **the** algebra over raw law-satisfying sets. FCA remains legitimate as an audit tool over the dual `C*` or over actual protocol × element corpus data, whose intents are intersection-closed by construction. This is exactly the limited FCA use recommended in `BRIEF.md` §5b and used here only in spirit through signature equality, not as a claimed Duquenne–Guigues base.

## 4. Vocabulary additions and cuts

- **ADDED:** X21, the formal atomic-scope hazard `Fl + any G12 element`, with G12 here exactly `{Xm,Xf,Rl,Of}`.
- **ADDED (cosmetic):** correct `Gs` stratum from 3 to 4.
- **CUT/DEMOTED:** none. All 58 elements remain, including realizable `Uc`.
- **CANDIDATES FOR MERGING:** the five redundant-generator classes in §3.3. They are reports of closure-system interchangeability, not unilateral deletions. No mutation of `viz/src/data.ts` was authorized or performed.
- **DECLINED PROMOTION:** X19 remains residue because the asset-level restricted-claim premise is unavailable and blanket promotion would reject ordinary permissionless bridges.

## 5. Blind-set discrimination and calibration

### Protocol calibration

The independent parser agreed with the reference `closes()` engine on all 12 protocol symbol arrays. Closure alone is not the full R4 predicate, but all 12 calibration protocols were written-hazard-free and atomic-scope-clean, so their final verdicts happen to equal their closure results.

| protocol | closed | written-hazard-free | atomic clean | R4 verdict |
|---|---:|---:|---:|---|
| aave | yes | yes | yes | ADMISSIBLE |
| uniswapv3 | yes | yes | yes | ADMISSIBLE |
| maker | yes | yes | yes | ADMISSIBLE |
| liquity | yes | yes | yes | ADMISSIBLE |
| gmx | yes | yes | yes | ADMISSIBLE |
| lido | no (L15) | yes | yes | INADMISSIBLE |
| cow | yes | yes | yes | ADMISSIBLE |
| cctp | no (L19) | yes | yes | INADMISSIBLE |
| centrifuge | no (L6) | yes | yes | INADMISSIBLE |
| terra (dead) | no (L1) | yes | yes | INADMISSIBLE |
| mango (dead) | no (L2, L4) | yes | yes | INADMISSIBLE |
| euler (dead) | no (L15) | yes | yes | INADMISSIBLE |

Thus R4 accepts 6/9 alive protocols (66.7%) and rejects 3/3 dead protocols in this small, non-random calibration. It exactly reproduces the closure table: the six named live protocols close, the other three live protocols do not, and all three dead protocols do not.

### Blind classifications

The 156 classifications contain **42 ADMISSIBLE (26.9%)** and **114 INADMISSIBLE (73.1%)**.

The following mutually exclusive reason profiles sum to all 156 cases:

| profile | cases |
|---|---:|
| ADMISSIBLE | 42 |
| R1 out-of-signature | 2 |
| R4b open only | 97 |
| R4c written hazard only | 1 |
| R4d atomic scope only | 1 |
| R4b + R4c | 8 |
| R4b + R4d | 4 |
| R4b + R4c + R4d | 1 |

Equivalently, the non-exclusive reason totals are: out-of-signature 2, open 110, written-hazard-armed 10, and atomic-scope-armed 6. Written hazard counts are X2 = 6 and corrected X11a = 4. The one closed case rejected only by X2 is T037; the one otherwise-valid case rejected only by atomic scope is T090. Corrected X11a rejected no closed case.

R1 fires exactly twice:

- T058: out-of-signature `Ve`.
- T104: out-of-signature `Ve`.

### Self-assessed discrimination ratio

There is no blind-set ground truth, so no measured discrimination ratio is available. The calibrated real-protocol acceptance estimate is `p_real ≈ 6/9 = 0.667`, while the observed blind acceptance is `q = 42/156 = 0.269`. If `π` is the unknown real share of the blind set and the calibration rate transfers, the implied synthetic acceptance is

`p_synth = (0.269 - 0.667π)/(1-π)`

and the estimated discrimination ratio is `0.667/p_synth`. This is feasible only for `π ≤ 0.404`; beyond that, at least one transfer assumption is wrong. As a transparent sensitivity range, if the blind set is 20%–35% real, the implied synthetic acceptance is about 17.0%–5.5%, giving an estimated ratio of about **3.9×–12.1×**. This conditional range exceeds the reference 3.3× baseline, but it is not a scored result: the mix is unknown, the calibration has only nine alive observations, and “alive” is not itself ground-truth admissibility.

## 6. What breaks

The decisive blind spot is asset-indexed reflexivity. X1 is not membership-decidable, and a law-completed Terra-shaped set is admitted even though the live `backs` cycle can collapse. More generally, the one-sorted carrier cannot represent strategy policies, port-local assumptions, scope/inheritance, asset identity, or settlement-domain placement; these are the same gaps identified by `corpus50/VERDICT.md`.

The classifier is also strict about editorial signature boundaries: the contested `Ve` rejects T058 and T104 before their otherwise meaningful mechanisms are examined. Finally, X11a adds no rejection power after closure, while X19 adds none by ruling; of the written table, only X2 independently rejects a closed blind case. The validity filter is therefore driven mainly by requirement closure, not by the prose-heavy hazard register.

## DEVIATIONS

The instruction's R7 example suggests that Terra's exact protocol set `{As,Rd,Ex,Pl,Ix,Em}` may be admissible if X1 is skipped. Direct computation, consistent with `formal/FINDINGS.md`'s Protocol Closure Results table, shows that this set is open under L1 and therefore INADMISSIBLE. I did not force the suggested result. The closed completion `{As,Rd,Ex,Pl,Ix,Em,Ct,Li}` is ADMISSIBLE and is used above as the correct witness for the Terra-shaped structural blind spot.
