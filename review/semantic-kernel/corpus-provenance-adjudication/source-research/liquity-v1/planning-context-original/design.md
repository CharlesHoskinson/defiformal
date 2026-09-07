## Context

See `proposal.md` and the source-bound inventory in
[planning research](../../../wiki-llm/corpus-provenance-planning-draft.md). The original 72 rows produce 75 candidates,
375 facet decisions, 346 provisional agreements and 29 differences across 24
units. There are 11 source version labels, 64 unresolved versions and zero
verified deployments. Every candidate is development. The separate Liquity V1
liquidation challenge concerns an agreed label, while its actual disagreement is
redemption. `dispute-inventory.json` freezes these distinct observations.

The original proposal contains 62 occurrences of 45 opaque citation tokens and
two unavailable sandbox attachment references. These are unresolved provenance.
The current three primary excerpt records and the planning-only Liquity V1
retrievals do not constitute deployment evidence or recovered original files.

This independent later package does not depend on Atomic runtime changes and is
not accepted Sprint 8 implementation. User AFK authorization covers routine
execution choices; exact planning/native acceptance gates still apply.

## Goals / Non-Goals

**Goals:** Lossless, offline-checkable evidence decisions; a complete finite
source/identity work ledger for the 75 candidates; additional justified splits;
source pins, dependencies and residues; all 29 disagreements and the separate
challenge individually accounted for; preserved original-reference uncertainty;
and enforceable development/evaluation separation.

**Non-goals:** Overwriting historical lanes, source proposal, raw A/B answers or
accepted normalized outputs; claiming that all external facts can be recovered;
requiring all 75 deployments to become verified; implementing model adapters,
differential financial testing or refinements; selecting or acquiring new
holdout semantics; changing Lean, taxonomy 0.1.0 or historical `SOURCE_ONLY` rules.
Source inspection is distinct from implementation-to-model fidelity.

## Decisions

### 1. Append a new overlay with explicit layer boundaries

Create `corpus/adjudicated/v1/` with `schema.json`, `rules.json`,
`inputs/{baseline,work-queue,source-requests,sources,identities,dependencies,residues,references,
adjudications,exposure,freeze}.json`, permitted captures under `sources/sha256/`,
and `generated/{corpus,coverage,development-manifest,evaluation-manifest}.json`.
A baseline record binds every old source, identity, annotation and output by
path/digest and its source Git revision. Raw historic records remain byte exact.
Additional splits add new IDs and `derived_from` links to the existing candidate;
they never renumber or remove its historical row. Derived candidate count is
reported separately from the invariant 75 original candidates/72 original rows.

Use `scripts/corpus_adjudicate.py` as the CLI, focused helpers in
`scripts/corpus_adjudication/`, and
`scripts/test_corpus_adjudication.py` for actual subprocess controls. Preserve
`scripts/corpus_normalize.py` behavior. JSON Schema Draft 2020-12 uses the existing
pinned `jsonschema==4.19.2`; no new runtime dependency is required. Sorted IDs,
sorted set-valued arrays, stable source-order legacy rows, UTF-8, two-space JSON
indentation and one final LF define canonical output. Run times belong to run
manifests, not deterministic generated projections.

Alternative considered: replace old annotation answers. Rejected because it
would erase disagreement evidence. Alternative: resolve every deployment first.
Rejected as a precondition because public evidence may not identify a historical
bundle; the explicit unresolved record is still valuable and testable.

### 2. Complete finite work accounting, not fabricated factual closure

The initial queue contains all 75 candidate identity reviews, all 29 facet
records, one separate challenge, all 62 original citation occurrences and two
attachment pointers. Each item has a stable ID, source pointer, exposure role,
allowed acquisition scope, attempt references and current disposition. Distinct
citation tokens are additionally grouped into 45 mapping records. The same
retrieved source can serve several queue items without duplicating its bytes.
`source-requests.json` is an explicit development-only acquisition projection of
this ledger, with parent item IDs. Reference items of unknown/reserved exposure
remain inventoried but ineligible for acquisition. The projection records why
each unselected ledger item has no request; selection does not erase that item.

