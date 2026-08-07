# Cold Proof Audit: DefiElements M3 Nary

Audit date: 2026-08-07

Primary scope: `lean/Defialgebra/Nary.lean` and the M3 entries in
`lean/Axioms.lean`.

Contract sources: `research/positive-program/sigma/M3-DESIGN.md`,
`research/positive-program/sigma/INTERFACE-COUNCIL.md`, and the current
positive-program planning files.

## Verdict: REVISE

The checked M3 proofs are kernel-valid. The global agreement core and the
fixed-cut negative witness satisfy their local statements.

M3 does not export the reindex theorem required by M3-DESIGN contract item 4.
The current theorem relates one binding to its own symmetric closure. It does
not compare two bindings with equal symmetric closures.

The council requirement also remains only partly discharged. The module proves
an associative algebra of binding constraints. It does not define an n-ary
composite of machines.

These are contract and API gaps, not proof-soundness failures. Therefore, the
correct verdict is REVISE rather than REJECT.

## Acceptance criteria

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Build hygiene | PARTIAL | `lake build` completed 977 jobs. Direct checks passed. The source scan found no `sorry`, `admit`, custom `axiom`, `opaque`, or `unsafe` token in M3. All seven exported theorem checks used only `propext`, `Classical.choice`, and `Quot.sound`. However, `lean/Axioms.lean:30-33` permanently checks only three M3 theorems. |
| 2 | M3 fidelity, global binding | PASS | `Machine.ports` is finite at `lean/Defialgebra/Nary.lean:45-47`. `Binding.pairs` is a finite global pair set at `lean/Defialgebra/Nary.lean:49-51`. `Agrees` requires equal state on every bound pair at `lean/Defialgebra/Nary.lean:53-59`. |
| 3 | Bracket and reindex independence | PARTIAL | Constraint union is associative and commutative at `lean/Defialgebra/Nary.lean:77-105`. Orientation independence is proved at `lean/Defialgebra/Nary.lean:61-75`. No theorem compares two bindings under equality of their symmetric closures, as required by `research/positive-program/sigma/M3-DESIGN.md:8`. |
| 4 | Negative companion | PASS | `PairLocal` requires every edge to cross one cut at `lean/Defialgebra/Nary.lean:107-115`. `pairLocal_excludes_skip` uses cut disjointness at `lean/Defialgebra/Nary.lean:121-127`. The concrete `Fin 3` witness proves an actual skip edge at `lean/Defialgebra/Nary.lean:129-151`. |
| 5 | Scope honesty | PASS | The module excludes transition systems, the M1 lift, and M4 corpus work at `lean/Defialgebra/Nary.lean:31-35`. Its positive claim is limited to constraint union at `lean/Defialgebra/Nary.lean:24-26`. |
| 6 | Gaps and risks | FAIL | `Machine` is unused after its definition. Bindings need not reference exposed ports. Ordered pairs represent an undirected concept only semantically. There is no linear port-use rule or link to M1 and M2. The permanent axiom audit is incomplete. |
| 7 | Next steps | PASS | The ranked list below separates required M3 rework from M4 work. |

## Concrete findings

### F1 — High: the contract-level reindex theorem is absent

M3-DESIGN requires two bindings with the same symmetric closure to induce the
same agreement predicate at
`research/positive-program/sigma/M3-DESIGN.md:8`.

`agrees_iff_agrees_sym` quantifies one binding and one state at
`lean/Defialgebra/Nary.lean:64-75`. Its conclusion compares `Agrees B s` with
agreement over `symClosure B.pairs`.

The theorem has no second binding. It also has no hypothesis that two symmetric
closures are equal as relations.

The required result is likely a direct corollary. However, the audit cannot
credit an unstated theorem as a delivered contract item.

This finding is the main reason for REVISE.

### F2 — Medium: bracket independence is valid but deliberately weak

`Binding.union` is only finite-set union at
`lean/Defialgebra/Nary.lean:77-78`. `union_assoc` reduces to
`Finset.union_assoc` at `lean/Defialgebra/Nary.lean:91-94`.

