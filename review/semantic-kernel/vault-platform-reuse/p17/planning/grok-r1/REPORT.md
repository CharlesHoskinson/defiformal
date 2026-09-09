# P17 vault source-entry and reuse design — Grok 4.6 author r1

**Status: pending_independent_gpt6_review. Not acceptance.** Native Grok 4.6 authored the exact P17 concrete source-entry and platform-reuse planning slice. Independent GPT-6 has not reviewed these bytes. `gate_accepted` is false. `P17.platform_reuse` is false. No Foreman. No subagents. No commit or push. No Lean implementation. No campaign solc/EVM scoring. No production mutation credit. Frozen program tasks 18.1–18.7 were not ticked. P16 source-gate R1/R2 repairs are not assumed closed.

- **Requested author:** native Grok 4.6
- **Returned author identity:** Grok 4.6 (this author session; no separate native CLI session id)
- **Independent checker:** required next; not run
- **Worktree:** `/home/charl/defiformal-wt-p17-vault-grok-gpt6-20260908`
- **HEAD:** `2ad464397cd207bca647768d77d57abb1f8e575c` branch `work/p17-vault-readiness-grok-gpt6-20260908`
- **Change:** `openspec/changes/vault-platform-reuse-p17/`
- **Evidence:** `review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r1/`

## What this slice is

A P17-only OpenSpec planning package that freezes Sky/Spark sUSDS `src/SUsds.sol` at sdai `dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce` as the contrasting vault, not `src/l2/SUsds.sol` and not a second AMM. It freezes ordinary deposit/mint/withdraw/redeem conversion, source-selected transfer and authorization refusals, compiler/EVM/harness assumptions, nonempty fixtures and production mutants, proof obligations, and a concrete platform-reuse experiment.

Counts: 5 capabilities, 20 requirements, 27 scenarios, 23 unchecked implementation tasks. `openspec validate vault-platform-reuse-p17 --strict` exits 0. Intact `diagnose.py` exits 0 with 37/37 checks. `--empty-corpus` exits 3. Production mutation credit is 0.

## Pin (compared, not self-asserted)

| Item | Digest |
| --- | --- |
| Selected `src/SUsds.sol` | SHA-256 `9fe0c713751142e75a1da60ad6c0127d5ad01cb6d24289183ac48b202f3c5d69`, 16399 bytes, blob `efe937675bbbbc7f93bde453fd5648fa885655ab` |
| Rejected `src/l2/SUsds.sol` | SHA-256 `bcf6dfabed3c99f200d0c184943f88a9361c11e35c1adbf6212d33c4dc8165fa`, 8616 bytes |
| Commit | `dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce`; `susds` branch locator-only |
| OZ upgradeable / core | `723f8cab09cdae1aca9ec9cc1cfa040c2d4b06c1` / `dbb6104ce834628e473d2173bbc9d47f81a9eec3` |
| Closure | ten compiler-source keys; ERC1967Proxy extra harness root, not a deployed identity |
| External boundaries | VatLike, UsdsJoinLike, UsdsLike, IERC1271 not discharged by import closure |

L2 is a bridged ERC20 with auth mint/burn and no asset/share conversion. Main SUsDS is an ERC-4626-like savings vault.

`blocked_missing_source` is false for this design. That is not source acceptance.

## Domain and observations

D0: initialized, `chi = RAY`, `timestamp = rho`, drip else-branch (no `vat.suck` / `usdsJoin.exit`). D1: same with `chi = RAY+1` so floor and ceil diverge. Whole-source accrual/upgrade/permit is not claimed.

Independent literals (not solc):

- D0 `deposit(10^18)` shares `10^18`
- D1 `deposit(10^18)` shares `10^18 - 1`
- D1 `mint(10^18)` assets `10^18 + 1`

Transfer refusal is `usds.transferFrom` revert. Authorization refusal is `_burn` `SUsds/insufficient-allowance` / `insufficient-balance`. Successful external calls are not asset credit. Overflow success theorems take `totalSupply + shares < 2^256` as premises rather than the source comment.

Characteristic mutant V-TF-SKIP deletes `transferFrom` in `_mint`; designated false P17-DEP-D0; unaffected P17-RED-D0 and P17-DEP-BAD-RECV. V-DEP-CEIL flips deposit floor to `_divup`; designated false P17-DEP-D1; unaffected P17-DEP-D0 and P17-RED-D1. Source-independent negative P17-NEG-MINT-NO-CREDIT is a model counterexample, not a source fixture.

## Compiler / EVM (not campaign-scored)

solc `0.8.21+commit.d9974bed` SHA-256 `f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df`. Campaign freeze: optimizer 200, shanghai, `bytecodeHash none`. Root smoke used IPFS; those artifact hashes are not campaign identities. EVM is geth `evm` 1.15.11-stable SHA-256 `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c`. Vault fork is a separate Shanghai prestate, not P16 Istanbul. Chained `evm run --dump` roundtrip is unverified; failure is `blocked_missing_evm`.

## Platform reuse experiment (designed, not executed)

- One engine: proposed `scripts/platform_engine/` extracted from delivered `record_cmd.py`. Wrapper of two campaigns rejected.
- Shared lemma: `Rounding.divideNat_down_ok_iff` / `divideNat_up_ok_iff` and directed `mulDiv` rational-error theorems under the no-product-overflow premise.
- Shared executor theorem: `Typed.execute_ok_iff`, instantiated by both adapters with real `e.Valid` premises.
- Token0 bridge: `Quantity.toQuantity` into a QuoteSqrtP register. Ordinary add is a nonzero debit of `2^95`. Source token0 observations stay four inputs plus `uint160 | revert`. Not Uniswap history.
- Composition not claimed. Case-two inventory designed, not measured. Missing inventory leaves the gate open.
- If the quote-register is rejected, do not weaken `P17.platform_reuse`.

## What was not done

Independent GPT-6 review, Lean, campaign compile, scored EVM, compiled mutants, P16 source-gate close, P21, P30, commit, push.
