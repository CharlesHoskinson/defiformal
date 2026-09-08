# Sprint11 interface-r1

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. Checker assigned: `gpt-6-astra` (not executed here). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private cwd: `/home/charl/.cache/defiformal-sprint11-builds/fixture` (formerly the fixture-author cache).
Lean in that directory: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`).
Lake: `5.0.0-src+d8b1897`.

Repository `.lake` was not used. Proof-author cache was not used. Root/binary cache was not used.

## Compile

| Command | Exit |
| --- | --- |
| `lake build DefiKernel.Nary.InterfaceInstances` attempt 00 | **1** (preserved) |
| `lake build DefiKernel.Nary.InterfaceInstances` attempt 01 | **0**, 963 jobs, Built 4.1s |
| `lake build DefiKernel.Nary.InterfaceInstances` attempt 02 | **0**, 963 jobs, Built 3.8s |
| `lake env lean DefiKernel/Nary/InterfaceInstances.lean` | **0** |

Worktree and private lean/config hashes matched after the final full sync (`hashes/source-hash-equality.txt` = `yes`). Owned module SHA-256 `c693f425623d4445619d44dbc82c4304e37b9f54c9d03ad451554557c57e8a69` (43172 bytes) matched in both locations.

Failed private attempt 00 is kept: NeutralOn/`receiptDelta` conversion, `have rec :=` binder, `accept_away` peer inequality direction, F14 identity tactics.

## Owned source

Edited only `lean/DefiKernel/Nary/InterfaceInstances.lean` and this evidence directory. Examples/Tests/Audit, Interference, BinaryCorrespondence, Causal, and other workers' files were not edited. Private sources were not copied back over other owners.

## Kernel results (not bounded Audit 288/288)

F18 uses actual `Interface.Examples.cfg`, `initial55`, `boundary 0`, `op102`, `receipt102`, region `{alice,bob,carol}`, and the full fixed edge `[(name 0, name 1)]`. Constant value 10, empty support.

- Local receipts: any successful `executeStep` of `op102` yields `receipt102` from `executeStep_sound` plus reducing `prepareInvocation`/`extractReceipt`. Writes confinement, neutrality, empty-support separation, and `EffectPaired` on the full edge are proved on that receipt.
- Accepted M2 bridges invoked: `step_typed_total_preserved` and `step_binding_preserved`. Also `RegionObligations`/`BindingObligations` for the allowed-step form. Transition guarantee “region sum unchanged and alice/bob increments equal” is derived from `step_receipt_region`/`step_receipt_cell`, not assumed as a post-invariant.
- Generic finite rule: `LocalObligation`, `CrossInclusion`, `Stable`, then `every_prefix_invariants` / `runPrefix_invariants` for `TypedTotalContract` and `Agrees` on the entire fixed edge set. Conditional on actual `executeStep = .ok`; not an enabledness claim.
- Finite three-stream execution: kernel `decide +kernel` of `executeStep` at `initial55`, `paired1`, `paired2`. All six complete schedules unfold to world `2/2/6` with each local `nextIndex = 1` and event index `0`. Balance table `5/5/0 → 4/4/2 → 3/3/4 → 2/2/6` is proved on `f18WorldAfter`.

F19 uses actual `op103`/`receipt103`. Successful step reaches alice 4, bob 5, carol 1. Empty-edge `Agrees` and `bindingsHold` hold. Full global `checkBindings` is `.error (.unequal 0 (name 0) (name 1) 4 5)`. `TypedTotalContract` still holds; `EffectPaired` on the global edge fails (`-1 ≠ 0`). That is the remaining `step_binding_preserved` premise.

F11: authorized transfer 7 from vault 10 succeeds to vault 3 / recipient 7, nonnegative, catalog valid. `LocalObligation` for reserve ≥ 4 is false. Authorization-only success is not the generic theorem.

F13: authorized peer withdrawal 7 takes vault 10 to 3. Deposit-only `Stable` holds; the actual peer step is not `depositRely`. Unsafe peer is not covered by a deposit-only instance.

F14: identity `executeStep` at vault 3 stays 3. Universal identity local obligation, cross-inclusion, and stability hold; initialization `4 ≤ 3` fails. Generic initialized preservation is not applied. First prefix token remains uninitialized.

F15: `False → False` both ways, neither fact follows. No financial runtime result.

Source scan of the owned file: no `sorry`, `native_decide`, or `axiom`. That is not an imported axiom inventory.

`decide +kernel` is kernel reduction of decidable equalities, including the literal `executeStep` equations. It is not `native_decide`. Bounded Audit 288/288 was not substituted for these local-premise proofs.

## Remaining

- Independent GPT-6 check of this module
- Imported axiom inventory
- `runNary` admission wrapping the proved `runPrefix` machines
- F14 full `[0,1,2]` identity unfolding (first token and universal identity obligation are proved)
- BinaryCorrespondence, Causal, integrated root build, 16 production mutants, final acceptance
- Flexible-simp / unused-simp-argument warnings (did not fail the private builds)
