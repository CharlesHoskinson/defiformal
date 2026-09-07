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
The normalized corpus's three primary excerpt records remain unchanged. Separate
retained source-research packets now supply unaccepted drafts for all 29 facet
differences (32 disputed label instances) and the separate Liquity liquidation
challenge. Their captures, source/code pins where present, locators, extraction
records and failed attempts are existing evidence inputs, not merely URL leads.
They are retained under
`review/semantic-kernel/corpus-provenance-adjudication/source-research/`.
They establish neither accepted adjudication, deployed fidelity nor recovery of
the missing originals.

This independent package does not change kernel runtime semantics. Sprint 9 was
accepted at source `eec499d613688137a341f3556cd80ca461dd2ee9` and archived/delivered
at `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff`. Sprint 10 has its own accepted
planning gate and concurrent implementation; that does not approve this corpus
package. Corpus official-r1 received native Fable REQUEST CHANGES; this r2 author
revision requires a newly frozen nonauthor GPT-6/native Fable planning gate. User AFK authorization covers routine execution choices, not gate bypass.

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
adjudications,interpretations,exposure,freeze}.json`, permitted captures under `sources/sha256/`,
and `generated/{corpus,source-claims,coverage,development-manifest,evaluation-manifest}.json`.
`corpus.json` is the historical-primary projection defined in decision 5;
`source-claims.json` is a separately scoped source-reading table, not a current
replacement for the historical corpus or a new deployment assertion.
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
allowed acquisition scope, attempt references and current disposition. Work
disposition is a closed enum: `not_attempted`, `attempted_unavailable`,
`budget_exhausted`, `review_pending`, `reviewed_unresolved`, `reviewed_resolved`.
The terminal states for complete bookkeeping are `attempted_unavailable`,
`budget_exhausted`, `reviewed_unresolved`, `reviewed_resolved`; each requires its
reason and attempt/review references (or an explicit no-request eligibility
reason). `not_attempted` and `review_pending` remain open and block a claimed
complete-work exit 0. Closed bookkeeping is not factual resolution: only the
last state can count toward a separately checked, scope-specific factual claim.
Coverage counts every state, including zero counts, by item kind. Distinct
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

The future collector's bounded first acquisition pass allows at most three distinct primary source
URL targets per original candidate per pass, prioritizing version-specific official
docs, pinned code/release manifests, then deployment records. A target is the
exact absolute HTTP(S) request URL after fragment removal; path/query spelling
is retained (no guessed slug or query equivalence). Each first attempted target
consumes one slot, including failed guesses and corrected/fallback URLs. Retries
of the identical target use its existing slot; at most two attempts total
(initial plus one retry) are allowed. Server-issued redirect hops are recorded
under that target and consume the independent five-hop bound, not extra target
slots; manually following a different URL starts a new target. Reusing a redirect
endpoint later as a requested target consumes a slot. Every attempt records the
full redirect chain. Each attempt has a 30-second total wall deadline covering
connection, redirects and body reading; each body is limited
to 20 MiB and the pass to 512 MiB. Exhaustion records `budget_exhausted` and the
unexamined queue, never success for those items. A new explicit acquisition-pass
manifest can extend these bounds later without rewriting earlier evidence.
Secondary sources can locate primary material but cannot alone promote a
version/deployment or decide a disputed label. Record all failed attempts.

Existing research passes are a separate acquisition history. Several bounded
research packets limited substantive retained bodies to three per unit while
trying additional failed or fallback URLs. Preserve each actual pass's declared
limits, attempts, empty responses, timestamps and tool records; never assert that
those passes satisfied the future collector's three-distinct-URL budget. An HTTP
success or retained zero-byte transport response is not substantive evidence.
Such failed/empty records remain available with zero claim-support credit.

Before scheduling network work, validate available research packets against the
development queue. A queue item may reference validated existing bytes without a
new request. Record import eligibility, remaining evidence gaps and why no new
request is required; this does not mark its proposed adjudication accepted or
complete unexamined identity/deployment work. Fresh acquisition is needed only
for a missing, invalid, inadequate or explicitly time-sensitive required source.

### 3. Capture, bibliography and original recovery have separate statuses

A source record includes `source_id`, original/requested/final URL, UTC retrieval,
HTTP status/content type, body byte length/digest, capture path or explicit
unavailability reason, extraction method/version, excerpt/code locators,
product/version/time scope and source-authority rationale. Use `capture_status`
`retained`, `empty_or_non_substantive`, `fingerprint_only`, `unavailable`, or
`restricted`. `retained` requires positive body length, matching retained body
bytes, at least one valid nonempty content locator and a documented substantive
source classification; HTTP status alone
does not qualify. Empty responses, access/challenge pages and redirect-only
wrappers use `empty_or_non_substantive` with a reason and receive zero support
credit even if their transport bytes and digest replay. Evidence locators must
select a nonempty span `0 ≤ start < end ≤ byte_length` in an eligible retained
coordinate space; reject zero-length/out-of-range spans and any span in an
empty/non-substantive or redirect-wrapper record. No digest alone supplies support.
Mutable docs support retrieval-time assertions; archived historical material must
have an explicit historical scope. A current code commit alone does not establish
historical deployment behavior.

Store permitted captures. If redistribution or access prevents retaining needed
bytes, record the limitation and keep dependent replay/factual claims unresolved;
do not bypass access controls or treat an inaccessible URL as captured evidence.
A later authorized local evidence package can carry restricted material without
inventing a public artifact. Network acquisition is explicit and separate from
build/check, which never fetch or refresh a page.

Source inputs distinguish `origin_kind: research_packet_import` from
`origin_kind: collector_run`. The former binds the original packet manifest,
response body, exact raw or derived locator, and the extraction/source-code pin
where used; it retains original acquisition UTC, requested/final URLs, failures,
limits and recorded tools. Import validation records its own command/time/tool
identity separately and must not overwrite or backfill unknown historical tool
metadata with current values. Derived-text offsets must identify that coordinate
space and bind both extraction output and original response bytes. Retain the
actual derived output bytes with positive length and digest, extractor/version
and input-body binding; a method name, pin or an ability to rerun extraction
does not substitute for those bytes. Missing output bytes block dependent replay
with `missing_extraction_output`. Span checking is mechanical; the factual
adequacy of a nonempty excerpt still requires source review. Import writes only
new normalized overlay records with original-record pointers and normalization
reasons: legacy transport records marked retained but empty/wrappers become
`empty_or_non_substantive`, with no support credit. Preserve their original
labels, capture bytes and manifests unchanged. Unknown substantiveness remains
non-substantive pending review, not implicitly retained. Missing
required provenance blocks the dependent claim; honest unknown metadata remains
unknown. Draft source interpretations stay `draft` or `review_pending` until
independently reviewed under the frozen rule. Offline `build` validates these
records through `provenance.py`; no new network or additional CLI mode is needed.
When a packet binds an older planning-file digest, resolve that digest to the
preserved historical snapshot and bind the current rule separately. Do not rewrite
the packet's old path/hash or rerun its capture-time no-drift check against a
changed plan and call that the original run. Import qualification must compare
the actual applicable predicate text and scope; changed rules require a new
reviewed interpretation. This refresh preserves the literal inclusion predicates.

Every original occurrence retains exact token/text, byte offsets, proposal hash
and associated claim span. Pointer statuses are `unresolved_original`,
`recovered_original`, or `reconstructed_support`. Recovery requires the actual
original attachment bytes plus their origin record, or an original browsing
transcript mapping the citation token to its URL. Such recovery additionally
records `origin_trust_assumption`, transcript provider/custody history where
known, transcript digest, exact mapping span and reviewer assessment. A matching
digest and internally consistent mapping verify byte integrity only, not the
authenticity/completeness of the supplied browsing transcript. Unknown origin
trust leaves the mapping unresolved; accepted recovered mappings explicitly
remain conditional on the recorded origin assumption. Matching a claim to a new web
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
assert that any named protocol satisfies them. The versioned `rules.json` is the
authoritative predicate payload (the planning copy is supplied with this change).
Each rule stores its literal Markdown row in addition to parsed fields; the table
below is a literal-equality checked presentation copy. The implemented overlay
copies the frozen payload without silently changing it. Common scope clauses
and any interpretation selection are separately version/hash bound.

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

Derive the disagreement set directly from bound normalized `adjudications`
filtered by `rule == INTERSECTION_UNRESOLVED`; derive each symmetric difference
from its raw `a` and `b` arrays, cross-check `unresolved_labels`, and compare
exact unit/facet/label tuples to the queue inventory. The actual baseline yields
29 facets, 32 label instances and 24 distinct units; these numbers are outputs
of that comparison, never authority taken from inventory counters.

Each of the 29 inventory records expands its symmetric difference into label
claims. Preserve the facet-level count of 29 even when a row has multiple labels.
Supported and contradicted labels can coexist in one facet-level decision; a row
is historically semantically resolved only when every disputed label has a
unique accepted effective decision with `unit_applicability: established` and
`supported`, `refuted`, or justified `not_applicable` disposition under the
applicable rule/interpretation. Source-only support cannot close this count. Accepted
`not_evidenced`/`conflicting` means reviewed unresolved, not semantic closure.
The liquidation challenge is a separate claim about a label present in both raw
annotations. Its actual mechanisms facet is `INTERSECTION_UNRESOLVED` at
`corpus/normalized/generated/corpus.json#/adjudications/77`, because B alone
includes redemption. Preserve that exact facet record. The historical challenge
uses `AGREE` as label-membership shorthand; retain its text without promoting
that wording to a facet-level rule or inventing a thirtieth disagreement.

