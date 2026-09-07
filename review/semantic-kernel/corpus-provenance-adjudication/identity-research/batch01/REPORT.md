# Identity/source research batch01

**Draft author research; no identities or annotations accepted.** The first 16 entries of consolidated-01/remaining-research-queue.json were processed in their stored order. All original rows, split rules and residue are preserved in selected-units.json.

| Order | Original unit | Source label | Card |
|---|---|---|---|
| 1 | `unit:lane1:c0:p0` | Uniswap | [u01](cards/u01.md) |
| 2 | `unit:lane1:c0:p1` | PancakeSwap | [u02](cards/u02.md) |
| 3 | `unit:lane1:c0:p2` | Curve | [u03](cards/u03.md) |
| 4 | `unit:lane1:c0:p3` | Raydium | [u04](cards/u04.md) |
| 5 | `unit:lane1:c0:p4` | Fluid | [u05](cards/u05.md) |
| 6 | `unit:lane1:c1:p0` | Aave V3 | [u06](cards/u06.md) |
| 7 | `unit:lane1:c1:p1` | Morpho | [u07](cards/u07.md) |
| 8 | `unit:lane1:c1:p2` | SparkLend | [u08](cards/u08.md) |
| 9 | `unit:lane1:c1:p5` | Compound V3 | [u09](cards/u09.md) |
| 10 | `unit:lane1:c2:p0` | Sky (Sky Lending, ex-MakerDAO) | [u10](cards/u10.md) |
| 11 | `unit:lane1:c2:p1` | Ethena (USDe / sUSDe) | [u11](cards/u11.md) |
| 12 | `unit:lane1:c2:p2` | USDD | [u12](cards/u12.md) |
| 13 | `unit:lane1:c2:p4:v2` | Liquity V2 | [u13](cards/u13.md) |
| 14 | `unit:lane1:c2:p5` | crvUSD | [u14](cards/u14.md) |
| 15 | `unit:lane1:c3:p2` | EigenCloud (EigenLayer) | [u15](cards/u15.md) |
| 16 | `unit:lane1:c3:p3` | ether.fi (eETH / weETH) | [u16](cards/u16.md) |

Exactly 48 primary target URLs were attempted within the three-target budget for each of 16 original units. There were 52 attempts:44 successful transport responses and 8 failed attempts across 4 targets. Two attempts per target, 30-second curl timeout, 5 redirects and 5 MiB body limits were enforced. The largest retained body was 892,615 bytes; maximum curl duration 1.378 seconds; maximum redirects 1. Full commands, stdout, stderr, response headers, status, UTC timestamps and byte hashes are retained for every attempt.

Eight responses contain repository commit metadata; eight READMEs were then acquired at those exact commits. Four further READMEs were decoded from primary GitHub content envelopes and verified against their Git blob IDs. These four do not have a resolved commit/release identity; one contains only a repository title. None is a captured implementation tree or a source-to-deployment proof. Four navigation/short-orientation responses are classified separately. The 31 substantive-document/readme category includes development documentation and does not mean 31 financial mechanisms verified.

The failed targets are the former Ethena USDe URL (404 twice), former crvUSD overview URL (404 twice), EigenCloud docs root (403 twice), and candidate SparkLend README URL (404 twice). All failure bytes are retained. Focused alternative docs/pinned EigenLayer README used remaining allocated target slots. No unit exceeded its target budget, and no new fallback pass beyond that budget was performed.

Material follow-ups: Aave V3 core is explicitly deprecated in its pinned README; V3 Origin remains an unacquired pointer. Current crvUSD documentation distinguishes market-specific Controller/AMM blueprints. Current ether.fi product documentation says eETH/weETH do not bundle additional restaking rewards and describes an August 2026 residual wind-down; its pinned README still describes native restaking and KING rewards. Those descriptions remain separately scoped and unresolved. SparkLend, Fluid DEX, Morpho Blue and Curve DEX are kept separate from siblings and dependencies.

Offline verification passed **2746 nonempty checks** over 16 cards, 35 literal claim locators, retained hashes, text-extraction replay, exact original JSON pointers, retrieval budgets and 546 protected existing files, including all 88 frozen Sprint10 inputs. Before and after HEAD: `5dc7abbf520ad01ed7a1681d70b492855080a16d` / `5dc7abbf520ad01ed7a1681d70b492855080a16d`. HEAD did not move during the measured interval; the verification permits unrelated HEAD movement and binds each relevant Git object/current byte separately. Changing corpus normative drafts and concurrent identity batches were excluded from immutable-input requirements.

One development verification attempt failed because the author script expected canonical field `id` instead of actual `unit_id`. The original script, stderr and partial after-snapshot are preserved under development-attempt-1. The corrected verifier then completed. This was an evidence-script defect, not a source-retrieval or corpus failure.

All 16 cards retain accepted=false, identity_resolved=false and deployment_verified=false. Documented addresses are candidates only. Brand, organization, maintainer, legal issuer and deployment identity are not collapsed. No label is inherited from a sibling/dependency or rejected from absence of evidence. No source commands were executed, no production collector was implemented, no canonical corpus or prior packet was edited, and no native review or commit was performed. The original 51-entry remaining queue is unchanged; these packets do not subtract 16 accepted resolutions from it.

Machine-readable entries: identity-index.json, cards/uNN.json, source-index.json, source-assessment.json, retrieval-summary.json, verification.json and protection-before/after.json. The artifact manifest binds the complete retained batch; final-verification.json seals that manifest separately to avoid self-reference.
