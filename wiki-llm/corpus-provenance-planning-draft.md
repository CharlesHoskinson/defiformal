# Corpus provenance follow-up: planning draft

> Current refresh-03 context (2026-09-07): Sprint 9 is accepted at source
> `eec499d613688137a341f3556cd80ca461dd2ee9` and archived/delivered at
> `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff`. Sprint 10 awaits substantive
> native Fable planning review, with implementation gated. The historical research
> below retains its original measurement and retrieval identities. Later retained
> source packets now cover draft decisions for all 29 facet disagreements / 32
> disputed label instances plus the separate Liquity liquidation challenge; none
> is accepted. Validated import preserves original bytes, extraction, tools,
> times, failures and research limits without inventing a production collector
> run or requiring duplicate retrieval. Earlier three-body research bounds are
> not the future collector's three-distinct-URL budget. The twelve proposed
> evaluation cases were all audited development-exposed; none is untouched and
> no replacement is selected. See the [current decision](corpus-provenance-adjudication.md)
> and [refresh-03 author evidence](../review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-03/REPORT.md).

Status: bounded design inputs, 2026-09-07 UTC. This document proposes a later OpenSpec change; it does not adjudicate annotations, certify deployments, acquire holdouts, or change corpus outputs. Prepared through the stock GPT-6 Codex harness. No Foreman or reviewer approval is implied.

The recommended next step is an append-only, source-backed adjudication layer for the existing development corpus. Preserve raw annotations, mechanical agreement records, unresolved provenance, and historical source bytes. Start with the 29 observed differences and the separate Liquity V1 challenge. A reviewed unresolved outcome is valid when the evidence cannot determine a label.

## Authority and measurement boundary

Read the repository instructions, approved semantic-kernel design/progress, corpus documentation and Sprint 3 adjudication/challenge artifacts. The graphify query `Corpus normalization 75 candidates 29 annotation disagreements Liquity V1 unresolved source references untouched holdouts` completed but returned historical material rather than current normalization records. The existing graph is navigation only; direct source files below determine this inventory. No graph rebuild or saved graph result was requested.

The brainstorming skill was used to compare bounded approaches and expose assumptions. Existing user authorization permits autonomous planning; this draft requires no new permission and makes no implementation or commit claim.

At inventory measurement, source HEAD was `6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`. The read-only command `python3 scripts/corpus_normalize.py check --repo .` returned exit 0 and:

> OK check: 72 source rows; 75 candidate units; 375 facet decisions; 346 provisional agreements; 29 unresolved differences. No semantic accuracy claim.

All 18 inspected corpus/proposal files retained identical SHA-256 values and nanosecond modification times across that check. This is a bookkeeping verification, not a financial or protocol-fidelity result. The fingerprints at the end bind the principal planning inputs independently of subsequent proof-only repository commits.

## Current inventories

| Population | Current count / status |
| --- | --- |
| Historical source lanes | 3 files: 22 + 30 + 20 = 72 rows, all 72 mapped |
| Normalized candidate units | 75: the Liquity parent has 2 children; the Ondo parent has 3 |
| Normalization status | 70 `needs_identity_review`; 5 `split_candidate` |
| Organizations / products | 75 `label_only` organizations; 75 `provisional` products |
| Version identity | 11 `source_label`; 64 unresolved; a source label is not a code revision |
| Deployment identity | 75 unresolved; 0 verified; all chain/address/source-revision fields null |
| Evaluation role | 75 development; 0 untouched |
| Facet decisions | 375 = 75 × 5 |
| Annotation agreement | 346 provisional: 279 nonempty + 67 empty |
| Annotation differences | 29 facet decisions across 24 units |
| Separate semantic challenges | 1 open challenge on an agreed Liquity V1 label |
| Existing retained primary sources | 3 excerpt records, concerning Liquity V1, Liquity V2 and Ondo |

The two annotations came from independent contexts in the same GPT-6 model family. They are neither human annotations nor independent-provider validation. Agreement is an elicitation observation. Empty sets mean not evidenced, not absence.

