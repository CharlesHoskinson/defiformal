# Evidence packet usage contract (P15 task 16.4)

**Status:** author freeze, pending independent GPT-6 review  
**Schema:** `evidence-packet.schema.json`  
**This file is the scoring contract.** Schema validity is not acceptance.

One packet describes **one selected operation** (token0 helper, vault
deposit, or another later case). P16 and P17 should reuse this envelope.
This freeze does not implement a scheduler, certificate checker, or
semantic scorer.

## 1. Obligation classes (keep separate)

Every obligation in the packet must use exactly one class:

| Class | What it may claim | What it must not claim |
| --- | --- | --- |
| `model_proof` | Lean theorem over the model, with full premises and axiom evidence | Source fidelity, compiler correctness, certificate tags as proof |
| `bounded_source_execution` | Actual pinned-source and model runs over a predeclared nonempty matrix | Universal refinement, unexecuted tools, Python-only as production |
| `representation_correspondence` | Quantified representation-to-Lean result for a supported certificate/IR domain | Pinned-source refinement. Codec round-trips are not this class |
| `source_refinement` | Implementation-to-model refinement over related admissible states | Closed by encode/decode or by bounded samples alone |
| `authenticity_environment_assumption` | Explicit trust: compiler/runtime, authentication, observation truth, token/callback behavior | Silent omission of an assumption that scoring relied on |

An increment **may** ship as model-verified with bounded source differential
evidence and source refinement open. P16/P18 are expected to do that.
P30 remains required before full-program closure.

That publication of two classes does **not** close complete P16/P17
operational or source-bound operation acceptance. Complete operation
acceptance still requires the mutation and control evidence in §2–§4.

Certificates, if later delivered, first accept the repaired Typed/sequential
grammar and invoke actual Lean semantics. A caller judgment, source hash, or
theorem name is not proof. Certificates are **not** a P16 prerequisite.

## 2. Required bindings

Two credit levels apply. Do not treat a narrower class report as complete
operation acceptance.

**Complete P16/P17 operational or source-bound operation credit** requires
every item below. Missing actual characteristic production mutations **or**
independently verified unaffected controls leaves that complete-operation
packet incomplete or open. It does not become complete by omitting a
separate “mutation sensitivity” claim.

1. Exact **source** identity (revision, path, SHA-256). Compiler settings
   when the source is compiled. Observation relation id.
2. Exact **model** identity (module path, git revision, SHA-256).
3. Exact **tools** (binary path, version string, SHA-256 where available).
4. Supported input/state/observation relation (see adapter contract).
5. Relevant Lean **theorems**, full premises, and axiom evidence, or an
   explicit statement that the class is not a model_proof claim.
6. **Actual** pinned-source and model executions over predeclared nonempty
   partitions, including refusal behavior.
7. **Actual** characteristic production mutations **and** independently
   verified unaffected controls. Both are required. Neither is optional
   when claiming complete operation acceptance.
8. Independent exact-candidate **verdict** with requested/reported model
   identity, or `pending` with `credit_eligible=false`.
9. Explicit **remaining obligations**.

**Narrower evidence** remains reportable with explicit limitations:

- `model_proof` only
- `accepted_historical` pointers
- other class-bounded records that do not claim complete operation credit

Those records must keep `credit_eligible=false` for complete P16/P17
operation acceptance. They cannot close that gate.

## 3. Scoring rules the schema cannot prove

JSON Schema can reject some illegal shapes. It cannot prove Lean, cannot
run solc, and cannot accept a package. Apply these rules in review:

1. **Draft or illustrative packets cannot self-assert credit.**
   `packet_status` in `{illustrative, blocked, incomplete}` requires
   `credit_eligible=false`.
2. **Empty denominator is blocked, not success.** A partition with
   `count=0` or `nonempty=false` cannot contribute a passing score.
   A comparison printed as `0 of 0` is a blocked check (defi-footguns /
   GATE-REGISTER exit 3).
3. **Unexecuted tool path is not success.** If `denominators.executions.actually_run`
   is 0, `bounded_source_execution` must not be `independently_reviewed`
   as holding. Record `open` or `blocked`.
4. **Python-only mutation is not production mutation credit.**
   Compilation failure, timeout, or in-memory Python-only edit earns none.
5. **Missing production mutations or missing independently verified
   unaffected controls block complete operation acceptance.**
   If `denominators.mutations.compiled_production` is 0 **or**
   `denominators.mutations.unaffected_controls` is 0, a P16/P17 operation
   packet is incomplete or open for operational or source-bound credit.
   This holds even when model proof and bounded source agreement are
   present, and even when no separate mutation-sensitivity claim is made.
6. **Structural schema validity is not semantic acceptance**, not a
   certificate checker, and not a proof.
7. **This author freeze cannot set `credit_eligible=true`** for P15, P16,
   or P17. Independent GPT-6 reviews the freeze. Later implementation
   packets are scored after those implementations exist.
8. Historical accepted Arithmetic may be **cited** as `accepted_historical`
   model_proof evidence. Citing it here does not re-accept it and does not
   close P16 source obligations or complete operation acceptance.

### Documentation control: omitted mutations stay uncredited

Suppose a future token0 packet binds source/model/tools, a nonempty
execution matrix, and a model theorem, but records
`mutations.compiled_production = 0` or `mutations.unaffected_controls = 0`.
That packet may report `model_proof` and `bounded_source_execution` as
narrower classes. It remains incomplete for complete operational or
source-bound operation credit. The existing examples
`examples/token0-unexecuted-incomplete.packet.json` and
`examples/illustrative-not-credited.packet.json` already keep
`credit_eligible=false` with empty mutation denominators. This freeze
does not run a mutation campaign.

## 4. Denominators that must be printed

Each packet prints nonempty counts for every class it scores.

For **complete P16/P17 operational or source-bound operation credit**,
zero on a required row blocks that credit. Narrower class reports still
print the integers. They do not become complete operation acceptance
when a complete-operation row is zero.

| Denominator | Blocked when |
| --- | --- |
| `partitions.declared` / `partitions.nonempty` | declared = 0 or nonempty = 0 while claiming bounded execution or complete operation credit |
| `executions.actually_run` | 0 while claiming source/model agreement or complete operation credit |
| `mutations.compiled_production` | 0 while claiming complete P16/P17 operational or source-bound operation credit. Missing production mutations leave that credit incomplete or open |
| `mutations.unaffected_controls` | 0 while claiming complete P16/P17 operational or source-bound operation credit. Missing independently verified unaffected controls leave that credit incomplete or open |
| `theorems.named` | 0 while claiming model_proof |
| `independent_reviews` | 0 while claiming independent acceptance |

Print the integers in the packet. Do not infer them from directory names.

## 5. Minimum packet vs later certificates

This envelope is intentionally small. It is enough for P16 token0 and P17
vault reuse records.

It is **not**:

- a serialized Typed/sequential certificate grammar (P19)
- a representation-to-Lean correspondence theorem (P20)
- a mutation runner
- a Lean axiom auditor
- permission to treat `credit_eligible=true` as a proof

If a later certificate checker exists, it must recompute by invoking
delivered Lean entrypoints. This schema does not perform that recomputation.