An adjudication record binds raw A/B hash and pointer, label/rule version and
hash, evidence spans, scoped proposition, rationale, disposition, interpretation
references, reviewer findings and process status `draft`, `review_pending`,
`accepted`, or `superseded`. Every record has a mandatory `unit_applicability`:

| Value | Required meaning | Historical-primary effect |
| --- | --- | --- |
| `established` | Reviewed evidence binds this source proposition to this exact historical unit's product, version or explicitly version-unspecified scope, operation and snapshot time; unresolved deployment does not become verified | Eligible for an accepted unique effective decision |
| `current_documentation_only` | Positive evidence supports only the explicitly named retrieval-time product/documentation scope, not the historical unit | Source-claims table only; historical claim remains not evidenced/unresolved |
| `unresolved` | Even the source-to-unit applicability cannot be established; source reading may still be recorded at its exact scope | No historical label promotion/removal and no semantic closure |

The historical-primary view targets the preserved 2026-08-04 research snapshot
and its exact row/unit identities, retaining unresolved version/deployment fields.
It begins with the original retained intersection as `provisional_observation`,
not supported evidence. Only a unique accepted effective `established` decision
can add a supported label, or remove a refuted/justifiably-not-applicable label.
Accepted not_evidenced/conflicting leaves provisional labels visibly provisional
and the claim unresolved. Other applicability values never alter the historical
facet. The source-claims table shows exact product/document/version/operation/time
and disposition for each current or narrower source scope; it is not a broad
unit-wide current facet projection. Coverage cross-tabulates every disposition
by applicability, review status and scope; historical semantic closure and
source-scoped supported counts are separate. No existing research packet,
including one with a proposed supported unit label, is automatically accepted or
assigned established applicability. Import creates draft/review-pending records.

