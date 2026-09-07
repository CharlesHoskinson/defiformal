The review packet was truncated in the chat, so I’ll read the full offloaded prompt first and then give a plain-text verdict from the supplied sources only.The packet is larger than the first slice; I’ll keep reading the remaining claim entries and source excerpts.I’ll keep pulling the remaining cited source spans so each CL item can be checked against the supplied bytes.I’ll extract the cited Lean, paper, and evidence spans next rather than reread the whole packet.VERDICT: ACCEPT WITH LIMITATIONS

This is an advisory source review of the uncommitted DRAFT packet (`REPORT.md` SHA256 `bde9591e…bdf4`, `claims.json` SHA256 `03ca3d0b…c0b1`). It is not an OpenSpec gate, implementation acceptance, Lean build, measurement rerun, or whole-manuscript reconciliation. Source files are treated as Git bytes at `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`. The packet files are authored subjects bound by those hashes; they are not relabelled as existing at that revision.

The 18 proposed dispositions are, as a set, aligned with the supplied sources and with `docs/research/semantic-kernel-claim-disposition.md`. None of the proposed wordings asks to weaken, delete, or restatement-change a scoped Lean theorem. Already-corrected paper passages (internal meet, explicit acyclicity on `thm:excomp`, qualified AFT/bilattice text, mixed-polarity rows) should be preserved, not re-refuted. No hidden 397-check, hash, or execution evidence is assumed here.

---

## Findings

### High
None. No proposed correction, as worded, is a false mathematical statement that should be blocked.

### Medium

**M1. CL06 over-groups an already-narrower abstract with the stronger conclusion.**
The actual corollary is only union-closure failure, hence not a sublattice of the positive family (`paper/atlas.tex` `cor:admnotlattice`). Ledger P1 and the conclusion do overclaim (“the prohibitions are what removes it”). The abstract is weaker and ambiguous: positive constraints form a complete lattice under union, “while the admissible sets do not.” That can be read as “not a complete lattice under union,” which is already the corollary, not as “no induced-order lattice.”
Do not rewrite the abstract into a claim the corollary does not make. Apply the narrowing to P1, the conclusion, and any prose that infers induced-order absence from polarity or one failed ambient operation. `Lattice.lean` `completeLattice` is for a `UnionClosedFamily` with `∅` and `univ`; it does not decide the admissible induced order.

**M2. CL07’s “some Horn classes are also union-closed” is a packet gap, not a cited Lean positive.**
The paper’s universal “Horn model classes are not union-closed” is stronger than `Polarity.lean`: `horn_inter_closed` / `pureNeg_inter_closed` are the positive direction; `pureNeg_not_union_closed` / `proh_not_union_closed` are existential. “Need not be union-closed” is the right replacement. The extra assertion that particular Horn classes *are* union-closed is standard, but no supplied theorem exhibits a union-closed Horn class. Mark that as an uncited observation, or add an instance (empty clause set, or Horn∩dual-Horn), before treating it as source-backed.

**M3. Applying CL06/CL07 must not erase the mixed-row account.**
`formal/v3/VERIFICATION.md` already refuted “prohibitions are the sole obstruction” because `X19*`/`X18` are mixed. The current paper records that in `prop:mixed` and `meas:whereitfalls` (185 pairs; 184 Horn-row arms; six mixed). CL06/CL07 correctly separate generic polarity from instance witnesses. They do not mention mixed polarity. A rewrite that says “only Horn prohibitions matter” would be a stale overcorrection relative to the same manuscript.

### Low

**L1. CL03/CL04 correctly separate one-pass and stabilized Delta.**
`algebra/MODEL.md` §1 records that `Δ` is not idempotent; §2 then defines `ADMISSIBLE` via a kernel/interior `Δ` that is called idempotent. That is a real internal contradiction about the *named* one-pass map. The paper definition displays one-pass `Δ(X)={e∈X: X warrants e}` and immediately says “iterated to a fixed point.” Historical non-idempotence of one-pass `Δ` does not refute a separately defined finite stabilization, if that operator is defined and terminating. Do not transfer idempotence, kernel-hood, or meet-hood between them. Do not treat this packet as a repaired `D*` proof.