| Facet | Agreed nonempty | Agreed empty | Differences |
| --- | ---: | ---: | ---: |
| `economic_functions` | 70 | 0 | 5 |
| `execution` | 30 | 39 | 6 |
| `instruments` | 69 | 3 | 3 |
| `mechanisms` | 63 | 4 | 8 |
| `trust` | 47 | 21 | 7 |

The following is the complete current disagreement inventory. A-only and B-only are set differences, not full proposed label sets; the existing intersection is preserved. The dash means an empty difference, not a negative factual claim.

| Unit / historical label | Facet | A-only | B-only |
| --- | --- | --- | --- |
| `unit:lane1:c1:p3` / JustLend V1 | `mechanisms` | collateralization | — |
| `unit:lane1:c1:p4` / Maple | `mechanisms` | allocation | — |
| `unit:lane1:c2:p3` / Lista CDP | `trust` | — | issuer, keeper |
| `unit:lane1:c2:p4:v1` / Liquity V1 | `mechanisms` | — | redemption |
| `unit:lane1:c3:p0` / Lido | `trust` | — | curator |
| `unit:lane1:c3:p1` / Binance staked ETH (WBETH) | `economic_functions` | offchain_claims | — |
| `unit:lane1:c3:p4` / Babylon Protocol | `instruments` | — | spot_asset |
| `unit:lane2:c0:p0` / Hyperliquid | `mechanisms` | allocation | — |
| `unit:lane2:c0:p1` / ApeX Protocol (ApeX Omni) | `trust` | attester | — |
| `unit:lane2:c0:p3` / Lighter | `execution` | appchain | — |
| `unit:lane2:c0:p4` / edgeX | `trust` | attester | — |
| `unit:lane2:c0:p5` / Jupiter Perpetual Exchange | `economic_functions` | asset_management | — |
| `unit:lane2:c0:p5` / Jupiter Perpetual Exchange | `mechanisms` | allocation, redemption | — |
| `unit:lane2:c1:p0` / Pendle | `instruments` | spot_asset | — |
| `unit:lane2:c1:p1` / Spark Savings (sUSDS / Sky Savings Rate) | `execution` | async_cross_domain | — |
| `unit:lane2:c1:p4` / Huma Finance V2 | `economic_functions` | asset_management | — |
| `unit:lane2:c1:p4` / Huma Finance V2 | `mechanisms` | allocation | — |
| `unit:lane2:c1:p4` / Huma Finance V2 | `trust` | — | attester |
| `unit:lane2:c2:p0` / WBTC | `execution` | async_cross_domain | — |
| `unit:lane2:c2:p0` / WBTC | `trust` | legal_obligor | — |
| `unit:lane2:c2:p2` / Coinbase Bridge (cbBTC and other wrapped assets) | `mechanisms` | mint_burn | — |
| `unit:lane2:c2:p2` / Coinbase Bridge (cbBTC and other wrapped assets) | `execution` | async_cross_domain, offchain_legal_settlement | — |
| `unit:lane2:c2:p4` / Binance Bitcoin (BTCB) | `execution` | async_cross_domain | — |
| `unit:lane2:c3:p7` / CoW Swap | `mechanisms` | collateralization | — |
| `unit:lane3:c1:p1` / Rysk V12 | `trust` | curator | — |
| `unit:lane3:c2:p0` / Tether USDT | `execution` | async_cross_domain | — |
| `unit:lane3:c3:p0` / Kalshi | `economic_functions` | — | exchange |
| `unit:lane3:c3:p1` / Polymarket | `economic_functions` | — | exchange |
| `unit:lane3:c3:p4` / Grove Finance (Onchain Capital Allocator) | `instruments` | — | fund_share |