Before acquisition, extract all additional source-named product/version bundles
from the 75 development records into candidate split decisions. For each, either
record evidence-supported child identities or `unresolved_bundle` with the exact
parent spans. Do not enumerate children from brand knowledge. Each original row's
residue/forced-fit fields survive unchanged; new residues name their own scoped
claim, kind (`identity`, `semantic`, `modeling`, `external_assumption`), evidence,
reason, and disposition. No candidate count is predetermined beyond the frozen
75 baseline. Every candidate receives an explicit dependency assessment, including
`not_evidenced`; an empty edge list does not establish independence.

The bounded first acquisition pass allows at most three distinct primary source
URLs per original candidate, prioritizing version-specific official docs, pinned
code/release manifests, then deployment records. Each request has 30-second
connect/read bounds, at most two retries and five redirects; each body is limited
to 20 MiB and the pass to 512 MiB. Exhaustion records `budget_exhausted` and the
unexamined queue, never success for those items. A new explicit acquisition-pass
manifest can extend these bounds later without rewriting earlier evidence.
Secondary sources can locate primary material but cannot alone promote a
version/deployment or decide a disputed label. Record all failed attempts.

### 3. Capture, bibliography and original recovery have separate statuses

A source record includes `source_id`, original/requested/final URL, UTC retrieval,
HTTP status/content type, body byte length/digest, capture path or explicit
unavailability reason, extraction method/version, excerpt/code locators,
product/version/time scope and source-authority rationale. Use `capture_status`
`retained`, `fingerprint_only`, `unavailable`, or `restricted`. Evidence locators
bind exact retained bytes; a digest without bytes cannot pass a replay check.
Mutable docs support retrieval-time assertions; archived historical material must
have an explicit historical scope. A current code commit alone does not establish
historical deployment behavior.

Store permitted captures. If redistribution or access prevents retaining needed
bytes, record the limitation and keep dependent replay/factual claims unresolved;
do not bypass access controls or treat an inaccessible URL as captured evidence.
A later authorized local evidence package can carry restricted material without
inventing a public artifact. Network acquisition is explicit and separate from
build/check, which never fetch or refresh a page.

Every original occurrence retains exact token/text, byte offsets, proposal hash
and associated claim span. Pointer statuses are `unresolved_original`,
`recovered_original`, or `reconstructed_support`. Recovery requires the actual
original attachment bytes plus their origin record, or an original browsing
transcript mapping the citation token to its URL. Matching a claim to a new web
page is only reconstructed support, with a separate evidence record; the original
mapping remains unresolved. Finding a plausible CSV filename is insufficient.
Never reproduce the missing original 31/72 statistic without its original coding
or a separately labelled new calculation.

### 4. Identity, source code, deployment and fidelity are independent

Organization resolution has `label_only`, `source_identified`, or `conflicting`;
legal-entity identity is a separate optional claim. Products and versions have
`provisional`, `source_identified`, `unresolved_bundle`, or `conflicting`. A named
version and immutable source revision remain separate fields. A source pin has
repository URI, exact commit/tree/file/blob digests and compiler/configuration
metadata when available; statuses are `unpinned`, `code_pinned`, `conflicting`.

A deployment record has `unresolved`, `candidate`, `verified`, `conflicting`, or
`not_applicable`. Verification requires chain/network identity, contract/program
address, observation block hash/height and UTC time, retained code bytes/hash,
source/build pin, and a documented bytecode/build correspondence check. Resolve
proxy/implementation address, code and upgrade configuration at the same block.
For non-EVM environments record their equivalent program/account/runtime identity
and exact verification method. Record compiler, linked libraries and immutable
arguments needed for the comparison; an unexplained stripped-bytecode match is
insufficient. If required reproducible build evidence is missing, retain
`candidate`. Off-chain-only products can use `not_applicable` with positive scope
evidence, never as an escape from missing chain evidence. Historical deployments
and retrieval-time deployments occupy separate records.

