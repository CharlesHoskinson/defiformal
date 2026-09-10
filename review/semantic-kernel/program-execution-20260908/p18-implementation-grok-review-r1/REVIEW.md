# P18 R2 platform increment — independent Grok review

**Verdict: ACCEPT_WITH_LIMITATIONS.** `implementation_accepted = false`.
`credit_eligible` stays false. Root alone accepts and records reviewer
identity. This is an externally usable versioned library example and an
honest evidence-packet release. It is not a new theorem and not a
source-refinement gate.

| | |
|---|---|
| Candidate | `p18-implementation-grok-r2-candidate.tar.gz`, native Grok 4.6 |
| SHA256 before review | `75319b8f5879ae448c722fe4d1d24bf998a7a27d0c6a47b7ed078f296ded1ed3` |
| SHA256 after review | `75319b8f5879ae448c722fe4d1d24bf998a7a27d0c6a47b7ed078f296ded1ed3` (unchanged) |
| Overlay files verified | 140 / 140 before and after, 0 mismatches |
| Reviewer | native Grok 4.6 high, requested `grok-4.6`, fresh session, not the author conversation |
| Toolchain | `leanprover/lean4:v4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17` |
| Author worktree | never read, never written |
| P17 packets | absent |

Root 8/8 is prior evidence. Every number below is from this sandbox or from
a write-once diagnostic that added only the historical source capture.
Full argv/cwd/UTC/exit records are in `commands.json`.

## 1. Public example and affected consumer

Documented binder `examples/platform-increment/bind-environment.py` discovered
`/home/charl/.elan/bin/lake` and required `lake env lean --version` =
4.33.0-rc2 from `lean/`. It did not bake a private author path into the API
templates.

`run-token0-example.py --binding <receipt>` exited 0. Lean printed
`denominator=12`, `ok=12`, `status=ok`. The twelve nonempty rows include:

- zero-amount identity `P16-I-ADD` / `P16-I-REM` returning `2^96`
- planned add `(2^96, 1, 1, true)` returning `2^95`
- removal-denominator failure `P16-REQ` as `error:subUnderflow`
- sum-overflow fallback `P16-WRAP` as success

Stdout SHA-256 `0d9c11e6…` matches the bound author log. This is Lean
execution, not a Python substitute.

Missing binding exited **3**. Missing lake in an explicit config exited **3**.

Affected P16 consumer `lake env lean DefiKernel/ConcentratedLiquidity/RuntimeAudit.lean`
exited 0 with 22 `true` rows, SHA-256 `57f8b25d…`. `Tests.lean` compile
exited 0 with 0-byte stdout SHA-256 `e3b0c442…`. Empty compile stdout is
compilation, not a model runtime witness.

## 2. P16 carry-forward

Accepted P16 archives, logs, theorems, and six compiled mutants were not
rerun as campaigns. Hashes match the release binding index:

- source runtime logs: 12 nonempty, class `source_runtime`
- model runtime logs: 4 nonempty, class `model_runtime`
- derived `actually_run` = 16
- compiled production mutants: 6, each designated changed and ADD control unchanged
- unaffected controls: 6
- named theorems: 12, file hashes match, no `sorry` / `native_decide` in those modules
- archives: `p16-source-candidate-r6.tar.gz` `8a8a9400…`, `p16-proof-recorder-candidate-r2.tar.gz` `62a2b86a…`
- model `SqrtPriceMath.lean` `437ceee4…`

P16 source campaign identity remains GPT-6 `ACCEPT_WITH_LIMITATIONS`.
P16 proof/recorder identity remains GPT-6 `ACCEPT_WITH_LIMITATIONS`.
Those identities are not this P18 verdict.

## 3. P18-R1 through P18-R5

The public validator is
`review/semantic-kernel/platform-increment/p18/validation/validate_p18.py`.
Required inventory is independent of the packet glob. Controls invoke that
validator. Copied negative JSON is not the execution.

Prepared sandbox ROOT does not contain
`review/semantic-kernel/program-loop-20260908/.../SqrtPriceMath.sol`.
Intact validation in that sandbox therefore exits **3**
(`main packet source missing …`). Contradiction cases also become 3 because
blocked evidence dominates. Public `run_release_controls.py` matched **4/8**.
Independent mutated copies matched **4/8**. Derived runtime in the intact
blocked run was still 12+4=16 with 6 mutants and 6 controls.

The claimed source SHA-256 `ddd62e3a…` matches:

- accepted P16 r6 compiler baseline overlay, present in this sandbox
- historical capture in the parent review tree
  `/home/charl/defiformal/review/semantic-kernel/program-loop-20260908/.../SqrtPriceMath.sol`

A write-once diagnostic checkout added only that historical file and a
byte-identical validator copy (SHA-256 `d7258771…`, same as root R2).
It did not edit the candidate. In that tree:

| Case | Expected | Actual |
| --- | --- | --- |
| intact | 0 | 0 |
| missing-required-main-packet | 3 | 3 |
| zero-main-execution-denominator | 3 | 3 |
| missing-main-source | 3 | 3 |
| changed-actual-source-log-binding | 1 | 1 |
| invented-execution-denominator | 1 | 1 |
| missing-production-mutations-and-controls | 3 | 3 |
| empty-stdout-presented-as-model-runtime | 1 | 1 |

Independent mutated copies also matched **8/8**. Changing intact expected
exit from 0 to 1 made the control suite fail (`ok: false`, process exit 1).

R1–R5 are therefore closed on the validator and packet when the bound source
path exists. The 140-file overlay does not contain that path. Unpack-only
consumers of the candidate plus the copied P16 campaign tree see blocked 3
until the historical capture or a hash-identical overlay path is present.
That is a packaging limitation, not a P16 hash mismatch and not a new EVM
campaign.

## 4. Scope

`credit_eligible: false` is correct for this pre-review candidate. Frozen
`requested_model: opus` / `reported_model: null` strings are pre-review
history. Current routing selected this Grok audit. Root records final
reviewer identity. The author must not self-certify.

Schema validity is not proof. Bounded Solidity/EVM agreement is not
universal refinement. The model quote register is not pool storage, cash
settlement, or sequential token0-vault composition. Illustrative/blocked
control packets stay `credit_eligible: false`. P17 packets are absent.
P17 implementation remains separate.

Still open: P30 source/assembly refinement, P19/P20, P21, M4/P37, parent
delivery to `semantic-kernel-pivot`, and whole-program completion.

## 5. Failed reviewer setup

None. The sandbox 4/8 result is a real consumer outcome of the missing
source path, not a reviewer defect.