`inputs/interpretations.json` contains append-only interpretation records with
ID, rule ID/version/payload hash, precise ambiguity, ruling text, rationale,
evidence/review bindings, status and supersession references. Interpretations do
not silently change predicate text: a changed inclusion predicate requires a new
rule version. For each (rule ID, rule version), a frozen selection names exactly
one accepted interpretation head when any ruling applies. Every effective accepted decision
under that rule version must reference that same selected interpretation, even
if the reviewer considers the case straightforward. Retired/superseded historical
records keep their original ruling and are excluded from current-head uniformity;
selecting a replacement ruling cannot silently rewrite or reaccept older heads.
Every affected current decision must be reviewed and superseded as needed before
current acceptance under the new selection. The affected-unit inventory
covers all decisions and pending proposals for the rule, including Lighter,
ApeX and edgeX when R-appchain is reviewed; these names are review coverage, not
new taxonomy rulings. Unresolved ambiguity or missing/unaccepted ruling keeps
interpretation-dependent decisions review_pending. Import must flag conditional
packet wording; it cannot infer a ruling from an author's proposed support.

Decision keys are (unit_id, facet, label, rule_version, scope_id), where scope_id
binds the full explicit historical or source scope. Supersession is an append-only
acyclic graph within one key. A new record can supersede one or more existing
records of that key; references must exist, cycles/self-links/cross-key links
are violations. Only accepted successors retire an accepted predecessor in the
effective projection; draft successors do not. A single non-superseded accepted
head supplies the effective decision. Multiple heads produce `conflicting` with
all IDs retained, even when their dispositions happen to agree, until a reviewed
successor explicitly reconciles every head. No filesystem order, timestamp or
reviewer vote chooses a winner. Interpretation selections obey the same
acyclic/unique-head rule per rule/version; conflicting heads block acceptance
of dependent decisions. Historical and current scopes do not supersede each
other. All previous bytes and review observations remain available.

The retained `source-research/liquity-v1/` and `liquity-v1-redemption/` packets now
provide separate liquidation and redemption source inputs. Validate their actual
capture, code-pin, extraction and locator bindings and inspect the stated
version-specific conditions before independent review. Earlier fingerprint-only
planning observations remain weaker historical evidence; the later retained
packets do not retroactively change their capture status. Import valid retained
bytes without mandatory duplicate retrieval. Neither import nor a proposed
supported disposition asserts historical/deployed fidelity or closes the challenge.

### 6. Development exposure is monotonic