`fidelity_status` is independently `not_evaluated`, `source_inspected`,
`bounded_differential`, or `refinement_checked`, with per-claim evidence links and
limits. This package can establish the first two only. Existing imported later
fidelity evidence requires exact external run/proof binding and is never inferred
from `verified` deployment. Reports keep source-pinned, deployment-verified and
fidelity-checked denominators separate.

Dependency edges have stable IDs, resolved or provisional endpoint IDs, relation
(`uses_oracle`, `custodied_by`, `issued_by`, `settles_on`, `bridges_via`,
`delegates_to`, `underlying_product`), version/time scope, evidence and disposition.
Unknown endpoint identities stay explicit; cycles are representable, not silently
deleted. Transitive relationships never transfer facet labels automatically.
All original residue text is referenced at source-row level; child assignment
requires evidence rather than blanket inheritance.

### 5. Freeze auditable label predicates before evidence adjudication

Historical `SOURCE_ONLY` remains the old annotation protocol. New rule set
`evidence-adjudication/1` applies only to the new overlay and explicitly permits
retained primary evidence. Every claim identifies product, version, operation
and time scope. Parent text is admissible for a child only when its scope
explicitly includes that child. The following are inclusion predicates for all
17 currently disputed labels and the separate liquidation challenge; they do not
assert that any named protocol satisfies them.

| Rule / facet label | Required positive evidence | Insufficient by itself |
| --- | --- | --- |
| `R-collateralization` / mechanisms | Identified assets are encumbered or checked to secure a scoped obligation | A product merely holds assets |
| `R-allocation` / mechanisms | A rule or authorized actor distributes capital or exposure across identified destinations | Holding an underlying allocation product |
| `R-redemption` / mechanisms | A holder can submit a claim/token for settlement against backing or payout under stated conditions | Secondary-market sale; borrower repayment alone |
| `R-mint_burn` / mechanisms | The scoped operation creates or destroys token/claim supply, with authority identified | Transfer into custody or return of existing inventory |
| `R-liquidation` / mechanisms | A rule-triggered process closes, reduces or resolves an undercollateralized/defaulted position and specifies debt/collateral consequences | Unscoped parent terminology or ordinary voluntary redemption |
| `R-asset_management` / economic_functions | The product directly supplies management/allocation of users' pooled or delegated capital | Incidental treasury management inside another service |
| `R-offchain_claims` / economic_functions | The direct product grants a claim on performance/assets enforced or settled outside its on-chain state machine | Merely centralized operation or branding |
| `R-exchange` / economic_functions | The scoped product directly enables trading/exchanging instruments between participants or against a pool | Issuing/resolving an event claim alone |
| `R-spot_asset` / instruments | The exposed instrument transfers current ownership/control of an asset, without being only a derivative or future-contingent claim | A spot underlying referenced by a derivative |
| `R-fund_share` / instruments | The instrument gives a proportional beneficial/economic interest in a defined managed fund pool | Generic token name or pooled custody without share rights |
| `R-appchain` / execution | The scoped service executes on a dedicated application chain with its execution/settlement role stated | A chain brand or unrelated organization service |
| `R-async_cross_domain` / execution | A scoped workflow has causally linked transitions in distinct domains with an explicit delivery/finality boundary | Tokens available on multiple chains |
| `R-offchain_legal_settlement` / execution | A scoped obligation is discharged or enforced through a stated off-chain legal settlement process | Custody alone or unspecified centralized processing |
| `R-attester` / trust | A named role supplies an attestation accepted as evidence for a financial transition | Any signature or ordinary transaction authorization |
| `R-curator` / trust | A named role chooses strategy, eligible assets/counterparties or capital allocation relied on by users | Passive operator name or validator participation |
| `R-issuer` / trust | A named authority controls issuance of the scoped claim/token or the promise it represents | Merely hosting an interface |
| `R-keeper` / trust | An external actor is relied on to trigger/maintain a required state transition with its role stated | The mere existence of callable functions |
| `R-legal_obligor` / trust | A named entity owes an identifiable legally grounded performance/payment obligation to the holder | A custodian label without the relevant obligation |

