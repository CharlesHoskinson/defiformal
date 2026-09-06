# Corpus Provenance Implementation Plan

> Use superpowers:subagent-driven-development; user approved execution.
> GPT-6 implementation, two independent GPT-6 annotations, direct native
> Grok/Fable review. No Foreman.

**Goal:** Deliver a deterministic, validated provisional crosswalk from 72
preserved legacy rows to 75 candidate units, with explicit source identity and
unresolved annotation/normalization work.

**Architecture:** Frozen source inventory and neutral identities feed two blind
annotation tasks; a builder records agreement and unresolved differences and
emits a schema-validated corpus, CSV and coverage report. Checking is read-only.

**Tech stack:** Python standard library, jsonschema==4.19.2, native GPT-6 agents,
Grok/Claude native review CLIs. Existing Lean sources and historical lanes stay
unchanged. Read the sprint design, AGENTS.md and repository footgun instructions.

## Task 1: Implement schema, deterministic builder and validator

Owner: GPT-6 implementation agent. Own `scripts/corpus_normalize.py`,
`scripts/test_corpus_normalize.py`, `corpus/normalized/corpus.schema.json`, and
`corpus/normalized/requirements.txt`. Do not edit inputs, annotations, generated
outputs, README, plans, review records or Lean files; do not commit.

Read `../specs/2026-09-06-corpus-provenance-design.md` first. Consume the exact
parent-owned input formats and annotation interface defined there. Parent may
add `corpus/normalized/sources/` excerpt provenance; it is separate from the
frozen historical classification input and must not silently change coding.

- [ ] Write failing real-CLI tests using temporary synthetic annotations in the
  specified format, then implement. Source fixtures copy the real pinned inputs
  and the three lanes into temporary repositories outside the worktree.
- [ ] Implement `python3 scripts/corpus_normalize.py build --repo ROOT --out NEW_DIR`
  to produce corpus.json, crosswalk.csv and coverage.json deterministically.
  Fail rather than overwrite an existing output directory. The default data
  directory for check is ROOT/corpus/normalized/generated.
- [ ] Implement `python3 scripts/corpus_normalize.py check --repo ROOT [--data DIR]`;
  schema and relational checks plus exact deterministic output comparisons,
  without writes. Use 0/1/3 status contract and specific actionable diagnostics.
- [ ] Implement a real Draft202012 schema with closed derived structures and
  statuses; preserve arbitrary original source record fields losslessly.
- [ ] Derive all 375 unit/facet decisions; identical sets remain provisional,
  differing sets explicitly remain unresolved. Bind all four input files plus
  both annotation files and schema by SHA256. Check neutral annotation input
  matches the actual identity map, taxonomy and source rows.
- [ ] Exercise corruption cases from the design, including partial source walk,
  duplicate JSON keys, unknown labels, missing inputs, no-op check and source
  drift. Record counts and exact diagnostics, not just aggregate exit codes.
- [ ] Write `/tmp/defiformal-sprint3-code-report.md` with files, commands, observed
  failures/controls, output locations, assumptions and limits. Parent owns
  integration, fresh verification, source freeze and native reviews.

## Task 2: Independent source-grounded annotations

Owners: two independent GPT-6 tasks, each owning only its respective
`corpus/normalized/annotations/a.json` or `b.json`. Read the neutral
`corpus/normalized/inputs/annotation-input.json` and taxonomy/design. Never read
the other annotator's output or the generated corpus. Use no external facts
from memory; no need to browse for this historical-source coding task.

- [ ] Read all 75 candidate contexts and classify all five facets with controlled
  labels, concise rationale and uncertainty. Source-only and bundle-context
  rules apply, especially Liquity V1/V2 and the three Ondo products.
- [ ] Emit exactly the design's annotation envelope and unit fields, with the
  actual input byte hash, correct annotator_id and model_requested.
- [ ] Check every ID appears once, no unknown labels, all source uncertainty
  retained. Report row count and method to `/tmp/defiformal-sprint3-annotator-X.md`.
  Do not claim human independence or semantic ground truth; do not commit.

## Task 3: Integrate, reproduce and review

Owner: parent. Own inputs, generated outputs, corpus README/provenance notes,
review/semantic-kernel/sprint3/, and sprint/progress records.

- [ ] Save design, neutral input/source manifest and independent-task contract.
- [ ] Record limited primary-source excerpt provenance for version/product
  distinctions. Preserve current retrieval date separately from legacy snapshot
  date; leave deployments unresolved. Do not claim missing attachments recovered.
- [ ] Build the corpus from actual independent annotation files, inspect split
  children and repeated organization labels, and run the real check command.
- [ ] Run the actual CLI corruption suite; reproduce generated output in a new
  temporary directory and compare bytes; verify source hashes/read-only status.
- [ ] Freeze a local candidate. Invoke native Grok and Fable on exact code and
  scoped data/evidence bundles; inspect actual model identities and verdicts.
- [ ] Resolve concrete findings with GPT-6 and covering tests, then perform one
  focused re-review if needed. Preserve disagreements and deferred limitations.
- [ ] Commit final records, update the milestone ledger, push the reviewed sprint
  to semantic-kernel-pivot and verify the remote head.
