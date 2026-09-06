# Sprint 3: source-bound provisional corpus normalization

User authorized this sprint with “begin” after the corpus/provenance milestone
was proposed. Base: `1d26fd863f9bf9ecb8361982f43e212a4c94eec7`; continue on
`semantic-kernel-pivot`. GPT-6 implements and independently annotates through
native Codex agents; native Grok and Fable review. No Foreman.

## Scope and decision

Reconstruct a schema and crosswalk from the three frozen `corpus50/lanes` files.
The original linked CSV/schema were not recovered in the accessible searched
roots; `/mnt/data` does not exist. This is a new, explicitly provisional artifact,
not a reproduction of the proposal's absent coding or its aggregate statistics.

Preserve all 72 original rows with their JSON pointers, source-file hashes,
category and complete original record (including rank statement, residue,
forced fits and ordering information). Source statements remain historical
claims, not newly verified measurements. Split Liquity V1/V2 and Ondo's three
named products into 75 candidate units. No other identity is silently declared
fully normalized. Exposed version labels are distinct from code revisions;
all deployment addresses, chain identities and source-code revisions remain
unresolved in this increment. Other bundled products remain flagged for review.

A lossless source registry plus provisional candidate units is chosen over
rewriting the historical lanes or guessing deployments. A full deployment
benchmark requires a later source-acquisition sprint. This sprint establishes
reproducible bookkeeping and independent coding, not deployment fidelity.

## Inputs and identities

Parent-owned `corpus/normalized/inputs/` contains source-manifest.json,
identity-map.json, taxonomy.json, and the neutral annotation-input.json.
IDs are stable within this pinned source inventory. Source identity combines
file path, byte hash and JSON pointer. Organization IDs are corpus-label
containers, never verified legal entities. Repeated Jupiter/Maple/Steakhouse
labels share organization containers but retain distinct product-context units.
Liquity versions share one product. Product/version/deployment states are explicit.

The identity map and annotation input contain no proposed facet labels.
Two separate GPT-6 contexts annotate all 75 units from the same source input,
without reading each other's output. The shared taxonomy supplies five facets:
economic functions, instruments, mechanisms, execution and trust. Arrays may
be empty when evidence is absent. Empty is not a proof of absence. Each annotation
contains a concise source-grounded rationale and uncertainty. These are
independent model annotations, not independent human expert verification.

Exact annotation interface:

```json
{"schema_version":"0.1.0","annotator_id":"a","model_requested":"gpt-6-astra",
 "input_sha256":"SHA256 of annotation-input.json","annotations":[
  {"unit_id":"unit:lane1:c0:p0","facets":{"economic_functions":["exchange"],
   "instruments":[],"mechanisms":[],"execution":[],"trust":[]},
   "rationale":"Relevant source fields and why they support these labels.",
   "uncertainty":["Unresolved identity or facet evidence."]}]}
```

The file for annotator b differs in annotator_id. All units must appear exactly
once. All facet labels must belong to taxonomy.json. Annotators may not add
external facts from memory or silently apply the parent row's complete element
list to a split child. Their independence is process evidence, not cryptographic
attestation. Generated data must never pretend to prove annotation truth.

## Adjudication and generated outputs

Every unit/facet pair has a recorded decision. Identical sets are provisional
agreement (AGREE). Different sets retain the intersection, record the symmetric
difference, and remain unresolved under INTERSECTION_UNRESOLVED. This rule is
reusable on future rows; no target agreement percentage or arbitrary tie-break
forces closure. A disagreement is not resolved merely by intersection.

`generated/corpus.json` contains schema_version, status, input_bindings,
source_records, units with provisional facets, and adjudications. Each unit
retains its identity-map fields and both source annotations by reference.
`generated/crosswalk.csv` has one row per candidate unit, connecting all 72 legacy
IDs to the 75 candidates and exposing provisional facets and unresolved identity.
`generated/coverage.json` reports exact source/derived denominators and agreement/
disagreement counts, without equating them to semantic accuracy.

Graph relationships in this increment are identity hierarchy and source mapping.
No inferred protocol-dependency, custody or issuance edge is claimed verified.
Every candidate is a development case; none is an untouched holdout. Original
residue/forced fields stay at source-row level and are not silently attributed
to every split child.

## Build and verification contract

Use JSON Schema Draft 2020-12 with pinned jsonschema 4.19.2. Save a concrete
corpus schema. Python's standard library handles deterministic generation and
CSV; jsonschema validates structure. The CLI has separate `build` (explicit
output creation) and `check` (read-only) operations. The checker validates
schema, unique IDs, exact source row coverage, source/annotation input binding,
parent-child correspondence, facet vocabulary, every adjudication, development
role, and exact deterministic projection into all three generated outputs.
It must not regenerate in place to make its own check pass.

Exit 0: nonempty, complete, internally consistent provisional dataset. Exit 1:
derived data or annotations violate the contract. Exit 3: required inputs or
pinned sources are missing/unreadable/empty or source identity cannot be checked.
Missing generated output is blocked, never success. Malformed JSON, duplicate
JSON keys and path escape must have explicit nonzero diagnostics. Declared
source digests are compared with actual bytes; manifests are audit records,
not authenticated signatures. Source schemas cannot certify external facts.

Tests exercise the real CLI with a positive control and targeted bad content:
dropped source mapping, omitted/duplicate unit, missing annotation, unknown facet,
wrong provenance hash, modified residue, false holdout promotion, and disagreement
silently called agreement. Missing/empty source and read-only behavior are
separately tested. Validate full JSON schema itself. No vacuous passes and no
compile-only/missing-input failure presented as a bad-content detection.

Parent records exact input/tool identities, fresh output, actual source counts,
read-only status and both native reviewer verdicts. One initial review and one
focused remediation round if necessary; failed invocations may be retried in
smaller scopes. No Lean source changes are needed in this sprint.