**L2. CL15 correctly leaves the concrete bridge open; “established” is statement-level.**
`cor:ourconvex` concludes a convex geometry on all `2^58` subsets from a 15-arc graph and a 21,712-seed `Cn`=reachability check. `ConvexGeometry.lean` proves generic facts (`reachCl_antiExchange_iff` and related) under stated hypotheses on `r` and the closure. `VERIFICATION.md` reports size-`≤3` agreement, two different arc tables (raw 15 vs `L*` 13), and does not encode every subset. The packet is right not to call the concrete claim false. This review does not re-run `lake build`; it only confirms the generic statement and hypotheses in the supplied file.

**L3. CL16’s incompatibility is real; neither total is promoted.**
Current appendix: 172,431,735 size-`≤3` pairs from `ℛ`, 0 intersection failures and 0 union failures, with a five-element intersection witness outside that bound. Historical v3: 179,864,061 size-`≤3` pairs, 0 union failures, 68,058 intersection failures. `meas:latticeconf` 175,230 is shared; intersection counts differ (paper “about 44,000” vs v3 51,917 / seeded 50,223–50,611). Bind revision, predicate, universe, bound/seed, and record. Do not relabel.

**L4. CL17 is the right standard for a model-class claim.**
Width 34 and 20.4% bijunctive clauses are syntax. Failure of majority closure of the *admissible relation* needs three full-instance models whose coordinatewise majority fails. `structures-round2.md` only witnesses one clause `¬x∨y1∨y2`. A wide CNF can still define a bijunctive relation. The packet has not searched for a full-instance witness; that is a gap, not a disproof of median-closure failure.

**L5. Hash/excerpt completeness is outside this review.**
The packet’s “397 passing checks” and “59 exact excerpts” are not in the supplied evidence for this review. Their absence is a packet-completeness gap, not a finding against the mathematical dispositions.

---

## Per-item dispositions (advisory)

