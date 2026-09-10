# P18 grok-r1 author candidate — native Grok 4.6

**Status: ready for independent Opus review. Not P18 acceptance. Not self-accepted. Not source refinement. Not P37.**

Native Grok 4.6 authored the P16-only early increment: versioned example/API and evidence packets. Independent reviewer is native Claude Opus, requested model `opus`, not run in this session. No Foreman, subagents, commit, or push.

Worktree `d03abac355e79bde0945df5c52c68a99c4933a9b` on `work/p18-release-grok-opus-20260909`. Seven P18 entry input hashes matched the preparation file. Accepted P16 Lean modules matched the grok-r2 used-closure. No `Vault` modules were imported.

## What was built

Public example under `examples/platform-increment/`:

- `bind-environment.py` records lake and requires `lake env lean` 4.33.0-rc2 from `lean/`
- `run-token0-example.py` refuses to run without that binding (missing binding exit 3)
- `lean/Token0ReleaseExample.lean` calls `observeToken0` / `getNextSqrtPriceFromAmount0RoundingUp`
- API files use repository-relative paths and null tool slots; they do not bake a private worktree or cache path

Packets under `review/semantic-kernel/platform-increment/p18/packets/`:

- `p18.token0.next-price.packet.json` — operation packet, `ready_for_independent_review`, `credit_eligible=false`, verdict `pending`
- empty-denominator, missing-evidence, and illustrative controls — all `credit_eligible=false`
- no P17 packets

Counts were read from accepted files:

- 12 source rows in grok-r6 `evm/baseline/rows.json` and `campaign-score.json` baseline 12/12
- 6 compiled mutants and 6 unaffected ADD controls from grok-r6 mutant summaries
- 10 nonempty partitions taken from the row `partition` field
- 12 named public theorems; inventory still records 62 source-written statements
- independent reviews completed = 0 for this packet

The six Solidity mutants were not rerun. The twelve EVM baseline rows were not rerun. ProofAudit/`#audit_axioms` was not rerun.

## Actual Lean execution this session

`lake env lean` from `lean/` reported `4.33.0-rc2`. Default PATH lean 4.33.1 was not used.

| Command | Exit | Result |
| --- | --- | --- |
| `Token0ReleaseExample.lean` | 0 | denominator=12 ok=12, identity/add/remove/overflow printed |
| public `run-token0-example.py` | 0 | same 12 rows |
| `RuntimeAudit.lean` | 0 | 22 `true` lines including 12 P16 ids |
| `Tests.lean` | 0 | compile-only consumer; empty stdout |
| missing binding | 3 | blocked |
| `validate_p18.py` | 0 | schema+link checks; semantic_credit false |

P16-ADD printed `ok:39614081257132168796771975168`. P16-REQ printed `error:subUnderflow`. P16-WRAP printed the accepted fallback value. Python did not compute those numbers.

## Historical P16 identities bound, not re-accepted

- Source archive SHA-256 `8a8a9400e04a63ade06976959faca2a575e8158fa92f31d29e612cdc049ff981`
- Proof/recorder archive SHA-256 `62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8`
- P16 source independent reviewer: nonauthor GPT-6, ACCEPT_WITH_LIMITATIONS, review SHA-256 `b711a01859f079386be214245d5a9d239165c03ae79315afd0d907183b3e2265`
- P16 author historically requested grok-4.6/high and reported grok-4.6-build
- Those verdicts do not accept this P18 packet

Old P15 illustrative packets retain hashes `04826ff3…`, `cf610eb2…`, `9c3ea55a…`.

## Remainders

Opus must review the exact candidate. Root alone accepts and publishes to `semantic-kernel-pivot`. P17, P19–P21, P30, and P37 stay open. A model-only quote is not pool storage or vault composition.
