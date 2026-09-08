# P15 minimum reusable contract freeze — Grok author report

**Result:** `pending_independent_gpt6_review`  
**Author:** native Grok 4.6  
**Checker required:** independent GPT-6  
**This author cannot accept the freeze, tick tasks 16.1–16.5, or open P16.**  
**Foreman:** not used  
**Commit/push:** not performed  
**HEAD:** `01490b539b3d30bb992e0d6cfc603022d7be99a9`  
**Worktree:** `/home/charl/defiformal-wt-p15-contracts-grok-gpt6-20260908`

## What was produced

A small versioned contract package for tasks 16.1–16.5, using delivered
Typed/Composition/Arithmetic APIs and the retained Uniswap v3-core capture.

Allowed outputs only:

- `openspec/changes/reusable-verification-platform-program/contracts/**`
- `review/semantic-kernel/p15-contracts-20260908/grok-author/**`

Planning files, Lean sources, historical fixtures, AGENTS.md, and other
worktrees were not edited. Tasks 16.1–16.5 remain unchecked in `tasks.md`.

| Task | Output |
| --- | --- |
| 16.1 | `contracts/kernel-operator-contract.md` plus `source-bindings.json` kernel section |
| 16.2 | `contracts/library-arithmetic-contract.md` |
| 16.3 | `contracts/adapter-observation-contract.md` |
| 16.4 | `contracts/evidence-packet.schema.json`, `evidence-packet-usage.md`, three schema-valid examples |
| 16.5 | this report, `result.json`, `source-bindings.json`, `CANDIDATE-MANIFEST.json` |

## Kernel/operator (16.1)

Reusable operator: `DefiKernel.Typed.execute`
(`lean/DefiKernel/Typed/Transition.lean` 171–187,
SHA-256 `73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2`).

Sequential first-refusal: `DefiKernel.Composition.advance` /
`run` (`Sequence.lean` 33–51,
SHA-256 `32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729`).

Identities, dimensions (`Unit`), roles (`Right`: invoke/debit/changeSupply),
effects, supply, access, and the exact computational refusal order are cited
from those files. Pilot `DefiKernel.Transition` in `Core.lean` is a different
API and is not this operator.

Pure Arithmetic (`Except Failure (Word w)`) is not a Typed wrapped operation.
`Arithmetic.Reference.observeExecution` is the delivered Typed wrap shape.
P16/P18 may omit a Typed wrapper. Kernel-platform evidence later requires the
library-to-Typed bridge. No undeclared operator fields were added.

## Library arithmetic (16.2)

Delivered `Operations.add` is checked `addOverflow` without wrap
(`Operations.lean` 8–9, SHA-256
`081c4d29809a33b6377ab1746ae93f2f2a429f5fa307983331c4cb5fbc460485`).
Historical mutant `wrap-add` made F04 false (exit 1). That is accepted
negative evidence, not the API.

P16 denominator-sum overflow is a **future** source observation:
Solidity 0.7.6 native `uint256 +` wraps, then `denominator >= numerator1`
fails, then `UnsafeMath.divRoundingUp` fallback. That is not
`Operations.add` and not unbounded Python addition.

Python oracle
`cl_oracle.py` SHA-256 `4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd`
uses unbounded `numerator1 + product`. It is diagnostic only, not source
execution, and not accepted source behavior.

Pinned helper bytes: `SqrtPriceMath.sol`
`ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149`,
commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, lines 28–56.
Compiler settings are declared (0.7.6, optimizer 800, `bytecodeHash none`).
No solc binary or EVM run was performed here.

## Adapter observation (16.3)

Token0 is a pure function of `(sqrtPX96, liquidity, amount, add)` to
`uint160` or source revert. Zero amount is identity success. No ledger or
history fields. Vault pin is `not_established`. Second AMM substitution is
forbidden. `P17.platform_reuse` harness/executor requirements are named and
not implemented.

## Evidence packet (16.4)

Schema `0.1.0` distinguishes the five obligation classes. Examples are
schema-valid and `credit_eligible=false`. Empty partitions and unexecuted
tools cannot succeed. A negative fixture with `illustrative` plus
`credit_eligible=true` is rejected by the schema (3 errors). Schema validity
is not semantic acceptance, not a certificate checker, and not a proof.
Certificates are not a P16 prerequisite.

## Validation (nonempty denominators)

Commands and versions: Python 3.14.4, jsonschema 4.19.2, git 2.53.0,
sha256sum uutils 0.8.0.

```
python3 review/semantic-kernel/p15-contracts-20260908/grok-author/validate_packets.py
exit 0
packets 3
checks 9
failures 0
binding_hash_pairs 21
token0_capture_files 7
negative_control_schema_errors 3
```

Zero validator failures is the positive-path count. The negative control is
a separate nonempty rejection count (3). Not run: `lake build`, historical
kernel campaigns, solc, P16/P17 implementation.

## Remaining obligations

1. Independent GPT-6 review of this exact freeze. Author cannot accept it.
2. P16: verify pin closure against CURRENT.json liquidity archive
   `e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77`,
   declare solc/EVM harness, repair Python oracle, implement token0 library,
   execute nonempty partitions including wrapped-sum overflow, prove the
   0.7.6 fallback equation, compile production mutants. Do not exclude the
   overflow branch.
3. P16 planning-slice GPT-6 review remains a P16 gate. This freeze is not
   that review.
4. TickMath, SwapMath, token1/delta, bitmap/factory, compiled M09 SwapMath,
   and full traversal remain P21.
5. P17 vault pin or `blocked_missing_source`. No pin is selected here.
6. `P17.platform_reuse` harness, shared lemma/contract, shared executor
   result, token0 kernel bridge, both adapters, case-two inventory.
7. Source refinement (P30) remains open.
8. Certificates (P19/P20) remain independent and are not P16 prerequisites.
9. Root may publish accepted work to `semantic-kernel-pivot` after
   independent review. This worktree did not commit or push.

## What was preserved

Historical Arithmetic acceptance, wrap-add mutant evidence, Uniswap capture,
Python oracle defect, P01 Recovery import on `DefiKernel.lean`, and all
negative/historical kernel evidence remain under their original identities.
No theorem statement was changed.
