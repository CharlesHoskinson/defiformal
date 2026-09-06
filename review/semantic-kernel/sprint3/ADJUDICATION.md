# Sprint 3 review and disposition

Initial candidate: `045126ef8493ff34da5f485c80d71414b29b2df3`.
Intermediate remediation: `4abac77a0ff11a262b91f9939ed5c71c76e9c113`.
Final source candidate: `7df773478df6408ac75abeca64ef04d76320c6fe`.
The same focused bundle was sent to both native reviewers.

GPT-6 implemented through native Codex collaboration agents. Two separate GPT-6
contexts produced the 75 annotations each, without sibling output access.
`annotation-process.json` records requested identity, input/output hashes and the
limits of the process evidence. No Foreman was used.

## Native review scope and identities

Both providers received the same initial three bundles: full implementation and
schema; full regression suite plus initial log and coverage; and eight selected
source/annotation contexts including all five split children. `review-scope.json`
records the candidate, hashes and exact sampled unit IDs. Automatic checks cover
all 75 units. This is not an independent semantic review of all 75 classifications.

Grok was requested as `grok-4.6` and reported `grok-4.6-build`. Fable was requested
and reported as `claude-fable-5-1`; its native CLI also reports auxiliary Haiku
usage. All six initial calls exited 0 and returned completed responses. Raw JSON,
invocation records, stderr, prompt bundles and text projections are retained.
Some Grok calls located and hash-checked repository files despite the requested
empty tool list; others inspected only attachments. No independent pipeline
execution by either reviewer is claimed. Review is advisory evidence, not proof.

## Initial findings and disposition

| Finding | Disposition |
| --- | --- |
| Both test reviewers: empty/subset disagreement cannot discriminate always-A or dropping disputed sets | Fixed with overlapping non-subset sets, exact retained and symmetric-difference assertions, order-only agreement and three real CLI mutants |
| Both test reviewers: supplied regression log is synthetic, not actual corpus verification | The actual integration evidence already existed in `verification.json` but was omitted from their bundle. Added separately identified command/revision/tool/hash evidence and clarified README commands; focused review receives it |
| Grok: alternate `check --data` not exercised | Added a check of the second generated directory |
| Both: weak assertions on binding paths and corruption diagnostics | Assert all seven exact paths, more specific field diagnostics, no output for blocked builds, and path-selected manifest mutation |
| Fable: Python equality conflates JSON true and 1 | Reproduced false acceptance; fixed neutral binding with canonical JSON bytes and a same-type positive control |
| Both: empty-empty agreement mixed with positive labels | Added overall and per-facet agreed_empty/agreed_nonempty; actual 346 agreements split into 279 nonempty and 67 empty, with 29 differences |
| Fable: Ondo Stocks assertion absent from durable excerpt | Added the two-word string from the original captured response, verified against its recorded body hash; no refetch or historical-input change |
| Fable: hash encoding unclear | Specified exact response body bytes, headers excluded, and UTF-8 LF-joined excerpts with final LF |
| Grok: V1 excerpt does not itself name V1 | Clarified URL and sibling V2 excerpt are the naming evidence; did not invent a V1 title excerpt |
| Fable: OS-specific path separators | Changed serialized relative paths to POSIX notation; no Windows execution claimed |
| Grok: split suffixes do not constrain split payloads | Fixed exact version/product payload constraints; five coherent identity/neutral/hash corruptions that previously passed now fail |
| Grok: schema allows inconsistent rule/status and duplicated annotator references | Fixed with rule/status conditions and ordered a/b references. Relational source/identity/set checks still require the CLI |

## Preserved semantic disagreement

Grok challenged the Liquity V1 `liquidation` label as insufficiently grounded in
child-specific prose. Fable's sample review found no split inheritance bug.
`open-semantic-challenges.json` records the open challenge; the corpus README
calls it out. Both GPT-6 annotators actually supplied the label, so falsifying an
A/B disagreement or editing their original answers would corrupt elicitation
history. The agreement remains a provisional observation and is not certified
protocol behavior. Targeted evidence and a versioned adjudication remain work.

## Suggestions not adopted as new acceptance requirements

- Empty or missing generated files remain status 3, as the saved design explicitly
  requires. Wrong annotations/projections remain status 1. Argument syntax errors
  remain argparse status 2 and are now explicit in README.
- Proposal bytes are transitively bound by the hashed source manifest and checked
  against its digest. They are not authenticated publisher evidence. Source commit
  is an audit assertion, not a Git authentication mechanism.
- Liquity versions sharing a provisional product label is the saved identity
  design. It does not assert verified deployed or legal identity. Other repeated
  organization labels keep distinct product contexts; integration records check
  the Jupiter, Maple and Steakhouse pairs.
- Exact split inventory/counts already have CLI constraints; additional coverage
  convenience counters do not change the acceptance denominator.
- Schema alone is explicitly insufficient. Set intersection, uniqueness across
  identity fields, exact provenance and output reconstruction are CLI obligations.
  Equality to a deterministically rebuilt object plus exact bytes enforces the
  actual file's values; a duplicate independent set implementation is unnecessary.
- Recursive malformed-input diagnostics, stronger standalone schema reuse/ID
  patterns, additional label-level coverage, explicit future package schemas and
  a strict extra-file directory inventory remain follow-ups. No such behavior is
  claimed by this increment.

## Verification and final decision

Both focused native reviews returned **accept with recorded limitations** on
`7df773478df6408ac75abeca64ef04d76320c6fe`. `review-results.json` records all eight
completed calls, requested/reported models and matching response/bundle digests.
The final review patch and actual execution evidence are bound in
`focused-scope.json`; neither reviewer claims an independent pipeline run.

Fresh parent verification: **20 tests / 76 real CLI calls** (13 successes,
49 invalid-content refusals, 14 blocked-input refusals). `final-verification.json`
and `final-cli-tests.log` bind exact source files, tools and candidate. Actual
`check --repo .` succeeds with 72 rows / 75 candidates / 375 decisions and preserves
bytes and modification times. A fresh build and explicit `check --data` succeed;
all three outputs are byte-identical. The three adjudication mutants were replayed
against the final files: each completed its own checks, then failed expected-data
assertions (`final-mutants.log`). These are discriminating failures, not missing
inputs or parser failures.

Actual decisions: 279 nonempty agreements, 67 empty agreements, 29 unresolved
differences. All75 candidates remain development cases; no deployment is verified.
The separate Liquity V1 source challenge remains open despite model agreement.

Focused-review limits: coverage integrity comes from deterministic CLI checking,
not a separate coverage schema. `final-source-checks.json` independently records
body/excerpt hash and substring checks for all three original temporary captures;
those response bytes are not archived. Unknown split IDs are rejected by exact
parent/child coverage before suffix lookup; future inventory changes still require
explicit code/schema/input revisions. Evidence artifacts are bound by the final
evidence manifest and the evidence commit, not self-signed by the source candidate.

Historical `corpus50` and `formal` files remain unchanged from the Sprint 2 base.
This sprint establishes provisional source-bound bookkeeping, not a deployment
benchmark, holdout performance, financial truth or reproduction of the missing
proposal artifacts.

The staged whitespace check flags blank diff-context lines in focused-bundle.txt
and the final blank line in tests-bundle.txt. These exact native-review inputs
are retained byte-for-byte to preserve their recorded hashes. Source changes
passed the whitespace check; the raw review-bundle findings are intentional
evidence-format exceptions.