`SPRINT3-LIQUITY-V1-LIQUIDATION` is a separate item for `unit:lane1:c2:p4:v1`, mechanism `liquidation`. Both annotations included liquidation. Grok challenged child-specific evidence for that label; Fable found no split-child inheritance bug. Liquidation belongs to both raw label sets. The actual mechanisms facet at `corpus/normalized/generated/corpus.json#/adjudications/77` is `INTERSECTION_UNRESOLVED`, because B also includes redemption. Preserve that record and the historical challenge text; its `AGREE` wording refers only to shared label membership. Do not count the separate liquidation challenge as a thirtieth facet disagreement. Its existing status remains `open_targeted_source_evidence` until a separately versioned evidence adjudication is accepted. The same unit's actual annotation difference concerns `redemption`.

## Approaches and recommended boundary

| Approach | Benefit | Cost / limit | Recommendation |
| --- | --- | --- | --- |
| Append evidence decisions to the frozen development inventory | Preserves provenance and permits explicit unresolved results | Requires a separate adjudication schema and review trail | Adopt; first queue is 29 differences plus 1 challenge |
| Reannotate and replace the old answers | Simple current label table | Erases the original elicitation and can hide unresolved disagreements | Do not replace; any later reannotation must be a new run |
| Resolve every deployment before any facet work | Strongest eventual identity boundary | Unbounded acquisition work; many historical names bundle versions/products | Separate track, with no promise to verify all 75 |

A first OpenSpec change should implement provenance and adjudication records for development cases only. Deployment expansion and any new untouched evaluation need separate manifests and acceptance gates. Do not set a target agreement percentage: forcing every case to agree would reward unsupported decisions.

## Candidate deterministic rules

Retain existing taxonomy rules `DIRECT_SERVICE`, `SOURCE_ONLY`, `BUNDLE_CONTEXT`, `BRAND_IS_NOT_DEPLOYMENT`, `AGREE`, and `INTERSECTION_UNRESOLVED`. Version additional rules before use. Deterministic means identical recorded evidence and rule versions yield identical bookkeeping; deciding what a source establishes still requires explicit, reviewable judgment.

1. **Identity and time before labels.** Every claim names its unit, product/version scope and observation time. Parent-brand text cannot establish a split child's mechanism unless explicitly applicable to that child. Unresolved child identity produces an unresolved claim, not inherited certainty.
2. **Direct service before dependency.** A function describes what the scoped product supplies. Holding another product's token or relying on its mechanism does not automatically add that function. Instrument, service, mechanism, execution environment and trust role remain distinct facets.
3. **Behavioral evidence for mechanisms.** Require a cited passage or source location that describes the operation and relevant conditions. Labels such as collateralization, allocation, auction, custody, mint/burn, redemption and routing need separate support; one does not imply all the others.
4. **Execution is not branding.** Cross-chain availability does not establish asynchronous cross-domain execution. Require evidence of the relevant message/state transition or settlement boundary. A branded chain name alone does not establish a product's full execution model.
5. **Trust roles name an authority.** Identify the actor and authority or obligation that justifies attester, curator, custodian, issuer, keeper, legal obligor, oracle or validator-set classification. An organization name or operator title is insufficient. Off-chain legal settlement needs evidence of the scoped settlement/legal claim, not an inference from custody alone.
6. **No absence from silence.** Missing documentation, an empty annotation, or failure to find a label is `not_evidenced`. Use `refuted` only for evidence contradicting the scoped claim. No silent conversion of unknown to false.
7. **Source conflict is retained.** Prefer version-specific evidence over broad marketing summaries for a version-specific claim, and distinguish source-code behavior from claims about deployed behavior. If versions, times or authoritative sources conflict without a justified resolution, record both and retain `conflicting` or unresolved identity.
8. **Separate observation from judgment.** Raw A/B answers, their intersection and `AGREE` records never change. An evidence overlay references them and records `supported`, `refuted`, `not_evidenced`, `conflicting`, or `not_applicable`, with rationale. Keep review process status separate from the factual disposition.
9. **No provider vote as truth.** Native Grok and Fable reviews can identify unsupported interpretations. Record exact model identities, source/revision bindings, findings and dissent; an unavailable reviewer is an open review. Neither agreement nor Lean bookkeeping proves protocol fidelity.