`agrees_union_assoc` then rewrites by that equality at
`lean/Defialgebra/Nary.lean:101-105`. This proves bracket independence at the
constraint level.

The result does not prove operational associativity. It has no transitions,
reachability, machine family, or composite state space.

The module states this narrow scope honestly. M3-DESIGN also limits item 5 to
constraint union at `research/positive-program/sigma/M3-DESIGN.md:9`.

The broader council text asks for n-ary composition over a global binding set at
`research/positive-program/sigma/INTERFACE-COUNCIL.md:123-124`. The current file
supplies only the binding algebra for that future object.

### F3 — Medium: `Machine` does not constrain any binding

`Machine` contains only `ports` at `lean/Defialgebra/Nary.lean:45-47`. No later
declaration consumes `Machine`.

`Binding` contains arbitrary pairs of global indices at
`lean/Defialgebra/Nary.lean:49-51`. It does not require either endpoint to occur
in an exposed machine port set.

`Agrees` evaluates a total state on every index at
`lean/Defialgebra/Nary.lean:53-59`. Therefore, a binding can mention no machine
port and still form a valid constraint.

This does not falsify contract items 1 through 3. It weakens the connection
between the global-name model and actual machine interfaces.

### F4 — Medium: bindings are ordered data with undirected semantics

`Binding.pairs` stores values of type `Idx × Idx` at
`lean/Defialgebra/Nary.lean:49-51`. Thus `(a,b)` and `(b,a)` are different stored
pairs.

`symClosure` adds swapped pairs at `lean/Defialgebra/Nary.lean:61-62`.
`agrees_iff_agrees_sym` proves that agreement ignores orientation at
`lean/Defialgebra/Nary.lean:64-75`.

This is sufficient for state agreement. It does not make bindings equal as
data, and it does not normalize unions under edge reversal.

Future theorems that inspect `Binding.pairs` can observe orientation unless they
explicitly pass through symmetric closure.

### F5 — Medium: the negative companion is real but models one fixed cut

`PairLocal` defines every permitted edge as a left-to-right or right-to-left
edge at `lean/Defialgebra/Nary.lean:112-115`.

`SkipEdge` requires two distinct endpoints on the left at
`lean/Defialgebra/Nary.lean:117-119`. The exclusion proof uses the cut's
disjointness in both orientation cases at `lean/Defialgebra/Nary.lean:121-127`.

The witness chooses `{0,2} | {1}` and proves `(0,2)` is a skip edge at
`lean/Defialgebra/Nary.lean:129-149`. Any finite edge set containing that pair
fails `PairLocal` at `lean/Defialgebra/Nary.lean:148-151`.

The witness is not vacuous. It establishes the stated fixed-cut obstruction.

It does not model sequences of binary compositions. It also does not quantify
binary trees, accumulated earlier edges, or quotient-class couplings.

Therefore, it cannot support a stronger claim that every possible binary
encoding fails. The M3-DESIGN claim is acceptable only with its designated-cut
reading at `research/positive-program/sigma/M3-DESIGN.md:10`.

### F6 — Medium: council linearity and milestone integration remain absent

The council requires linear, plug-once use for `Q` ports at
`research/positive-program/sigma/INTERFACE-COUNCIL.md:56-63`.

`Nary.lean` has no sort, ownership, degree, or port-use predicate. A port can
occur in any number of binding pairs.

The module imports only Mathlib at `lean/Defialgebra/Nary.lean:6-9`. No M3 theorem
mentions M1 `Cons`, M1 `Ledger`, M2 polarity, M2 flows, or M2 directed edges.

These integration gaps do not contradict the stated M3 exclusions. M3-DESIGN
excludes the M1 transition lift and keeps M2 local at
`research/positive-program/sigma/M3-DESIGN.md:12-16`.

They remain risks against the complete council architecture.

### F7 — Low: permanent axiom coverage omits part of the M3 API

`lean/Axioms.lean:30-33` prints axioms for `agrees_union_assoc`,
`pairLocal_excludes_skip`, and `skip_not_pairLocal_witness`.