`development-manifest.json` includes the original 75, all derived candidates,
source hashes, and exposure reasons/times. Each retained source additionally
records the publisher identity as stated (or unresolved), and all substantively
described organizations/products with exact source locators, their identity status
and relation to the queued unit. These include described third-party providers,
not only the requesting unit or URL host; source attribution is not automatic
legal-entity resolution. The overlap inventory indexes these descriptions and
retains aliases/unresolved identities. Every design-inspected source or case
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
cases cannot be reclassified. The existing twelve-case exposure audit under
`review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/` found
all twelve proposed cases development-exposed. Preserve its exact source/line/
hash evidence and distinctions between meaningful design use and proposal
mentions. There are zero untouched cases selected or certified by this package;
do not read or select replacements as part of this refresh or implementation.

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
queue entries. Eligibility is checked against the bound development manifest
using exact unit/ancestry membership and source exposure, not a caller-supplied
role field; missing membership or a spoofed development role is rejected before
a request. Task 6.1 must therefore precede task 2.4. It emits source/attempt records and captures for review; it never
accepts an adjudication or modifies baseline inputs. `build` emits proposed
canonical outputs from validated local records. `check` is read-only, including
mtime, and compares the actual complete projection without repairing outputs.
All commands bind input paths/digests and Git source revisions where tracked;
record driver/schema/rule/dependency versions. Recheck relevant bytes and HEAD
at completion; relevant input/tool byte drift blocks the run. HEAD movement is
recorded with both revisions and Git-object bindings; unrelated commits do not
relabel captures or invalidate byte-identical relevant inputs. A changed relevant
Git object or absent binding blocks the run. Fresh output paths must be external to repo
and protected input/evidence roots, nonexistent, and free of symlink traversal.
No overwrite or output-inside-source workaround is allowed.

Exit 0 means a nonempty complete declared work inventory was processed and its
integrity/record contract holds, with every item in the closed terminal work
dispositions of decision 2. It does not mean every factual item resolved. Open
not_attempted/review_pending items give exit 3 `incomplete_work_queue`; unknown
enum values are readable contract violations (exit 1).
Exit 1 means readable, bound records or generated content violate a rule. Exit 3
means required inputs/tools/captured bytes are missing, unreadable, malformed,
empty, unbound or drifting, so the required check cannot finish. Explicit
`unavailable`/`not_evidenced` records are valid data; a missing body claimed
`retained` is blocked. A collection pass with missing external evidence records
all failures and exits 3; later offline inventory validation can pass honest
unavailable records. A retained zero-length/non-substantive body or invalid nonempty locator is a
readable false record (exit 1); a missing body/output claimed retained is exit 3.
Structured diagnostics identify item and reason, not just a
summary substring. No stderr words override a real structured result.

Offline execution uses an enforceable Linux network-denial wrapper for both
`build` and `check`: a dedicated network namespace with no external interfaces
and a pinned seccomp launcher denying socket/socketpair/connect plus equivalent
network syscalls to the entire child process tree (including subprocesses). The
launcher and policy bytes, version and self-test results are run inputs. A fresh
subprocess socket-creation/connect probe must actually fail under that policy
while a local-file positive succeeds. Unavailable namespace/seccomp support,
launcher or a failed denial self-test is exit 3 `offline_isolation_unavailable`;
never fall back to an assertion or an unenforced Python monkey-patch. DNS and
child processes are covered; the trusted OS/launcher enforcement is explicit.
Collector HTTP fixtures run outside that offline wrapper and are labelled separately.
Implementation may select an existing system launcher, but must bind its exact
executable/policy and demonstrate these behaviors before an offline claim.

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

Freeze the planning bundle and exact current context, obtain nonauthor stock
GPT-6/native Fable 5.1 planning acceptance on that same candidate, then implement
in the authorized branch. Request `claude-fable-5-1[1m]` with `--effort medium`
and retain the actual returned model, including for native Grok/Fable
implementation/evidence reviews. This r2 revision addresses the preserved official-r1 native REQUEST CHANGES
report; historical GPT-6/Fable review records exist but do not approve these new
bytes. Revised-candidate reviews and implementation remain pending. Start with
failing real CLI controls and schemas; validate existing development source
imports before acquiring missing development evidence; execute
all finite queues and preserve unresolved results. Run the final checks and
native Grok/Fable audits before accepting outputs. Install generated overlays by
explicit copy from verified fresh output, preserving their source manifest.
Rollback removes only the new overlay/tool consumers; historical normalized
artifacts and evidence do not need restoration because they were never changed.

Update roadmap items only to the scope supported by accepted facts. A complete
ledger with unresolved deployments does not check off complete deployment
identity; an unresolved original pointer with replacement support does not become
recovered. Deliver/archive this package separately from accepted kernel sprints
after its own acceptance. Prior author reports and research packets remain
immutable; official-r2-preparation supplies refreshed author bindings and is
not a review verdict. At each official freeze regenerate all in-change normative
inventories/maps/context manifests, and preserve prior versions as historical
snapshots; a stale manifest cannot serve as the current implementation map.