The 24-unit queue above is bounded. It can be ordered by identity clarity, then mechanism/function/trust/execution questions, but unresolved identity must not be silently repaired by selecting a convenient version. The Liquity V1 challenge and redemption difference are a small first source package because the existing unit already supplies a version label.

## Primary-source pilot: existing Liquity V1 development unit

Only an existing development case was researched. The V1-specific liquidation FAQ explicitly describes liquidation and its debt/collateral handling. This supplies child-specific material absent from the original parent-text rationale. It supports proposing a new adjudication of the liquidation label; it does not itself close the stored challenge. [Official V1 liquidation FAQ](https://docs.liquity.org/liquity-v1/faq/stability-pool-and-liquidations), retrieved 2026-09-07 UTC.

The V1 redemption FAQ describes exchanging LUSD for ETH, with applicable fees, and distinguishes redemption from a borrower's repayment. It supplies direct evidence relevant to the existing redemption difference. Treat this as scoped documentation, not a guarantee of unconditional execution. [Official V1 redemption FAQ](https://docs.liquity.org/liquity-v1/faq/lusd-redemptions), retrieved 2026-09-07 UTC.

The official V1 repository resolves `main` to commit `3e64ee1b52c50d51587c64c1cf75e0ba82934979` at retrieval. Its `TroveManager.sol` contains liquidation entry points, distinct normal/recovery handling, offset/redistribution logic, and `redeemCollateral` with guards. This is corroborating implementation evidence for those mechanisms in that source revision. It does not bind a chain, deployed address, bytecode or the historical 2026-08-04 corpus state. [Pinned official contract](https://github.com/liquity/dev/blob/3e64ee1b52c50d51587c64c1cf75e0ba82934979/packages/contracts/contracts/TroveManager.sol), retrieved 2026-09-07 UTC.

| Response | Retrieval UTC | HTTP / bytes | SHA-256 of response body |
| --- | --- | --- | --- |
| V1 liquidation FAQ, URL linked above | 2026-09-07T07:26:41.439767+00:00 | 200 / 497128 | `894514a333e4affea46c1640e3af78b1f275cf05cb231e631b0302d119e565ab` |
| V1 redemption FAQ, URL linked above | 2026-09-07T07:27:03.695288+00:00 | 200 / 428349 | `186a31d73883ce8ecfd55aec081ac19c8759c4e6bc78fdf7560d4e786c64c57e` |
| [Official commit API](https://api.github.com/repos/liquity/dev/commits/main) | 2026-09-07T07:25:28.431991+00:00 | 200 / 7233 | `eb48ebdce2dbd205f79c4cbda90c011225dfbca48d5a39e1a047d2679ce8e1ef` |
| [Pinned raw contract](https://raw.githubusercontent.com/liquity/dev/3e64ee1b52c50d51587c64c1cf75e0ba82934979/packages/contracts/contracts/TroveManager.sol) | 2026-09-07T07:25:30.312405+00:00 | 200 / 68444 | `30871ff587a8d0208340699023c2ce3f9f2279d1472cb4448770d74bf81b1c96` |

The successful FAQ retrievals used Python urllib after the browsing tool could not render the liquidation page. An initially guessed redemption URL returned 404; the linked successful URL came from the site's navigation. No missing response was treated as evidence. Requested and final successful URLs were identical. Hash input is exact response-body bytes, excluding headers. These bodies were inspected in memory and are **not archived in this planning deliverable**. The table is a retrieval record, not a completed reproducible evidence package; a later implementation must capture permitted evidence and locators explicitly. No financial threshold or guarantee needs to be imported into the taxonomy to adjudicate whether these mechanisms exist in the cited source.

## Source gaps and what can be resolved autonomously

Current `primary-excerpts.json` holds three brief excerpts retrieved on 2026-09-06, requested/final URLs, response digests and excerpt digests. Full bodies were temporary and are not committed. These excerpts corroborate names/version distinctions; they do not verify all narratives, deployment identities or historical state. A body hash does not recover missing bytes. Current Ondo navigation naming also does not establish a historical rename or equivalence for the Global Markets child.

Public primary documentation, official versioned source repositories, deployment manifests and chain records can be acquired without asking the user. They can support current product behavior and source revision identities. A verified deployment would additionally need chain identifier, address, observation block/time, proxy/implementation resolution where relevant, and a check connecting deployed code to the claimed source. Record unavailable and contradictory evidence explicitly. Historical claims need contemporaneous archives, releases or chain records; today's documentation alone cannot establish them.

The original proposal has **62 opaque citation-token occurrences, 45 distinct tokens, zero ordinary HTTP(S) source URLs, and two sandbox links**:

- `sandbox:/mnt/data/defi_kernel_corpus_crosswalk.csv`
- `sandbox:/mnt/data/defi_kernel_taxonomy_schema.json`

The Sprint 3 recovery record reports that those original artifacts were not found in the accessible local search and that `/mnt/data` was absent. This draft does not claim a new exhaustive filesystem search. The current normalized crosswalk and taxonomy are reconstructions, not recovered original attachments. In particular, the missing original crosswalk cannot substantiate the proposal's original 31/72 multifunction count.

Opaque tokens such as `turn10search0` are not public locators. Matching a current page to a nearby claim cannot recover the original token-to-URL mapping. A later bibliography can supply `reconstructed_support` with its own URL, date and scope; preserve the original pointer as unresolved. The original attachment bytes or original browsing transcript would be needed to recover their exact contents or mappings truthfully. Public research can replace support for a claim, but cannot establish an unknown original provenance chain.

The follow-up should inventory each original claim/pointer before acquisition, distinguish already exposed development material from reserved evaluation material, and research only the development side. Do not follow proposed holdout references merely to fill a bibliography before the evaluation freeze. Citation completeness and untouched status are separate requirements.

## Proposed evidence and adjudication records

Use immutable source records with a stable ID, requested/final URL, retrieval time, status/content type, response-byte digest and retained-body location or an explicit capture limitation. Include exact excerpt/code locators, product/version/time scope, source revision and deployment fields when supported, and the original proposal pointer where applicable. Preserve earlier records when a page changes. An immutable source-code URL pins code; a mutable documentation URL plus an unarchived hash is a weaker record.

Each adjudication references the frozen unit/facet/label, annotation input hashes, evidence IDs and spans, rule/taxonomy version, disposition, rationale, unresolved assumptions, and review identities/results. Include a supersedes link rather than replacing earlier judgments. One evidence item can support several claims, but each claim requires its own scoped rationale. Preserve the distinction between source assertions, analyst inference, bounded checks and mathematical proof.

## Development and untouched manifests

All existing 75 candidates remain development permanently. Historical examples and any case already inspected to design the kernel, primitives, taxonomy or adjudication rules are exposed. A proposed holdout list is not certification of untouched status; merely renaming or splitting an exposed product is insufficient.

Before selecting or unsealing new evaluation cases, freeze the kernel/library, taxonomy, translation instructions, adjudication rules, evaluator and development manifest by Git revision and content hashes. An independent curator can maintain the selection and exposure records without feeding case semantics to builders. Use explicit novelty criteria and a declared sampling population; do not promise a fixed untouched count before this manifest exists.

The untouched manifest should bind case IDs, product/version/deployment boundaries where known, source package hashes, curator identity, selection time, freeze revision, exposure audit and unsealing/access log. Metadata inspection must be recorded and must not include semantic design feedback. Check overlap at organization, product, version, mechanism and source-example levels according to the declared evaluation claim; disclose allowed overlap rather than claiming stronger novelty.

Unseal once for the frozen evaluation. Report attempted, translated, checked, failed and blocked denominators separately. A case consulted to change the model becomes development or a clearly identified post-freeze adaptation case. Re-evaluation after adaptation is useful regression evidence, but cannot retroactively become the original untouched result. Keep the original frozen result and excluded-case reasons.

This planning pass acquired no proposed untouched-case sources and made no annotation edits. The source pilot above concerns only Liquity V1, already in the development corpus.

## Inputs for the later OpenSpec change

The bounded implementation should satisfy these acceptance scenarios:

1. Reproduce the current 72/75/375/346/29 inventory from frozen inputs and preserve their hashes. Duplicate/missing units, empty declared check inventories, unbound sources, and unsupported status promotion are blocked rather than counted as success.
2. Represent all 29 differences and the one separate challenge without changing A/B answers or inventing a thirtieth difference. Every queued item receives an explicit reviewed disposition, including honest unresolved outcomes; no forced completion of missing financial facts.
3. Resolve the Liquity pilot only through version-specific captured evidence and a separately versioned decision. Native Grok/Fable source review records exact candidate/evidence identity and retains dissent. Review acceptance does not certify deployed protocol fidelity.
4. Distinguish a retrieved current source, a reproducibly retained source package, a verified deployment, a historical-state claim, and recovered original provenance. A current URL or digest alone must not pass stronger gates.
5. Keep the deployment-verified count at zero until actual deployment checks exist. Do not infer identity from names, rankings or parent bundles. Missing originals remain unresolved even if replacement sources are found.
6. Exercise the actual normalization/adjudication CLI with missing, duplicated, altered and conflicting evidence controls, together with valid siblings. Define test counts in the implementation plan after the interface exists; these controls validate the bookkeeping boundary, not protocol semantics.
7. Emit separate development and untouched manifests with exposure/freeze checks. Any attempted promotion of an exposed case to untouched must fail. Blocked or empty evaluation batches cannot be reported as validation.

No source acquisition for new holdouts, broad corpus relabeling, kernel modification, or claim of complete source recovery is included in this first change. These limits make the proposed result reviewable while preserving unresolved work.

## Principal input fingerprints

Paths are relative to the repository. Historical lane hashes are already bound by `inputs/source-manifest.json`; raw source/annotation bytes remain authoritative.

| Input | SHA-256 |
| --- | --- |
| `corpus/normalized/inputs/source-manifest.json` | `2d9b70729adf7743f0376893220afdc78277f08611f08fa2c2e3170a0b7d3c48` |
| `corpus/normalized/inputs/identity-map.json` | `6cda8464f7b2effbec57cd6c1a88bb25b9d32a236a38d86707b5518f1e2eecb0` |
| `corpus/normalized/inputs/annotation-input.json` | `dc36166d26447203ba5af7f12db14f53d4ab1865dcace85955b58e026f3ef8e2` |
| `corpus/normalized/inputs/taxonomy.json` | `8f854470619216917fef489bb93c62afa8e56da6d1cfc8dd68afc7a46beed681` |
| `corpus/normalized/annotations/a.json` | `bef2613e0d4a1b88fcd179a5b051e8eb942610a6299d15e553187705890bc007` |
| `corpus/normalized/annotations/b.json` | `b2d30c390da953c464169f805aef1e4bcfaeeec076bc6c235cc6872536a47022` |
| `corpus/normalized/generated/corpus.json` | `43455c0a4bd490eea9f723a93ca18df10f79741f96ab16f73ef301cf919c0c90` |
| `corpus/normalized/generated/coverage.json` | `e199548b467ef919b1e5600d7be3675c2ff3672800f5619912204434534895fe` |
| `corpus/normalized/sources/primary-excerpts.json` | `f408fa630e27e207d60c6b93fca6c36037dc1b4fb3a3391a82664b86361cd794` |
| `docs/research/2026-09-06-defi-source-plan.md` | `c458c6c9e32675afe6a6aa44e6f1a6767d3963accb6d291ec24e6212ecac9975` |
