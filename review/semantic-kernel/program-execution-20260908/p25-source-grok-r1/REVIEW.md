# P25 Balancer source-preparation and compiler-baseline audit

**USABLE.** Frozen sandbox source, dependency, and compiler-baseline packets are usable as compiler input for later P25 work. This review does not freeze task 26.1 cash-plus-owed or hook-revert observations, does not accept tasks 26.2/26.3, and does not accept full P25.

Independent auditor: requested native Grok `grok-4.6` high. Returned model identity is unknown until root terminal metadata. One auditor. No subagents, Foreman, network, branches, commits, pushes, package installs, or upstream edits. AGY R21/R22 author worktrees were not inspected.

## Scope

Audit of frozen source/dependency/compiler preparation only. Historical `stored_path` strings under `/home/charl/defiformal/review/...` were resolved to sandbox copies. Original Balancer archive is `source-archives/balancer.tar.gz`. One fresh isolated `solc --standard-json` reproduction used the supplied gzip input and the `compiler.json` binary after SHA-256 verification. Contracts were not executed. Capture helpers were not rerun.

## Source identity

Official `balancer/balancer-v3-monorepo` commit `449f7e074be4a92f9ed35ac8d201f45d4ac01f7e` is observed main HEAD at discovery, not a deployed identity. Commit tree SHA is `a4420a82ead6c17ed670915216551cf430fa664b`.

78 captured files: 68 `import_traversal_source` plus 10 configuration or unexecuted reference tests. All 78 match sandbox SHA-256, git blob SHA-1, byte length, and follow-up git-tree blobs.

Original packet import graph on the 68 traversal sources: 210 local edges and 72 external occurrences. Independent recount on those 68 files matches. Including the two foundry tests raises local imports to 236; those 26 extra edges are not in the original 210 and are not in the 98-source compile set.

## Failed first tree check (zero credit)

`p25-balancer-source-verification/failure.json` exit 1, `credit: false`. The first recursive-tree request used the commit SHA; the JSON `sha` field echoes `449f7e07...`, which is not `commit.tree.sha`. Blob/member checks were not reached. That attempt is not a successful identity check.

Explicit-tree follow-up requested `a4420a82...` and returns that SHA with 1247 entries. The original and follow-up entry sets `(path, sha, mode, type)` are identical. Identity after follow-up holds; the failed first attempt remains failed.

## Archives and locked dependencies

Balancer tarball SHA-256 `a163dac24b7650d9ab131cc3bdb1d12cb6d76cc08b44ea443d19cf2f409ff1af`. Prefix `balancer-v3-monorepo-449f7e074be4a92f9ed35ac8d201f45d4ac01f7e`. 1081 regular members. All 78 captured files extract byte-identical. Ten relative `pkg/*/coverage.sh -> ../../coverage.sh` symlinks stay inside the prefix; no absolute, NUL, or escaping names.

OpenZeppelin 5.4.0 npm archive SHA-256 `4e4d51f18935b32f0c877bf666ac37f5e5a98e75f03e7a77eb7569f84701f680`. Independently computed sha512-SRI and sha1 match `identity.json` and registry `dist.integrity` / `dist.shasum`. Registry JSON is a version document with top-level `dist`, not a packument `versions.5.4.0` object. `dist.fileCount` 423 equals regular members. Selected 26 OZ sources extract byte-identical.

Permit2 commit `cc56ad0f3439c502c246fc5cfcc3db92bb8b7219`. Archive SHA-256 `1f0da63e66c69fa85f2a68af7f598aca8f3354f87e7703aa3abe6522685e9f04`. All 104 regular archive members match git tree blobs. Selected 4 Permit2 sources extract byte-identical. `identity.json` records that count as integer 104, not a boolean.

Yarn checksums in the captured lockfile are cache-container values and are not the raw archive SHA-512, SHA-256, or SHA-1.

Final selected compile set: 98 sources = 68 Balancer + 26 OpenZeppelin + 4 Permit2. `imports.json` records 308 lexical edges and `unresolved: []`. Independent lexical recount from the 98 files is 308 with 0 unresolved source paths. This is not a reference-test closure and not a full npm/build closure. Packet flags `compiler_resolution_verified` and `test_import_closure_verified` remain false.

## Compiler baseline

Official `solc-linux-amd64-v0.8.27+commit.40a35a09` SHA-256 `b9977d500c17cba6f0032ca939ef98c4decf6363f19f386d05fb02f708115264` matches `compiler.json`, the list.json build, and the on-disk binary. Version stdout hash `cdb57de025a5221bb3b663cff856a0bbf6544a92102f7de9d722fd7409dfd804`.

