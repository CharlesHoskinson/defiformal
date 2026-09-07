You are the independent native Grok reviewer of a bounded author claim-site inspection in DeFiFormal. Give a substantive plain-text VERDICT (ACCEPT WITH LIMITATIONS / REQUEST CHANGES), findings with severity, and scope limits. No tools, XML tool requests, or claims of execution. Review the 18 CL01–CL18 proposed corrections/citation guards against the supplied actual sources. Challenge incorrect or overstated corrections, stale references, universal claims inferred from syntax or bounded runs, and confusion between one-pass and stabilized Delta. Confirm that already corrected paper passages and scoped Lean theorems are preserved. This is an advisory research/source review of a DRAFT packet, NOT an OpenSpec planning gate, implementation acceptance, full paper reconciliation, Lean build, or whole-instance proof. Source files are exact Git bytes at the stated source revision; REPORT.md and claims.json are uncommitted authored packet subjects bound by hashes. Do not relabel them as existing at that source revision. No hidden evidence should be assumed. Distinguish a gap in this packet from a false mathematical statement. Do not provide private chain-of-thought; give concise review conclusions and supporting citations only.

Source revision: 4d42600082d4213d34ac5ab4b0dfc3eefde23d5e

===== FILE review/semantic-kernel/claim-reconciliation/preparation/REPORT.md | SHA256 bde9591efc02b3818bd09bdf3709c9ba1324b7f6603d45d4079638cb1a94bdf4 =====
# Historical claim-site inspection

This bounded author review identifies passages to reconcile with the adopted claim-disposition register. It records proposed corrections and citation guards; it does not apply them or certify the whole manuscript.

Source revision: `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`. 18 findings, 59 exact excerpts from 20 files.

| ID | Subject | Proposed disposition |
| --- | --- | --- |
| CL01 | Q/Sigma provenance | withdraw semantic partition |
| CL02 | Four primitives and minimality | withdraw semantic minimality retain syntax |
| CL03 | One-pass Delta | separate one pass and stabilized operators |
| CL04 | Paper Delta notation | clarify definition not blanket refutation |
| CL05 | Admissibility versus positive fixed points | restore full predicate scope |
| CL06 | Union closure versus induced lattice | narrow to set operation failure |
| CL07 | Horn model classes | replace universal negative with possibility |
| CL08 | Definite fragment counts | preserve correction and denominator |
| CL09 | AFT and bilattice obstruction | retain construction specific obstruction |
| CL10 | Extremal allocation separation | retain restricted grammar |
| CL11 | Historical binding associativity | retain static agreement only |
| CL12 | Historical interface conservation | retain explicit premises and counterexample |
| CL13 | Generation benchmark | retain syntactic coverage and residue |
| CL14 | Certificate seed | name actual keyword check |
| CL15 | Concrete convex-geometry bridge | retain generic theorem leave instance bridge open |
| CL16 | Enumeration and sampled totals | bind exact revision predicate seed and bound |
| CL17 | Majority closure from clause width | require instance witness or narrow to syntax |
| CL18 | Current versus historical paper corrections | do not reapply stale refutations |

## Findings

### CL01: Q/Sigma provenance

BASIS infers external provenance from update form and says quantity state is never externally overwritten. The cited USDT model includes an enabled attestReserve action assigning reserve from newReserve.

**Proposed wording:** The historical replacement/update classifier measures assignment form. It does not establish provenance, conservation or a quantity/scalar partition.

**Limit:** The Quint source is a model counterexample to the historical claim; no deployed USDT correspondence is established here.

Source spans: `research/positive-program/basis/BASIS.md:25–36` (claim); `quint-models/L6/usdt.qnt:148–174` (counterexample_source); `research/positive-program/sigma/QSIGMA-VERDICT.md:72–115` (recorded_correction).

### CL02: Four primitives and minimality

The four-operation basis is asserted as semantic independence, but the Lean Independence language proves constructor-use properties in a declared toy syntax.

**Proposed wording:** The four constructors are independent under the declared uses predicates. This result supplies no denotational minimality theorem for DeFi protocols or the new kernel.

**Limit:** Preserve every historical Lean statement; restrict the prose that cites it.

Source spans: `research/positive-program/basis/BASIS.md:188–193` (claim); `lean/Defialgebra/Independence.lean:8–16` (scope); `lean/Defialgebra/Independence.lean:30–68` (definition); `research/positive-program/sigma/QSIGMA-VERDICT.md:120–127` (recorded_correction).

### CL03: One-pass Delta

MODEL explicitly records non-idempotence, then calls the same named operator idempotent in its next section.

**Proposed wording:** Use D for one-pass removal and D* only for a separately defined stabilized iteration. Do not transfer properties between the two without a definition and argument.

**Limit:** This audit does not implement or prove a repaired operator.

Source spans: `algebra/MODEL.md:59–62` (claim); `algebra/MODEL.md:74–85` (claim).

### CL04: Paper Delta notation

The paper combines a one-pass displayed formula with the phrase iterated to a fixed point. The historical non-idempotence finding does not itself refute a stabilized finite iteration.

**Proposed wording:** Name the one-pass map and its finite stabilization separately. Attach fixed-point and idempotence claims to the exact operator to which the argument applies.

**Limit:** The current paper already rejects Delta-of-intersection as the lattice meet; retain that correction.

Source spans: `paper/atlas.tex:490–494` (claim); `paper/atlas.tex:430–440` (current_corrected_meet).

### CL05: Admissibility versus positive fixed points

MODEL equates admissibility with two fixed-point conditions, omitting prohibition and grounding conditions that its own earlier correction acknowledges.

**Proposed wording:** Requirements and warrants describe the positive part. Full admissibility must retain every stated prohibition, conditional and grounding predicate of the selected instance.

**Limit:** No equivalence between historical definitions is inferred from shared terminology.

Source spans: `algebra/MODEL.md:44–51` (recorded_correction); `algebra/MODEL.md:74–85` (claim); `paper/atlas.tex:44–52` (current_paper_distinction).

### CL06: Union closure versus induced lattice

The abstract and conclusion claim prohibitions remove lattice structure; the actual corollary states only failure of union closure and hence failure to be a sublattice of the positive family. Ledger P1 makes the same stronger inference.

**Proposed wording:** The positive family has joins given by union and internal meets. The selected admissible family fails union closure and is not its sublattice. Its induced-order lattice status requires a separate argument.

**Limit:** Neither polarity nor failure of one ambient set operation alone determines the induced-order result.

Source spans: `paper/atlas.tex:44–49` (claim); `paper/atlas.tex:457–460` (actual_corollary); `paper/atlas.tex:2625–2628` (claim); `algebra/THEOREM-LEDGER.md:28–28` (claim); `lean/Defialgebra/Lattice.lean:116–127` (scope).

### CL07: Horn model classes

The prose says Horn model classes are not union-closed. The generic Lean negative result gives an existential counterexample, while some Horn classes are also union-closed.

**Proposed wording:** Horn model classes are intersection-closed and need not be union-closed. Particular composition failures require the actual instance witnesses.

**Limit:** The recorded 185-pair measurement is separate from the generic theorem and is not rerun here.

Source spans: `paper/atlas.tex:485–488` (claim); `lean/Defialgebra/Polarity.lean:110–124` (positive_theorems); `lean/Defialgebra/Polarity.lean:216–227` (existential_negative).

### CL08: Definite fragment counts

MODEL and ledger P2 repeat eight rules and 3,140 closed sets; ledger R9 explicitly corrects the rules to sixteen and says 3,140 was a corpus sample.

**Proposed wording:** Bind each count to its actual rule extraction, universe and measurement record. Do not describe a sampled set as the entire lattice.

**Limit:** The corrected large cardinality estimate is historical evidence, not a fresh verified count.

Source spans: `algebra/MODEL.md:98–107` (claim); `algebra/THEOREM-LEDGER.md:29–29` (claim); `algebra/THEOREM-LEDGER.md:53–53` (recorded_correction).

### CL09: AFT and bilattice obstruction

Ledger R6/R7/T0 and the paper conclusion use framework-wide language. The current paper theorem and abstract expressly limit the argument to the specified diagonal/component constructions.

**Proposed wording:** The specified constructions cannot supply the desired nontrivial diagonal behavior under their stated hypotheses. This is not an obstruction to approximation fixpoint theory or bilattices as frameworks.

**Limit:** No external literature theorem is re-audited here; the correction reconciles the manuscript's own stated scope.

Source spans: `algebra/THEOREM-LEDGER.md:51–54` (claim); `algebra/THEOREM-LEDGER.md:64–64` (claim); `paper/atlas.tex:568–592` (qualified_theorem); `paper/atlas.tex:52–57` (qualified_abstract); `paper/atlas.tex:2631–2634` (claim).

### CL10: Extremal allocation separation

The historical refutation promotes ordered allocation to a missing primitive. Extremal.lean separates a declared sum-local selector grammar closed under conjunction.

**Proposed wording:** Ordered prefix allocation cannot be represented by the stated sum-local/conjunction selector grammar. This does not exclude libraries with ordered state, traversal or a richer grammar.

**Limit:** Do not promote this result to universal kernel minimality or complete Quint semantics.

Source spans: `research/positive-program/basis/REFUTATION.md:191–209` (claim); `lean/Defialgebra/Extremal.lean:44–53` (aggregate); `lean/Defialgebra/Extremal.lean:84–112` (grammar).

### CL11: Historical binding associativity

Historical Nary states binding union and bracket-independent agreement and explicitly excludes operational transition systems and reachability.

**Proposed wording:** Binding-set union preserves the static agreement predicate under regrouping. Operational execution and invariant lifting need separate results.

**Limit:** This is a citation guard; it is not a defect in the scoped Lean theorem. The proposed operational sprints remain unimplemented.

Source spans: `lean/Defialgebra/Nary.lean:12–38` (declared_scope); `lean/Defialgebra/Nary.lean:103–120` (theorems).

### CL12: Historical interface conservation

Interface's preservation result assumes confinement, shared-region neutrality, an initialized conservation predicate and a total excluded from ports. Same-sort gluing alone does not supply those premises.

**Proposed wording:** Conservation is conditional on the stated confinement, neutrality and protected-total conditions. Retain the counterexample when the declared total may be shared.

**Limit:** No automatic interface inference or deployed composability is established.

Source spans: `lean/Defialgebra/Interface.lean:5–29` (scope); `lean/Defialgebra/Interface.lean:84–105` (conditional_theorem); `lean/Defialgebra/Interface.lean:120–144` (negative_companion).

### CL13: Generation benchmark

GENERATION distinguishes syntax from bisimulation and reports 743/820 definitions generated with 77 residual failures. A later ten-spec measurement rejects complete generation on its own different denominator.

**Proposed wording:** Report the exact grammar, allowed plumbing, corpus slice, denominator and residue. Syntactic coverage does not establish transition-system equivalence, semantic completeness or primitive minimality.

**Limit:** No historical metric is recomputed or merged across denominators here.

Source spans: `research/positive-program/basis/GENERATION.md:17–41` (definition); `research/positive-program/basis/GENERATION.md:60–111` (measurement); `research/positive-program/sigma/GATE-3.1-GENERATION.md:1–25` (later_slice).

### CL14: Certificate seed

gate33 collects names, assigns tags by keyword counts, checks allowed labels and rejects empty inputs. It does not recompute financial or transition judgments.

**Proposed wording:** The historical Gate 3.3 seed checks keyword tagging and input non-emptiness. Semantic certificates require a separate checker and correspondence evidence.

**Limit:** The blocked-empty correction remains valid. No checker execution is claimed in this audit.

Source spans: `research/positive-program/sigma/gate33_cert_check.py:1–10` (declared_scope); `research/positive-program/sigma/gate33_cert_check.py:41–54` (algorithm); `research/positive-program/sigma/gate33_cert_check.py:77–110` (actual_checks).

### CL15: Concrete convex-geometry bridge

The paper concludes a result on all 2^58 subsets after a finite graph check and a 21,712-seed operator comparison. The generic Lean theorem is conditional on the actual relation and closure; sampled equality does not by itself establish all-input correspondence.

**Proposed wording:** The generic reachability theorem is established under its formal hypotheses. A concrete all-subset conclusion needs an exact instance encoding and proof that the shipped closure matches that relation for every input.

**Limit:** This finding does not refute the generic theorem or assert that the concrete claim is false; it identifies the missing reviewed correspondence.

Source spans: `paper/atlas.tex:950–960` (claim); `lean/Defialgebra/ConvexGeometry.lean:10–26` (generic_scope); `formal/v3/VERIFICATION.md:19–35` (historical_audit); `lean/Defialgebra/ConvexGeometry.lean:301–306` (actual_generic_theorem); `formal/v3/VERIFICATION.md:216–259` (historical_bounded_execution_and_table_discrepancy).

### CL16: Enumeration and sampled totals

The current appendix and historical v3 report contain different size-three pair totals and intersection outcomes. They cannot be reconciled by relabelling old measurements as current runs.

**Proposed wording:** Every reported total must name the actual source revision, selected predicate, universe, enumeration bound or seed, and execution record. Preserve incompatible historical results with their own inputs.

**Limit:** No old exhaustive computation was rerun and no count is promoted to current acceptance.

Source spans: `paper/atlas.tex:2678–2705` (claim); `formal/v3/VERIFICATION.md:12–16` (sampling_warning); `formal/v3/VERIFICATION.md:38–76` (historical_execution).

### CL17: Majority closure from clause width

The appendix infers failure of majority closure from widest-clause width and the proportion of syntactically bijunctive clauses. A chosen wide CNF alone does not rule out an equivalent bijunctive definition of its full model relation.

**Proposed wording:** Report the clause-width statistics as syntax. Retain a claim about failure of majority closure only with three actual full-instance satisfying assignments whose coordinatewise majority fails.

**Limit:** A witness for one clause is not automatically a witness for the conjunction of the whole instance. This audit has not searched for a full-instance witness.

Source spans: `paper/atlas.tex:2672–2676` (claim); `research/positive-program/evidence/gen_chunk3.py:529–535` (downstream_echo); `algebra/research/structures-round2.md:30–31` (single_clause_witness_scope).

### CL18: Current versus historical paper corrections

The v3 report refutes the old Delta meet formula and notes a missing acyclicity hypothesis. The current paper already uses the internal meet and explicitly assumes acyclicity; its cost model is stated separately.

**Proposed wording:** Bind old audit findings to the manuscript revision they examined. Preserve already corrected definitions and hypotheses, and track remaining proof/implementation correspondence separately.

**Limit:** Source inspection is not a fresh build, axiom audit or complexity proof.

Source spans: `formal/v3/VERIFICATION.md:19–35` (historical_audit); `paper/atlas.tex:427–440` (current_meet); `paper/atlas.tex:966–994` (current_hypothesis_and_cost); `paper/atlas.tex:1110–1141` (current_formalization_limits).

## Evidence boundary

The 397 passing checks establish source hashes, excerpt locations, Git byte identity and preservation of all 88 frozen Sprint 10 inputs. They do not establish the truth of the proposed mathematical interpretation.

No historical proof or negative result has been changed. No Lean build, model check, numerical rerun, current axiom audit or independent native review was performed for this packet. A complete reconciliation still requires a reviewed plan, source-specific edits, downstream search, and independent result review. The concrete historical-instance correspondence and full paper rewrite remain separate roadmap obligations.

===== END FILE =====

===== FILE review/semantic-kernel/claim-reconciliation/preparation/claims.json | SHA256 03ca3d0b9e735b2135203b96ee7ee1080c7ca8ff0c82e8b121bdd7c659c9c0b1 =====
{
  "status": "DRAFT_SOURCE_SCOPED_FINDINGS_NOT_ACCEPTED_RECONCILIATION",
  "scope": "Bounded inspection of historical claim sites selected by the adopted semantic-kernel claim-disposition register. Not a repository-wide completeness audit.",
  "author": "stock GPT-6 root",
  "entries": [
    {
      "id": "CL01",
      "topic": "Q/Sigma provenance",
      "disposition": "withdraw_semantic_partition",
      "finding": "BASIS infers external provenance from update form and says quantity state is never externally overwritten. The cited USDT model includes an enabled attestReserve action assigning reserve from newReserve.",
      "proposed_wording": "The historical replacement/update classifier measures assignment form. It does not establish provenance, conservation or a quantity/scalar partition.",
      "sites": [
        {
          "path": "research/positive-program/basis/BASIS.md",
          "start_line": 25,
          "end_line": 36,
          "role": "claim"
        },
        {
          "path": "quint-models/L6/usdt.qnt",
          "start_line": 148,
          "end_line": 174,
          "role": "counterexample_source"
        },
        {
          "path": "research/positive-program/sigma/QSIGMA-VERDICT.md",
          "start_line": 72,
          "end_line": 115,
          "role": "recorded_correction"
        }
      ],
      "limit": "The Quint source is a model counterexample to the historical claim; no deployed USDT correspondence is established here."
    },
    {
      "id": "CL02",
      "topic": "Four primitives and minimality",
      "disposition": "withdraw_semantic_minimality_retain_syntax",
      "finding": "The four-operation basis is asserted as semantic independence, but the Lean Independence language proves constructor-use properties in a declared toy syntax.",
      "proposed_wording": "The four constructors are independent under the declared uses predicates. This result supplies no denotational minimality theorem for DeFi protocols or the new kernel.",
      "sites": [
        {
          "path": "research/positive-program/basis/BASIS.md",
          "start_line": 188,
          "end_line": 193,
          "role": "claim"
        },
        {
          "path": "lean/Defialgebra/Independence.lean",
          "start_line": 8,
          "end_line": 16,
          "role": "scope"
        },
        {
          "path": "lean/Defialgebra/Independence.lean",
          "start_line": 30,
          "end_line": 68,
          "role": "definition"
        },
        {
          "path": "research/positive-program/sigma/QSIGMA-VERDICT.md",
          "start_line": 120,
          "end_line": 127,
          "role": "recorded_correction"
        }
      ],
      "limit": "Preserve every historical Lean statement; restrict the prose that cites it."
    },
    {
      "id": "CL03",
      "topic": "One-pass Delta",
      "disposition": "separate_one_pass_and_stabilized_operators",
      "finding": "MODEL explicitly records non-idempotence, then calls the same named operator idempotent in its next section.",
      "proposed_wording": "Use D for one-pass removal and D* only for a separately defined stabilized iteration. Do not transfer properties between the two without a definition and argument.",
      "sites": [
        {
          "path": "algebra/MODEL.md",
          "start_line": 59,
          "end_line": 62,
          "role": "claim"
        },
        {
          "path": "algebra/MODEL.md",
          "start_line": 74,
          "end_line": 85,
          "role": "claim"
        }
      ],
      "limit": "This audit does not implement or prove a repaired operator."
    },
    {
      "id": "CL04",
      "topic": "Paper Delta notation",
      "disposition": "clarify_definition_not_blanket_refutation",
      "finding": "The paper combines a one-pass displayed formula with the phrase iterated to a fixed point. The historical non-idempotence finding does not itself refute a stabilized finite iteration.",
      "proposed_wording": "Name the one-pass map and its finite stabilization separately. Attach fixed-point and idempotence claims to the exact operator to which the argument applies.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 490,
          "end_line": 494,
          "role": "claim"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 430,
          "end_line": 440,
          "role": "current_corrected_meet"
        }
      ],
      "limit": "The current paper already rejects Delta-of-intersection as the lattice meet; retain that correction."
    },
    {
      "id": "CL05",
      "topic": "Admissibility versus positive fixed points",
      "disposition": "restore_full_predicate_scope",
      "finding": "MODEL equates admissibility with two fixed-point conditions, omitting prohibition and grounding conditions that its own earlier correction acknowledges.",
      "proposed_wording": "Requirements and warrants describe the positive part. Full admissibility must retain every stated prohibition, conditional and grounding predicate of the selected instance.",
      "sites": [
        {
          "path": "algebra/MODEL.md",
          "start_line": 44,
          "end_line": 51,
          "role": "recorded_correction"
        },
        {
          "path": "algebra/MODEL.md",
          "start_line": 74,
          "end_line": 85,
          "role": "claim"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 44,
          "end_line": 52,
          "role": "current_paper_distinction"
        }
      ],
      "limit": "No equivalence between historical definitions is inferred from shared terminology."
    },
    {
      "id": "CL06",
      "topic": "Union closure versus induced lattice",
      "disposition": "narrow_to_set_operation_failure",
      "finding": "The abstract and conclusion claim prohibitions remove lattice structure; the actual corollary states only failure of union closure and hence failure to be a sublattice of the positive family. Ledger P1 makes the same stronger inference.",
      "proposed_wording": "The positive family has joins given by union and internal meets. The selected admissible family fails union closure and is not its sublattice. Its induced-order lattice status requires a separate argument.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 44,
          "end_line": 49,
          "role": "claim"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 457,
          "end_line": 460,
          "role": "actual_corollary"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 2625,
          "end_line": 2628,
          "role": "claim"
        },
        {
          "path": "algebra/THEOREM-LEDGER.md",
          "start_line": 28,
          "end_line": 28,
          "role": "claim"
        },
        {
          "path": "lean/Defialgebra/Lattice.lean",
          "start_line": 116,
          "end_line": 127,
          "role": "scope"
        }
      ],
      "limit": "Neither polarity nor failure of one ambient set operation alone determines the induced-order result."
    },
    {
      "id": "CL07",
      "topic": "Horn model classes",
      "disposition": "replace_universal_negative_with_possibility",
      "finding": "The prose says Horn model classes are not union-closed. The generic Lean negative result gives an existential counterexample, while some Horn classes are also union-closed.",
      "proposed_wording": "Horn model classes are intersection-closed and need not be union-closed. Particular composition failures require the actual instance witnesses.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 485,
          "end_line": 488,
          "role": "claim"
        },
        {
          "path": "lean/Defialgebra/Polarity.lean",
          "start_line": 110,
          "end_line": 124,
          "role": "positive_theorems"
        },
        {
          "path": "lean/Defialgebra/Polarity.lean",
          "start_line": 216,
          "end_line": 227,
          "role": "existential_negative"
        }
      ],
      "limit": "The recorded 185-pair measurement is separate from the generic theorem and is not rerun here."
    },
    {
      "id": "CL08",
      "topic": "Definite fragment counts",
      "disposition": "preserve_correction_and_denominator",
      "finding": "MODEL and ledger P2 repeat eight rules and 3,140 closed sets; ledger R9 explicitly corrects the rules to sixteen and says 3,140 was a corpus sample.",
      "proposed_wording": "Bind each count to its actual rule extraction, universe and measurement record. Do not describe a sampled set as the entire lattice.",
      "sites": [
        {
          "path": "algebra/MODEL.md",
          "start_line": 98,
          "end_line": 107,
          "role": "claim"
        },
        {
          "path": "algebra/THEOREM-LEDGER.md",
          "start_line": 29,
          "end_line": 29,
          "role": "claim"
        },
        {
          "path": "algebra/THEOREM-LEDGER.md",
          "start_line": 53,
          "end_line": 53,
          "role": "recorded_correction"
        }
      ],
      "limit": "The corrected large cardinality estimate is historical evidence, not a fresh verified count."
    },
    {
      "id": "CL09",
      "topic": "AFT and bilattice obstruction",
      "disposition": "retain_construction_specific_obstruction",
      "finding": "Ledger R6/R7/T0 and the paper conclusion use framework-wide language. The current paper theorem and abstract expressly limit the argument to the specified diagonal/component constructions.",
      "proposed_wording": "The specified constructions cannot supply the desired nontrivial diagonal behavior under their stated hypotheses. This is not an obstruction to approximation fixpoint theory or bilattices as frameworks.",
      "sites": [
        {
          "path": "algebra/THEOREM-LEDGER.md",
          "start_line": 51,
          "end_line": 54,
          "role": "claim"
        },
        {
          "path": "algebra/THEOREM-LEDGER.md",
          "start_line": 64,
          "end_line": 64,
          "role": "claim"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 568,
          "end_line": 592,
          "role": "qualified_theorem"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 52,
          "end_line": 57,
          "role": "qualified_abstract"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 2631,
          "end_line": 2634,
          "role": "claim"
        }
      ],
      "limit": "No external literature theorem is re-audited here; the correction reconciles the manuscript's own stated scope."
    },
    {
      "id": "CL10",
      "topic": "Extremal allocation separation",
      "disposition": "retain_restricted_grammar",
      "finding": "The historical refutation promotes ordered allocation to a missing primitive. Extremal.lean separates a declared sum-local selector grammar closed under conjunction.",
      "proposed_wording": "Ordered prefix allocation cannot be represented by the stated sum-local/conjunction selector grammar. This does not exclude libraries with ordered state, traversal or a richer grammar.",
      "sites": [
        {
          "path": "research/positive-program/basis/REFUTATION.md",
          "start_line": 191,
          "end_line": 209,
          "role": "claim"
        },
        {
          "path": "lean/Defialgebra/Extremal.lean",
          "start_line": 44,
          "end_line": 53,
          "role": "aggregate"
        },
        {
          "path": "lean/Defialgebra/Extremal.lean",
          "start_line": 84,
          "end_line": 112,
          "role": "grammar"
        }
      ],
      "limit": "Do not promote this result to universal kernel minimality or complete Quint semantics."
    },
    {
      "id": "CL11",
      "topic": "Historical binding associativity",
      "disposition": "retain_static_agreement_only",
      "finding": "Historical Nary states binding union and bracket-independent agreement and explicitly excludes operational transition systems and reachability.",
      "proposed_wording": "Binding-set union preserves the static agreement predicate under regrouping. Operational execution and invariant lifting need separate results.",
      "sites": [
        {
          "path": "lean/Defialgebra/Nary.lean",
          "start_line": 12,
          "end_line": 38,
          "role": "declared_scope"
        },
        {
          "path": "lean/Defialgebra/Nary.lean",
          "start_line": 103,
          "end_line": 120,
          "role": "theorems"
        }
      ],
      "limit": "This is a citation guard; it is not a defect in the scoped Lean theorem. The proposed operational sprints remain unimplemented."
    },
    {
      "id": "CL12",
      "topic": "Historical interface conservation",
      "disposition": "retain_explicit_premises_and_counterexample",
      "finding": "Interface's preservation result assumes confinement, shared-region neutrality, an initialized conservation predicate and a total excluded from ports. Same-sort gluing alone does not supply those premises.",
      "proposed_wording": "Conservation is conditional on the stated confinement, neutrality and protected-total conditions. Retain the counterexample when the declared total may be shared.",
      "sites": [
        {
          "path": "lean/Defialgebra/Interface.lean",
          "start_line": 5,
          "end_line": 29,
          "role": "scope"
        },
        {
          "path": "lean/Defialgebra/Interface.lean",
          "start_line": 84,
          "end_line": 105,
          "role": "conditional_theorem"
        },
        {
          "path": "lean/Defialgebra/Interface.lean",
          "start_line": 120,
          "end_line": 144,
          "role": "negative_companion"
        }
      ],
      "limit": "No automatic interface inference or deployed composability is established."
    },
    {
      "id": "CL13",
      "topic": "Generation benchmark",
      "disposition": "retain_syntactic_coverage_and_residue",
      "finding": "GENERATION distinguishes syntax from bisimulation and reports 743/820 definitions generated with 77 residual failures. A later ten-spec measurement rejects complete generation on its own different denominator.",
      "proposed_wording": "Report the exact grammar, allowed plumbing, corpus slice, denominator and residue. Syntactic coverage does not establish transition-system equivalence, semantic completeness or primitive minimality.",
      "sites": [
        {
          "path": "research/positive-program/basis/GENERATION.md",
          "start_line": 17,
          "end_line": 41,
          "role": "definition"
        },
        {
          "path": "research/positive-program/basis/GENERATION.md",
          "start_line": 60,
          "end_line": 111,
          "role": "measurement"
        },
        {
          "path": "research/positive-program/sigma/GATE-3.1-GENERATION.md",
          "start_line": 1,
          "end_line": 25,
          "role": "later_slice"
        }
      ],
      "limit": "No historical metric is recomputed or merged across denominators here."
    },
    {
      "id": "CL14",
      "topic": "Certificate seed",
      "disposition": "name_actual_keyword_check",
      "finding": "gate33 collects names, assigns tags by keyword counts, checks allowed labels and rejects empty inputs. It does not recompute financial or transition judgments.",
      "proposed_wording": "The historical Gate 3.3 seed checks keyword tagging and input non-emptiness. Semantic certificates require a separate checker and correspondence evidence.",
      "sites": [
        {
          "path": "research/positive-program/sigma/gate33_cert_check.py",
          "start_line": 1,
          "end_line": 10,
          "role": "declared_scope"
        },
        {
          "path": "research/positive-program/sigma/gate33_cert_check.py",
          "start_line": 41,
          "end_line": 54,
          "role": "algorithm"
        },
        {
          "path": "research/positive-program/sigma/gate33_cert_check.py",
          "start_line": 77,
          "end_line": 110,
          "role": "actual_checks"
        }
      ],
      "limit": "The blocked-empty correction remains valid. No checker execution is claimed in this audit."
    },
    {
      "id": "CL15",
      "topic": "Concrete convex-geometry bridge",
      "disposition": "retain_generic_theorem_leave_instance_bridge_open",
      "finding": "The paper concludes a result on all 2^58 subsets after a finite graph check and a 21,712-seed operator comparison. The generic Lean theorem is conditional on the actual relation and closure; sampled equality does not by itself establish all-input correspondence.",
      "proposed_wording": "The generic reachability theorem is established under its formal hypotheses. A concrete all-subset conclusion needs an exact instance encoding and proof that the shipped closure matches that relation for every input.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 950,
          "end_line": 960,
          "role": "claim"
        },
        {
          "path": "lean/Defialgebra/ConvexGeometry.lean",
          "start_line": 10,
          "end_line": 26,
          "role": "generic_scope"
        },
        {
          "path": "formal/v3/VERIFICATION.md",
          "start_line": 19,
          "end_line": 35,
          "role": "historical_audit"
        },
        {
          "path": "lean/Defialgebra/ConvexGeometry.lean",
          "start_line": 301,
          "end_line": 306,
          "role": "actual_generic_theorem"
        },
        {
          "path": "formal/v3/VERIFICATION.md",
          "start_line": 216,
          "end_line": 259,
          "role": "historical_bounded_execution_and_table_discrepancy"
        }
      ],
      "limit": "This finding does not refute the generic theorem or assert that the concrete claim is false; it identifies the missing reviewed correspondence."
    },
    {
      "id": "CL16",
      "topic": "Enumeration and sampled totals",
      "disposition": "bind_exact_revision_predicate_seed_and_bound",
      "finding": "The current appendix and historical v3 report contain different size-three pair totals and intersection outcomes. They cannot be reconciled by relabelling old measurements as current runs.",
      "proposed_wording": "Every reported total must name the actual source revision, selected predicate, universe, enumeration bound or seed, and execution record. Preserve incompatible historical results with their own inputs.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 2678,
          "end_line": 2705,
          "role": "claim"
        },
        {
          "path": "formal/v3/VERIFICATION.md",
          "start_line": 12,
          "end_line": 16,
          "role": "sampling_warning"
        },
        {
          "path": "formal/v3/VERIFICATION.md",
          "start_line": 38,
          "end_line": 76,
          "role": "historical_execution"
        }
      ],
      "limit": "No old exhaustive computation was rerun and no count is promoted to current acceptance."
    },
    {
      "id": "CL17",
      "topic": "Majority closure from clause width",
      "disposition": "require_instance_witness_or_narrow_to_syntax",
      "finding": "The appendix infers failure of majority closure from widest-clause width and the proportion of syntactically bijunctive clauses. A chosen wide CNF alone does not rule out an equivalent bijunctive definition of its full model relation.",
      "proposed_wording": "Report the clause-width statistics as syntax. Retain a claim about failure of majority closure only with three actual full-instance satisfying assignments whose coordinatewise majority fails.",
      "sites": [
        {
          "path": "paper/atlas.tex",
          "start_line": 2672,
          "end_line": 2676,
          "role": "claim"
        },
        {
          "path": "research/positive-program/evidence/gen_chunk3.py",
          "start_line": 529,
          "end_line": 535,
          "role": "downstream_echo"
        },
        {
          "path": "algebra/research/structures-round2.md",
          "start_line": 30,
          "end_line": 31,
          "role": "single_clause_witness_scope"
        }
      ],
      "limit": "A witness for one clause is not automatically a witness for the conjunction of the whole instance. This audit has not searched for a full-instance witness."
    },
    {
      "id": "CL18",
      "topic": "Current versus historical paper corrections",
      "disposition": "do_not_reapply_stale_refutations",
      "finding": "The v3 report refutes the old Delta meet formula and notes a missing acyclicity hypothesis. The current paper already uses the internal meet and explicitly assumes acyclicity; its cost model is stated separately.",
      "proposed_wording": "Bind old audit findings to the manuscript revision they examined. Preserve already corrected definitions and hypotheses, and track remaining proof/implementation correspondence separately.",
      "sites": [
        {
          "path": "formal/v3/VERIFICATION.md",
          "start_line": 19,
          "end_line": 35,
          "role": "historical_audit"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 427,
          "end_line": 440,
          "role": "current_meet"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 966,
          "end_line": 994,
          "role": "current_hypothesis_and_cost"
        },
        {
          "path": "paper/atlas.tex",
          "start_line": 1110,
          "end_line": 1141,
          "role": "current_formalization_limits"
        }
      ],
      "limit": "Source inspection is not a fresh build, axiom audit or complexity proof."
    }
  ]
}

===== END FILE =====

===== FILE docs/research/semantic-kernel-claim-disposition.md | SHA256 60fb88bcd5cfec9108d8b115a8cf0c963c9a2b1e66b5453457b4601e584b9890 =====
# Claim disposition for the semantic-kernel pivot

This document records scope corrections adopted on 2026-09-06. It does not
regenerate historical measurements or certify new deployed behavior.

| Existing claim or artifact | Current disposition | Repository evidence |
| --- | --- | --- |
| Q/Sigma as a semantic provenance partition; four-element basis | Withdrawn as kernel design claims. Assignment form does not establish provenance. | `research/positive-program/sigma/QSIGMA-VERDICT.md`, sections 3–5 |
| Delta is an idempotent interior/kernel operator | Withdrawn for the operator described in MODEL.md. Its own correction records non-idempotence. Use the warrant operator/predicate unless a repaired definition and proof are supplied. | `algebra/MODEL.md`, section 1 correction versus section 2 |
| Mixed Horn/dual-Horn polarity proves the admissible poset is not a lattice | Unsupported inference. Report explicit failures of particular set operations separately from the induced order structure. | `lean/Defialgebra/Lattice.lean`, `completeLattice` and `meet_ne_inter`; `lean/Defialgebra/Polarity.lean` |
| Independence.lean establishes semantic or financial minimality | It establishes constructor independence in its declared toy syntax. Retain that result at its actual scope. | `lean/Defialgebra/Independence.lean`, module description and `uses` predicates |
| Extremal allocation requires a new universal primitive | The separation concerns the declared sum-local/conjunction grammar. It does not prohibit a library using ordered state and traversal. | `lean/Defialgebra/Extremal.lean`, declared grammar and separation theorem |
| Nary.lean proves operational composition associativity | It proves binding union and agreement properties. Operational reachability and conservation lifting remain separate obligations. | `lean/Defialgebra/Nary.lean`, “What is not proved” |
| Interface.lean automatically infers safe interfaces | Conservation depends on stated confinement/neutrality and non-shareable-total premises. Retain theorem and negative witness. | `lean/Defialgebra/Interface.lean`, `cons_of_portConfined`, `cons_broken_if_sup_is_port` |
| Gate 3.3 PASS certifies financial construction semantics | It checks keyword tagging and input non-emptiness. Retain as a historical prototype, not semantic certification. | `research/positive-program/sigma/gate33_cert_check.py`; `formal/v3/GATE-REGISTER.md` |
| Syntactic generation is domain-relative semantic completeness | Retain as a benchmark with the exact grammar and denominator. Do not promote its rates to semantic completeness or minimality. | `research/positive-program/basis/GENERATION.md`; `sigma/GATE-3.1-GENERATION.md` |
| Bounded anti-exchange executions independently establish the entire finite instance | Keep bounded execution separate from general structural Lean theorems and their application to the concrete instance. Audit the instance correspondence and counting argument before restating exhaustive totals. | `lean/Defialgebra/ConvexGeometry.lean`; `formal/v3/VERIFICATION.md` |

The empirical atlas, hazard data, corpus residue, exact-arithmetic work, fidelity
criteria and negative tests remain reusable research. Their original input
identities and scopes remain attached. No historical theorem is deleted or
weakened to make the new pilot pass.

The paper and all downstream claim sites still need a dedicated reconciliation
pass. These corrections govern new work and override conflicting historical
prose; they are not a claim that every old occurrence has been edited.

===== END FILE =====

===== FILE algebra/MODEL.md | SHA256 f7461d1a0e2ed613176ff6190d39938226cae6ce957af40c8c4cefd46449d148 =====
# Current scope correction (2026-09-06)

This is a historical research record. The
[claim disposition](../docs/research/semantic-kernel-claim-disposition.md)
overrides conflicting claims below: Delta's idempotent-interior description is
withdrawn, and mixed clause polarity alone does not prove absence of a lattice
under inclusion. The active objective is the
[semantic-kernel migration](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).

---

# The model

> **The running score lives in [`THEOREM-LEDGER.md`](THEOREM-LEDGER.md)** — proved, refuted, contested and open. Plain-English companion: [`PLAIN-ENGLISH.md`](PLAIN-ENGLISH.md).

Nine mathematicians, three schools, one problem. The useful model is not any one
of their answers — it is three of them stacked, and they stack cleanly because
each solves what the one below it cannot express.

---

## 1. The central idea: the atlas is half a specification

This is OP-ORD's finding and it reframes everything.

The 29 laws state what a mechanism **requires**. Nothing anywhere states what a
mechanism is **for**. Compute the Galois adjoint of the requirement relation and
you get 27 **warrant** rows — `Li → Ct`, `Tp → (Cp|Cl|St|Wg|Pm|Ob)`,
`As → (Ex|Tp|Oa|At)`. A liquidation mechanism is *for* a collateral test. A
time-weighted price is *for* a pool that needs one.

The ablation reproduces to the digit under independent re-implementation. **The
story I told about it does not.**

| | discrimination |
|---|---|
| closure `Γ` alone | 2.45× |
| warrant `Δ` alone | 2.37× |
| **`Γ ∧ Δ` — the two adjoints together** | **4.46×** |
| independence would predict | 5.79× |
| all four blocks (adds Ban+Cond, Ground) | **10.83×** |

**Correction, and it is mine.** I reported 10.83× as what the two adjoints
achieve together. It is not. `Γ ∧ Δ` is **4.46×**, which is *below* the 5.79×
independence would give — the two adjoints are **sub-multiplicative**, rejecting
35 of the same 84 negatives where independence predicts 31. More than half of
the 10.83× comes from **Ban+Cond and Ground**, two blocks this document never
mentioned.

So warrant is worth about **1.8× on top of closure**, not 4.4×. That is still a
real and useful contribution, and it is the single largest *conceptual* addition
— but "the product of two adjoints produces the number" is false, and the
half-specified framing oversells what the second adjoint buys.

**And `Δ` is not idempotent**, so it is not literally a kernel operator. The
closure/kernel pairing is the right intuition and the wrong algebra; state it as
a pair of monotone operators whose common fixed points we want, and stop calling
`Δ` a kernel until it is repaired.

One more, and it is uncomfortable: **the parser bug was doing discriminating
work.** Reference closure falls from 2.33× to 1.98× once the mixed terms are
fixed. Treating five disjunctions as hard requirements was accidentally encoding
constraints that are really there — which is why the corrected engine accepts
more junk. The fix was still correct; it just cost us discrimination we had not
earned.

## 2. The validity predicate

> **A protocol is admissible iff it is a fixed point of both a closure operator
> and a kernel operator.**
>
> `ADMISSIBLE(X) ⟺ γ(X) = X ∧ Δ(X) = X`
>
> where `γ` is requirement-closure (everything you need is present) and `Δ` is
> warrant-interior (everything present has something to be for).

`γ` is a closure operator: extensive, monotone, idempotent. `Δ` is its order
dual — a kernel/interior operator: contractive, monotone, idempotent. Admissible
sets are the common fixed points.

**Why this is prescriptive and the old predicate was not.** Closure alone answers
one question — *what am I missing?* The kernel answers the question no one was
asking: *what am I carrying that I cannot justify?* An unwarranted mechanism is a
mechanism present with nothing to serve. In security terms that is attack surface
with no compensating function, and it is exactly the shape of a protocol that
accreted features. The atlas could never say this before because it had no
vocabulary for purpose.

## 3. The carrier: three layers, each earning its keep

Do not pick one. Each layer exists because the one below it provably cannot
express something we need.

**Layer 1 — mechanism sets, as up-sets of a poset.** OP-LOG's result: split the
laws into 8 definite Horn *productions* and everything else as *constraints*. The
definite fragment has **height 1** — bodies and heads are disjoint — so `Cn` is a
one-pass Galois closure and the closed sets are exactly the up-sets of a
54-point dependency poset.

By Birkhoff duality that lattice is completely determined by the poset. **We do
not need 29 laws; we need a partial order on 54 points.** It is completely
distributive, `⊔ = Cn(∪)`, `⊓ = intersection`, verified over 3,140 closed sets.
This recovers the meet I had recorded as permanently lost — that failure was a
fact about disjunction, not about the lattice.

**Layer 2 — mandates.** OP-LOG's second sort. A curator, a vault, a strategy is a
*policy over* mechanisms, not a mechanism. This is what makes non-monotonicity
**derived rather than asserted**: `{Ct,Im,Sh}` is a valid mandate; add `Li` and
it becomes a mechanism, which must then supply a truth source, and it fails. The
sort test explains the pathology instead of stipulating it.

**Layer 3 — instances.** OP-CAT's typed graph over sorts `El, Ast, Dom, Prt, Mnd`.
Needed for exactly two things, both of which Layer 1 provably cannot do:
Terra's reflexive cycle, and the USDT/USD1 fibre.

## 4. Two impossibility results that are actually true

These are the interesting ones, because two entrants proved *opposite* things and
both are right — the difference is exactly the scope decision the brief forced
them to make.

**Reflexivity needs asset indexing.** S5 survives three independent
confirmations: the requirement relation is a DAG with no self-loops, so no set
of element *types* can contain a cycle. Over `El × Ast` under `backs := reads ; over⁻¹`,
Terra is a 2-cycle — and crvUSD, with a comparable element set, has none. The
control is what makes it a result rather than a construction.

**Solvency is not a function of on-chain mechanism.** OP-LOG bounded scope to
on-chain state machines and derived `USDT ≡ USD1` as a **theorem**. OP-CAT
enriched the carrier with a party sort and separated them. Both are correct.
Together they give the sharp statement:

> No observation over on-chain mechanism sets separates USDT from USD1. The
> minimal enrichment that does is a party sort carrying obligor, attester and
> jurisdiction.

That is D2, refined and true. It is also the most consequential thing this
project can say: the fibre is not a modelling sloppiness to be tidied — it is a
theorem that mechanism inventory does not determine credit.

---

## 4b. Why validity is non-monotone: a proof, not an observation

GR-LOG's result, and it is the deepest thing the council produced. Read the laws
as clauses and the polarities are opposite:

| | clause shape | model class |
|---|---|---|
| requirement (`subject → alternatives`) | at most one negative literal — **dual-Horn** | **union**-closed |
| hazard (exclusion) | pure negative — **Horn** | **intersection**-closed |

`ADMISSIBLE = CLOSURE ∩ HAZARD-FREE` mixes the two, so by Schaefer/Post duality
it is provably a lattice under **neither** operation.

This is the reason, not the symptom. I had recorded non-monotonicity as an
empirical fact from the model checker and asked the council to "deal with it";
it is a theorem about clause polarity, and it was derivable from the shape of the
law language without running anything. It also settles T1 below: `γ` and `Δ` do
not commute, because they are closure operators of opposite polarity.

It sharpens §5b too. Feature models were rated a near-exact structural fit —
`requires` constraints are dual-Horn, `excludes` constraints are Horn, and that
split is precisely why feature-model validity moves in both directions at once.
The fit was closer than the survey knew.

**Encoding note, so nobody builds this wrong.** The clause classification above is right — `subject → (a|b|c)` is `¬subject ∨ a ∨ b ∨ c`, one negative literal, hence dual-Horn. But the obvious ASP encoding is *not*: `a :- b` is a **definite Horn** rule that derives `a`, and is Horn, not dual-Horn. The union-closed half of the profile is carried by **choice rules** `{a} :- b.`, not by definite rules. Encode as choice rules plus constraints.

**And it corrects my own benchmark.** I built the HYBRID family as a
contamination probe, on the reasoning that spliced protocols cannot have been
memorised. It is also — and mostly — a **union-closure detector**: a union-closed
model class must accept splices, because a splice of closed sets is closed. GR-LOG
admits 57.9% of hybrids and correctly calls this "a structural consequence of
union-closure, not a fixable bug". So the hybrid column ranks models by how
union-closed they are, not by how honest they are. OP-CAT at 21% and OP-ORD at
16% are not less contaminated than GR-LOG at 58%; they are less union-closed.

## 4c. The fragments, reconciled — and one functor for two problems

Three entrants said things that sound contradictory and are not. Sorted by
fragment, they are one coherent picture:

| fragment | clause shape | closure behaviour |
|---|---|---|
| definite productions (8 laws) | Horn, height 1 | up-sets of a poset — union **and** intersection closed, completely distributive |
| disjunctive requirements | dual-Horn | union-closed only |
| hazard exclusions | Horn (pure negative) | intersection-closed only |
| all three together | mixed polarity | **neither** — and not a Moore family |

So OP-LOG's beautiful distributive lattice is real *on the definite fragment*,
and GR-CAT's finding that the full closed-set family is **not a Moore family** —
hence admits no single-valued Galois closure operator, with Terra exhibiting four
incomparable minimal completions — is also real, on the whole system. The
well-behaved algebra lives in the Horn core; the disjunctions and the
prohibitions are what break it, exactly as §4b's polarity argument predicts.

**Design consequence, and it is the prescriptive one.** If you want a composable
algebra, work in the definite fragment and treat disjunctive requirements and
hazards as an outer filter. You get a real lattice with `⊓ = intersection`
inside, and you pay for it precisely at the boundary — which is a bounded,
nameable cost rather than a diffuse one.

**One functor for two problems.** GR-CAT's cleanest result: the forgetful functor
`U : DecProt → Sub(E)`, from instances typed by `(element, asset)` pairs down to
flat element sets, has both of our headline failures **in its kernel**. USDT ≡
USD1, and Terra's cycle is invisible — not two defects but one, the same
information destroyed by the same forgetting. Anything you want to fix in either
is fixed by refusing to apply `U`.

This also explains the hazard failures. GR-CAT attempted four hazard promotions
and **withdrew all four** after testing them against the 72 real decompositions:
`{Fl,Xm}` (our own model checker's prize) flags Aave v3; X19 flags 14 of 72 live
protocols. Every failure traces to the same root — a flat element-set carrier
cannot say *which instance* co-occurs with which. Only X18 survived, with zero
false positives.

**`{Fl, Xm}` is dead as a membership predicate.** The council split 3–3, but the
split is not symmetric: the three who promoted it did so because our FINDINGS
recommended it, and the three who killed it had *tested it against the corpus*.
Evidence beats provenance. The narrowing `Fl ∧ (Xf|Rl|Of)` survives; the flat
version does not.

## 4d. AFT is out — and my first two reasons were both wrong

Three passes. Worth keeping all three, because the final argument is the useful one.

**Pass 1 (wrong).** "Both operators are monotone, so neither fills AFT's antitone
slot." **Refutable in one line:** `≤_p`-monotonicity unpacks to `A¹` monotone in
arg 1 and antitone in arg 2, and antitonicity is satisfied **vacuously by
constancy** — so `A(x,y) = (Γ(x), Δ(y))` with both monotone *is* `≤_p`-monotone.
DMT (KR2002, Prop 4.7) states outright that for monotone `O` the ultimate
approximator **is** the product `(O(x), O(y))`.

**Pass 2 (right to reopen, wrong conclusion).** `U_O` exists for any operator
with no hypotheses, so the framework is not blocked by our operators' shape.

**Pass 3 — the real obstruction, and it is stronger and simpler than either.**
Every AFT variant requires `A` to preserve **consistency**: `lower ≤ upper`. Take
`A(x,x) = (Γ(x), Δ(x))`. Consistency forces `Γ(x) ≤ Δ(x)`. But `Γ` is a closure,
so `x ≤ Γ(x)`; and `Δ` is a kernel, so `Δ(x) ≤ x`. Chain them:

> `Γ(x) ≤ Δ(x) ≤ x ≤ Γ(x)`  ⟹  `Γ = Δ = id`.

This holds for **any** `A`, product-form or not, and needs neither exactness nor
monotonicity. **AFT's lower slot must *under*-approximate; a closure
*over*-approximates. The assignment is backwards.** Swapping to
`A(x,y) = (Δ(x), Γ(y))` is legal but empty: `lfp(Δ) = ⊥` always, so the stable
operator is a **constant map** and `Δ` never appears in the answer.

**And that is exactly why candidate 1 is the right next move.** The obstruction
names our structure precisely: `Γ` is *inflationary* (`x ≤ Γ(x)`) and `Δ` is
*deflationary* (`Δ(x) ≤ x`). They point in opposite directions **relative to the
identity**, which is the diagonal picture stated algebraically. The theory of
`Fix(Γ) ∩ Fix(Δ)` for an inflationary and a deflationary map is common
fixed-point theory — not approximation theory, which wants both bounds on *one*
operator.

One escape hatch exists and does not save it: Charalambidis/Rondogiannis/Symeonidou
2018 and Vanbesien/Bogaerts/Denecker 2025 drop exactness entirely, but their
interlattice conditions still force `lower ⪯ upper`, so the polarity obstruction
survives. No non-monotone AFT variant exists.

## 5. Theorems worth proving

Ordered by what I would actually want to know.

**T1 — ANSWERED, by GR-LOG. They do not commute, and the reason is polarity.**
See §4b above. What remains is the quantitative version: the obstruction is a
finite computable set, so *enumerate it*. Which admissible sets fail to be fixed
points of both operators, and how many are there? That converts a structural
impossibility into a bounded list of exceptions.

**T2 — The congruence fragment.**
OP-LOG refuted X3: `⊕` is not a congruence for validity, with witnesses on all
four closures. Turn it around: *find the largest sublattice on which it is.*
This is the practically useful theorem — it says exactly which protocols compose
without re-analysis, which is the entire promise of composability.

**T3 — Birkhoff reduction.**
If Layer 1's closed sets are the up-sets of a 54-point poset, then the 29 laws
are redundant and the real object is that poset. Prove the reduction and exhibit
the Hasse diagram. **This would replace the law list with a partial order** — and
a partial order is drawable, which the law list never was.

**T4 — Warrant completeness, and the generator split.**
Conjecture: the elements with **no** warrant are exactly the primitive
generators. 27 of 58 have derived warrants; OP-LOG's typing gives 31 generators
and 27 dependents. If those two partitions coincide, C3 (independence) falls out
of the warrant structure for free rather than needing 58 separate proofs.

**T5 — Bound the non-monotone damage.**
OP-CAT: 4 of 44 conjuncts are non-monotone, so 91% of the algebra survives
composition. Prove the non-monotone part is exactly the fragment with
*conjunctive antecedents* — X19 is the witness — and that everything else is
union-closed. Then non-monotonicity is quarantined rather than pervasive.

**T6 — The scope dichotomy, stated once.**
Formalise §4: any algebra over on-chain mechanism sets satisfies `USDT ≡ USD1`;
any algebra separating them contains a party sort. No middle position exists.

---

## 6. What this makes the visualization

The model finally gives the atlas something to *do*, which is what it has been
missing since the first build. Four questions, each with a computable answer:

1. **What am I missing?** — closure. Already have it.
2. **What can I not justify?** — warrant. New, and the interesting one.
3. **What can I safely compose with?** — the T2 congruence fragment.
4. **What is unbuildable?** — hazards, corrected.

And T3 says the law list should be redrawn as a **54-point poset**, which is a
Hasse diagram — orderable, layerable, and finally an honest replacement for the
stratum column that two independent methods now say was never a rank.

===== END FILE =====

===== FILE algebra/THEOREM-LEDGER.md | SHA256 16fa3d924c599cd7d92358e34fda2bc36c869b3ba384417d877d26daf4cf153e =====
# Current scope correction (2026-09-06)

Retain this chronological ledger as evidence of the original program. The
[claim disposition](../docs/research/semantic-kernel-claim-disposition.md)
governs new citations: distinguish set-operation closure from induced lattice
structure, syntactic independence from semantic minimality, and bounded checks
from structural proofs and their concrete-instance correspondence.

---

# Theorem ledger

**The authoritative record.** Everything proved, refuted, contested or open across
the nine-model council and our own model checking. `MODEL.md` explains the model;
`THEOREMS.md` states the acceptance obligations; **this file is the running score
and nothing may be dropped from it.**

Rules: a refutation with a witness is a *result*, not a failure. Every entry
carries who established it and what the evidence was. Contested entries stay
contested until adjudicated — no silent resolution.

---

## PROVED

| # | Statement | By | Evidence |
|---|---|---|---|
| **P1** | **Requirement clauses are dual-Horn (≤1 negative literal) so their model class is union-closed; hazard exclusions are pure-negative Horn so theirs is intersection-closed; `ADMISSIBLE` mixes the polarities and is provably a lattice under neither.** | GR-LOG | Schaefer/Post duality. Derivable from the law language without execution. |
| **P2** | The definite fragment (8 laws) has height 1 — bodies and heads disjoint — so `Cn` is a one-pass Galois closure and closed sets are exactly the up-sets of a 54-point poset: a completely distributive lattice with `⊔ = Cn(∪)`, `⊓ = ∩`. | OP-LOG | machine-checked over 3,140 closed sets; assoc/comm/idem/absorption/distributivity all hold |
| **P3** | **DOWNGRADED — the construction holds, the claim about it does not.** Requirements and warrants do form an adjoint pair and the 27 warrant rows are real. But `Γ ∧ Δ` scores **4.46×**, *below* the 5.79× independence predicts — they are sub-multiplicative — and over half of the headline 10.83× comes from Ban+Cond and Ground, blocks never credited. Warrant is worth ~1.8× over closure, not 4.4×. **And `Δ` is not idempotent, so it is not a kernel operator.** | OP-ORD (numbers), Quint v2 (refutation) | every ablation cell reproduced to the digit; the causal story did not |
| **P4** | The requirement relation over all 58 elements is a DAG with no self-loops, so **no set of element types can contain a cycle**. | Quint + OP-CAT + GP-ORD + GR-CAT | four independent confirmations |
| **P5** | Terra's collapse *is* a 2-cycle over `(element, asset)` under `backs := reads ; over⁻¹` — and crvUSD, comparable element set, has none. | OP-CAT | computed, with control |
| **P6** | USDT and USD1 separate under a party sort: their `attests-to` edges point at different `Prt` nodes. | OP-CAT | constructive |
| **P7** | Under scope bounded to on-chain state machines, **`USDT ≡ USD1` is a theorem**. | OP-LOG | derived under the fixed observation map |
| **P8** | The forgetful functor `U : DecProt → Sub(E)` has **both** the non-injectivity and the reflexivity-invisibility in its kernel — one phenomenon, not two. | GR-CAT | unifies P5–P7 |
| **P9** | The full closed-set family is union-closed but **not a Moore family**, so no single-valued Galois closure operator exists over it. Terra has four incomparable minimal completions. | GR-CAT | consistent with P1/P2 — the Horn core is well-behaved, the mixture is not |
| **P10** | **`⊕` is not a congruence for validity** — refuted on all four closures with witnesses. (Discharges obligation X3 by refutation.) | OP-LOG | explicit witnesses |
| **P11** | Stratum **is** derivable — not as law-graph rank (3/58) but as the maximal sort of the typing functor (**57/58**, `Pm` the sole exception). | OP-CAT | the `Gs→Au` inversion dissolves; sort powerset is not linearly ordered |
| **P12** | `X11a`'s polarity is inverted, and `Uc` is **realizable** — subsumed by L3 under closure. Our "zero hazard-free completion" was a projection bug. | OP-CAT, OP-LOG, GP-ORD, GR-LOG, GR-CAT | five of nine, unanimous among those who ruled |
| **P13** | HYBRID acceptance is a **structural consequence of union-closure**, not a contamination signal: a union-closed model class must accept splices. | GR-LOG | corrects our own benchmark design |
| **P14** | The reference parser treated mixed terms (`Tg \| bounded emergency process`) as hard element requirements, dropping the prose disjunct. Five terms; `L15` alone rejected 25 of 72 live protocols. Closure **6/12 → 9/12**. | OP-ORD, OP-LOG; verified in our own code | Lido, Centrifuge, Euler all close once fixed |

## REFUTED / DEAD

| # | Claim | Why it died |
|---|---|---|
| **R1** | `{Fl, Xm}` as a flat membership hazard — our model checker's "prize" | Flags **Aave v3**. Council split 3–3, but asymmetric: the three who promoted it followed our FINDINGS, the three who killed it *tested against the 72-protocol corpus*. Evidence beats provenance. The narrowing `Fl ∧ (Xf\|Rl\|Of)` survives. |
| **R2** | "Meet is not intersection" as a general fact | True only outside the definite fragment (P2). |
| **R3** | "Stratum is not derivable" as a general fact | True only for law-graph rank (P11). |
| **R4** | "Euler fails closure for a reason unrelated to why it died" | Our parser bug (P14). Euler had a bounded emergency process; L15 permits either. |
| **R7** | AFT as our framework | **REINSTATED, with the correct proof.** Not the antitone-slot argument (wrong) but the consistency/polarity argument: inflationary closure and deflationary kernel cannot occupy AFT's lower/upper slots without collapsing both to the identity. *Earlier note:* WITHDRAWN. See T0 — the refutation was of one construction, not the framework. The genuine risk is informativeness (`U_O` can return `(⊥,⊤)`), not applicability. Two independent obstructions (AFT, bilattices) with the same cause: validity is a diagonal, and componentwise structures cannot see diagonals. |
| **R8** | `{Fl, Xm}` dies because it fires on Aave v3 | It dies on **warrant** — neither element has anything to be *for*, so `Δ` would have killed it on day one. But the atomic-scope family is **sharpened, not killed**: 78 of 81 minimal witnesses are admissible, arm no listed hazard, and appear in **none of the 72 live protocols**, all of shape `{w_Fl, Fl, Xm, w_Xm}`. There IS an unlisted hazard family; it is not the flat pair. |
| **R9** | OP-LOG's definite fragment is 8 rules over 3,140 closed sets | It is **16 rules**, and two of OP-LOG's eight (`Rs→Vl`, `Ad→Li`) **appear in no law text**. The lattice has ~2.2×10¹⁵ elements; 3,140 was a corpus sample, not the lattice. Height-1 itself is independently confirmed. |
| **R6** | Bilattices as the home for two opposite polarities | Refuted by the theorem we hoped would help. Avron Thm 3.3: every interlaced bilattice is isomorphic to a componentwise product `L⊙R`, uniquely. Setting `L = Fix(Γ)`, `R = Fix(Δ)` gives pairs *(closed set, open set)* with no constraint that the coordinates agree — our validity set is the **diagonal**, and the representation theorem makes the structure componentwise and therefore blind to it. It would also make validity a lattice under *both* orders, where P1 says neither. **Keep the carrier `L²`; drop the framework.** |
| **R5** | "Two independent implementations agree" as verification of closure | Quint was built from the same spec and reproduced the same bug. Shared spec error, not confirmation. |

## OPEN — the work to do

Ordered by value. **T2 is the one that matters most.**

| # | Statement to prove | Why |
|---|---|---|
| **T2** | **PARTIAL ANSWER, and it is usable.** A union-closed fragment `F` covering **47.8% of admissible sets certifies 59% of live protocol pairs with zero errors** — compositional checking is sound there. Caveat: `F` is a **join-semilattice, not a sublattice**, and maximality is open in [11026, 23055). *Original:* **Find the largest sublattice on which `⊕` IS a congruence.** **CANDIDATE ANSWER: the stratifiable fragment.** Vennekens–Gilis–Denecker, Def. 3.3 / Thm. 3.5: an operator `O` is *stratifiable* iff `∀x,y,i: x|⪯i = y|⪯i ⟹ O(x)|⪯i = O(y)|⪯i`, and then `x` is a fixpoint of `O` **iff** each `x(i)` is a fixpoint of `O_i^{x|≺i}`. It is an **iff**, so composition-preserves-validity is exactly stratifiability, and our counterexamples should be exactly the non-stratifiable compositions. **Verify this.** | P10 refuted congruence in general. This turns the negative into the practically useful positive: it names exactly which protocols compose without re-analysis, which is the entire promise of composability. |
| ~~**T0**~~ | **CLOSED: AFT is out, on the third and correct argument.** Consistency forces `lower ≤ upper`; `Γ` inflationary and `Δ` deflationary then chain to `Γ = Δ = id`. Holds for any `A`, needs neither exactness nor monotonicity — **AFT's lower slot must under-approximate and a closure over-approximates; the assignment is backwards.** My first argument (antitone slot) is refutable by DMT Prop 4.7; my second (reopening) was right to reopen and wrong to conclude. *Superseded:* REOPENED — I closed this too early. Building `A` from `Γ` and `Δ` collapses componentwise, but that kills one construction, not the framework: `U_O` exists for *any* operator in closed form with no hypotheses, the antitone slot is definitional to approximators rather than demanded of ingredients, and splitting needs no approximator at all. **New decisive test: brute-force `U_O` on the smallest known-answer instance — if `WF ≠ (⊥,⊤)`, AFT is live.** *Superseded text:* ANSWERED: NO. `Γ` and `Δ` are both monotone, so neither fills AFT's antitone slot and any `A` collapses to a componentwise product — the same obstruction that killed bilattices. Stratifiability ≠ union-closure (`Pl ∧ Of → Ct`). AFT does not transfer. *Original text:* **The AFT go/no-go, and do it before committing.** AFT's two components are the lower and upper bound of **one** operator; our `Γ` and `Δ` are two **different** operators. The shapes coincide, the meanings may not. Concretely: **can we define `A(x,y)` from `Γ` and `Δ` that is `≤_p`-monotone?** Yes → we inherit three semantics plus the splitting theorem, and T2 falls out. No → AFT gives us nothing and the resemblance was cosmetic. This is a decidable check and it gates everything above. |
| **T1′** | Enumerate the `γ`/`Δ` non-commutation obstruction. P1 proves they do not commute; the obstruction is finite and computable. | Converts a structural impossibility into a bounded exception list. |
| **T3** | **Birkhoff reduction:** prove the 29 laws are redundant and the real object is the 54-point poset; exhibit its Hasse diagram. | Would replace the law list with a partial order — and a partial order is *drawable*, which the law list never was. |
| **T4** | Warrant completeness: are the elements with **no** warrant exactly the primitive generators? (P3 gives 27 warrants; OP-LOG's typing gives 31 generators / 27 dependents.) | If the partitions coincide, independence (C3) falls out for free instead of needing 58 proofs. |
| **T5** | Prove the non-monotone part is exactly the conjunctive-antecedent fragment (X19 the witness) and everything else is union-closed. | Quarantines non-monotonicity instead of letting it be pervasive. OP-CAT measured 4 of 44 conjuncts. |
| **T6** | **The scope dichotomy:** any algebra over on-chain mechanism sets satisfies `USDT ≡ USD1`; any algebra separating them contains a party sort; no middle position exists. | Formalises P6+P7 into one statement. The most consequential claim available: **mechanism inventory does not determine credit.** |
| **T7** | Is `El × Ast` the *minimal* enrichment expressing reflexivity? | P5 shows it suffices. Minimality is unproven. |
| **T8** | Does "definite-fragment lattice + outer filter" yield a decidable composability check with stated complexity? | The engineering payoff of P1/P2/P9. |

## CONTESTED — do not resolve silently

| # | Question | Positions |
|---|---|---|
| **K1** | **The minimal generating set.** | OP-CAT: 56, `St`/`Wg` collapse. GR-ORD: **zero** type-level redundancy over 83 protocols; only 4 ungrounded symbols (`Wg,Cv,Sb,Sd`). GR-LOG: 4 clause-redundant pairs (`{Sh,Ix},{Rf,Ba},{Im,Op},{Rd,Ps}`). OP-ORD: 10 reducible attributes, cut `Gs`. **Unresolved — these use different equivalences and must be compared on a common one.** |
| **K2** | Is there a single-valued closure operator over the full family? | OP-ORD constructs one via the Galois adjoint; GR-CAT proves the family is not Moore. Likely different families — needs stating precisely. |
| **K3** | Promote `X19` (`Xf → Aw`) to a positive law? | GR-ORD yes (restores union-closure). GR-CAT no — flags 14 of 72 live protocols. GP-ORD declines on cost. |
| **K4** | **Is `⊕` a congruence?** GP-CAT *proves* it; OP-LOG *refutes* it with witnesses on all four closures. | Almost certainly two different statements, and the distinction matters more than either result. BRIEF §2 defines `≃` by quantifying over **all** contexts, which makes `≃`-congruence true by construction — GP-CAT derives exactly that from `⊕` being total plus associativity. OP-LOG's refutation is about **validity**: `⊨a` and `⊨b` do not give `⊨(a ⊕ b)`. So observational equivalence is preserved by composition and *admissibility is not*. **Resolve by stating both separately in T2, and never write "congruence" unqualified again.** |

---

## Provenance note

Two entrants disclosed things that cost them score, and both disclosures were
correct and load-bearing: OP-ORD reported the blind-set leak unprompted and gave
its uncalibrated 6.88× beside its calibrated 10.83×; OP-LOG declined a cheap
67.7% rejection rate because it was "a lookup table with no sentence attached to
any clause." GR-CAT withdrew all four of its own hazard promotions after testing
them. Record this — it is why P12, P13 and R1 are trustworthy.

===== END FILE =====

===== FILE algebra/research/structures-round2.md | SHA256 856a4bfa1d91ccb7be3d58056406f02cf65dbe74a9a2d5594e83ef25990f8949 =====
# Structures, round 2 — matched against the measured six-point profile

Scope: structures the first survey (feature models, assume-guarantee contracts, FCA, open games, decorated cospans, institutions, semirings) missed. Judged against the measured profile, not against "DeFi".

**Method note / honesty caveat.** The session's WebSearch budget was exhausted at the outset, so every source below was reached by direct WebFetch of primary URLs, with DuckDuckGo's HTML endpoint used as a search proxy until it began returning 403. Several primary PDFs (O'Hearn–Pym 1999, Pawlak 1982, Calcagno–O'Hearn–Yang, the AFT lecture notes) could not be text-extracted. Everything unconfirmed is flagged inline and collected in the final section. No theorem below is stated from memory without a flag.

Recurring shorthand: **Γ** = the requirement closure operator, **Δ** = the "what is this element for" kernel/interior operator, **P1–P6** = the six profile points.

---

## 0. The finding that reframes P1 — your system is probably bijunctive, and the object you are missing is a median algebra

This is not one of the candidates you listed. It is the thing I would act on first, and it is cheap to check.

**Verified.** Schaefer's dichotomy gives six tractable polymorphisms; the relevant three are: Horn ⟺ closed under binary **min** (∧), dual-Horn ⟺ closed under binary **max** (∨), bijunctive (2-SAT-definable) ⟺ closed under the ternary **majority** operation `maj(x,y,z) = (x∧y)∨(x∧z)∨(y∧z)`. (Schaefer, "The complexity of satisfiability problems", STOC 1978; polymorphism restatement confirmed at <https://en.wikipedia.org/wiki/Schaefer%27s_dichotomy_theorem>.)

Now look at your two clause shapes:

- A requirement "X needs Y" over a **binary** requirement relation is `¬X ∨ Y` — a 2-clause.
- A prohibition "X and Y must never co-occur" is `¬X ∨ ¬Y` — a 2-clause.

If both are binary, the entire constraint system is **2-SAT**, i.e. bijunctive. You told me the requirement relation is a DAG — a *binary* relation. So the requirement side is binary by your own construction.

**Verified consequence.** The solution set of a 2-SAT instance is closed under coordinatewise majority and carries the structure of a **median graph**: "The set of all solutions to a 2-satisfiability instance has the structure of a median graph… The median of any three solutions is formed by setting each variable to the value it holds in the majority of the three solutions. This median always forms another solution to the instance." (<https://en.wikipedia.org/wiki/2-satisfiability>, "The set of all solutions", citing Bandelt & Chepoi 2008 and Chung, Graham & Saks 1989. I reached the primaries only through this citation — see final section.)

**Why this matters more than anything else in this document.** Your P1 says validity is "a lattice under neither" polarity. That is correct and it is also *only the negative half of the statement*. The positive half is that a family closed under neither min nor max can still be closed under **majority** — and majority-closed subsets of the Boolean cube are exactly **median algebras**, a genuinely rich structure (Isbell; Bandelt–Hedlíková; equivalent to CAT(0) cube complexes; retracts of hypercubes) with canonical representation theory, a convexity theory, and linear-time algorithmics. You have been looking for a weakening of "lattice" in the direction of category theory. The weakening you actually need is one step sideways in universal algebra: **lattice → median algebra**. A distributive lattice is a median algebra (with `maj(x,y,z) = (x∧y)∨(x∧z)∨(y∧z)`); median algebras are what survives when you drop the two binary operations and keep only the ternary one. That is *precisely* the "closed under neither ∧ nor ∨" situation.

**The sharp dichotomy this creates, and the one question you must answer.** It turns entirely on the **arity of the consequent** — i.e. on Δ, and on whether a requirement can be satisfied by *any one of several* alternatives.

- **Arity 1 (single-valued purpose).** Each element serves one designated thing, so Δ is `¬x ∨ y` and Γ is `¬x ∨ y`; prohibitions are `¬x ∨ ¬y`. Every clause is a 2-clause, so the system is **bijunctive**. Validity is a **median algebra**; satisfiability and structure enumeration are **linear time**. Note this is bijunctive, *not* the smaller class `IM2` discussed below: `(¬x ∨ ¬y)` has two negative literals so it is not an implication, and prohibitions therefore sit in `ID2 ∖ IM2`.
- **Arity ≥ 2 (disjunctive purpose).** "Element x is allowed only if *any one of* y₁…y_k is present" is `¬x ∨ y₁ ∨ … ∨ y_k` with `k ≥ 2`. **Verified**: this relation is dual-Horn but **not bijunctive** — witness `(1,0,1), (1,1,0), (0,0,0)` are all models of `¬x ∨ y₁ ∨ y₂` but their coordinatewise majority `(1,0,0)` is not, so `maj` is not a polymorphism. Combined with prohibitions `(¬x ∨ ¬y)`, which are Horn and bijunctive but **not** dual-Horn, the language lies in none of Schaefer's tractable cases (not Horn, not dual-Horn, not bijunctive, not affine), so **SAT is NP-complete**. The direct witness is stark: **graph k-colourability is exactly your profile** — variables `x_{v,c}`, requirement clauses `⋁_c x_{v,c}` (all-positive, dual-Horn), prohibition clauses `¬x_{u,c} ∨ ¬x_{v,c}` per edge (Horn). "Can I extend this to a valid configuration" *is* graph colouring. (Schaefer, STOC 1978, <https://dl.acm.org/doi/10.1145/800133.804350>.)

So: **is an element's purpose single-valued or disjunctive?** That one modelling decision determines whether your object is a median algebra with linear-time algorithms or an NP-complete constraint system with no structure theory at all. Nothing else in this document is as consequential.

Note that P3 (non-monotonicity) is *entirely consistent* with bijunctivity — 2-SAT solution sets are not upward closed, and majority-closure says nothing about monotonicity. **P1 and P3 together are the signature of a median algebra, not an obstruction to one.**

### The related trap: two different objects you may be conflating

This came out of the clone-theoretic lane and is worth stating separately, because the distinction is easy to lose and one half of it is tractable.

- **A family closed under both ∪ and ∩** is a sublattice of `2^E`, hence *distributive*, hence Birkhoff-representable. **Verified**: the co-clone `Inv({∧,∨})` is `IM2`, whose **plain base is exactly `{(x), (¬x), (¬x ∨ y)}`** — unit clauses and implications, nothing else (Creignou, Kolaitis & Zanuttini, "Structure identification of Boolean relations and plain bases for co-clones", *JCSS* 74(7) 2008, Table 2; <https://users.soe.ucsc.edu/~kolaitis/bio11/papers11/jcss08-creignou.pdf>). Equivalently: such a family is the family of **up-sets of a quasi-order on the elements**, restricted by fixed literals. That is the Birkhoff picture in logical clothing. Note `IM2 ⊊ ID2 = bijunctive`, since `maj` is built from `∧` and `∨` — Horn-∧-dual-Horn is *strictly stronger* than 2-SAT.
- **The intersection of a ∪-closed family with a ∩-closed family** — which is what you actually have — is `Mod(dual-Horn ∧ Horn)`, closed under **neither**, carrying **no polymorphism and therefore no structure theory**. There is **no name for this in the literature**, and the lane searched for one. The reason there is no name is that in clone theory the object is degenerate: `Inv(∅)`.

Your P1 is therefore right but understated. It is not merely "not a lattice"; with disjunctive requirements it is the *structureless* case. Your escape hatch — and it is the only lattice-theoretic one — is to give up multi-consequent requirements and land in `IM2`, where everything is distributive, poly-time and Birkhoff-representable. The middle road is arity-1 requirements *with* prohibitions, which lands in bijunctive/median. **Three regimes, and you get to choose which one you model in.**

---

## 1. Approximation Fixpoint Theory (Denecker–Marek–Truszczyński) — the strongest single candidate

Not on your list. It is the algebraic theory that sits underneath three of the things you *did* list (bilattices, ASP, default logic) and it was built to solve exactly your P2 and P3.

**Definition (verified).** AFT works on the bilattice `L²` of *approximations* — pairs `(x, y)` read as lower and upper bounds — ordered by the **precision order** `(a₁,a₂) ≤_p (b₁,b₂)` iff `a₁ ≤ b₁` and `a₂ ≥ b₂`. An **approximator** `A : L² → L²` approximates an operator `O` on `L`; it is *exact* when `A(a,a) = (O(a), O(a))`, and *consistent* when it maps consistent pairs (`a ≤ b`) to consistent pairs. (Definitions confirmed from the restatement in "A Category-Theoretic Perspective on Approximation Fixpoint Theory", <https://arxiv.org/pdf/2502.09234>; I could not text-extract the DMT originals — see final section.)

**The property that makes this the candidate.** *A is required to be monotone with respect to ≤_p even when the underlying operator O on L is non-monotone.* That is the whole trick: AFT does not tolerate non-monotonicity, it **converts** it — a non-monotone operator on `L` is replaced by a monotone operator on `L²`, so Knaster–Tarski applies and you get a canonical least fixpoint back. From one approximator you get three semantics uniformly: the **Kripke–Kleene** fixpoint (least fixpoint of `A` under `≤_p`), the **stable** operator, and the **well-founded** fixpoint.

**Verified theorem (abstract quoted verbatim).** Denecker, Marek & Truszczyński, "Ultimate approximations in nonmonotonic knowledge representation systems", <https://arxiv.org/abs/cs/0205014> (journal version: *Information and Computation* 192(1), 2004):

> "We study fixpoints of operators on lattices. To this end we introduce the notion of an approximation of an operator. We order approximations by means of a precision ordering. We show that each lattice operator O has a unique most precise or ultimate approximation. We demonstrate that fixpoints of this ultimate approximation provide useful insights into fixpoints of the operator O. We apply our theory to logic programming and introduce the ultimate Kripke-Kleene, well-founded and stable semantics. We show that the ultimate Kripke-Kleene and well-founded semantics are more precise then their standard counterparts We argue that ultimate semantics for logic programming have attractive epistemological properties and that, while in general they are computationally more complex than the standard semantics, for many classes of theories, their complexity is no worse."

The **ultimate approximation** result is the one to lean on: you do not have to invent an approximator for your Γ/Δ system: *every* lattice operator has a canonical most-precise one.

**Composition — and this is the part that speaks directly to P4.** Vennekens, Gilis & Denecker, "Splitting an operator: Algebraic modularity results for logics with fixpoint semantics", <https://arxiv.org/abs/cs/0405002> (ACM TOCL, 2006). Verified from the abstract page: it presents "a general, algebraic splitting theory for logics with a fixpoint semantics", dividing programs "into distinct computational levels" so that "models of the entire program can be constructed by incrementally constructing models for each level", and it generalises the splitting results for logic programming, autoepistemic logic and default logic under a single approximation-theoretic roof.

**The formal statements are now verified from the v2 PDF, and they are stronger than the abstract suggests:**

> **Definition 3.3.** An operator `O` on a product lattice `L` is **stratifiable** iff `∀x,y ∈ L, ∀i ∈ I`: if `x|⪯i = y|⪯i` then `O(x)|⪯i = O(y)|⪯i`.
>
> **Proposition 3.4.** Stratifiability is equivalent to the existence, for each `i` and each `u ∈ L|≺i`, of a unique component operator `O_i^u` on `L_i` with `(O(x))(i) = O_i^u(x(i))` whenever `x|≺i = u`.
>
> **Theorem 3.5.** `x` is a fixpoint of `O` **iff** `∀i ∈ I`: `x(i)` is a fixpoint of `O_i^{x|≺i}`.

Propositions 3.6/3.7 lift this to least fixpoints for monotone `O`. §4.1.3 states explicitly that Lifschitz & Turner (1994) proved a splitting theorem for logic programs under stable model semantics, that Eiter et al. (1997) obtained similar results independently, and that VGD are more general in also covering supported, Kripke–Kleene and well-founded semantics.

**This is your P4 and P5 in one theorem, and it is a characterisation rather than an obstacle.** Theorem 3.5 is an **iff**: fixpoints decompose across a split **exactly when** the operator is stratifiable, and Definition 3.3 says stratifiability means lower strata do not depend on higher ones — i.e. **no cyclic dependency across the interface**. So P4 (composition does not preserve validity) is neither a defect of the framework nor a brute empirical fact: **it is the failure of Definition 3.3, and your witnesses are precisely the non-stratifiable compositions.** P5 explains *why* they are non-stratifiable — the `backs` relation cycles at the instance level, invisibly to the type-level DAG. One citable algebraic account of both points, and no other candidate in this document produces one.

**Where it stands on the six points.**
- **P1** — partial. AFT does not itself supply two opposite-polarity closure operators; it supplies the bilattice `L²` in which a lower and an upper operator live *independently* (unlike rough sets, where they are forced duals). Your Γ and Δ are naturally the two components of an approximator.
- **P2** — strong. "Common fixed points of a closure and a kernel" is literally a fixpoint of an operator on `L²`. This is the native object.
- **P3** — strong, and uniquely so. This is the only candidate that handles non-monotonicity by construction rather than by accident.
- **P4** — strong, as an *explanation*: the splitting theorem tells you precisely when composition preserves and why yours does not.
- **P5** — neutral. AFT is agnostic about the carrier lattice; put `(element, asset)` instances in `L` and it does not object, but it contributes nothing to detecting the cycle.
- **P6** — fails. No sort structure.

**Decidability & tooling.** Stable-model reasoning for normal programs is NP-complete territory; DMT note ultimate semantics are "in general computationally more complex than the standard semantics" though "for many classes of theories, their complexity is no worse" (quoted above). Tooling is real and maintained: **IDP-Z3**, a KU Leuven knowledge-base engine implementing **FO(·)/FO-dot**, extending first-order logic with "types, aggregates, inductive definitions, bounded arithmetic, partial functions" (<https://www.idp-z3.be/>, docs at <https://docs.idp-z3.be/>), plus clingo/Potassco on the ASP side. The inductive-definition semantics of FO(ID) is the AFT well-founded fixpoint — *I did not confirm that link on the pages I fetched*.

**Verdict: AFT fits P2, P3 and P4 better than anything else surveyed in either round, is neutral on P1 and P5, and fails P6. It is the only candidate whose central theorem explains your measured non-preservation rather than contradicting it.**

---

## 2. Abstract Dialectical Frameworks (Brewka & Woltran) — AFT with your two polarities already built in

Also not on your list, and it is the concrete instance of AFT you want.

**Definition (verified).** An ADF is `D = (S, L, C)` with `S` statements, `L ⊆ S × S` links, and `C` assigning each statement `s` an **acceptance condition** `C_s`, a Boolean function over the parents of `s`. (Brewka, Ellmauthaler, Strass, Wallner & Woltran, "Abstract Dialectical Frameworks Revisited", IJCAI 2013, <https://www.ijcai.org/Proceedings/13/Papers/125.pdf>.)

**The two polarities are native and independent.** In bipolar ADFs links are classified into four kinds — **attacking**, **supporting**, **redundant**, and **dependent** — and a single link may be attacking, supporting, both, or neither, depending on how the acceptance condition uses that parent. This is exactly your requirement/prohibition split, not forced into a de Morgan duality (contrast rough sets, §5) and not collapsed into a single polarity (contrast Petri nets, §7). "X needs Y" and "X and Y never co-occur" are both just clauses in `C_X`.

**Non-monotonicity is native, by the AFT mechanism.** Verified from the IJCAI paper: the characteristic operator `Γ_D` on three-valued interpretations "is monotone with respect to the information order even though acceptance" conditions are arbitrary Boolean functions and hence individually non-monotone. Semantics: complete = fixpoints of `Γ_D`, grounded = least complete, preferred = maximal complete, plus admissible and stable.

**The AFT link is a published theorem, not my inference.** Strass, "Approximating operators and semantics for abstract dialectical frameworks", *Artificial Intelligence* (2013), <https://doi.org/10.1016/j.artint.2013.09.004> — verified as giving "a principled and uniform reconstruction of the semantics of abstract dialectical frameworks by embedding them into the approximation operator framework of Denecker, Marek and Truszczynski", and showing many Dung-AF and ADF semantics arise as "direct applications" of AFT.

**Six points.** P1 ✔ (native, independent). P2 ✔ (via AFT). P3 ✔ (native). P4 — no composition theorem found; ADFs inherit AFT's splitting, *unverified*. P5 ✘ (flat statement set; you would index by hand). P6 ✘ (no sorts).

**Decidability & tooling.** ADF reasoning is "one level up in the polynomial hierarchy compared to AFs" (verified phrasing; exact per-semantics bounds *unverified* — an earlier fetch returned a "PSPACE-complete" claim I believe to be a summariser artefact and am discarding). Solvers exist (DIAMOND, YADF, k++ADF, QADF) — *I did not verify their current maintenance status*.

**Verdict: ADFs fit P1, P2 and P3 natively and fail P5 and P6. If you want a running implementation of the closure+kernel model tomorrow, this is the shortest path; it is AFT with the bipolarity pre-installed.**

---

## 2b. Answer set programming — passes P1, P2, P3, P5; and its P4 story is AFT's

**The reduct (verbatim,** Lifschitz, *Twelve Definitions of a Stable Model*, <https://www.cs.utexas.edu/~vl/papers/12defs.pdf>, §5 "Definition C"**).** The reduct of Π relative to a set `M` of atoms is obtained from Π by grounding, then *(i) dropping each rule containing a term `not A_i` with `A_i ∈ M`, and (ii) dropping the negative parts `not A_{m+1},…,not A_n` from the bodies of the remaining rules.* `M` is a stable model iff the minimal model of the reduct w.r.t. `M` equals `M`. Attributed to Gelfond & Lifschitz 1988, independently invented by Fine 1989.

**Correct your framing of the two polarities — this matters.** You wrote that requirements are rules and prohibitions are constraints. Half right. `a :- b` is a **definite Horn** rule: it *derives* `a`; it is not dual-Horn. Integrity constraints `:- a, b.` are exactly your prohibitions. But if "X needs Y" is a *constraint on admissible sets* rather than a derivation, its ASP form is `:- x, not y.` — also a constraint. The union-closed/generative half of your profile is carried by **choice rules** `{a} :- b.`, not by `a :- b`. So ASP does hold both polarities in one program, but the mapping is **choice rules + constraints**, not rules + constraints. Anyone who tells you "requirements are rules, prohibitions are constraints" has conflated derivation with admissibility, and will build the wrong encoding.

**Non-monotonicity (P3): native and exact.** Adding `a` to a candidate `M` changes the reduct — clause (i) deletes rules — so the minimal model of the reduct is not monotone in `M`. "Adding an element satisfies a requirement and arms a prohibition simultaneously" is the textbook shape of this.

**Stratification.** Same source, §2.2, verbatim: stratified = programs in which "recursion and negation *don't mix*"; the semantics is the **iterated least fixpoint**, and "to prove the soundness of this definition one needs to show that this fixpoint doesn't depend on the choice of a stratification." Stable model semantics is presented as a generalisation and simplification of that. The standard corollary — every stratified normal program has exactly one stable model, its perfect model — is *standard but was not quoted from a primary source this session*.

**P5 comes for free.** First-order ASP with variables grounds over instances, so `backs(E,A)` plus a recursive reachability predicate detects cycles over `(element, asset)` pairs even though the type-level requirement relation is a DAG. The cycle detector is a *positive* recursive definition, hence stratified below the negation layer — no semantic cost.

**P6 is the weak spot.** ASP is many-sorted only by convention. A "policy over mechanisms" requires **reification**: naming mechanisms as terms and writing meta-rules over those names (clingo's meta-programming / `--output=reify`). Workable, ugly, not native.

**Tooling** is the most mature of any candidate here: clingo/gringo/clasp (Potassco) and DLV. Complexity (NP-complete for normal, Σ₂ᵖ-complete for disjunctive) is standard but *was not verified from a primary source this session*.

**Verdict: ASP handles P1, P2, P3 and P5 natively, needs reification for P6, and its P4 behaviour is exactly AFT's — composition preserves stable models only under the stratifiability side condition of VGD Definition 3.3, which is what your witnesses violate. This is the pragmatic implementation route; AFT is the theory of why it behaves as it does.**

---

## 2c. Bilattices — refuted by the representation theorem you hoped would help

You thought the two independent axes might fit. The theorem that makes bilattices tractable is the same theorem that disqualifies them.

**Definition (verified,** Avron, *The Structure of Interlaced Bilattices*, <https://www.cs.tau.ac.il/~aa/articles/interlaced.pdf>, Def. 1.1**).** An interlaced bilattice is `B = ⟨B, ≤_t, ≤_k, ∧, ∨, ⊗, ⊕, t, f, ⊤, ⊥⟩` where `⟨B,≤_t,∧,∨,t,f⟩` and `⟨B,≤_k,⊗,⊕,⊤,⊥⟩` are bounded lattices and **all four operations are order-preserving with respect to both orders**. Def. 1.3: negation is `≤_k`-order-preserving and a `≤_t`-involution.

**The product construction (Def. 1.4).** `L⊙R` has carrier `L×R` with `(a₁,b₁) ≤_k (a₂,b₂) ⟺ a₁≤_L a₂ ∧ b₁≤_R b₂` and `(a₁,b₁) ≤_t (a₂,b₂) ⟺ a₁≤_L a₂ ∧ b₂≤_R b₁`.

**Theorem 3.3 (verified).** *If `B` is an interlaced bilattice then there are bounded lattices `L, R` such that `B ≅ L⊙R`, and these are unique up to isomorphism.* The witnesses are canonical: `L_B = {x | x ≥_t ⊥}`, `R_B = {x | x ≤_t ⊥}`, with isomorphism `g(x) = (x∨⊥, x∧⊥)`. **Proposition 3.7**: with negation, `⟨B,¬⟩ ≅ L⊙L` under `¬(x,y) = (y,x)`. Avron's abstract: *"every interlaced bilattice is isomorphic to the Ginsberg-Fitting product of two bounded lattices."*

**Why this kills it.** Your Γ and Δ act on **one** powerset `2^E`, and validity is `Fix(Γ) ∩ Fix(Δ)`. Set `L = Fix(Γ)` and `R = Fix(Δ)`; `L⊙R` is a legitimate interlaced bilattice — but its elements are **pairs** `(closed set, open set)` with **no constraint that the two coordinates be the same set**, and both orders are computed componentwise. The object you care about is the **diagonal** of that product, and the representation theorem guarantees the structure is componentwise and therefore blind to it. Worse: your P1 says validity is a lattice under *neither* order; a bilattice makes it a lattice under **both**. That is not modelling your problem, it is assuming it away.

**And the non-monotonicity argument you were counting on belongs to AFT, not here.** Bilattices per se handle nothing non-monotone. What does the work is an operator theory built *on* a bilattice — Fitting's `Φ_P` being `≤_k`-monotone despite negation. That construction is exactly what AFT abstracts (§1); `L²` under `≤_p` *is* an interlaced bilattice by Avron's Def. 1.4, which is the only real link between the two candidates. Fitting's own wording could not be retrieved (melvinfitting.org serves a mismatched TLS certificate) — *unverified*, and confirmed only indirectly through AFT.

**Composition:** the product constructs *bilattices*, not compositions of models. No theorem of the form "validity of `B₁` and `B₂` implies validity of `B₁∘B₂`". Nothing for P4. **Tooling:** Arieli–Avron bilattice logics have proof systems; no mainstream solver. Effectively zero.

**Verdict: fails P1 (the representation theorem forces a componentwise product, erasing the non-lattice diagonal that is your validity set), P4 and P6, and supplies P3 only by borrowing AFT. Drop it — and take the carrier `L²` with you, since that is the part that was doing the work.**

---

## 3. Formal topology, specifically Sambin's *positive topologies* — the only framework where Γ and Δ are independent primitive data

You listed this as an afterthought alongside Chu spaces. It is the serious half of that pairing.

**Definition (verified).** A formal topology is a cover relation `a ◁ U` between basic opens and subsets, satisfying reflexivity, transitivity, left/right meet and top (Coquand, Sambin, Smith & Valentini, "Inductively generated formal topologies", *APAL* 124 (2003); PDF at <https://www.math.unipd.it/~sambin/txt/tig000615.pdf> — could not text-extract; definition taken from <https://ncatlab.org/nlab/show/formal+topology>).

The companion is the **binary positivity relation** `a ⋉ V`: "there is a point in the basic open `a` whose basic neighbourhoods are all in `V`". A **positive topology** carries *both* an **inductively generated** cover and a **coinductively generated** positivity, linked by the compatibility axiom

> `a ⋉ V`, `a ◁ U` ⟹ `∃x ∈ A (x ⋉ V and x ε U)`

with **fixpoints of ◁ = formal opens (a closure operator)** and **fixpoints of ⋉ = formal closeds (an interior/kernel operator)**. (Maietti, Maschio & Rathjen, <https://arxiv.org/abs/2103.16592>, text extracted via ar5iv. Book-length primary: Sambin, *Positive Topology: A New Practice in Constructive Mathematics*, OUP, <https://global.oup.com/academic/product/positive-topology-9780199232888> — described there as "a set equipped with two particular relations between elements and subsets of that set: a convergent cover relation and a positivity relation".)

This is P2 stated as a definition rather than derived: common fixed points of an inductively generated closure and a coinductively generated kernel, with a compatibility law relating them. And the generation modes map onto your semantics without strain — Γ is *inductively* generated from your requirement DAG (an axiom-set), Δ is *coinductively* generated from your "serves" relation. That is the right polarity for each.

**The caveat that decides whether you can use it.** Verified verbatim from Maietti–Maschio–Rathjen: *"Classically, a positivity relation can be associated to any basic cover in the form `a ⋉ V ≡ ¬ a ◁ ¬V` but constructively one needs to add a primitive operator."* So **classically, positivity collapses into the de Morgan dual of cover** — the exact failure mode that kills rough sets. Formal topology gives you two genuinely independent operators **only if you work constructively/predicatively**, taking `⋉` as primitive data linked to `◁` by compatibility alone. That is not a technicality; it is the entire reason to choose this framework, and it commits you to intuitionistic logic.

**Bonus for P5.** A **basic pair** `(X, ⊩, S)` (Maschio & Sambin, <https://arxiv.org/abs/1611.03078>) is two-sorted by definition — concrete points `X`, formal indices `S`, relation `⊩` — and its induced operators `◇D = {a ∈ S | ext a ≬ D}`, `□D = {a ∈ S | ext a ⊆ D}` are *literally* Yao's generalised rough approximations relativised to a relation between two different sets. So rough set theory turns out to be a degenerate special case sitting **inside the basic-pair layer of formal topology, one level below where the independent Γ/Δ pair lives**. That is the cleanest available argument for preferring this over rough sets, and it answers your rough-set question by subsumption.

**Six points.** P1 ✔ (constructively). P2 ✔ (definitional). P3 ✘ — both `◁` and `⋉` are monotone in the subset argument by axiom; nothing models "one addition satisfies a requirement and arms a prohibition". P4 ✘/unverified — no source found on whether positivity is preserved by products; point-free products are locale products, which *do* preserve frame structure, i.e. the wrong direction for you. P5 ✔ (two-sorted natively). P6 ✘ (two sorts only). Tooling: type-theoretic formalisations exist in the Minimalist-Foundation / Martin-Löf line; **no decision procedure or checker found**.

**Verdict: the only framework surveyed in which your Γ and Δ are independent primitive data with a compatibility law, matching P1, P2 and P5 — and it fails P3, P4 and P6, and charges you intuitionistic logic as the price of admission.**

---

## 4. Displayed categories + coloured operads — the light answer to P5 and P6

You asked for a lighter fibration account than institutions. Here it is, in two pieces.

**P5 — displayed categories, and the name for your forgetful functor.** A Grothendieck fibration requires cartesian lifts (Grothendieck, SGA1 Exp. VI; <https://ncatlab.org/nlab/show/Grothendieck+fibration>). You almost certainly cannot produce them — there is no canonical way to restrict a mechanism along an arbitrary asset map — and a fibration you cannot cleave buys nothing. Take instead **displayed categories** (Ahrens & Lumsdaine, "Displayed Categories", *LMCS* 15(1), 2019, <https://arxiv.org/abs/1705.04296>), which index objects and morphisms of `D` *directly by* those of `C` with no lifting obligation, and — from the abstract — avoid the equality-on-objects that the functorial definition of a fibration smuggles in. Formalised in Coq/UniMath.

More useful still, **your P5 has a standard name.** A **concrete category** is one equipped with a *faithful* functor `U : C → Set`; a category admitting none is **not concretizable** (verified, <https://ncatlab.org/nlab/show/concrete+category>). The canonical precedent is **Freyd, "Homotopy is not concrete", in *The Steenrod Algebra and its Applications*, LNM 168, Springer (1970)** — verified — showing `Ho(Top)` admits no faithful functor to `Set` even though it is a quotient of the concretizable `Top`. That is structurally *identical* to your situation: flat sets are a quotient of the indexed structure, and the quotient destroys the cycle. The companion notion is an **amnestic** functor; your two near-identical assets are precisely an amnesticity failure. So the sentence you want is: *"the category of protocol configurations is not concretizable over Set; the forgetful functor to flat element sets is neither faithful nor amnestic, and both the backing cycle and the USDT/USD1 identification lie in its kernel."*

**P6 — a curator is an n-ary morphism of a coloured operad.** Spivak, "The operad of wiring diagrams", <https://arxiv.org/abs/1305.0297>. Warning 2.1.1 states he means "a symmetric colored operad or a symmetric multicategory"; Example 2.1.7 gives morphisms `X₁,…,Xₙ → Y` as cospans `X₁+⋯+Xₙ → C ← Y` with `C` the set of *cables*; Example 4.1.1 gives the **typed** version, objects being pairs `(X, τ : X → Ob(Set))` with type-matching at solder points. Definition 2.2.5: "An algebra on O is an operad functor `R : O → Sets`".

A vault taking `n` protocols and yielding a composite **is** an `n`-ary morphism `φ : (M₁,…,Mₙ) → V`. Mechanisms are colours; policies are multi-morphisms. The sort stratification you are missing is built into the operad's own type discipline — objects versus multi-morphisms — with no 2-categorical or institutional apparatus. Lighter than a double category, far lighter than an institution.

**The trap, and the fix.** An operad algebra is a *strict* functor, with an identity law and a composition law. If you make validity membership in the algebra's value set, wiring valid mechanisms together **forces** the composite valid — exactly what your P4 disproves. The fix is clean and you should adopt it: **model observational behaviour as the algebra, and validity as a non-algebraic predicate over it.** Spivak's `Rel_A` (Example 2.2.10) assigns each star the set of relations of that type and composes them along wiring diagrams — which is precisely your "composition preserves observational equivalence". Put validity in the algebra and the operad contradicts your measurements; keep it outside and the operad models the half of P4 that *is* true. (Lax algebras would relax the strictness, but I found no usable primary treatment over the WD operad — *unverified*.)

**Verdict: displayed categories name and formalise P5 (with "not concretizable over Set" as the precise, citable diagnosis), and a typed coloured operad gives P6 cleanly and lightly. Both are silent on P1–P3. Neither competes with AFT; they compose with it.**

---

## 5. Rough set theory — refuted, at the definition

Your hypothesis was that lower/upper approximation is "literally a kernel/closure pair on the same set". It is, and that is the problem: it is *one* operator presented twice.

**Definition and the disqualifying axiom (verified).** `R̲X = ⋃{[x]_R : [x]_R ⊆ X}`, `R̄X = ⋃{[x]_R : [x]_R ∩ X ≠ ∅}` (Pawlak 1982 is paywalled; definitions taken from the open-access restatement in "On twelve types of covering-based rough sets", <https://pmc.ncbi.nlm.nih.gov/articles/PMC4937015/>). That same paper lists **duality — `R̲(¬X) = ¬R̄(X)` — as an axiom (8_LH) of the classical theory**, not an incidental fact. Yao's generalisation to an arbitrary binary relation (<https://www2.cs.uregina.ca/~yyao/PAPERS/approximation_ks.pdf>) keeps the shape: lower = "all R-successors inside X", upper = "some R-successor in X". These are `□` and `◇` of a Kripke frame.

**So: knowing Γ determines Δ completely.** There is only one relation in an approximation space. You cannot encode "what a set requires" and "what an element is for" as two independent relations. **P1 and P2 fail outright.**

**Does the covering generalisation decouple them? Only by breaking them.** Huang & Zhu, <https://arxiv.org/abs/1210.0074>, enumerate five covering operators and state explicitly that "SH and SL, and XL and XH … are dual, respectively"; only `XL` is an interior operator and only `XH` a closure operator. The operators that lose duality lose idempotence or extensivity instead — you get a badly-behaved non-closure, not a second independent closure. Li & Zhu (<https://arxiv.org/abs/1209.5569>) show fixed-point sets of a single lower approximation form complete distributive lattices or Boolean algebras — lattice-structured, which P1 says yours provably is not.

**Boundary region ≠ your residue.** `BN(X) = R̄X \ R̲X` is *epistemic uncertainty about membership* — objects the granularity cannot classify. Nothing in the theory says a nonempty boundary is **invalid**; it says the set is *rough*, and quantifies it with accuracy `|R̲X|/|R̄X|`. You need a validity predicate; rough sets give a vagueness measure.

**Non-monotonicity: no.** Both approximations are monotone in `X` by standard axiom. (Tellingly, Çaksu Güler, <https://arxiv.org/abs/2411.04133>, advertises "preserve the monotonic property" as a *selling point* of a new model.) **P3 fails.**

**Composition: nothing found.** arXiv sweeps on covering-based rough sets and approximation operators (45 hits across two queries) returned matroid structures, lattice structures, boolean-matrix axiomatisations, attribute reduction and fuzzy variants — **zero** papers on products of approximation spaces. Treat as *unverified absence*, but this is a data-analysis tradition, not a compositional one. **P4 fails by having nothing to say.** P5, P6 fail — one universe, one relation, no sorts.

**Tooling** is mature but aimed elsewhere: ROSETTA (<https://bioinf.icm.uu.se/rosetta/>), R.ROSETTA, RSES (<https://www.mimuw.edu.pl/~szczuka/rses/start.html>). These compute reducts and decision rules from data tables. No model checker, no validity prover.

**Verdict: fails P1, P2, P3, P4, P5 and P6. Its two operators are de Morgan conjugates of a single relation by construction; the generalisations that break duality break the operator instead. And it is subsumed — see §3, where rough approximations reappear as the basic-pair layer of formal topology, one level below where independent Γ/Δ lives. Drop it.**

---

## 6. Bunched implication / separation logic — refuted, and the mismatch runs the opposite way from what you expected

You asked me to assess this seriously. I did, and it is the most confidently negative result in this document.

**(a) Additive/multiplicative is not your union-closed/intersection-closed split.** Your P1 is about **closure polarity of a model class**. BI's split is about **whether a resource is shared or partitioned**. Different axes. `m ⊨ P ∧ Q` iff `m ⊨ P` and `m ⊨ Q` on the same `m`; `m ⊨ P ∗ Q` iff `∃m₁,m₂. m₁·m₂ = m` with `m₁ ⊨ P`, `m₂ ⊨ Q`. Both are *positive* conjunctions, neither is a closure operator, neither is idempotent (`P ∗ P ⇏ P`), neither corresponds to closure under union or intersection of models.

Critically — and this confirms your own suspicion — **`∗` is a positive assertion of separation, not a prohibition on sharing.** Reynolds derives non-aliasing as a *consequence*: `e₁↦e₁' ∗ e₂↦e₂' ⇒ e₁ ≠ e₂` ("Separation Logic: A Logic for Shared Mutable Data Structures", LICS 2002, <https://www.cs.cmu.edu/~jcr/seplogic.pdf>). That is "these do in fact live in disjoint parts", not "these must never overlap". To say "X and Y never co-occur", BI offers only ordinary negation — `¬(X ∧ Y)` in Boolean BI, `X ∧ Y → ⊥` intuitionistically — and the resource structure drops out entirely, leaving a plain Horn clause you already had.

Reynolds *does* have your concept, and pointedly it is **not a connective**. Verbatim: "we say that two assertions are *immiscible* if they cannot both hold for overlapping heaps." He presents immiscibility as a meta-level property of assertion *pairs* and speculates it "may be a fertile source of new inference rules" — i.e. as of 2002 an open direction, not machinery. **BI does not internalise the one concept your prohibitions need.**

**(b) Non-monotonicity — intuitionistic SL fails P3 outright.** Reynolds, verbatim: "We say that an assertion p is *intuitionistic* iff, for all stores s and heaps h and h′: h ⊆ h′ and ⟦p⟧(s,h) implies ⟦p⟧(s,h′)"; and historically, "The intuitionistic character of this logic implied a monotonicity property: that an assertion true for some portion of the addressable storage would remain true for any extension of that portion… Ishtiaq and O'Hearn also presented a classical version of the logic that does not impose this monotonicity property". So intuitionistic SL assertions are **monotone under heap extension by construction**. Classical BBI is non-monotone but *uniformly and degenerately* so — precise assertions like `x ↦ 3` are false on any strict extension because they describe the heap exactly. That is anti-monotone across the board, not your interleaving where one addition simultaneously satisfies a requirement and arms a prohibition. BBI clears the bar while doing none of the work.

**(c) The frame rule is the fatal mismatch, and it runs the other way.** `{p} c {q} ⊢ {p ∗ r} c {q ∗ r}` (Reynolds, verbatim, side condition: no free variable of `r` is modified by `c`). Its purpose in his words: "the frame rule is the key to 'local reasoning' about the heap… to infer from a local specification of a command the more global specification appropriate to the larger footprint". Yang proved it complete in a precise sense. **The frame rule *is* "composition preserves validity", and it is the load-bearing beam of the entire edifice.** Your P4 asserts the opposite, with witnesses. Adopting SL for a system that fails frame means importing the notation while discarding the only theorem that justified inventing it; without frame, separation logic degenerates to Hoare logic with a fancy conjunction.

**(d) Decidability — the decidable fragments are precisely the ones that cannot state prohibitions.** Intuitionistic propositional BI is decidable (Galmiche, Méry & Pym, *MSCS* 15 (2005) 1033–1088). **Boolean BI is undecidable** (Larchey-Wendling & Galmiche, LICS 2010, <https://members.loria.fr/DLarchey/files/papers/lics10_larchey_galmiche_full.pdf>). Brotherston & Kanovich, *JACM* (<https://www0.cs.ucl.ac.uk/staff/J.Brotherston/JACM/brotherston_kanovich_JACM.pdf>), Corollary 5.1: provability and validity are undecidable "even when restricted to the language (∧, →, I, ∗, −∗) of Minimal BBI", across all separation models and the concrete heap models; Corollary 5.2: "Neither Minimal BBI nor BBI nor BBI+eW has the **finite model property**" — so **no finite countermodels**, hence no model-enumeration debugging of a failed constraint. Remark 6.1 notes undecidability arises *purely from combining* ∧/→ with ∗/−∗, not from negation, "notwithstanding the fact that both its components are decidable". The decidable fragments — Berdine–Calcagno–O'Hearn symbolic heaps (FSTTCS 2004), Iosif–Rogalewicz–Šimáček bounded tree width (<https://arxiv.org/abs/1301.5139>) — are **negation-free positive** fragments. Your prohibitions are negations of co-occurrence. Adding them exits the decidable fragment.

**(e) Tooling is aimed at programs you do not have.** Only **cvc5** is a general checker not requiring a program (quantifier-free `SL(T)`, <https://cvc5.github.io/docs/cvc5-1.0.2/theories/separation-logic.html>) — but it allows **one `declare-heap` per context**, no quantifiers, no mixed Loc/Data sorts, which collides directly with P5 and P6. Infer, VeriFast, Viper, Cyclist and Iris all consume *programs*. You have a static structural-validity question.

**(f) Iris resource algebras: a real hit on double-counting, but a backing cycle is not a double-count.** Iris RAs are `(M, V, |−|, ·)` with **RA-VALID-OP: `∀a,b. V(a·b) ⇒ V(a)`**, motivated verbatim by ruling out the case where "multiple threads claim to have ownership of an exclusive resource" (Jung et al., "Iris from the ground up", *JFP* 28 (2018) e20, <https://people.mpi-sws.org/~dreyer/papers/iris-ground-up/paper.pdf>). If Terra were *the same asset counted twice*, cameras would be the right object. **But A→B→C→A can be perfectly disjoint at every hop** — each mechanism holds a distinct token, `V(a·b·c)` holds, the RA is content. What is wrong is that the transitive closure of `backs` has no exogenous grounding: a **reachability/well-foundedness** property of a directed graph. Separation algebras have no notion of reachability, and RA-VALID-OP is anti-monotone — a purely Horn-shaped property that cannot express your dual-Horn requirements. SL gets acyclicity for free only in the narrow `ls x nil` case, where nodes *are* the resources; that trick would reject legitimate asset sharing along with the pathological cycle. Too blunt.

**Verdict: fails P1, P3 and P4; a too-blunt partial hit on P5; clears P6 only by borrowing generic higher-order logic in Coq. P4 is fatal — the frame rule is the assumption that composition preserves validity, which is exactly what your system disproves, and BI's decidable fragments are precisely the negation-free ones that cannot express your prohibitions. Drop it.**

---

## 7. Petri nets, siphons and traps — my own best hunch, honestly refuted on polarity

I went in expecting siphons/traps to be an exact Γ/Δ pair. They are not, and the reason is worth recording.

**Definitions (verified, Murata, "Petri Nets: Properties, Analysis and Applications", *Proc. IEEE* 77(4):541–580, 1989, <https://www.dsc.ufcg.edu.br/~abrantes/CursosAnteriores/MVSRP/murata89.pdf>).** A **siphon** is a nonempty `S` with `•S ⊆ S•` — "every transition having an *output* place in S has an *input* place in S". A **trap** is a nonempty `Q` with `Q• ⊆ •Q`. Behaviourally, verified: "a siphon has a behavioral property that if it is token-free under some marking, then it remains token-free under each successor marking"; dually a marked trap stays marked. Desel & Esparza call these **stable predicates**, which is the right vocabulary for your Γ/Δ (*Free Choice Petri Nets*, CUP, <https://www7.in.tum.de/~esparza/bookfc.html>).

**Commoner/Hack (verified, Murata Thm 12 / Thm 15).** "A free-choice net (N, M₀) is live **iff** every siphon in N contains a marked trap." For asymmetric-choice nets the condition is sufficient but not necessary. Structurally: "a free-choice net is structurally live iff every siphon has a trap." That is a beautifully profile-shaped theorem — and it is not the shape you have.

**The refutation.** **Siphons and traps are BOTH closed under union; neither is closed under intersection.** `•(S₁∪S₂) = •S₁ ∪ •S₂ ⊆ S₁• ∪ S₂• = (S₁∪S₂)•`, and dually for traps; intersection fails for both because pre-/post-sets of an intersection are only *contained in* the intersection of the pre-/post-sets. (Definitions are Murata's; **this derivation is the lane's, not quoted from a source**.) Consequently each family has a maximal element inside any place set, giving **two interior/kernel operators of the *same* polarity** — "largest siphon inside X" and "largest trap inside X". You do not get an opposite-polarity Γ/Δ pair. **P1 is not matched, and the Murata §VII duality — "a set of places is a trap (siphon) in N⁻¹ iff it is a siphon (trap) in N" — is *arrow reversal*, not lattice polarity.** Do not force this analogy.

**Where it does earn its keep: P5.** Coloured Petri nets (Jensen) put `(element, asset)` instance data on the token, so "asset A backs mechanism M mints asset B backs N backs A" is a directed circuit at the *token* level, structurally detectable, even though the type-level net is a DAG. **Collapsing colours is exactly your non-faithful forgetful functor.** P6 fails outright: two sorts (places, transitions); CPN substitution transitions are modular nesting, not a policy sort.

**Decidability & tooling.** Reachability is decidable (Mayr 1981, Kosaraju 1982 — standard attribution, not re-verified) and **Ackermann-complete**, proved independently in 2021 by Leroux (FOCS 2021, <https://ieee-focs.org/FOCS-2021-Papers/pdfs/FOCS2021-5stbVHiOp5jRHWlSl41FkR/205500b241/205500b241.pdf>) and Czerwiński & Orlikowski (FOCS 2021, <https://ieee-focs.org/FOCS-2021-Papers/pdfs/FOCS2021-5stbVHiOp5jRHWlSl41FkR/205500b229/205500b229.pdf>). Computing the *maximal* siphon inside a place set is polynomial (greedy removal, justified by union-closure); complete siphon enumeration is exponential and minimal-siphon extraction is NP-complete in identified cases. Tools: LoLA, TINA, CPN Tools, Snoopy, TAPAAL.

**Verdict: fails P1 (both operators union-closed — same polarity) and P6 entirely; excellent on P5. Steal siphon/trap computation as an *analysis technique* for backing-cycle detection. Do not adopt Petri nets as the ambient formalism.**

---

## 8. Chu spaces — a stretch; drop

Objects of `Chu(Set,2)` are `(A, X; r : A × X → 2)`, points versus states, with a contravariant self-duality swapping the components; it is a genuine \*-autonomous category and **does model linear logic** (confirmed by Papadopoulos & Syropoulos, <https://arxiv.org/abs/1101.2999>: "the logic of Chu spaces is linear logic"; construction per <https://ncatlab.org/nlab/show/Chu+construction>).

**But the two sorts in Chu are each other's dual by construction.** Your `(element, asset)` sorts are not: assets are *indices*, not the dual space of elements. Writing `r : Element × Asset → 2` for `backs` is syntactically possible and semantically empty — you get one bipartite relation and neither Γ nor Δ. Worse for P4: Chu is a category, morphisms compose, and object/morphism properties are preserved by composition — the opposite of your measurement.

**Verdict: fails P1, P2, P3 and P4. Self-duality is exactly the wrong shape: you need two *independent* operators, and Chu gives you one structure and its mirror. The genuine partial match on P5 is available more cheaply from displayed categories (§4). Drop.**

---

## 9. Hyperdoctrines — rejected in one line

A hyperdoctrine is `P : Tᵒᵖ → C` with each substitution `P(f)` having both adjoints `∃_f ⊣ P(f) ⊣ ∀_f`, subject to Beck–Chevalley and Frobenius (Lawvere, "Adjointness in Foundations", *Dialectica* 23 (1969), TAC reprint <http://www.tac.mta.ca/tac/reprints/articles/16/tr16abs.html>; "Equality in hyperdoctrines…", <https://ncatlab.org/nlab/files/LawvereComprehension.pdf>; Seely, *ZML* 29 (1983), <https://www.math.mcgill.ca/seely/ZML/ZML.PDF>). It is genuinely "predicates indexed over contexts" and genuinely much lighter than an institution, and it delivers P5.

**But the fibres are lattices/Heyting algebras by definition, and your P1 says validity is a lattice under neither polarity.** The core assumption is violated at the fibre. Comprehension nominally offers P6, but to state it you must already have the mechanism-object in the base — the extra sort is a precondition, not a dividend.

**Verdict: fails P1 at the fibre; does not deliver P6 for free. Reject.**

---

## 10. Antimatroids, greedoids, convex geometries, convexity spaces — refuted, and one of your premises is backwards

**Correction first, because it would have poisoned everything downstream.** You wrote: "Convex geometries are the dual of matroids and are exactly union-closed families." **That is backwards.** A convex geometry's *closed (convex) sets* form a Moore family and are **intersection-closed**. It is the **antimatroid's *feasible* sets** that are **union-closed**. The two are complementary — feasible sets of the antimatroid are the complements of the closed sets of the convex geometry — so of course they carry opposite polarity.

**Definitions (verified** from Kempner & Levit, "Cospanning characterizations of antimatroids and convex geometries", <https://arxiv.org/abs/2107.08556>, attributing to Korte, Lovász & Schrader, *Greedoids*, Springer 1991**).** A **greedoid** is `(E,F)` with `∅ ∈ F` and the exchange axiom `X,Y ∈ F, |X| > |Y| ⇒ ∃x ∈ X∖Y . Y∪x ∈ F`. An **antimatroid** is "a greedoid closed under union"; for an accessible system, antimatroid ⟺ `F` closed under union ⟺ (`A, A∪x, A∪y ∈ F ⇒ A∪{x,y} ∈ F`). **Accessibility**: every nonempty closed `X` contains `x` with `X−x` closed. **Anti-exchange**: `p,q ∉ τ(X) ∧ p ∈ τ(X∪q) ⇒ q ∉ τ(X∪p)`. A **convex geometry** is "a closure space with anti-exchange property". Closure lattices of convex geometries are meet-distributive/locally distributive (Adaricheva & Nation, <https://arxiv.org/abs/1205.3236>; Dilworth 1940 lineage **not fetched**).

**Your "seating order" intuition is genuinely accessibility** — and accessibility is a shellability/removal axiom, not monotonicity, so it does *not* by itself clash with P3. That much of your hunch was right.

**But union-closure is the kill shot.** In an antimatroid, if `{x}` is feasible and `{y}` is feasible then `{x,y}` is feasible. Your prohibitions say precisely that `{x,y}` is *not*. Worse, `E = ⋃F` is always feasible in an antimatroid — the "everything at once" configuration is always valid, which is the exact negation of having any prohibition at all. **An antimatroid cannot express a single prohibition.** Full stop.

**Greedoids are worse.** The exchange axiom forces all maximal feasible sets to be **equicardinal** (immediate: a smaller maximal set could be augmented). Your maximal valid configurations differ in size. Dead on arrival.

**Convexity spaces (van de Vel) — the hope I had for this cluster, and it collapses.** Verified axioms (via <https://arxiv.org/abs/2412.01445>, citing van de Vel, *Theory of Convex Structures*, North-Holland Math. Library 50, 1993): **(C1)** `∅, X ∈ C`; **(C2)** closed under intersections; **(C3)** closed under **nested** unions. I hoped C2/C3 was the opposite-polarity pair. It is not: **in a finite carrier C3 is vacuous**, since every finite chain contains its own maximum and its union is already a member. Over a finite `E`, a convexity space is *nothing but* a Moore family containing `∅` and `E`. C3 only earns its keep over infinite carriers (algebraic/finitary closure). **Only revisit this if your `(element, asset)` instance carrier is genuinely unbounded.**

**Products/composition: unverified.** KLS 1991 has chapters on interval greedoids, lattices associated with greedoids, and local poset greedoids, but the lane could not confirm a direct-sum/free-product construction or that antimatroid-hood is preserved. Do not cite products here. **Optimisation** is the one genuine strength: greedy is optimal for R-compatible linear objectives over a greedoid (Korte & Lovász, *SIAM J. Alg. Disc. Meth.* 5 (1984), <https://epubs.siam.org/doi/abs/10.1137/0605024>). **No software found** (SageMath has matroids, not antimatroids) — unverified negative.

**Verdicts.**
- **Antimatroid** — fails P1 outright (union-closure makes prohibitions inexpressible and forces `E` valid); also fails P4, P5, P6.
- **Convex geometry** — fails P1 from the other side: intersection-closed only, so it expresses prohibitions but not disjunctive requirements; also fails P3 (closure lattices are monotone by construction), P5, P6.
- **Greedoid** — fails P1 *and* forces equicardinal maximal valid sets. Worst fit of the four.
- **Union-closed set families / Frankl's conjecture** — irrelevant; Frankl is a frequency lower bound, not a structure theory.
- **Convexity spaces** — fails P1 in the finite case, where C3 is vacuous and the structure degenerates to a Moore family.

---

## Ranked verdict

**Nothing here replaces the closure+kernel model. Two things genuinely extend it, and one thing reframes it.** Ranked by what I would act on:

**1. The bijunctive/median reframing (§0) — not a framework, a measurement.** Highest value per unit of effort, and it is a *decision*, not a survey result. Your P1 and P3 are jointly the signature of a **median algebra** if and only if requirements are single-consequent. Answer the arity question first: arity-1 buys you a median algebra with linear-time algorithms and a real representation theory; arity-≥2 puts you in the provably structureless NP-complete regime whose canonical instance is graph colouring. Every other choice in this document is downstream of that answer. Fails nothing, because it is not competing — it tells you which regime you are in.

**2. Approximation Fixpoint Theory (§1), with ADFs (§2) and ASP (§2b) as its runnable instances.** The strongest *framework* candidate, and the only one whose central machinery is built for P3 rather than tripped up by it: a non-monotone operator on `L` becomes a `≤_p`-monotone operator on `L²`, and Knaster–Tarski applies again. It is also the only candidate that *explains* P4 instead of contradicting it, and this is now verified at theorem level rather than inferred: **VGD Theorem 3.5 is an iff** — fixpoints decompose across a split exactly when the operator satisfies the stratifiability condition of Definition 3.3 — so "composition does not preserve validity" is not a brute fact but the failure of a named, citable side condition, with Terra's instance-level cycle as the reason it fails. ADFs give you P1 natively (attacking/supporting/redundant/dependent links, independent, not de Morgan duals); ASP gives you P1, P2, P3, P5 plus the most mature solvers of anything here, at the cost of reification for P6. **Fails P5 and P6 at the AFT level** (carrier-agnostic by construction: it takes the lattice as given and will never tell you the carrier must be indexed by `(element, asset)`); neutral on P1. This is what I would build on.

*One honest test before committing:* AFT's two components are the lower and upper bound of **one** operator, whereas your Γ and Δ are two **different** operators on the same lattice. The shapes coincide; the meanings do not. The concrete go/no-go is: **can you define `A(x,y)` from Γ and Δ such that `A` is `≤_p`-monotone?** If yes, you inherit all three semantics and the splitting theorem for free. If no, AFT gives you nothing.

**3. Displayed categories + typed coloured operads (§4) — the cheap answers to P5 and P6.** Not competitors; bolt-ons. Displayed categories give the `(element, asset)` indexing with no cartesian-lift obligation, and — more useful — your P5 has a **name**: the configuration category is **not concretizable over Set**, the forgetful functor being neither faithful nor amnestic, with Freyd's "Homotopy is not concrete" (1970) as the exact structural precedent. A typed coloured operad makes a curator an `n`-ary multi-morphism `(M₁,…,Mₙ) → V`, which *is* P6, lighter than a double category and far lighter than an institution — **provided you keep validity out of the algebra**, putting only observational behaviour in it, which is precisely the half of P4 that holds. **Silent on P1–P3.**

**4. Formal topology / Sambin positive topologies (§3) — the honourable near-miss.** The only framework where Γ and Δ are *independent primitive data* with a compatibility law, and where the generation modes (inductive cover, coinductive positivity) match your semantics exactly. It also subsumes rough sets as its basic-pair layer. **But it fails P3 and P4 — both operators are monotone by axiom — and it charges intuitionistic logic as the entry fee, since classically positivity collapses to `¬ a ◁ ¬V` and you are back to de Morgan duals.** Read it for vocabulary and for the compatibility axiom; do not rebuild on it.

**5. Petri net siphons/traps (§7) — demoted to a tool.** My own best hunch going in, and honestly refuted: **siphons and traps are both union-closed**, so they are two kernel operators of the *same* polarity, not your Γ/Δ pair. Commoner's theorem ("a free-choice net is live iff every siphon contains a marked trap") is profile-shaped but is not your shape. Keep coloured Petri nets and siphon computation as an **analysis technique for backing-cycle detection** — they are strong on P5 — and drop them as an ambient formalism (P6 fails outright).

**Refuted, in descending order of how confidently:**

**6. Bunched implication / separation logic (§6).** The most confident rejection. `∗` asserts separation positively; it cannot say "must not share" — Reynolds's own word for your concept, *immiscibility*, is explicitly a meta-level property of assertion pairs and not a connective. Intuitionistic SL is monotone under extension by construction (P3 dead); the **frame rule *is* the claim that composition preserves validity**, which your P4 disproves with witnesses, so the load-bearing theorem is exactly the one you cannot have. Boolean BI is undecidable **with no finite model property** (so no countermodels to debug with), and every decidable fragment is negation-free — i.e. cannot express a prohibition. Iris cameras genuinely detect double-counting but a backing cycle is a *reachability* property, and separation algebras have no notion of reachability. **Fails P1, P3, P4; blunt on P5; clears P6 only via generic higher-order logic.**

**7. Antimatroids / greedoids / convex geometries / convexity spaces (§10).** An antimatroid cannot express a single prohibition (union-closure forces `E` valid); a greedoid additionally forces equicardinal maximal sets; a convex geometry is intersection-closed and so cannot express disjunctive requirements; a finite convexity space degenerates to a Moore family because C3 is vacuous. And your premise that convex geometries are union-closed is backwards. **All fail P1.**

**8. Rough set theory (§5).** Fails at the definition: lower and upper are de Morgan conjugates of a *single* relation — duality is an axiom, not an accident — so Γ determines Δ and you cannot have two independent operators. The covering generalisations that break duality break the operator instead. The boundary region is a vagueness measure, not your residue. **Fails all six**, and is subsumed by §3 anyway.

**9. Bilattices (§2c).** Refuted by the very theorem that makes them tractable: Avron's Theorem 3.3 forces every interlaced bilattice to be a componentwise product `L⊙R`, so your validity set — the *diagonal* of `Fix(Γ) × Fix(Δ)` — is exactly what the structure cannot see. And a bilattice makes validity a lattice under *both* orders, where P1 says it is a lattice under neither. The non-monotonicity argument you were counting on is AFT's, not the bilattice's. **Keep the carrier `L²`, drop the framework.**

**10. Chu spaces (§8) and hyperdoctrines (§9).** Chu's two sorts are each other's dual by construction, which is the wrong shape for two *independent* operators, and everything in a category is preserved by composition. Hyperdoctrines are genuinely lighter than institutions and do deliver P5, but their fibres are Heyting algebras **by definition**, contradicting P1 at the fibre.

**Bottom line.** Keep the closure+kernel model. Ask the arity question, because it decides whether you are in the median-algebra regime or the NP-complete one. Then take AFT/ADFs as the semantic engine for P1–P4, bolt on a displayed category for P5 and a coloured operad for P6, and steal siphon/trap computation as a cycle detector. Nothing on your list beats what you have; three things extend it in directions it does not currently reach.

---

## What I could not verify

**Tooling constraint that shaped everything.** The session's WebSearch budget was exhausted (200/200) before research began. All sources were reached by direct WebFetch of primary URLs, with DuckDuckGo's HTML endpoint as a search proxy until it began returning HTTP 403. Several primary PDFs would not text-extract. One guessed arXiv ID returned a completely unrelated paper, so **no arXiv identifier below was used unless it was resolved through a search result, never guessed**.

**Claims I could not confirm from a primary source:**

- **The median-algebra structure of 2-SAT solution sets (§0)** — I confirmed the statement and its attributions (Bandelt & Chepoi 2008; Chung, Graham & Saks 1989) only through <https://en.wikipedia.org/wiki/2-satisfiability>. I did **not** read either primary. The claim is standard, but treat the citation as second-hand until checked.
- **Schaefer 1978 itself** was never fetched. The polymorphism characterisations (Horn↔min, dual-Horn↔max, bijunctive↔majority, affine↔minority) were confirmed via the Wikipedia article on the dichotomy theorem and via the CKZ 2008 paper's §2.2 restatement. The **NP-completeness of the mixed Horn/dual-Horn case is a derivation** from the dichotomy plus the non-membership witnesses, not a quoted theorem — though the graph-colouring encoding makes it concrete and I regard it as safe.
- **The DMT originals on AFT** — "Approximations, stable operators, well-founded fixpoints…" (2000) and the *Information and Computation* 2004 version — could not be text-extracted. AFT's core definitions come from the restatement in <https://arxiv.org/pdf/2502.09234>; only the **ultimate approximation** abstract is quoted verbatim from a primary (<https://arxiv.org/abs/cs/0205014>).
- **The AFT splitting theorem's precise side condition — NOW VERIFIED, upgrade from the earlier draft.** Definitions 3.3, Proposition 3.4 and Theorem 3.5 were subsequently read from the v2 PDF of <https://arxiv.org/abs/cs/0405002> and are quoted in §1. This was flagged as the single most load-bearing *inference* in an earlier draft; it is now a quoted theorem, and the P4 story stands on it. What remains unverified is the **exact Lifschitz–Turner 1994 splitting-set theorem statement** (`vl/papers/splitting.pdf` serves a different paper — Harrison & Lifschitz on infinitary formulas — and every other URL 404'd), and the **Oikarinen–Janhunen module theorem** (ECAI'06/TPLP'08 unreachable; all engines 403, Semantic Scholar API rate-limited). The commonly-reported side condition for the latter — *no positive recursion through the module input/output interface* — **could not be confirmed from a primary source and must not be cited as confirmed.**
- **Bilattice and ASP items.** Avron's Definitions 1.1–1.4 and Theorems 3.3/3.7 are quoted from the primary PDF and are solid. **Fitting's own wording** on `Φ_P` being `≤_k`-monotone is **unverified** — melvinfitting.org serves a mismatched TLS certificate (`*.securedata.net`) and the Lehman mirror 404s; the claim is confirmed only indirectly, in generalised form, via AFT. Also unverified: **uniqueness of the stable model of a stratified normal program** (standard, but not quoted here), and the **NP-complete / Σ₂ᵖ-complete** complexity statements for normal/disjunctive ASP (standard, not verified this session).
- **That FO(ID)/IDP-Z3's inductive-definition semantics is the AFT well-founded fixpoint.** Widely stated in the KU Leuven literature; not confirmed on the pages I fetched.
- **ADF complexity.** I have only the verified phrasing "one level up in the polynomial hierarchy compared to AFs". Exact per-semantics bounds are unverified; an earlier fetch returned "PSPACE-complete", which I believe is a summariser artefact and have discarded rather than reported. Solver maintenance status (DIAMOND, YADF, k++ADF, QADF) unchecked.
- **Formal topology composition.** No source found on whether the positivity relation is preserved by products of formal topologies, and none on completeness/cocompleteness of the category. The general risk (point-free products are locale products, which preserve frame structure) is my inference. Coquand–Sambin–Smith–Valentini would not text-extract.
- **O'Hearn & Pym 1999**, the actual BI primary, was never obtained — the Cambridge link served an unrelated paper. BI content is quoted via Reynolds (a co-developer) and via Larchey-Wendling & Galmiche. **Calcagno–O'Hearn–Yang** (separation algebras, safety monotonicity, frame property) also could not be fetched, so those precise definitions are unverified. Mayr/Kosaraju attributions for Petri reachability decidability were not re-verified.
- **The siphon/trap union-closure derivation (§7)** is the lane's own one-line proof from Murata's definitions, not a quoted result — though it is elementary and I am confident in it. That adding tokens can destroy liveness in general nets, and that place/transition-fusion composition does not preserve liveness, are both standard folklore that **could not be sourced this session**.
- **Edelman & Jamison 1985** (paywalled), **Dilworth 1940**, and **Monjardet 1985** (paywalled) were never read; antimatroid/convex-geometry definitions come from Kempner & Levit's restatement of Korte–Lovász–Schrader. **Products of antimatroids/greedoids: entirely unverified — do not cite.** No antimatroid software found, which is an unverified negative.
- **Lax algebras over the wiring-diagram operad** — the construction that would let validity live in the algebra without forcing preservation under composition — could not be sourced. If the operad route is pursued, this is the gap to close.
- **Freyd's "Homotopy is not concrete"** and the *amnestic* definition come from nLab; the TAC reprint and Adámek–Herrlich–Strecker both failed to fetch (ECONNRESET / TLS mismatch). Attribution is secondary-confirmed only.
- **No literature name exists for "the intersection of a union-closed and an intersection-closed family."** The lane searched and found none, and gives a principled reason (the object is `Inv(∅)` and carries no polymorphism). Reported as *searched-for and not found*, **not** as a proven gap in the literature.
- **Sequencing note.** The bilattice/ASP lane returned *after* the first complete draft was written; §2b, §2c and the upgraded §1 splitting statements were folded in afterwards, and the ranked verdict was revised accordingly. An earlier partial fetch indicated Oikarinen & Janhunen's module theorem "properly strengthens Lifschitz and Turner's splitting set theorem" and permits "recursion between modules" — the exact side condition was never recoverable, and ASP-specific composition remains the obvious next thing to check.

===== END FILE =====

===== FILE formal/v3/VERIFICATION.md | SHA256 a4e9ca6ab5873bdc65a4b5c3bebef12d14e6cb1edd418a757b222d841e8a1b9c =====
# VERIFICATION — machine-checking `paper/atlas.tex`

Date: 2026-08-04. Scope: `formal/v3/` (measurements) and `lean/` (proofs).
Rule observed: nothing outside `lean/` and `formal/v3/` was modified. Nothing was tuned to make a
claim pass; every witness below is reported as found.

Harness: `formal/v3/lib.mjs` re-exports the shipped model from `formal/v2/tables.mjs` but uses it
**as membership predicates only** — `inR`, `inW`, `inH`, `grounded` — never as operators, matching
the paper's own §"Model classes, not operators". The one place an operator is used is
`prop:joinmeet`, which is itself an operator claim.

**Reproducibility note that applies to every sampled figure.** The v2 probes
(`audit/probe4.mjs`) draw pools with `Math.random()` and no seed, so the paper's exact counts
are not reproducible by construction. v3 uses a seeded mulberry32 RNG and reports the seed, and
where feasible replaces sampling with exhaustive enumeration.

---

## Summary table

| Claim | Verdict |
|---|---|
| `lem:polarity` + `thm:closure` | **VERIFIED** in Lean, both halves incl. the negative ones |
| `cor:lattice` | **VERIFIED** in Lean (largely from mathlib — low-content) |
| `thm:convex` | **VERIFIED** in Lean and exhaustively in v3 |
| `thm:excomp` | **VERIFIED** in Lean and on 1,464,616 closed pairs — **but the paper's proof sketch is missing the acyclicity hypothesis** |
| `meas:closureprops` | **VERIFIED qualitatively; the two cited counts do NOT reproduce** |
| `meas:latticeconf` | **VERIFIED** (0 union violations robust; 51,917 is seed-specific, ±3%) |
| `prop:joinmeet` | **REFUTED** — meet is not `Δ^ω(A ∩ B)`; explicit 4-element witness |
| `cor:oplusclosed` | **VERIFIED** — but `cor:admnotlattice`'s "prohibitions are the sole obstruction" is **REFUTED** |
| `cor:ourconvex` | **VERIFIED**; the "15 arcs" figure holds only for the raw parse, not for `L*` |

Two substantive refutations (`prop:joinmeet`, the sole-obstruction claim), one incomplete proof
(`thm:excomp`), two unreproducible figures (`meas:closureprops`, "15 arcs").

---

## 5. `meas:closureprops` — VERIFIED qualitatively, counts not reproducible

> "{Op,Tp} and {Ex,Op} both satisfy 𝓡, while their intersection {Op} does not (L1a is
> unsatisfied). Sampling 194,775 pairs from 𝓡: 1,923 fail intersection-closure, 0 fail
> union-closure."

```
$ cd /root/DefiElements/formal/v3 && node m1-closureprops.mjs
witness  {Op,Tp} in R : true
witness  {Ex,Op} in R : true
witness  {Op}    in R : false  open terms: [["L1a","Ex|Tp|At|Oa|Sv|Cl|Cp|St|Wg"]]

EXHAUSTIVE over R-members of size<=3: |pool| = 18966, pairs (i<=j) = 179864061
  union-closure failures        : 0
  intersection-closure failures : 68058  (0.038%)

SAMPLED (seed=1, |pool|=3000, v2 probe4 pairing scheme): pairs 175230
  union-closure failures        : 0
  intersection-closure failures : 3342
SAMPLED (seed=2, ...): pairs 175230  union 0  intersection 2955
SAMPLED (seed=3, ...): pairs 175230  union 0  intersection 2809

ADVERSARIAL (density 0.35, seed 77): pairs 155220, union failures 0, inter failures 19013
  first intersection witness: {As,Au,Aw,Ct,Cv,Em,Ft,Fz,Li,Oa,Op,Pf,Ps,Rd,Sh,Sl,Tg,Up,Wg,Wq,Xf}
                            ^ {Ad,As,At,Au,Aw,Cd,Ct,Em,Ex,In,Ix,Op,Pf,Rs,Sr,Tg,Up,Wq}
                            = {As,Au,Aw,Ct,Em,Op,Pf,Tg,Up,Wq}
```

* The named witness is **exactly right**, including the attribution to `L1a`.
* Union-closure: **0 failures** across 179,864,061 exhaustively enumerated pairs plus 680,910
  sampled ones. This is now also a theorem (Lean `Polarity.lean`), so the measurement is
  corroboration, not evidence.
* The two sampled numbers do **not** reproduce. The v2 pairing scheme (pool 3000, window 60)
  produces **175,230** pairs, not 194,775 — and 194,775 is the pair count the paper attributes to
  a *different* measurement (`meas:latticeconf`). The intersection-failure count is
  seed-dependent (2,809–3,342 here versus 1,923 reported), and rises to 19,013/155,220 at higher
  sampling density: it is a property of the sampler, not of 𝓡. **Recommendation:** replace both
  figures with the exhaustive ones (0 / 179,864,061 and 68,058 / 179,864,061 at size ≤ 3), which
  are deterministic.

## 6. `meas:latticeconf` — VERIFIED

> "Over 175,230 pairs from 𝓡 ∩ 𝓦 there are 0 union-closure violations. Meet is not
> intersection: 51,917 pairs have X ∩ Y ∉ 𝓡 ∩ 𝓦."

```
$ node m2-latticeconf.mjs
empty in R n W : true
TOP   in R n W : true
TOP   admissible (i.e. also in H) : false

seed=1  |pool|=3000  pairs=175230   union 0   intersection 50223   [paper: 0 / 51,917]
seed=2  |pool|=3000  pairs=175230   union 0   intersection 50611
seed=3  |pool|=3000  pairs=175230   union 0   intersection 50276

EXHAUSTIVE over (R n W)-members of size<=3: |pool|=8023, pairs=32188276
  union-closure violations : 0
  intersection violations  : 396437
```

The pair count **175,230 reproduces exactly** (it is determined by the scheme, not the seed), and
0 union violations is robust across seeds and confirmed exhaustively. 51,917 is within ~3% of the
seeded reruns — consistent, but it is a sample statistic reported as if exact. The hypotheses of
`cor:lattice` (∅ ∈ 𝓡∩𝓦, ⊤ ∈ 𝓡∩𝓦) both check out; note ⊤ is *not* admissible, which is
`cor:admnotlattice` in miniature.

## 7. `prop:joinmeet` — **REFUTED**

> "In 𝓡 ∩ 𝓦 the join of A and B is A ∪ B and the meet is Δ^ω(A ∩ B)."

The join half is correct. The meet half is false, and fails on 4-element sets.

```
$ node m3-joinmeet.mjs
{Cp,Fl}  in R: true  in W: true  in RnW: true
{Cl,Fl}  in R: true  in W: true  in RnW: true
{Fl}     in R: true  in W: false in RnW: false   open=[] unwarranted=["Fl"]
  A n B = {Fl};  Delta^w(A n B) = {};  in RnW: true

tested 4000 pairs (|A n B| <= 18, true meet computed exhaustively over subsets)
  Delta^w(A n B) NOT in R n W          : 16
  Delta^w(A n B) != true meet          : 16
  Delta^w(A n B) == true meet          : 3984

minimal counterexample search over R n W members of size <= 4:
  A={Cp,Ix,Op,Sh} B={Ix,Op,Sh,Wg} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
  A={Cp,Ix,Op,Sh} B={Ix,Op,Sh,St} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
  A={Cp,Ix,Op,Sh} B={Cl,Ix,Op,Sh} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
```

**Witness.** `A = {Cp,Ix,Op,Sh}` and `B = {Ix,Op,Sh,Wg}` are both in 𝓡 ∩ 𝓦.
`A ∩ B = {Ix,Op,Sh}`. `Δ` removes nothing from it (every element still has a consumer present),
so `Δ^ω(A ∩ B) = {Ix,Op,Sh}` — but that set violates `L1a`: `Op` needs a price element, whose
only witnesses were `Cp` in A and `Wg` in B, and neither survives the intersection.
So `Δ^ω(A ∩ B) ∉ 𝓡 ∩ 𝓦` and cannot be the meet. The true meet, computed as the largest member
of 𝓡 ∩ 𝓦 below `A ∩ B` (well defined by union-closure), is `{Ix,Sh}`.

**This is the paper's own `prop:noinvariance` biting.** That proposition proves Δ does not preserve
𝓡; `prop:joinmeet` then asserts a formula whose value is `Δ^ω` of something, and the two are
inconsistent whenever Δ has nothing to remove but the intersection has already lost a disjunctive
witness. The paper's stated witness `{Cp,Fl}/{Cl,Fl}` happens to be a case where Δ *does* fire
(`Δ^ω({Fl}) = ∅`, and ∅ is the meet), which is why the error was not visible.

**Correct statement.** The meet exists — 𝓡 ∩ 𝓦 is a complete lattice by `cor:lattice` — and is
`A ⊓ B = ⋃ { C ∈ 𝓡 ∩ 𝓦 : C ⊆ A ∩ B }`, the union of all common lower bounds, exactly as
`cor:lattice`'s own proof says. `Δ^ω(A ∩ B)` is an *upper* estimate of it that is sometimes not
even a member. The clause "and the meet is Δ^ω(A ∩ B)" should be struck.

## 8. `cor:oplusclosed` — VERIFIED, but the attribution around it is partly wrong

> "𝓡 ∩ 𝓦 is closed under ⊕. Composition therefore fails to preserve admissibility only once
> prohibitions are imposed."

```
$ node m4-oplus.mjs
(+)-closure of R n W: 96720 pairs, 0 failures

admissible pool: 2500
pairs 96720; union not admissible: 9883 (10.2%)
  attributable to REQUIREMENTS (closure clauses) : 0
  attributable to WARRANTS                       : 0
  attributable to GROUNDING                      : 0
  attributable to PROHIBITIONS (bansCond)        : 9883
  prohibition rows fired (with multiplicity):
      X21      5679
      X2       2747
      X19*     1188
      X18      1118
  failures where that row was the SOLE cause:
      X21      4955
      X2       2100
      X19*     1032
      X18      976
```

⊕-closure of 𝓡 ∩ 𝓦 holds (0 / 96,720), and it is a consequence of union-closure, so it is a
restatement rather than an independent fact. The half of the sentence that matters is the
attribution, and here is the answer to *which condition produces the failures*:

**No failure comes from a requirement, a warrant, or a grounding clause. Every one of the 9,883
comes from `bansCond`. But `bansCond` is not the prohibition clutter.** Only 4 of its 5
hand-written rows ever fire, and they are not all prohibitions:

```
  X11a*   Uc & !(Aw & At)            => Uc -> Aw ; Uc -> At               DUAL-HORN (a requirement written negatively)
  X19*    Aw & Xf & !(At|Fz|Xm)      => !Aw v !Xf v At v Fz v Xm          MIXED, 2 negative literals — neither Horn nor dual-Horn
  X2      Fl & (Cp|Cl) & (Pl|Cd|Im)  => !Fl v !c v !d for each c,d        PURELY NEGATIVE (Horn) — a genuine prohibition
  X18     Oa & Li & !(Ex|Tp)         => !Oa v !Li v Ex v Tp               MIXED, 2 negative literals — neither Horn nor dual-Horn
  X21     Fl & (Xf|Rl|Of)            => !Fl v !Xf ; !Fl v !Rl ; !Fl v !Of PURELY NEGATIVE (Horn) — a genuine prohibition

per-row union-closure failures, that row alone, 400-member pools:
   X11a*        0 / 79800        <- dual-Horn, union-closed, as predicted by lem:polarity
   X19*      1008 / 79800
   X2        1206 / 79800
   X18       1334 / 79800
   X21      13505 / 79800
```

Consequences for the paper:

1. **The clutter is not doing the work.** Of the 20 recorded prohibition rows, only `X2` projects
   to a positive element set (`HAZ_PROJ` has exactly one member — this confirms `meas:clutter`).
   `X21`, `X19*`, `X18`, `X11a*` are hand-written predicates in the model, not table rows.
   `X2` fires in at most **2,747 of 9,883 failures (27.8%)**, and is the sole cause in 2,100
   (21.2%). So **at least 72% of composition failures are not attributable to the recorded
   prohibition table at all** — they come from hand-written rows, with `X21` alone accounting for
   5,679 (57%). The standing attribution "the failures come from the prohibition clutter" is
   wrong by a factor of ~3.6.
2. **23% of the failures are not prohibitions at all.** `X19*` and `X18` are mixed-polarity
   clauses with two negative literals each. They are neither Horn nor dual-Horn, so they fall
   outside `lem:polarity`'s taxonomy entirely, and they break union-closure for a reason the paper
   never states. `cor:admnotlattice`'s "prohibitions are the sole obstruction" is false as written
   for the shipped model: the sole obstruction is *non-dual-Horn clauses*, of which the
   prohibitions are one species and `X19*`/`X18` another.
3. `X11a*` is a requirement in negative clothing and provably cannot break anything — 0 failures,
   as `lem:polarity` predicts. That is a small positive confirmation of the polarity lemma on real
   data.

## 9. `cor:ourconvex` — VERIFIED (with one number off)

> "D has 15 arcs and 58 strongly connected components, none non-trivial, so it is acyclic; and
> Cn coincides with reachability in D (checked on 21,712 seeds)."

```
$ node m5-convex.mjs
LSTAR (paper's L*): definite (singleton-term) arcs = 13, distinct = 12
   Pl->Ct Im->Ct Cd->Ct Pf->Ct Uc->Aw Uc->At Py->Ep Py->Rd Of->Xm Of->Xf Rl->Au Gs->Au
PARSED_NEW (raw data.ts law strings): definite arcs = 16, distinct = 15
   Pl->Ct Im->Ct Cd->Ct Pf->Ct Op->Ct Uc->Aw Uc->At Pf->Ex Pf->Li Py->Ep Py->Rd Of->Xm Of->Xf Rl->Au Gs->Au

--- LSTAR definite digraph ---
vertices 58; arcs 13; SCCs 58; non-trivial SCCs 0; self-loops 0
ACYCLIC: true
Cn == reachability on all 32567 seeds of size <= 3: mismatches 0
Cn(A u B) == Cn(A) u Cn(B) on 30856 split seeds: failures 0
anti-exchange over 1700 closed sets x 58^2 pairs (5169336 tests): violations 0
thm:excomp  ex(A u B) == max(ex A u ex B) over 1464616 closed pairs: failures 0
elements whose principal closure is themselves (Cn({e}) = {e}): 49 / 58

--- PARSED_NEW definite digraph ---
vertices 58; arcs 16; SCCs 58; non-trivial SCCs 0; self-loops 0
ACYCLIC: true
Cn == reachability on all 32567 seeds of size <= 3: mismatches 0
Cn(A u B) == Cn(A) u Cn(B) on 30856 split seeds: failures 0
anti-exchange over 1697 closed sets x 58^2 pairs (5142758 tests): violations 0
thm:excomp  ex(A u B) == max(ex A u ex B) over 1464616 closed pairs: failures 0
elements whose principal closure is themselves (Cn({e}) = {e}): 48 / 58
```

* **Acyclicity: verified**, 58 SCCs, none non-trivial, no self-loops — under *both* extractions.
* **`Cn` = reachability: verified exhaustively** on all 32,567 seeds of size ≤ 3 (the paper's
  21,712 is a subset of this), 0 mismatches.
* **Union-stability verified** (0 / 30,856), which is the `lem:cm` hypothesis of `thm:convex`.
* **Anti-exchange verified** by direct exhaustive test over 5.1M configurations, independently of
  the acyclicity route.
* **"15 arcs" is the wrong table.** The paper's own corrected law system `L*` yields **13 arcs
  (12 distinct)**. 15 distinct arcs is what the *raw* `data.ts` law strings give (`PARSED_NEW`),
  which additionally contain `Op→Ct`, `Pf→Ex`, `Pf→Li`. Nothing downstream changes — both
  digraphs are acyclic and give the same verdicts — but the figure cited should say which
  extraction it refers to.
* **`cor:ex`'s honesty caveat is if anything understated**: 49 of 58 elements have
  `Cn({e}) = {e}`, so the canonical form is the identity on 84% of singletons.

---

## Files

* `formal/v3/lib.mjs` — seeded harness, membership predicates only
* `formal/v3/m1-closureprops.mjs`, `m1.out` — `meas:closureprops`
* `formal/v3/m2-latticeconf.mjs`, `m2.out` — `meas:latticeconf`, `cor:lattice` hypotheses
* `formal/v3/m3-joinmeet.mjs`, `m3.out` — `prop:joinmeet` (refutation)
* `formal/v3/m4-oplus.mjs`, `m4.out` — `cor:oplusclosed` + failure attribution
* `formal/v3/m5-convex.mjs`, `m5.out` — `cor:ourconvex`, `thm:convex`, `thm:excomp`
* `formal/v3/LEAN-REPORT.md` — full Lean detail (axioms, per-theorem content classification)

---

# Lean targets

Build, verified independently of the lane that wrote the files:

```
$ cd /root/DefiElements/lean && lake build 2>&1 | tail -3; echo "EXIT=$?"
Build completed successfully (734 jobs).
EXIT=0
```

No `sorry`, no `axiom`, no `native_decide`. The only `sorry` string in the tree is prose inside a
doc comment at `ConvexGeometry.lean:352`. **Every new declaration depends on at most
`[propext, Classical.choice, Quot.sound]`**; four (`horn_of_pureNeg`, `dualHorn_reqClause`,
`pureNeg_prohClause`, `horn_prohClause`) depend on only `[propext, Quot.sound]`. The full
verbatim `#print axioms` transcript is in `formal/v3/LEAN-REPORT.md`.

Files: `lean/Defialgebra/Polarity.lean` (new), `lean/Defialgebra/Lattice.lean` (new),
`lean/Defialgebra/ConvexGeometry.lean` (appended, nothing deleted),
`lean/Defialgebra.lean` (two imports added). `Obstruction.lean` untouched.

## 1. `lem:polarity` + `thm:closure` — VERIFIED, both halves

`Polarity.lean`. Clauses as `⟨pos, neg⟩ : Finset E × Finset E`,
`Sat X c := (∃ e ∈ c.pos, e ∈ X) ∨ (∃ e ∈ c.neg, e ∉ X)`, `DualHorn c := c.neg.card ≤ 1`,
`Horn c := c.pos.card ≤ 1`, `PureNeg c := c.pos = ∅`.

| Theorem | Content |
|---|---|
| `sat_union_of_dualHorn` | **REAL, small.** The genuine argument: if both witnesses are negative, `card ≤ 1` forces them equal, and `Finset.mem_union` closes it. ~8 lines. |
| `sat_inter_of_horn` | **REAL, small.** Dual argument on positive literals. |
| `dualHorn_union_closed`, `horn_inter_closed`, `pureNeg_inter_closed` | **TRIVIAL.** Pointwise lifting to clause sets, one line each. |
| `sat_reqClause_iff`, `sat_prohClause_iff` | **REAL, modest.** The bridge from the clause encoding to the paper's own conditions (`s ∈ X → (T ∩ X).Nonempty`, `¬ H ⊆ X`). This is the step that makes the general lemma count as the paper claim rather than as a lemma about an unrelated encoding. |
| `req_models_union_closed`, `proh_models_inter_closed` | **DERIVED.** Transports of the above; short, but they are the statements the paper actually makes. |
| `warrant_models_union_closed` | **TRIVIAL.** Literally `req_models_union_closed` with variables renamed — warrants and requirements have the same clause shape. Counted as zero. |
| `dualHorn_reqClause`, `horn_prohClause`, `pureNeg_prohClause` | **TRIVIAL.** `simp`/`rfl`. |
| `dualHorn_not_inter_closed`, `req_not_inter_closed`, `pureNeg_not_union_closed`, `proh_not_union_closed` | **Real claims, zero-effort proofs (`decide`).** The negative halves of `thm:closure`, which the paper asserts and defers ("the negative halves are witnessed below"). Now witnessed on `Fin 3`: the requirement `(0,{1,2})` holds on `{0,1}` and `{0,2}` but not on `{0}`; the prohibition `{0,1}` holds on `{0}` and `{1}` but not on their union. |

Verdict: the paper's foundation is machine-checked, including the negative halves it left
informal. The mathematical content is genuinely small — it is a pigeonhole on a `card ≤ 1`
finset — but it is proved, not restated, and it is now tied to the paper's own definitions.

## 2. `cor:lattice` — VERIFIED, and honestly low-content

`Lattice.lean`. `structure UnionClosedFamily` (carrier, `∅ ∈`, `univ ∈`, binary-union-closed),
`noncomputable instance completeLattice : CompleteLattice F.carrier`.

mathlib search result, recorded because the instruction was to use mathlib rather than reprove:
`CompleteSublattice` does **not** apply (it demands `sInf`-closure, which 𝓡 ∩ 𝓦 does not have —
that is the whole point of `prop:joinmeet`); `SupClosed` is keyed on subsets of a lattice, not on
the subtype. The usable piece is `completeLatticeOfSup`.

| Theorem | Content |
|---|---|
| `famSup_mem` | **REAL.** The only non-mathlib step: binary union-closure plus `∅ ∈ F` upgrades to closure under arbitrary `sSup` over a `Fintype`, by `Finset.sup_induction`. |
| `completeLattice` | **TRIVIAL given the above** — `completeLatticeOfSup _ F.isLUB_sSup'`. Reported as a one-liner, not as a result. |
| `coe_sup` | **ROUTINE.** Join is union. |
| `inf_eq_sSup`, `coe_inf` | **REAL, modest — and independently important.** The meet is `⋃ {C ∈ F : C ⊆ A ∩ B}`. This is proved in Lean *and* is exactly the formula that refutes `prop:joinmeet` below. Two independent routes to the same correction. |
| `meet_ne_inter` | **Real claim, `decide` proof.** An explicit union-closed family on `Fin 3` containing `∅` and `univ` in which `{0,1} ∩ {0,2} = {0}` is not a member. |

## 3. `thm:convex` — VERIFIED

`ConvexGeometry.lean`. The pre-existing `reachCl_antiExchange_iff` supplied half of this; the new
material completes it.

| Theorem | Content |
|---|---|
| `reachSet_union` / `reachCl_union` | **REAL, modest.** Union-stability of the reachability closure — the `lem:cm` hypothesis, and what makes `A ⊕ B = A ∪ B`. |
| `reachSet_eq_self_iff` | **REAL, modest.** Closed sets are exactly the down-sets of the specialization preorder. |
| `reachCl_antiExchange_iff` | pre-existing; **REAL**, both directions. |
| `thm_convex` | **TRIVIAL.** A bare `⟨_, _, _⟩` bundle of the three above with no new mathematics. It exists so the paper's theorem has one name; it must not be counted as a fourth result. |

Corroborated computationally (`m5-convex.mjs`): union-stability 0 failures / 30,856 splits,
anti-exchange 0 violations / 5,169,336 direct tests, `Cn` = reachability 0 mismatches / 32,567
seeds — on both the `L*` and the raw-parse digraphs.

## 4. `thm:excomp` — VERIFIED, and this is the one with real content

| Theorem | Content |
|---|---|
| `exists_ex_reach_aux` / `exists_ex_reach` | **REAL — the technical heart.** Every element of `S` is reached by an *extreme* element of `S`, by strong induction on `card {x ∈ S : x ≼ b}`, which shrinks strictly only because antisymmetry rules out a 2-cycle stalling the descent. |
| `ex_reachCl_union_ex` | **REAL — the paper's theorem.** `ex (A ∪ B) = max_≼ (ex A ∪ ex B)`, with the filter ranging over the *generators only*. This is strictly stronger than the pre-existing `ex_reachCl_union`, whose filter ranged over all of `A ∪ B` and therefore did not give the linear-time composition law the paper claims. |
| `ex_oplus` | **DERIVED.** The `⊕` form for closed `A, B`, via `reachCl_union_of_closed`. |

**Acyclicity is load-bearing, and that is now machine-checked too.** The Lean statement carries
antisymmetry as a hypothesis, used in exactly two places. That it cannot be dropped is confirmed
computationally (`m6-antisymm-needed.mjs`):

```
$ node m6-antisymm-needed.mjs
digraph: x<->y, x->z, y->z   (one non-trivial SCC {x,y})
A = z      closed? true
B = x,y,z  closed? true
ex(A)      = {z}
ex(B)      = {}
LHS ex(AuB)= {}
RHS max(exA u exB) = {z}
thm:excomp holds here? false
```

Both `A` and `B` are closed, as `thm:excomp` requires, and the identity fails. So the paper's
proof sketch — which derives `thm:excomp` from union-stability alone and never invokes
`cor:ourconvex` — is **incomplete as written**: it needs acyclicity, which the paper has but does
not cite at that point. The theorem is true for this atlas; the sketch is missing a hypothesis.

Corroborated on 1,464,616 closed pairs of the real digraph with 0 failures (`m5.out`), under both
extractions.

## What is *not* improved

`Obstruction.lean` was left untouched, and the earlier audit's finding stands:
`adm_univ_of_consistent` is `exact aft_obstruction …` with a `simp` wrapper and adds nothing to
`aft_obstruction`; `Consistent Γ Δ` is assumed rather than derived. `aft_obstruction` itself is
real (three lines, and the right three lines), `fix_iterate` is a one-line induction. Nothing in
this pass changes that, and the count of genuine theorems in that file remains two.

---

## Provenance note

While this verification ran, a concurrent process in `/root/DefiElements` produced commit
`548dacf` and swept the new `formal/v3/` and `lean/` files into git, and a parallel LaTeX run
rewrote `texput.log`. Neither was done by this verification, which committed nothing and wrote
only inside `lean/` and `formal/v3/`.

===== END FILE =====

===== FILE lean/Defialgebra/ConvexGeometry.lean | SHA256 3b301a6b0179c36b9936c923805a37938a0127f17121a4140929c980819fbca4 =====
/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Order.Closure
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Max
import Mathlib.Data.Fintype.Powerset
import Mathlib.Logic.Relation

/-!
# Anti-exchange closures, unique minimum generators, and reachability

Machine-checked counterparts of Theorems `R` and `U`.

## Main results

* `ex_subset_of_generates` — the "extreme points" `ex c A` sit inside *every* generator of `A`.
  Needs no anti-exchange hypothesis.
* `maximal_closed_gap` — under anti-exchange, a closed set of maximum cardinality strictly
  below a closed `A` (relative to a floor `D`) misses exactly one point of `A`.
* `closure_ex` — under anti-exchange, `ex c A` really generates `A`.
* `unique_minimum_generator` — every closed set has a unique *minimum* generator, `ex c A`.
* `reachCl` — the closure operator generated by unary rules, i.e. reachability in a digraph.
* `reachCl_antiExchange_iff` — the reachability closure is anti-exchange **iff** the
  reachability preorder is antisymmetric (all strongly connected components are trivial).
-/

-- The ambient carrier is a *finite* ground set with decidable equality throughout; several
-- individual statements do not need one or the other, but the uniform signature is deliberate.
set_option linter.unusedFintypeInType false
set_option linter.unusedDecidableInType false
set_option linter.unusedSectionVars false

namespace Defialgebra

namespace ConvexGeometry

variable {E : Type*} [Fintype E] [DecidableEq E]

/-! ## The abstract part: anti-exchange and minimum generators -/

/-- The **anti-exchange** axiom for a closure operator on `Finset E`: from a closed set `A`
and two distinct outside points `x`, `y`, at most one of them can be dragged in by adjoining
the other. -/
def AntiExchange (c : ClosureOperator (Finset E)) : Prop :=
  ∀ A : Finset E, c A = A → ∀ x y : E, x ∉ A → y ∉ A → x ≠ y →
    x ∈ c (insert y A) → y ∉ c (insert x A)

/-- The **extreme points** of `A`: those `a ∈ A` not recoverable from the rest of `A`. -/
def ex (c : ClosureOperator (Finset E)) (A : Finset E) : Finset E :=
  A.filter (fun a => a ∉ c (A.erase a))

variable {c : ClosureOperator (Finset E)}

@[simp] lemma mem_ex {A : Finset E} {a : E} :
    a ∈ ex c A ↔ a ∈ A ∧ a ∉ c (A.erase a) := by
  simp only [ex, Finset.mem_filter]

lemma ex_subset (c : ClosureOperator (Finset E)) (A : Finset E) : ex c A ⊆ A :=
  Finset.filter_subset _ _

/-- Monotonicity of a closure operator, spelled with `⊆` rather than `≤`. -/
lemma cl_mono (c : ClosureOperator (Finset E)) {S T : Finset E} (h : S ⊆ T) : c S ⊆ c T :=
  c.monotone h

lemma subset_cl (c : ClosureOperator (Finset E)) (S : Finset E) : S ⊆ c S :=
  c.le_closure S

/-- **Theorem 1.** The extreme points of `A` are contained in *every* generating set of `A`.
No anti-exchange hypothesis is needed. -/
theorem ex_subset_of_generates (c : ClosureOperator (Finset E)) {A G : Finset E}
    (h : c G = A) : ex c A ⊆ G := by
  intro a ha
  rw [mem_ex] at ha
  by_contra haG
  have hGA : G ⊆ A := by rw [← h]; exact subset_cl c G
  have hGe : G ⊆ A.erase a := Finset.subset_erase.mpr ⟨hGA, haG⟩
  have h2 : A ⊆ c (A.erase a) := by
    have := cl_mono c hGe
    rwa [h] at this
  exact ha.2 (h2 ha.1)

/-- **Theorem 2** (relativised to a floor `D`). This is the only place anti-exchange is used.
If `C` is a closed set of maximum cardinality among the closed sets `C'` with `D ⊆ C' ⊆ A`
and `C' ≠ A`, then `A \ C` is a singleton. -/
theorem maximal_closed_gap (c : ClosureOperator (Finset E)) (hae : AntiExchange c)
    {D A C : Finset E} (hA : c A = A) (hC : c C = C)
    (hDC : D ⊆ C) (hCA : C ⊆ A) (hCne : C ≠ A)
    (hmax : ∀ C' : Finset E, c C' = C' → D ⊆ C' → C' ⊆ A → C' ≠ A → C'.card ≤ C.card) :
    ∃ x : E, A \ C = {x} := by
  -- Adjoining any point of `A \ C` to `C` and closing already reaches all of `A`.
  have key : ∀ z ∈ A \ C, c (insert z C) = A := by
    intro z hz
    obtain ⟨hzA, hzC⟩ := Finset.mem_sdiff.mp hz
    have hsubA : insert z C ⊆ A := Finset.insert_subset hzA hCA
    have h1 : c (insert z C) ⊆ A := by
      have := cl_mono c hsubA
      rwa [hA] at this
    have h2 : C ⊆ c (insert z C) :=
      (Finset.subset_insert z C).trans (subset_cl c _)
    have hzmem : z ∈ c (insert z C) := subset_cl c _ (Finset.mem_insert_self z C)
    by_contra hne
    have hle : (c (insert z C)).card ≤ C.card :=
      hmax _ (c.idempotent _) (hDC.trans h2) h1 hne
    have hss : C ⊂ c (insert z C) :=
      (Finset.ssubset_iff_of_subset h2).mpr ⟨z, hzmem, hzC⟩
    exact absurd (Finset.card_lt_card hss) (not_lt.mpr hle)
  have hne : (A \ C).Nonempty := by
    rw [Finset.sdiff_nonempty]
    intro hAC
    exact hCne (Finset.Subset.antisymm hCA hAC)
  have hcard : (A \ C).card ≤ 1 := by
    by_contra hgt
    rw [not_le] at hgt
    obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hgt
    have hxC : x ∉ C := (Finset.mem_sdiff.mp hx).2
    have hyC : y ∉ C := (Finset.mem_sdiff.mp hy).2
    have hyin : y ∈ c (insert x C) := by
      rw [key x hx]; exact (Finset.mem_sdiff.mp hy).1
    have hxin : x ∈ c (insert y C) := by
      rw [key y hy]; exact (Finset.mem_sdiff.mp hx).1
    exact hae C hC x y hxC hyC hxy hxin hyin
  exact Finset.card_eq_one.mp (Nat.le_antisymm hcard (Finset.card_pos.mpr hne))

/-- Unrelativised form of `maximal_closed_gap` (take `D = ∅`). -/
theorem maximal_closed_gap' (c : ClosureOperator (Finset E)) (hae : AntiExchange c)
    {A C : Finset E} (hA : c A = A) (hC : c C = C) (hCA : C ⊆ A) (hCne : C ≠ A)
    (hmax : ∀ C' : Finset E, c C' = C' → C' ⊆ A → C' ≠ A → C'.card ≤ C.card) :
    ∃ x : E, A \ C = {x} :=
  maximal_closed_gap c hae hA hC (Finset.empty_subset _) hCA hCne
    (fun C' h1 _ h3 h4 => hmax C' h1 h3 h4)

/-- **Theorem 3.** Under anti-exchange, the extreme points of a closed set generate it. -/
theorem closure_ex (c : ClosureOperator (Finset E)) (hae : AntiExchange c)
    {A : Finset E} (hA : c A = A) : c (ex c A) = A := by
  have hDA : c (ex c A) ⊆ A := by
    have := cl_mono c (ex_subset c A)
    rwa [hA] at this
  by_contra hDne
  have hDF : c (ex c A) ∈
      (Finset.univ : Finset (Finset E)).filter
        (fun C => c C = C ∧ c (ex c A) ⊆ C ∧ C ⊆ A ∧ C ≠ A) := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨c.idempotent _, Finset.Subset.refl _, hDA, hDne⟩
  obtain ⟨C, hCF, hCmax⟩ :=
    Finset.exists_max_image
      ((Finset.univ : Finset (Finset E)).filter
        (fun C => c C = C ∧ c (ex c A) ⊆ C ∧ C ⊆ A ∧ C ≠ A))
      Finset.card ⟨_, hDF⟩
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hCF
  obtain ⟨hCcl, hDC, hCA, hCne⟩ := hCF
  have hmax : ∀ C' : Finset E, c C' = C' → c (ex c A) ⊆ C' → C' ⊆ A → C' ≠ A →
      C'.card ≤ C.card := by
    intro C' h1 h2 h3 h4
    refine hCmax C' ?_
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨h1, h2, h3, h4⟩
  obtain ⟨x, hx⟩ := maximal_closed_gap c hae hA hCcl hDC hCA hCne hmax
  have hxmem : x ∈ A \ C := by rw [hx]; exact Finset.mem_singleton_self x
  have hxA : x ∈ A := (Finset.mem_sdiff.mp hxmem).1
  have hxC : x ∉ C := (Finset.mem_sdiff.mp hxmem).2
  have heq : A.erase x = C := by
    apply Finset.Subset.antisymm
    · intro a ha
      rw [Finset.mem_erase] at ha
      by_contra haC
      have hmem : a ∈ A \ C := Finset.mem_sdiff.mpr ⟨ha.2, haC⟩
      rw [hx, Finset.mem_singleton] at hmem
      exact ha.1 hmem
    · intro a ha
      rw [Finset.mem_erase]
      exact ⟨fun h => hxC (h ▸ ha), hCA ha⟩
  have hxex : x ∈ ex c A := by
    rw [mem_ex, heq, hCcl]
    exact ⟨hxA, hxC⟩
  exact hxC (hDC (subset_cl c _ hxex))

/-- **Theorem 4 / Theorem U.** Every closed set `A` has a unique *minimum* generator, and it is
`ex c A`: it generates `A`, and it is contained in every other generator. -/
theorem unique_minimum_generator (c : ClosureOperator (Finset E)) (hae : AntiExchange c)
    {A : Finset E} (hA : c A = A) :
    ∃! G : Finset E, c G = A ∧ ∀ G' : Finset E, c G' = A → G ⊆ G' := by
  refine ⟨ex c A, ⟨closure_ex c hae hA, fun G' hG' => ex_subset_of_generates c hG'⟩, ?_⟩
  rintro G ⟨hG1, hG2⟩
  exact Finset.Subset.antisymm (hG2 _ (closure_ex c hae hA))
    (ex_subset_of_generates c hG1)

/-- The two halves of `unique_minimum_generator`, stated separately. -/
theorem ex_isMinimumGenerator (c : ClosureOperator (Finset E)) (hae : AntiExchange c)
    {A : Finset E} (hA : c A = A) :
    c (ex c A) = A ∧ ∀ G : Finset E, c G = A → ex c A ⊆ G :=
  ⟨closure_ex c hae hA, fun _ hG => ex_subset_of_generates c hG⟩

/-! ## The reachability part: Theorem R -/

section Reach

variable (r : E → E → Prop) [DecidableRel (Relation.ReflTransGen r)]

/-- The set of vertices reachable from `S` along `r`. -/
def reachSet (S : Finset E) : Finset E :=
  Finset.univ.filter (fun x => ∃ s ∈ S, Relation.ReflTransGen r s x)

@[simp] lemma mem_reachSet {S : Finset E} {x : E} :
    x ∈ reachSet r S ↔ ∃ s ∈ S, Relation.ReflTransGen r s x := by
  simp only [reachSet, Finset.mem_filter, Finset.mem_univ, true_and]

lemma reachSet_mono {S T : Finset E} (h : S ⊆ T) : reachSet r S ⊆ reachSet r T := by
  intro x hx
  rw [mem_reachSet] at hx ⊢
  obtain ⟨s, hs, hsx⟩ := hx
  exact ⟨s, h hs, hsx⟩

lemma subset_reachSet (S : Finset E) : S ⊆ reachSet r S := by
  intro x hx
  rw [mem_reachSet]
  exact ⟨x, hx, Relation.ReflTransGen.refl⟩

lemma reachSet_idem (S : Finset E) : reachSet r (reachSet r S) = reachSet r S := by
  apply Finset.Subset.antisymm _ (subset_reachSet r _)
  intro x hx
  rw [mem_reachSet] at hx
  obtain ⟨s, hs, hsx⟩ := hx
  rw [mem_reachSet] at hs
  obtain ⟨t, ht, hts⟩ := hs
  rw [mem_reachSet]
  exact ⟨t, ht, hts.trans hsx⟩

/-- Reachability as a closure operator on `Finset E`. This is exactly the closure generated
by the unary rules `s → e` of the digraph `r`. -/
def reachCl : ClosureOperator (Finset E) where
  toFun := reachSet r
  monotone' := fun _ _ h => reachSet_mono r h
  le_closure' := fun S => subset_reachSet r S
  idempotent' := fun S => reachSet_idem r S

@[simp] lemma reachCl_apply (S : Finset E) : reachCl r S = reachSet r S := rfl

lemma reachSet_empty : reachSet r (∅ : Finset E) = ∅ := by
  ext x
  simp

/-- The key computational lemma: closing an insertion splits. -/
lemma reachSet_insert (x : E) (A : Finset E) :
    reachSet r (insert x A) = reachSet r A ∪ reachSet r {x} := by
  ext z
  simp only [mem_reachSet, Finset.mem_union, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨s, (rfl | hs), hsz⟩
    · exact Or.inr ⟨s, rfl, hsz⟩
    · exact Or.inl ⟨s, hs, hsz⟩
  · rintro (⟨s, hs, hsz⟩ | ⟨s, rfl, hsz⟩)
    · exact ⟨s, Or.inr hs, hsz⟩
    · exact ⟨s, Or.inl rfl, hsz⟩

/-- For a closed `A`, membership in `reachSet r (insert y A)` is membership in `A` or
reachability from `y`. -/
lemma mem_reachSet_insert_of_closed {A : Finset E} (hA : reachSet r A = A) (y x : E) :
    x ∈ reachSet r (insert y A) ↔ x ∈ A ∨ Relation.ReflTransGen r y x := by
  rw [mem_reachSet]
  constructor
  · rintro ⟨s, hs, hsx⟩
    rcases Finset.mem_insert.mp hs with rfl | hs
    · exact Or.inr hsx
    · refine Or.inl ?_
      rw [← hA, mem_reachSet]
      exact ⟨s, hs, hsx⟩
  · rintro (hx | hyx)
    · exact ⟨x, Finset.mem_insert_of_mem hx, Relation.ReflTransGen.refl⟩
    · exact ⟨y, Finset.mem_insert_self _ _, hyx⟩

/-- **Theorem R, forward direction.** If the reachability preorder is antisymmetric (every
strongly connected component is trivial) then the reachability closure is anti-exchange. -/
theorem reachCl_antiExchange_of_antisymm
    (h : ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y) :
    AntiExchange (reachCl r) := by
  intro A hA x y hxA hyA hxy hx
  have hA' : reachSet r A = A := hA
  rw [reachCl_apply, mem_reachSet_insert_of_closed r hA'] at hx
  have hyx : Relation.ReflTransGen r y x := hx.resolve_left hxA
  intro hy
  rw [reachCl_apply, mem_reachSet_insert_of_closed r hA'] at hy
  have hxy' : Relation.ReflTransGen r x y := hy.resolve_left hyA
  exact hxy (h x y hxy' hyx)

/-- **Theorem R, converse direction.** If the reachability closure is anti-exchange then the
reachability preorder is antisymmetric. -/
theorem antisymm_of_reachCl_antiExchange (h : AntiExchange (reachCl r)) :
    ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y := by
  intro x y hxy hyx
  by_contra hne
  have hcl : reachCl r (∅ : Finset E) = ∅ := reachSet_empty r
  have hx : x ∈ reachCl r (insert y (∅ : Finset E)) := by
    rw [reachCl_apply, mem_reachSet]
    exact ⟨y, Finset.mem_insert_self _ _, hyx⟩
  refine h ∅ hcl x y (Finset.notMem_empty x) (Finset.notMem_empty y) hne hx ?_
  rw [reachCl_apply, mem_reachSet]
  exact ⟨x, Finset.mem_insert_self _ _, hxy⟩

/-- **Theorem R.** The reachability closure satisfies anti-exchange if and only if the
reachability preorder is antisymmetric. -/
theorem reachCl_antiExchange_iff :
    AntiExchange (reachCl r) ↔
      ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y :=
  ⟨antisymm_of_reachCl_antiExchange r, reachCl_antiExchange_of_antisymm r⟩

/-! ### The extreme points of a reachability closure are the minimal elements -/

/-- For the reachability closure, `ex` computes the `≤`-**minimal** elements of `A`, where
`≤` is the reachability preorder. (Antisymmetry is not needed for this identification; under
antisymmetry `≤` is a genuine partial order and these are minimal in the usual sense.) -/
theorem ex_reachCl (A : Finset E) :
    ex (reachCl r) A =
      A.filter (fun a => ∀ b ∈ A, Relation.ReflTransGen r b a → b = a) := by
  ext a
  rw [mem_ex, Finset.mem_filter, reachCl_apply]
  constructor
  · rintro ⟨haA, h⟩
    refine ⟨haA, fun b hbA hba => ?_⟩
    by_contra hne
    exact h ((mem_reachSet r).mpr ⟨b, Finset.mem_erase.mpr ⟨hne, hbA⟩, hba⟩)
  · rintro ⟨haA, h⟩
    refine ⟨haA, fun hmem => ?_⟩
    obtain ⟨b, hb, hba⟩ := (mem_reachSet r).mp hmem
    obtain ⟨hbne, hbA⟩ := Finset.mem_erase.mp hb
    exact hbne (h b hbA hba)

/-- Composition law: the extreme points of a union are the extreme points of the two pieces,
filtered down to those still minimal in the union. -/
theorem ex_reachCl_union (A B : Finset E) :
    ex (reachCl r) (A ∪ B) =
      (ex (reachCl r) A ∪ ex (reachCl r) B).filter
        (fun a => ∀ b ∈ A ∪ B, Relation.ReflTransGen r b a → b = a) := by
  ext a
  simp only [ex_reachCl, Finset.mem_filter, Finset.mem_union]
  constructor
  · rintro ⟨haAB, hmin⟩
    refine ⟨?_, hmin⟩
    rcases haAB with h | h
    · exact Or.inl ⟨h, fun b hb hba => hmin b (Or.inl hb) hba⟩
    · exact Or.inr ⟨h, fun b hb hba => hmin b (Or.inr hb) hba⟩
  · rintro ⟨(⟨h, _⟩ | ⟨h, _⟩), hmin⟩
    · exact ⟨Or.inl h, hmin⟩
    · exact ⟨Or.inr h, hmin⟩

end Reach

/-! ## Axiom audit

Every named result above depends only on Lean's three standard axioms (in fact several depend
on strictly fewer). No `sorry`, no new axioms.
-/

section AxiomAudit

#print axioms Defialgebra.ConvexGeometry.mem_ex
#print axioms Defialgebra.ConvexGeometry.ex_subset
#print axioms Defialgebra.ConvexGeometry.cl_mono
#print axioms Defialgebra.ConvexGeometry.subset_cl
#print axioms Defialgebra.ConvexGeometry.ex_subset_of_generates
#print axioms Defialgebra.ConvexGeometry.maximal_closed_gap
#print axioms Defialgebra.ConvexGeometry.maximal_closed_gap'
#print axioms Defialgebra.ConvexGeometry.closure_ex
#print axioms Defialgebra.ConvexGeometry.unique_minimum_generator
#print axioms Defialgebra.ConvexGeometry.ex_isMinimumGenerator
#print axioms Defialgebra.ConvexGeometry.mem_reachSet
#print axioms Defialgebra.ConvexGeometry.reachSet_mono
#print axioms Defialgebra.ConvexGeometry.subset_reachSet
#print axioms Defialgebra.ConvexGeometry.reachSet_idem
#print axioms Defialgebra.ConvexGeometry.reachCl
#print axioms Defialgebra.ConvexGeometry.reachCl_apply
#print axioms Defialgebra.ConvexGeometry.reachSet_empty
#print axioms Defialgebra.ConvexGeometry.reachSet_insert
#print axioms Defialgebra.ConvexGeometry.mem_reachSet_insert_of_closed
#print axioms Defialgebra.ConvexGeometry.reachCl_antiExchange_of_antisymm
#print axioms Defialgebra.ConvexGeometry.antisymm_of_reachCl_antiExchange
#print axioms Defialgebra.ConvexGeometry.reachCl_antiExchange_iff
#print axioms Defialgebra.ConvexGeometry.ex_reachCl
#print axioms Defialgebra.ConvexGeometry.ex_reachCl_union

end AxiomAudit


/-! ## Union-stability, down-sets, and the composition law for canonical forms

Paper: `lem:cm` (union-stability for singleton premises), `thm:convex`, `cor:ex`, `thm:excomp`.

Orientation warning. The paper's specialization preorder is `a ≽ b ↔ b ∈ Cn {a}`, i.e.
`a ≽ b` exactly when `a` reaches `b` along `r`. Consequently a `≼`-**maximal** element of `A`
is one that no *other* element of `A` reaches — reachability-**minimal**. This is exactly the
predicate used by `ex_reachCl`, so `ex = max_≼` as claimed in `cor:ex`.
-/

section ReachExtra

variable (r : E → E → Prop) [DecidableRel (Relation.ReflTransGen r)]

/-- **Union-stability** (paper `lem:cm`, the content that makes `A ⊕ B = A ∪ B`). Because
every definite rule has a *singleton* premise, the reachability closure distributes over
union. -/
theorem reachSet_union (A B : Finset E) :
    reachSet r (A ∪ B) = reachSet r A ∪ reachSet r B := by
  ext z
  simp only [mem_reachSet, Finset.mem_union]
  constructor
  · rintro ⟨s, (hs | hs), hsz⟩
    · exact Or.inl ⟨s, hs, hsz⟩
    · exact Or.inr ⟨s, hs, hsz⟩
  · rintro (⟨s, hs, hsz⟩ | ⟨s, hs, hsz⟩)
    · exact ⟨s, Or.inl hs, hsz⟩
    · exact ⟨s, Or.inr hs, hsz⟩

/-- Same statement for the closure operator. -/
theorem reachCl_union (A B : Finset E) :
    reachCl r (A ∪ B) = reachCl r A ∪ reachCl r B := reachSet_union r A B

/-- For closed `A` and `B`, the composite `A ⊕ B = Cn (A ∪ B)` is literally `A ∪ B`. -/
theorem reachCl_union_of_closed {A B : Finset E}
    (hA : reachCl r A = A) (hB : reachCl r B = B) : reachCl r (A ∪ B) = A ∪ B := by
  rw [reachCl_union, hA, hB]

/-- **The closed sets are exactly the down-sets of the specialization preorder** (paper
`thm:convex`, second half). Here "down-set" is taken in the `≼`-orientation of the paper:
`A` is closed iff everything `a ∈ A` reaches stays in `A`. -/
theorem reachSet_eq_self_iff (A : Finset E) :
    reachSet r A = A ↔ ∀ a ∈ A, ∀ b : E, Relation.ReflTransGen r a b → b ∈ A := by
  constructor
  · intro h a ha b hab
    rw [← h, mem_reachSet]
    exact ⟨a, ha, hab⟩
  · intro h
    refine Finset.Subset.antisymm ?_ (subset_reachSet r A)
    intro x hx
    obtain ⟨s, hs, hsx⟩ := (mem_reachSet r).mp hx
    exact h s hs x hsx

/-- **Paper `thm:convex`, bundled.** The reachability closure is always union-stable and its
closed sets are always the down-sets of the specialization preorder; it satisfies
anti-exchange exactly when that preorder is antisymmetric, i.e. when the digraph is acyclic,
in which case the preorder is a genuine partial order. -/
theorem thm_convex :
    (∀ A B : Finset E, reachCl r (A ∪ B) = reachCl r A ∪ reachCl r B) ∧
      (∀ A : Finset E, reachCl r A = A ↔ ∀ a ∈ A, ∀ b : E, Relation.ReflTransGen r a b → b ∈ A) ∧
      (AntiExchange (reachCl r) ↔
        ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y) :=
  ⟨reachCl_union r, reachSet_eq_self_iff r, reachCl_antiExchange_iff r⟩

/-! ### Descent to extreme points

The technical heart of `thm:excomp`. Antisymmetry of reachability is genuinely needed: with a
2-cycle `x ⇄ y` and `S = {x, y}` we have `ex S = ∅`, so no extreme point of `S` reaches `x`.
-/

/-- Every element of `S` is reached by an *extreme* element of `S`. Proved by strong
induction on the size of the down-set `{x ∈ S : x ≼ b}`; antisymmetry is what makes that
set shrink strictly at each step. -/
theorem exists_ex_reach_aux
    (hanti : ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y)
    (S : Finset E) : ∀ (n : ℕ) (b : E), b ∈ S →
      (S.filter (fun x => Relation.ReflTransGen r x b)).card ≤ n →
      ∃ b' ∈ ex (reachCl r) S, Relation.ReflTransGen r b' b := by
  intro n
  induction n with
  | zero =>
    intro b hb hcard
    have hpos : 0 < (S.filter (fun x => Relation.ReflTransGen r x b)).card :=
      Finset.card_pos.mpr ⟨b, Finset.mem_filter.mpr ⟨hb, Relation.ReflTransGen.refl⟩⟩
    exact absurd hcard (by omega)
  | succ n ih =>
    intro b hb hcard
    by_cases h : ∀ y ∈ S, Relation.ReflTransGen r y b → y = b
    · refine ⟨b, ?_, Relation.ReflTransGen.refl⟩
      rw [ex_reachCl, Finset.mem_filter]
      exact ⟨hb, h⟩
    · push_neg at h
      obtain ⟨y, hyS, hyb, hne⟩ := h
      -- the down-set of `y` is a *strict* subset of the down-set of `b`
      have hsub : S.filter (fun x => Relation.ReflTransGen r x y) ⊆
          S.filter (fun x => Relation.ReflTransGen r x b) := by
        intro x hx
        obtain ⟨hxS, hxy⟩ := Finset.mem_filter.mp hx
        exact Finset.mem_filter.mpr ⟨hxS, hxy.trans hyb⟩
      have hbnot : b ∉ S.filter (fun x => Relation.ReflTransGen r x y) := by
        intro hbm
        exact hne (hanti y b hyb (Finset.mem_filter.mp hbm).2)
      have hssub : S.filter (fun x => Relation.ReflTransGen r x y) ⊂
          S.filter (fun x => Relation.ReflTransGen r x b) :=
        (Finset.ssubset_iff_of_subset hsub).mpr
          ⟨b, Finset.mem_filter.mpr ⟨hb, Relation.ReflTransGen.refl⟩, hbnot⟩
      have hlt := Finset.card_lt_card hssub
      obtain ⟨b', hb'ex, hb'y⟩ := ih y hyS (by omega)
      exact ⟨b', hb'ex, hb'y.trans hyb⟩

/-- Every element of `S` is reached by an extreme point of `S` (under acyclicity). -/
theorem exists_ex_reach
    (hanti : ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y)
    {S : Finset E} {b : E} (hb : b ∈ S) :
    ∃ b' ∈ ex (reachCl r) S, Relation.ReflTransGen r b' b :=
  exists_ex_reach_aux r hanti S _ b hb le_rfl

/-- **Paper `thm:excomp`.** The extreme points of a union are the `≼`-maximal elements of the
union of the extreme points — the filter now ranges over the *generators only*, which is what
makes the law computable in `|ex A| + |ex B|`. Acyclicity is required. -/
theorem ex_reachCl_union_ex
    (hanti : ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y)
    (A B : Finset E) :
    ex (reachCl r) (A ∪ B)
      = (ex (reachCl r) A ∪ ex (reachCl r) B).filter
          (fun a => ∀ b ∈ ex (reachCl r) A ∪ ex (reachCl r) B,
            Relation.ReflTransGen r b a → b = a) := by
  have hPsub : ex (reachCl r) A ∪ ex (reachCl r) B ⊆ A ∪ B :=
    Finset.union_subset_union (ex_subset _ A) (ex_subset _ B)
  ext a
  rw [ex_reachCl, Finset.mem_filter, Finset.mem_filter]
  constructor
  · -- easy direction: minimal over `A ∪ B` implies extreme in its own side and minimal over
    -- the smaller set of generators
    rintro ⟨haAB, hmin⟩
    refine ⟨?_, fun b hb hba => hmin b (hPsub hb) hba⟩
    rw [Finset.mem_union] at haAB ⊢
    rcases haAB with h | h
    · refine Or.inl ?_
      rw [ex_reachCl, Finset.mem_filter]
      exact ⟨h, fun b hb hba => hmin b (Finset.mem_union_left _ hb) hba⟩
    · refine Or.inr ?_
      rw [ex_reachCl, Finset.mem_filter]
      exact ⟨h, fun b hb hba => hmin b (Finset.mem_union_right _ hb) hba⟩
  · -- hard direction: descend an arbitrary `b ≼ a` to an extreme point of its own side
    rintro ⟨haP, hmin⟩
    refine ⟨hPsub haP, fun b hb hba => ?_⟩
    by_contra hne
    have hdesc : ∃ b' ∈ ex (reachCl r) A ∪ ex (reachCl r) B,
        Relation.ReflTransGen r b' b := by
      rcases Finset.mem_union.mp hb with h | h
      · obtain ⟨b', hb', hb'b⟩ := exists_ex_reach r hanti h
        exact ⟨b', Finset.mem_union_left _ hb', hb'b⟩
      · obtain ⟨b', hb', hb'b⟩ := exists_ex_reach r hanti h
        exact ⟨b', Finset.mem_union_right _ hb', hb'b⟩
    obtain ⟨b', hb'P, hb'b⟩ := hdesc
    -- `b'` is a generator reaching `a`, so minimality of `a` over the generators forces
    -- `b' = a`; then `a` and `b` reach each other and antisymmetry kills the assumption.
    have hb'a : Relation.ReflTransGen r b' a := hb'b.trans hba
    have : b' = a := hmin b' hb'P hb'a
    subst this
    exact hne (hanti b' b hb'b hba).symm

/-- **Paper `thm:excomp`, in `⊕` form.** For *closed* `A` and `B` the composite is
`Cn (A ∪ B)` and its canonical form is computed from the canonical forms of the parts. -/
theorem ex_oplus
    (hanti : ∀ x y : E, Relation.ReflTransGen r x y → Relation.ReflTransGen r y x → x = y)
    {A B : Finset E} (hA : reachCl r A = A) (hB : reachCl r B = B) :
    ex (reachCl r) (reachCl r (A ∪ B))
      = (ex (reachCl r) A ∪ ex (reachCl r) B).filter
          (fun a => ∀ b ∈ ex (reachCl r) A ∪ ex (reachCl r) B,
            Relation.ReflTransGen r b a → b = a) := by
  rw [reachCl_union_of_closed r hA hB]
  exact ex_reachCl_union_ex r hanti A B

end ReachExtra

section AxiomAudit2

#print axioms Defialgebra.ConvexGeometry.reachSet_union
#print axioms Defialgebra.ConvexGeometry.reachCl_union
#print axioms Defialgebra.ConvexGeometry.reachCl_union_of_closed
#print axioms Defialgebra.ConvexGeometry.reachSet_eq_self_iff
#print axioms Defialgebra.ConvexGeometry.thm_convex
#print axioms Defialgebra.ConvexGeometry.exists_ex_reach_aux
#print axioms Defialgebra.ConvexGeometry.exists_ex_reach
#print axioms Defialgebra.ConvexGeometry.ex_reachCl_union_ex
#print axioms Defialgebra.ConvexGeometry.ex_oplus

end AxiomAudit2

end ConvexGeometry

end Defialgebra

===== END FILE =====

===== FILE lean/Defialgebra/Extremal.lean | SHA256 971391a3f4e733f935d5cba957a41c1c9e5db63748dd64db444267481e47b163 =====
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.List.Basic
import Mathlib.Data.List.Sort
import Mathlib.Tactic.Linarith

/-!
# Gate 0.2 — extremal prefix allocation vs the sum-local filter class

## Formal claim (precise)

Let `SumAgg` be the observation interface `(totalSize, count, demand)` and let a
**sum-local selector** be any `phi : Claim → SumAgg → Bool`. The class
`LocalSel phi` is closed under the finite grammar `SumLocalProg` (atomic
selectors and conjunction). No program in that class can match **general**
extremal prefix fill on both of the two-claim unit-demand populations below.

That is the invariant every `SumLocalProg` composite preserves (still some
`LocalSel`) and extremal prefix fill breaks.

## What this is not

* Not the full F9 record of `REFUTATION.md` (no settlement price, limit vector,
  or conservation game). Extremal here is the **priority-order demand prefix**
  fragment used by R2 (Liquity-style walk).
* Not a claim that every Quint fold in the corpus is definitionally `LocalSel`.
  The reproducible bridge is the fold census artifact
  `sigma/GATE-0.2-FOLD-CENSUS.md` (**52** `acc + ...` folds and **1** identity fold);
  the formal theorem is about the sum-local filter class that census motivates.
* Not the delegated-allocation mandate refuter.
-/

namespace Defialgebra.Extremal

structure Claim where
  id : Nat
  size : Nat
  priority : Nat
  deriving DecidableEq, Repr, Inhabited

structure SumAgg where
  totalSize : Nat
  count : Nat
  demand : Nat
  deriving DecidableEq, Repr

def sumAgg (cs : List Claim) (demand : Nat) : SumAgg where
  totalSize := (cs.map (fun c => c.size)).sum
  count := cs.length
  demand := demand

/-- Priority-then-id total preorder (ascending: earlier first). -/
def prioLE (a b : Claim) : Prop :=
  a.priority < b.priority ∨ (a.priority = b.priority ∧ a.id ≤ b.id)

instance : DecidableRel prioLE := fun a b => by
  dsimp [prioLE]; infer_instance

def prioLeB (a b : Claim) : Bool :=
  decide (prioLE a b)

/-- Take a demand-bounded prefix of an already priority-sorted list.
Partial last fill: the last claim is kept with `size` reduced to residual demand. -/
def takeDemand : List Claim → Nat → List Claim
  | _, 0 => []
  | [], _ => []
  | c :: rest, d =>
      if c.size ≥ d then
        [{ c with size := d }]
      else
        c :: takeDemand rest (d - c.size)

/-- **General extremal prefix fill:** sort by `prioLE`, then `takeDemand`. -/
def extremalFill (cs : List Claim) (demand : Nat) : List Claim :=
  takeDemand (cs.insertionSort prioLE) demand

/-- Selected claim ids (ignores partial-size annotation on the last fill). -/
def fillIds (cs : List Claim) (demand : Nat) : List Nat :=
  (extremalFill cs demand).map (fun c => c.id)

/-- Local (sum-aggregate) selection filter. -/
def LocalSel (phi : Claim → SumAgg → Bool) (cs : List Claim) (demand : Nat) :
    List Claim :=
  cs.filter (fun c => phi c (sumAgg cs demand))

def localIds (phi : Claim → SumAgg → Bool) (cs : List Claim) (demand : Nat) :
    List Nat :=
  (LocalSel phi cs demand).map (fun c => c.id)

/-! ## Sum-local program grammar and closure -/

/-- Finite programs that only ever filter by sum-local predicates. -/
inductive SumLocalProg : Type where
  | atom (phi : Claim → SumAgg → Bool)
  | and (p q : SumLocalProg)

/-- Interpretation: every program is some single filter predicate. -/
def SumLocalProg.eval : SumLocalProg → Claim → SumAgg → Bool
  | atom phi, c, g => phi c g
  | and p q, c, g => p.eval c g && q.eval c g

/-- Running a program is exactly `LocalSel` of its evaluation. -/
theorem run_eq_localSel (p : SumLocalProg) (cs : List Claim) (d : Nat) :
    cs.filter (fun c => p.eval c (sumAgg cs d)) = LocalSel p.eval cs d := by
  rfl

/-- **Closure / composite invariant:** conjunction of sum-local selectors is
still a sum-local selector (the evaluation of `and`). -/
theorem sumLocal_and_eval (p q : SumLocalProg) :
    (SumLocalProg.and p q).eval =
      fun c g => p.eval c g && q.eval c g := by
  rfl

/-- Conjunction of programs is still an evaluated selector (class closed under `and`). -/
theorem eval_and (p q : SumLocalProg) :
    (SumLocalProg.and p q).eval = fun c g => p.eval c g && q.eval c g := rfl

/-- Filtering by an `and` program equals sequential filtering at the same aggregate. -/
theorem localSel_and (p q : SumLocalProg) (cs : List Claim) (d : Nat) :
    LocalSel (SumLocalProg.and p q).eval cs d =
      (LocalSel p.eval cs d).filter (fun c => q.eval c (sumAgg cs d)) := by
  simp [LocalSel, SumLocalProg.eval, List.filter_filter, Bool.and_comm]

/-- Atomic programs are sum-local by definition. -/
theorem atom_is_local (phi : Claim → SumAgg → Bool) (cs : List Claim) (d : Nat) :
    LocalSel (SumLocalProg.atom phi).eval cs d = LocalSel phi cs d := by
  rfl

/-! ## Concrete separation witnesses -/

def cA : Claim := ⟨0, 1, 5⟩
def cB : Claim := ⟨1, 1, 10⟩
def cC : Claim := ⟨2, 1, 3⟩

theorem sumAgg_AB : sumAgg [cA, cB] 1 = ⟨2, 2, 1⟩ := by decide
theorem sumAgg_AC : sumAgg [cA, cC] 1 = ⟨2, 2, 1⟩ := by decide
theorem sumAgg_eq : sumAgg [cA, cB] 1 = sumAgg [cA, cC] 1 := by
  simp [sumAgg_AB, sumAgg_AC]

theorem prioLE_AB : prioLE cA cB := by dsimp [prioLE, cA, cB]; decide
theorem not_prioLE_AC : ¬ prioLE cA cC := by dsimp [prioLE, cA, cC]; decide
theorem prioLE_CA : prioLE cC cA := by dsimp [prioLE, cC, cA]; decide

/-- insertionSort of two elements when the first is already earlier. -/
theorem sort_AB : [cA, cB].insertionSort prioLE = [cA, cB] := by
  rw [List.insertionSort_cons, List.insertionSort_cons, List.insertionSort_nil]
  -- orderedInsert cA (orderedInsert cB [])
  have hb : List.orderedInsert (r := prioLE) cB ([] : List Claim) = [cB] := by
    simp [List.orderedInsert]
  rw [hb]
  exact List.orderedInsert_cons_of_le (r := prioLE) (a := cA) (b := cB) (l := []) prioLE_AB

theorem sort_AC : [cA, cC].insertionSort prioLE = [cC, cA] := by
  rw [List.insertionSort_cons, List.insertionSort_cons, List.insertionSort_nil]
  have hc : List.orderedInsert (r := prioLE) cC ([] : List Claim) = [cC] := by
    simp [List.orderedInsert]
  rw [hc]
  have h := List.orderedInsert_of_not_le (r := prioLE) (a := cA) (b := cC) (l := []) not_prioLE_AC
  rw [h]
  have ha : List.orderedInsert (r := prioLE) cA ([] : List Claim) = [cA] := by
    simp [List.orderedInsert]
  rw [ha]

theorem takeDemand_unit (c : Claim) (hc : c.size = 1) :
    takeDemand [c] 1 = [{ c with size := 1 }] := by
  simp [takeDemand, hc]

theorem extremal_AB :
    (extremalFill [cA, cB] 1).map (fun c => c.id) = [0] := by
  unfold extremalFill
  rw [sort_AB]
  simp [takeDemand, cA]

theorem extremal_AC :
    (extremalFill [cA, cC] 1).map (fun c => c.id) = [2] := by
  unfold extremalFill
  rw [sort_AC]
  -- takeDemand [cC, cA] 1 = [{cC with size := 1}]
  simp [takeDemand, cC]

theorem mem_localSel_iff (phi : Claim → SumAgg → Bool) (c : Claim)
    (cs : List Claim) (d : Nat) :
    c ∈ LocalSel phi cs d ↔ c ∈ cs ∧ phi c (sumAgg cs d) = true := by
  simp [LocalSel, List.mem_filter]

theorem phi_accepts_cA_of_AB (phi : Claim → SumAgg → Bool)
    (h : localIds phi [cA, cB] 1 = [0]) :
    phi cA (sumAgg [cA, cB] 1) = true := by
  have hin : 0 ∈ localIds phi [cA, cB] 1 := by simp [h]
  rcases List.mem_map.1 hin with ⟨c, hc, hid⟩
  have hcAB : c ∈ [cA, cB] := ((mem_localSel_iff phi c [cA, cB] 1).1 hc).1
  have hphi : phi c (sumAgg [cA, cB] 1) = true :=
    ((mem_localSel_iff phi c [cA, cB] 1).1 hc).2
  have hcA : c = cA := by
    have fine : c = cA ∨ c = cB := by
      simpa [List.mem_cons, List.mem_singleton] using hcAB
    rcases fine with hEq | hEq
    · exact hEq
    · have : c.id = 1 := by simp [hEq, cB]
      simp [this] at hid
  simpa [hcA] using hphi

theorem phi_rejects_cA_of_AC (phi : Claim → SumAgg → Bool)
    (h : localIds phi [cA, cC] 1 = [2]) :
    phi cA (sumAgg [cA, cC] 1) = false := by
  by_contra hne
  have ht : phi cA (sumAgg [cA, cC] 1) = true := by
    cases hphi : phi cA (sumAgg [cA, cC] 1) with
    | true => rfl
    | false => exact (hne hphi).elim
  have hmem : cA ∈ LocalSel phi [cA, cC] 1 :=
    (mem_localSel_iff phi cA [cA, cC] 1).2 ⟨by simp, ht⟩
  have : 0 ∈ localIds phi [cA, cC] 1 := by
    refine List.mem_map.2 ?_
    exact ⟨cA, hmem, rfl⟩
  simp [h] at this

/-- No sum-local **filter** matches general extremal fill on both witnesses. -/
theorem extremal_not_local :
    ¬ ∃ (phi : Claim → SumAgg → Bool),
      localIds phi [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds phi [cA, cC] 1 = fillIds [cA, cC] 1 := by
  rintro ⟨phi, hAB, hAC⟩
  have hAB' : localIds phi [cA, cB] 1 = [0] := by
    simpa [fillIds, extremal_AB] using hAB
  have hAC' : localIds phi [cA, cC] 1 = [2] := by
    simpa [fillIds, extremal_AC] using hAC
  have ht := phi_accepts_cA_of_AB phi hAB'
  have hf := phi_rejects_cA_of_AC phi hAC'
  rw [sumAgg_eq] at ht
  simp [ht] at hf

/-- **Main gate theorem:** no `SumLocalProg` (including composites under `and`)
matches extremal prefix fill on both witnesses. -/
theorem extremal_not_sumLocalProg :
    ¬ ∃ (p : SumLocalProg),
      localIds p.eval [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds p.eval [cA, cC] 1 = fillIds [cA, cC] 1 := by
  rintro ⟨p, hAB, hAC⟩
  exact extremal_not_local ⟨p.eval, hAB, hAC⟩

/-- Roadmap name: F9-style extremal prefix is outside the sum-local program class. -/
theorem f9_irreducible_to_sum_local :
    ¬ ∃ (p : SumLocalProg),
      localIds p.eval [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds p.eval [cA, cC] 1 = fillIds [cA, cC] 1 :=
  extremal_not_sumLocalProg

end Defialgebra.Extremal

===== END FILE =====

===== FILE lean/Defialgebra/Independence.lean | SHA256 831c297df2df0fe71220014ae9bc169e283834c6574c95b5d3fafa615d45e67c =====
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/

/-!
# Pairwise independence of the reduced basis `P = {Led, Prop, Cmp, Post}`

Gate 1.2: no primitive is a term over the others.

Toy term language whose constructors are the four generators plus constants.
For each primitive `X` we exhibit a target that uses `X`, and prove every term
in the language with `X` deleted has `usesX = false`.

Corpus witnesses: `research/positive-program/sigma/GATE-1.2-WITNESSES.md`.
-/

namespace Defialgebra.Independence

/-- Sorts of the toy algebra (subset of BASIS six). `Sort` is reserved in Lean. -/
inductive Ty where
  | qty    -- quantity Q
  | scalar -- Σ
  | bool   -- B
  | phase  -- Φ
  deriving DecidableEq, Repr

/-- Term constructors = reduced basis + constants. -/
inductive Term where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (amt : Term)
  | ledMove (amt : Term)
  | prop (a b c : Term)
  | cmpLe (a b : Term)
  | postS (v : Term)
  | postPh (v : Term)
  deriving Repr

/-- Typing (selected rules sufficient for targets). -/
inductive HasType : Term → Ty → Prop where
  | qConst (n : Int) : HasType (.qConst n) .qty
  | sConst (n : Int) : HasType (.sConst n) .scalar
  | phConst (n : Nat) : HasType (.phConst n) .phase
  | ledCredit {amt : Term} (h : HasType amt .qty) : HasType (.ledCredit amt) .qty
  | ledMove {amt : Term} (h : HasType amt .qty) : HasType (.ledMove amt) .qty
  | prop {a b c : Term}
      (ha : HasType a .qty) (hb : HasType b .qty) (hc : HasType c .qty) :
      HasType (.prop a b c) .qty
  | cmpLe {a b : Term} (ha : HasType a .qty) (hb : HasType b .qty) :
      HasType (.cmpLe a b) .bool
  | postS {v : Term} (h : HasType v .scalar) : HasType (.postS v) .scalar
  | postPh {v : Term} (h : HasType v .phase) : HasType (.postPh v) .phase

def usesLed : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a => true || usesLed a
  | .ledMove a => true || usesLed a
  | .prop a b c => usesLed a || usesLed b || usesLed c
  | .cmpLe a b => usesLed a || usesLed b
  | .postS v | .postPh v => usesLed v

def usesProp : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesProp a
  | .prop a b c => true || usesProp a || usesProp b || usesProp c
  | .cmpLe a b => usesProp a || usesProp b
  | .postS v | .postPh v => usesProp v

def usesCmp : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesCmp a
  | .prop a b c => usesCmp a || usesCmp b || usesCmp c
  | .cmpLe a b => true || usesCmp a || usesCmp b
  | .postS v | .postPh v => usesCmp v

def usesPost : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesPost a
  | .prop a b c => usesPost a || usesPost b || usesPost c
  | .cmpLe a b => usesPost a || usesPost b
  | .postS v => true || usesPost v
  | .postPh v => true || usesPost v

/-! ### Languages with one primitive deleted -/

inductive TermNoLed where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | prop (a b c : TermNoLed)
  | cmpLe (a b : TermNoLed)
  | postS (v : TermNoLed)
  | postPh (v : TermNoLed)

def TermNoLed.toTerm : TermNoLed → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoLed.toTerm_not_usesLed (t : TermNoLed) : usesLed t.toTerm = false := by
  induction t <;> simp [TermNoLed.toTerm, usesLed, *]

inductive TermNoProp where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoProp)
  | ledMove (a : TermNoProp)
  | cmpLe (a b : TermNoProp)
  | postS (v : TermNoProp)
  | postPh (v : TermNoProp)

def TermNoProp.toTerm : TermNoProp → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoProp.toTerm_not_usesProp (t : TermNoProp) : usesProp t.toTerm = false := by
  induction t <;> simp [TermNoProp.toTerm, usesProp, *]

inductive TermNoCmp where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoCmp)
  | ledMove (a : TermNoCmp)
  | prop (a b c : TermNoCmp)
  | postS (v : TermNoCmp)
  | postPh (v : TermNoCmp)

def TermNoCmp.toTerm : TermNoCmp → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoCmp.toTerm_not_usesCmp (t : TermNoCmp) : usesCmp t.toTerm = false := by
  induction t <;> simp [TermNoCmp.toTerm, usesCmp, *]

inductive TermNoPost where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoPost)
  | ledMove (a : TermNoPost)
  | prop (a b c : TermNoPost)
  | cmpLe (a b : TermNoPost)

def TermNoPost.toTerm : TermNoPost → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm

theorem TermNoPost.toTerm_not_usesPost (t : TermNoPost) : usesPost t.toTerm = false := by
  induction t <;> simp [TermNoPost.toTerm, usesPost, *]

/-! ### Targets -/

def targetLed : Term := .ledCredit (.qConst 1)

theorem targetLed_usesLed : usesLed targetLed = true := by
  native_decide

theorem targetLed_typed : HasType targetLed .qty :=
  .ledCredit (.qConst 1)

def targetProp : Term := .prop (.qConst 100) (.qConst 50) (.qConst 200)

theorem targetProp_usesProp : usesProp targetProp = true := by
  native_decide

theorem targetProp_typed : HasType targetProp .qty :=
  .prop (.qConst 100) (.qConst 50) (.qConst 200)

def targetCmp : Term := .cmpLe (.qConst 150) (.qConst 100)

theorem targetCmp_usesCmp : usesCmp targetCmp = true := by
  native_decide

theorem targetCmp_typed : HasType targetCmp .bool :=
  .cmpLe (.qConst 150) (.qConst 100)

def targetPost : Term := .postS (.sConst 42)

theorem targetPost_usesPost : usesPost targetPost = true := by
  native_decide

theorem targetPost_typed : HasType targetPost .scalar :=
  .postS (.sConst 42)

/-! ### Non-definability -/

theorem led_not_definable_from_rest (t : TermNoLed) :
    usesLed t.toTerm ≠ usesLed targetLed := by
  rw [t.toTerm_not_usesLed, targetLed_usesLed]
  decide

theorem prop_not_definable_from_rest (t : TermNoProp) :
    usesProp t.toTerm ≠ usesProp targetProp := by
  rw [t.toTerm_not_usesProp, targetProp_usesProp]
  decide

theorem cmp_not_definable_from_rest (t : TermNoCmp) :
    usesCmp t.toTerm ≠ usesCmp targetCmp := by
  rw [t.toTerm_not_usesCmp, targetCmp_usesCmp]
  decide

theorem post_not_definable_from_rest (t : TermNoPost) :
    usesPost t.toTerm ≠ usesPost targetPost := by
  rw [t.toTerm_not_usesPost, targetPost_usesPost]
  decide

theorem pairwise_independence :
    (∀ t : TermNoLed, usesLed t.toTerm ≠ usesLed targetLed) ∧
    (∀ t : TermNoProp, usesProp t.toTerm ≠ usesProp targetProp) ∧
    (∀ t : TermNoCmp, usesCmp t.toTerm ≠ usesCmp targetCmp) ∧
    (∀ t : TermNoPost, usesPost t.toTerm ≠ usesPost targetPost) :=
  ⟨led_not_definable_from_rest, prop_not_definable_from_rest,
   cmp_not_definable_from_rest, post_not_definable_from_rest⟩

end Defialgebra.Independence

===== END FILE =====

===== FILE lean/Defialgebra/Interface.lean | SHA256 e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8 =====
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.

# The interface discipline for `⋈`

`BASIS.md` §5 composes constructions along a coupling `κ` that "identifies only
carriers of the same sort". `P1 · Led` has carrier `(N ⇀ Q) × Q` — a balance map and
a declared total — with the law `‖bal‖ = sup`. But `sup` is merely sort `Q`, so `κ`
may glue it to an unrelated `Q` of the partner, whose transitions then write it while
the balance map is untouched. **Conservation dies under plain interleaving, with no
fusion involved**, and the invariant induction §5 relies on has no proof.

Four independent designs (`sigma/INTERFACE-COUNCIL.md`) converged on one fix:
*the declared total is not a shareable thing*. This file is the Lean statement of it.

* `Ledger.sup_not_port` — the discipline, carried as a well-formedness field rather
  than proved. This is the whole fix.
* `cons_of_portConfined` — a foreign transition confined to a ledger's ports, and
  `Q`-neutral on the ports it shares, preserves `‖bal‖ = sup`.
* `cons_broken_if_sup_is_port` — **the negative companion.** Drop `sup ∉ ports` and
  the same theorem is false, by explicit counterexample. Without this the result
  could hold vacuously, which is the failure mode this programme keeps finding.

SCOPE, stated plainly. Sorts are not modelled: state here is `Idx → ℤ`, because
conservation quantifies over `Q` alone and the sort discipline is a separate
concern. Fusion, polarity of `Q` flows, and associativity are M2/M3 and are absent.
What is proved is exactly the milestone: the coupling defect is real, and
`sup ∉ ports` closes it.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Int

namespace Defialgebra.Interface

variable {Idx : Type*} [DecidableEq Idx]

/-- The state of a construction, restricted to its `Q` carriers. -/
def St (Idx : Type*) : Type _ := Idx → ℤ

/-- A `Led` block: the balance indices, the declared total, and the ports it
exposes to a coupling.

`bal : N ⇀ Q` is modelled as `N`-many `Q`-carriers rather than one map carrier.
That is faithful to §5's "`S` a finite product of carriers", and it is what makes
the defect *sayable*: `sup` is a different index from every balance, so a port list
can contain the balances and exclude the total. -/
structure Ledger (Idx : Type*) where
  /-- The indices holding individual balances. -/
  bals : Finset Idx
  /-- The index holding the declared total. -/
  sup : Idx
  /-- The indices a coupling is permitted to bind. -/
  ports : Finset Idx
  /-- The total is not one of the balances. -/
  sup_not_bal : sup ∉ bals
  /-- **THE INTERFACE DISCIPLINE.** The declared total is never a port, so no
  coupling can bind it and no foreign transition can write it. Carried as a
  well-formedness condition, not derived. -/
  sup_not_port : sup ∉ ports

/-- `P1 · Led`'s law: `‖bal‖ = sup`. -/
def Cons (L : Ledger Idx) (s : St Idx) : Prop :=
  ∑ i ∈ L.bals, s i = s L.sup

/-- `f` touches nothing outside `P` — what a coupling confines a partner to. -/
def WritesWithin (P : Finset Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s i, i ∉ P → f s i = s i

/-- `f` moves no net quantity across the ports it shares with `L`. A transfer that
debits one shared balance and credits another satisfies this; a mint into a shared
balance does not. -/
def QNeutralOn (P : Finset Idx) (L : Ledger Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s, ∑ i ∈ L.bals.filter (· ∈ P), f s i
        = ∑ i ∈ L.bals.filter (· ∈ P), s i

/-- **The milestone.** A foreign transition confined to `L`'s ports and `Q`-neutral
on the shared balances preserves conservation.

The proof is three lines and every one of them is the discipline doing work: the
total is untouched *because it is not a port*; the private balances are untouched
*because the transition is confined to ports*; the shared balances net to zero *by
hypothesis*. Remove `sup_not_port` and the first line fails — see
`cons_broken_if_sup_is_port`. -/
theorem cons_of_portConfined (L : Ledger Idx) (f : St Idx → St Idx)
    (hw : WritesWithin L.ports f) (hq : QNeutralOn L.ports L f)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsup : f s L.sup = s L.sup := hw s L.sup L.sup_not_port
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i := by
    rw [← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) (f s),
        ← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) s, hq s]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro i hi
    exact hw s i (by simpa using (Finset.mem_filter.mp hi).2)
  unfold Cons at h ⊢
  rw [hsum, hsup, h]

omit [DecidableEq Idx] in
/-- The frame case: a transition touching none of a ledger's carriers preserves
conservation. Immediate, and worth stating because it is what makes composition
with an unrelated machine free. -/
theorem cons_of_disjoint (L : Ledger Idx) (f : St Idx → St Idx)
    (P : Finset Idx) (hw : WritesWithin P f)
    (hb : ∀ i ∈ L.bals, i ∉ P) (hs : L.sup ∉ P)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i :=
    Finset.sum_congr rfl fun i hi => hw s i (hb i hi)
  unfold Cons at h ⊢
  rw [hsum, hw s L.sup hs, h]

/-- **The negative companion, and the point of the whole file.**

Drop `sup ∉ ports` and `cons_of_portConfined` is false. Here is the witness: one
balance, one total, and a partner permitted to bind the total. The partner writes
only its permitted index and is `Q`-neutral on the shared balances — vacuously, since
it shares none — yet conservation breaks.

This is exactly the coupling `BASIS.md` §5 admits, since `sup` is merely sort `Q`
and `κ` identifies same-sort carriers. -/
theorem cons_broken_if_sup_is_port :
    ∃ (bals : Finset Bool) (sup : Bool) (ports : Finset Bool)
      (f : St Bool → St Bool) (s : St Bool),
      sup ∉ bals ∧
      sup ∈ ports ∧                                    -- the discipline VIOLATED
      WritesWithin ports f ∧                           -- confined to its ports
      (∀ t, ∑ i ∈ bals.filter (· ∈ ports), f t i
            = ∑ i ∈ bals.filter (· ∈ ports), t i) ∧     -- Q-neutral on shared bals
      (∑ i ∈ bals, s i) = s sup ∧                      -- conservation HOLDS
      (∑ i ∈ bals, f s i) ≠ f s sup := by              -- and FAILS after
  -- No `classical`: `Bool` already has `DecidableEq`, and introducing
  -- `Classical.dec` makes the two `∅`s carry different instances, so
  -- `Finset.sum_empty` rewrites one side and not the other.
  refine ⟨{false}, true, {true},
          fun t i => if i = true then t i + 1 else t i,
          fun _ => 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · decide
  · decide
  · intro t i hi
    have : i ≠ true := by
      intro h; exact hi (by simp [h])
    simp [this]
  · -- The two sums are equal POINTWISE on an empty index set. Computing both to
    -- `0` via `Finset.sum_empty` rewrites only one side here; congruence avoids
    -- the question entirely.
    intro t
    refine Finset.sum_congr rfl ?_
    intro i hi
    have hfil : ({false} : Finset Bool).filter (· ∈ ({true} : Finset Bool)) = ∅ := by
      decide
    rw [hfil] at hi
    exact absurd hi (Finset.notMem_empty i)
  · simp
  · simp

end Defialgebra.Interface

===== END FILE =====

===== FILE lean/Defialgebra/Lattice.lean | SHA256 97f6dcda33de19f12f5971798e5745ace09ca66ee91f9c43c1d18030e6122eb4 =====
/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Order.CompleteLattice.Defs
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Powerset

/-!
# Union-closed families are complete lattices

Machine-checked counterpart of paper `cor:lattice` and `prop:joinmeet`.

A family `F ⊆ 2^E` on a finite ground set which contains `∅` and `E` and is closed under
binary union is a complete lattice under inclusion, with `⊔ = ∪`.

## Implementation note

This is *low-content*: mathlib already supplies `completeLatticeOfSup`, which builds a
`CompleteLattice` from any `SupSet` whose `sSup` is a least upper bound. All that is left is
(i) to define `sSup` on the subtype as the union of a finite subfamily, and (ii) to check that
this union stays in `F` — which is exactly `Finset.sup_induction` fed with `∅ ∈ F` and binary
union-closure. Over a `Fintype` ground set every subset of `F` is finite, so binary closure
upgrades to arbitrary `sSup` for free; this is the only genuinely mathematical step.

## Main results

* `UnionClosedFamily.completeLattice` — the `CompleteLattice` instance.
* `UnionClosedFamily.coe_sup` — the join is literally union (paper `prop:joinmeet`).
* `UnionClosedFamily.inf_eq_sSup` — the meet is the join of all common lower bounds *inside
  the family*, i.e. `⋃ {C ∈ F : C ⊆ A ∩ B}`, not the intersection.
* `meet_ne_inter` — an explicit union-closed family containing `∅` and `univ` in which the
  intersection of two members is not a member; so meet really is not intersection.
-/

set_option linter.unusedSectionVars false

namespace Defialgebra

namespace Lattice

/-- A family of subsets of a finite ground set containing `∅` and the whole set and closed
under binary union. Paper: the family `ℛ ∩ 𝒲`. -/
structure UnionClosedFamily (E : Type*) [Fintype E] [DecidableEq E] where
  /-- The underlying family of subsets. -/
  carrier : Set (Finset E)
  /-- The empty set is a member. -/
  empty_mem : (∅ : Finset E) ∈ carrier
  /-- The whole ground set is a member. -/
  univ_mem : (Finset.univ : Finset E) ∈ carrier
  /-- The family is closed under binary union. -/
  union_mem : ∀ ⦃A B : Finset E⦄, A ∈ carrier → B ∈ carrier → A ∪ B ∈ carrier

namespace UnionClosedFamily

variable {E : Type*} [Fintype E] [DecidableEq E] (F : UnionClosedFamily E)

/-- The underlying finset of the (necessarily finite) subfamily `S`. -/
noncomputable def toFinsetFamily (S : Set F.carrier) : Finset (Finset E) :=
  letI := Classical.decPred
    (fun A : Finset E => ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A)
  Finset.univ.filter (fun A : Finset E => ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A)

@[simp] lemma mem_toFinsetFamily {S : Set F.carrier} {A : Finset E} :
    A ∈ F.toFinsetFamily S ↔ ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A := by
  classical
  simp [toFinsetFamily]

/-- The candidate supremum: the union of all members of the subfamily `S`. -/
noncomputable def famSup (S : Set F.carrier) : Finset E := (F.toFinsetFamily S).sup id

/-- **The one mathematical step.** An arbitrary union of members of `F` is again a member:
over a `Fintype` ground set the subfamily is finite, so `∅ ∈ F` plus binary union-closure
suffice, by induction on the finite `Finset.sup`. -/
lemma famSup_mem (S : Set F.carrier) : F.famSup S ∈ F.carrier := by
  refine Finset.sup_induction F.empty_mem (fun a ha b hb => F.union_mem ha hb) ?_
  intro A hA
  obtain ⟨a, _, rfl⟩ := F.mem_toFinsetFamily.mp hA
  exact a.2

noncomputable instance : SupSet F.carrier := ⟨fun S => ⟨F.famSup S, F.famSup_mem S⟩⟩

lemma coe_sSup (S : Set F.carrier) : ((sSup S : F.carrier) : Finset E) = F.famSup S := rfl

lemma isLUB_sSup' (S : Set F.carrier) : IsLUB S (sSup S) := by
  constructor
  · intro a ha
    show (a : Finset E) ≤ F.famSup S
    exact Finset.le_sup (f := id) (F.mem_toFinsetFamily.mpr ⟨a, ha, rfl⟩)
  · intro b hb
    show F.famSup S ≤ (b : Finset E)
    refine Finset.sup_le ?_
    intro A hA
    obtain ⟨a, ha, rfl⟩ := F.mem_toFinsetFamily.mp hA
    exact hb ha

/-- **Paper `cor:lattice`.** A union-closed family containing `∅` and the ground set is a
complete lattice under inclusion. Obtained from mathlib's `completeLatticeOfSup`. -/
noncomputable instance completeLattice : CompleteLattice F.carrier :=
  completeLatticeOfSup _ F.isLUB_sSup'

/-- **Paper `prop:joinmeet`, join.** The join is union. -/
lemma coe_sup (a b : F.carrier) :
    ((a ⊔ b : F.carrier) : Finset E) = (a : Finset E) ∪ (b : Finset E) := by
  set u : F.carrier := ⟨(a : Finset E) ∪ (b : Finset E), F.union_mem a.2 b.2⟩ with hu
  have hau : a ≤ u := show (a : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) from
    Finset.subset_union_left
  have hbu : b ≤ u := show (b : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) from
    Finset.subset_union_right
  have h1 : ((a ⊔ b : F.carrier) : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) :=
    sup_le hau hbu
  have h2 : (a : Finset E) ∪ (b : Finset E) ⊆ ((a ⊔ b : F.carrier) : Finset E) :=
    Finset.union_subset (le_sup_left (a := a) (b := b)) (le_sup_right (a := a) (b := b))
  exact Finset.Subset.antisymm h1 h2

/-- **Paper `prop:joinmeet`, meet.** The meet of `A` and `B` is the join of *all members of the
family* below both, i.e. `⋃ {C ∈ F : C ⊆ A ∩ B}` — not `A ∩ B`. -/
lemma inf_eq_sSup (a b : F.carrier) : a ⊓ b = sSup {x : F.carrier | x ≤ a ∧ x ≤ b} := by
  refine le_antisymm (le_sSup ⟨inf_le_left, inf_le_right⟩) (sSup_le ?_)
  rintro x ⟨hx1, hx2⟩
  exact le_inf hx1 hx2

/-- Concretely: the meet is the union of all members of `F` contained in `A ∩ B`. -/
lemma coe_inf (a b : F.carrier) :
    ((a ⊓ b : F.carrier) : Finset E) =
      F.famSup {x : F.carrier | (x : Finset E) ⊆ (a : Finset E) ∩ (b : Finset E)} := by
  rw [inf_eq_sSup, coe_sSup]
  congr 1
  ext x
  constructor
  · rintro ⟨h1, h2⟩
    exact Finset.subset_inter h1 h2
  · intro h
    refine ⟨?_, ?_⟩
    · exact show (x : Finset E) ⊆ (a : Finset E) from
        Finset.Subset.trans h Finset.inter_subset_left
    · exact show (x : Finset E) ⊆ (b : Finset E) from
        Finset.Subset.trans h Finset.inter_subset_right

/-- The top of the lattice is the whole ground set (this is where `univ_mem` is used). -/
lemma top_eq_univ : ((⊤ : F.carrier) : Finset E) = Finset.univ :=
  Finset.Subset.antisymm (Finset.subset_univ _)
    (le_top (a := (⟨Finset.univ, F.univ_mem⟩ : F.carrier)))

end UnionClosedFamily

/-- **Meet is not intersection.** An explicit union-closed family on `Fin 3` containing `∅`
and `univ` whose members `{0,1}` and `{0,2}` have intersection `{0}` outside the family.
Together with `UnionClosedFamily.inf_eq_sSup` this shows the meet of the complete lattice
cannot be intersection. -/
theorem meet_ne_inter :
    ∃ C : Finset (Finset (Fin 3)),
      (∅ ∈ C) ∧ (Finset.univ ∈ C) ∧ (∀ A ∈ C, ∀ B ∈ C, A ∪ B ∈ C) ∧
        ∃ A ∈ C, ∃ B ∈ C, A ∩ B ∉ C := by
  refine ⟨{∅, {0, 1}, {0, 2}, Finset.univ}, ?_, ?_, ?_, ?_⟩ <;> decide

section AxiomAudit

#print axioms Defialgebra.Lattice.UnionClosedFamily.mem_toFinsetFamily
#print axioms Defialgebra.Lattice.UnionClosedFamily.famSup_mem
#print axioms Defialgebra.Lattice.UnionClosedFamily.isLUB_sSup'
#print axioms Defialgebra.Lattice.UnionClosedFamily.completeLattice
#print axioms Defialgebra.Lattice.UnionClosedFamily.coe_sup
#print axioms Defialgebra.Lattice.UnionClosedFamily.inf_eq_sSup
#print axioms Defialgebra.Lattice.UnionClosedFamily.coe_inf
#print axioms Defialgebra.Lattice.UnionClosedFamily.top_eq_univ
#print axioms Defialgebra.Lattice.meet_ne_inter

end AxiomAudit

end Lattice

end Defialgebra

===== END FILE =====

===== FILE lean/Defialgebra/Nary.lean | SHA256 31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680 =====
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith

/-!
# M3 — n-ary binding and bracket-independent agreement

`INTERFACE-COUNCIL.md` §2: pair-local `κ` makes associativity *unstatable*, because
`κ` is attached to a pair, not to an object. The remedy is **stable port names**
plus **n-ary composition over a global binding set**.

## What is proved

* `Binding` — a finite set of port-pairs (global names).
* `Agrees` — state agreement on every bound pair.
* `agrees_iff_agrees_sym` — agreement depends only on the symmetric closure
  (pair orientation does not matter).
* `agrees_union`, `union_assoc`, `agrees_union_assoc` — multi-party composition
  is constraint-union; union is associative, so bracketing does not change
  agreement.
* `agrees_of_same_symClosure` — **two-binding reindex:** if two bindings have
  equal symmetric closures, they induce the same agreement predicate (listing
  order / pair orientation / redundant reverse edges do not matter).
* `pairLocal_excludes_skip` — **negative companion.** Pair-local edges on a
  binary cut cannot include a skip edge with both ends on the same side.
* `skip_not_pairLocal_witness` — concrete three-port witness.

## What is not proved

* Operational transition systems / reachability.
* Lifting M1 conservation through transitions.
* Corpus adequacy (M4).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false

namespace Defialgebra.Nary

variable {Idx : Type*} [DecidableEq Idx]

/-- A construction exposes a finite set of globally named ports. -/
structure Machine (Idx : Type*) where
  ports : Finset Idx

/-- Global binding: port-pairs that must carry equal state. -/
structure Binding (Idx : Type*) where
  pairs : Finset (Idx × Idx)

def St (Idx : Type*) : Type _ := Idx → ℤ

def PairAgrees (s : St Idx) (p : Idx × Idx) : Prop :=
  s p.1 = s p.2

def Agrees (B : Binding Idx) (s : St Idx) : Prop :=
  ∀ p ∈ B.pairs, PairAgrees s p

def symClosure (P : Finset (Idx × Idx)) : Finset (Idx × Idx) :=
  P ∪ P.image (fun p => (p.2, p.1))

theorem agrees_iff_agrees_sym (B : Binding Idx) (s : St Idx) :
    Agrees B s ↔ (∀ p ∈ symClosure B.pairs, PairAgrees s p) := by
  constructor
  · intro h p hp
    simp only [symClosure, Finset.mem_union, Finset.mem_image] at hp
    rcases hp with hp | ⟨q, hq, rfl⟩
    · exact h p hp
    · exact (h q hq).symm
  · intro h p hp
    exact h p (by
      simp only [symClosure, Finset.mem_union]
      exact Or.inl hp)

def Binding.union (B₁ B₂ : Binding Idx) : Binding Idx where
  pairs := B₁.pairs ∪ B₂.pairs

theorem agrees_union (B₁ B₂ : Binding Idx) (s : St Idx) :
    Agrees (B₁.union B₂) s ↔ Agrees B₁ s ∧ Agrees B₂ s := by
  constructor
  · intro h
    exact ⟨fun p hp => h p (Finset.mem_union_left _ hp),
           fun p hp => h p (Finset.mem_union_right _ hp)⟩
  · rintro ⟨h₁, h₂⟩ p hp
    cases Finset.mem_union.1 hp with
    | inl hp => exact h₁ p hp
    | inr hp => exact h₂ p hp

theorem union_assoc (B₁ B₂ B₃ : Binding Idx) :
    (B₁.union B₂).union B₃ = B₁.union (B₂.union B₃) := by
  cases B₁; cases B₂; cases B₃
  simp [Binding.union, Finset.union_assoc]

theorem union_comm (B₁ B₂ : Binding Idx) :
    B₁.union B₂ = B₂.union B₁ := by
  cases B₁; cases B₂
  simp [Binding.union, Finset.union_comm]

/-- **Bracket independence.** Agreement under `((B₁ ∪ B₂) ∪ B₃)` iff under
`(B₁ ∪ (B₂ ∪ B₃))`. -/
theorem agrees_union_assoc (B₁ B₂ B₃ : Binding Idx) (s : St Idx) :
    Agrees ((B₁.union B₂).union B₃) s ↔ Agrees (B₁.union (B₂.union B₃)) s := by
  rw [union_assoc]

/-- **Two-binding reindex (M3-DESIGN item 4).** Bindings with the same symmetric
closure of pairs induce the same agreement predicate. Parenthesization of n-ary
composition is already ; this covers reordering and
re-orienting the declared pair list. -/
theorem agrees_of_same_symClosure (B₁ B₂ : Binding Idx) (s : St Idx)
    (h : symClosure B₁.pairs = symClosure B₂.pairs) :
    Agrees B₁ s ↔ Agrees B₂ s := by
  rw [agrees_iff_agrees_sym, agrees_iff_agrees_sym, h]

structure BinaryCut (Idx : Type*) where
  left : Finset Idx
  right : Finset Idx
  disjoint : Disjoint left right

/-- Pair-local κ: every edge spans the cut. -/
def PairLocal (C : BinaryCut Idx) (P : Finset (Idx × Idx)) : Prop :=
  ∀ p ∈ P,
    (p.1 ∈ C.left ∧ p.2 ∈ C.right) ∨ (p.1 ∈ C.right ∧ p.2 ∈ C.left)

/-- Skip edge: both ends on the left side (cannot be stated by pair-local κ). -/
def SkipEdge (C : BinaryCut Idx) (p : Idx × Idx) : Prop :=
  p.1 ∈ C.left ∧ p.2 ∈ C.left ∧ p.1 ≠ p.2

/-- **Negative companion.** Pair-local edge sets exclude skip edges. -/
theorem pairLocal_excludes_skip (C : BinaryCut Idx) (P : Finset (Idx × Idx))
    (hPL : PairLocal C P) {p : Idx × Idx} (hp : p ∈ P) (hS : SkipEdge C p) :
    False := by
  rcases hPL p hp with ⟨_, hR⟩ | ⟨hR, _⟩
  · exact Finset.disjoint_left.1 C.disjoint hS.2.1 hR
  · exact Finset.disjoint_left.1 C.disjoint hS.1 hR

private theorem cut02_1_disjoint :
    Disjoint ({(0 : Fin 3), 2} : Finset (Fin 3)) {1} := by
  decide

private def cut02_1 : BinaryCut (Fin 3) :=
  ⟨{0, 2}, {1}, cut02_1_disjoint⟩

private theorem skip02 : SkipEdge cut02_1 ((0 : Fin 3), 2) := by
  unfold SkipEdge cut02_1
  refine ⟨?_, ?_, ?_⟩
  · exact Finset.mem_insert_self (0 : Fin 3) {2}
  · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self (2 : Fin 3))
  · exact by decide

/-- Concrete three-port witness: cut `{0,2} | {1}`, skip `(0,2)` is not pair-local
for any edge set containing it. -/
theorem skip_not_pairLocal_witness :
    ∃ (C : BinaryCut (Fin 3)) (p : Fin 3 × Fin 3),
      SkipEdge C p ∧
      ∀ P : Finset (Fin 3 × Fin 3), p ∈ P → ¬ PairLocal C P := by
  refine ⟨cut02_1, (0, 2), skip02, ?_⟩
  intro P hp hPL
  exact pairLocal_excludes_skip cut02_1 P hPL hp skip02

end Defialgebra.Nary

===== END FILE =====

===== FILE lean/Defialgebra/Polarity.lean | SHA256 3c0d18247d5df39c1f37f6a2adfb50cd304ecb3f6c7543da1f23bb8b53f203d3 =====
/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Basic

/-!
# Polarity and the closure properties of the model classes

Machine-checked counterparts of paper `lem:polarity` and `thm:closure`.

A clause over a ground set `E` is a pair of finsets: the positive literals and the negative
literals. A set `X ⊆ E` satisfies it when some positive literal is present or some negative
literal is absent.

## Main results

* `sat_union_of_dualHorn` / `dualHorn_union_closed` — dual-Horn clause sets (at most one
  negative literal) are preserved by union.
* `sat_inter_of_horn` / `horn_inter_closed` — Horn clause sets (at most one positive literal)
  are preserved by intersection.
* `req_models_union_closed`, `warrant_models_union_closed`, `proh_models_inter_closed` — the
  same statements phrased in the paper's own vocabulary of requirements, warrants and
  prohibitions.
* `dualHorn_not_inter_closed`, `pureNeg_not_union_closed` — the *negative* halves of
  `thm:closure`: these closure properties do not hold in the other direction. Both are
  witnessed by explicit three-element counterexamples, checked by `decide`.
-/

set_option linter.unusedSectionVars false

namespace Defialgebra

namespace Polarity

/-- A clause over the ground set `E`: a finset of positive literals and a finset of negative
literals. The clause is read as `⋁_{e ∈ pos} e ∨ ⋁_{e ∈ neg} ¬e`. -/
structure Clause (E : Type*) where
  /-- The positive literals. -/
  pos : Finset E
  /-- The negative literals. -/
  neg : Finset E
  deriving DecidableEq

variable {E : Type*} [DecidableEq E]

/-- `X` satisfies the clause `c`: some positive literal is present, or some negative literal
is absent. -/
def Sat (X : Finset E) (c : Clause E) : Prop :=
  (∃ e ∈ c.pos, e ∈ X) ∨ (∃ e ∈ c.neg, e ∉ X)

instance (X : Finset E) (c : Clause E) : Decidable (Sat X c) := by
  unfold Sat; infer_instance

/-- A clause is **dual-Horn** when it has at most one negative literal. -/
def DualHorn (c : Clause E) : Prop := c.neg.card ≤ 1

instance (c : Clause E) : Decidable (DualHorn c) := by unfold DualHorn; infer_instance

/-- A clause is **Horn** when it has at most one positive literal. -/
def Horn (c : Clause E) : Prop := c.pos.card ≤ 1

instance (c : Clause E) : Decidable (Horn c) := by unfold Horn; infer_instance

/-- A clause is **purely negative** when it has no positive literal at all. This is the shape
of the paper's prohibitions, and a special case of `Horn`. -/
def PureNeg (c : Clause E) : Prop := c.pos = ∅

lemma horn_of_pureNeg {c : Clause E} (h : PureNeg c) : Horn c := by
  have h2 : c.pos = ∅ := h
  simp [Horn, h2]

/-- `X` satisfies the clause *set* `S`. -/
def Models (X : Finset E) (S : Set (Clause E)) : Prop := ∀ c ∈ S, Sat X c

/-! ## The two preservation lemmas -/

/-- **Union preservation, clause level.** A dual-Horn clause satisfied by `X` and by `Y` is
satisfied by `X ∪ Y`. -/
theorem sat_union_of_dualHorn {c : Clause E} (hc : DualHorn c) {X Y : Finset E}
    (hX : Sat X c) (hY : Sat Y c) : Sat (X ∪ Y) c := by
  rcases hX with ⟨e, he, heX⟩ | ⟨e, he, heX⟩
  · exact Or.inl ⟨e, he, Finset.mem_union_left _ heX⟩
  rcases hY with ⟨f, hf, hfY⟩ | ⟨f, hf, hfY⟩
  · exact Or.inl ⟨f, hf, Finset.mem_union_right _ hfY⟩
  -- Both witnesses are negative literals, and there is at most one of those.
  have hef : e = f := Finset.card_le_one.mp hc e he f hf
  refine Or.inr ⟨e, he, ?_⟩
  rw [Finset.mem_union]
  rintro (h | h)
  · exact heX h
  · exact hfY (hef ▸ h)

/-- **Intersection preservation, clause level.** A Horn clause satisfied by `X` and by `Y` is
satisfied by `X ∩ Y`. -/
theorem sat_inter_of_horn {c : Clause E} (hc : Horn c) {X Y : Finset E}
    (hX : Sat X c) (hY : Sat Y c) : Sat (X ∩ Y) c := by
  rcases hX with ⟨e, he, heX⟩ | ⟨e, he, heX⟩
  · rcases hY with ⟨f, hf, hfY⟩ | ⟨f, hf, hfY⟩
    · -- Both witnesses are positive literals, and there is at most one of those.
      have hef : e = f := Finset.card_le_one.mp hc e he f hf
      exact Or.inl ⟨e, he, Finset.mem_inter.mpr ⟨heX, hef ▸ hfY⟩⟩
    · exact Or.inr ⟨f, hf, fun h => hfY (Finset.mem_inter.mp h).2⟩
  · exact Or.inr ⟨e, he, fun h => heX (Finset.mem_inter.mp h).1⟩

/-- **Paper `thm:closure`, positive half for `ℛ` and `𝒲`.** A dual-Horn clause set has a
union-closed model class. -/
theorem dualHorn_union_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, DualHorn c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∪ Y) S :=
  fun c hc => sat_union_of_dualHorn (hS c hc) (hX c hc) (hY c hc)

/-- **Paper `thm:closure`, positive half for `ℋ`.** A Horn clause set has an
intersection-closed model class. -/
theorem horn_inter_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, Horn c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∩ Y) S :=
  fun c hc => sat_inter_of_horn (hS c hc) (hX c hc) (hY c hc)

/-- The purely negative case, which is what the paper's prohibitions actually are. -/
theorem pureNeg_inter_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, PureNeg c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∩ Y) S :=
  horn_inter_closed (fun c hc => horn_of_pureNeg (hS c hc)) hX hY

/-! ## The paper's actual clause shapes

A requirement `(s, T)` contributes `¬s ∨ ⋁_{e ∈ T} e`; a warrant `(e, C)` has the same shape;
a prohibition `H` contributes `⋁_{e ∈ H} ¬e`.
-/

/-- The clause `¬s ∨ ⋁_{e ∈ T} e` of a requirement `(s, T)` (equally, of a warrant `(s, T)`).
-/
def reqClause (s : E) (T : Finset E) : Clause E := ⟨T, {s}⟩

/-- The clause `⋁_{e ∈ H} ¬e` of a prohibition `H`. -/
def prohClause (H : Finset E) : Clause E := ⟨∅, H⟩

/-- **Paper `lem:polarity`, requirements and warrants.** -/
theorem dualHorn_reqClause (s : E) (T : Finset E) : DualHorn (reqClause s T) := by
  simp [DualHorn, reqClause]

/-- **Paper `lem:polarity`, prohibitions: purely negative.** -/
theorem pureNeg_prohClause (H : Finset E) : PureNeg (prohClause H) := rfl

/-- **Paper `lem:polarity`, prohibitions: hence Horn.** -/
theorem horn_prohClause (H : Finset E) : Horn (prohClause H) :=
  horn_of_pureNeg (pureNeg_prohClause H)

/-- Satisfaction of a requirement clause is the paper's condition
`s ∈ X → T ∩ X ≠ ∅`. -/
theorem sat_reqClause_iff (s : E) (T X : Finset E) :
    Sat X (reqClause s T) ↔ (s ∈ X → (T ∩ X).Nonempty) := by
  simp only [Sat, reqClause, Finset.mem_singleton, exists_eq_left]
  constructor
  · rintro (⟨e, heT, heX⟩ | hs) hsX
    · exact ⟨e, Finset.mem_inter.mpr ⟨heT, heX⟩⟩
    · exact absurd hsX hs
  · intro h
    by_cases hs : s ∈ X
    · obtain ⟨e, he⟩ := h hs
      exact Or.inl ⟨e, (Finset.mem_inter.mp he).1, (Finset.mem_inter.mp he).2⟩
    · exact Or.inr hs

/-- Satisfaction of a prohibition clause is the paper's condition `H ⊄ X`. -/
theorem sat_prohClause_iff (H X : Finset E) : Sat X (prohClause H) ↔ ¬ H ⊆ X := by
  constructor
  · rintro (⟨e, he, -⟩ | ⟨e, heH, heX⟩)
    · exact absurd he (Finset.notMem_empty e)
    · exact fun hsub => heX (hsub heH)
  · intro h
    obtain ⟨e, heH, heX⟩ := Finset.not_subset.mp h
    exact Or.inr ⟨e, heH, heX⟩

/-- **Paper-level statement for requirements**: the models of a requirement `(s, T)` are
closed under union. -/
theorem req_models_union_closed (s : E) (T X Y : Finset E)
    (hX : s ∈ X → (T ∩ X).Nonempty) (hY : s ∈ Y → (T ∩ Y).Nonempty) :
    s ∈ X ∪ Y → (T ∩ (X ∪ Y)).Nonempty := by
  rw [← sat_reqClause_iff] at hX hY ⊢
  exact sat_union_of_dualHorn (dualHorn_reqClause s T) hX hY

/-- **Paper-level statement for warrants**: identical shape, `(e, C)` in place of `(s, T)`. -/
theorem warrant_models_union_closed (e : E) (C X Y : Finset E)
    (hX : e ∈ X → (C ∩ X).Nonempty) (hY : e ∈ Y → (C ∩ Y).Nonempty) :
    e ∈ X ∪ Y → (C ∩ (X ∪ Y)).Nonempty :=
  req_models_union_closed e C X Y hX hY

/-- **Paper-level statement for prohibitions**: the models of a prohibition `H` are closed
under intersection. -/
theorem proh_models_inter_closed (H X Y : Finset E)
    (hX : ¬ H ⊆ X) (hY : ¬ H ⊆ Y) : ¬ H ⊆ X ∩ Y := by
  rw [← sat_prohClause_iff] at hX hY ⊢
  exact sat_inter_of_horn (horn_prohClause H) hX hY

/-! ## The negative halves of `thm:closure`

Dual-Horn model classes need not be intersection-closed, and purely negative model classes
need not be union-closed. Both witnessed on `Fin 3`, checked by kernel evaluation.
-/

/-- **Paper `thm:closure`, negative half for `ℛ` and `𝒲`.** The dual-Horn clause
`¬0 ∨ 1 ∨ 2` is satisfied by `{0,1}` and by `{0,2}` but not by their intersection `{0}`. -/
theorem dualHorn_not_inter_closed :
    ∃ (c : Clause (Fin 3)) (X Y : Finset (Fin 3)),
      DualHorn c ∧ Sat X c ∧ Sat Y c ∧ ¬ Sat (X ∩ Y) c :=
  ⟨⟨{1, 2}, {0}⟩, {0, 1}, {0, 2}, by decide, by decide, by decide, by decide⟩

/-- The same counterexample stated in the paper's requirement vocabulary: the requirement
`(0, {1,2})` is satisfied by `{0,1}` and `{0,2}` but fails on `{0}`. -/
theorem req_not_inter_closed :
    ∃ (s : Fin 3) (T X Y : Finset (Fin 3)),
      (s ∈ X → (T ∩ X).Nonempty) ∧ (s ∈ Y → (T ∩ Y).Nonempty) ∧
        ¬ (s ∈ X ∩ Y → (T ∩ (X ∩ Y)).Nonempty) := by
  refine ⟨0, {1, 2}, {0, 1}, {0, 2}, ?_, ?_, ?_⟩ <;> decide

/-- **Paper `thm:closure`, negative half for `ℋ`.** The purely negative clause `¬0 ∨ ¬1`
(the prohibition `{0,1}`) is satisfied by `{0}` and by `{1}` but not by their union. -/
theorem pureNeg_not_union_closed :
    ∃ (c : Clause (Fin 3)) (X Y : Finset (Fin 3)),
      PureNeg c ∧ Sat X c ∧ Sat Y c ∧ ¬ Sat (X ∪ Y) c :=
  ⟨prohClause {0, 1}, {0}, {1}, rfl, by decide, by decide, by decide⟩

/-- The same counterexample in the paper's prohibition vocabulary. -/
theorem proh_not_union_closed :
    ∃ (H X Y : Finset (Fin 3)), ¬ H ⊆ X ∧ ¬ H ⊆ Y ∧ ¬ (¬ H ⊆ X ∪ Y) := by
  refine ⟨{0, 1}, {0}, {1}, ?_, ?_, ?_⟩ <;> decide

section AxiomAudit

#print axioms Defialgebra.Polarity.sat_union_of_dualHorn
#print axioms Defialgebra.Polarity.sat_inter_of_horn
#print axioms Defialgebra.Polarity.dualHorn_union_closed
#print axioms Defialgebra.Polarity.horn_inter_closed
#print axioms Defialgebra.Polarity.pureNeg_inter_closed
#print axioms Defialgebra.Polarity.horn_of_pureNeg
#print axioms Defialgebra.Polarity.dualHorn_reqClause
#print axioms Defialgebra.Polarity.pureNeg_prohClause
#print axioms Defialgebra.Polarity.horn_prohClause
#print axioms Defialgebra.Polarity.sat_reqClause_iff
#print axioms Defialgebra.Polarity.sat_prohClause_iff
#print axioms Defialgebra.Polarity.req_models_union_closed
#print axioms Defialgebra.Polarity.warrant_models_union_closed
#print axioms Defialgebra.Polarity.proh_models_inter_closed
#print axioms Defialgebra.Polarity.dualHorn_not_inter_closed
#print axioms Defialgebra.Polarity.req_not_inter_closed
#print axioms Defialgebra.Polarity.pureNeg_not_union_closed
#print axioms Defialgebra.Polarity.proh_not_union_closed

end AxiomAudit

end Polarity

end Defialgebra

===== END FILE =====

===== FILE paper/atlas.tex | SHA256 a424721a161cba011b682cecc582fa8cc4550a06ba3f2b8a1d3dd7543fdcb704 =====
\documentclass[11pt,reqno]{amsart}
\usepackage[margin=1.15in]{geometry}
\usepackage{amsmath,amssymb,amsthm,mathtools}
\usepackage{booktabs}
\usepackage[hidelinks]{hyperref}

\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{conjecture}[theorem]{Conjecture}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}
\theoremstyle{remark}
\newtheorem{measurement}[theorem]{Measurement}
\newtheorem{remark}[theorem]{Remark}

\newcommand{\Pos}{\mathcal{P}}
\newcommand{\Adm}{\mathrm{Adm}_{0}}
\newcommand{\Admf}{\mathrm{Adm}}
\newcommand{\Fix}{\operatorname{Fix}}
\newcommand{\lfp}{\operatorname{lfp}}
\newcommand{\gfp}{\operatorname{gfp}}
\newcommand{\El}{\mathcal{E}}
\newcommand{\Law}{\mathsf{Req}}
\newcommand{\Haz}{\mathsf{Proh}}
\newcommand{\War}{\mathsf{War}}

\title[An algebra of mechanism composition]
  {An algebra of mechanism composition}

\author{}
\date{}

\subjclass[2020]{Primary 06A15, 52A01; Secondary 03B70, 68V15, 91G80}
\keywords{closure operator, convex geometry, Horn clause, union-closed family,
  compositionality, decentralised finance}

\begin{document}

\begin{abstract}
A protocol is modelled as a finite subset of a fixed vocabulary of mechanisms,
constrained by requirements, which state what a mechanism needs, and
prohibitions, which state which combinations are forbidden. Requirements are
dual-Horn and prohibitions Horn, so the sets satisfying the positive constraints
form a complete lattice under union while the admissible sets do not. The sets satisfying requirements and warrants form the agreement set of an
inflationary and a deflationary map; admissibility is that agreement set
intersected with the prohibition class, so the diagonal is its positive part
rather than the whole of it. Two constructions fail on that diagonal for one
reason. In an interlaced bilattice the diagonal is not reachable from the
componentwise product by a stated family of coordinatewise operations and
projections; and a pair of maps taking the diagonal to an inflationary and a
deflationary value is consistent only when both are the identity. Neither is an
obstruction to bilattices or to approximation fixpoint theory as such: the first
is about the stated family, the second about pairs that are not approximators. Bottom-up reasoning
over the powerset collapses for reasons intrinsic to the constraint set rather
than to any operator. On the fragment generated by definite requirements the closure is a convex
geometry, so every closed set has a unique minimal generator and the generator
of a composite is computable from those of its parts by a bounded number of word
operations. We instantiate the model on seventy-two decomposed protocols and, in
detail, on sixty of them, stating for each the obligations it discharges and
those the vocabulary cannot name. A partial classification of the unnameable
residue suggests three extensions --- a sort for parties, a constraint form for
obligations that cannot arise, and a bounded delegation schema --- and each is
priced against the results above.
\end{abstract}

\maketitle

\section{Introduction}

\subsection{The problem}

Decentralised finance is built on a promise of composition. Protocols are
deployed independently, by parties who have never communicated, and are then
combined: a lending market accepts as collateral a token that represents a
position in a liquid-staking protocol, which is itself secured by a validator
set that has been rented out to a third system. Each component was verified in
isolation, if at all. The composite was verified by nobody.

The promise is usually stated informally, as ``money legos''. The informality is
not innocent. It presumes that soundness is preserved by combination, and that
presumption is what fails: several of the largest losses in the sector arose not
from a defect in any single contract but from an interaction between contracts
that were individually working as designed. What is missing is not a better
auditing tool but an answer to a prior question --- \emph{what, if anything, does
composition preserve?}

Answering that requires first saying what a protocol \emph{is}, in a form on
which composition can act. This paper takes the coarsest such form that is still
faithful to practice: a protocol is a finite set of \emph{mechanisms} drawn from
a fixed vocabulary, together with constraints saying which mechanisms require
which others and which combinations are forbidden. The question then becomes
concrete: what is the algebraic structure of the admissible sets, and is it
closed under the operation that models composition?

\subsection{Where the vocabulary comes from}

The vocabulary is empirical rather than designed. Fifty-eight mechanisms were
extracted from a corpus of $72$ deployed protocols spanning twelve categories ---
spot exchange, lending, collateralised stablecoins, liquid staking, perpetual
futures, yield vaults, bridges, intent systems, tokenised real-world assets,
options, fiat-backed stablecoins and prediction markets --- selected by capital
or volume from live data rather than by reputation. Each protocol was decomposed
into mechanisms, and everything the vocabulary could \emph{not} express was
recorded as residue.

This matters for the reading of what follows. The vocabulary was not constructed
to have good algebraic properties, and it does not have them uniformly. It was
constructed to describe what is actually deployed, and it inherits the
irregularity of that subject. Two thirds of the recorded requirement
content is natural language rather than reference to a named mechanism; the
detail is finest where many independent implementations happen to exist and
coarsest where the underlying finance is hardest; and the largest single asset in
the corpus reduces to five mechanisms, of which three are approximations. A
formalism that assumed a clean vocabulary would be modelling a different object.

\subsection{The shape of the answer}

Two families of constraint act on protocols. \emph{Requirements} say what the
present mechanisms need. \emph{Warrants} remove mechanisms that
nothing present makes use of --- an element carried with no consumer is
unjustified, and in a security setting it is attack surface with no compensating
function. A protocol is \emph{admissible} when it satisfies both and is forbidden
by none of the prohibitions.

Read as operators where that is possible, the two point in opposite directions
relative to the identity: one inflationary, one deflationary. Satisfying both is therefore a
\emph{diagonal} --- the agreement set of two maps --- while being forbidden by
none of the prohibitions is a further condition the diagonal does not express.
That diagonal is the positive part of admissibility, and this single fact
explains a sequence of otherwise unrelated failures. The diagonal is not
reachable from the componentwise product by the operations and projections of
Definition~\ref{def:rect}, because their representation theorem makes them
componentwise products and a
componentwise structure is blind to a diagonal; and a pair of maps taking the
diagonal to an inflationary and a deflationary value is consistent only when both
are the identity. Such a pair is not an approximator in the sense of
approximation fixpoint theory, which requires exact pairs to map to exact pairs,
so the second is a statement about consistent bounding pairs and not about that
theory. The obstruction has the same shape in both cases, and recognising that is
more useful than either observation on its own.

What survives is proved rather than measured, and follows from clause polarity
alone. Requirements and warrants are both dual-Horn, so the protocols satisfying
them are closed under union and form a complete lattice; prohibitions are Horn and destroy that closure. Almost every observed composition failure arises from purely negative
prohibitions, which is what the polarity account predicts: Horn clauses are not
preserved by union. A lattice says little about any individual protocol, so the stronger result
concerns the deterministic core. Restricted to requirements with a single consequent, the
closure appears to satisfy the anti-exchange property, making it a \emph{convex
geometry} --- and in a convex geometry every closed set has a unique minimal
generator: an irredundant core from which the remainder follows by necessity,
defined on the closed set itself rather than on any presentation of it.

\subsection{Composition, and why it is a clique problem}

Composition does not preserve admissibility. This is not a modelling artefact;
explicit counterexamples exist, and the reason is structural. Requirements and
prohibitions have opposite clause polarity --- the first union-closed, the second
intersection-closed --- so their conjunction is closed under neither operation.
No amount of care in the encoding removes this.

The useful question is therefore how much of the admissible region \emph{is}
composable. Stated precisely, a family is composition-safe exactly when it is a
clique in the \emph{compatibility graph}, whose vertices are admissible protocols
and whose edges record that a pair composes to something admissible. The largest
composable family is then a maximum clique. Three things follow. Maximum clique is NP-hard in general, though we exhibit no
reduction showing that the graphs arising here realise a hard class. Safety is
not preserved by union, so maximal safe families need not be unique, which
leaves the uniqueness of a maximum-cardinality family open. And the productive
question is structural rather than extremal: whether the graph belongs to a
class on which clique is tractable. We conjecture perfection for the graph on
the listed-clause admissible sets, where compatibility is determined by
prohibition traces and the graph is a blow-up of a small quotient. The graph on
the operational predicate is not covered by that reduction, and we leave it
open.

\subsection{What this document is not}

It is not a claim that the vocabulary is complete, and the corpus measurement
argues against it: not one of the $72$ protocols is fully expressible, and the unexpressed part is
consistently the part on which protocols compete. Coverage degrades systematically as more of a protocol's substance lies
off-chain. It is not a verification method; nothing here establishes that any
protocol is safe. And it is not a finished theory. Results below are labelled by the
status conventions that follow, and the distinction between a proved statement
and a measured one is load-bearing throughout.

\section{Data and methods}\label{sec:methods}

\paragraph{Sampling frame.} Seventy-two protocols were selected across twelve
categories, the categories being those of the public aggregators from which the
rankings were drawn. Within each category, members were selected by the ranking
variable natural to it --- total value locked, notional volume, or circulating
supply --- from live data on 4 August 2026. No protocol was selected by
reputation. The categories are a sampling frame and not a construct of the
algebra: nothing proved in \S\S\ref{sec:models}--\ref{sec:convex} depends on
where their boundaries fall. Two consequences of the frame should be stated. It
is a capital-weighted sample, so it describes where value sits rather than what
is typical; and one category, treated in \S\ref{sec:cat:pred}, is a residual
holding systems that did not fall under another heading.

\paragraph{Units.} Two populations appear below and must not be conflated. All
seventy-two protocols were decomposed into element sets, and the corpus-level
measurements --- the counts of protocols satisfying the constraints, of
composing pairs, and of failures --- are over those seventy-two. Sixty of them,
the five highest-ranked of each category, were then given an obligation ledger
and a construction; every coverage and residue figure is over those sixty.

\paragraph{Obligation ledgers.} For each of the sixty, the behaviour of the
system was recorded as a list of obligations, each one thing the protocol does,
stated so that a reader can check it against a cited source, together with the
elements that discharge it. Where no element names the behaviour the obligation
is recorded with an empty element list. Recording an obligation as unnameable
was preferred to fitting a nearby symbol, and where a symbol was used
approximately the record says so. The ledgers hold 1{,}259 obligations across
60 applications; every obligation carries an evidence reference, and
639 distinct sources are cited.

\paragraph{Verification.} Admissibility, canonical forms, coverage, minimality
and the search for compositional decompositions were computed, not judged. The
figures reported in the measurement environments are generated from that
computation rather than transcribed into the text.

\paragraph{Reliability.} Coding was performed once per application against a
fixed instruction. No blinded overlap sample at fixed scope was taken, so
inter-rater reliability is unknown; the two systems that happen to have been
recorded twice did so under different category headings and at different scopes,
and their agreement figures are reported in \S\ref{sec:atlas} for what they are.
Coverage figures are sensitive to this: Measurement~\ref{meas:covsens} gives the
size of the effect.

\paragraph{Availability.} The element vocabulary and constraint tables, the
seventy-two decompositions, the sixty obligation ledgers with their evidence
references, the verification programs, the formalisation, and the programs that
generate every figure and table in this paper are available in the
accompanying repository.

\section{Preliminaries}

\begin{definition}[Vocabulary and protocols]
Let $\El$ be a finite set of \emph{elements} (mechanisms), $|\El| = 58$. A
\emph{protocol} is a subset $X \subseteq \El$. We write
$L = (2^{\El}, \subseteq)$ for the resulting complete lattice, with
$\bot = \emptyset$ and $\top = \El$.
\end{definition}

\begin{definition}[Requirements]
A \emph{requirement} is a pair $(s, T)$ with $s \in \El$ a \emph{subject} and
$T = \{T_1,\dots,T_k\}$ a finite family of \emph{terms}, each $T_j \subseteq \El$
a nonempty set of \emph{alternatives}. It is \emph{satisfied} by $X$ when
\[
  s \in X \;\Longrightarrow\; \forall j \le k,\; T_j \cap X \neq \emptyset .
\]
Write $\Law$ for the set of requirements. In clause form a requirement is
$\neg s \vee \bigvee_{e \in T_j} e$, which carries exactly one negative literal
and is therefore \emph{dual-Horn}.
\end{definition}

\begin{definition}[Prohibitions]
A \emph{prohibition} is a set $H \subseteq \El$, forbidden in the sense that
$H \not\subseteq X$ is required. Write $\Haz$ for the family of prohibitions; we
take $\Haz$ to be an antichain (a \emph{clutter}) of minimal forbidden sets. In
clause form a prohibition is $\bigvee_{e \in H} \neg e$: purely negative, hence
\emph{Horn}.
\end{definition}

\begin{definition}[Warrants]
A \emph{warrant} is a pair $(e, C)$ with $e \in \El$ and $C \subseteq \El$ a set
of \emph{consumers}. It is satisfied by $X$ when
$e \in X \Rightarrow C \cap X \neq \emptyset$. Write $\War$ for the set of
warrants. Where a requirement says what $e$ \emph{needs}, a warrant says what $e$
is \emph{for}: an element present with no consumer is unwarranted.
\end{definition}

$\War$ is independent data. The vocabulary as originally recorded contains
$\Law$ and $\Haz$ only; the consumer relation $C$ was recorded alongside them,
and $|\War| = 27$. It is tempting to read $C$ as the residual (order-theoretic
adjoint) of the requirement relation, but it is not one: no element's consumer
set coincides with the set of subjects that can require it. Ten elements have
both and disagree, seventeen have a consumer and no requiring subject, and eight
the reverse. Section~\ref{sec:tradeoff} takes up what replacing $C$ by the true
residual would cost.

\begin{table}[t]\centering\small
\begin{tabular}{ll}
\toprule
\multicolumn{2}{l}{\emph{Objects}}\\
$\El$ & the vocabulary, a finite set of $58$ elements (mechanisms)\\
$X, Y$ & protocols: subsets of $\El$\\
$P$ & an application: a deployed system, described by obligations\\
$(o, S_{o})$ & an obligation and the elements that discharge it\\
$\mathcal{O}$ & a finite set of obligations\\
\midrule
\multicolumn{2}{l}{\emph{Constraints}}\\
$\Law$ & requirements, each $\neg s \vee \bigvee_{e \in T} e$; dual-Horn\\
$\War$ & warrants, derived; $C$ the fitted assignment, $C^{\ast}$ the residual\\
$\Haz$ & prohibitions, each $\bigvee_{e \in H} \neg e$; Horn\\
\midrule
\multicolumn{2}{l}{\emph{Model classes}}\\
$\mathcal{R},\mathcal{W},\mathcal{H}$ & the models of $\Law$, $\War$, $\Haz$\\
$\Pos$ & $\mathcal{R} \cap \mathcal{W}$; the object of the lattice, composition and diagonal results\\
$\Adm$ & $\Pos \cap \mathcal{H}$; the model class of the recorded clauses\\
$\Admf$ & $\Adm$ with grounding and the conditional prohibitions; the operational predicate\\
\midrule
\multicolumn{2}{l}{\emph{Closure and composition}}\\
$Cn$ & the closure generated by the definite requirements\\
$D$, $\preceq$ & the definite-requirement digraph and its specialization order\\
$\mathrm{ex}(A)$ & the $\preceq$-maximal elements of $A$: its canonical form\\
$X \oplus Y$ & $Cn(X \cup Y)$\\
$G_\oplus$ & the compatibility graph on $\Admf$\\
\bottomrule
\end{tabular}
\caption{Notation. Element symbols such as $Cp$, $Ct$, $Ex$ name mechanisms,
and clause identifiers such as $L1$ and $X2$ name recorded rows. The
supplement's appendix on the instantiated vocabulary lists all 58 elements,
the 29 requirement rows, the 27 warrant entries and the 20 prohibition rows
in full.}
\label{tab:notation}
\end{table}

\section{Model classes, not operators}\label{sec:models}

It is tempting to model requirements by a closure operator that adds what is
missing. For disjunctive requirements no such operator exists: a term with
several alternatives determines no unique addition, so there is no canonical
map $L \to L$ whose fixed points are the models of $\Law$. We therefore work with
model classes throughout, and reserve operator language for the definite fragment
of \S\ref{sec:convex}, where it is available.

\begin{definition}[Model classes]
For a clause set $S$ write $\mathcal{M}(S) = \{X \subseteq \El : X \models S\}$.
Put
\[
  \mathcal{R} = \mathcal{M}(\Law), \qquad
  \mathcal{W} = \mathcal{M}(\War), \qquad
  \mathcal{H} = \mathcal{M}(\Haz), \qquad
    \Pos = \mathcal{R} \cap \mathcal{W}, \qquad
    \Adm = \Pos \cap \mathcal{H}.
\]
\end{definition}

Three classes are in play and they are not the same. $\Pos$ is the positive
part --- the models of the requirements and warrants --- and it is the object of
the lattice, composition and diagonal results of
\S\S\ref{sec:models}--\ref{sec:convex}: those results are proved for $\Pos$
and do not transfer to the smaller classes, since $\El$ lies in $\Pos$ and in
neither of them. $\Adm$ is the model class of the recorded clauses. The
empirical work uses a third and strictly stronger predicate.

\begin{definition}[The operational predicate]\label{def:admfull}
Write $\Admf$ for the sets that lie in $\Adm$, satisfy the \emph{grounding
condition} --- a set carrying an element of a risk-bearing group must carry some
element of stratum at most two --- and violate none of the \emph{conditional
prohibitions}, each of which is a clause with two or more negative literals
together with a positive one. Thus $\Admf \subseteq \Adm$, and the inclusion is
strict.
\end{definition}

\begin{remark}
Every theorem below is stated for the predicate it is proved for, and the
predicates differ. The lattice result is about $\Pos$; the polarity results are
about $\mathcal{R}$, $\mathcal{W}$ and $\mathcal{H}$ separately; the convex
geometry is about $Cn$ on the definite fragment. None transfers to $\Admf$,
because the conditional prohibitions lie outside the Horn/dual-Horn
classification on which they rest. Every figure computed against
deployed protocols --- the counts of satisfying protocols, of composing pairs
and of failures, and every construction of \S\ref{sec:construct} --- is computed
against $\Admf$.
\end{remark}

\begin{lemma}[Polarity]\label{lem:polarity}
Every requirement and every warrant is a clause with exactly one negative
literal, hence dual-Horn. Every prohibition is purely negative, hence Horn.
\end{lemma}

\begin{proof}
A requirement $(s,T)$ contributes $\neg s \vee \bigvee_{e \in T_j} e$ for each
$j$; a warrant $(e,C)$ contributes $\neg e \vee \bigvee_{c \in C} c$. A
prohibition $H$ contributes $\bigvee_{e \in H} \neg e$.
\end{proof}

\begin{theorem}[Closure properties]\label{thm:closure}
$\mathcal{R}$ and $\mathcal{W}$ are closed under union; $\mathcal{H}$ is closed
under intersection. Neither $\mathcal{R}$ nor $\mathcal{W}$ is closed under
intersection, and $\mathcal{H}$ is not closed under union.
\end{theorem}

\begin{proof}
A Boolean relation is closed under conjunction exactly when it is Horn-definable,
and closed under disjunction exactly when it is definable by clauses with at most
one negated literal \cite[Ex.~5.3.5]{jeavons1997}. Applied coordinatewise this is
closure under intersection and union respectively.

For the negative halves, three witnesses. $\{Ct,Ex,Im,Li\}$ and
$\{At,Ct,Im,Li\}$ both lie in $\mathcal{R}$ while their intersection
$\{Ct,Im,Li\}$ does not, since $L1$ is unsatisfied: the price witnesses
available to $Im$ are $Ex$ and $At$, and each survives in only one of the two. $\{Ad,Ba,Fl,Im,Ob,
Pm,Sh\}$ and $\{Ag,Ba,Cl,Cp,Fl,Ix,Pl,Rb\}$ lie in $\mathcal{W}$ while their
intersection $\{Ba,Fl\}$ does not, $Fl$ having no consumer there. And
$\{Fl,Cp\}$ and $\{Pl\}$ both lie in $\mathcal{H}$, arming no
prohibition, while their union $\{Cp,Fl,Pl\}$ arms $X2$.
\end{proof}

\begin{remark}
This is the Pol--Inv characterisation, not Schaefer's dichotomy
\cite{schaefer1978}: Schaefer's Lemma 3.1W characterises weakly positive and
weakly negative formulas via $0/1$-closed variable sets, and his only
componentwise-closure statement is the majority condition for bijunctive
formulas, which is the correct citation for
Measurement~\ref{meas:arity} rather than for this theorem.
\end{remark}

\begin{corollary}[Structure of $\Pos$]\label{cor:lattice}
$\Pos$ is a union-closed family containing $\emptyset$ and $\El$, hence a
complete lattice under inclusion with $\bigvee = \bigcup$.
\end{corollary}

\begin{proof}
Intersections of dual-Horn model classes are dual-Horn, so union-closure is
inherited from Lemma~\ref{lem:polarity} and Theorem~\ref{thm:closure}. Both $\emptyset$ and $\El$ satisfy every clause with a nonempty antecedent,
$\El$ because every consumer set and every requirement term is nonempty. A
union-closed family with a top element is a complete lattice, joins being unions
and meets the union of all common lower bounds.
\end{proof}

\begin{proposition}[The operations]\label{prop:joinmeet}
In $\mathcal{R} \cap \mathcal{W}$ the join of $A$ and $B$ is $A \cup B$, and the
meet is the join of all common lower bounds. Meet is not intersection, and it is
not obtained by applying $\Delta$ to the intersection either.
\end{proposition}

\begin{proof}
Join is union by Corollary~\ref{cor:lattice}. For the meet, take
$A = \{Ct,Ex,Im,Li\}$ and $B = \{At,Ct,Im,Li\}$, both in
$\mathcal{R} \cap \mathcal{W}$. Their intersection $\{Ct,Im,Li\}$ violates $L1$:
the price witnesses available to $Im$ are $Ex$ and $At$, and each survives only
in the other set. $\Delta$ removes nothing from the intersection, so
$\Delta^{\omega}(A \cap B) \notin \mathcal{R} \cap \mathcal{W}$ and is not the
meet. Every non-empty subset of $\{Ct,Im,Li\}$ fails $\Law$ or leaves an
element unwarranted, so the meet is $\varnothing$.
\end{proof}

The failure is Proposition~\ref{prop:noinvariance} in another guise: $\Delta$ does
not preserve $\mathcal{R}$, so no formula built by applying $\Delta$ to a
set-theoretic operation can be relied on. The meet exists by completeness, and is
computed as a supremum rather than by a closure.

\begin{corollary}\label{cor:oplusclosed}
$\Pos$ is closed under $\oplus$: verified on $96{,}720$ pairs with no
failure. Composition $\oplus$ is defined at
Definition~\ref{def:oplus}; only the fact that it is a closure of the union is
used here.
\end{corollary}

\begin{corollary}\label{cor:admnotlattice}
$\Admf$ is not union-closed and so is not a sublattice of
Corollary~\ref{cor:lattice}.
\end{corollary}

\begin{proposition}[A third clause class]\label{prop:mixed}
Lemma~\ref{lem:polarity} does not exhaust the constraint set, and the recorded
conditional rows fall into three classes rather than one. A row whose forbidden
configuration is a conjunction of present elements negates to a purely negative
clause, which is Horn: $X2$ and $X21$ are of this kind. A row that also requires
the \emph{absence} of elements negates to a clause carrying those elements
positively. Such a clause is Horn when at most one of its literals is positive
and dual-Horn when at most one is negative, so it is neither exactly when at
least two are positive and at least two negative. $X18$, with two of each, and
$X19^{*}$, with two negative and three positive, are of this kind. One row, $X11a^{*}$,
negates to a clause with a single negative literal and is dual-Horn.
\end{proposition}

\begin{measurement}[Where composition actually fails]\label{meas:whereitfails}
Of the $185$ failing pairs among the $61$ protocols satisfying the requirements
and warrants, \emph{none} fails through a requirement, a warrant or the
grounding condition. Every failure arms a prohibition. Of these, $147$ arm
$X21$ and $37$ arm $X2$, both purely negative and hence Horn, and $6$ arm
$X19^{*}$, which is genuinely mixed; some pairs arm two rows. The dual-Horn row
$X11a^{*}$ causes no failure.
\end{measurement}

Composition failure is therefore explained by the polarity account rather than
falling outside it. Requirements and warrants are dual-Horn and cost nothing;
the prohibitions are Horn, Horn model classes are not union-closed, and $184$ of
the $185$ failures arm a Horn row. The two mixed-polarity rows are real but
marginal, accounting for six failures between them.

\begin{definition}[Warrant]
$X$ \emph{warrants} $e \in X$ if $C(e) \cap X \neq \emptyset$. The map
$\Delta(X) = \{e \in X : X \text{ warrants } e\}$, iterated to a fixed point, is
deflationary and monotone; its fixed points are exactly $\mathcal{W}$.
\end{definition}

\section{Obstructions}\label{sec:obstructions}

\begin{definition}[Rectangles, and the permitted constructions]\label{def:rect}
Call $P \subseteq \mathcal{R} \times \mathcal{W}$ a \emph{rectangle} if
$P = S \times T$ for some $S \subseteq \mathcal{R}$ and
$T \subseteq \mathcal{W}$. Let $\mathcal{C}$ be the smallest family of subsets
of $\mathcal{R} \times \mathcal{W}$ that contains $\mathcal{R} \times
\mathcal{W}$ and is closed under
\begin{enumerate}
  \item[(i)] \emph{coordinatewise operation}: for $P, Q \in \mathcal{C}$ and a
    bilattice operation $\ast$ acting as $\ast_{1}$ on the first coordinate and
    $\ast_{2}$ on the second,
    $\{(a \ast_{1} c,\; b \ast_{2} d) : (a,b) \in P,\ (c,d) \in Q\}$;
  \item[(ii)] \emph{projection and re-pairing}: for $P, Q \in \mathcal{C}$,
    $\pi_{1}[P] \times \pi_{2}[Q]$.
\end{enumerate}
The members of $\mathcal{C}$ are the sets \emph{obtained from} $\mathcal{R}
\odot \mathcal{W}$ by the bilattice operations and the coordinate projections.
Unions are not among the permitted constructions: Avron's operations act
coordinatewise on elements, and a union of rectangles need not be a rectangle.
\end{definition}

\begin{proposition}[Bilattices]\label{thm:bilattice}
Let $B$ be an interlaced bilattice with $B \cong \mathcal{R} \odot \mathcal{W}$
under Avron's representation. Then $\operatorname{Diag} = \{(x,x) : x \in \Pos\}$
is not a member of $\mathcal{C}$.
\end{proposition}

\begin{proof}
By Avron's representation theorem \cite{avron1996} every interlaced bilattice is
isomorphic to a componentwise product, uniquely, and its operations act
coordinatewise; this is what licenses reading $\ast$ as the pair
$(\ast_{1}, \ast_{2})$ in Definition~\ref{def:rect}.

Every member of $\mathcal{C}$ is a rectangle, by induction on its construction.
The base $\mathcal{R} \times \mathcal{W}$ is one. If $P = S \times T$ and
$Q = S' \times T'$ are rectangles then the set formed by (i) is
$\{a \ast_{1} c : a \in S,\, c \in S'\} \times \{b \ast_{2} d : b \in T,\,
d \in T'\}$, again a rectangle, because the two coordinates are chosen
independently; and the set formed by (ii) is $\pi_{1}[P] \times \pi_{2}[Q] =
S \times T'$, a rectangle.

Suppose $\operatorname{Diag} = S \times T$. Because $\Pos$ contains both
$\emptyset$ and $\El$ it has at least two members; take $x \neq y$ in it. Then
$(x,x)$ and $(y,y)$ lie in $\operatorname{Diag}$, so $x, y \in S$ and
$x, y \in T$, whence $(x,y) \in S \times T = \operatorname{Diag}$ ---
contradicting $x \neq y$. So $\operatorname{Diag}$ is not a rectangle, and
therefore not a member of $\mathcal{C}$.
\end{proof}

\begin{remark}
The obstruction is one of reachability, and it is a statement about
$\mathcal{C}$. Every construction permitted by Definition~\ref{def:rect} chooses
its two coordinates independently, and the diagonal does not. Avron's theorem
supplies the product representation; it does not single out $\mathcal{C}$ as the
only notion of representability, so nothing here shows that interlaced bilattices
cannot represent the diagonal by some other means.
\end{remark}

\begin{definition}[Inflationary selections]\label{def:gamma}
A map $\Gamma \colon L \to L$ is an \emph{inflationary selection} for $\Law$ if
$X \subseteq \Gamma(X)$ for every $X$ and $\Gamma(X) \models \Law$ whenever some
superset of $X$ does. Section~\ref{sec:models} shows that no such $\Gamma$ is canonical: a
disjunctive term determines no unique addition, so a choice is made at each.
Selections exist --- add, for each unsatisfied term, its least alternative in
some fixed order --- and every result below is stated for the whole class, so
nothing depends on which is taken. The definite closure $Cn$ is \emph{not} a
selection: it acts only on singleton-consequent requirements and may leave a
disjunctive term unsatisfied.
\end{definition}

\begin{theorem}[Consistent bounding pairs]\label{thm:aft}
Let $\Gamma$ be an inflationary selection and $\Delta$ the warrant kernel.
Call $(\Gamma,\Delta)$ a \emph{consistent bounding pair} if
$\Gamma(x) \le \Delta(x)$ for every $x$. Then the pair is consistent only if
$\Gamma = \Delta = \mathrm{id}$. The argument uses only that $\Gamma$ is
inflationary and $\Delta$ deflationary, so it holds for every selection at once.

This is \emph{not} a statement about approximation fixpoint theory. An
approximator there is precision-monotone and maps exact pairs to exact pairs, so
a diagonal whose two components differ fails that definition before the
inequality below is reached; the pair above is therefore not an approximator and
no obstruction to the framework is claimed.
\end{theorem}

\begin{proof}
Every approximator is required to preserve consistency: $A^1(x,y) \le A^2(x,y)$.
Evaluating on the diagonal, $A(x,x) = (\Gamma(x), \Delta(x))$ gives
$\Gamma(x) \le \Delta(x)$ for all $x$. But $\Gamma$ is inflationary, so
$x \le \Gamma(x)$, and $\Delta$ is deflationary, so $\Delta(x) \le x$. Chaining,
\[
  \Gamma(x) \;\le\; \Delta(x) \;\le\; x \;\le\; \Gamma(x),
\]
whence $\Gamma(x) = \Delta(x) = x$ for every $x$. The argument uses neither exactness nor $\le_p$-monotonicity. Its scope is
exactly the approximators satisfying $A(x,x) = (\Gamma(x), \Delta(x))$ on the
diagonal, which is what it means here for $A$ to have components $\Gamma$ and
$\Delta$; it says nothing about approximators not of that form.

That hypothesis is incompatible with exactness, and the incompatibility is worth
stating. An exact approximator satisfies $A(x,x) = (O(x), O(x))$ for the operator
$O$ it approximates, so pairing two \emph{different} maps on the diagonal is
already non-exact unless they agree everywhere --- which is the conclusion. The
theorem is therefore a statement about non-exact approximators of a particular
shape, and it is not evidence that approximation fixpoint theory is unsuited to
the subject.
\end{proof}

\begin{corollary}
The assignment is backwards: an approximator's lower component must
\emph{under}-approximate, while a closure operator \emph{over}-approximates.
Exchanging the roles is admissible but vacuous, since $\lfp(\Delta) = \bot$
identically, so the induced stable operator is constant.
\end{corollary}

\begin{remark}
A common misdiagnosis should be recorded. It is \emph{not} the case that
monotonicity of both $\Gamma$ and $\Delta$ obstructs $\le_p$-monotonicity of $A$:
antitonicity in the second argument is satisfied vacuously by constancy, and for
monotone $O$ the ultimate approximator is exactly the product
$(O(x), O(y))$. The obstruction is consistency, as above.
\end{remark}

\section{Collapse over the powerset}

\begin{proposition}\label{prop:collapse}
Let $O$ be any operator on $L$ with $\Fix(O) = \Admf$. If
\emph{(i)} $\emptyset \in \Admf$ and \emph{(ii)} $\bigcup \Admf = \El$, then the
ultimate approximator satisfies $U_O(\bot,\top) = (\bot,\top)$; the
Kripke--Kleene fixpoint is $(\bot,\top)$ and carries no information.
\end{proposition}

\begin{proof}
$U_O(x,y) = \bigl(\bigwedge O([x,y]),\ \bigvee O([x,y])\bigr)$. The interval
$[\bot,\top]$ contains $\emptyset$, and by (i) $O(\emptyset) = \emptyset$, so the
lower bound is $\bot$. By (ii) the upper bound is $\top$. Hence
$(\bot,\top)$ is a fixed point of the iteration at the first step.
\end{proof}

\begin{remark}
Hypotheses (i) and (ii) hold for our vocabulary and are facts about the
\emph{constraint set}, not about $O$: (i) because every requirement is an
implication with a nonempty antecedent, so the empty protocol violates nothing;
(ii) because every element occurs in some admissible set. Proposition
\ref{prop:collapse} therefore rules out bottom-up reasoning over $2^{\El}$ for
\emph{every} operator with the right fixpoints. The obstruction is the lattice.
\end{remark}

\section{Completion lattices}

\begin{definition}[Completion lattice]
For a seed $S \subseteq \El$, the \emph{completion lattice} is the interval
$[S,\top] = \{X : S \subseteq X \subseteq \El\}$, and the associated question is
\emph{which extensions of $S$ are admissible}.
\end{definition}

\begin{proposition}
$\Gamma$ restricts to $[S,\top]$, since it is inflationary. $\Delta$ does not
restrict; the corrected operator $\Delta_S(X) \coloneqq \Delta(X) \cup S$ does.
\end{proposition}

\begin{definition}[Downward iteration]
Set $x_0 = \top$ and $x_{n+1} = \Gamma\bigl(\Delta(x_n) \cup S\bigr)$, and let
$x_\infty$ be the limit.
\end{definition}

\begin{proposition}[The iteration is vacuous here]\label{prop:vacuous}
If every dependent element has a consumer present in $\top$, then
$\Delta(\top) = \top$, and since $\Gamma$ is inflationary the iteration is
stationary at $x_0$: $x_\infty = \top$ for every seed.
\end{proposition}

\begin{proof}
Warrant is a \emph{co-presence} condition: $e$ is unwarranted in $X$ only if
$C(e) \cap X = \emptyset$. At $X = \top$ every consumer set is met, so $\Delta$
removes nothing. Then $x_1 = \Gamma(\top \cup S) = \top$.
\end{proof}

\begin{remark}
A ban-aware variant does descend and recovers the atomic-scope prohibition on
seed $\{Fl,Xm\}$, but it is \emph{unsound}: on seed $\{Uc\}$ it prunes to
$\{Uc,Aw,At\}$, excluding every witness of the third and fourth terms of the
governing requirement, and so declares $Uc$ uncompletable although two live
protocols instantiate it. 
\end{remark}

\section{The positive theory does not bind}\label{sec:vacuity}

The results of Section~\ref{sec:obstructions} concern frameworks. This section
concerns the content, and is the more serious finding.

\begin{measurement}[Vacuity at scale]\label{meas:vacuous58}
Take as seeds the $72$ decomposed protocols and compute, for each, the set of
elements that remain possible in some admissible completion. The median fraction
of candidate elements \emph{excluded} is $0.0\%$ (min $0.0$, p25 $0.0$, p75
$2.1$, max $12.2$, mean $1.8$). For $37$ of $72$ seeds the upper bound is exactly
$\top$. Across all seeds, $61$ exclusions out of $3{,}553$ candidate slots.
\end{measurement}

\begin{measurement}[Ablation: the positive clauses exclude nothing]\label{meas:ablation58}
Of the $93$ clauses transcribing admissibility ($31$ closure, $27$ warrant, $21$
grounding, $14$ negative), the positive fragment --- all $79$ closure, warrant
and grounding clauses --- excludes \textbf{zero} elements across all $72$ seeds.
Every one of the $61$ exclusions is attributable to two hand-written
prohibitions, $X21$ ($32/72$) and $X2$ ($8/72$).
\end{measurement}

\begin{remark}[Consequence]
Measurement~\ref{meas:ablation58} is not a statement about a semantics. It says
that the $79$ positive constraints of the vocabulary, taken together, do not
bind any completion of any real protocol at $|\El| = 58$. Whatever discriminating
power the requirement and warrant tables possess is exercised by
\emph{rejecting} candidate sets, not by \emph{constraining} extensions. Any
proposal to use the positive theory as a completion oracle is therefore ruled out
on content, independently of the framework chosen to express it.
\end{remark}

\begin{remark}[Method]
The bound is exact rather than approximated: membership of each element reduces
to one satisfiability query against a complete decision procedure, so each
exclusion is a proof. Soundness was checked by $3{,}938$ inclusion certificates
and $9{,}600$ sampled admissible completions, with no violation; the encoding was
validated against an independent implementation on $305{,}272$ sets with no
mismatch. Total cost $3.15$ seconds.
\end{remark}

\section{What the carrier cannot express}

\begin{proposition}[No reflexivity over element types]\label{prop:dag}
The requirement relation on $\El$, taking every alternative of every term, is a
directed acyclic graph without self-loops. Consequently no $X \subseteq \El$
contains a requirement cycle.
\end{proposition}

\begin{corollary}
Reflexive failure modes are not expressible over element types. They become
expressible over $\El \times \mathcal{A}$ for an asset set $\mathcal{A}$, under
the relation $\mathrm{backs} \coloneqq \mathrm{reads} \mathbin{;} \mathrm{over}^{-1}$.
\end{corollary}

\begin{conjecture}[Fibre separation]\label{conj:fibre}
There exist protocols $P \neq Q$ with identical element sets and materially
different solvency. Hence no function of $2^{\El}$ separates them, and separation
requires a party sort carrying obligor, attester and jurisdiction.
\end{conjecture}

\section{Composition}

\begin{definition}[Definite closure]\label{def:cn}
Let $Cn$ be the closure operator generated by the requirements whose terms are
singletons: $Cn(X)$ is the least superset of $X$ closed under every rule
$s \to \{e\}$ of $\Law$.
\end{definition}

\begin{definition}[Composition]\label{def:oplus}
$X \oplus Y \coloneqq Cn(X \cup Y)$, with $Cn$ as in
Definition~\ref{def:cn}. No closure operator exists for the disjunctive
requirements (\S\ref{sec:models}), so composition is defined on the deterministic
fragment and every statement about $\oplus$ below is a statement about that
fragment.
\end{definition}

\begin{definition}[Decomposition and construction]\label{not:decomp}
For a protocol $P$ write $D(P) \subseteq \El$ for its corpus decomposition, the
element set recorded for it in \S\ref{sec:atlas}. This is distinct from a
construction \emph{exhibited} for an application, written $X_{P}$ in
\S\ref{sec:construct}: the two need not agree, and for Uniswap they do not.
A bare protocol name never denotes a set.
\end{definition}

\begin{theorem}\label{thm:noncong}
$\oplus$ does not preserve admissibility: there exist $X, Y \in \Admf$ with
$X \oplus Y \notin \Admf$.
\end{theorem}

\begin{proof}
Take $X = D(\text{Uniswap})$ and $Y = D(\text{Aave v3})$:
\[
  X = \{Cl,Cp,Fd,Fl,Sh,Tg,Tp\}, \qquad
  Y = \{Bs,Cd,Ct,Em,Ex,Fd,Fl,Gp,Im,Ix,Li,Pl,Rb,Sl,Tg,Up,Xm\}.
\]
Each lies in $\Admf$: both satisfy $\Law$ and $\War$, arm no prohibition, and
are grounded. Their union has $21$ elements and satisfies $\Law$ and $\War$
still, but it carries $Fl$ together with $Cp$ and with $Pl$ and $Cd$, which arms
$X2$. Since $Cn$ only adds definite consequences, $X \oplus Y = Cn(X \cup Y)
\supseteq X \cup Y$ arms $X2$ as well. Hence $X \oplus Y \notin \Admf$.
\end{proof}

\begin{conjecture}\label{conj:frag}
There is a union-closed $F \subseteq \Admf$ certifying a substantial fraction of
live protocol pairs. A lower bound is witnessed by exhibiting one: the twenty-two
elements
\[
  \{Ag,At,Ba,Cl,Cp,Em,Ep,Fd,Gp,In,Ix,Oa,Ob,Pm,Rf,Sh,Sr,St,Tg,Up,Wg,Wq\}
\]
are \emph{free}, meaning every one of their $2^{22} = 4{,}194{,}304$ subsets is
admissible. Their powerset is therefore union-closed and contained in $\Admf$,
so $|F| \geq 4{,}194{,}304$. The set is not maximal --- further elements can be
added --- and no certification rate is claimed for it.
\end{conjecture}

\begin{remark}[Width, indicatively]
Monte-Carlo runs on synthetic $2^8$ atlases suggest composition success falls as
maximum disjunctive width rises. We report this as an indication only: it is not
computed from the corpus and no inference in this paper depends on it.
\end{remark}

\begin{remark}
It is tempting to read the width runs as showing that the recurring
``good fragment'' phenomenon is a \emph{single} effect parameterised by
disjunctive width. That is half right, and the half that is wrong matters.
Proposition~\ref{prop:twoeffects} separates the two causes: prohibitions destroy
$\cup$-closure and nothing else, while disjunctive requirements destroy
$\cap$-closure and nothing else. Width governs one of the two failures, not both.
\end{remark}

\begin{proposition}[Two independent failures]\label{prop:twoeffects}
Let $\mathcal{M}(\Law)$ and $\mathcal{M}(\Haz)$ denote the model classes of the
requirements and the prohibitions. If some requirement has a term of width at
least two, both of whose alternatives are attained by models and neither of
which is implied by the rest, then $\mathcal{M}(\Law)$ is not closed under
intersection. If $\Haz$ contains a forbidden set of size at least two whose
proper subsets are attained by models, then $\mathcal{M}(\Haz)$ is not closed
under union. The converses fail: a term of width two whose alternatives include
its own subject is tautologous, a redundant requirement does not change the
model class, and a prohibition family all of whose members are singletons has a
union-closed model class. The two failures are independent: neither implies nor
mitigates the other.
\end{proposition}

\section{What the prohibitions cost}\label{sec:cost}

Corollary~\ref{cor:lattice} gives a complete lattice; Corollary~\ref{cor:admnotlattice}
says the prohibitions remove it. This section records the size of that loss.

\begin{proposition}\label{prop:noinvariance}
$\Delta$ does not preserve $\mathcal{R}$: there is $X \in \mathcal{R}$ with
$\Delta(X) \notin \mathcal{R}$.
\end{proposition}

\begin{proof}
$X = \{Ct,Im,Li,Tp\} \models \Law$, and $\Delta^{\omega}(X) = \{Ct,Im,Li\}$, in
which $L1$ is unsatisfied. The element $Tp$ is the only witness in $X$ for a term
$Im$ depends on, yet $Im \notin C(Tp)$, so $Tp$ counts as unwarranted and is
removed.
\end{proof}

Proposition~\ref{prop:noinvariance} does not threaten Corollary~\ref{cor:lattice},
which is proved from clause polarity and does not use $\Delta$ as an operator on
$\mathcal{R}$. It does mean that computing $\mathcal{R} \cap \mathcal{W}$ by
alternating the two conditions is unsound, and that no Tarski-style \cite{tarski1955} argument is
available.

\section{Structure and content are in tension}\label{sec:tradeoff}

The warrant relation is not the residual of the requirement relation, which suggests a repair: replace $C$ by the true
residual of $R$. The repair restores invariance and destroys the operator, and the
tension between the two is the substantive result of this section.

\begin{measurement}[The residual restores invariance]\label{meas:repair}
Of the $57$ (subject, term-alternative) pairs in the residual of $R$, $32$ are
absent from $C$. Taking $C$ to be the residual and testing over the same
$224{,}025$ closed sets gives $0$ invariance failures.
\end{measurement}

\begin{corollary}\label{cor:residual}
If $C$ is the residual of $R$ then $\Delta$ is $\mathcal{R}$-invariant, and
$\mathcal{R} \cap \mathcal{W}$ is a complete lattice by Tarski's theorem \cite{tarski1955}.
\end{corollary}

\begin{measurement}[The repair destroys the operator]\label{meas:tradeoff}
Under the fitted assignment $C$, $\Delta$ fixes $71$ of $72$ protocols and $35$ of
$84$ synthetic negatives --- a separation of $+0.569$. Under the true residual it
fixes $13$ of $72$ real protocols and $25$ of $84$ negatives, a separation of
$-0.117$. The repaired operator rejects $82\%$ of deployed protocols and is
\emph{anti-correlated} with reality: it discards real designs more readily than
synthetic corruptions.
\end{measurement}

\begin{remark}[The trade-off]
The residual and the fitted table are incomparable, not nested: $27$ elements
carry a consumer entry and $18$ a residual entry, $10$ are defined in both and
disagree on every one, $17$ have a consumer and no requiring subject, and $8$ the
reverse. Neither refines the other. The assignment that brings $\Delta$ into
agreement with deployed practice is nevertheless the one that destroys the
residual property and with it invariance. One may therefore have
\begin{itemize}
  \item a \textbf{structure theorem} --- $\Pos$ a complete lattice --- with an
    operator that rejects four fifths of real DeFi; or
  \item an operator \textbf{consistent with practice}, with no known structure on
    $\Adm$.
\end{itemize}
and not both. A lattice computed by a predicate anti-correlated with deployed
protocols is not a description of the subject, so we take the second. The
conclusion is that \textbf{the warrant relation is under-determined}: the data
admits at least two incompatible extensions and nothing in the vocabulary
adjudicates between them.
\end{remark}

\begin{remark}[What would resolve it]
The question is whether any consumer assignment is both invariant and
faithful. It cannot be posed as a search between the two in hand, because they
are incomparable and no assignment lies between them. The residual is the
assignment that makes invariance provable; the shipped table is one fitted to
practice; they agree on no element defined in both. What is searchable is the
space of assignments that dominate the residual on the elements where invariance
needs it while agreeing with the table where practice does, and whether any
member of it exists is open.
\end{remark}

\section{The definite fragment is a convex geometry}\label{sec:convex}

On the definite fragment a closure operator does exist, and its structure is
determined completely by two conditions, both of which our instance satisfies.

\begin{definition}[The definite digraph]\label{def:digraph}
Write $D$ for the digraph on $\El$ with an arc $s \to e$ for each singleton-term
rule $s \to \{e\}$ --- the rules generating $Cn$ of
Definition~\ref{def:cn} --- and $\preceq$ for the specialization preorder
$a \succeq b \iff b \in Cn(\{a\})$.
\end{definition}

\begin{lemma}[Singleton premises \cite{caspardmonjardet2004}, \S3]\label{lem:cm}
If every implication $A \to B$ has $|A| = 1$, the induced closure system is
union-stable. The condition is on the \emph{premise}, not the consequent: a
singleton premise with $|B| > 1$ is stable, while $\{a,b\} \to \{c\}$ is not.
\end{lemma}

\begin{remark}
The converse fails without nontriviality conditions, and only the direction above
is used here. A tautological implication with $B \subseteq A$ induces the identity
closure and is union-stable for any $|A|$; and $A = \emptyset$ induces
$X \mapsto X \cup B$, which is union-stable for any $B$. Neither is a
singleton-premise implication, and neither arises in $\Law$.
\end{remark}

\begin{lemma}[\cite{edelmanjamison1985}, Thm.\ 3.2]\label{lem:ej}
A convex geometry is a downset alignment if and only if its closure system is
union-closed.
\end{lemma}

\begin{theorem}\label{thm:convex}
A union-stable closure satisfies anti-exchange if and only if $\preceq$ is
antisymmetric, i.e.\ if and only if $D$ is acyclic. In that case $(\El, Cn)$ is
the down-set geometry of the poset $(\El, \preceq)$.
\end{theorem}

\begin{proof}[Proof sketch]
Union-stability follows from Lemma~\ref{lem:cm} since every definite requirement
has a single subject. Given it, $Cn$ is reachability in $D$, so $Cn(\{a\})$ is the
principal down-set of $a$ and the closed sets are exactly the down-sets of
$\preceq$. Antisymmetry makes $\preceq$ a partial order, and the down-sets of a
poset form a convex geometry by Lemma~\ref{lem:ej}. Conversely a directed cycle
$x \to y \to x$ gives $\emptyset$ closed with $y \in Cn(\{x\})$ and
$x \in Cn(\{y\})$, contradicting anti-exchange.
\end{proof}

\begin{corollary}\label{cor:ourconvex}
$(\El, Cn)$ is a convex geometry, on all $2^{58}$ subsets.
\end{corollary}

\begin{proof}
$D$ has $15$ arcs and $58$ strongly connected components, none non-trivial, so it
is acyclic; and $Cn$ coincides with reachability in $D$ (checked on $21{,}712$
seeds). Apply Theorem~\ref{thm:convex}.
\end{proof}

\begin{corollary}[Canonical form]\label{cor:ex}
Every closed set $A$ has a unique minimal generator
$\mathrm{ex}(A) = \max_{\preceq}(A)$, its set of $\preceq$-maximal elements.
\end{corollary}

\begin{theorem}[Composition on canonical forms]\label{thm:excomp}
Assume $D$ acyclic (Corollary~\ref{cor:ourconvex}). For $Cn$-closed $A, B$,
\[
  \mathrm{ex}(A \oplus B) \;=\; \max\nolimits_{\preceq}\bigl(\mathrm{ex}(A) \cup \mathrm{ex}(B)\bigr).
\]
\end{theorem}

\begin{proof}
Union-stability gives $A \oplus B = Cn(A \cup B) = A \cup B$, and acyclicity
(Corollary~\ref{cor:ourconvex}) makes $\preceq$ a partial order, so the down-set
generated by the union is generated by the $\preceq$-extremal elements of the
union of the generators.
\end{proof}

\begin{proposition}[Cost]\label{prop:excost}
Fix the down-set table of $\preceq$, an $|\El| \times |\El|$ bit matrix
independent of the arguments. On a unit-cost random-access machine with words of
at least $|\El|$ bits, $\mathrm{ex}(A \oplus B)$ is computed from
$\mathrm{ex}(A)$ and $\mathrm{ex}(B)$ in $O(k)$ word operations, where
$k = |\mathrm{ex}(A)| + |\mathrm{ex}(B)|$.
\end{proposition}

\begin{proof}
Let $U = \mathrm{ex}(A) \cup \mathrm{ex}(B)$, formed as a bitmask in $O(k)$
operations. Let $S$ be the bitwise disjunction of the strict down-sets of the
members of $U$, one word each, so $O(k)$ operations. An element $a \in U$ is
$\preceq$-maximal in $U$ exactly when $a \notin S$, since $a \in S$ holds iff
some $b \in U$ distinct from $a$ has $a$ strictly below it. The answer is
$U \setminus S$, one further word operation.
\end{proof}

Acyclicity is necessary, not decorative. On $x \rightleftarrows y$, $x \to z$,
$y \to z$ with $A = \{z\}$ and $B = \{x,y,z\}$ both closed, the left-hand side is
$\emptyset$ and the right-hand side $\{z\}$.

\begin{remark}
Theorem~\ref{thm:excomp} is a compositionality result of the kind sought in
\S\ref{sec:cfp}, obtained on canonical forms rather than on raw sets: the
canonical form of a composite is computable from the canonical forms of its
parts, at the cost of Proposition~\ref{prop:excost} and with no reference to
the rest of the vocabulary. It
holds on the definite fragment only. Adding disjunctive requirements destroys the
operator (\S\ref{sec:models}) and adding prohibitions destroys union-closure
(Corollary~\ref{cor:admnotlattice}); the price of leaving the fragment is exactly
the loss of this theorem.
\end{remark}

Anti-exchange and uniqueness of minimal generators are not independent
properties: by Theorem~\ref{thm:convex} a directed cycle breaks both
simultaneously. Neither requires measurement, the digraph condition being
decidable directly.

\begin{remark}[Distributivity]
Meet-distributivity is equivalent to convex geometry (\cite{edelman1980}, Thm.\ 3.3),
so the distributivity observed on this fragment is not an independent property.
A union-closed closure system is a sublattice of $(2^{\El}, \subseteq)$ and hence
distributive outright. The equivalence holds up to lattice isomorphism: a closure
system whose lattice is meet-distributive need not itself satisfy anti-exchange
unless it is standard, which here is again acyclicity.
\end{remark}

\begin{remark}[Honest scale]
$D$ has $15$ arcs on $58$ vertices. The poset is therefore very sparse: most
elements are $\preceq$-maximal and are their own canonical form, so
Corollary~\ref{cor:ex} is exact but weak on most inputs, and
Theorem~\ref{thm:excomp} reduces to near-union in the common case. The structure
is real; it is also thin, and its thinness is the same fact as the vacuity of the
positive theory recorded in \S\ref{sec:vacuity}.
\end{remark}

\section{Repair}

The prohibitions carry more structure than the requirements, and it is the
structure that answers the question a user actually asks: \emph{what is the
minimal change that restores admissibility?}

\begin{definition}[Clutter and blocker]
A \emph{clutter} on ground set $\El$ is an antichain $\mathcal{C} \subseteq 2^{\El}$.
Its \emph{blocker} $b(\mathcal{C})$ is the clutter of minimal sets meeting every
member of $\mathcal{C}$.
\end{definition}

\begin{remark}[Terminology]
In this tradition a \emph{transversal} meets each member exactly once; the object
we need is a \emph{cover}, meeting each member at least once. The distinction is
not cosmetic and the literature is not uniform about it.
\end{remark}

\begin{theorem}[Blocker duality \cite{isbell1958,edmondsfulkerson1970}]\label{thm:blocker}
$b(b(\mathcal{C})) = \mathcal{C}$.
\end{theorem}

\begin{corollary}[Minimal repair]
Let $X$ arm some prohibition. The minimal sets of elements whose removal restores
hazard-freedom are exactly the members of $b(\Haz)$ restricted to $X$.
\end{corollary}

\begin{proposition}[Addition and removal are one object]\label{prop:oneobject}
Minimal removals from a seed $S$ are given by the deletion minor
$b\bigl(\Haz \setminus (\El \setminus S)\bigr)$ and minimal forbidden additions by
the contraction minor $\Haz / S$. The two are exchanged by Seymour's identity
\[
  b(\mathcal{C} \setminus I / J) \;=\; b(\mathcal{C}) / I \setminus J .
\]
Hence a single computation answers both.
\end{proposition}

Theorem~\ref{thm:blocker} is evaluated purely combinatorially on the ground set:
it never evaluates $\emptyset$ and never iterates from $\bot$. It is therefore
\emph{immune} to Proposition~\ref{prop:collapse}, unlike every fixpoint framework
considered above. This is the first candidate structure that dodges the collapse
rather than being defeated by it.

\begin{measurement}[The prohibition table]\label{meas:clutter}
Of the $20$ recorded prohibition rows, exactly one --- $X2$ --- is a positive
element set and hence enforceable by membership. Nine name no element; several
are requirements written in negative form; one pair fails the antichain condition
by containment.
\end{measurement}

\begin{remark}
Theorem~\ref{thm:blocker} and Proposition~\ref{prop:oneobject} are classical and
give minimal repair for any clutter. With a single enforceable row the blocker is
the clutter of its singletons and the construction is trivial, so the machinery is
available but not yet exercised on a non-degenerate instance. Its value here is
that it is combinatorial on the ground set: it never evaluates $\emptyset$ and
never iterates from $\bot$, so Proposition~\ref{prop:collapse} does not apply to
it.
\end{remark}

\begin{measurement}[Accessibility fails]\label{meas:access}
$\Admf$ is not accessible: over four $16$-element ground sets ($4{,}580$ admissible
sets) there are $20$ admissible sets $X$ with no $e \in X$ such that
$X \setminus \{e\}$ is admissible. Minimal witness: $\{Ex, Op\}$ is admissible
while neither $\{Ex\}$ nor $\{Op\}$ is.
\end{measurement}

Admissible sets therefore cannot in general be built one element at a time, and
$\Admf$ is not an antimatroid --- independently of the failure of $\cup$-closure.
Accessibility on the admissible side cannot be used to corroborate anti-exchange
on the closure side.

\section{Machine-checked fragment}\label{sec:lean}

A fragment of the above is formalised in Lean~4 against mathlib. The
development builds with no \texttt{sorry} and no custom axioms, every
declaration depending only on \texttt{propext}, \texttt{Classical.choice} and
\texttt{Quot.sound}. Because a formalisation claim is worth exactly as much as
its statement, we say precisely which statements are formalised and which are
not.

\emph{Formalised.} The polarity classification of Lemma~\ref{lem:polarity};
union-closure of the model class of dual-Horn clauses and intersection-closure of
the model class of purely negative ones, which are the positive halves of
Theorem~\ref{thm:closure}; that a union-closed family with a top element is a
complete lattice, which is Corollary~\ref{cor:lattice}; the anti-exchange
characterisation of Theorem~\ref{thm:convex} and with it uniqueness of minimal
generators; and the algebraic identity of Theorem~\ref{thm:excomp}, as an
equality of finite sets.

\emph{Not formalised, and the gap matters in three places.} First,
Theorem~\ref{thm:excomp} also asserts that the composite is computable in time
linear in $|\mathrm{ex}(A)| + |\mathrm{ex}(B)|$; the Lean declaration is an
equality of finite sets and contains no algorithm, no cost model and no
complexity bound, so the linear-time half is unformalised. Second, the negative
halves of Theorem~\ref{thm:closure} are witnessed in Lean generically --- there
\emph{exist} dual-Horn and purely negative classes lacking the opposite closure
--- and not for our $\mathcal{R}$, $\mathcal{W}$ and $\mathcal{H}$, whose
failures are established by the explicit counterexamples given above rather than
in Lean. Third, the atlas itself is not formalised at all.

Lemma~\ref{lem:polarity} is in any case immediate from the Lean definition of a
dual-Horn clause, so its formal proof carries less weight than its statement
suggests.

\section{Applying the canonical form to the corpus}\label{sec:apply}

Corollary~\ref{cor:ex} assigns a canonical form to a \emph{closed} set. For an
arbitrary $X \subseteq \El$ put
\[
  \mathrm{can}(X) \;=\; \mathrm{ex}\bigl(Cn(X)\bigr),
\]
which agrees with $\mathrm{ex}$ on closed sets and is defined everywhere.
Computing $\mathrm{can}$ for the $72$ decomposed protocols yields statements
about named systems that the raw element sets do not support. Where a
decomposition is not $Cn$-closed --- as for the venues that omit a definite
consequence --- it is $\mathrm{can}$ and not $\mathrm{ex}$ that is being
reported.

\begin{measurement}\label{meas:compress}
The specialization poset has $15$ distinct arcs and $10$ non-maximal elements. Of
the $72$ protocols, $29$ have a strictly smaller canonical form.
\end{measurement}

\begin{measurement}[Derived solvency machinery in order-book venues]\label{meas:perps}
The perpetuals category contains seven protocols. For six of them --- Hyperliquid,
ApeX, Aster, Lighter, edgeX and GMX~v2 --- the canonical form omits exactly
$\{Ct, Ex, Li\}$: the collateral test, the price oracle and the incentivised
liquidator. Hyperliquid reduces from $14$ mechanisms to $11$ and GMX~v2 from $13$
to $10$. The two order-book options venues, Derive and Aevo, exhibit the same
signature.
\end{measurement}

\begin{measurement}[The exception, and why]\label{meas:jupiter}
The seventh, Jupiter Perpetual Exchange, drops nothing: its canonical form has
the same eight mechanisms as its element set. It is the only oracle-priced pool
venue in the category, carrying $Pm$ and no $Pf$, so no requirement arc reaches
$Ct$, $Ex$ or $Li$ and each is primitive in it.
\end{measurement}

\begin{remark}
The pair is more informative than a uniform claim would have been. Among venues
that match orders, the collateral test, the oracle and the liquidator are not
design choices but consequences, and six independent implementations agree to the
symbol. Among venues that price against a pool they are choices. The canonical
form separates the two microstructures without being told about either, which is
a distinction the raw element sets do not make.
\end{remark}

\begin{measurement}[The collateral test is never primitive in lending or collateralised debt]\label{meas:ct}
$Ct$ is absent from the canonical form of every lending and collateralised-debt
protocol in the corpus: Aave~v3 ($17 \to 16$), Morpho, SparkLend, JustLend,
Compound~v3, Sky, USDD, Lista, Liquity, crvUSD, Fluid, Steakhouse, Maple,
Rysk and Panoptic.
\end{measurement}

Together with Measurement~\ref{meas:perps} this identifies $Ct$ as the most
derived mechanism in the vocabulary wherever the requirement rows reach it: of
the $28$ corpus protocols carrying $Ct$ it is a consequence in $25$ and a
primitive in three --- Jupiter Perpetual Exchange, CIAN Yield Layer and Kalshi
--- each of which carries it without carrying anything that requires it. A
taxonomy that lists it beside genuinely independent mechanisms overstates its
status in the lending and collateralised-debt protocols of
Measurement~\ref{meas:ct}, where it is never primitive. In those three venues it
is a design choice, which is the more interesting case and the one a taxonomy
should not flatten.

\begin{measurement}[Canonical form does not resolve the fibres]\label{meas:fibres}
Passing to canonical forms neither merges nor separates any pair: the collision
classes on canonical forms are exactly those on full element sets --- USDT/USD1,
LiquidMesh/KyberSwap, Binance~Wallet/OKX~DEX, Jupiter/1inch.
\end{measurement}

The indistinguishability of USDT and USD1 is therefore not an artefact of
redundant mechanisms that a canonical form could remove. It survives compression,
which strengthens the claim that separating them requires enrichment of the
carrier rather than tidying of the vocabulary.

\begin{example}[Composition, worked]\label{ex:comp}
$\mathrm{ex}(\text{Aave~v3})$ has $16$ elements and
$\mathrm{ex}(\text{Uniswap~v3})$ has $7$; the canonical form of their composite is
the union of the two, with nothing dropped, since no generator of either lies
below a generator of the other. By Theorem~\ref{thm:excomp} the composite is
determined without consulting the remaining $38$ elements of the vocabulary.
\end{example}

\section{Which protocols compose}\label{sec:pairs}

We now ask the composability question of the sampled protocols rather than
of abstract sets.

\begin{measurement}[Which protocols compose]\label{meas:pairs}
Sixty-one of the $72$ protocols satisfy the requirements and warrants. Of the
$1{,}830$ unordered pairs among them, $1{,}645$ compose to an admissible set and
$185$ do not. Every failure arms a prohibition; requirements, warrants and
grounding contribute none. Of the failures, $182$ join protocols of different
categories and $3$ protocols of the same, those three being
$(\text{Uniswap}, \text{Fluid})$, $(\text{PancakeSwap}, \text{Fluid})$ and
$(\text{Spark Savings}, \text{CIAN})$. Twenty of the $61$ compose with every
other protocol in the corpus, and five categories contain no such member:
lending, collateralised-debt stablecoins, bridges, options and prediction
markets. Ranked by incompatible partners out of $60$, the extremes are Uniswap
and PancakeSwap at $31$ each and twenty protocols at none.
Table~\ref{tab:composition} gives the distribution by category.
\end{measurement}

\begin{remark}
The two measurements together locate composition risk by category rather than by
protocol. The categories with no universally safe member are those whose members
carry credit machinery --- pooled lending, collateralised debt --- which is one
half of the prohibition $X2$; any member is then one flash-liquidity partner away
from covering it. Intents and aggregation, at the other extreme, contributes six
of the twenty, its members being small element sets dominated by routing.
\end{remark}

\begin{remark}
Fluid accounts for two of the three, and for a structural reason that its
category does not otherwise exhibit: it is the only spot exchange in the corpus
whose collateral is simultaneously lending inventory, so it carries $Pl$ and $Cd$
alongside the pricing mechanisms. Composed with a conventional automated market
maker supplying $Cp$, $Cl$ and $Fl$, the union covers $X2$. Within-category
composition is safe in this corpus except where a protocol imports the machinery
of another category, which is precisely what makes Fluid unusual.
\end{remark}

\begin{example}[Uniswap composed with Aave]\label{ex:uniaave}
The pair $(\text{Uniswap}, \text{Aave~v3})$ fails, and additionally arms a
recorded hazard row --- one of only three such pairs in the corpus. Uniswap
contributes $\{Cp, Cl, Fl\}$ and Aave contributes $\{Pl, Cd, Fl\}$; their union
covers $\{Fl, Cp, Cl, Pl, Cd\}$, which is exactly the recorded prohibition $X2$.
Neither protocol covers it alone.
\end{example}

\begin{remark}
Example~\ref{ex:uniaave} is the sharpest statement the framework produces. The
condition it recovers --- atomic flash liquidity co-present with both an
automated market maker and a lending facility --- is the standing precondition
for flash-loan price manipulation, and the composite of the two largest protocols
in their respective categories is precisely where it first appears. Neither
protocol is defective; the pair is. This is what it means for a property to be
non-compositional, exhibited on named systems rather than argued in the abstract.
\end{remark}

\begin{remark}
The $90\%$ figure should not be read as reassurance. It is a statement about
pairs drawn uniformly, whereas deployed compositions are not uniform: the pairs
that actually occur in production are concentrated among the spot exchanges and
lending markets, which are exactly the protocols
Measurement~\ref{meas:pairs} ranks as most hostile.
\end{remark}

\begin{remark}[What the coverage figure is]\label{rem:coverage}
Coverage below means one thing only: the fraction of \emph{recorded obligation
rows} that some element discharges. The rows are authored, one per thing a lane
judged the application to do, and their granularity is a coding decision rather
than a property of the protocol. Splitting a row into a base mechanism and a
refinement changes both numerator and denominator while the protocol stands
still. The figure therefore supports no statement about how much of a protocol's
behaviour, code, capital or risk the vocabulary expresses, and comparisons
between two applications inherit the coding difference between two lanes.
\end{remark}

\begin{measurement}[The figure is robust to weighting and fragile to
adjudication]\label{meas:covsens}
Pooling all $1{,}259$ rows gives $45.3\%$; weighting each of the $60$
applications equally{,} and each of the $12$ categories equally{,} gives figures
within half a point of it. The spread is $0.6$ percentage points, although the
finest-coding lane recorded $1.73$ times the rows of the coarsest, so the
statistic is nearly insensitive to how many rows a lane chose to write.

It is not insensitive to what counts as discharged. Of the $570$
assigned rows, $205$ --- $36.0\%$ --- carry a note
marking the fit approximate, forced or partial. Counting those as residue gives
$29.0\%$, a swing of $16.3$ points.
\end{measurement}

\begin{remark}
The second figure is the one that bounds what may be claimed. The coding
granularity, which is the obvious objection, moves the number by less than a
point; the adjudication of borderline assignments, which is less obvious, moves
it by seventeen. Every coverage figure in this paper is the permissive reading,
in which an approximate fit counts as a fit, and $29.0\%$ is the strict one. We
report the permissive figure because the lanes' notes are not a uniform
instrument --- some lanes annotated every assignment and some only the doubtful
ones --- so the strict figure is itself a lower bound of unknown tightness.
Neither is a measurement of the subject; both are measurements of the ledger.
\end{remark}

\begin{measurement}[Resolution and coverage move together]\label{meas:rho}
For each of the twelve categories take the number of distinct elements its five
constructions use, and its coverage in the sense of
Remark~\ref{rem:coverage}. Over the twelve the Spearman rank correlation between
the two is $\rho = 0.874$. Coverage runs from $26.5\%$ on intents, which uses
ten distinct elements, to $59.1\%$ on perpetuals, which uses twenty-six.
\end{measurement}

\begin{remark}
The relationship the corpus reports informally --- that the vocabulary is finest
where many independent implementations exist and coarsest where the capital is
--- has two halves, and only one of them is measured here.
Measurement~\ref{meas:rho} establishes the first: where the vocabulary spends
more symbols it also covers more of what the applications do, so resolution and
coverage are not independent axes. The second half, the relation to capital, is
not measured. Capital enters this corpus only as a selection criterion and never
as a quantity, so any correlation we computed against it would be a correlation
against our own sampling rule. Selection was itself by capital or volume, so an observed association between
capital and coverage would in part report the sampling rule. We record only that
the three least covered categories are the wrapped-asset bridges, the
reserve-backed issuers and the order-flow aggregators.
\end{remark}

\section{Constructions}\label{sec:construct}

Everything above describes protocols that were decomposed. The question the
algebra should also answer is the constructive one: given a statement of what an
application does, can the vocabulary build something that does it? This section
fixes what that means, because the question is easy to ask loosely and the loose
version has no content.

\begin{definition}[Functional obligation]\label{def:obligation}
Let $P$ be an application. An \emph{obligation} for $P$ is a pair
$(o, S_{o})$ where $o$ is a statement of one thing $P$ does, checkable against a
cited source, and $S_{o} \subseteq \El$ is the set of elements any one of which
discharges it. We allow $S_{o} = \emptyset$, meaning that no element names $o$.
Write $\mathcal{O}$ for a finite set of obligations.
\end{definition}

\begin{remark}\label{rem:predicate}
$\Admf$ is computed from the $29$ recorded requirement rows under the parser of
\S\ref{sec:models}. A reduced system of $11$ rows over $10$ subjects is also
derivable from the same tables, and the two are not extensionally equivalent.
\end{remark}

The two differ on $675$ of the $65{,}536$ subsets of the universe of
Measurement~\ref{meas:nonunique}, and on the corpus the reduced system
admits four protocols the recorded rows reject. Every figure in this paper
is computed under the recorded rows.

\begin{definition}[Construction, coverage, residue]\label{def:construction}
A \emph{construction} for $\mathcal{O}$ is a set $X \subseteq \El$. It
\emph{covers} $(o,S_{o}) \in \mathcal{O}$ when $S_{o} \cap X \neq \emptyset$. The
\emph{residue} of $X$ on $\mathcal{O}$ is the set of obligations it does not
cover; obligations with $S_{o} = \emptyset$ lie in the residue of every
construction. $X$ is \emph{sound} when $X \in \Admf$.
\end{definition}

\begin{definition}[Justified, minimal]\label{def:minimal}
An element $e \in X$ is \emph{justified} when $e \in S_{o}$ for some obligation
$X$ covers. $X$ is \emph{minimal} for $\mathcal{O}$ when $X \in \Admf$, and for
every
$e \in X$ either $X \setminus \{e\}$ covers strictly fewer obligations or
$X \setminus \{e\} \notin \Admf$.
\end{definition}

The definition of minimality has to name both conditions, because neither is
implied by the other, and that is the substance of the next proposition.

\begin{proposition}[Soundness is inherited in neither direction]\label{prop:neither}
$\Admf$ is closed neither upward nor downward.
\end{proposition}

\begin{proof}
Upward: $\{Cp,Sh,Fl\} \in \Admf$ and $\{Cp,Sh,Fl,Pl\} \notin \Admf$, the latter
covering $X2$ and additionally leaving three requirement terms open. Downward:
$\{Aw,Xf,At\} \in \Admf$ and its subset $\{Aw,Xf\} \notin \Admf$, since removing
the attestation arms $X19^{*}$. The second witness uses a conditional
prohibition carrying a negative literal, of the kind in
Proposition~\ref{prop:mixed}. The listed clutter $\Haz$ is an antichain of
minimal forbidden sets and is therefore not itself downward closed --- a proper
subset of a listed row is in general not a listed row. What is downward closed
is its model class $\mathcal{H} = \mathcal{M}(\Haz)$, since a set containing no
forbidden set has no subset containing one.
\end{proof}

\begin{remark}
It forbids monotone greedy search without backtracking: neither adding elements
while soundness holds nor deleting them while soundness holds is a correct
strategy, because soundness is preserved in neither direction. It does not
forbid search. Enumeration by increasing cardinality with a fresh admissibility
test at each candidate finds a minimum-size sound cover of the obligation set of
Measurement~\ref{meas:nonunique} at size six, and backtracking or
deletion-with-recheck are equally available. What Proposition~\ref{prop:neither}
costs is the monotonicity a greedy algorithm would need, and that is why the
checker tests removal element by element rather than descending, and why a
construction is exhibited with a witness rather than derived by an algorithm we
could claim to be complete.
\end{remark}

The failure of downward closure is therefore attributable entirely to the
conditional prohibitions, and Proposition~\ref{prop:neither} depends on them.
This is the same division as Measurement~\ref{meas:whereitfails}: the recorded
clutter is nearly inert, and the conditional constraints do the work.

\begin{measurement}[Minimal constructions are not unique, exhaustively]\label{meas:nonunique}
Take the six obligations of a pooled lending market: a proportional claim
($\{Sh,Ix,Rb\}$), pooled rather than bilateral borrowing ($\{Pl\}$), a
collateral threshold ($\{Ct\}$), a price the threshold reads
($\{Ex,Tp,At\}$), a way an unhealthy position is closed or its loss absorbed
($\{Li,Ad,Sl,Bs\}$), and a way out for the depositor ($\{Wq,Rd,Im,Ps\}$). Over
all $65{,}536$ subsets of the $16$ declared alternatives, $3{,}930$ are sound
constructions covering all six obligations and exactly $60$ of those are
minimal. All $60$ have size $6$, and all $60$ have distinct canonical forms.
\end{measurement}

\begin{corollary}\label{cor:notthe}
A minimal construction is not unique in general: the instance of
Measurement~\ref{meas:nonunique} has $60$ over the declared universe. A
statement that the algebra reproduces an application must therefore exhibit a
particular construction and say why that one.
\end{corollary}

\begin{remark}[Two sources of choice, and the scope of the count]
The alternatives are not exhausted by the disjunctive terms. An element may be
carried because admissibility needs it while discharging no obligation, and
Definition~\ref{def:minimal} permits that, requiring only that removal lose
coverage or lose soundness. Admitting four such support elements to the universe
of Measurement~\ref{meas:nonunique} yields $60$ further minimal constructions
that use one, among them $\{Cp,Ct,Li,Pl,Sh,Tp,Wq\}$, where the constant-product
element discharges no obligation of a lending market and is present because the
price obligation is met by the time-weighted price, which requires it. The count
of $60$ is therefore exact over the sixteen declared alternatives and a lower
bound over $\El$. The corollary needs only non-uniqueness, which the restricted
count establishes; it does not claim that every application admits several
constructions, and \emph{application} is not a formal type here in which that
could be stated.
\end{remark}

\begin{remark}
$Ct$ occurs in all $60$ minimal constructions of
Measurement~\ref{meas:nonunique} --- it is forced, being the only element
discharging the threshold obligation --- and in none of their canonical forms.
Measurement~\ref{meas:ct} recorded that $Ct$ is absent from the canonical form
of every lending and collateralised-debt protocol in the corpus --- it is a
primitive in three protocols overall, none of them in those two categories --- and
the same holds on constructions that are not in the corpus, which is evidence
that the observation is a property of the requirement digraph rather than of the
sample.
\end{remark}

\begin{remark}[Method]\label{rem:checker}
Constructions are checked mechanically. The verification reports the four failure
modes separately --- open requirement terms, unwarranted elements, armed
prohibitions, grounding --- together with the canonical form, the covered and
uncovered obligations, elements carried that discharge no obligation, the
elements whose removal preserves both coverage and soundness, and any exact
decomposition $A \oplus B$ or $A \oplus B \oplus C$ over the $72$ corpus
protocols.  

Every figure in this paper is computed against the recorded $29$-row requirement
system. The repository also carries a reduced $11$-row table, $L^{*}$, and the
two are not interchangeable: they disagree on $387$ of the $30{,}856$ subsets
tested. Under $L^{*}$ the arcs $Op \to Ct$, $Pf \to Ex$ and $Pf \to Li$ are
absent, the agreement reported in Section~\ref{sec:apply} on $\{Ct, Ex, Li\}$
weakens to $\{Ct\}$, and $Ct$ becomes primitive in a fourth protocol. Where a
figure would change under $L^{*}$ it is a figure about the $29$-row system, and
this remark is the disclosure that it is.
\end{remark}

\begin{remark}[What a construction does not establish]
That a sound construction covers every stated obligation of an application is a
statement about the vocabulary, not about the application: it says the recorded
behaviour can be named and that naming it violates no recorded constraint. It
does not say the two systems behave alike, and nothing here is a verification
method. The interesting output is the residue, and
Measurement~\ref{meas:vacuous58} is the reason to expect it: a vocabulary whose
positive theory excludes nothing will not fail to cover an obligation by being
over-constrained. It will fail by having no name.
\end{remark}

\section*{The corpus by category}\label{sec:atlas}

The twelve sections that follow report the corpus one category at a time. The
categories are the sampling frame, not a construct of the algebra: they are
DefiLlama's and rwa.xyz's own tags, and protocols were selected within them by
live capital or volume. Nothing proved above depends on where the boundaries
fall. What the boundaries do determine is the cross-category composition
statistics of \S\ref{sec:pairs}, and that dependence is stated wherever it is
used.

Tables~\ref{tab:categories}, \ref{tab:footprints} and \ref{tab:composition}
give the twelve categories at a glance: what each discharges, which elements
it uses and which are peculiar to it, and how its members compose. Each
section then reports the category's \emph{footprint} --- which of the $58$
elements its members use, which it uses exclusively, and which every member
carries; how its members compose, with the prohibition that drives any failures
named; and what the constructions could not express.

Four applications are treated at length, each because a result depends on it:
Uniswap, which supplies the composition counterexample of
Example~\ref{ex:uniaave}; Rysk, whose obligations are discharged by construction
and which motivates the extension of \S\ref{sec:extend}; WBTC, on which the
party sort is exhibited; and Lido, whose category carries a candidate element
that no member of it uses. Profiles of all sixty, with their full residue
lists, are in the supplement.

\begin{table}[t]
\centering\small
\begin{tabular}{lrrrrr}
\toprule
category & elements & obligations & discharged & residue & inadmissible \\
\midrule
Spot exchange & 18 & 110 & 46 & 64 & 1 \\
Lending & 20 & 112 & 51 & 61 & 1 \\
Collateralised-debt stablecoins & 26 & 105 & 58 & 47 & 1 \\
Liquid staking & 20 & 108 & 60 & 48 & 0 \\
Perpetual futures & 26 & 115 & 68 & 47 & 1 \\
Yield vaults & 24 & 103 & 52 & 51 & 1 \\
Bridges & 11 & 89 & 25 & 64 & 3 \\
Intents and aggregation & 10 & 98 & 26 & 72 & 2 \\
Tokenised real-world assets & 24 & 106 & 49 & 57 & 1 \\
Options & 26 & 101 & 50 & 51 & 2 \\
Reserve-backed stablecoins & 13 & 114 & 42 & 72 & 0 \\
Prediction markets & 22 & 98 & 43 & 55 & 2 \\
\midrule
total & --- & 1259 & 570 & 689 & 15 \\
\bottomrule
\end{tabular}
\caption{The twelve categories. \emph{Elements} counts the distinct
elements the five constructions of the category use; \emph{obligations}
counts the recorded obligations of its five applications;
\emph{inadmissible} counts constructions that leave a requirement term
open or arm a prohibition. Coverage in the sense of
Remark~\ref{rem:coverage} runs from 26.5\% to 59.1\%.}
\label{tab:categories}
\end{table}

\begin{table}[t]\centering\small
\begin{tabular}{lrll}
\toprule
category & footprint & exclusive to it & in every member \\
\midrule
Spot exchange & 16 & $Cp,St$ & $Sh$ \\
Lending & 24 & --- & $Ct,Em,Ex,Gp,Ix,Li,Pl$ \\
CDP stablecoins & 25 & $As$ & --- \\
Liquid staking & 19 & $Rs$ & --- \\
Perpetual futures & 20 & $Ad,Pm$ & $Ct,Ex,Li,Sh$ \\
Yield vaults & 23 & $Py$ & $Ix$ \\
Bridges & 17 & $Of$ & $Xf$ \\
Intents & 8 & $Ba$ & $Ag$ \\
Real-world assets & 24 & --- & $Aw,Gp,Sh,Up$ \\
Options & 20 & $Op$ & $Gp,Op,Sh,Up$ \\
Reserve-backed stablecoins & 10 & --- & $At,Fz,Ps,Rd,Up$ \\
Prediction markets & 20 & $Au,Gs,Rl$ & --- \\
\bottomrule
\end{tabular}
\caption{Footprints. \emph{Footprint} is the number of distinct elements the
category's members use; \emph{exclusive} are those used by no member of any
other category; \emph{in every member} are those every member carries.}
\label{tab:footprints}
\end{table}

\begin{table}[t]\centering\small
\begin{tabular}{lrrrr}
\toprule
category & satisfying & incompatible partners & universal & within-category \\
\midrule
Spot exchange & 5/5 & 0--31 & 1 & 2 \\
Lending & 5/6 & 2--26 & 0 & 0 \\
CDP stablecoins & 6/6 & 2--7 & 0 & 0 \\
Liquid staking & 5/5 & 0--1 & 3 & 0 \\
Perpetual futures & 6/7 & 0--7 & 1 & 0 \\
Yield vaults & 7/8 & 0--23 & 5 & 1 \\
Bridges & 6/7 & 7--7 & 0 & 0 \\
Intents & 8/8 & 0--23 & 6 & 0 \\
Real-world assets & 4/5 & 0--7 & 1 & 0 \\
Options & 1/5 & 7--7 & 0 & 0 \\
Reserve-backed stablecoins & 5/5 & 0--7 & 3 & 0 \\
Prediction markets & 3/5 & 1--7 & 0 & 0 \\
\bottomrule
\end{tabular}
\caption{Composition. \emph{Satisfying} counts members meeting the requirements
and warrants, the others being excluded from the pairwise test;
\emph{incompatible partners} is the range over those members, out of the $60$
others; \emph{universal} counts members compatible with every other protocol;
\emph{within-category} counts failing pairs drawn from the category itself.}
\label{tab:composition}
\end{table}

\begin{measurement}[What the corpus exercises]\label{meas:cat:usage}
The $72$ decompositions use $54$ of the $58$ elements. Four are unused by every
protocol in every category: $Wg$ (weighted-geometric invariant), $Cv$ (mutual
cover pool), $Sb$ (shielded balance) and $Sd$ (selective disclosure). Two
elements are carried by more than two thirds of the corpus --- $Up$ ($49/72$,
eleven categories) and $Gp$ ($48/72$, eleven categories) --- and both are
control-plane rather than financial.
\end{measurement}

\begin{measurement}[Composition failure is concentrated in eight protocols]\label{meas:cat:eight}
Of the $61$ protocols satisfying requirements and warrants, seven carry $Fl$:
Uniswap, PancakeSwap, Aave~v3, Morpho, SparkLend, CIAN and CoW~Swap. Of the
$185$ failing pairs, $180$ have at least one such endpoint. The remaining $5$
all have Spark~Savings as an endpoint and all arm the same conditional
prohibition $X19^{*}$. Eight of $61$ protocols are therefore endpoints of every
composition failure in the corpus.
\end{measurement}

\begin{remark}
Measurement~\ref{meas:cat:eight} sharpens Measurement~\ref{meas:whereitfails}
from clause classes to named systems: $147$ of the failures arm $X21$
(atomic flash liquidity co-present with a cross-domain transfer, a resource lock
or an optimistic fill), $37$ arm $X2$, and $6$ arm $X19^{*}$. Since both $X21$
and $X2$ have $Fl$ in their antecedent, the concentration is a property of the
prohibition table and not a discovery about the protocols. It is reported here
because it is what makes the per-category composition figures below legible: in
almost every case the number of incompatible partners a protocol has is
determined by whether it, or the partner, carries one element.
\end{remark}

\begin{remark}[Reproducibility of the decompositions]\label{rem:cat:repro}
Two systems were decomposed twice under different category headings: Maple, as
a lending market and as private credit, and Steakhouse, as a yield vault and as
a risk curator. The two records of Maple agree on $11$ of the $18$ symbols in
their union and those of Steakhouse on $5$ of $10$. The scopes differ --- each
record was made of the products that fell under its heading --- so these figures
are not an inter-rater measurement and do not license one. \emph{Inter-rater
reliability for the decomposition is unknown.} Establishing it requires a
blinded overlap sample at fixed scope, which we have not performed, and every
per-application statement should be read subject to that.
\end{remark}

\begin{remark}[Encoding note]
Two decompositions, Curve and crvUSD, record the symbol $Ve$ (vote-escrow),
which belongs to the contested register and not to $\El$. The encoding drops it,
so both protocols are analysed one symbol short of what their lane recorded. No
other decomposition uses a symbol outside the $58$.
\end{remark}

\section{Spot exchange}\label{sec:cat:dex}

Five protocols, ranked by total value locked: Uniswap, PancakeSwap, Curve,
Raydium and Fluid. The category question is how to price and settle a swap
against passive inventory when no counterparty is on the other side.

\begin{measurement}[Composability is decided by one element]\label{meas:cat:dexcomp}
Incompatible partners out of $60$: Uniswap $31$, PancakeSwap $31$, Fluid $7$,
Raydium $3$, Curve $0$. Uniswap and PancakeSwap carry $Fl$ together with $Cp$
and $Cl$ and are the two most composition-hostile protocols in the corpus.
Raydium carries $Cp$ and $Cl$ but not $Fl$, and fails only against the three
lending markets that supply $Fl$ themselves. Curve carries neither $Fl$ nor
$Cp$ nor $Cl$, and is the category's only universally composable member.
\end{measurement}

\begin{remark}
Curve's immunity should not be read as a statement about stable-hybrid pools.
The prohibition $X2$ names $Cp$ and $Cl$ by symbol; $St$ and $Wg$ do not appear
in it, although a stable-hybrid pool is manipulable on the same argument. What
the measurement records is the trace of how the prohibition was written, and it
is a case where the element-level encoding of a hazard is narrower than the
hazard. This is a defect of the table, not a finding about Curve.
\end{remark}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 64 obligations that no element discharges. Three gaps span the category.
There is no element for a pluggable hook executing third-party code inside the
settlement path, which is what Uniswap~v4, PancakeSwap Infinity and Fluid each
build their differentiation on. There is no element for a value-return channel
that destroys supply rather than distributing it; $Fd$ names distribution to a
claim class, and three of the top four now route fees into a buy-and-burn.
And there is no element for a non-fungible per-range liquidity position: $Cl$
names the curve and $Sh$ names a pro-rata claim, and a $v3$ position is neither.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement. Uniswap is treated here, since a result depends on it.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\subsection{Uniswap}\label{case:dex:uniswap}

A liquidity provider deposits an ordered pair of tokens into a pool identified by that pair and a fee parameter. In v2 the claim is a fungible share of the whole reserve; in v3 and v4 it is a position bounded by a lower and an upper tick, so two providers in one pool holding different ranges hold economically different instruments. No counterparty quotes the swap --- the price is read off the constant-product invariant, applied to the reserves in v2 and to virtual reserves inside the active tick range thereafter, and the fee is skimmed from the input and left in the pool, so the marginal price moves monotonically against size. Settlement moves both tokens at each pool in v2 and v3; in v4 a singleton records signed deltas in transient storage across an unlocked scope and moves only the net, release being conditional on those deltas cancelling. A position ends when its owner burns it and collects principal and accrued fees; there is no maturity, no margin call and no liquidation, because no one is ever short.

\begin{measurement}\label{meas:case:dex:uniswap}
Take $X = \{Cl,Cp,Fl,Ix,Sh,Tg,Tp,Xf\}$, with canonical form
$\mathrm{ex}(X) = \{Cl,Cp,Fl,Ix,Sh,Tg,Tp,Xf\}$, every element being primitive in it.
It is not admissible: it arms $X21$. It discharges 10 of the 22 recorded obligations; 12 are residue. No composite of at most three corpus protocols equals it; no corpus protocol is contained in it.
\end{measurement}

\begin{remark}
What the vocabulary cannot state is most of what v4 is. A hook is not merely third-party code in the settlement path: it is a capability vector fixed at pool initialization and chosen by mining the hook's address, of which the delta-returning bits promote the hook from observer to pricer, and that promotion is the boundary between a v4 pool and an arbitrary market maker wearing a v4 interface. The category now differentiates on exactly this obligation and each protocol binds the permission set differently --- into the hook's address here, into the pool's own key at PancakeSwap, into a named controller at Fluid --- so a symbol for hooks would first have to decide whether the permissions belong to the code or to the pool. Deferred net settlement is unnamed for a separate reason: $Fl$ names borrow-and-repay in one scope, nothing is borrowed here, and the requirement that the accumulated deltas cancel at release is a conservation law over a transaction, which no symbol states. The registry deciding which curves may exist is monotone --- a tier may be added and never removed --- so it is a ratchet on the space of admissible pools rather than a parameter, and the construction discharges the pool arithmetic while missing nearly everything that separates this protocol from its own earlier generations.

The 13 obligations no element discharges are listed in the supplement.
\end{remark}

\begin{remark}
The element-set decomposition records the value-return channel as a buy-and-burn, and on the evidence it is neither a purchase nor a distribution, so $Fd$ is dropped and supply destruction is left as residue: Firepit.release takes a fixed quantity of UNI from a searcher, releases the jar's balance to that searcher's recipient, and sends the UNI to the burn address, and the protocol never places a market order of its own. $Tg$ is carried against the corpus's reading that the mechanism is beyond authority --- the v3 factory owner may add a fee tier and the v2 fee setter may switch the protocol fee on, both exercised in the single governance act that installed the fee machine --- so immutability holds of the code and not of the parameters. $Xf$ is carried because that same channel completes on another domain, the L2 jar releasing locally and queueing a withdrawal whose effect lands on the settlement chain after the challenge window. Carried with $Fl$ it arms $X21$, although the flash path lives inside a pool's settlement scope and the burn path on a bridge days later, and an element set has no way to say that the two never meet.
\end{remark}

\section{Lending}\label{sec:cat:lend}

Six protocols: Aave~v3, Morpho, SparkLend, JustLend~v1, Maple and Compound~v3.
The category question is how to lend to anonymous strangers against posted
collateral with no maturity and no recourse, and close them out before the
collateral is worth less than the debt.

\begin{measurement}[The vocabulary orders the category]\label{meas:cat:lendorder}
Two of the six have element sets that are proper subsets of Aave~v3's:
SparkLend and Compound~v3, each smaller by exactly five symbols; and JustLend~v1
is a proper subset of Maple, smaller by seven. Every one of the six has a
strictly smaller canonical form, and every one drops $Ct$, as
Measurement~\ref{meas:ct} records.
\end{measurement}

\begin{measurement}[One rejection, and its reason]\label{meas:cat:lendrej}
Maple is the one member the vocabulary rejects. It carries $Uc$, and the
requirement governing undercollateralised credit demands a first-loss layer
--- a staked backstop or a tranche waterfall. Maple's decomposition names
neither, so the term $\{Bs, Tr\}$ is open and the protocol is not admissible.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 61 obligations that no element discharges. The dominant one is the price of credit: no element
anywhere names a rate. The utilisation curve that all six run, and that is the
thing they compete on, has no symbol, so the mechanics of a loan are recorded in
detail and its price is not recorded at all. The second is the delegated
allocation mandate --- a curator choosing exposures for other people's deposits
under caps, a timelock and a performance fee. $Sv$ names discretion over a
\emph{loan}; a curator never touches a loan.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement, with their constructions, verdicts and residue.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\section{Collateralised-debt stablecoins}\label{sec:cat:cdp}

Six protocols: Sky, Ethena, USDD, Lista, Liquity and crvUSD. The category
question is how to issue a unit that holds a peg when its backing is volatile,
held by someone else, and can become worth less than the unit.

\begin{measurement}[Canonical form separates the outlier]\label{meas:cat:cdpex}
Five of the six have a strictly smaller canonical form and each drops exactly
$Ct$. The exception is Ethena, whose canonical form is its element set. Ethena
is the only member carrying no $Cd$: it is a hedged synthetic dollar rather than
a collateralised debt position, and the canonical form separates it from the
category it was filed under without being told the distinction.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 47 obligations that no element discharges.
Every member sets a rate to defend its peg --- a stability fee, a savings rate,
an automatic controller, a borrower-chosen rate. The stability register contains
$Rd$, $Ps$ and $As$: a redemption right, a par swap and a quantity adjustment.
It contains no price-of-credit instrument, and that is the instrument all of
them actually use. This is the same gap as in \S\ref{sec:cat:lend}, reached
independently by a different lane.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement. Lido is treated here, since a result depends on it.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\section{Liquid staking and restaking}\label{sec:cat:lsd}

Five protocols: Lido, Binance staked ETH, EigenLayer, ether.fi and Babylon. The
category question is how to turn a locked, slashable consensus position into a
transferable claim that someone else operates.

\begin{measurement}[Nothing is derived]\label{meas:cat:lsdex}
No member has a strictly smaller canonical form: for all five, every element is
$\preceq$-maximal and the protocol is its own minimal generator. The category is
entirely primitive under the definite fragment, which is true of only three of
the twelve.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 48 obligations that no element discharges. $Vl$ is
required by four of the five and adequate in none. In Lido it stands for at
least five separable mechanisms: key registration and vetting, stake allocation
across operator modules, deposit front-running defence, exit signalling, and
penalty attribution. In Binance staked ETH it is not usable at all, there being
no on-chain validator lifecycle to name behind a custodial receipt. In
EigenLayer and Babylon it is used for an operator and a finality provider, which
are not validators. One symbol asserting sameness across three trust models is
the category's largest single failure.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement. Lido is treated here, since a result depends on it.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\subsection{Lido}\label{case:lsd:lido}

A user sends ETH to the core pool and receives stETH, a share of a ledger whose balance is the pool's total ether apportioned across its shares; wstETH holds the share directly, for integrations that cannot tolerate a moving balance. Rewards and losses both arrive as a rebase, because a permissioned committee reports consensus-layer balances on a fixed frame and the ledger is recomputed from what it reports. The pooled ether is scheduled across a registry of staking modules, each a different operator set under a different trust model, and only the permissionless module requires its operators to post a bond. Exit has a user side and a validator side that do not meet: the holder burns stETH into a queue and holds an NFT until a batch is finalised at a rate fixed then, while the protocol must separately signal beacon-chain exits and, where an operator does not comply, force them. A penalty or a slashing is absorbed as a negative rebase across the entire supply, irrespective of which operator caused it, and the bonded module runs its own attributed loss regime alongside.

\begin{measurement}\label{meas:case:lsd:lido}
Take $X = \{Aw,Bs,Cd,Ct,Ep,Ex,Fd,Gp,Ix,Rb,Rd,Sh,Sl,Tg,Up,Wq\}$, with canonical form
$\mathrm{ex}(X) = \{Aw,Bs,Cd,Ep,Ex,Fd,Gp,Ix,Rb,Rd,Sh,Sl,Tg,Up,Wq\}$; the elements \{Ct\} are derived rather than chosen.
It is admissible: no requirement term is open, every element is warranted, and it arms no prohibition. It discharges 16 of the 24 recorded obligations; 8 are residue. No composite of at most three corpus protocols equals it; 2 corpus protocols are contained in it, and together they supply every element except \{Bs,Cd,Ep,Ex,Fd,Gp,Rb,Sl,Tg,Wq\}.
It is not minimal: \{Ix,Cd,Ep,Wq,Sl,Tg,Up,Gp\} can be removed with every obligation still covered and admissibility intact.
\end{measurement}

\begin{remark}
Everything between the ether arriving and the ether returning is residue. The protocol admits operators under mutually incompatible regimes over a single share ledger and a single loss pool, schedules principal across them, defends its own deposit path against its own operators by structurally unrelated devices --- a guardian signature quorum in the core pool, a credential proof against a beacon block root with a forfeitable bond in the vaults --- signals exits over a bus whose enforcement is a social norm, and now resizes, tops up and merges live validators. That last mechanism is \emph{neither entry nor exit}, which is the demonstration in miniature: the candidate symbol for this category has nowhere to put it, and nowhere to put the rest either. What the construction does say is the accounting: a share ledger, an index, a queue, a fee, a governance delay. What it cannot say is the staking.

The 9 obligations no element discharges are listed in the supplement.
\end{remark}

\begin{remark}
$Vl$ is not used: it names the category rather than any mechanism, and this protocol keeps operator admission, stake scheduling, deposit defence, exit signalling and penalty attribution in separate contracts under separate failure modes, so one symbol laid over all of them would assert a sameness the code refutes. The element-set decomposition's fee marker does not hold --- the protocol's own fee page and its operator portal state a split that differs per module, so a single global split is not a fact about Lido --- and the construction adds a permission element the record omits, because the curated and the distributed-validator modules both admit operators by approval, and adds the collateralised-debt pair, because the vault product reached mainnet after the record was written and mints the pool token as a liability against an isolated validator set. Incentivised liquidation is deliberately not claimed for the permissionless force-rebalance: the design document states the power and states no payment to whoever exercises it, and asserting the element would be exactly the forced fit this stage exists to catch. Among the alternatives the loss-absorption term leaves open, the witness carries both socialised rebase and a posted bond, because the protocol runs both regimes at once and either alone misdescribes part of the stake.
\end{remark}

\section{Perpetual futures}\label{sec:cat:perp}

Seven protocols: Hyperliquid, ApeX, Aster, Lighter, edgeX, Jupiter Perpetual
Exchange and GMX~v2. The category question is where the price comes from, who
the counterparty is, and what happens to a position that can no longer pay.

The canonical-form behaviour of this category is
Measurement~\ref{meas:perps} and Measurement~\ref{meas:jupiter}, and is not
restated here. Two further facts belong to the category rather than to the
theorem.

\begin{measurement}[The rejection]\label{meas:cat:perprej}
Aster is the one member the vocabulary rejects, and the reason is specific: it
carries $Pf$, and the requirement governing perpetual funding demands a
loss-absorption mechanism from $\{Ad, Sl, Bs\}$. Aster's decomposition names
none of the three. Every other venue in the category names at least one.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 47 obligations that no element discharges. The vocabulary resolves one axis of venue design and
is blind to two. It separates book venues from pool venues cleanly. It cannot
see where the book lives or who is trusted to run it: an in-consensus book, two
operator-run books and a proven sequencer book all emit $Ob$, and these are
different trust models with different failure modes. And it cannot see the
tether itself: $Pf$ presumes a long/short funding transfer, which the
oracle-priced venue does not have at all --- it charges a utilisation borrow fee
--- and which the pool venue supplements with a mechanism $Pf$ does not name.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement, with their constructions, verdicts and residue.

Each
subsection states what the venue does, exhibits one construction with the reason
for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verification verdict, and lists the
obligations no element discharges. Every figure in the measurement environments
is emitted from the verification output rather than transcribed.

\section{Yield vaults and aggregators}\label{sec:cat:yield}

Eight protocols: Pendle, Spark~Savings, Convex, CIAN, Huma, Yearn, Beefy and
Steakhouse. The category question is how to repackage a yield-bearing position
that already exists somewhere else, and who decides where the capital goes.

\begin{measurement}[The rejection is the largest member]\label{meas:cat:yieldrej}
Steakhouse, the largest protocol in the category by capital, is the one member
the vocabulary rejects: it carries $Im$ and $Ct$ with no element from
$\{Li, Ad, Sl, Bs\}$, so the loss-absorption term of the governing requirement
is open. The rejection is correct on the letter of the table and uninformative
about the system, whose distinguishing feature --- a named party with
discretionary authority over other people's deposits --- has no symbol at all.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 51 obligations that no element discharges. A strategy --- borrow this
against that up to a target ratio, unwind above it, harvest weekly --- is a
policy expressed over other protocols' mechanisms. It has no on-chain mechanism
of its own. Because the model has elements and protocols and nothing above them,
Yearn, Beefy and CIAN reduce to two claim symbols and control-plane furniture,
and Beefy's element set is a proper subset of all three of the others. Adding
strategy as an element would be the wrong repair; the carrier needs a third
level.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement, with their constructions, verdicts and residue.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\section{Bridges}\label{sec:cat:bridge}

Seven protocols: WBTC, LayerZero~v2, Coinbase Bridge, Hyperliquid Bridge,
Binance BTCB, Circle CCTP and Across. The category question is what exactly has
to be trusted for a claim in one domain to remain equal to a claim in another.

\begin{measurement}[The three largest bridges verify nothing]\label{meas:cat:bridgetop}
WBTC, Coinbase Bridge and Binance BTCB decompose to $\{At,Aw,Gp,Rd,Tg,Xf\}$,
$\{At,Aw,Gp,Rd,Up,Xf\}$ and $\{At,Aw,Gp,Rd,Xf\}$. The third is a proper subset
of each of the first two, which differ from each other in exactly one
control-plane symbol. None of the three contains $Xm$, or any truth element
other than an attestation. The decomposition is correct: there is nothing to
verify, because a company holds the asset.
\end{measurement}

\begin{remark}
The lane recorded these three as an identical decomposition. Against the arrays
they are not identical but nested, and the distinction matters for
Measurement~\ref{meas:fibres}: containment is the relation that holds, and it is
the relation the collision analysis uses.
\end{remark}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 61 obligations that no element discharges. The $Xm$/$Xf$/$Of$ split is too coarse by roughly a
factor of four: $Xf$ conflates custodial wrap, lock-and-mint escrow,
burn-and-mint canonical issuance and liquidity-network fill with no
representation at all; $Xm$ conflates single-company attestation,
application-configured verifier sets, endogenous consensus and proof
verification. These are the distinctions that determine what a holder is
exposed to, and the vocabulary does not make them.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement. WBTC is treated here, since a result depends on it.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\subsection{WBTC}\label{case:bri:wbtc}

A holder sends bitcoin to a deposit address the custodian controls and receives an ERC-20 on Ethereum. The mint is not the holder's transaction: a permissioned merchant performs the identity check and submits the request, and the custodian's confirmation is the bridge --- nothing on Ethereum observes the Bitcoin chain. Redemption is the merchants' right and not the holder's, so an ordinary holder has no contract-enforced path back to bitcoin and exits by selling into a secondary market. What is trusted is that a custodian whose key material is split across several jurisdictions holds the bitcoin unencumbered, and that the multisig quorums owning the mint authority --- which execute the instant they are reached --- do not point it somewhere else.

\begin{measurement}\label{meas:case:bri:wbtc}
Take $X = \{Aw,Gp,Rd,Xf\}$, with canonical form
$\mathrm{ex}(X) = \{Aw,Gp,Rd,Xf\}$, every element being primitive in it.
It is not admissible: it arms $X19*$. It discharges 4 of the 19 recorded obligations; 15 are residue. No composite of at most three corpus protocols equals it; no corpus protocol is contained in it.
\end{measurement}

\begin{remark}
Everything that makes the peg hold is in this list. That a company holds the bitcoin, that a permissioned intermediary stands between the holder and the mint, that the reserve is an address listing the issuer publishes and third parties consume as ground truth, and that the contract authorising issuance can be swapped for another without touching a line of the token --- none of it has a symbol. The item that ought to be a guarantee reads as an omission: this token cannot freeze or seize a holder's balance, and the requirement language can record that only by declining to name an element, which is the same string a decomposition produces when nobody looked. The elements describe the facility; the residue holds the whole question of who operates it.

The 16 obligations no element discharges are listed in the supplement.
\end{remark}

\begin{remark}
The corpus separates this issuer from the other custodial wrappers by a timelock, and the witness drops it: all three governing contracts are plain Consensys multisig wallets, none exposes a delay accessor, and execution follows immediately on quorum. The corpus freeze marker goes with it, because the blacklist accessors revert and the token's inheritance list carries no such power. What actually distinguishes this system is quorum rather than delay, and the vocabulary has an element for delayed execution and none for authority that is shared but immediate, so the witness carries the permission registry, the pause and the reserve listing it can evidence and nothing more.
\end{remark}

\section{Intents and aggregation}\label{sec:cat:intent}

Eight protocols: LiquidMesh, Binance Wallet, OKX~DEX, Jupiter, KyberSwap,
DFlow, 1inch and CoW~Swap. The category question is who competes for the right
to fill an order the user did not route.

\begin{measurement}[Three of the corpus's four collisions live here]\label{meas:cat:intentcoll}
LiquidMesh $\equiv$ KyberSwap $= \{Ag\}$, Binance~Wallet $\equiv$ OKX~DEX
$= \{Ag,Rf\}$, and Jupiter $\equiv$ 1inch $= \{Ag,In,Rf\}$. Three of the four
collision classes of Measurement~\ref{meas:fibres} are inside this one
category, and $22$ ordered containment pairs hold among its eight members.
\end{measurement}

\begin{remark}
The pattern of Measurement~\ref{meas:pairs} is visible in one category:
small element sets dominated by routing compose with everything, because they
supply no antecedent to any prohibition. This is a statement about how little
the vocabulary records of them, not about how safe they are.
\end{remark}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 72 obligations that no element discharges. The four execution symbols do separate the protocols
that use them, so the category is not over-resolved. The failure runs the other
way: the vocabulary spends four symbols on \emph{how} an order is matched and
none on \emph{who owns the order and how the right to fill it is sold}. Three of
the top five by volume are order-flow owners whose entire economic position
reduces to $Ag$.
\end{remark}

The five highest-ranked members by volume are profiled in the supplement.
This is the category where the vocabulary says least. Two of them decompose, in the corpus,
to a single element. The subsections test whether that thinness is a fact about
the systems or a failure of the vocabulary, and the answer is visible in the
residue: what these systems compete on --- who owns the order, who is allowed to
fill it, and against what benchmark the price is called good --- is stated as
obligations in all five and discharged by no element in any of them. Each
subsection exhibits one construction with the reason for that witness among the
alternatives the disjunctive terms leave open (Corollary~\ref{cor:notthe}).

\section{Tokenised real-world assets}\label{sec:cat:rwa}

Five protocols: Ondo, Circle USYC, BlackRock BUIDL, Maple and Centrifuge. The
category question is who the obligor is, where the register of record is, who
determines value, and who can force a transfer.

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 57 obligations that no element discharges. The original decomposition recorded the
highest residue density in the corpus here, seven findings per protocol; and the recurring holes are structural rather than incidental: no
obligor, so nothing names who owes the money or what recourse exists; no
register of record, so nothing distinguishes a bearer instrument from a receipt
mirroring a transfer agent's book; no claim perfection or bankruptcy remoteness,
so $Tr$ names a waterfall without naming what it attaches to; no reserve
composition, $At$ naming the attestation and not the assets; and no investment
discretion. The vocabulary can express the wrapper and none of the wrapped.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement, with their constructions, verdicts and residue.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\section{Options and structured products}\label{sec:cat:opt}

Five protocols: Derive, Rysk, Hegic, Aevo and Panoptic. The category question is
who prices a non-linear payoff, who underwrites it, what collateral secures it,
and how the terminal payoff is determined.

\begin{measurement}[The vocabulary rejects four of the five]\label{meas:cat:optrej}
Only Derive satisfies requirements and warrants. The other four fail on terms of
the requirements governing $Op$ and $Pf$: Rysk and Hegic leave the
loss-absorption term $\{Li,Ad,Sl,Bs\}$ open, Hegic additionally leaving $Ct$
open; Aevo leaves $\{Ad,Sl,Bs\}$ open; and Panoptic leaves the price-source
term $\{Ex,Tp,At\}$ open. This is the worst rejection rate of the twelve
categories.
\end{measurement}

\begin{remark}[A qualification]
Options appears in Measurement~\ref{meas:pairs} as a category with no
universally composable member. For this category the statement is weaker than it
looks: four of its five members never entered the pairwise test, having been
rejected before it. The one member that did, Derive, has $7$ incompatible
partners. The same qualification applies to prediction markets, where two of
five were rejected. Where a category's rejection rate is high, its composition
statistics are computed on a remnant, and should be read as such.
\end{remark}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 51 obligations that no element discharges. $Op$ collapses
at least six distinctions that change the risk materially --- exercise style,
settlement in cash or in kind, peer-to-peer against peer-to-pool underwriting,
upfront against streamed premium, isolated against portfolio margin, and
model-priced against book-priced. Downstream of that the category has three
whole missing mechanisms, of which a pricing model and a volatility surface are
the largest.
\end{remark}

The five venues of the category are profiled in the supplement. Rysk is
treated here, since the extension of \S\ref{sec:extend} turns on it. Two of the four rejections
recorded above turn out to be artefacts of the corpus decomposition and vanish
once the record is corrected; two survive, and they are exactly the venues that
escrow the maximum payoff at trade time, whose obligations are therefore closed
by construction rather than left unspecified. Each subsection exhibits one
construction with the reason for that witness among the alternatives the
disjunctive terms leave open (Corollary~\ref{cor:notthe}). Every figure in the
measurement environments is emitted from the verification output.

\subsection{Rysk}\label{case:opt:rysk}

A venue where the writer escrows the maximum loss at the moment of trade. There is no margin call because there is no margin: the worst case is already held, and settlement can only pay out of it.

\begin{measurement}\label{meas:case:opt:rysk}
Take $X = \{At,Ep,Ex,Gp,Op,Rf,Sh,Sv,Up,Wq\}$, with canonical form
$\mathrm{ex}(X) = \{At,Ep,Ex,Gp,Op,Rf,Sh,Sv,Up,Wq\}$, every element being primitive in it.
It is not admissible: it leaves the requirement terms $L1\!:\!Ct$, $L1\!:\!Li{\mid}Ad{\mid}Sl{\mid}Bs$ open. It discharges 8 of the 20 recorded obligations; 12 are residue. No composite of at most three corpus protocols equals it; 1 corpus protocol is contained in it, and together they supply every element except \{At,Ct,Ep,Rf,Sv,Wq\}.
\end{measurement}

\begin{remark}
This is the sharpest case in the paper of a requirement discharged \emph{by construction}. The requirement language admits one way to satisfy a term --- name an element that discharges it --- so it reads an obligation that cannot arise as an obligation left unspecified. The rejection is correct about the tables and wrong about the protocol, and the repair is to the constraint language rather than to the vocabulary.

The 13 obligations no element discharges are listed in the supplement.
\end{remark}

\begin{remark}
The witness deliberately carries no collateral test and no backstop, and the construction is rejected for exactly that. This is not a defect in the witness. Escrowing the maximum payoff makes the obligations those elements would discharge unable to arise, and the honest decomposition records that as residue rather than fitting a symbol to a mechanism the venue does not have.
\end{remark}

\section{Reserve-backed stablecoins}\label{sec:cat:fiat}

Five issuers: Tether USDT, Circle USDC, USD1, USDG and PYUSD. The category
question is how a token stays at a dollar when what makes it worth a dollar is a
bank account and a legal promise.

\begin{measurement}[Footprint]\label{meas:cat:fiatfoot}
The category uses $10$ elements, none exclusively. Five are present in all five
members: $At$, $Fz$, $Ps$, $Rd$, $Up$. Every element in the footprint comes from
the truth, incentive, control, cross-domain, stability or access groups. The
category uses \emph{no} element of accounting, pool pricing, execution,
liquidity catalysis, credit, solvency or risk transfer. Element sets run from
$5$ to $9$ symbols.
\end{measurement}

\begin{measurement}[The identity that survives]\label{meas:cat:fiatid}
USDT and USD1 decompose to the identical set $\{At,Fz,Ps,Rd,Up\}$, and PYUSD is
a proper subset of USDC. The USDT/USD1 collision is one of the four in
Measurement~\ref{meas:fibres} and, as recorded there, it survives passage to
canonical forms.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 72 obligations that no element discharges.
USDT reduces to five symbols, and every symbol any member of this category uses
is control-plane or attestation rather than mechanism. What determines whether
the token is worth a dollar --- what the reserve holds, who custodies it, which
banks hold the cash, who the obligor is, whether redemption is available to the
holder, and which regulator can order the issuer to stop --- is outside the
model in its entirety. This is the sharpest instance of the general finding: the
vocabulary's resolution is inversely correlated with capital, being finest where
many independent codebases happen to exist and coarsest where the money is.
\end{remark}

The five issuers are profiled in the supplement. The evidence establishes
the redemption terms, the supervisory regimes and the holders of the freeze
keys, and it qualifies Table~\ref{tab:footprints} rather than confirming it:
under corrected constructions these issuers do carry elements outside the
control and attestation groups, so the strong form of the claim fails. What
survives is checked issuer by issuer: the model records who may freeze the
token, and for none of the five who holds the money.

\section{Prediction markets}\label{sec:cat:pred}

Five protocols: Kalshi, Polymarket, Azuro, Steakhouse Risk Curators and Grove.
The category is the residual of the sampling frame --- prediction markets
together with two large protocols its lane could not file elsewhere --- and its
question is how to price and settle a claim on a fact rather than on a price.

\begin{measurement}[The only warrant failure in the corpus]\label{meas:cat:predrej}
Two members are rejected. Steakhouse Risk Curators leaves two terms of the
governing requirement open. Azuro carries $Rl$ with no $Au$, which leaves a
requirement term open \emph{and} makes $Rl$ unwarranted --- no element present
consumes it. Of the eleven protocols the vocabulary rejects, ten fail on a
requirement alone; Azuro is the only one that additionally carries an element
with no consumer.
\end{measurement}

\begin{remark}[What the vocabulary cannot see here]
The five constructions leave 55 obligations that no element discharges. $Py$ splits a claim along time; nothing
splits one along state. The second is a central counterparty: the vocabulary
contains three symbols that are reconstructions of a clearinghouse default
waterfall and none for the institution being reconstructed, which is what the
largest venue in the category is.
\end{remark}

\begin{remark}[Reading the twelve together]
Three patterns hold across the categories rather than within any one. The footprint is smallest in intents, at $8$ elements, in the reserve-backed
stablecoins at $10$, and in bridges at a mean of $5.6$ symbols per protocol, and
largest where many independent implementations exist. The
element that decides composability is almost never the element that defines the
category: no member of the perpetuals footprint participates in a failure, and
membership of the seven-protocol $Fl$ set does. And the categories the
vocabulary rejects most often --- options at four of five, prediction at two of
five --- are the ones whose members hold risk that the requirement tables
insist must be absorbed by a named mechanism, which those protocols carry
off-chain or not at all.
\end{remark}

The five highest-ranked members of the category are profiled in the
supplement, with their constructions, verdicts and residue.

Each
subsection states what the system does, exhibits one construction with the
reason for that witness among the alternatives the disjunctive terms leave open
(Corollary~\ref{cor:notthe}), reports the verdict, and lists the obligations no
element discharges. Every figure in the measurement environments is emitted from
the verification output rather than transcribed.

\section{The composable fragment problem}\label{sec:cfp}

Theorem~\ref{thm:noncong} says $\Admf$ is not closed under $\oplus$. The useful
question is how much of it is. We state that precisely, because the precise form
turns out to be a named problem rather than a vague one.

\begin{definition}[Safe and closed fragments]
Let $F \subseteq \Admf$. Call $F$
\begin{itemize}
  \item \emph{$\oplus$-safe} if $A, B \in F \implies A \oplus B \in \Admf$;
  \item \emph{$\oplus$-closed} if $A, B \in F \implies A \oplus B \in F$.
\end{itemize}
Every $\oplus$-closed set is $\oplus$-safe; the converse fails, since a composite
may be admissible without lying in $F$.
\end{definition}

\begin{remark}
The distinction is operational. $\oplus$-safety is what an integrator needs:
\emph{if I compose two protocols from this family, is the result sound?}
$\oplus$-closure is what an algebraist needs: a subalgebra. Our measured fragment
(Conjecture~\ref{conj:frag}) is a join-semilattice and hence $\oplus$-closed,
but the certification figure reports $\oplus$-safety.
\end{remark}

\begin{definition}[Compatibility graph]
Let $G_\oplus$ be the simple graph with vertex set $\Admf$ and, for
$A \neq B$,
\[
  A \sim B \quad\Longleftrightarrow\quad A \oplus B \in \Admf .
\]
The relation is defined on distinct vertices, so the graph has no loops. Nothing
is lost by that: $A \oplus A = Cn(A) = A$ for $Cn$-closed $A$, so every vertex
would be self-compatible and the diagonal carries no information.
\end{definition}

\begin{proposition}[Reformulation]\label{prop:clique}
$F \subseteq \Admf$ is $\oplus$-safe if and only if $F$ is a clique in
$G_\oplus$. Consequently the largest $\oplus$-safe fragment has size
$\omega(G_\oplus)$, the clique number of the compatibility graph.
\end{proposition}

\begin{proof}
$\oplus$-safety asserts compatibility of every pair of distinct members of $F$,
which is the clique condition; the diagonal is immediate from $A \oplus A = A$.
\end{proof}

\begin{corollary}[Safe families need not have a unique maximum]\label{cor:nomax}
The family of $\oplus$-safe sets is closed downward but not under union: if
$A \in F_1$ and $B \in F_2$ with $A \not\sim B$, then $F_1 \cup F_2$ is not
$\oplus$-safe. Three notions must therefore be kept apart: a \emph{maximal} safe
family, which no superset extends; a \emph{maximum-cardinality} one; and a
\emph{unique} maximum. Failure of union-closure shows that maximal families need
not be unique. It leaves open whether the maximum-cardinality family is unique,
and ``the largest composable fragment'' is to be read as maximum-cardinality
throughout.
\end{corollary}

\begin{remark}[Consequences of Proposition~\ref{prop:clique}]
Three follow immediately, and together they change the status of the problem.

\emph{(i) Hardness, as a reformulation and not as a bound.} Maximum clique is
NP-hard in general. We have not shown that the compatibility graphs arising here
realise a hard class, and without such a reduction the general result bounds
nothing about this instance. What Proposition~\ref{prop:clique} does supply is
the reason Conjecture~\ref{conj:frag} reports an interval: those are clique
bounds, a witnessed lower bound and a structural upper bound, not an unfinished
computation.

\emph{(ii) The right question is structural, not extremal.} Maximum clique is
tractable on perfect graphs, chordal graphs and comparability graphs. So the
productive question is not ``what is $\omega(G_\oplus)$'' but:
\begin{quote}
  \textbf{Does $G_\oplus$ belong to a class on which clique is tractable, and if
  so, why --- what is it about requirement/prohibition systems that makes
  compatibility perfect?}
\end{quote}
That question is decidable for our instance and, unlike the extremal one, has an
answer that would transfer to other constraint systems.

\emph{(iii) A fragment and a graph are different objects.} The edge density of
$G_\oplus$ restricted to the corpus is $90.3\%$. That is a property of the graph
and not a certification rate for any fragment; Conjecture~\ref{conj:frag}
asserts no rate.
\end{remark}

\begin{proposition}[Compatibility is trace-determined on the listed rows]\label{prop:trace}
Let $G^{0}$ be the compatibility graph of $\oplus$ on $\Adm$. Since
$\mathcal{R} \cap \mathcal{W}$ is union-closed (Corollary~\ref{cor:lattice}),
$A \oplus B$ can leave $\Adm$ only through a listed prohibition covered by
$A \cup B$ and by neither alone. Compatibility in $G^{0}$ therefore depends only
on the traces $\{H \cap A\}_{H \in \Haz}$, and $G^{0}$ is a blow-up of the
induced quotient.
\end{proposition}

\begin{remark}\label{rem:tracelimit}
The proposition does not extend to $G_\oplus$, whose vertex set is $\Admf$. A
conditional prohibition may fire on a set that covers no listed row, so the
traces of $\Haz$ do not determine adjacency there; and by
Measurement~\ref{meas:whereitfails} the conditional rows account for every
observed failure. Any argument about $G_\oplus$ by way of the quotient must
first exhibit a quotient for the full predicate and show that it preserves
adjacency, which we have not done.
\end{remark}

\begin{measurement}
Over $4{,}000$ sampled members of $\mathcal{R} \cap \mathcal{W}$ there are $9$
distinct traces of the listed rows and no inconsistency in $1{,}936$ checks. The
quotient on those traces is complete, so perfection holds trivially on this
sample: with one enforceable listed row of five elements, no union of sampled
protocols covers it. The sample therefore supports the conjecture only in the
degenerate case, and the interesting case is the one the sample does not
reach.
\end{measurement}

\begin{conjecture}\label{conj:perfect}
$G^{0}$ is a perfect graph.
\end{conjecture}

\begin{remark}
The conjecture is falsifiable by exhibiting an odd hole or odd antihole. Direct
search is infeasible, $|\Adm|$ being of order $10^{16}$, but by
Proposition~\ref{prop:trace} $G^{0}$ is a blow-up of a quotient on the trace
space and perfection may be decided there, blow-ups of perfect graphs being
perfect \cite{lovasz1972}. Were it settled affirmatively, the maximum
$\oplus$-safe subfamily of $\Adm$ would be computable in polynomial time
\cite{gls1981}. It would say nothing about $G_\oplus$, for the reason given in
Remark~\ref{rem:tracelimit}. We have not tested it.
\end{remark}

\section{What the residue asks for, and what each repair costs}\label{sec:extend}

The sixty constructions leave $689$ obligations that no element discharges.
Taken one at a time these are a list of complaints; grouped, they are a small
number of requests, and each request has a price against the results above.

The grouping below was performed on the $385$ residue obligations available when
it was made, which are those of the first seven categories to complete: spot
exchange, perpetuals, yield, bridges, intents, options and prediction. The
remaining $304$ are not classified here: the $285$ of lending,
collateralised-debt stablecoins, liquid staking, real-world assets and
reserve-backed stablecoins, together with the $19$ that the first seven have
accumulated since the grouping was made --- those categories now hold $404$.
Every proportion in this section is therefore of the $385$, and every group size
is a count within them. The categories that arrived later
supply further instances of the groups named below --- the bounded mandate in
lending and in the rate instruments of the collateralised-debt issuers, the
party sort in the custody arrangements of the real-world assets and in the
shared freeze key of the reserve-backed issuers --- so the counts are lower
bounds on the full residue and the ranking is not established over it.

This section states the three repairs we would act on and the reason for
declining the largest. The classification and the costings are recorded in full
in the development; what follows is the part that bears on the algebra.

\begin{definition}[Kinds of repair]\label{def:repairkind}
A residue group admits a repair of exactly one of four kinds:
\emph{(a)} a new \textbf{element}, where a mechanism exists and no symbol names
it; \emph{(b)} a new \textbf{constraint form}, where the mechanism can be named
but the clause language cannot state the relation; \emph{(c)} a new \textbf{sort}
in the carrier, where the object is not a mechanism at all; and \emph{(d)} a new
\textbf{level}, where the object is a relation over protocols rather than a part
of one.
\end{definition}

\begin{measurement}[The residue by kind of repair]\label{meas:kinds}
Of the $385$ classified residue obligations, $172$ ($44.7\%$) ask for a new
element, $134$ ($34.8\%$) for a new sort, $51$ ($13.2\%$) for a new constraint
form and $28$ ($7.3\%$) for a new level; the four counts partition the $385$.
Regrouped by the sort a repair presupposes rather than by the kind of edit it
makes, $135$ obligations --- $35.1\%$ --- turn on a party sort, more than double
any other single addition.
\end{measurement}

Definition~\ref{def:minimal} permits a construction to carry an element
that discharges no obligation. No construction in the corpus does, but the
constructions were written under an instruction forbidding it, so this
records adherence to that instruction and not a property of the subject.

\subsection{The party sort}

The largest request is for a carrier that can name a party. Ninety-five of the
classified obligations, across all seven categories in the classification and
twenty-six of their thirty-five applications, ask who holds an authority and how
many of them there are: an externally-owned account, a quorum, a delegated
agent, an obligor.

\begin{proposition}[The party sort is free except on one measurement]\label{prop:party}
Adjoin party facts as positive existential atoms occurring only as heads. Then
Lemma~\ref{lem:polarity}, Corollary~\ref{cor:lattice},
Theorem~\ref{thm:convex}, Corollary~\ref{cor:ex} and
Theorem~\ref{thm:excomp} hold unchanged, and the prohibition $X9$ becomes
enforceable, taking the enforceable clutter from one row to two.
\end{proposition}

\begin{proof}[Proof sketch]
A requirement over the enlarged signature is still $\neg s \vee \bigvee_e e$,
one negative literal, hence dual-Horn, so polarity and union-closure are
inherited. The specialization digraph has fifteen arcs whose sources and targets
are disjoint; atoms appearing only as heads add targets and no sources, so $D$
stays acyclic and the convex geometry survives with its canonical forms.
\end{proof}

\begin{remark}[The encoding is the whole cost]
The condition is not decorative. If the sort instead records \emph{exactly}
which holder shape is present, the mutual-exclusion clauses $\neg\mathit{quorum}
\vee \neg\mathit{singleKey}$ are purely negative, and the argument that purely
negative classes are not union-closed applies verbatim:
Corollary~\ref{cor:lattice} dies. The existential encoding is a choice, and the
choice is where the structure is preserved or lost.
\end{remark}

\begin{remark}[What is damaged]
$X9$ --- a mutable implementation under immediate single-key control --- is one
of the nine recorded rows that name no element, and a party atom makes it a
genuine prohibition. The trace space of Proposition~\ref{prop:trace} grows and
the measurement that the quotient is complete, on which perfection held
trivially, is destroyed. Conjecture~\ref{conj:perfect} becomes a real conjecture
rather than a vacuous one. A measurement in this paper ceases to hold, which must
be counted as damage even though what it removes is a false comfort.
\end{remark}

\subsection{The bounded mandate}

Twenty-seven of the classified obligations, across six of the seven categories,
describe one primitive: a named agent may move a quantity within a declared
envelope. Four categories found it
independently --- over allocations, over interest rates, in code at five further
instances, and in legal form --- and it is the best-evidenced request in the
residue.

\begin{measurement}[The envelope, part by part]\label{meas:mandate}
Across the corpus the parts of the envelope are recorded as follows: fifteen
magnitude caps, nine domain restrictions, seven rate-of-change limits or delays,
six mandates with no bound at all, and \emph{zero} revocations. Revocation is in
every instance held by a party other than the agent, which is why this repair
and the party sort must be made together or not at all.
\end{measurement}

\begin{proposition}[The mandate costs nothing and improves the polarity split]\label{prop:mandate}
Recording the mandate at presence granularity --- that an envelope of each kind
exists, not what its value is --- preserves every result above, and reclassifies
$X16$ from the Horn half to the dual-Horn half.
\end{proposition}

\begin{remark}
The reclassification is the interesting half. $X16$ --- unbounded delegated
authority --- is a prohibition precisely because the envelope is absent, so
naming the envelope turns a negative row into a requirement with a positive
consequent. This is the only proposal in the residue that \emph{shrinks} the
part of the theory to which Measurement~\ref{meas:whereitfails} attributes every
observed composition failure. Union-closure of the enlarged system was verified
exhaustively over $2^{12}$ assignments.
\end{remark}

\subsection{Discharge by construction}

\begin{definition}[Void terms]\label{def:void}
For a requirement $(s,T)$ and a set $V \subseteq \El$ of \emph{voiding}
elements, the \emph{voided requirement} is the clause with head $T \cup V$: the
term is discharged either by satisfying it or by the presence of a mechanism
that makes the obligation unable to arise.
\end{definition}

\begin{theorem}[The repair is free on the lattice results]\label{thm:void}
Voided requirements are dual-Horn and their model class is union-closed, and the
model class of a voided requirement contains that of the original.
\end{theorem}

\begin{proof}
Formalised in Lean~4 against mathlib as \texttt{dualHorn\_voidReq},
\texttt{voidReq\_union\_closed} and \texttt{sat\_voidReq\_of\_sat}, with no
\texttt{sorry} and depending only on \texttt{propext},
\texttt{Classical.choice} and \texttt{Quot.sound}. Widening the head does not
touch the negative literal.
\end{proof}

\begin{remark}[The price, stated]
The model class only grows, so no protocol admissible before becomes
inadmissible and no published verdict is reversed in that direction. What is
lost is definiteness: \texttt{voidReq\_not\_definite} shows a voided requirement
with two distinct alternatives is not definite, so the term leaves the fragment
of \S\ref{sec:convex}. On our instance the loss is one arc of fifteen,
$Op \to Ct$, and the digraph remains acyclic, so the convex geometry survives
with a smaller definite fragment.
\end{remark}

\begin{remark}[Why it is worth the arc]
Eleven obligations in four categories are of this kind, and two of them are the
options venues that escrow the maximum payoff at trade time. Their rejection is
correct about the tables and wrong about the protocols, and no assignment of
elements repairs it, because the defect is that the language admits one way to
discharge a term. Definition~\ref{def:void} admits a second.
\end{remark}

\subsection{What we decline, and the open problems}

\begin{remark}[The largest group is not worth repairing]
Eighty-two of the classified obligations, spread over all seven categories and
twenty-six applications, are of the form \emph{the mechanism itself has no
symbol}. It is
the widest evidence base in the residue and we recommend against acting on it.
It is not one gap seen seven times; it is eighty-two gaps seen once each, and a
repair is eighty-two fitted warrant rows that prove no theorem. The vocabulary
would grow by half and the algebra would be unchanged. This is the clearest case
in the study of evidence quantity failing to imply structural significance.
\end{remark}

\begin{remark}[Three requests left open, with reasons]
A \emph{level} above the protocol --- a curator allocating across venues, an
aggregator routing to aggregators --- would break four of the five results
above, composition no longer being union. \emph{Magnitudes}, the request to
record how much rather than whether, break all five and come with a witnessed
counterexample. And the \emph{off-ledger register} splits: the half that names a
holder folds into the party sort, and the half that asks the carrier to
represent a fact whose truth-maker is a document breaks everything and is
unbounded. These are recorded as open problems rather than proposals.
\end{remark}

\section{Open problems}

\begin{enumerate}
  \item \textbf{The structure of $\Admf$ --- reopened, and now the central gap.}
    Commutation fails, invariance fails (Proposition~\ref{prop:noinvariance}),
    and the literature offers no structure theorem for non-commuting
    inflationary/deflationary pairs. Is $\Adm$ a lattice under any order?
  \item \textbf{Maximal composable fragment.} By
    Proposition~\ref{prop:clique} this is a maximum-clique problem on the
    compatibility graph. Conjecture~\ref{conj:perfect} asks whether $G^{0}$ is
    perfect; the corresponding question for $G_\oplus$ is open and is not
    reducible to it by Remark~\ref{rem:tracelimit}.
  \item \textbf{Minimal repair --- resolved for the prohibition half}
    (Theorem~\ref{thm:blocker}, Proposition~\ref{prop:oneobject}). What remains
    open is \emph{restoring closure after removal}, which is the completion
    problem and is NP-complete.
  \item \textbf{Independence.} Is the generating set $\El$ minimal, and which
    elements are definable from the rest?
\end{enumerate}

\section{Related work}\label{sec:related}

\paragraph{Interface theories.} Interface automata \cite{dealfaro2001} model
components by input assumptions and output guarantees and compose
\emph{optimistically}: two components are compatible when some environment makes
them work. Our compatibility relation is the same shape --- a symmetric binary
relation on components, with compatibility not implying joint compatibility ---
and de Alfaro and Henzinger's incremental-design axiom already records that
non-transitivity. What differs is the carrier. Interface automata compose
behaviours over shared ports; our protocols have no ports, and composition is set
union followed by closure. The absence of ports is why the assume-guarantee
contract algebra, whose composition, conjunction and quotient are well developed,
does not transfer wholesale: its composition operator is defined on ported
objects and half its operations depend on that structure.

\paragraph{Constraint satisfaction.} That a constraint language's closure properties determine its behaviour rests on
the Pol--Inv Galois connection \cite{geiger1968}, in the form
\cite[Thm.~32]{bkw2017}; the specific characterisation of union- and
intersection-closed Boolean relations is \cite[Ex.~5.3.5]{jeavons1997}, and
Lemma~\ref{lem:polarity} is an instance of it rather than a new result. Geiger's
theorems concern closed systems of relations and operations and quantify over
languages; they carry no cardinality-extremal content about subfamilies of a
single family, and so do not bear on the question of \S\ref{sec:cfp}. Schaefer's dichotomy \cite{schaefer1978} is often cited for
this; it is the wrong citation, its componentwise-closure statement being the
majority condition for bijunctive formulas, which is what
Measurement~\ref{meas:arity} concerns.

The reformulation of composability as a clique problem has a precedent we do not
claim to improve on. Jégou's microstructure \cite{jegou1993} encodes a CSP as a
graph whose $n$-cliques are its solutions, and Salamon and Jeavons
\cite{salamonjeavons2008} show that when that graph is perfect the instance is
tractable, via \cite{gls1981}. The move --- graph, clique, perfection,
polynomial algorithm --- is theirs. What is different here is the object: their
graph is on \emph{assignments} and a clique is one solution, whereas
$G_\oplus$ is on \emph{solutions} and a clique is a family of them that may be
composed. We are not aware of a perfection result for a graph of that kind, and
Conjecture~\ref{conj:perfect} should be read as asking whether their programme
transfers, not as an independent discovery.

The underlying combinatorial question --- given a family of sets that is not
union-closed, find a maximum-cardinality union-closed subfamily --- appears to be
unnamed. Searches of the constraint-satisfaction, lattice-theory and
union-closed-families literatures return nothing; the extensive work following
Frankl's conjecture concerns families that are already union-closed and supplies
no machinery for extracting one. In the language of universal algebra it is a
maximum subuniverse of the partial algebra $(\Adm, \cup)$, also apparently
unstudied. Proposition~\ref{prop:clique} is therefore offered as a reformulation
of a question that is open rather than as a retrieval of one that is settled.

\paragraph{Financial contract formalisms.} Peyton Jones and Eber
\cite{peytonjones2000} give a combinator language for financial contracts with a
denotational semantics; ACTUS \cite{actus} gives a taxonomy of contract types.
Neither is a completeness result and ACTUS does not claim to be one, describing
its coverage as ``the vast majority'' via ``about $32$'' patterns, a set that has
grown since its introduction. The instructive precedent is Marlowe: benchmarking
it against ACTUS produced a documented language extension and recorded coverage
failures \cite{kondratiuk2021}. That is the standard we hold ourselves to --- a
vocabulary is assessed by confronting it with a corpus and recording what it
cannot express --- and it is why the residue is reported rather than tidied away.

\paragraph{What is not here.} We are not aware of an application of interface
theories or assume-guarantee contracts to decentralised finance. The nearest work
is adversarial rather than structural, taking extractable value as the property
to be preserved under composition. That is a semantic criterion where ours is
syntactic, and the two are complementary: a syntactic criterion can rule a
composition out cheaply, but only a semantic one can rule it in.

\section{Conclusion}

Three things are settled. Requirements and warrants are dual-Horn and
prohibitions Horn, so the protocols satisfying the positive constraints form a
complete lattice under union and the prohibitions are what removes it; this is
proved from clause polarity and needs no measurement. On the deterministic
fragment the closure is a reachability closure on an acyclic digraph, hence a
convex geometry, hence every closed set has a unique minimal generator; composition on those generators is a bounded number of word
operations and refers to nothing else. And the diagonal
character of admissibility obstructs two standard frameworks for one common
reason, which is more informative than either obstruction alone.

Two things are not. The positive theory does not constrain any completion of any
protocol in the corpus: the $79$ positive clauses exclude no element across all
$72$ seeds, so the vocabulary rejects but does not predict. And the order
structure of the operationally admissible sets is unknown, commutation and
invariance both failing.

Composition failure, by contrast, is explained by the account that explains the
structure. Requirements and warrants are dual-Horn and cost nothing; the
prohibitions are Horn; Horn model classes are not closed under union; and $184$
of the $185$ observed failures arm a purely negative row. Only two recorded
rows are of genuinely mixed polarity and they account for six failures between
them. The classification is not evaded by the data; it predicts it.

Two applied results follow. That six order-book venues agree to the symbol on which mechanisms they derive
rather than choose, while the one oracle-priced venue derives none of them, is a
statement about design freedom that the raw element sets cannot express. That
Uniswap composed with Aave covers a prohibition neither covers alone is
non-compositionality exhibited rather than argued, on the two largest protocols
of their respective categories. Both follow from the canonical form, and neither
would survive a formalism that declined to be applied.

What the vocabulary cannot see remains the honest limit. Coverage degrades with the fraction of a protocol that lives off-chain, and the
largest asset in the corpus reduces to five mechanisms of which three are
approximations. A framework
that explains the structure of what is on-chain, and is silent about the obligor,
the custodian and the register of record, is describing the part of the subject
that happens to be formalisable rather than the part that determines whether
anyone is paid.

\appendix

\section{Validation}\label{sec:validation}

These computations confirm that the implementation behaves as the
definitions require. None is a statement about the subject, and no result
in the body depends on one except where it is cited.

\begin{measurement}[clause widths]\label{meas:arity}
In the CNF encoding of admissibility the widest clause has $34$ literals, and
$20.4\%$ of clauses are bijunctive. The system is therefore not preserved by the
majority operation and is not median-closed, though the bijunctive fragment is.
\end{measurement}

\begin{measurement}[exhaustive to size three]\label{meas:closureprops}
Exhaustively over all $172{,}431{,}735$ pairs from $\mathcal{R}$ of size at
most three, $0$ fail intersection-closure and $0$ fail union-closure.
Intersection-closure nevertheless fails, and the smallest witness has five
elements: $\{Ct,Ex,Li,Pl,Sh\}$ and $\{Ct,Li,Pl,Sh,Tp\}$ both satisfy $\Law$,
while their intersection $\{Ct,Li,Pl,Sh\}$ leaves $L1$ unsatisfied. The
exhaustive range is therefore too small to exhibit the failure, not evidence
against it.
\end{measurement}

\begin{measurement}\label{meas:latticeconf}
Over $175{,}230$ pairs from $\mathcal{R} \cap \mathcal{W}$ there are $0$
union-closure violations. Meet is not intersection: about $44{,}000$ pairs have
$X \cap Y \notin \mathcal{R} \cap \mathcal{W}$.
\end{measurement}

\begin{measurement}\label{meas:vacuous}
On synthetic operators of the present shape the iteration was sound $2000/2000$
and exact $2000/2000$ with zero slack. On the actual $\Gamma,\Delta$ it is sound
and \emph{vacuous}: $x_\infty = \top$ on every seed at $10$, $20$ and $58$
elements, exact in $0$ of $18$ seed-instances, slack $1$--$58$. The synthetic
operators admitted a $\Delta$ that removes at $\top$; ours structurally cannot.
\end{measurement}

\begin{measurement}\label{meas:noinvariance}
Exhaustively over the $224{,}025$ members of $\mathcal{R}$ of size at most four,
$\Delta$ leaves $\mathcal{R}$ on $116$.
\end{measurement}

\begin{measurement}[Which prohibitions cost downward closure]\label{meas:downward}
Over the $16{,}384$ subsets of a $14$-element universe containing every element
that occurs in a prohibition, $15{,}872$ model the listed clutter and \emph{none}
of them has a subset that does not: $\mathcal{H}$ is downward closed, as
Lemma~\ref{lem:polarity} requires of a purely negative clause set. Under the
full prohibition predicate, listed rows together with the conditional ones,
$6{,}580$ subsets are prohibition-free and $1{,}708$ of them have a subset that
is not. The smallest witness is $\{Oa,Li,Ex\}$, which arms $X18$ on the removal
of $Ex$.
\end{measurement}

\bibliographystyle{plain}
\bibliography{refs}

\end{document}

===== END FILE =====

===== FILE quint-models/L6/usdt.qnt | SHA256 ae189e12f85b3b529fb475ca59da17658db3a2f5f2d0db4e1f4499323915fb4a =====
// Tether USDT — core on-chain state machine.
// Source: protocol-repos/fiat/tethercoin_USDT/TetherToken.sol
//   balances / _totalSupply (StandardToken L107–108, L82)
//   issue / redeem onlyOwner (L406–427)
//   transfer with optional fee basisPointsRate/maximumFee (L126–136)
//   addBlackList / destroyBlackFunds (L281–297)
//   pause (Pausable L254)
// Off-chain reserve is NOT in the contract — modelled as external `reserve`.

module usdt {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("owner", "alice", "bob", "carol")
  pure val OWNER: str = "owner"

  var balances: str -> int
  var totalSupply: int
  var restricted: str -> bool   // isBlackListed
  var paused: bool
  var feeBps: int               // basisPointsRate (max 20 in code)
  var maxFee: int               // maximumFee
  var reserve: int              // off-chain attested reserve (external)

  action init: bool = all {
    balances' = USERS.mapBy(u => if (u == OWNER) 1000 else 0),
    totalSupply' = 1000,
    restricted' = USERS.mapBy(_ => false),
    paused' = false,
    feeBps' = 0,
    maxFee' = 0,
    reserve' = 1000,
  }

  pure def transferFee(amount: int, bps: int, cap: int): int = {
    val raw = mulDivDown(amount, bps, 10000)
    if (raw > cap) cap else raw
  }

  /// issue(amount): mint to owner (TetherToken.sol L406–413)
  action issue(amount: int): bool = all {
    not(paused),
    amount > 0,
    val minted = applyMint(balances, totalSupply, OWNER, amount)
    all {
      balances' = minted._1,
      totalSupply' = minted._2,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve + amount,
    }
  }

  /// redeem(amount): burn from owner (L420–427)
  action redeem(amount: int): bool = all {
    not(paused),
    canBurnFrom(balances, OWNER, amount),
    reserve >= amount,
    val burned = applyBurn(balances, totalSupply, OWNER, amount)
    all {
      balances' = burned._1,
      totalSupply' = burned._2,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve - amount,
    }
  }

  /// transfer with optional fee to owner (L126–136, L340–347)
  action xfer(src: str, dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(src),
    USERS.contains(dst),
    not(isRestricted(restricted, src)),
    amount > 0,
    balances.get(src) >= amount,
    val fee = transferFee(amount, feeBps, maxFee)
    val sendAmt = amount - fee
    all {
      sendAmt > 0,
      balances' = {
        val b1 = balances.setBy(src, b => b - amount)
        val b2 = b1.setBy(dst, b => b + sendAmt)
        if (fee > 0) b2.setBy(OWNER, b => b + fee) else b2
      },
      totalSupply' = totalSupply,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve,
    }
  }

  /// addBlackList (L281–284)
  action blacklist(user: str): bool = all {
    USERS.contains(user),
    user != OWNER,
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = setRestricted(restricted, user, true),
    paused' = paused,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  /// destroyBlackFunds: wipe balance and burn supply (L291–297)
  action destroyBlackFunds(user: str): bool = all {
    USERS.contains(user),
    isRestricted(restricted, user),
    val dirty = balances.get(user)
    all {
      dirty > 0,
      balances' = balances.put(user, 0),
      totalSupply' = totalSupply - dirty,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve,
    }
  }

  action pause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = true,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  action unpause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = false,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  /// Off-chain reserve attestation update (no on-chain function — external)
  action attestReserve(newReserve: int): bool = all {
    newReserve >= 0,
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = paused,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = newReserve,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet v = USERS.oneOf()
    nondet amt = 1.to(50).oneOf()
    nondet r = 900.to(1200).oneOf()
    any {
      issue(amt),
      redeem(amt),
      xfer(u, v, amt),
      blacklist(u),
      destroyBlackFunds(u),
      pause,
      unpause,
      attestReserve(r),
    }
  }

  /// Supply equals sum of balances (fee stays on-ledger).
  val inv_supply_conserved: bool =
    supplyConserved(balances, USERS, totalSupply)

  /// Non-negative balances and supply.
  val inv_nonneg: bool =
    totalSupply >= 0 and USERS.forall(u => balances.get(u) >= 0)

  /// Off-chain 1:1 backing is NOT enforced on-chain. `attestReserve` can set
  /// any value; `destroyBlackFunds` shrinks supply without touching reserve.
  /// We therefore check the WEAKER on-chain property: wipe can only increase
  /// the reserve surplus (reserve - totalSupply), never create under-backing
  /// by itself. Under-backing requires the external attest action.
  ///
  /// inv_reserve_covers_if_honest: holds only if attest is disabled from step.
  /// Documented failure: with attestReserve in step, inv_reserve_covers fails
  /// (seed evidence in ledger) — the hidden precondition of the category.
  val inv_reserve_covers: bool =
    reserveCovers(reserve, totalSupply)

  /// Always-true on-chain conservation (independent of off-chain reserve).
  val inv_onchain_only: bool =
    supplyConserved(balances, USERS, totalSupply) and totalSupply >= 0
}

===== END FILE =====

===== FILE research/positive-program/basis/BASIS.md | SHA256 fd1f246ce8c6cc23a70f1f542b9201a756513640a9acb04538a2258007be7023 =====
# BASIS — the primitive set `P`

Derived from the 57 typechecked specs in `quint-models/L1..L6`, the six `common.qnt`
factorings, and `research/positive-program/sigma/extraction.json`
(2694 defs, 388 state variables, 32 record types).

---

## 1. Sorts

Quint gives every carrier `int`, `bool`, `str`, or a map/record over these. Those are
not sorts of the algebra. A sort is a class of values closed under the operations that
act on it; two Quint `int`s belong to different sorts when no definition in the corpus
mixes them without an explicit conversion. Six sorts fall out.

| sort | what it holds | witnesses (extraction `statevars`) |
|---|---|---|
| `Q` | **quantity** — owned, conserved, non-negative | `balances`(7), `totalShares`(7), `totalSupply`(6), `shares`(6), `reserve0/1`, `cash`, `collateral`, `syLocked`, `escrowBalance` |
| `Σ` | **scalar** — a ratio against a declared unit | `price`(4), `oraclePrice`(3), `collPrice`, `markPrice`, `liquidityIndex`, `variableBorrowIndex`, `borrowIndex`, `syRate`; units `INDEX_BASE`, `WAD`, `RAY`, `BPS`, `ODDS_BASE` |
| `T` | **time** — ordinal, appears only in differences | `time`(7), `clock`(3), `lastTime`, `lastUpdated`, `updatedAt`, `readyAt`, `startHeight` |
| `Φ` | **phase** — finite, written by the protocol | `ReqStatus`, `ReqPhase`, `FillStatus`, `IntentStatus`, `Side`, `condState`, `OptionPos.phase` |
| `N` | **name** — equality only, never arithmetic, never written | `USERS`(40 specs), `owner`, `maker`, `requester`, `minter`, `srcDomain`, `nonce` |
| `B` | **truth** | 1062 of 2694 defs have `out_type: bool` |

**Six, not nine.** The load-bearing split is `Q`/`Σ`. Both are `int` in every spec, and
`mulDivDown(a,b,d)` takes arguments from both indiscriminately
(`mulDivDown(assets, totalShares, totalAssets)` — all `Q`;
`mulDivDown(scaled, index, INDEX_BASE)` — `Q,Σ,Σ`). They are nevertheless distinct
sorts because **different operations are legal on them**: a `Σ` may be overwritten by
an external writer (`applyPostPrice`, L5/common.qnt:109; `shockPrice` in
L1/morpho_blue.qnt), a `Q` never is. Across all 57 specs no state variable of sort `Q`
is ever assigned a value that is not an arithmetic term over prior `Q`s — even USDT's
off-chain reserve moves only in lockstep (`reserve' = reserve + amount`,
L6/usdt.qnt:51,68). That asymmetry is what stops the basis being degenerate (§5).

`T` is not `Q`: nothing transfers time between names, and every spec advances it
monotonically by fiat. `Φ` is not `N`: `Φ` is written, `N` is a fixed index set.

---

## 2. The primitives

### P1 · `Led` — the ledger

**Carrier** `(N ⇀ Q) × Q` — a balance map and a declared total.
**Operations**
- `credit : N × Q → Led`, `debit : N × Q ⇀ Led` (partial), `move : N × N × Q ⇀ Led`.

**Laws.** With `bal` the map, `sup` the total, and `‖bal‖ = Σ_{n∈N} bal(n)`:
1. *Conservation.* `‖bal‖ = sup` is preserved by all three operations
   (`move` changes neither; `credit`/`debit` change both by the same `q`).
2. *Non-negativity.* `debit(n,q)` and `move(n,n',q)` are defined only when
   `bal(n) ≥ q`; `sup ≥ 0` always.
3. *Additivity.* `credit(n,q₁) ∘ credit(n,q₂) = credit(n,q₁+q₂)`; likewise `debit`.
4. *Locality.* `move(n,n',q)` is the identity on `bal(m)` for `m ∉ {n,n'}`.
5. *No forgery.* `Q` is closed under `Led`: there is no operation `X → Q` for `X ≠ Q`.

**Instantiated by** L6/common.qnt `canTransfer`/`applyTransfer`/`applyMint`/`applyBurn`/
`supplyConserved`; L5/common.qnt `canMintSupply`/`applyMintSupply`/`canBurnSupply`/
`applyBurnSupply`; L4/common.qnt `canMintWrap`/`applyBurnWrap`, `applyEscrowDeposit`/
`applyEscrowWithdraw`, `applyBurnOnSrc`/`applyMintOnDst`; L3/common.qnt `applyDeposit`/
`applyRedeem`; L2/common.qnt `mapSum`/`nonNegMap`.

**Not definable from the others.** It is the only operation whose result sort is `Q` and
whose effect is a state change. Remove it and the reachable `Q`-values of any machine
are exactly the initial ones: `Prop` computes but does not store, `Cmp` returns `B`,
`Post` cannot write `Q` by law 5.

---

### P2 · `Prop` — fused proportion

**Signature** `π : Q × Q × Q → Q`, `π(a,b,c) = ⌊a·b/c⌋` for `c > 0`, `0` otherwise;
dual `π̄(a,b,c) = ⌈a·b/c⌉`. `Q` carries an ordered commutative monoid `(+,0)`;
`Prop` supplies multiplication and floored division.

**Laws.**
1. *Unit.* `π(a,c,c) = a`.
2. *Round-down.* `π(π(a,b,c),c,b) ≤ a` — the round-trip never returns more than it took.
   Stated in code as L5/common.qnt:47 `navRoundTripLeq`.
3. *Dual bound.* `π(a,b,c) ≤ π̄(a,b,c) ≤ π(a,b,c) + 1`.
4. *Sub-additivity.* `π(a₁,b,c) + π(a₂,b,c) ≤ π(a₁+a₂,b,c)` — the dust of a split
   deposit accrues to the pool, never to the depositor.
5. *Monotonicity.* `a ≤ a′ ⟹ π(a,b,c) ≤ π(a′,b,c)`.
6. *Fusion.* `π(a,b,c) ≥ ⌊a·⌊b/c⌋⌋` and the inequality is strict in general — staged
   rounding is not the same operation, which is why every spec uses a fused form.

**Instantiated by** `mulDivDown` (37 specs, L1/L4/L5/L6), `mulDivUp` (20), `divFloor`
(11), `ceilDiv` (L2); and on top of them: L1 `sharesFromAssets`/`assetsFromShares`,
`presentFromScaled`/`scaledFromPresent`, `cpAmountOut`, `seizeCollateral`, `utilization`,
`twoSlopeRate`; L2 `assetsToShares`/`sharesToAssets`/`assetsToSharesCeil`,
`accrueByIndex`, `collateralRatio`; L3 `assetsToShares`/`sharesToAssets`, `syToAsset`/
`assetToSy`, `applyProfit`; L5 `sharesFromNav`/`assetsFromNav`, `utilCollateralReq`;
L6 `betPayout`, `redeemPayout`.

**Not definable from the others.** Without `Prop` the reachable `Q`-values lie in the
ℕ-span of the initial values, since `Led`'s arguments would be sums of existing
balances. `cpAmountOut(r₀,r₁,δ,997,1000)` is not in that span for generic reserves, and
neither is any share count against a non-unit ratio.

---

### P3 · `Cmp` — comparison

**Signature** `≤ : X × X → B` for `X ∈ {Q, Σ, T}`; `= : X × X → B` for `X ∈ {Φ, N}`.
`B` carries its Boolean algebra. `Cmp` is the only operation whose result sort is `B`.

**Laws.** Total order on `Q`, `Σ`, `T`; equivalence on `Φ`, `N`; compatibility with the
monoid, `a ≤ b ⟹ a + c ≤ b + c`; compatibility with `Prop`, law P2.5.

**Instantiated by** — two distinct roles, both in the code.
*Guard mode* (blocks the actor's own transition): L1 `isHealthy`, `cpKHolds` used as a
precondition in L1/uniswap_v2.qnt:83,100; L2 `isHealthy`/`collateralRatio`;
L3 `maintainsMargin`, `canConsume`, `canRedeem`, `headReady`; L4 `canBurnMintSend`,
`canFillOrder`, `clearsAtLimit`, `canDeliverOnce`; L5 `canReserve`, `isMarginSolvent`,
`canWithdrawCash`; L6 `canConsume`, `canBook`, `canSplit`, `canMerge`.
*Enabler mode* (its **negation** opens a transition to a party other than the owner):
L3/common.qnt:120 `canLiquidate = … and not(maintainsMargin(…))`, used at
L3/apex.qnt:142 and L3/gmx.qnt:134; the same shape gates `liquidate` in
L1/morpho_blue.qnt and L2/liquity.qnt.

**Not definable from the others.** No composite of `Led`, `Prop`, `Post` has result sort
`B`. Delete `Cmp` and every guard becomes `true`: `debit` loses partiality, so
non-negativity (P1.2) fails on the first over-withdrawal, and no liquidation is ever
enabled.

---

### P4 · `Post` — exogenous write

**Signature** `post_X : N × X × X → X` for `X ∈ {Σ, Φ, T}`, parameterised by an
authority `n ∈ N` and a relation `R_X ⊆ X × X`; `post_X(n, x, x′)` is defined iff
`n` is the declared writer and `(x,x′) ∈ R_X`.

**Laws.**
1. *`Q`-exclusion.* `post_Q` does not exist. This is the non-degeneracy axiom.
2. *`R`-respect.* Every write lies in `R_X`; `R_T` is `<` (clocks advance),
   `R_Σ` is `Σ_{>0} × Σ_{>0}` (free), and **`R_Φ` is per-instance — acyclic for
   status machines, cyclic for toggles.**

   > **CORRECTION.** This clause previously read "`R_Φ` is the acyclic status
   > DAG". That is false of the corpus this basis was extracted from, and the
   > surrounding laws already said so: P4.3 is conditional — "***When*** `R_X` is
   > acyclic the sequence of writes is a chain" — which is vacuous if P4.2 had
   > fixed acyclicity; and P4.4's idempotence admits `(x,x) ∈ R_X`, which a DAG
   > has no room for. Acyclicity described the `ReqStatus`/`ReqPhase`/
   > `FillStatus`/`IntentStatus` instances sampled for §1, not the sort.
   >
   > **Measured** (`basis/phi_cycles.py`): of the finite protocol-written boolean
   > carriers in the 51 protocol specs, **18 are driven both ways and 9 only one
   > way**, with a cyclic carrier in **14 of 51 specs**. Witnesses:
   > `L6/usdc.qnt` `paused` (`pause`/`unpause`, :127-145) and `restricted`
   > (`blacklist`/`unblacklist`, :105-125); `L1/uniswap_v4.unlocked`;
   > `L1/pancakeswap.unlocked`; `L3/spark.frozen`; `L6/usdg.paused`;
   > `L6/usdt.restricted`; `L5/panoptic.poolLocked`.
   >
   > The 9 "monotone" carriers are an **upper bound on acyclicity, not a
   > measurement of it**: several are one-way only because the spec omits the
   > inverse. `L6/usdc.isMinter` is granted by `configureMinter` and never
   > revoked, yet the contract carries `removeMinter`
   > (`FiatTokenV1.sol:346`), which `usdc.qnt:5` records as covered and the spec
   > does not model. The true cyclic population is larger than 18.
   >
   > **Consequence.** The *once* law (P4.3) holds only of the acyclic instances,
   > and no argument may quantify over all `Φ` writes and assume a chain. A role
   > assignment — granted, revoked, re-granted — is a legal `Φ` carrier under the
   > corrected clause, which is why `post_Φ` reaches it. See
   > `sigma/RETRACTION.md`.
3. *Irreversibility.* When `R_X` is acyclic the sequence of writes is a chain — this is
   the *once* law: `markUsed` (L4/common.qnt:108) grows monotonically, `applyClaim`
   reaches a terminal phase.
4. *Idempotence.* `(x,x) ∈ R_X ⟹ post(n,x,x) = x`.

**Instantiated by** *Σ-writes*: L5 `PostedPrice`/`canPostPrice`/`applyPostPrice`;
`shockPrice` in every L1/L2 lending spec; L3/pendle.qnt `syRate`; L6 UMA `payout`.
*Φ-writes*: L4 `applyApprove`/`applyReject`/`applyCancel`, `applyDelegate`/
`applyExecute`/`applyRevoke`, `applyFill`, `applyCancelOrder`, `canDeliverOnce`/
`markUsed`; L5 `applyRequest`/`applyPrice`/`applyClaim`.
*T-writes*: the `time' = time + 1` tick in all 51 `step` actions.

**Not definable from the others.** `Led` is conservative and `Prop` is a term former;
neither can produce a value on a carrier that has no additive structure (`Φ`) or that is
not derived from prior state (`Σ`). Without `Post`, prices are constant for all time —
no liquidation is ever triggered — and no two-phase request ever advances past `Pending`.

---

## 3. `|P| = 4`, sorts `= 6`

Four operations, six sorts. Four because each of the four independence witnesses above
exhibits a corpus protocol that the remaining three cannot express; six because each sort
is discriminated by an operation legal on it and illegal on another (`Q` vs `Σ` by
`Post`; `T` vs `Q` by `Led`; `Φ` vs `N` by `Post`; `B` by `Cmp`).

---

## 4. What was dropped or merged

**F4 (conservation) is not a primitive; it is a law on `Led`.** Decisive evidence: every
conservation definition in the corpus is `qualifier: val`, result `bool`, and appears
*only* on the right of an invariant declaration — `supplyConserved` and `reserveCovers`
in L6/{usdc,usdt,usdg,pyusd}.qnt:142–199, `shareSolvency` in L3/{yearn,beefy}.qnt:153–156,
`pyBackingHolds` in L3/pendle.qnt:196, `remainingBounded` in L4/{cow,oneinch}.qnt,
`shareConservation` in L1/morpho_blue.qnt. Not one of them is an argument to an update
or a precondition of an action. The single apparent exception, `cpKHolds` at
L1/uniswap_v2.qnt:83, is a *guard* — and a guard is `Cmp`, not a conservation operation.
F4 therefore splits cleanly: its guard occurrences are `Cmp`, its invariant occurrences
are laws P1.1–P1.2, and nothing remains.

**F7 (index accrual) is not a primitive.** It reduces to `Prop` + `Led`, not to F1 + F6.
The conversion half is literally `Prop`: `presentFromScaled(s,i) = mulDivDown(s,i,BASE)`
is `assetsFromShares(s, i, BASE)` with the ratio pair `(i, BASE)` supplied externally.
The accrual half is an unbacked `Led.credit`. The corpus proves the reduction by
exhibiting both implementations of the same observable: Morpho stores no index at all and
accrues by `totalSupplyAssets' = totalSupplyAssets + interest` with
`totalSupplyShares' = totalSupplyShares` (L1/morpho_blue.qnt:168–170), while Aave stores
`liquidityIndex`/`variableBorrowIndex` and calls `accrueIndex` (L1/aave_v3.qnt:196).
INSIGHT-L1 §2 records exactly this: Morpho has "no separate index var; interest mutates
asset totals." The index is `Prop`'s endogenous ratio hoisted into a `Σ` variable.
*One* variant needs more: Pendle's `ratchetIndex(ix,newRate,now) = max(stored,newRate)`
reads an external rate — that is `Post(Σ)` followed by `Cmp`, so it needs F6, i.e. `Post`.

**F1 and F6 merge into `Prop` + `Post`.** F1 is `Prop` with the ratio read off a pair of
`Q` totals; F6 is `Post(Σ)` supplying the same ratio exogenously. They are the same
arithmetic with different provenance for the denominator — compare
`assetsFromShares(s, A, S) = mulDivDown(s,A,S)` (L1) with
`assetsFromNav(s, price, scale) = mulDivDown(s,price,scale)` (L5). No spec distinguishes
them at the point of use.

**F3 (rate-limit envelope) drops.** `currentLimit = min(cap, last + slope·Δt)`
(L3/common.qnt:176, L6/common.qnt:119 — same formula, two lanes) is `Led.credit` of a
`Prop`-computed amount, clamped by a `Cmp` case split.

**F5 (health) becomes `Cmp`,** retaining its two modes (guard, and enabler under
negation). The enabler mode carries the authority content — `liquidate` is
`move(owner, liquidator, q)` guarded by `¬τ`, versus `withdraw` which is
`move(owner, owner, q)` guarded by `τ`. Because `Led` already names both endpoints, no
separate seize primitive is needed.

**F8 (payoff) drops.** `redeemPayout` and `betPayout` are `Prop` against a `Post`ed
scalar. `europeanPayoff`'s kink is a two-way `Cmp` case split.

**F2 (deferred claim) drops** to `Post(Φ)` for the status machine, `Cmp` on `T` for the
gate (`headReady`), and `Led` for the escrowed amount.

**One derived operation deserves a name** even though it is eliminable: truncated
difference `a ∸ b = max(0, a−b)`. It is the single most reused *derived* term —
`applyLoss` junior-first absorption, `europeanPayoff`, `currentLimit`'s cap,
`applyPayClaim`'s `min(balance, amount)`, `ratchetIndex`'s `max`, `seizeCollateral`'s
clamp. Limited liability, tranche subordination, option payoff and rate-limit saturation
are the same operation. It is not primitive because every occurrence is a finite case
split on `Cmp`, which the composition operation supplies for free.

---

## 5. Composition

A **construction** is `M = (S, s₀, →)` where `S` is a finite product of carriers of the
six sorts, `s₀ ∈ S`, and `→` is a finite set of **guarded updates** `g ⊳ u`: `g` a
`B`-term over `Cmp`, `u` a simultaneous assignment whose right-hand sides are terms over
`Led`, `Prop`, `Post`. This is exactly the corpus shape: `all { guard, assignments }`,
with every variable assigned including the untouched ones (see the ten echoed
assignments in `mintPY`, L3/pendle.qnt:60–74).

Given `M₁`, `M₂` and a **coupling** `κ`, a partial injection between their carriers that
identifies only carriers of the same sort:

> `M₁ ⋈_κ M₂ = ( (S₁ × S₂)/κ , (s₀¹, s₀²)/κ , →₁ ⊎ →₂ ⊎ →_κ )`

where `→₁`, `→₂` are lifted by identity on the other's private carriers, and
`→_κ = { (g₁ ∧ g₂) ⊳ (u₁ ∥ u₂) : u₁, u₂ agree on κ-shared carriers }` is the set of
**fused** transitions. The `any { … }` of all 51 `step` actions is `⊎`; shared `var`s
are `κ`; fused transitions are what makes Convex-over-Curve or Pendle-over-SY a single
atomic action rather than two.

`⋈` adds no expressive power on its own: a construction over the empty basis has no
transitions, and `⋈` of two such is still empty. Closure under `⋈` therefore means
exactly "reachable by fusing and interleaving the four primitives".

**Refutation condition.** Every machine in the closure satisfies, by induction on `→`:
(i) `‖bal‖ = sup` for each `Led` factor except across declared mint/burn;
(ii) `T` is monotone; (iii) rounding is never in the caller's favour (P2.2, P2.4);
(iv) no `Q` changes except by `Led`. Exhibit a DeFi application requiring the failure of
any one of these — a quantity that moves without a debit anywhere, or a conversion whose
round trip returns strictly more than it took — and completeness is refuted.

===== END FILE =====

===== FILE research/positive-program/basis/GENERATION.md | SHA256 74303c8f2115e7bd62f1feae89e3ee839baab268df9c384bed56ff0a16edb777 =====
# The Generation Theorem

## 1. What "generated" has to mean

A protocol is a state machine, so "lies in the closure of `P` under composition"
needs a reading. Three were on offer.

**(a) Dataflow-graph composition.** Worthless, and demonstrably so. A dataflow
graph records arity and wiring, nothing else. `collValue(amount, price) = amount
* price` and `cpProduct(r0, r1) = r0 * r1` have the identical graph; so does
every binary operation in the corpus. I ran the check that reading licenses: it
matched 29 of the corpus's 64 raw arithmetic sites to `collValue` alone, because
`collValue`'s body *is* the pattern `X * Y`. Under (a) a basis of one binary
operator generates everything. This is Post's `P = {⊤}` failure exactly.

**(b) Bisimilarity of transition systems.** The strongest reading, and right in
principle: there is a `P`-term whose denotation is bisimilar to the protocol's
transition relation. It is not one I can discharge — bisimulation between two
388-variable systems over unbounded integers is not a finite exact computation.
I take (b) as the target that (c) approximates from below.

**(c) Every definition is a `P`-term up to renaming.** This is checkable, and it
is non-degenerate **provided arithmetic is not free**. Naively, (c) is vacuous:
every Quint definition is by construction a finite term over Quint builtins, so
"reducible to primitives plus arithmetic" is true of everything. The whole
question is what "plus arithmetic" admits.

So I fix the reading by splitting the builtins.

> **Definition.** Let `Π` be the *plumbing*: boolean connectives, comparison,
> conditional, additive integer arithmetic (`+`, `-`, unary minus), and data
> movement (records, tuples, sets, maps, `get`/`put`, `fold`, `filter`,
> quantifiers, action combinators, assignment, `oneOf`). Let
> `Π_hard = {*, /, mod, pow}`.
>
> A definition `d` of protocol spec `S` in lane `ℓ` is **`P`-generated** iff
> every operator applied in `body(d)` lies in `Π ∪ B_ℓ ∪ G(S)` — where `B_ℓ` is
> the set of operators declared in `ℓ/common.qnt` and `G(S)` is the set of
> definitions of `S` already shown generated, under a well-founded order — and
> **no operator of `Π_hard` occurs in `body(d)` outside a `B_ℓ` call.**

The load is carried by the last clause. Additive arithmetic is inert: a ledger
is an additive monoid, and every one of the eight families presupposes that
carrier. **Multiplicative and divisive arithmetic is not inert — it is precisely
what the families are.** `a*b/d` is pro-rata (F1). `x * index / BASE` is index
accrual (F7). `c*p*ltv ≥ d*p*10⁴` is the health predicate (F5). If `*` and `/`
were free plumbing, F1, F5, F7 and F8 would all be plumbing, and the theorem
would say nothing. Banning `Π_hard` outside a basis call is what makes an
unbounded family of definitions capable of failing.

Two corollaries of the definition, both enforced in the check:

- **Non-substantive basis members cannot serve as templates.** A basis operator
  whose body is a single builtin applied to distinct bare metavariables is a
  *rebadged builtin*, not a mechanism. Thirteen lane primitives are of this
  form — `collValue(a,p) = a*p`, `cpProduct(r0,r1) = r0*r1`,
  `applyEscrowDeposit(e,a) = e+a`, and ten more. They are excluded from
  matching, and their existence is itself evidence.
- **Closed arithmetic is not a mechanism.** `100 * 100`, `BASE_BPS / 2`,
  `DELEGATE_COVER / 2` compute numbers from literals. Three such sites are
  excluded as constant folding.

What (c) lets through that (b) would not: **anything whose content is temporal
rather than algebraic.** A two-phase request/claim and an immediate claim have
the same terms and different transition systems. This blind spot is real and I
report where it bites (§6).

## 2. The theorem

> **Generation.** For every application `A` in the corpus with a Quint
> formalisation `S_A` in lane `ℓ`, every definition of `S_A` is `P`-generated in
> the sense of §1, where `B_ℓ` realises only families of `P`.
>
> **Non-degeneracy.** `Π_hard ∩ Π = ∅`, and no member of `B_ℓ` used as a
> template is a rebadged builtin.
>
> **Independence.** For each `F ∈ P`, some operator realising `F` is not a term
> over `(P \ {F}) ∪ Π`.
>
> **Refutation condition.** The theorem is refuted by exhibiting a DeFi
> application and a definition in its specification containing a `Π_hard`
> operator outside every `B_ℓ` call, where no operator realising a family of `P`
> has that content.

That last clause is what makes this a theorem rather than a slogan, and it is
satisfied. Nineteen such witnesses exist.

## 3. The check

All 57 specs parse under `quint 0.32.0`; IR extracted with `quint parse --out`.
Fifty-one are protocol specs, six are lane `common.qnt`. **820 definitions**
tested (the six commons are the basis and are not tested against themselves).

| | count |
|---|---|
| definitions tested | 820 |
| `P`-generated | **743** |
| not generated | **77** |
| — of which fail on their own body (root cause) | 37 |
| — of which fail only through a dependency | 40 |
| specs with zero violations | **27 / 51** |
| specs with residue | 24 / 51 |

Of the 40 transitive failures, 24 are the `step` action — the nondeterministic
driver that disjoins every other action, so it inherits any failure in the spec.
It is an artefact of the model, not a finding.

The root cause is small and fully enumerable: **46 maximal violating subterms**
(maximal = the outermost `Π_hard` node outside a basis call; nested products
inside one are part of the same violation). Forty-six sites is the whole
residue, and every one is listed below.

## 4. The residue, item by item

Each of the 46 is either a basis operator the spec wrote out by hand
(**INLINE** — the basis covers it, the spec is sloppy) or content no operator in
the lane basis and no family in `P` possesses (**MISSING** — the basis must
grow).

**INLINE: 27.** These re-fold. Eleven are `x * y / d` — the F1 kernel — written
raw: `babylon.slash` `(sats * SLASH_FRACTION_BPS)/BPS`, `crvusd.health`
`(debt * (WAD - LIQ_DISCOUNT))/WAD`, `eigenlayer.slash` ×3,
`eigenlayer.sharesToUnderlying`, `eigenlayer.underlyingToShares`,
`etherfi.rebase`, `usdd_psm.buyGem`, `usdd_psm.sellGem`, `liquity.redeem`. Eight
more are fixed-ratio scalings (`uniswap_v3` `amountIn/1000`, `panoptic`
`collat/2`, `kyber` `amountIn*2`, `fluid` `rate/2`, `beefy` `pool*shares`,
`apex` `baseIn*lpShares`, `huma` `seniorRedeemReq*fillS` and `juniorRedeemReq*fillJ`).
Eight are index arithmetic that `presentFromScaled` / `scaledFromPresent` /
`accrueIndex` already provide: `justlend` ×5 (`principal*globalIdx`,
`amount*INDEX_BASE`, `seizeUnderlying*INDEX_BASE`, `cTokens*rate`,
`((cash+borrows)-reserves)*INDEX_BASE`), `justlend.accrueBlock`
`(totalBorrows*rateBpsPerBlock)*blocks`, `maple.accrueLoan`, and `convex.pending`
`stakedU*(ix-paid)` — the reward-debt accumulator, which is F7 then F1.

**MISSING: 19.** These are the result.

| # | spec · definition | term | family that must be added |
|---|---|---|---|
| 1 | `L1/compound_v3.absorb` | `col * collPrice` | N2 mark-to-market |
| 2 | `L1/morpho_blue.liquidate` | `seizedCol * collPrice` | N2 |
| 3 | `L1/morpho_blue.liquidate` | `(seizedCol * collPrice) * 10000` | N2 |
| 4–6 | `L3/gmx.increaseLong`, `.increaseShort`, `.oiCovered` | `poolAmount * markPrice` | N2 |
| 7 | `L3/gmx.oiCovered` | `impactPool * markPrice` | N2 |
| 8–10 | `L6/polymarket.tradeYes` (×3) | `yesAmt * price` | N2 |
| 11 | `L2/liquity.redeem` | `(boldAmt * WAD) / price` | N2, inverse |
| 12 | `L5/derive.openOption` | `qty * MAINT_PER_SHORT` | N2, per-unit margin |
| 13 | `L1/uniswap_v2.mint` | `(reserve0 + a0) * (reserve1 + a1)` | N1 trading function |
| 14 | `L1/uniswap_v2.burn` | `(reserve0 - a0) * (reserve1 - a1)` | N1 |
| 15 | `L3/apex.swapOut` | `y * dx` | N1 |
| 16 | `L3/apex.addLiquidity` | `baseIn * reserveQuote` | N1 |
| 17–19 | `L1/curve.approxD` | `2 * min(x,y)`, `amp * 2`, `((ann*S) + prodTerm)/(ann+1)` | N1, StableSwap `D` |
| 20 | `L3/huma.depositSenior` | `MAX_SENIOR_RATIO * max(1, tranches.junior)` | N4 tranche subordination |

Three distinct families, and the diagnosis for each is different.

**N2 — valuation application, `(A, P) → V`.** Nine of the nineteen. `P` contains
F6, *valuation source*, signature `() → (P)`: it produces a price. **Nothing in
`P` consumes one.** Mark-to-market — the step from a quantity and a price to a
value — is the single most common operation in the corpus and it is not a
family. L1 and L3 noticed and added `collValue` and `positionValue` to their
commons; both are rebadged `*`, which is why the strict check rejects them. This
is a genuine missing primitive and it is not exotic.

**N1 — trading function.** Seven. Constant product and StableSwap `D` are the
rule by which a pool quotes a price. `P` has no such family. F8, *payoff*, is
`(P) → (A)`: it consumes a price. N1 *produces* one from reserves. `curve.approxD`
is the extreme case: a Newton iteration solving an implicit invariant, with no
counterpart anywhere in the eight.

**N4 — tranche subordination.** One, `huma.depositSenior`, enforcing
`senior ≤ k · junior`. L3's common already carries `totalTranche`, `applyLoss`,
`applyProfit`, `seniorFirstRedeem` — a complete waterfall family that `P` does
not contain.

## 5. The converse check, which is worse

Running generation forward asks whether the specs stay inside the basis. The
converse asks whether the *basis* stays inside `P`. I classified all **183**
distinct operators declared across the six `common.qnt` files:

| | count |
|---|---|
| realise a family of `F1..F8` | 101 |
| neutral kernel (`min`, `max`, `abs`, `WAD`, `RAY`, `BPS`, scale constants) | 8 |
| sum-type constructors | 17 |
| **outside `P` entirely** | **57** |

Fifty-seven lane primitives — 31% — belong to no family of `P`. They fall into
ten groups: **N1** swap (3), **N2** mark-to-market (3), **N3** utilization rate
curve (2), **N4** tranche (4), **N5** custody/escrow/wrap (12), **N6** once-only
delivery (2), **N7** limit order with partial fill (6), **N8** delegated
authority (6), **N9** the plain transfer/mint/burn ledger (14), **N10**
authorization and allowances (5).

N1, N2 and N4 were rediscovered independently by the forward check. The other
seven never appear in the forward residue for a mechanical reason: their content
is relational, not arithmetic, so the `Π_hard` test cannot see them — a custody
wrap and a delegation grant are both `put` into a map. This is reading (c)'s
blind spot, and it means 57 is a floor on the shortfall, not a ceiling.

## 6. Independence

For each family, is some operator realising it irreducible over the others plus
plumbing, with `Π_hard` banned?

| family | ops | verdict |
|---|---|---|
| F1 pro-rata | 26 | independent (21 irreducible; `mulDivDown` needs raw `*`,`/`) |
| F2 deferred claim | 19 | **dependent — no independent term content** |
| F3 rate limit | 17 | independent (8; `currentLimit` needs raw `*`) |
| F4 conservation | 15 | independent (1; `supplyConserved` via `sumMap`) |
| F5 health | 11 | independent (9; `isHealthy`, `collateralRatio`, `seizeCollateral`) |
| F6 valuation source | 2 | **dependent — no independent term content** |
| F7 index accrual | 17 | independent (11; `accrueIndex`, `accrueByIndex`) |
| F8 payoff | 7 | independent (3; `redeemPayout` needs raw `*`) |

F2 and F6 fail. Every F2 operator — `canRequest`, `applyRequest`, `canClaim`,
`applyClaim`, `enqueue`, `headReady` — is a record update and a comparison: pure
plumbing. F6's two operators post an exogenous number. **Neither has any term
content at all.** Under reading (c) they are not primitives and must be dropped.

I do not think they should be dropped, and this is the honest limit of my
reading. F2's content is that the claim is *deferred* — a temporal separation
between request and settlement, invisible in a term and visible in a transition
system. F2 is a family under (b) and not under (c). F6 is weaker still: "a price
arrives from outside" is a signature, not a mechanism.

## 7. Verdict

**`P` does not generate the corpus.**

Of 51 formalised protocols: **27 generated outright**, **14 more generated once
inlined basis calls are re-folded** — 41 of 51 — and **10 not generated at any
reading**: `compound_v3`, `curve`, `morpho_blue`, `uniswap_v2`, `liquity`,
`apex`, `gmx`, `huma`, `derive`, `polymarket`. Uniswap V2 and Curve are not
edge cases; they are the two largest AMMs in the corpus, and both fail on the
trading function.

The refutation condition is met, and the refuting objects are named: the 19
subterms of §4. The basis must gain at least **N1 trading function**, **N2
valuation application**, and **N4 tranche subordination**, and the converse
check says at least seven more — N3, N5, N6, N7, N8, N9, N10 — are needed for
`B_ℓ` itself to be a `P`-realisation.

Two scope facts must not be buried. The corpus names 72 applications and only
51 have specs; the theorem is untested on 21, and one of the untested is
**Steakhouse Financial**, whose mechanism is exactly N8, delegated allocation
authority. It is a $3.08B application in the corpus that `P` does not generate,
and formalising it is not needed to see that. Second, F2 and F6 fail
independence under the reading I chose, so `P` as stated is neither complete
nor irredundant.

This is a positive result. The eight families cover 101 of 183 lane primitives
and 41 of 51 protocols. Ten named families close the gap. **The basis is
`F1, F3, F4, F5, F7, F8` (six, independent) plus `N1..N10`, with F2 and F6
readmitted only under a transition-system reading** — sixteen to eighteen
families, not eight, and now with an exact list of what each must do.

===== END FILE =====

===== FILE research/positive-program/basis/REFUTATION.md | SHA256 3f71b469688f1562048eed475b2984a79e5aba52eea59437438d40b9bff44f68 =====
# REFUTATION — adversarial attack on the completeness of `P = {F1..F8}`

The attack that works is not "here is an exotic protocol." It is: **every family in `P`
is an operation on scalars held per account, and the eight of them are closed under
composition of such operations. A large, deployed, structurally coherent half of DeFi
consists of operations whose argument is the *ledger as an ordered set* — argmin,
sort, match, clear — and no composite of scalar operations produces one.**

Four survivors, ranked. Then the candidates I killed, including several the brief
nominated. Then the minimal repair.

---

## R1 — Endogenous price formation by matching (STRONGEST)

**The mechanism.** `GPv2Settlement.settle(tokens, clearingPrices, trades, interactions)`
(`/root/DefiElements/protocol-repos/intent/cowprotocol_contracts/src/contracts/GPv2Settlement.sol:115-132`,
`computeTradeExecutions` at :286-313). A solver submits a *uniform clearing price vector*
`p` over the batch's token set. Every order `i` in the batch is a signed limit
`(sell_i, buy_i, limitSell_i, limitBuy_i)`; the settlement is valid iff each order's
limit inequality holds *at the common `p`* and the batch nets to zero across all
tokens. Same shape: 1inch LOP's remaining-invalidator fills
(`/root/DefiElements/protocol-repos/intent/1inch_limit-order-protocol`), Polymarket's
CTF Exchange (`/root/DefiElements/protocol-repos/pred/Polymarket_ctf-exchange-v2`),
Lighter's proven price-time book, Kalshi's CCP match-and-novate (L6 §7,
"Novation / clearing house … no symbol").

**Why `P` does not generate it.** `P` has exactly two ways a price can exist. `F6` is
`() → (P)`: an *exogenous* source, read. `F4` lets a price be recovered from scalar
reserve state — the AMM route, `p = ∂Φ/∂x` for a pool invariant `Φ(x,y)`. Both are
functions of **bounded arity over protocol-held state**. A clearing price is neither.
It is the solution of a *feasibility problem over an unbounded multiset of private
declarations that are not protocol state at all* — the orders are off-chain signatures,
the batch composition is chosen by the solver, and `p` must simultaneously satisfy `n`
inequalities where `n` is unbounded. No finite composite of `F1..F8` has a signature
that can even *accept* that argument, let alone produce `p`. The distinguishing
property: **the output is jointly determined by the declared preferences of an
unbounded set of parties, and existence of an output is a constraint-satisfaction
question, not an evaluation.** An AMM always has an answer; a batch may have none.

`F4` cannot be stretched to cover it without conceding the non-degeneracy failure
below: "conservation" would have to mean "any solver-supplied witness satisfying any
predicate", at which point `F4` alone generates everything and `P` says nothing.

**Verdict: genuine refuter.** And it is not a corner case. `P` is a basis for
*pool-shaped* DeFi. Order-driven DeFi — CLOBs, batch auctions, RFQ, intent solvers,
clearing houses — is roughly the other half of the field by volume and is absent from
the basis entirely. The lanes saw this and it was dropped: L4 §5 records
`BATCH_CLEARING` and `SIGNED_ORDER_REMAINING` as candidate primitives, L3 §6 splits
`Ob` four ways (`Ob-AMM` / `Ob-CLOB-proven` / `Ob-CLOB-consensus` / `Ob-none-pool`),
and none of it survived into `F1..F8`.

---

## R2 — Extremal selection over the ledger (Liquity V2 redemption priority)

**The mechanism.** Liquity V2 (`/root/DefiElements/protocol-repos/cdp/liquity_bold`).
Each borrower *sets their own* `annualInterestRate` on their trove. `SortedTroves.sol`
maintains the troves in a doubly-linked list ordered by that rate. `TroveManager.
redeemCollateral` (:747-841) begins at `sortedTrovesCached.getLast()` and walks
upward, consuming troves **lowest-rate-first** until the redemption amount is filled
(:770, :783, :807). The borrower's rate choice is therefore not a credit price — it is
a *bid for position in a queue of systemic liability* (L2 §7, "Borrower-chosen
interest = redemption priority").

**Why `P` does not generate it.** This is an exact invariance argument, and it is the
cleanest refutation in this document. `F1`, the pro-rata share ledger, is **symmetric
under permutation of equal claimants**: two holders of equal shares are affected
identically by every `F1` action, because the allocation rule is proportional.
Composition preserves that symmetry pointwise. `F5` can *break* symmetry, but only
by a **pointwise predicate**: "every position with health < 1 is liquidable" is a test
each position passes or fails independently of the others.

Liquity's rule is neither. The set of troves redeemed is the minimal prefix of the
*global rate order* whose total debt covers the redemption size. Whether your trove is
touched depends on **how many other troves are cheaper and how large they are** — the
cut-off is `argmin` over an unbounded set, determined endogenously by the size of the
incoming redemption. That is a sort, not a predicate. No composite of pointwise
predicates and permutation-symmetric allocations computes a prefix of a total order.

Same structure, independently recorded: Huma's senior-first redemption waterfall
(L3 §7, "`Tr` names waterfall, not leverage bound"), Sky's descending `clip` auction
(L2 §6, `Li-descending-auction`), Lighter's priority queue, Maple's FIFO withdrawal
queue. `F2` (deferred claim) supplies the *delay* but carries no *discipline* — FIFO,
pro-rata rationing and price-priority are three different machines under one signature
`(K) → (K@later)`.

**Verdict: genuine refuter.** Structurally the same missing primitive as R1 — see the
repair — but worth stating separately, because it shows the gap is not confined to
exchanges. It sits in the middle of a CDP.

---

## R3 — Commitment-carrier ledgers (Lighter desert mode; shielded pools)

**The mechanism.** `/root/DefiElements/protocol-repos/perp/elliottech_lighter-contracts`,
`IZkLighterDesertMode` + `IDesertVerifier`. The L1 contract holds `totalDeposited` and
a state *root*. It does not hold anyone's balance. When the operator misses a priority
request deadline, anyone may set an irreversible mode bit; thereafter users exit by
submitting a Merkle proof of their leaf against the last committed root. Sharper and
outside the corpus: Railgun / Aztec / Privacy Pools, where the claim carrier is a
commitment tree plus a nullifier set — there is no account map at all, and "who owns
what" is not a question the contract can answer.

**Why `P` does not generate it.** Every family in `P` presupposes that the construction
can *read* the ledger. `F1` maps assets to a claim held at an index. `F4`'s conservation
law is a boundary condition on `A` and `K` — to state it you must be able to sum `K`.
Under a commitment carrier the construction cannot read a single balance and cannot
compute the sum; **its own solvency invariant is not expressible in its own state.**
What replaces it is: an accumulator, a one-time-spend set, and a verification relation
that *accepts a proof about state it does not have*. That is a different kind of object
— possession of a witness, not possession of a quantity.

The honest counterweight: the *observable balance behaviour* of the composite (deposit
in, prove, withdraw) is `F1`-shaped, so an extensional reading may say it is generated.
The refutation bites on the intensional claim the paper actually needs — that the
construction's invariants are theorems of `P`. Here they are theorems of the circuit,
which is not in `P`.

**Verdict: genuine refuter of the invariant claim; contested on pure behaviour.**

---

## R4 — Babylon: enforcement authority created by the fault

**The mechanism.** `/root/DefiElements/protocol-repos/lsd/babylonlabs-io_babylon`,
`CreateBTCDelegation`. The protocol holds nothing. The stake is a Bitcoin UTXO under a
Taproot script tree with a timelock path, a covenant unbonding path, and a slashing
path. Slashing is a **pre-signed transaction** whose completion requires the finality
provider's key — and that key is *extracted* from an EOTS double-signature. The fault
manufactures the secret that authorises the penalty (L2 §7: "enforcement is adaptor-
signature completion, not an on-protocol state write").

**Why `P` does not generate it.** `F5` is `(K, K*, P) → (V)`: an evaluator produces a
verdict, and a seizure action is gated on it. Babylon has no evaluator and no gate.
There is no state variable whose value is "slashable"; there is a *capability* that
either exists in someone's hands or does not, and it comes into existence as a
by-product of misbehaviour. `P` has no primitive whose output is a permission, and no
carrier in which authority is a first-class, pre-committable, transferable object.

**Verdict: genuine refuter of `F5`'s account of enforcement; the balance arithmetic
around it is generated.** Ranked below R1–R3 because it can be argued down to "`F5`
with the fault as the valuation source" by anyone willing to make `F6` accept
arbitrary witnesses.

---

## Candidates I killed

- **EigenLayer slashability magnitude budget** (the brief's headline nominee).
  Dissolves. `maxMagnitude` is a **quota** — `F3` with slope zero (no refill); the
  deallocation delay is `F3` composed with `F2`; slashing's proportional burn of
  deposit shares is `F1`. That a single action updates two ledgers at once is
  composition, not a new primitive. "Conserved liability orthogonal to shares" is a
  second application of `F3`+`F4`, not a ninth family.
- **Convex permanent one-way lock.** Dissolves immediately. `F1`'s signature includes
  both directions; a construction is free to expose `(A)→(K)` and omit `(K)→(A)`.
  Omission is not a mechanism.
- **Polymarket complementary outcome split.** Dissolves. `1 collateral → 1 YES + 1 NO`
  is `F4` over two claim ledgers; redemption is `F8` on a discrete-valued `F6`
  (the UMA resolution). The dispute-reset is just a non-monotone `F6`; nothing in
  `F6` promised monotonicity. The *exchange* around it is R1 — that is where
  Polymarket actually escapes.
- **Uniswap v4 deferred net settlement.** Mostly dissolves. "Signed deltas sum to zero
  at scope close" is `F4` on a transaction-scoped carrier; adding a carrier is free.
  The residue — that the invariant is *bracketed* rather than holding in every state,
  so temporary insolvency is legal — is real but is a statement about when `F4` is
  checked, expressible as a mode.
- **crvUSD soft-liquidation bands (LLAMMA).** Dissolves, conditionally. In the
  arbitraged limit the collateral fraction is a function of the current oracle price:
  `F8`, `(P) → (A)`. The hysteresis on round trips is a loss term, not a new family.
- **Lighter desert as such / register-of-record duality (BUIDL, USYC).** The duality
  dissolves behaviourally: transfer-agent supremacy is an admin write on `F1`. Its real
  consequence is that the composite has *no* invariants — degenerate, not ungenerated.
  Lighter survives only through R3's commitment carrier.
- **Superfluid-style continuous streaming** (outside corpus). Dissolves. `balance(t) =
  b₀ ± r·Δt` is `F3`'s envelope arithmetic with the cap removed and the sign flipped.
  A quota and a balance differ in role, not in behaviour.

**One meta-observation the adversary is obliged to record.** The kills above lean hard
on `F4`. If `F4` means "any invariant `Φ` you like, and the action is whatever saturates
it", then `F4` alone generates `F1` (`Φ` = shares/assets), `F5` (`Φ` = health), `F7`
(`Φ` monotone) and every AMM curve — and `P` has Post's `⊤` problem. Note also that
`CONSTANT_PRODUCT_SWAP` is L1's most-instantiated candidate primitive (6 protocols) and
appears nowhere in `F1..F8`; it is currently being absorbed by exactly this unrestricted
reading of `F4`. The generation theorem must fix a restricted grammar for `Φ` *before*
it can claim any of my kills.

---

## The minimal addition to `P`

R1 and R2 are one missing primitive. Add:

> **`F9` — Allocation rule.** `Multiset(D) × ≼ → (Fill, P)`. Takes a finite multiset of
> declarations `D = {(party, size, limit)}` and a total preorder `≼` on `D`, and returns
> a fill vector plus a settlement price, such that (i) each filled declaration satisfies
> its own limit inequality at `P`, (ii) the fill is aggregate-conserving, and (iii) the
> filled set is **`≼`-extremal** among feasible fills.

Instances: `≼` trivial and the fill proportional gives pro-rata rationing; `≼` by price
gives uniform-price batch clearing (CoW) and CLOB matching; `≼` by borrower-set rate
gives Liquity redemption; `≼` by arrival gives FIFO queues; `≼` by descending price over
time gives Sky's `clip` auction; `≼` by tranche seniority gives Huma's waterfall.

The constructive payoff is larger than a ninth family. **`F1` is the `≼`-trivial,
permutation-symmetric instance of `F9`.** Pro-rata is not primitive; it is the
*anonymous* allocation rule. If the paper adopts `F9` it loses a primitive as well as
gaining one, which is exactly what an independence argument is supposed to do — and it
brings the order-driven half of DeFi inside the basis instead of leaving it outside,
unnamed, in six separate lane ledgers.

===== END FILE =====

===== FILE research/positive-program/evidence/gen_chunk3.py | SHA256 e971b4c91087c7393a72b9e8bc4bca031f9851083b059ded5c5dd2f9cebd3589 =====
# -*- coding: utf-8 -*-
import json, re, collections
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


BASE = str(_REPO / "paper/kg-corpus/")
VOCF = BASE + "formal-01-the-instantiated-vocabulary-and-constraints.md"
VOC  = "kg_corpus_formal_01_the_instantiated_vocabulary_and_constraints"
ATLF = BASE + "atlas-37-validation.md"
ATL  = "kg_corpus_atlas_37_validation"
S13F = BASE + "supp-13-the-instantiated-vocabulary-and-constraints.md"
S13  = "kg_corpus_supp_13_the_instantiated_vocabulary_and_constraints"
S00F = BASE + "supp-00-preamble.md"
S00  = "kg_corpus_supp_00_preamble"

nodes = []
edges = []
seen_nodes = set()
seen_edges = set()

def N(nid, label, ftype, src, rationale=None):
    if nid in seen_nodes:
        return nid
    seen_nodes.add(nid)
    n = {"id": nid, "label": label, "file_type": ftype, "source_file": src,
         "source_location": None, "source_url": None, "captured_at": None,
         "author": None, "contributor": None}
    if rationale:
        n["rationale"] = rationale
    nodes.append(n)
    return nid

def E(s, t, rel, conf, score, src, w=1.0):
    k = (s, t, rel)
    if k in seen_edges or s == t:
        return
    seen_edges.add(k)
    edges.append({"source": s, "target": t, "relation": rel, "confidence": conf,
                  "confidence_score": score, "source_file": src,
                  "source_location": None, "weight": w})

# ---------------------------------------------------------------- elements
ELEMENTS = [
 ("Sh","Pro-rata share accounting","G01",0),
 ("Ix","Index-based accrual","G01",0),
 ("Rb","Rebasing accounting","G01",0),
 ("Cp","Constant-product invariant","G02",1),
 ("Wg","Weighted-geometric invariant","G02",1),
 ("St","Stable-hybrid invariant","G02",1),
 ("Cl","Concentrated liquidity","G02",1),
 ("Pm","Oracle-priced inventory curve","G02",1),
 ("Ob","On-chain order book","G03",1),
 ("Rf","Request for quote","G03",1),
 ("Ba","Batch-auction clearing","G03",2),
 ("In","Intent & solver execution","G03",4),
 ("Ag","Aggregation & routing","G04",1),
 ("Fl","Atomic flash liquidity","G04",1),
 ("Pl","Pooled lending","G05",3),
 ("Im","Isolated lending market","G05",3),
 ("Cd","Collateralized-debt minting","G05",3),
 ("Uc","Undercollateralized credit","G05",3),
 ("Ft","Fixed-term debt","G05",3),
 ("Ct","Collateral-threshold test","G06",3),
 ("Li","Incentivized liquidation","G06",3),
 ("Ad","Auto-deleveraging","G06",3),
 ("Sl","Socialized-loss allocation","G06",3),
 ("Bs","Staked backstop","G06",3),
 ("Pf","Perpetual funding transfer","G07",3),
 ("Op","Option payoff","G07",3),
 ("Tr","Tranche waterfall","G07",3),
 ("Cv","Mutual cover pool","G07",3),
 ("Py","Principal/yield separation","G07",3),
 ("Sv","Servicing & determination discretion","G07",3),
 ("Dp","Directional position & hedge maintenance","G07",3),
 ("Ex","External data oracle","G08",2),
 ("Tp","Time-weighted price","G08",2),
 ("Oa","Optimistic assertion oracle","G08",2),
 ("At","Reserve / NAV attestation","G08",2),
 ("Sr","Streaming accrual","G09",2),
 ("Ep","Epoch-gated transition","G09",2),
 ("Wq","Withdrawal queue","G09",2),
 ("Em","Protocol-funded emissions","G10",2),
 ("Fd","Surplus & fee distribution","G10",2),
 ("Tg","Delayed-governance execution","G11",4),
 ("Up","Mutable implementation proxy","G11",4),
 ("Gp","Guardian or pause","G11",4),
 ("Au","Delegated execution scope","G11",4),
 ("Gs","Sponsored-fee liability","G11",3),
 ("Xm","Cross-domain message verification","G12",4),
 ("Xf","Cross-domain asset transfer","G12",4),
 ("Rl","Resource lock / reservation","G12",4),
 ("Of","Optimistic fill & reimbursement","G12",4),
 ("Rd","Direct redemption right","G13",3),
 ("Ps","Peg-swap module","G13",3),
 ("As","Algorithmic supply adjustment","G13",3),
 ("Aw","Permission / identity gate","G14",2),
 ("Sb","Shielded-balance state","G14",2),
 ("Sd","Selective-disclosure proof","G14",2),
 ("Fz","Freeze / forced transfer","G14",2),
 ("Rs","Restaking / shared security","G15",4),
 ("Vl","Staking & validator lifecycle","G16",3),
]
assert len(ELEMENTS) == 58, len(ELEMENTS)

def eid(sym):
    return VOC + "_" + sym.lower()

groups = collections.OrderedDict()
for sym, name, grp, strat in ELEMENTS:
    groups.setdefault(grp, []).append(sym)

N(VOC + "_instantiated_vocabulary_tables",
  "The instantiated vocabulary and constraints (58 elements, 29 requirement rows, 27 warrant entries, 20 prohibition rows)",
  "concept", VOCF,
  "The authoritative tables the checking scripts read: 58 elements with group and stratum, 29 recorded requirement rows, the warrant consumer relation over 27 elements, and 20 listed prohibition rows. Reproduced verbatim so a witness can be checked without the repository.")

for grp, members in groups.items():
    N(VOC + "_" + grp.lower(), "Element group " + grp, "concept", VOCF,
      "group=" + grp + "; members=" + ",".join(members))
    E(VOC + "_" + grp.lower(), VOC + "_instantiated_vocabulary_tables",
      "references", "EXTRACTED", 1.0, VOCF)

for sym, name, grp, strat in ELEMENTS:
    N(eid(sym), sym + " - " + name, "concept", VOCF,
      "group=%s; stratum=%d" % (grp, strat))
    E(eid(sym), VOC + "_" + grp.lower(), "implements", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- requirements
# term = (ext_flag, [alternatives])
REQS = {
 "L1": (["Pl","Im","Cd","Pf","Op"], [(0,["Ex","Tp","At"]),(0,["Ct"]),(0,["Li","Ad","Sl","Bs"])]),
 "L2": (["Pl"], [(0,["Sh","Ix"]),(1,[])]),
 "L3": (["Uc"], [(0,["Aw"]),(0,["At"]),(0,["Bs","Tr"]),(1,[])]),
 "L4": (["Pf"], [(0,["Ex"]),(0,["Ct"]),(0,["Li"]),(0,["Ad","Sl","Bs"])]),
 "L5": (["Py"], [(0,["Sh","Ix","Rb"]),(0,["Ep"]),(0,["Rd"])]),
 "L6": (["Tr"], [(1,["Sv"]),(1,[]),(1,[]),(1,[])]),
 "L7": (["Cd"], [(1,["Rd","Ps"])]),
 "L8": (["Xf"], [(1,["Xm"])]),
 "L9": (["Xf"], [(1,[])]),
 "L10": (["Sb"], [(1,[]),(1,[])]),
 "L11": (["Sd"], [(1,[]),(1,[]),(1,[])]),
 "L12": (["In"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L13": (["Ex"], [(1,[])]),
 "L14": ([], [(1,["Wq"])]),
 "L15": (["Up"], [(1,["Tg"])]),
 "L16": (["Aw"], [(1,[])]),
 "L17": (["Au"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L18": (["Xm"], [(1,[]),(1,[]),(1,[])]),
 "L19": (["Of"], [(0,["Xm"]),(0,["Xf"]),(0,["Bs","Sl"]),(1,[])]),
 "L20": (["Rl"], [(0,["Au"]),(1,[]),(1,[]),(1,[]),(1,[])]),
 "L21": (["Gs"], [(0,["Au"]),(1,[]),(1,[])]),
 "L22": (["Rs"], [(1,[]),(1,[]),(1,[])]),
 "L23": ([], [(0,["Xm"]),(1,[])]),
 "L24": (["In","Rf","Ba"], [(1,[])]),
 "L25": ([], [(1,[]),(1,[]),(1,[])]),
 "L26": ([], [(1,[]),(1,[]),(1,[])]),
 "L27": (["At"], [(1,[]),(1,[]),(1,[]),(1,[]),(1,[])]),
 "L28": (["Fz"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L29": (["In","Ba","Rf","Of"], [(1,[])]),
}
assert len(REQS) == 29

fully_empty_rows = []
for rid in ["L%d" % i for i in range(1, 30)]:
    subs, terms = REQS[rid]
    n_terms = len(terms)
    empty = [i+1 for i,(x,alts) in enumerate(terms) if x == 1 and not alts]
    ext_with_el = [i+1 for i,(x,alts) in enumerate(terms) if x == 1 and alts]
    rat = "requirement row %s; subjects=%s; %d term(s). " % (
        rid, ",".join(subs) if subs else "NONE (no subject element recorded)", n_terms)
    if len(empty) == n_terms:
        rat += ("unformalized: %d of %d terms are [ext] () with no element alternatives - "
                "the whole row is external natural language and names no element in any term."
                % (len(empty), n_terms))
        fully_empty_rows.append(rid)
    elif empty:
        rat += ("unformalized: %d of %d terms are [ext] () with no element alternatives "
                "(terms %s are external natural language naming no element); the remaining "
                "terms do name elements." % (len(empty), n_terms, ",".join(map(str, empty))))
    else:
        rat += "every term names at least one element alternative; no empty [ext] term."
    if ext_with_el:
        rat += (" Terms %s are marked [ext] but still offer element alternatives."
                % ",".join(map(str, ext_with_el)))
    if not subs:
        rat += " The subject column is blank: the row is triggered by no named element."
    N(VOC + "_" + rid.lower(), "Requirement row " + rid, "concept", VOCF, rat)
    E(VOC + "_" + rid.lower(), VOC + "_instantiated_vocabulary_tables",
      "references", "EXTRACTED", 1.0, VOCF)
    for s in subs:
        E(VOC + "_" + rid.lower(), eid(s), "references", "EXTRACTED", 1.0, VOCF)
    for x, alts in terms:
        for a in alts:
            E(VOC + "_" + rid.lower(), eid(a), "references", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- warrants
WARRANTS = {
 "Ad": ["Ct","Pf","Ob"],
 "As": ["Ex","Tp","Oa","At"],
 "Bs": ["Pl","Im","Cd","Uc","Pf","Op","Rs","Vl","In","Of","Xm","Xf","Cv","Tr","Ob","Ct","Sl","Rl","Ba","Ft","Wq"],
 "Cd": ["Sh","Ix","Rb","Rd","Ps","As"],
 "Ct": ["Pl","Im","Cd","Uc","Ft","Pf","Op","Dp","Tr","Cv","Rs","Vl","Pm","Ob","Fl","Rd"],
 "Cv": ["Pl","Im","Cd","Uc","Bs","Sh"],
 "Ex": ["Ct","Li","Ad","Pf","Op","Pm","Cd","Pl","Im","Uc","Ft","As","Ps","Rd","Tr","Cv","Sl","Bs","Vl","Dp","Py","Sv","Rl","Oa","Rs","Sr","Cl","St","Wg","Cp","Ob","Of","In"],
 "Fl": ["Cp","Cl","St","Wg","Pm","Pl","Im","Cd","Ob","Ag","Sh","Ix"],
 "Ft": ["Sh","Ix","Rb","Py","Ep","At","Sv","Uc","Tr"],
 "Gs": ["Au","Ob","In","Rl","Aw"],
 "Im": ["Sh","Ix","Rb","Ct"],
 "Li": ["Ct"],
 "Of": ["Xf","In","Rl","Xm"],
 "Op": ["Ct","Ob","Ex","Sh","Rf","Pm","Cl"],
 "Pf": ["Ct","Ob","Pm","Ex"],
 "Pl": ["Sh","Ix","Rb"],
 "Ps": ["At","Cd","Rd","Xf","Fz","Aw","Ix","Sr"],
 "Py": ["Ix","Sh","Rb","Ft"],
 "Rb": ["Sh","Ix","Vl","Pl","Im","Cd","Ps","Rd"],
 "Rl": ["In","Xf","Xm","Of","Au","Ob","Rf"],
 "Sl": ["Pl","Im","Cd","Uc","Ft","Pf","Op","Tr","Cv","Rs","Vl","Ob","Dp","Bs","Ct","Xf","Xm"],
 "Sv": ["Tr","Pl","Im","Uc","Ft","Cv","Op","Cd","Rl","Sh","Ep","Wq"],
 "Tp": ["Cp","Cl","St","Wg","Pm","Ob"],
 "Tr": ["Pl","Im","Uc","Ft","Cd","Cv","Rs","Vl","Sh","Ix","Sv","Dp"],
 "Uc": ["Sh","Ix","Rb","Ft"],
 "Vl": ["Rs","Bs","Sl","Sh","Wq","Ep","Rb","Ix","Xf","Ob"],
 "Xm": ["Xf","Rs","In","Of","Rl","Vl","Ob","Sb","Up","Tg","Gp"],
}
assert len(WARRANTS) == 27

for sym, cons in WARRANTS.items():
    wid = VOC + "_warrant_" + sym.lower()
    N(wid, "Warrant entry: " + sym + " consumers", "concept", VOCF,
      "warrant/consumer entry for %s; consumers=%s; an element present with no consumer "
      "among these is unwarranted." % (sym, ",".join(cons)))
    E(wid, eid(sym), "references", "EXTRACTED", 1.0, VOCF)
    E(wid, VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)
    for c in cons:
        E(eid(sym), eid(c), "shares_data_with", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- prohibitions
PROHIB = [
 ("X1","F","As + reflexive junior token, with no hard redemption or exogenous capital",["As"]),
 ("X2","H","Fl* + manipulable Cp/Cl price + Pl/Cd, where manipulation cost < position value",["Fl","Cp","Cl","Pl","Cd"]),
 ("X3","H","Protocol token as collateral AND oracle market AND backstop",[]),
 ("X4","F","Rb into a balance-invariant ledger with no adapter",["Rb"]),
 ("X5","H","Illiquid backing + uncapped instant par redemption",[]),
 ("X6","H","Borrowable voting power + immediate execution",[]),
 ("X7","H","Cross-domain mint whose verifier is present but unproven correct",[]),
 ("X8","H","Shared collateral across nominally isolated markets",[]),
 ("X9","H","Up with immediate single-key control",["Up"]),
 ("X10","H","Pm with a stale reference and unrestricted inventory",["Pm"]),
 ("X11a","F","Uc with no Aw, At, collateral or reputation",["Uc","Aw","At"]),
 ("X11b","H","Uc with all of them and weak underwriting",["Uc"]),
 ("X12","F","Lock-mint wrapped asset as canonical collateral whose value at risk exceeds the bridge's economic security",[]),
 ("X13","H","External-validator Xm securing value exceeding slashable stake",["Xm"]),
 ("X14","U","Exclusive market structure plus a price-improvement claim with no named benchmark",[]),
 ("X15","H","Rs securing a bridge mostly with assets issued by that bridge",["Rs"]),
 ("X16","H","Unbounded delegated authority, or unlimited token approvals",[]),
 ("X17","H","Passive protocol-token reserve backing protocol-token collateral",[]),
 ("X18","H","Oa as sole truth for high-frequency liquidation",["Oa"]),
 ("X19","F","Restricted claim bridged via Xf into a representation with no destination-side Aw",["Xf","Aw"]),
]
assert len(PROHIB) == 20
CONDITIONAL = ["X2","X18","X19","X21","X11a"]

for pid, cls, desc, els in PROHIB:
    rat = "prohibition row %s; class=%s; forbidden configuration: %s. " % (pid, cls, desc)
    if els:
        rat += "names element(s) %s in its forbidden configuration." % ",".join(els)
    else:
        rat += ("unformalized: this row is a prose description of a forbidden configuration and "
                "names no element symbol at all - nothing in it is stated in the vocabulary.")
    if pid in CONDITIONAL:
        rat += " Evaluated by the operational (conditional) predicate rather than as a listed row alone."
    N(VOC + "_" + pid.lower(), "Prohibition row " + pid, "concept", VOCF, rat)
    E(VOC + "_" + pid.lower(), VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)
    for e_ in els:
        E(VOC + "_" + pid.lower(), eid(e_), "references", "EXTRACTED", 1.0, VOCF)

N(VOC + "_x21", "Prohibition row X21", "concept", VOCF,
  "prohibition row X21 is named as one of the conditional rows evaluated by the operational "
  "predicate, and is ARMED by the Uniswap witness (Fl carried with Xf), but it does not appear "
  "in the table of 20 listed prohibition rows (which runs X1..X19 with X11a/X11b split). "
  "unformalized/unlisted: its forbidden configuration is stated nowhere in the reproduced tables, "
  "so the row names no element here.")
E(VOC + "_x21", VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)

# supp-13 restatement
N(S13 + "_restated_vocabulary_tables",
  "Supplement restatement of the instantiated vocabulary and constraints",
  "concept", S13F,
  "Section 13 of the supplement reproduces the formal-data tables verbatim: the same 58 elements "
  "with the same groups and strata, the same 29 requirement rows including every [ext] () empty "
  "term, the same 27 warrant entries and the same 20 prohibition rows. No row differs from "
  "formal-01; it is a duplicate printing so a reader can check a witness in place.")
E(S13 + "_restated_vocabulary_tables", VOC + "_instantiated_vocabulary_tables",
  "references", "EXTRACTED", 1.0, S13F)

N(S00 + "_sixty_protocol_profiles", "Sixty protocol profiles (supplement)", "concept", S00F,
  "For each of the sixty protocols the supplement records the construction exhibited for it, its "
  "canonical form ex(X), the verdict of the admissibility test, how many recorded obligations the "
  "construction discharges, and every obligation no element of the vocabulary names (the residue).")

# ---------------------------------------------------------------- protocols
SUPP = {
 1: ("kg_corpus_supp_01_spot_exchange", BASE + "supp-01-spot-exchange.md"),
 2: ("kg_corpus_supp_02_lending", BASE + "supp-02-lending.md"),
 3: ("kg_corpus_supp_03_collateraliseddebt_stablecoins", BASE + "supp-03-collateraliseddebt-stablecoins.md"),
 4: ("kg_corpus_supp_04_liquid_staking_and_restaking", BASE + "supp-04-liquid-staking-and-restaking.md"),
 5: ("kg_corpus_supp_05_perpetual_futures", BASE + "supp-05-perpetual-futures.md"),
 6: ("kg_corpus_supp_06_yield_vaults_and_aggregators", BASE + "supp-06-yield-vaults-and-aggregators.md"),
 7: ("kg_corpus_supp_07_bridges", BASE + "supp-07-bridges.md"),
 8: ("kg_corpus_supp_08_intents_and_aggregation", BASE + "supp-08-intents-and-aggregation.md"),
 9: ("kg_corpus_supp_09_tokenised_realworld_assets", BASE + "supp-09-tokenised-realworld-assets.md"),
 10: ("kg_corpus_supp_10_options_and_structured_products", BASE + "supp-10-options-and-structured-products.md"),
 11: ("kg_corpus_supp_11_reservebacked_stablecoins", BASE + "supp-11-reservebacked-stablecoins.md"),
 12: ("kg_corpus_supp_12_prediction_markets", BASE + "supp-12-prediction-markets.md"),
}

def slug(s):
    return re.sub(r"_+", "_", re.sub(r"[^a-z0-9]+", "_", s.lower())).strip("_")

# (section, name, slug, take-set, verdict-rationale, cause-list)
# cause entries: ("L","L1","Ex|Tp|At") open term, or ("X","X19","armed"), or ("W","Gs","unwarranted")
P = [
 (1,"Curve","curve","Ag,Em,Fd,Gp,Sh,St,Tg,Tp",
  "admissible: no requirement term open, every element warranted, arms no prohibition; discharges 8 of 22 recorded obligations, 14 residue; every element primitive in the canonical form.",[]),
 (1,"Fluid","fluid","Cl,Cp,Ct,Ex,Gp,Li,Pl,Sh,Tg,Tp,Up",
  "admissible; discharges 11 of 22 obligations, 11 residue; {Ct} derived rather than chosen; not minimal - {Cp} removable.",[]),
 (1,"PancakeSwap","pancakeswap","Cl,Cp,Em,Fl,Gp,Ix,Sh,St",
  "admissible; discharges 9 of 22 obligations, 13 residue; not minimal - {Cl} removable. Up dropped (core stated immutable), Gp added (one-directional PausableRole).",[]),
 (1,"Raydium","raydium","Cl,Cp,Em,Gp,Ix,Sh,Tp,Up",
  "admissible; discharges 8 of 22 obligations, 14 residue; not minimal - {Cl} removable. Fd dropped: value return is accumulation, not distribution to a claim class.",[]),
 (1,"Uniswap","uniswap","Cl,Cp,Fl,Ix,Sh,Tg,Tp,Xf",
  "NOT admissible: it arms X21 (Fl carried together with Xf); discharges 10 of 22 obligations, 12 residue. The flash path lives inside a pool settlement scope and the burn path on a bridge days later, and an element set cannot say the two never meet.",[("X","X21","armed")]),

 (2,"Aave V3","aave_v3","Aw,Ct,Ex,Fd,Fl,Gp,Ix,Li,Pl,Rb,Tg,Up,Xm",
  "admissible; discharges 12 of 23 obligations, 11 residue; {Ct} derived; not minimal - {Rb,Tg,Xm} removable. Bs, Cd, Em, Im, Sl dropped under cite-or-drop; Aw added for the address-keyed administrative gate.",[]),
 (2,"JustLend V1","justlend_v1","Aw,Ct,Ex,Gp,Ix,Li,Pl,Sh,Tg,Up",
  "admissible; discharges 10 of 18 obligations, 8 residue; {Ct} derived; not minimal - {Sh} removable. The control of its category: no bounded delegate anywhere in the tree.",[]),
 (2,"Maple","maple","Aw,Bs,Ct,Fd,Ft,Gp,Pl,Sh,Sl,Sv,Tg,Up,Wq",
  "NOT admissible: leaves the requirement term L1:Ex|Tp|At open - the pool manager holds no oracle and valuation is a human act performed off chain; discharges 10 of 23 obligations, 13 residue.",[("L","L1","Ex|Tp|At")]),
 (2,"Morpho","morpho","Aw,Ct,Ex,Fd,Gp,Im,Ix,Li,Pl,Sh,Sl,Tg",
  "admissible; discharges 11 of 24 obligations, 13 residue; {Ct} derived; not minimal - {Pl,Ix,Sl} removable. Em, Fl and Sv dropped; Sv would name a mechanism the protocol does not have.",[]),
 (2,"SparkLend","sparklend","Aw,Ct,Ex,Fl,Gp,Ix,Li,Pl,Rb,Tg,Up",
  "admissible; discharges 8 of 24 obligations, 16 residue; {Ct} derived; not minimal - {Pl,Rb,Up,Tg} removable. Price of credit is read live out of another protocol's accumulator.",[]),

 (3,"Ethena","ethena","At,Aw,Bs,Dp,Em,Fz,Gp,Ix,Rd,Rf,Sh,Sr,Tr,Wq,Xf",
  "admissible; discharges 13 of 22 obligations, 9 residue; not minimal - {Sh,Ix,Bs,Em} removable. A hedged synthetic dollar: no credit element, no collateral test, no liquidation path.",[]),
 (3,"Liquity","liquity","Bs,Cd,Ct,Em,Ep,Ex,Fd,Li,Rd,Sl",
  "admissible; discharges 9 of 22 obligations, 13 residue; {Ct} derived; not minimal - {Em,Fd} removable. L7's credit term satisfied by the redemption right alone; no peg-swap anywhere.",[]),
 (3,"Lista","lista","As,Cd,Ct,Em,Ex,Gp,Ix,Li,Ps,Sl,Wq",
  "admissible; discharges 12 of 20 obligations, 8 residue; {Ct} derived. The borrow rate is a closed-loop controller; no element names it.",[]),
 (3,"Sky","sky","Aw,Cd,Ct,Em,Ex,Fd,Gp,Ix,Li,Ps,Sh,Sl,Tg,Tr,Up,Xf",
  "NOT admissible: it arms X19* (conditional restricted-claim/cross-domain row); discharges 15 of 24 obligations, 9 residue; {Ct} derived. L7 satisfied through the peg-swap alone - the issuer grants no direct claim on collateral.",[("X","X19","armed as X19*"),("L","L7","satisfied by Ps alone")]),
 (3,"USDD","usdd","Cd,Ct,Ex,Gp,Ix,Li,Ps,Sh,Sl",
  "admissible; discharges 9 of 17 obligations, 8 residue; {Ct} derived; not minimal - {Sh} removable. The smallest CDP construction: five corpus elements dropped for want of a primary source, control plane UNKNOWN rather than absent.",[]),

 (4,"Babylon","babylon","Aw,Bs,Em,Ep,Fd,Ix,Rs,Sl,Xm",
  "admissible; discharges 11 of 22 obligations, 11 residue; not minimal - {Bs,Sl,Em,Fd} removable. The protocol holds nothing; Wq dropped because each delegation unbonds on its own Bitcoin timelock.",[]),
 (4,"Binance staked ETH","binance_staked_eth","Fz,Gp,Ix,Rd,Up,Wq",
  "admissible; discharges 7 of 16 obligations, 9 residue; not minimal - {Rd,Wq} removable. Vl inapplicable rather than approximate: no validator action of any kind occurs on chain. At deliberately not claimed - the unmet warrant is the finding.",[]),
 (4,"EigenLayer","eigenlayer","Aw,Bs,Ep,Fd,Gp,Rs,Sh,Sl,Up,Wq,Xm",
  "admissible; discharges 12 of 21 obligations, 9 residue; not minimal - {Bs,Sl,Wq,Fd,Up} removable. The conserved magnitude budget over slashability has no symbol.",[]),
 (4,"ether.fi","ether_fi","Aw,Ep,Ex,Fd,Fz,Gp,Ix,Rb,Rd,Rs,Sh,Sl,Tg,Up,Wq",
  "admissible; discharges 14 of 25 obligations, 11 residue; not minimal - {Ix,Ex,Ep,Rd,Sl,Tg,Up,Gp} removable. Tr and Bs dropped; the priced on-chain auction for the right to operate has no element.",[]),
 (4,"Lido","lido","Aw,Bs,Cd,Ct,Ep,Ex,Fd,Gp,Ix,Rb,Rd,Sh,Sl,Tg,Up,Wq",
  "admissible; discharges 16 of 24 obligations, 8 residue; {Ct} derived; not minimal - {Ix,Cd,Ep,Wq,Sl,Tg,Up,Gp} removable. Vl deliberately not used: it names the category rather than any mechanism.",[]),

 (5,"ApeX","apex","Ad,Au,Ct,Ex,Fd,Li,Ob,Pf,Sh,Xf,Xm",
  "admissible; discharges 12 of 22 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Xf,Xm} removable. Bs dropped: no insurance fund is documented anywhere.",[]),
 (5,"Aster","aster","Ad,Bs,Ct,Em,Ex,Li,Ob,Pf,Sb,Sd,Sh,Sv,Tp,Vl,Xf,Xm",
  "admissible; discharges 15 of 26 obligations, 11 residue; {Ct,Ex,Li} derived; not minimal - {Tp,Vl,Em,Xf,Xm} removable. The corpus rejection on the open loss-absorption term disappears; the departure is a correction of the record.",[]),
 (5,"edgeX","edgex","Ct,Ex,Li,Ob,Pf,Up,Xf",
  "NOT admissible: leaves the requirement term L4:Ad|Sl|Bs open - the venue documents no loss-absorption mechanism at all; discharges 9 of 18 obligations, 9 residue; {Ct,Ex,Li} derived. An undocumented mechanism and an absent one are different things the vocabulary cannot tell apart.",[("L","L4","Ad|Sl|Bs")]),
 (5,"Hyperliquid","hyperliquid","Ad,Ct,Ep,Ex,Gp,Li,Ob,Pf,Sh,Sl,Tp,Vl,Wq,Xf,Xm",
  "admissible; discharges 15 of 25 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Tp,Sl,Ep,Wq} removable. Bs dropped: HLP is unbonded, unslashable depositor capital, so Sl carries the loss-absorption term.",[]),
 (5,"Lighter","lighter","Ad,Aw,Ct,Em,Ex,Fd,Gp,Li,Ob,Pf,Rf,Sh,Sl,Tg,Tp,Up,Xf,Xm",
  "admissible; discharges 17 of 24 obligations, 7 residue; {Ct,Ex,Li} derived; not minimal - {Pf,Tp,Sl,Sh,Em,Fd,Tg,Up} removable. That the deployment can be checked against its source is invisible to every element.",[]),

 (6,"CIAN Yield Layer","cian_yield_layer","Aw,Ct,Ex,Fl,Gp,Ix,Sh,Up,Wq",
  "admissible; discharges 9 of 19 obligations, 10 residue. The strategy is not an element the vocabulary failed to name - it is not on the chain to be named. Em dropped, Aw added.",[]),
 (6,"Convex Finance","convex_finance","Em,Ep,Fd,Gp,Ix,Rd,Sh,Sr",
  "admissible; discharges 8 of 18 obligations, 10 residue; not minimal - {Sh,Rd} removable. The vocabulary can name mutability and cannot assert immutability.",[]),
 (6,"Huma Finance V2","huma_finance_v2","Aw,Bs,Ep,Fd,Ft,Gp,Sh,Sv,Tr,Uc,Wq",
  "NOT admissible: leaves the requirement term L3:At open AND arms X11a* - undercollateralised credit with no attestation to name; discharges 12 of 24 obligations, 12 residue; {Aw} derived.",[("L","L3","At"),("X","X11a","armed as X11a*")]),
 (6,"Pendle","pendle","Em,Ep,Fd,Ft,Gp,Ix,Py,Rd,Sh,Up,Wq",
  "admissible; discharges 11 of 21 obligations, 10 residue; {Ep,Rd} derived; not minimal - {Gp,Up} removable. The only application in the corpus carrying Py; residue is mechanism rather than discretion.",[]),
 (6,"Spark Savings","spark_savings","Aw,Ex,Gp,Ix,Ps,Rd,Sh,Sr,Tg,Up,Xf,Xm",
  "admissible; discharges 12 of 21 obligations, 9 residue; not minimal - {Sh,Ix,Sr,Ex} removable. The authority terms name the facilities, never the envelope.",[]),

 (7,"BTCB","btcb","Rd,Xf",
  "NOT admissible: it is ungrounded; discharges 2 of 15 obligations, 13 residue. The smallest construction in the category: issuance unbounded and unilateral from one externally-owned account, with no element weak enough to say so.",[]),
 (7,"Coinbase Bridge","coinbase_bridge","Aw,Fz,Gp,Rd,Up,Xf",
  "admissible; discharges 6 of 18 obligations, 12 residue. X9 (Up under immediate single-key control) cannot be evaluated because its antecedent - that the holder is a single key - is unstateable in the vocabulary.",[]),
 (7,"Hyperliquid Bridge","hyperliquid_bridge","Gp,Gs,Vl,Wq,Xf,Xm",
  "NOT admissible: leaves the requirement term L21:Au open AND {Gs} has no consumer present, i.e. it is unwarranted; discharges 7 of 19 obligations, 12 residue. The law behind Gs demands a user-granted delegation and the user grants nothing.",[("L","L21","Au"),("W","Gs","unwarranted")]),
 (7,"LayerZero V2","layerzero_v2","Au,Gs,Xf,Xm",
  "admissible; discharges 6 of 18 obligations, 12 residue; {Au} derived. Up, Gp and Tg all dropped on direct reads of the endpoint; verification is a per-application parameter the element cannot express.",[]),
 (7,"WBTC","wbtc","Aw,Gp,Rd,Xf",
  "NOT admissible: it arms X19*; discharges 4 of 19 obligations, 15 residue. The vocabulary has an element for delayed execution and none for authority that is shared but immediate.",[("X","X19","armed as X19*")]),

 (8,"Binance Wallet","binance_wallet","Ag,Aw,Up",
  "admissible; discharges 3 of 19 obligations, 16 residue. Rf and Gs both dropped for want of a primary source; the thinness is the evidence. The vocabulary has four symbols for how an order is matched and none for who owns the flow.",[]),
 (8,"Jupiter","jupiter","Ag,Aw,Gs,In",
  "NOT admissible: leaves the requirement term L21:Au open; discharges 4 of 20 obligations, 16 residue. That this venue routes to routers is a containment relation the carrier cannot state.",[("L","L21","Au")]),
 (8,"KyberSwap","kyberswap","Ag,Au,Ep,Fd,In,Rf,Xf",
  "admissible; discharges 6 of 20 obligations, 14 residue; not minimal - {Fd,Ep,Xf} removable. Exclusivity over a venue is not the same obligation as routing to one.",[]),
 (8,"LiquidMesh","liquidmesh","Ag,Au,Aw,Up",
  "admissible; discharges 6 of 20 obligations, 14 residue. Identical decomposition to another venue whose residue is disjoint - a sharper statement of non-identifiability than a collision on its own.",[]),
 (8,"OKX DEX","okx_dex","Ag,Au,Aw,Gs,In,Rf,Xf",
  "NOT admissible: it arms X19*; discharges 7 of 19 obligations, 12 residue; {Au} derived. Ba explicitly refused: many solvers bidding on one order is not a uniform price over a batch.",[("X","X19","armed as X19*")]),

 (9,"BlackRock BUIDL","blackrock_buidl","Aw,Fz,Gp,Rd,Sh,Up",
  "admissible; discharges 6 of 19 obligations, 13 residue. The smallest construction in the category; At, Ps and the cross-domain elements all removed. The witness arms a prohibition the corpus recorded as unarmed (single-key proxy owner).",[("X","X9","single-key upgrade path")]),
 (9,"Centrifuge","centrifuge","Au,Aw,Ep,Ex,Fz,Gp,Rd,Sh,Sv,Tg,Up,Xf,Xm",
  "admissible; discharges 11 of 22 obligations, 11 residue; not minimal - {Ex,Rd,Sv,Tg,Up} removable. Tr dropped: seniority, subordination and waterfall appear nowhere in the source.",[]),
 (9,"Circle USYC","circle_usyc","At,Aw,Ex,Fz,Gp,Ix,Rd,Sh,Sv,Up,Xf",
  "admissible; discharges 9 of 20 obligations, 11 residue; not minimal - {At,Ex,Fz,Gp,Sv} removable. Ps refused: an asymmetric NAV mint-and-redeem teller is the structural opposite of a par swap.",[]),
 (9,"Maple Finance","maple_finance","Aw,Ct,Fd,Ft,Gp,Pl,Sh,Sl,Sv,Tg,Up,Wq,Xf,Xm",
  "NOT admissible: leaves the requirement term L1:Ex|Tp|At open - the solvency test runs off chain against price feeds nothing on chain can see; discharges 10 of 22 obligations, 12 residue; {Ct} derived. The only member of the RWA category whose register of record is the token ledger.",[("L","L1","Ex|Tp|At")]),
 (9,"Ondo Finance","ondo_finance","At,Aw,Ex,Fz,Gp,Ix,Ps,Rb,Rd,Rf,Sh,Sv,Tg,Up,Xf,Xm",
  "admissible; discharges 13 of 23 obligations, 10 residue; not minimal - {Ex,Sv,Tg,Up,Xf,Xm} removable. Tr dropped: sponsor equity behind the whole issue is not a subordinated class of tokens.",[]),

 (10,"Aevo","aevo","Ad,Ct,Ex,Fd,Li,Ob,Op,Pf,Rf,Xf,Xm",
  "admissible; discharges 10 of 21 obligations, 11 residue; {Ct,Ex,Li} derived; not minimal - {Pf,Xf,Xm} removable. One of two rejections in the category that turn out to be decomposition artefacts: restoring Ct and Ad closes the term and the rejection disappears.",[]),
 (10,"Derive","derive","Ct,Em,Ex,Fd,Ix,Li,Ob,Op,Pf,Rf,Sl,Up,Xf,Xm",
  "admissible; discharges 12 of 22 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Fd,Ix,Pf,Xf,Xm} removable. Bs refused: a treasury that cannot be slashed does not answer to a bond, so Sl carries the term.",[]),
 (10,"Hegic","hegic","Bs,Ep,Ex,Fd,Gp,Op,Sh",
  "NOT admissible: leaves the requirement term L1:Ct open; discharges 7 of 15 obligations, 8 residue. A balance-sheet inequality checked at write time and a threshold test evaluated while a position is open are different mechanisms with the same purpose, and the vocabulary names only the second.",[("L","L1","Ct")]),
 (10,"Panoptic","panoptic","Cl,Ct,Fd,Gp,Ix,Li,Op,Pl,Sh,Sl,Sr,Tp",
  "admissible; discharges 13 of 23 obligations, 10 residue; {Ct} derived; not minimal - {Sh} removable. The second decomposition artefact: an on-chain time-weighted price is a price and a risk engine is a threshold test, and the rejection disappears with them.",[]),
 (10,"Rysk","rysk","At,Ep,Ex,Gp,Op,Rf,Sh,Sv,Up,Wq",
  "NOT admissible: leaves the requirement terms L1:Ct and L1:Li|Ad|Sl|Bs open; discharges 8 of 20 obligations, 12 residue. The sharpest case of a requirement discharged BY CONSTRUCTION - escrowing the maximum payoff makes those obligations unable to arise, and the constraint language reads that as unspecified. The repair is to the constraint language, not the vocabulary.",[("L","L1","Ct"),("L","L1","Li|Ad|Sl|Bs")]),

 (11,"Circle USDC","circle_usdc","At,Au,Aw,Fz,Gp,Rd,Up,Xf,Xm",
  "admissible; discharges 9 of 24 obligations, 15 residue; not minimal - {Xf,Xm} removable. Au added for signed transfer authorisations; Ps dropped. Disclosure quality does not change the decomposition.",[]),
 (11,"Global Dollar USDG","global_dollar_usdg","At,Au,Aw,Ep,Fd,Fz,Gp,Rd,Sh,Tg,Up",
  "admissible; discharges 10 of 23 obligations, 13 residue; not minimal - {Ep,Fd,Sh} removable. The vocabulary records that a timelock is present and that a freeze is present; it cannot record that they are the same single key and that the delay does not cover the freeze.",[]),
 (11,"PayPal USD","paypal_usd","At,Au,Aw,Fz,Gp,Rd,Up",
  "admissible; discharges 8 of 22 obligations, 14 residue; not minimal - {Rd} removable. Cross-domain elements removed for want of a primary source; shares its freeze key with another issuer in the same category.",[]),
 (11,"Tether USDT","tether_usdt","At,Aw,Fz,Gp,Rd,Up",
  "admissible; discharges 6 of 22 obligations, 16 residue; not minimal - {Aw} removable. Ps dropped: no on-chain module performs a par exchange. A power used constantly and a power never used are recorded identically.",[]),
 (11,"USD1","usd1","At,Au,Aw,Fz,Gp,Rd,Up,Xf,Xm",
  "admissible; discharges 9 of 23 obligations, 14 residue; not minimal - {Aw,Rd,Xf,Xm} removable. The two cross-domain elements added on a live canonical-issuance path break the corpus identity claim with Tether.",[]),

 (12,"Azuro","azuro","Au,Aw,Fd,Gp,Gs,Rd,Rl,Up",
  "admissible; discharges 7 of 19 obligations, 12 residue; {Au} derived; not minimal - {Gs,Gp} removable. The corpus carried Rl with no Au, making this the only protocol in the corpus rejected on a WARRANT - an element present that nothing consumes - rather than on a requirement alone; the witness repairs it with Au and Gs.",[("W","Rl","corpus carried Rl with no Au: rejected on a warrant"),("L","L20","Au")]),
 (12,"Grove Finance","grove_finance","At,Aw,Fd,Gp,Ix,Ps,Sh,Tg,Xf",
  "admissible; discharges 8 of 20 obligations, 12 residue; not minimal - {Sh,Ix} removable. Au declined; the linearly refilling per-key rate limit is the most load-bearing on-chain control and the vocabulary has no flow limiter at all.",[]),
 (12,"Kalshi","kalshi","Ad,Aw,Bs,Ct,Fd,Gp,Pf,Rd,Sl",
  "NOT admissible: leaves the requirement terms L1:Ex|Tp|At, L4:Ex and L4:Li open; discharges 9 of 22 obligations, 13 residue; {Ct} derived. Every element that could close the truth term requires a feed, a price series or an independent attester, and the truth source here is a committee. Nothing in the vocabulary is a counterparty-substitution (novation) operator.",[("L","L1","Ex|Tp|At"),("L","L4","Ex"),("L","L4","Li")]),
 (12,"Polymarket","polymarket","Au,Aw,Ct,Fd,Gp,Gs,Oa,Ob,Ps,Rd,Up",
  "admissible; discharges 12 of 20 obligations, 8 residue; {Au} derived. Oa kept although its shape fits badly; splitting collateral along the STATE space of a condition has no element, the only splitting element partitioning a claim along time.",[]),
 (12,"Steakhouse Financial","steakhouse_financial","Ct,Fd,Gp,Im,Rd,Sh,Tg",
  "NOT admissible: leaves the requirement terms L1:Ex|Tp|At and L1:Li|Ad|Sl|Bs open; discharges 7 of 17 obligations, 10 residue; {Ct} derived. The vault computes no price and absorbs no loss - both are properties of the markets underneath it - and the carrier has no way to record an obligation discharged one level down.",[("L","L1","Ex|Tp|At"),("L","L1","Li|Ad|Sl|Bs")]),
]
assert len(P) == 60, len(P)

prot_ids = {}
for sec, name, sl, take, verdict, causes in P:
    stem, sfile = SUPP[sec]
    pid = stem + "_" + sl
    cid = pid + "_construction"
    prot_ids[(sec, sl)] = pid
    N(pid, name, "concept", sfile, verdict)
    E(pid, S00 + "_sixty_protocol_profiles", "references", "EXTRACTED", 1.0, sfile)
    syms = take.split(",")
    N(cid, name + " exhibited construction", "concept", sfile,
      "exhibited construction X = {" + ", ".join(syms) + "}. " + verdict)
    E(pid, cid, "implements", "EXTRACTED", 1.0, sfile)
    for s in syms:
        E(cid, eid(s), "shares_data_with", "EXTRACTED", 1.0, sfile)
    for kind, ref, note in causes:
        if kind == "L":
            E(pid, VOC + "_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)
        elif kind == "X":
            E(pid, VOC + "_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)
        else:
            E(pid, VOC + "_warrant_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)

# ---------------------------------------------------------------- named residue themes
THEMES = [
 (2, "bounded_delegated_mandate", "Bounded delegated mandate (the five-part mandate)",
  "The recurring residue shape across categories: an agent, an enumerated domain of parameters it may write, a magnitude bound per update, a cooldown or refilling budget, and a revocation. Only the agent slot is nameable, and only by stretching Aw, which names who may send a transaction rather than who may move a parameter. Named at Aave V3 (the steward), Sky (the rate facilitator), SparkLend (keeper + liquidity controller), Spark Savings, Maple Finance and Steakhouse Financial. Across every instance the domain, the magnitude cap and the revocation are residue without exception.",
  ["Aw","Au","Tg"]),
 (6, "refilling_rate_limit_budget", "Refilling rate-limit budget (flow limiter)",
  "A per-key capacity that regenerates continuously with elapsed time, bounding how much value a privileged actor may move per unit time rather than how often it acts. Recurs at SparkLend, Spark Savings, ether.fi, Grove Finance, Circle USDC (minter allowance) and USDG (SupplyControl RateLimit). The vocabulary has no flow limiter at all; a schema with a single rate-of-change field records a cooldown and a refilling budget as the same guarantee.",
  ["Au","Tg","Gp"]),
 (10, "discharged_by_construction", "Discharged by construction",
  "An obligation that cannot arise because the design forecloses it - Rysk escrows the maximum payoff so no position can become under-secured, and Hegic checks a balance-sheet inequality at write time. The requirement language admits only one way to satisfy a term, naming an element, so it reads an obligation that cannot arise as an obligation left unspecified. The repair is to the constraint language rather than to the vocabulary.",
  ["Ct","Li","Bs","Sl","Ad"]),
 (1, "hook_extension_point_residue", "Hook / extension-point residue",
  "Third-party code in the settlement path whose permission set is bound differently at every protocol - mined into the hook's address at Uniswap, carried in the pool's own key at PancakeSwap, named as a controller address at Fluid. A symbol for hooks would first have to decide whether the permissions belong to the code or to the pool. Shared across the category's largest members and named by none of them.",
  ["Cl","Cp","Fl"]),
 (9, "register_of_record", "Register of record (chain versus book)",
  "Whether the token ledger IS the register of ownership or a mirror of a transfer agent's book, and which is authoritative on a conflict. BUIDL's books are authoritative over the chain; Centrifuge's token is prima facie evidence under BVI law; USYC's tokens are digital twins the administrator moves the register to match; Ondo answers three different ways across three products; Maple Finance is the only member whose register is the token ledger. Nothing in the vocabulary reaches the register.",
  ["Sh","Rd","Aw"]),
 (8, "protocol_containment_relation", "Containment between protocols (a protocol consuming another as a component)",
  "Composition in the paper is union of element sets between peers; one protocol consuming another as a component is a containment relation the carrier cannot state. Exhibited by Jupiter routing to rival routers, by Morpho vaults that are depositors in markets they do not control, by Convex exercising governance inside four foreign protocols, and by Steakhouse allocating across isolated markets one level down.",
  ["Ag","In","Pl","Im"]),
 (4, "vl_five_sub_mechanisms", "Vl's five sub-mechanisms",
  "Vl (staking & validator lifecycle) names the category rather than any mechanism, and the profiles decompose it into key registration and vetting, stake allocation and scheduling, deposit front-running defence, exit signalling, and penalty attribution - kept in separate contracts under separate failure modes at Lido, absent entirely at Binance staked ETH, and answered negatively at Babylon. Lido adds a sixth absent from the corpus: validator sizing, top-up and consolidation.",
  ["Vl","Rs","Sl","Bs","Wq"]),
 (5, "cite_or_drop", "Cite-or-drop discipline",
  "An element is carried only when a mechanism answers to it at a primary source, and dropped otherwise; dropping an unsupported element is the same discipline as adding a supported one. Applied against the corpus at ApeX (Bs), edgeX (four elements), Binance Wallet (Rf, Gs), Tether (Ps), PayPal USD (cross-domain), USDD (five elements) and LayerZero V2 (Up, Gp, Tg). An absence of evidence is recorded as UNKNOWN rather than as absence.",
  ["Bs","Ps","Up","Tg"]),
 (12, "novation_and_default_waterfall", "Novation and the mutualised default waterfall",
  "Counterparty substitution by a clearing house extinguishes a bilateral obligation and replaces it with obligations against the clearing house; nothing in the vocabulary is a counterparty-substitution operator, and Rd names a right to be paid and carries no obligor. Kalshi's capped operator tranches and callable member assessments have no symbol either, so the vocabulary reconstructs the mutualised middle of the waterfall and neither end.",
  ["Rd","Bs","Sl","Ad"]),
 (3, "price_of_credit_residue", "The price of credit",
  "The level and shape of a borrow or savings rate: a two-slope curve and its write-time bounds at Aave, a per-block rate at JustLend, a bilateral contract term at Maple, a closed-loop controller at Lista and Morpho, a live read of another protocol's accumulator at SparkLend, a written number at Sky and Spark Savings, a borrower-chosen rate that doubles as redemption priority at Liquity. No element names a rate, so protocols with identical element sets differ in setter, bound, latency and controlling party.",
  ["Ix","Pl","Cd","Sr"]),
]
for sec, sl, label, rat, rel_syms in THEMES:
    stem, sfile = SUPP[sec]
    tid = stem + "_" + sl
    N(tid, label, "rationale", sfile, rat)
    E(tid, S00 + "_sixty_protocol_profiles", "references", "EXTRACTED", 1.0, sfile)
    for s in rel_syms:
        E(tid, eid(s), "conceptually_related_to", "INFERRED", 0.85, sfile)

# ---------------------------------------------------------------- validation measurements
MEAS = [
 ("clause_widths", "Measurement: clause widths",
  "In the CNF encoding of admissibility the widest clause has 34 literals and 20.4% of clauses are bijunctive; the system is therefore not preserved by the majority operation and is not median-closed, though the bijunctive fragment is.", []),
 ("exhaustive_to_size_three", "Measurement: exhaustive to size three",
  "Over all 172,431,735 pairs from R of size at most three, 0 fail intersection-closure and 0 fail union-closure. Intersection-closure nevertheless fails; the smallest witness has five elements: {Ct,Ex,Li,Pl,Sh} and {Ct,Li,Pl,Sh,Tp} both satisfy the law while their intersection {Ct,Li,Pl,Sh} leaves L1 unsatisfied. The exhaustive range is too small to exhibit the failure, not evidence against it.",
  ["Ct","Ex","Li","Pl","Sh","Tp"]),
 ("lattice_confluence", "Measurement: lattice confluence",
  "Over 175,230 pairs from R intersect W there are 0 union-closure violations. Meet is not intersection: about 44,000 pairs have X intersect Y outside R intersect W.", []),
 ("vacuous_iteration", "Measurement: vacuity of the iteration",
  "On synthetic operators of the present shape the iteration was sound 2000/2000 and exact 2000/2000 with zero slack. On the actual Gamma, Delta it is sound and VACUOUS: x_infinity = top on every seed at 10, 20 and 58 elements, exact in 0 of 18 seed-instances, slack 1-58. The synthetic operators admitted a Delta that removes at top; ours structurally cannot.", []),
 ("no_invariance", "Measurement: no invariance",
  "Exhaustively over the 224,025 members of R of size at most four, Delta leaves R on 116.", []),
 ("downward_closure", "Measurement: which prohibitions cost downward closure",
  "Over the 16,384 subsets of a 14-element universe containing every element occurring in a prohibition, 15,872 model the listed clutter and NONE has a subset that does not: H is downward closed, as a purely negative clause set requires. Under the full prohibition predicate (listed rows together with the conditional ones), 6,580 subsets are prohibition-free and 1,708 of them have a subset that is not. The smallest witness is {Oa,Li,Ex}, which arms X18 on the removal of Ex.",
  ["Oa","Li","Ex"]),
]
N(ATL + "_validation", "Validation (computational checks on the implementation)", "rationale", ATLF,
  "These computations confirm that the implementation behaves as the definitions require. None is a statement about the subject, and no result in the body depends on one except where it is cited.")
for sl, label, rat, syms in MEAS:
    mid = ATL + "_" + sl
    N(mid, label, "rationale", ATLF, rat)
    E(mid, ATL + "_validation", "references", "EXTRACTED", 1.0, ATLF)
    for s in syms:
        E(mid, eid(s), "references", "EXTRACTED", 1.0, ATLF)
E(ATL + "_exhaustive_to_size_three", VOC + "_l1", "references", "EXTRACTED", 1.0, ATLF)
E(ATL + "_downward_closure", VOC + "_x18", "references", "EXTRACTED", 1.0, ATLF)

# ---------------------------------------------------------------- semantic similarity
SIM = [
 (VOC + "_l17", VOC + "_l20", 0.85, VOCF),
 (VOC + "_l17", VOC + "_l12", 0.75, VOCF),
 (VOC + "_l25", VOC + "_l26", 0.85, VOCF),
 (VOC + "_x11a", VOC + "_l3", 0.85, VOCF),
 (eid("Rd"), eid("Ps"), 0.75, VOCF),
 (eid("Bs"), eid("Sl"), 0.75, VOCF),
 (eid("Tg"), eid("Au"), 0.65, VOCF),
 (prot_ids[(2,"maple")], prot_ids[(9,"maple_finance")], 0.95, SUPP[9][1]),
 (prot_ids[(5,"hyperliquid")], prot_ids[(7,"hyperliquid_bridge")], 0.95, SUPP[7][1]),
 (prot_ids[(10,"aevo")], prot_ids[(10,"derive")], 0.85, SUPP[10][1]),
 (prot_ids[(2,"sparklend")], prot_ids[(6,"spark_savings")], 0.85, SUPP[6][1]),
 (prot_ids[(3,"sky")], prot_ids[(2,"sparklend")], 0.75, SUPP[2][1]),
 (prot_ids[(11,"circle_usdc")], prot_ids[(9,"circle_usyc")], 0.75, SUPP[9][1]),
 (prot_ids[(8,"liquidmesh")], prot_ids[(8,"kyberswap")], 0.75, SUPP[8][1]),
 (prot_ids[(6,"cian_yield_layer")], prot_ids[(12,"steakhouse_financial")], 0.85, SUPP[12][1]),
 (prot_ids[(4,"babylon")], prot_ids[(4,"eigenlayer")], 0.85, SUPP[4][1]),
]
for a, b, sc, sf in SIM:
    E(a, b, "semantically_similar_to", "INFERRED", sc, sf)

# ---------------------------------------------------------------- hyperedges
hyper = [
 {"id": "unformalized_external_requirement_rows",
  "label": "Requirement rows whose every term is [ext] () - external natural language naming no element",
  "nodes": [VOC + "_" + r.lower() for r in fully_empty_rows] + [VOC + "_instantiated_vocabulary_tables"],
  "relation": "form", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
 {"id": "prose_only_prohibition_rows",
  "label": "Prohibition rows that are prose descriptions naming no element symbol",
  "nodes": [VOC + "_" + p.lower() for p in ["X3","X5","X6","X7","X8","X12","X14","X16","X17"]],
  "relation": "form", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
 {"id": "l1_credit_solvency_triad",
  "label": "L1: truth source, collateral test and loss absorption for pooled credit and derivatives",
  "nodes": [VOC + "_l1", eid("Ex"), eid("Tp"), eid("At"), eid("Ct"), eid("Li"), eid("Ad"), eid("Sl"), eid("Bs"),
            eid("Pl"), eid("Im"), eid("Cd"), eid("Pf"), eid("Op")],
  "relation": "participate_in", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
]

out = {"nodes": nodes, "edges": edges, "hyperedges": hyper,
       "input_tokens": 0, "output_tokens": 0}

path = r"C:\Users\charl\AppData\Local\Temp\claude\C--Users-charl\18d5fad3-3a32-41fe-a407-e0314fe4d324\scratchpad\chunk_03.json"
with open(path, "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=1)

ids = set(n["id"] for n in nodes)
missing = set()
for e in edges:
    if e["source"] not in ids: missing.add(e["source"])
    if e["target"] not in ids: missing.add(e["target"])
for h in hyper:
    for n_ in h["nodes"]:
        if n_ not in ids: missing.add(n_)
print("nodes", len(nodes), "edges", len(edges), "hyperedges", len(hyper))
print("fully empty requirement rows:", fully_empty_rows, len(fully_empty_rows))
print("missing node refs:", sorted(missing))

===== END FILE =====

===== FILE research/positive-program/sigma/GATE-3.1-GENERATION.md | SHA256 2f8bd7fb370f5875df22276052b8b3d533e0e6c829aff390b602a764c0b8507e =====
# Phase 3.1 — generation (status from honest corpus)

**Claim options (ROADMAP):**  
(A) `P` generates the corpus, or  
(B) the residue names the closure.

**Measured (Gate 2.3, repo-reproducible):** on the ten re-specs,

| | ungenerated defs | rate |
|---|---:|---:|
| v1 | 28 / 168 | **16.7%** |
| v2 | 119 / 716 | **16.6%** |

Source: `sigma/GATE-2.3-TEN.md`, `basis/denominators.py`, Sol APPROVE at `292dc55`.

**Disposition:** (A) is **false** on the measured slice. (B) is the live claim:
residue / ungenerated protocol definitions name the closure gap. Rate is flat
v1→v2 → gap is **coverage / missing generators**, not fixable by the ten
fidelity re-specs alone.

**Gate 3.1 status:** **MEASURED** (inherits 2.3). Do not re-claim generation
without a new corpus slice and re-run.

## What would strengthen 3.1

1. Re-run generation after absorbing 2.2's six new specs (out of historical ten).
2. Name residue families for the ungenerated IR nodes (link `RESIDUE-*.md`).

===== END FILE =====

===== FILE research/positive-program/sigma/QSIGMA-VERDICT.md | SHA256 c0d8a92104126fcf9dea04f41fb8e88969dd2114598a335245fda4fa714b8a98 =====
# Gate 0.1 — the Q/Sigma invariant, resolved

**Verdict: the invariant as stated in `BASIS.md` is FALSE, and `|P| = 4` should be
withdrawn. A weaker, true partition exists and is offered as the replacement.**

The gate asked for "a script produces a non-trivial partition, or `|P| = 4` is
withdrawn". A script now produces one (`sigma/qsigma5.py`, Q 334 / Sigma 54). It
does not rescue the claim, for the reasons below, so the second branch applies.

---

## 1. The gate was recorded FAILED for the wrong reason, for seven passes

The record says three good-faith operationalisations produced a trivial
partition. Two things are wrong with that.

**There were two, not three.** `sigma/qsigma3.py` is byte-identical to
`sigma/qsigma2.py` apart from its output filename — `diff` reports only lines
108 and 110, and the two JSON outputs have the same MD5
(`a992fcedd03efb82f4fe937c2222c553`). It is a copy, not an independent attempt.

**Both failures were a harness bug, not a fact about the corpus.** `qsigma2`
scans the whole file:

    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", src)

with no action scoping, so it reads `init`. `init` assigns every variable a
literal, a literal never mentions the variable, so **every variable scores
exactly one replacement and Q collapses to the empty set by construction.** The
tell was in qsigma2's own output all along: nearly every violation reads `1/N`,
and the quoted right-hand sides are `100`, `0`, `USERS.mapBy(_ => 0)`.

The claim is about the transition relation. At `init` there are no "prior `Q`s",
so it is vacuous there rather than false. `sigma/qsigma4.py` is `qsigma2` with
the initialiser excluded and nothing else changed; the partition becomes
non-trivial immediately.

**The shape is the one this phase keeps finding: the check failed because the
harness was wrong, and nobody re-ran it.** It is the mirror image of the other
seven — there, a check passed because the stressing states were removed; here, a
check failed because states that were never in scope were included.

---

## 2. One further defect, in my own first correction

`qsigma4`'s violation list reports its "actions" as `newSup()`, `minted()`,
`r1n()` — those are **local `val` bindings**, not actions, because the span
regex split on `val`. Worse, the replacement test does not follow them:

    val newSup = userSupplyScaled.put(u, ... userSupplyScaled.get(u) ...)
    userSupplyScaled' = newSup

is syntactically a replacement and semantically an update. `sigma/qsigma5.py`
resolves local bindings transitively before testing self-mention.

The direction of that correction was stated before it was measured: resolution
can only move variables Sigma -> Q, so it must raise "balances in Q" and lower
"prices in Sigma". It moved 34 variables and did exactly that.

| operationalisation | Q | Sigma | non-trivial | balances in Q | prices in Sigma |
|---|---|---|---|---|---|
| qsigma2 / qsigma3 (init included) | 0 | 388 | **no** | 0.0% | 0.0% |
| qsigma4 (init excluded) | 300 | 88 | yes | 86.0% | 42.9% |
| **qsigma5 (+ binding resolution)** | **334** | **54** | **yes** | **95.5%** | **36.5%** |

---

## 3. Why the non-trivial partition still does not save the claim

`BASIS.md` §1 makes a semantic prediction: balances and supplies are `Q`, prices
and rates and phases are `Sigma`, because "a `Sigma` may be overwritten by an
external writer, a `Q` never is".

Half of that is strongly borne out. **95.5% of balance/supply variables are
never replaced.** Of the seven exceptions, four (`unlocked`, `locked`,
`poolLocked`, and `uniswap_v4`'s `unlocked`) are reentrancy flags that the
name-bucketing heuristic miscounts as balances; they are not counterexamples.

The other half fails. **Only 36.5% of price/rate/phase variables are replaced.**
The paradigm `Sigma` — an accrual index — lands in `Q`, and for a principled
reason: `liquidityIndex`, `variableBorrowIndex`, `baseSupplyIndex`,
`borrowIndex`, `supplyIndex` and `rateMul` all evolve multiplicatively **from
their own prior value**, so every assignment mentions the variable and scores an
update. So do `basePrice`, `oraclePrice`, `price0`, `price1` and `price` in the
specs that ratchet rather than overwrite them.

That is not a measurement artifact to be tuned away. It is the finding: **"is
ever wholesale-overwritten" and "is exogenous" are different properties**, and
the corpus separates them. An index is exogenous in provenance and endogenous in
update form. `BASIS.md` needs the first and the script can only see the second.

---

## 4. The claim is refuted by the witness `BASIS.md` chose

`BASIS.md`:31-34 argues:

> Across all 57 specs no state variable of sort `Q` is ever assigned a value that
> is not an arithmetic term over prior `Q`s — even USDT's off-chain reserve moves
> only in lockstep (`reserve' = reserve + amount`, L6/usdt.qnt:51,68).

`L6/usdt.qnt` assigns `reserve` at **:31, :51, :68 and :157**. The citation names
51 and 68. Line 157 is

    reserve' = newReserve,

inside `attestReserve`, whose own comment at :148 reads *"Off-chain reserve
attestation update (no on-chain function — external)"*. That is a wholesale
overwrite by an external writer, which is `BASIS.md`'s own definition of a
`Sigma`.

The spec knew. Lines 191-192 document it:

> `inv_reserve_covers_if_honest`: holds only if attest is disabled from step.
> Documented failure: with `attestReserve` in step, `inv_reserve_covers` fails.

**The one witness offered in support of the invariant is a counterexample to it,
and the spec that hosts it says so two lines below.**

---

## 5. What to do

1. **Withdraw `|P| = 4` and the six-sort split.** They rest on a `Q`/`Sigma`
   asymmetry that does not survive being stated testably. This is the branch the
   gate always permitted, and Phase 1 has an independent estimate (~16 families)
   that never depended on it.
2. **Keep the partition, under an honest name.** The replacement/update split is
   real, reproducible, non-trivial (334/54) and sharp on one axis (95.5%). It is
   a statement about *update form*, not about *provenance*. If Phase 1 wants it,
   it must earn its place as a law with witnesses, like any other family.
3. **Do not attempt a sixth operationalisation to rescue the semantic reading.**
   Sections 3 and 4 are not a tuning problem. The accrual index is a genuine
   exogenous-provenance / endogenous-update variable, and no syntactic test on
   assignment form will separate provenance.

## Reproduce

    python3 sigma/qsigma2.py     # the empty-Q result, init included
    python3 sigma/qsigma4.py     # init excluded, partition becomes non-trivial
    python3 sigma/qsigma5.py     # + local binding resolution — the figures above
    diff sigma/qsigma2.py sigma/qsigma3.py   # lines 108 and 110 only
    grep -n "reserve" quint-models/L6/usdt.qnt

===== END FILE =====

===== FILE research/positive-program/sigma/gate33_cert_check.py | SHA256 79a486132e8f789aae2592c4dabfe92168577df79c78d43e08695dbd28d39b03 =====
#!/usr/bin/env python3
"""Linear-time certificate checker seed for Phase 3.3.

Walks gen-ir-v2ten, tags declaration names by P-keyword rules, writes a
certificate summary JSON + validates invariants:
  - every file has at least one tagged node OR is allowed-empty
  - tag set subset of {Led, Prop, Cmp, Post, OTHER}
Exit 0 on success.
"""
from __future__ import annotations

import json
import os
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IR = Path(os.environ["GEN_IR"]) if os.environ.get("GEN_IR") \
     else ROOT / "research/positive-program/sigma/gen-ir-v2ten"
OUT = ROOT / "research/positive-program/sigma/GATE-3.3-CERT-RESULT.json"

RULES = {
    "Led": [
        "credit", "debit", "transfer", "mint", "burn", "balance", "supply",
        "move", "deposit", "withdraw", "reallocate", "shares", "collateral",
    ],
    "Prop": ["muldiv", "sharesfrom", "assetsfrom", "ceildiv", "geometric", "prorata"],
    "Cmp": [
        "healthy", "canliquidate", "require", "guard", "safe", "ishealthy",
        "invariant", "canborrow", "canwithdraw",
    ],
    "Post": [
        "price", "oracle", "shock", "post", "index", "phase", "status",
        "confirm", "approve", "attest",
    ],
}


def tag_name(name: str) -> str:
    n = name.lower()
    best, score = "OTHER", 0
    for fam, kws in RULES.items():
        s = sum(1 for k in kws if k.lower() in n)
        if s > score:
            best, score = fam, s
    return best if score else "OTHER"


def collect_names(d) -> list[str]:
    names: list[str] = []

    def walk(o):
        if isinstance(o, dict):
            if isinstance(o.get("name"), str):
                names.append(o["name"])
            for v in o.values():
                walk(v)
        elif isinstance(o, list):
            for i in o:
                walk(i)

    walk(d)
    return names


def main() -> int:
    if not IR.is_dir():
        # A missing corpus is a blocked check, not a failed certificate.
        print("BLOCKED - missing IR", IR, file=sys.stderr)
        return 3
    files = {}
    total = Counter()
    for fp in sorted(IR.glob("*.json")):
        names = collect_names(json.loads(fp.read_text()))
        tags = Counter(tag_name(n) for n in names)
        files[fp.name] = dict(tags)
        total.update(tags)
    # Invariants
    allowed = {"Led", "Prop", "Cmp", "Post", "OTHER"}
    for fn, tags in files.items():
        for k in tags:
            if k not in allowed:
                print("FAIL: bad tag", k, "in", fn, file=sys.stderr)
                return 1
        if sum(tags.values()) == 0:
            print("FAIL: empty file", fn, file=sys.stderr)
            return 1
    # Zero certificates examined is not a passing certificate check.
    # Guard sits BEFORE the write so an empty IR leaves no PASS artefact.
    if not files:
        print("BLOCKED - no *.json under", IR, "; nothing was certified",
              file=sys.stderr)
        return 3
    result = {
        "status": "PASS",
        "ir": str(IR),
        "files": len(files),
        "totals": dict(total),
        "per_file": files,
        "note": "keyword certificate seed; not signature-level",
    }
    OUT.write_text(json.dumps(result, indent=2) + "\n")
    print("PASS", len(files), "files; totals", dict(total))
    print("wrote", OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

===== END FILE =====
