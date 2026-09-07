# Corpus provenance and adjudication decision

The [OpenSpec package](../openspec/changes/corpus-provenance-adjudication/proposal.md)
is a review-ready draft for a separate corpus overlay. Its planning gate and all
28 implementation tasks remain pending. Sprint 9 is accepted at source
`eec499d613688137a341f3556cd80ca461dd2ee9` and archived/delivered at
`9908d9b56be2d5ed2b58a16fa8d28b23f33733ff`. Sprint 10 still awaits substantive
native Fable planning review; its implementation gate remains closed.

The 72 historical rows and 75 development candidates remain immutable. There are
29 facet disagreements across 24 units, containing 32 disputed label instances
and 17 distinct disputed labels. The separate Liquity V1 liquidation challenge
concerns a label present in both raw sets. Its mechanisms facet is actually
`INTERSECTION_UNRESOLVED`, because redemption differs, at
`corpus/normalized/generated/corpus.json#/adjudications/77`. Historical `AGREE`
wording remains only shared-label shorthand, never a replacement facet rule.

[Retained source-research packets](../review/semantic-kernel/corpus-provenance-adjudication/source-research/)
now provide unaccepted drafts for all 29 disagreements and the separate Liquity
challenge. These include actual response bytes, scoped code pins where available,
raw or derived locators, extraction records and failed attempts. They can become
validated source inputs without needless fresh retrieval. Import validation must
preserve original capture times, tools, failures and limits and record its own
identity separately; it is neither a production `collect` run nor an adjudication
approval. Some research passes tried extra failed/fallback URLs while limiting
substantive bodies to three per unit. Those passes must not be described as
meeting the future collector's three-distinct-URL budget. Empty transport bodies
and failed requests supply no factual support.

The package keeps source identity, deployment verification and model fidelity
separate. Newly captured supporting material does not recover an original opaque
citation or missing attachment. All normalized deployment records still begin
unresolved, with zero verified deployments. Complete records with reviewed
unknown facts do not imply complete factual recovery or semantic closure.

The [twelve-proposal exposure audit](../review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/REPORT.md)
found all twelve development-exposed. They are exposure records, not additional
normalized rows. No untouched case is selected or certified. This package does
not select or read replacements. The evaluation manifest remains `not_selected`
with zero cases until a later independent freeze/selection process; an empty
manifest is not a passed evaluation.

[Refresh-03](../review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-03/REPORT.md)
preserves prior author artifacts and current research bytes while updating the
five-capability, 20-requirement, 48-scenario, 28-task plan and its source bindings.
Earlier `context-files.json`, scenario maps and author checks retain their
historical identities; current review must use refresh-03 bindings and the
parent's eventual exact official candidate. Live roadmap/progress context must be
frozen again for that candidate.

The original author is stock GPT-6 and cannot serve as the nonauthor planning
reviewer. The gate requires another stock GPT-6 reviewer and native Fable 5.1
(`claude-fable-5-1[1m]`, medium effort) on identical frozen inputs. Implementation
uses stock GPT-6, followed by native Grok/Fable substantive and evidence review.
No Foreman is used. AFK authorization permits routine work, not acceptance or
implementation while these gates remain open.