Frozen gzip streams decompress to the hashes in `command.json`: input `9d7e02a1c04be2539d4c56424e5fe027f7436fbac6d85f38577b5873e62e4ac0` (872929 bytes), stdout `d0407c5bdef01e56c2158fa28eb1af0366ede87ae23b79cfe04b6c73f8a4400c` (2776435 bytes), empty stderr. Standard-JSON settings: optimizer enabled, 999 runs, Cancun, `viaIR` omitted (solc default false). 98 sources; each input content SHA-256 matches the sandbox file.

Parsed frozen stdout: 0 errors, 4 warnings, 96 contracts, 44 bytecode outputs. Warning 2394 once (transient storage). Warning 5574 three times: Router runtime 26365, Vault 33240, VaultExtension 28902. `result.json` agrees. `P25_accepted` is false. EVM execution is false.

Fresh isolated reproduction, cwd `logs/solc-repro`, argv `[binary, --standard-json]`, stdin the decompressed frozen input: exit 0, elapsed 2.808224 s, stdout and stderr hashes identical to frozen streams. Exit 0 was not taken as sufficient; the nonempty JSON was parsed for error severity and counts.

## Build profile

Foundry `pkg/vault/foundry.toml`: 0.8.27, optimizer 999, Cancun, ignored error codes 2394/5574/3860. The baseline matches that Foundry profile, not Hardhat.

Hardhat (three git-bound files): compilers 0.8.26 and 0.8.27, `viaIR` unless `COVERAGE=true`, custom optimizer sequence, default runs 9999. Vault.sol and VaultExtension.sol overrides use 0.8.26 / runs 500. Local Hardhat network `allowUnlimitedContractSize: true`. No Hardhat resolution or build was run. Code-size warnings belong to the 0.8.27 / no-IR / 999 baseline. They do not establish deployed size and do not endorse bypassing limits. Packet comparison text matches these files. Extra observation, not a packet mismatch: Hardhat default runs are 9999, not 999.

## Navigation excerpts (later contract, not frozen)

Six source-backed excerpts match current files:

1. Signed `tokenDelta`: credit is negative (`_supplyCredit` uses `-credit.toInt256()`), debt is positive.
2. Non-zero delta counter changes only on zero transitions (`next == 0` decrement, `current == 0` increment). Zero delta returns without touching the counter.
3. Outer `transient` unlock requires `_nonZeroDeltaCount() == 0` before relock. Nested unlock (`isUnlockedBefore == true`) does not take that check or session increment.
4. `settle` sets `_reservesOf[token] = token.balanceOf(this)` then `credit = current - prior`, then caps credit by `amountHint`. Excess remains in stored reserves and is not supplied as delta credit. The source comment says the leftover is "discarded" from the credited amount; it must not be treated as vanished from vault reserve accounting.
5. Before-add hook can change balances/rates; `reloadBalancesAndRates` runs before `_addLiquidity` accounting. After-add hook runs after those updates.
6. After-add hook `success == false` or wrong return length reverts `AfterAddLiquidityHookFailed`. If hook-adjusted amounts are disabled, returned amounts are ignored.

Source inspection is not a whole-EVM rollback proof. A Solidity revert of the outer call would undo storage, including hook-time updates; that is EVM semantics, not a P25 proof. Existing P17 pin must not be substituted. Financial integer, token, Permit2, compiler, and runtime assumptions remain open. Source-execution gate remains open.

## Packet defects versus open gaps

No required repair of the frozen source/compiler packet was found. Concrete gaps that remain open, and that this review does not close:

- Task 26.1 AGY cash-plus-owed and hook-revert observation contract, plus a later design review of that contract.
- Tasks 26.2/26.3 Lean accounting/rollback proof, join success, hook-revert refusal, mutants.
- Reference-test import closure and full npm/build closure.
- Hardhat viaIR / 0.8.26 / 500-run profile execution.
- Deployed bytecode, constructor args, and on-chain identity.
- Source-execution campaign and Permit2/token runtime behavior.

## Probe attempts

First `verify.py` JSON write failed on tar member `type` bytes; no results file from that attempt. Second probe wrote `logs/probe-results.json` with four over-strict predicates (tests included in the 210 count; relative coverage.sh `..` treated as escape; packument path into a version document; Permit2 count compared as boolean `True`). Those predicates are preserved under `logs/failed-attempts/` and have zero defect credit against the packet. Corrected facts are in `logs/corrected-checks.json` and `logs/followup-archive-graph.json`.