It does not print axioms for `agrees_iff_agrees_sym`, `agrees_union`,
`union_assoc`, or `union_comm`.

This audit printed all seven declarations through Lean standard input. Every
declaration used only `propext`, `Classical.choice`, and `Quot.sound`.

The trust result passes. The repository coverage remains incomplete.

### F8 — Low: agreement is satisfiable but proves no preservation property

`Agrees` is a pure state predicate at `lean/Defialgebra/Nary.lean:58-59`.
Constant states satisfy it for every binding.

This does not make the theorem vacuous. It shows that M3 proves constraint
equivalence, not reachability or invariant preservation.

The module reports this limit at `lean/Defialgebra/Nary.lean:31-35`.

## Ranked next actions

1. **M3 required:** Export the two-binding reindex theorem from M3-DESIGN item
   4. Its premise must compare symmetric closures as relations. Its conclusion
   must compare the two `Agrees` predicates.

2. **M3 required:** Add permanent axiom prints for the reindex theorem and all
   M3 contract theorems. Keep the allowed set limited to `propext`,
   `Classical.choice`, and `Quot.sound`.

3. **M3 required for the council claim:** Connect bindings to a finite machine
   family. Require each endpoint to be an exposed port, or narrow the delivered
   claim to a standalone constraint algebra.

4. **M3 recommended:** State whether undirected binding is semantic or
   canonical. If it is semantic, route all public equivalence claims through
   symmetric closure.

5. **M3 recommended:** Model stepwise binary coupling before making a universal
   binary-impossibility claim. Otherwise, keep the negative claim limited to one
   designated cut.

6. **M4 after M3 approval:** Map the 60 cross-carrier invariants to explicit M1,
   M2, and M3 obligations. Record derivable and rejected counts.

7. **M4 after M3 approval:** Re-annotate L3 `total*` claims and correct the
   Pendle backing check. Then rerun the corpus acceptance test from
   `research/positive-program/sigma/INTERFACE-COUNCIL.md:126-129`.

## Verification record

- `cd /root/DefiElements/lean && lake build`
  - PASS. Lake reported `Build completed successfully (977 jobs)`.

- `cd /root/DefiElements/lean && lake env lean Defialgebra/Nary.lean`
  - PASS with exit code 0 and no diagnostics.

- `cd /root/DefiElements/lean && lake env lean Axioms.lean`
  - PASS with exit code 0.
  - The three permanent M3 prints used only `propext`, `Classical.choice`, and
    `Quot.sound`.

- `printf ... | lake env lean --stdin`
  - PASS for all seven exported M3 theorems.
  - Each theorem used only `propext`, `Classical.choice`, and `Quot.sound`.

- Source scan for `sorry`, `admit`, `axiom`, `opaque`, and `unsafe`
  - PASS. No such token occurred in `lean/Defialgebra/Nary.lean`.
  - `lean/Axioms.lean` contains no custom axiom or opaque declaration.

- Repository usage search
  - `Machine` has no use after `lean/Defialgebra/Nary.lean:46`.
  - M3 declarations have no consumers outside `Nary.lean` and
    `Axioms.lean`.

## Prior audits

The previous combined M1 and M2 audit returned REVISE because M2 claimed
composition preservation without a composition theorem.

That report credited M1's local interface theorem and its negative witness. It
also recorded that M1 remained an abstraction of the council's full `GlueSt`
plan.

The same-session rework note says M2 replaced tag equality with `DirectedEdge`.
It also added positive-denominator flows and a same-polarity negative companion.

The prior report recorded a successful 976-job build after that rework. This M3
audit does not re-litigate M1 or M2.

## Final referee statement

M3 has a sound finite constraint core. It also has a concrete fixed-cut
obstruction against pair-local edges.

Approval requires the exact relation-equality reindex theorem promised by
M3-DESIGN. Approval also requires complete permanent axiom coverage for the M3
contract surface.

The broader INTERFACE-COUNCIL requirement remains incomplete until machines and
their exposed ports participate in an n-ary composite object.

**Final verdict: REVISE.**
