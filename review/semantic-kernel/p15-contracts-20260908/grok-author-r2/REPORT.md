# P15 R2 bounded repair — Grok author report

**Result:** `pending_independent_gpt6_review`  
**Author:** native Grok 4.6  
**Requested model (preserved):** `grok-4.6`  
**Reported model (preserved):** `grok-4.6`  
Native terminal actual identity is recorded by root, not relabelled here.  
**Checker required:** independent GPT-6  
**This author cannot accept the freeze or tick tasks.**  
**Foreman:** not used  
**Commit/push:** not performed  
**HEAD:** `01490b539b3d30bb992e0d6cfc603022d7be99a9`

Prior grok-author evidence is byte-identical (8 files). New evidence is only
under `review/semantic-kernel/p15-contracts-20260908/grok-author-r2/`.
Schema, examples, source-bindings, and other contracts were not edited.
Historical CURRENT path/hash in source-bindings is unchanged. Root already
records the recovered snapshot
`/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p15-context-CURRENT-at-read.json`.

## Repairs

**R1** (`evidence-packet-usage.md`). Complete P16/P17 operational or
source-bound operation credit now requires actual characteristic production
mutations **and** independently verified unaffected controls. Missing either
leaves complete operation acceptance incomplete or open. That holds even
when no separate mutation-sensitivity claim is made. Narrower
model-proof-only or historical-pointer records remain reportable with
`credit_eligible=false` and cannot close complete operation acceptance.
Section 3 scoring rule 5 and section 4 denominator rows state this. A short
documentation control describes a packet with executions but zero mutation
or control counts as uncredited. Existing no-credit examples are preserved.
No schema engine or mutation campaign was added.

**R2** (`adapter-observation-contract.md`). `P17.platform_reuse` now
distinguishes the common executable entrypoint from the shared proved
result. The proved result must be a named delivered executor or composition
theorem, with explicit premises, and checked unchanged instantiations for
**both** cases. Routing both adapters through one function is not enough.
Examples of actual theorem names, not selected or instantiated now:
`DefiKernel.Typed.execute_ok_iff` (`Transition.lean` 219) and
`DefiKernel.Composition.executeStep_sound` (`Execution.lean` 201). Common
harness, shared financial lemma or contract, token0 kernel bridge, both
adapters, case-two inventory, and meaningful-composition-if-claimed remain.

**Optional precision** (`kernel-operator-contract.md` §8). The summary table
now lists `Quantity.toQuantity` as returning `Typed.Quantity asset` directly
and `Quantity.fromRat` as returning `Except Failure (Word w)`.

## Changed contract hashes

| File | Before | After | Bytes |
| --- | --- | --- | --- |
| `contracts/evidence-packet-usage.md` | `f6b11219c2ad6ae50ae5758ac9b699b4795ea6e3ce2fe42df468071ecea513aa` | `1d1fc1d1f9cb17bff95aebfd56c975a0658c32b3bedb99941ebbe6d82c23fcad` | 8211 |
| `contracts/adapter-observation-contract.md` | `fe8e3c525bfcacea0182d9e0d756c256d93d79f7034f6f1bce8938a3bd503e37` | `585c0625b42d5ffe6767ed6fe78a909705a05bb273573c55261be75918dc0dad` | 10449 |
| `contracts/kernel-operator-contract.md` | `26535eb29a6587b46217bff7a2ba29df3b0e5cda4095dae287120a1183639e21` | `391d9aa4d0850b081547e91c38806f1fe8b802f0ab70309fecd8597da57317c2` | 13518 |

## Validation

Read-only replay of the original validator. New logs only in grok-author-r2.

```
python3 review/semantic-kernel/p15-contracts-20260908/grok-author/validate_packets.py
```

Python 3.14.4, jsonschema 4.19.2, exit 0. Packets 3. Checks 9. Failures 0.
Binding hash pairs 21. Token0 capture files 7. Negative credit self-assert
rejected with 3 schema errors. Original
`grok-author/validate_packets.stdout.json` was not overwritten. All 8
prior grok-author files matched their pre-replay SHA-256.

Not run: Lean rebuild, solc, mutation campaign, P16/P17 implementation,
new generic validator.

## Remaining boundaries

1. Independent GPT-6 review of this R2 repair. Author cannot accept P15.
2. P16 implementation, pin-closure, solc/EVM harness, oracle repair,
   nonempty partitions including wrapped-sum overflow, fallback equation,
   production mutants and unaffected controls.
3. P16 repaired-slice planning review remains a separate gate.
4. P17 vault pin or `blocked_missing_source`. No theorem selected or
   instantiated for `P17.platform_reuse`.
5. P21 residuals, P30 source refinement, P19/P20 certificates. Certificates
   are not a P16 prerequisite.
