# P15 minimum reusable contracts (author freeze)

This directory is the proposed P15 contract package for tasks 16.1–16.4.
It is an author freeze for independent GPT-6 review. It is not acceptance,
not a P16 implementation, and not a certificate checker.

**Package id:** `reusable-verification-platform.p15.minimum-contracts`  
**Author freeze version:** `0.1.0`  
**Worktree HEAD:** `01490b539b3d30bb992e0d6cfc603022d7be99a9`  
**Author:** native Grok 4.6  
**Checker required:** independent GPT-6  
**Foreman:** not used

## Files

| File | Task | Role |
| --- | --- | --- |
| `kernel-operator-contract.md` | 16.1 | Delivered Typed/Composition operator boundary and refusal order |
| `library-arithmetic-contract.md` | 16.2 | Delivered Arithmetic amount/rounding/error contract, plus P16 wrapping obligation |
| `adapter-observation-contract.md` | 16.3 | Pure token0 and future vault observation relations. P17 harness reuse named, not implemented |
| `evidence-packet.schema.json` | 16.4 | Structural schema for one operation evidence packet |
| `evidence-packet-usage.md` | 16.4 | Obligation classes and scoring rules the schema cannot prove |
| `source-bindings.json` | 16.1–16.5 | Exact hashes, line locations, pins, and unknown items |
| `examples/` | 16.4 | Schema-valid packets that cannot self-assert credit |

Author report and validation evidence live under
`review/semantic-kernel/p15-contracts-20260908/grok-author/`.

## Scope

These contracts cover only the next two cases:

1. P16 pinned Uniswap V3 token0 next-price (`getNextSqrtPriceFromAmount0RoundingUp`).
2. P17 contrasting stateful vault after an actual pin exists.

They use delivered APIs at this HEAD. They do not invent operator fields.
They do not implement Lean libraries, adapters, harnesses, or checkers.

Certificates and full M4 are not prerequisites to P16. A later certificate
path must first accept the repaired Typed/sequential grammar. A caller
judgment, source hash, or theorem name is not proof.

## Status labels used in this freeze

| Label | Meaning |
| --- | --- |
| `delivered` | Present in this worktree at the cited path/hash |
| `accepted_historical` | Previously accepted package. Bytes preserved. Not re-accepted here |
| `captured_not_executed` | Source bytes retained. No solc/EVM run in this freeze |
| `required_future` | P16/P17 obligation. Not implemented here |
| `not_established` | No reviewed pin or API exists |
| `diagnostic_only` | Third implementation. Not source execution |

## What this freeze does not do

- It does not tick OpenSpec tasks 16.1–16.5.
- It does not open P16 implementation.
- It does not select a vault pin.
- It does not rerun Lean campaigns or mutate kernel sources.
- It does not treat JSON Schema validity as semantic acceptance.
