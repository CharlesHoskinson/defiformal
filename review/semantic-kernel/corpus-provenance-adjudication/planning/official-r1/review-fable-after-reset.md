VERDICT: REQUEST CHANGES

The package is unusually careful about what it does not claim, and its record model, exit contract, controls and exposure boundary are mostly implementable as written. Three normative gaps would let the implementation produce accepted outputs whose meaning is undefined or inconsistent. Each is a small design or spec amendment, followed by a re-freeze and a focused re-review of the amended text only.

BLOCKING FINDINGS

1. The effective facet view has no declared time and identity scope, so a source-scoped "supported" decision has no defined effect on a frozen historical unit.
The corpus is a frozen research snapshot dated 2026-08-04 with every version and deployment unresolved. SRC-07 says a claim supported only by retrieval-time documentation leaves the historical claim not evidenced while a current scoped claim can be reviewed separately. The 25 retained packets already apply this inconsistently. Rysk, Tether, Coinbase, Lido, Hyperliquid and Kalshi propose "supported" for the unit label from current documentation about one product path, while WBETH and Huma keep the unit-wide proposal at "not_evidenced" despite a supported source-scoped reading, and Lighter's support is conditional on a taxonomy interpretation. Nothing in decision 5 or the ADJ requirements says which of these is correct. Under one reading the overlay describes a 2026-09 product path and no longer describes the object the 72 rows described. Under the other reading almost every "supported" packet collapses to not evidenced.
Required change: add to each adjudication record a mandatory unit-applicability field with a closed enum, for example established, current_documentation_only, unresolved. State the rule by which each value affects the effective view. State whether the effective view is a historical-snapshot view, a current-documentation view, or two separately projected views. Require the coverage report to count supported decisions by that field. Until this exists, "resolve the 29 disagreements" is not a measurable statement.

2. A zero-byte body can pass as a retained capture and replay successfully.
BTCB and WBETH packets contain HTTP 202 responses with empty bodies whose capture path is the digest of the empty string, marked retained by the transport helper. SRC-06 says such a body cannot supply support, but the capture status enum in decision 3 has no state for it. A retained record with a zero-byte body has a matching digest, so the replay check in SRC-05 passes, and nothing prevents an evidence locator from pointing into it. This is the empty-denominator footgun in a new form.
Required change: add an explicit capture status for empty or non-substantive bodies, require body length greater than zero for retained, reject any locator whose span lies in a zero-length or redirect-wrapper body, and make import normalize the existing packets into that status with zero support credit.

3. Predicate interpretation rulings have no record type and no cross-unit consistency contract.
The rule table is frozen literally and the equivalence check confirms all 18 rows match across packet bindings. Lighter's packet is explicitly conditional on whether R-appchain includes application-specific rollups, and ApeX and edgeX are StarkEx validiums with the same question latent. Decision 5 only says new labels need a new predicate and version. It does not say how an interpretation of an existing predicate is recorded, versioned and applied uniformly to every unit it touches. Two reviewers could accept Lighter as appchain and edgeX as not appchain under one rule text.
Required change: define an interpretation record bound to a rule id and version, cite it from every decision that depends on it, and add a check that all accepted decisions for a rule with an interpretation ruling reference the same ruling. Absent a ruling, such decisions stay review_pending.

LESSER FINDINGS

4. The inventory denominators must be recomputed from the bound corpus, not read from the inventory file. CHK-03 and task 5.1 should derive the 29 facets, 32 label instances and 24 units by counting INTERSECTION_UNRESOLVED records in the generated corpus and comparing, so the queue file and the corpus check each other.

5. rules.json and the design table are two copies of the same rule text. Make one authoritative and check the other for literal equality, otherwise they drift the way the packets' bound design hashes already have.

6. Derived-text locators require retained extraction output for replay. Recording the extraction method and version is not enough for offline verification unless the extractor is pinned and deterministic. Require the retained derived text bytes and digest, or block replay of those locators with a specific reason.

7. Exposure is tracked per unit but sources describe other entities. The zkLink, Anemoy, StarkEx, Janus Henderson and Sky material retrieved for development units exposes those publishers. The development manifest should record, per retained source, the publishers and products it substantively describes, so a later overlap check can see them. Also verify collector rejection against development-manifest membership, not a role field in the request.

8. Collector budget accounting is ambiguous. State whether failed guesses, redirect targets and retries count toward the three distinct URLs. The CoW and Jupiter packets show slug corrections that would matter under one reading.

9. Queue dispositions need a closed terminal enum for exit 0. Distinguish not_attempted, attempted_unavailable, budget_exhausted and reviewed_unresolved, and count each in the report. Fifty-one units have no exact-ID packet, so most identity items will end in one of these states.

10. Effective-view precedence for conflicting accepted records on the same label needs a deterministic rule, for example latest non-superseded record per unit, facet, label and scope, with mixed dispositions in one scope yielding conflicting.

11. Task dependencies say package 6 can proceed independently, but task 2.4 needs the development manifest from 6.1 to enforce SRC-10. Reorder or state the dependency.

12. The in-change artifact-inventory.json, author-check.json, scenario-map.json and context-files.json are older than the current design, proposal and tasks. Task 1.1 should regenerate them at the official freeze or mark them historical so an implementer does not bind to the stale scenario map.

13. Verification of "no network during build and check" needs a mechanism, such as running under a socket-denying wrapper, not an assertion.

14. Recovery of an original citation mapping from a browsing transcript rests on trusting the transcript's provenance. Record that as an assumption rather than a verified status.

SCOPE LIMITS

This is a planning review of the normative text, five specs, tasks and the supplied corpus and packet context at candidate 5dc7abbf. I did not adjudicate any of the 29 facets, 32 label instances or the Liquity challenge, and I did not assess whether any packet's source reading is correct. Raw HTTP and PDF captures were not supplied; packet manifests and hashes were taken as recorded. No CLI was run. The normalization check evidence supplied is from earlier heads and the corpus control suite retains its c880 identity through recorded source equivalence, so a fresh run at the frozen candidate remains an implementation obligation. All 75 units and the twelve proposed cases remain development exposed, no holdout is selected, and nothing here changes that. Acceptance of the amended plan would still not establish deployment identity, model fidelity or recovery of the original attachments.
