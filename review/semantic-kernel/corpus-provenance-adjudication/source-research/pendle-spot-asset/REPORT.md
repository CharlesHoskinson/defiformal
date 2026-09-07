# Pendle — draft source research

dispute-14/spot_asset: proposed **not_evidenced**. All remain unaccepted.

Unit `unit:lane2:c1:p0`; disputed facets dispute-14. [Exact raw A/B/generated observations](selection-and-observations.json) preserve each facet separately; all actual generated rules remain `INTERSECTION_UNRESOLVED`.

source statement: The documented Pendle V2 market trades PT against SY; PT is a maturity principal claim, YT carries pre-maturity yield rights, and SY wraps heterogeneous yield-bearing tokens. [amm](https://docs.pendle.finance/pendle-v2/ProtocolMechanics/LiquidityEngines/AMM), [architecture](https://docs.pendle.finance/pendle-v2-dev/HighLevelArchitecture)

source statement: SY redemption burns wrapper shares for an eligible output token. Routing may accept or return major assets around the PT/SY workflow. [amm](https://docs.pendle.finance/pendle-v2/ProtocolMechanics/LiquidityEngines/AMM), [standardized-yield](https://docs.pendle.finance/pendle-v2-dev/Contracts/StandardizedYield)

rule application limit: Trading a token immediately does not make its economic rights a spot asset: PT/YT’s claim rights defeat the annotation’s tradable-token shortcut. However these generic pages do not classify every concrete SY wrapper or routed output as the unit’s exposed instrument. [architecture](https://docs.pendle.finance/pendle-v2-dev/HighLevelArchitecture), [standardized-yield](https://docs.pendle.finance/pendle-v2-dev/Contracts/StandardizedYield)

bounded evidence gap: Without a specific market/instrument boundary and current ownership/control rights, the broad unit’s spot_asset label remains not_evidenced. This does not assert that no spot asset is ever handled by Pendle. [amm](https://docs.pendle.finance/pendle-v2/ProtocolMechanics/LiquidityEngines/AMM), [architecture](https://docs.pendle.finance/pendle-v2-dev/HighLevelArchitecture), [standardized-yield](https://docs.pendle.finance/pendle-v2-dev/Contracts/StandardizedYield)

Qualifications:

- The source version is current Pendle V2 documentation, whereas the corpus product version, market and deployment are unresolved. No historical source match is claimed.
- PT/YT claim semantics and SY wrapper rights must remain distinct. A spot underlying or an input/output routed through another venue is not automatically the direct instrument being classified.
- No specific SY implementation, accepted output token or settlement restriction was inspected. The documented generic redemption interface does not determine every wrapper’s rights.
- Do not reclassify PT as debt or YT as an option in this task. Other instrument taxonomy gaps remain outside this single-label review.

Retained 3 primary bodies (138215 bytes) from 3 target URLs. Failed attempts and exact source URLs/times/hashes remain in the retrieval manifests. No more than three bodies were retained for this unit. 7 source locators bind exact original bytes.

The [proposed disposition record](proposed-adjudication.json) binds the current proposed rule, per-label reasoning and full source provenance. No deployment/fidelity or canonical corpus acceptance is claimed.

Choose and source-bind the precise Pendle market/instrument exposure before applying R-spot_asset. Preserve the distinction between a current asset, a wrapper share, a principal/yield claim and an incidental router input/output.

Author: GPT-6 stock Codex harness. Independent review remains pending.