Missing support is `not_evidenced`. `refuted` requires positive evidence that the
scoped claim contradicts the rule, not a failed search. `not_applicable` requires
an explicit scope/rule exclusion. `conflicting` retains incompatible applicable
sources rather than choosing by provider vote. New labels outside this table
require a new explicit predicate and rule version before promotion. All rules
also enforce direct-service, identity/time and no-inheritance constraints.

Each of the 29 inventory records expands its symmetric difference into label
claims. Preserve the facet-level count of 29 even when a row has multiple labels.
Supported and contradicted labels can coexist in one facet-level decision; a row
is semantically resolved only when every disputed label has an accepted
`supported`, `refuted`, or justified `not_applicable` disposition. Accepted
`not_evidenced`/`conflicting` means reviewed unresolved, not semantic closure.
The liquidation challenge is a separate claim referencing its actual `AGREE`
record. Never reclassify that observation as `INTERSECTION_UNRESOLVED`.

An adjudication record binds raw A/B hash and pointer, label/rule, evidence spans,
scoped proposition, rationale, disposition, reviewer findings and process status
`draft`, `review_pending`, `accepted`, or `superseded`. Superseding appends a new
record and a link; it does not edit the old body. Accepted supported evidence
updates only the effective overlay facet view. Refutation can remove an old
provisional label from that view with a reason, while retaining its original
observation. No agreement percentage or majority vote determines truth.

The Liquity V1 primary URLs and exact code pin in the planning draft are
acquisition leads only. Capture them afresh with actual times/hashes, inspect
version-specific liquidation/recovery/redistribution and redemption conditions,
and obtain independent review. Do not relabel planning retrieval metadata as a
completed evidence package or assert historical/deployed fidelity.

### 6. Development exposure is monotonic

`development-manifest.json` includes the original 75, all derived candidates,
source hashes, and exposure reasons/times. Every design-inspected source or case
is permanently exposed. The separate `evaluation-manifest.json` initially has
status `not_selected`, zero candidates and no semantic source packages. Its empty
list is an honest planning artifact, never a passed evaluation.

A readiness record binds kernel/library, taxonomy/rules, translation instructions,
evaluator, development manifest and exact source/tool revisions. A later
independent evaluator/curator can select new cases after this freeze, with
explicit overlap/novelty criteria and access logs. This change provides schema and
validation but does not select, read or encode those new cases. Actual readiness
stays `blocked_missing_freeze` until those prerequisites exist. Existing proposed
case names are not untouched certification; descendants of current development
cases cannot be reclassified.

The later unsealing state machine is `not_selected` → `reserved` → `unsealed` →
`evaluated`, with immutable first-run results. Semantic builder exposure before
the frozen run changes role to development; adaptation after a failed run is
labelled post-freeze and does not replace the original untouched measurement.
Record attempted/translated/checked/failed/blocked denominators separately.

### 7. Actual CLI, honest exits and discriminating evidence

The command interface is fixed for implementation:

```text
python3 scripts/corpus_adjudicate.py collect --repo REPO --queue QUEUE --out FRESH_DIR
python3 scripts/corpus_adjudicate.py build --repo REPO --inputs INPUT_DIR --out FRESH_DIR
python3 scripts/corpus_adjudicate.py check --repo REPO --inputs INPUT_DIR --generated GENERATED_DIR
python3 scripts/test_corpus_adjudication.py --repo REPO --out FRESH_DIR
```

