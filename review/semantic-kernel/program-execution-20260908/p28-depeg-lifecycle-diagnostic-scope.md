# P28 public claim-processing diagnostic

Root executed eleven bounded cases through the pinned, unchanged `DepegProduct`, `ProductService`, and `PolicyDefaultFlow`. All three use their actual constructors. The 71 upstream compiler source strings and all 71 previously compiled contract creation/runtime objects match the prior compiler baseline.

The harness supplies mock registry/component/license, policy/instance service, price provider, treasury, and pool contracts. The mock application protects 100 token units per policy. The price fixture reports 80 against a target of 100. Policies begin in the mock controller's default active state; premium collection, underwriting, and application creation are outside this run. Claim creation and processing use the actual product's public functions. No real token moves.

| Case | Observed result |
| --- | --- |
| One claim, attested balance 150 | Processes 100 protected token units; mock payout 20; queue empty; mock policy closed. |
| Missing balance attestation | Exact `DP-043` refusal; claim remains queued; no processing effects persist. |
| Zero attested balance | Exact `DP-044` refusal; claim remains queued; no processing effects persist. |
| Claim creation by another actor | Exact `PRD-002` refusal; no claim created. |
| Processing without a queued claim | Exact `DP-042` refusal. |
| Three policies sharing balance 150 | First two consume 100 and 50 units and record payouts 20 and 10; third gets exact `DP-045` refusal and remains queued. |
| Owner reduces balance to 50 after 100 units were processed | Actual checked subtraction panics with code `0x11`; second claim remains queued. This differs from the zero-remaining `DP-045` branch. |
| Mock treasury deliberately reverts | The fixture refusal propagates through actual source calls. Queue removal, processed amount, mock confirmation, mock payout creation, and mock treasury effects all roll back. |
| Two-item processing batch, attested balance 100 | Second item refuses with `DP-045`; effects from the first item also roll back. Both claims remain queued. |
| Another actor submits balance attestations | Actual Ownable guard refuses; stored balance remains absent. |
| Attestation batch with one valid and two invalid records | Returns one accepted/two rejected; stores the valid 150 balance. Invalid entries do not revert the batch. |

Each EVM invocation returns twelve observed words. The executed harness checks exact revert/panic bytes internally; a marker in the returned array records that assertion's success. The twelve-word schema is in the diagnostic `result.json`. Python then checks concrete expected values. Root verification independently binds the command streams, source strings, compiled objects, selector, calldata, runtime and genesis. A deliberately altered payout expectation is rejected.

The compiler is the pinned Solidity 0.8.2 binary with optimizer 200 and its default Istanbul target. Execution uses the pinned geth EVM tool and existing local Paris genesis at block 0, timestamp 1. The 56,325-byte root harness is injected with `evm run` and exceeds EIP-170; normal deployment of this harness is not claimed. The actual constructed contract runtimes are 23,233 bytes (`DepegProduct`), 1,106 bytes (`ProductService`), and 13,138 bytes (`PolicyDefaultFlow`).

These observations do not prove real custody, controller accounting, oracle truth, deployed identity, arbitrary-state atomicity, or the complete insurance workflow. Mock treasury refusal is explicitly a fixture failure, not a reproduced TreasuryModule refusal. The permissive mock license does not establish real component authorization. Protected-wallet and owner refusal checks do execute the real product guards. Public processing runs as the diagnostic owner/protected wallet here; execution by an unrelated processing caller is not separately tested.

P28 tasks 29.1–29.3 remain open. Native AGY must implement the accepted source-faithful contract and proofs, and native Grok must independently audit them. This packet is root diagnostic evidence, not AGY implementation, Grok review, or P28 acceptance. Historical ABI-only packets remain unchanged.
