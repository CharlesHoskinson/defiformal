# Example packets

These packets check that the schema loads and that credit cannot be
self-asserted. They are not P16 or P17 evidence.

| File | Status | Purpose |
| --- | --- | --- |
| `illustrative-not-credited.packet.json` | `illustrative` | Shape of a packet that cites historical Arithmetic without re-scoring it |
| `empty-denominator-blocked.packet.json` | `blocked` | Empty partition count cannot be success |
| `token0-unexecuted-incomplete.packet.json` | `incomplete` | Required token0 relation with zero actual runs |

All three set `credit_eligible` to false. Independent GPT-6 review of this
freeze does not turn these examples into accepted operation evidence.