`collect` alone uses the network and accepts only exposure-approved development
queue entries. It emits source/attempt records and captures for review; it never
accepts an adjudication or modifies baseline inputs. `build` emits proposed
canonical outputs from validated local records. `check` is read-only, including
mtime, and compares the actual complete projection without repairing outputs.
All commands bind input paths/digests and Git source revisions where tracked;
record driver/schema/rule/dependency versions. Recheck relevant bytes and HEAD
at completion; drift blocks the run. Fresh output paths must be external to repo
and protected input/evidence roots, nonexistent, and free of symlink traversal.
No overwrite or output-inside-source workaround is allowed.

Exit 0 means a nonempty complete declared work inventory was processed and its
integrity/record contract holds. It does not mean every factual item resolved.
Exit 1 means readable, bound records or generated content violate a rule. Exit 3
means required inputs/tools/captured bytes are missing, unreadable, malformed,
empty, unbound or drifting, so the required check cannot finish. Explicit
`unavailable`/`not_evidenced` records are valid data; a missing body claimed
`retained` is blocked. A collection pass with missing external evidence records
all failures and exits 3; later offline inventory validation can pass honest
unavailable records. Structured diagnostics identify item and reason, not just a
summary substring. No stderr words override a real structured result.

Controls call these actual entry points in isolated multi-record fixtures; they
do not copy validation logic. Test missing/partial/duplicate inventory, swapped
facet observations, unknown predicate, unbound evidence, body/source/driver drift,
wrong historical scope, invented citation recovery, false deployment/proxy/source
match, empty agreement promoted to support, agreed-label challenge misclassified,
implicit dependency inheritance, and exposed holdout promotion. Keep valid
siblings for every rejecting family and distinguish violated from blocked by
specific diagnostics. Capture fixtures for collection use an explicitly local
HTTP test server; they are harness evidence, not production primary sources.

Freeze actual production inputs/drivers, rebuild twice to fresh directories,
compare canonical bytes, run read-only checks, existing normalization regression
and the new suite, then independently reconcile every item, status and artifact
hash. Bind native Grok/Fable implementation/evidence reviews to the exact frozen
candidate with requested/reported model identities, UTC times, exits, raw verdicts
and dissent. No native calls are part of this planning-only authoring task.

## Risks / Trade-offs

- Public material may not identify a historical deployment → preserve a complete
  attempted/unresolved ledger and keep the roadmap fact-level obligation open.
- Broad financial terminology admits competing interpretations → explicit scoped
  predicates, retained source spans and reviewed unresolved dispositions.
- Documentation changes or disappears → retained permitted bytes, exact pins and
  truthful fingerprint-only limits; offline checks never silently refetch.
- Collection is bounded and may exhaust its allowance → explicit per-pass
  limits and remaining queue, followed by a separately authorized/recorded pass.
- Source-code match is mistaken for protocol fidelity → independent status fields
  and rejection controls against unsupported promotion.
- A future evaluator reads development material → monotonic exposure propagation,
  freeze/access records and no current-case holdout promotion.

## Migration Plan

Freeze the planning bundle and exact context, obtain independent GPT-6/native
Fable planning acceptance, then implement in the authorized branch. Start with
failing real CLI controls and schemas; capture only development evidence; execute
all finite queues and preserve unresolved results. Run the final checks and
native Grok/Fable audits before accepting outputs. Install generated overlays by
explicit copy from verified fresh output, preserving their source manifest.
Rollback removes only the new overlay/tool consumers; historical normalized
artifacts and evidence do not need restoration because they were never changed.

Update roadmap items only to the scope supported by accepted facts. A complete
ledger with unresolved deployments does not check off complete deployment
identity; an unresolved original pointer with replacement support does not become
recovered. Deliver/archive this package separately from Sprint 8 after acceptance.
