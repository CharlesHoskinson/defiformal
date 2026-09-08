# Sprint11 interface-r2

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. Checker assigned: `gpt-6-astra` (not executed here). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private cwd: `/home/charl/.cache/defiformal-sprint11-builds/fixture`.
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`).
Lake: `5.0.0-src+d8b1897`.

interface-r1 bytes are preserved, including the stale `hashes/evidence-files.sha256` and REPORT.md. R1 repair is a supplemental `final-artifacts.json` plus disposition; the old manifest was not overwritten.

Owned file: `lean/DefiKernel/Nary/InterfaceInstances.lean`  
SHA-256 `e1c37f5c1ab0339f85daba12d3fba4c000ae11cc84a8882d8c34566e1ee267aa` (63591 bytes).

## Compile

| Command | Exit |
| --- | --- |
| `lake build DefiKernel.Nary.InterfaceInstances` 00 | **1** (preserved) |
| same 01 | **1** (preserved) |
| same 02 | **1** (preserved) |
| same 03 | **0**, 963 jobs, Built 6.1s |
| `lake env lean DefiKernel/Nary/InterfaceInstances.lean` | **0**, empty stderr |

Worktree and private lean/config hashes matched after the final full sync. Repository `.lake`, proof cache, and root cache were not used. Source scan of the owned file: no `sorry`, `native_decide`, or `axiom`.

## I1. Admission and runNary

`admit` is reduced with `decide` to `.isOk = true` on the actual cfg/roster/boundaries/branches/schedule. `admit_ok` then gives catalog validity, `analyzeAll` success, and `Complete`. `runNary_executed` turns that into `.executed schedule (runPrefix ...)`. Independent expected machines are identified by kernel `machineEq`:

- F18: all six schedules → `.executed s (expectedF18 s)` and world `f18WorldAfter 3` with `TypedTotalContract` and full-edge `Agrees`
- F11 `[0]` → `.executed [0] f11Expected`, vault 3 / recipient 7
- F13 `[1]` → `.executed [1] f13Expected`, vault 3
- F14 `[0,1,2]` → `.executed [0,1,2] f14Expected`
- F19 `[0]` → `.executed [0] f19Expected` and `.unequal 0 (name 0) (name 1) 4 5`

No wrapper assumes a desired execution: admission is the actual `admit` function.

## I2. F14 full `[0,1,2]`

Accept-chain `f14_three_run` from three identity successes. `f14_prefix_eq_expected` equals `f14Expected`. Locals each have `nextIndex = 1` and event index `0`. World and store remain `f14Initial`. Vault stays 3; `vaultReserve 4` is false. Local/cross/stability still hold; initialization remains the missing generic premise.

## I3. F13 failed generic premise

`Stable (vaultReserve 4) depositRely` is unchanged and true. The actual 10→3 step is not `depositRely`. New: any rely with `rely 0 f13Initial.state f13After.state` fails `Stable (vaultReserve 4)` (`f13_not_stable_if_rely_covers`). Coverage and stability use the same participant `0`. Also `¬ CrossInclusion f13WithdrawalGuarantee depositRely` for the actual peer-1 withdrawal guarantee. Catalog, `checkAccess`, and `executeStep = .ok` are bundled in `f13_valid_authority_success`.

## I4. Evidence

R1 old manifest retained (`423abaae…`, 2265 bytes). Supplemental r1 `final-artifacts.json` lists current r1 regular files excluding itself. This r2 directory’s `final-artifacts.json` is written last and excludes only itself.

## Remaining outside this lane

Independent GPT-6 re-review; imported axiom inventory of the enlarged module; integrated root build; 16 production mutants; BinaryCorrespondence/Causal/funded remaining work; Sprint11 acceptance.