| ID | Packet disposition | Review |
| --- | --- | --- |
| CL01 | Withdraw semantic Q/Σ partition | Accept. `BASIS.md` infers provenance from assignment form and cites USDT lockstep; `usdt.qnt` `attestReserve` sets `reserve' = newReserve` and is enabled in `step`. Quint model counterexample only; no deployed USDT correspondence. |
| CL02 | Withdraw semantic minimality; retain syntax | Accept. `Independence.lean` is constructor-use independence in a declared toy `Term`. Preserve the Lean statements; restrict citing prose. |
| CL03 | Separate one-pass and stabilized operators | Accept, with L1. Do not implement `D*` here. |
| CL04 | Clarify paper Delta; not a blanket refutation | Accept. Retain current `prop:joinmeet`: meet is not intersection and not `Δ` of intersection. |
| CL05 | Restore full admissibility predicates | Accept. MODEL §2 drops Ban/Cond/Ground after §1 credited them. Current abstract already treats admissibility as positive agreement ∩ prohibition class. Do not equate historical definitions by shared names. |
| CL06 | Narrow to set-operation failure | Accept the mathematical narrowing; see M1 and M3 for application. |
| CL07 | Replace universal negative with possibility | Accept “need not”; see M2 and M3. Keep 185-pair measurement separate; it is not rerun. |
| CL08 | Bind counts to extraction/universe/record | Accept. MODEL/P2 still say 8 rules and 3,140 closed sets; R9 says 16 rules and that 3,140 was a corpus sample. The large cardinality is historical, not a fresh count. |
| CL09 | Construction-specific AFT/bilattice obstruction | Accept. `thm:aft` and the abstract already deny a framework obstruction. Ledger R6/R7/T0 and the conclusion still use broader language. Do not rewrite the qualified theorem. No external AFT/bilattice literature re-audit. |
| CL10 | Restricted grammar, not a new universal primitive | Accept. `Extremal.lean` separates extremal prefix fill from `SumLocalProg` (atomic sum-local selectors and conjunction). `REFUTATION.md` F9 is broader; the Lean file says it is not the full F9 record. |
| CL11 | Static agreement only | Accept as a citation guard. `Nary.lean` proves binding-union / bracket-independent `Agrees`; it excludes operational TS and conservation lifting. Not a Lean defect. |
| CL12 | Conditional conservation + negative companion | Accept. `cons_of_portConfined` needs confinement, Q-neutrality, initialized `Cons`, and `sup ∉ ports`. `cons_broken_if_sup_is_port` is the counterexample. Same-sort gluing does not supply those premises. |
| CL13 | Syntactic coverage and residue; do not merge denominators | Accept. GENERATION: 743/820 generated, 77 residual, syntax≠bisimulation. GATE-3.1: 28/168 and 119/716 on a later ten-spec slice. Do not merge. |
| CL14 | Name the keyword seed | Accept. `gate33_cert_check.py` tags names by keyword counts, checks `{Led,Prop,Cmp,Post,OTHER}`, fails empty files, blocks missing/empty IR. It does not recompute financial or transition judgments. The blocked-empty correction remains. |
| CL15 | Keep generic theorem; leave instance bridge open | Accept, with L2. |
| CL16 | Bind revision/predicate/seed/bound | Accept, with L3. |
| CL17 | Syntax vs full-instance majority witness | Accept, with L4. |
| CL18 | Do not reapply stale refutations | Accept. v3 `prop:joinmeet` and missing-acyclicity notes target an older manuscript. Current paper already uses the internal meet, assumes acyclicity on `thm:excomp`, and states the cost model separately from the Lean equality. Remaining proof/implementation correspondence is a different obligation. |

---

## Preservation (required if these corrections are later applied)

Keep, do not restatement-weaken:

- `Independence.lean` uses-predicates and deleted-constructor theorems
- `Extremal.lean` `extremal_not_local` / `SumLocalProg` grammar
- `Nary.lean` `agrees_union_assoc` and related static results
- `Interface.lean` `cons_of_portConfined` and `cons_broken_if_sup_is_port`
- `Polarity.lean` dual-Horn union-closure, Horn/pure-neg intersection-closure, existential negatives
- `Lattice.lean` `completeLattice`, `inf_eq_sSup`, `meet_ne_inter`
- `ConvexGeometry.lean` generic anti-exchange/reachability theorems under their hypotheses

Keep, do not re-refute as if still current:

- `prop:joinmeet` (meet is the join of common lower bounds; not `Δ^ω(A∩B)`)
- `thm:excomp` acyclicity hypothesis
- abstract + `thm:aft` construction-specific AFT/bilattice qualifications
- abstract distinction between positive diagonal and full admissibility
- `prop:mixed` / mixed-row composition accounting
- paper statement that the linear-time cost claim is unformalised

---

## Scope limits of this review

- Advisory research/source review of a DRAFT packet only.
- No Lean build, Quint run, numerical rerun, axiom audit, or checker execution was performed for this verdict.
- No claim that every downstream occurrence in the repository has been found.
- A gap in this packet (missing Horn union-closed instance, unsupplied 397 checks, no full-instance majority witness) is not a demonstration that the corresponding mathematical statement is false.
- One-pass `Δ` and any stabilized `D*` remain distinct; this packet does not define or prove `D*`.
- The Quint USDT file is a model counterexample, not a deployed-contract correspondence.

Native Grok review. Requested role: independent native Grok reviewer. Reported identity: Grok 4.6. Reviewed subjects: DRAFT `REPORT.md` / `claims.json` as hashed above, against supplied sources at `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`.
