# Sprint 3 Task 1 implementation report

Implemented only the four assigned repository files. No commits. No edits to historical lanes, parent-owned inputs, annotations, generated outputs, Lean, documentation, or review records.

## Scope and behavior

- `build --repo ROOT --out NEW_DIR` validates required inputs before creating a new directory, refuses existing output paths, and emits deterministic UTF-8 corpus.json, crosswalk.csv and coverage.json.
- `check --repo ROOT [--data DIR]` reads existing generated artifacts, validates Draft 2020-12 structure and relational equality with an in-memory deterministic reconstruction, and compares exact bytes. It performs no writes. Default data directory is ROOT/corpus/normalized/generated.
- All 72 historical source rows retain full original JSON records, category, source pointer and source SHA256. Exact three-lane inventory and per-lane 22/30/20 denominators are enforced independently of manifest totals. Exact identity split IDs yield 75 units. All 375 facet pairs have explicit retained sets, symmetric differences, rules and statuses.
- All four input files, both annotation files and the schema have byte SHA256 bindings. Actual source bytes and proposal bytes are checked against their manifest digests. Neutral annotation input must equal actual identities, taxonomy and source records. Annotation envelopes bind their own input SHA and contain exactly every unit once.
- Agreements remain provisional. Differences retain intersections but stay unresolved. All evaluation roles are development and all deployments unresolved; no annotation truth or verified deployment is claimed.
- Required file missing/unreadable/empty and unverifiable source inventory/identity return 3. Invalid annotations or derived artifacts return 1. Success is 0 and prints nonzero denominators. Malformed JSON, duplicate keys, unknown labels, missing IDs and schema problems receive explicit diagnostics.

## Test commands and measured results

1. Initial red: `python3 /home/charl/defiformal/scripts/test_corpus_normalize.py CorpusCLI.test_positive_reproducible_read_only > /tmp/defiformal-sprint3-tdd-red.log 2>&1` returned 1; positive assertion failed because the implementation script did not yet exist (underlying CLI returned 2). This establishes absence of the feature, not bad-content discrimination.
2. First implementation run: `python3 /home/charl/defiformal/scripts/test_corpus_normalize.py > /tmp/defiformal-sprint3-tdd-green.log 2>&1`. An initial diagnostic mismatch for a missing lane was fixed: missing required lane files now name the missing/unreadable input. Excessively long jsonschema minItems diagnostics were narrowed to expected and observed lengths. The repeated nine-test run passed.
3. Added schema-reference regression: `python3 /home/charl/defiformal/scripts/test_corpus_normalize.py CorpusCLI.test_schema_broken_local_reference > /tmp/defiformal-sprint3-schema-ref-red.log 2>&1` returned 1 because a missing local schema reference produced a library traceback instead of an actionable diagnostic. The implementation now checks local reference targets before validation.
4. Final full suite: `python3 /home/charl/defiformal/scripts/test_corpus_normalize.py > /tmp/defiformal-sprint3-cli-tests.log 2>&1` returned 0: 15 tests passed in 7.811 seconds. The log records 59 real CLI invocations: eight successes, 37 invalid-content refusals, and 14 blocked-input refusals. The test harness checks both expected exit status and the named diagnostic.

The suite copies all real pinned inputs, all three complete historical lanes and the manifest's proposal file into temporary repositories under /tmp/corpus-cli-*. It creates synthetic complete a/b annotation envelopes there, including one deliberate differing mechanism label. Positive controls report 72 rows, 75 units, 375 decisions, 374 provisional agreements and one unresolved difference. These counts are test fixtures, not independent annotation results. Fixture repositories are cleaned automatically.

Checks snapshot every fixture file's bytes and modification timestamp before/after success and derived-data corruption checks. A second fresh build is byte-compared across all three outputs. Missing and empty generated artifacts never pass. Actual code is run as a subprocess; the suite contains no copied validator implementation.

## Assumptions and limits

- This schema version deliberately fixes the current 72-to-75 inventory, the three source filenames, exact split IDs and the current taxonomy. Changing this inventory requires an explicit schema/code/input revision.
- The proposal file named by source-manifest.json is also required and hash-checked. External fixtures must copy it as the included test harness does.
- Hashes are reproducibility records, not authenticated signatures. A collaborator controlling all inputs and their manifest can make a new consistent inventory. This is not adversarial attestation or semantic validation of source claims, rationale quality or annotation independence.
- Native reviewer identity and process evidence are parent-owned. Actual independent annotation integration and repository generated output creation are parent-owned and were not performed here.
- Build filesystem failures can leave a partial newly created output directory; the next build refuses to overwrite it and check blocks on missing/empty artifacts. Read-only checking does not repair files.
- CLI argument syntax errors use argparse's conventional status 2; the documented 0/1/3 contract applies once a valid build/check command is parsed.

## Exact file and tool identities

Python: 3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]

jsonschema: 4.19.2

- `4139132f8620c8e0bd780fcd4d4f8e26505a4afbd5da2e473e54c90d615b533f` `scripts/corpus_normalize.py`
- `f208acb00b5b03a72d5610cac557857afbc59d5b2abc7087f133c49237f2d697` `scripts/test_corpus_normalize.py`
- `98c005eeb9625f20ba3acd76135b92f2f6bda2ce09250d6ebdbae7c1dd887a15` `corpus/normalized/corpus.schema.json`
- `49026b67905a6c42bd426e6f8b3d2d08dc24ec6fe51cb2f706aea0a3fb5f8e08` `corpus/normalized/requirements.txt`

## Full final CLI diagnostic log

```text
test_annotation_corruptions (__main__.CorpusCLI.test_annotation_corruptions) ... test_annotation_corruptions: exit=1: FAIL: annotation unit coverage mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: unknown facet label: corpus/normalized/annotations/b.json/unit:lane1:c0:p0/trust
test_annotation_corruptions: exit=1: FAIL: annotation input hash mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: annotator_id mismatch in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0: 'rationale' is a required property
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0/facets/economic_functions: ['exchange', 'exchange'] has non-unique elements
ok
test_derived_corruptions (__main__.CorpusCLI.test_derived_corruptions) ... test_derived_corruptions: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
dropped source
test_derived_corruptions: exit=1: FAIL: schema corpus.json/source_records: minItems=72; observed length=71
omitted unit
test_derived_corruptions: exit=1: FAIL: schema corpus.json/units: minItems=75; observed length=74
duplicate unit
test_derived_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in units
duplicate source
test_derived_corruptions: exit=1: FAIL: duplicate legacy_id 'legacy:lane1:c0:p0' in source_records
wrong source mapping
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /units/0/legacy_id
wrong provenance hash
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /source_records/0/source_sha256
modified residue
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /source_records/0/original/residue/length
holdout promotion
test_derived_corruptions: exit=1: FAIL: schema corpus.json/units/0/evaluation_role: 'development' was expected
unknown facet
test_derived_corruptions: exit=1: FAIL: schema corpus.json/units/0/facets/trust/0: 'imaginary' is not one of ['oracle', 'custodian', 'sequencer', 'curator', 'issuer', 'legal_obligor', 'multisig', 'validator_set', 'attester', 'keeper']
false agreement
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /adjudications/2/rule
binding drift
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /input_bindings/0/sha256
annotation reference drift
test_derived_corruptions: exit=1: FAIL: corpus.json deterministic mismatch at /units/0/annotation_refs/0/pointer
duplicate decision
test_derived_corruptions: exit=1: FAIL: duplicate unit/facet adjudication
unknown derived field
test_derived_corruptions: exit=1: FAIL: schema corpus.json/units/0: Additional properties are not allowed ('verified' was unexpected)
test_derived_corruptions: exit=0: OK check: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_derived_corruptions: exit=1: FAIL: crosswalk.csv: bytes differ from deterministic projection; build into a new directory to inspect
test_derived_corruptions: exit=1: FAIL: coverage.json: bytes differ from deterministic projection; build into a new directory to inspect
test_derived_corruptions: exit=1: FAIL: coverage.json: bytes differ from deterministic projection; build into a new directory to inspect
ok
test_duplicate_json_keys_and_malformed_json (__main__.CorpusCLI.test_duplicate_json_keys_and_malformed_json) ... test_duplicate_json_keys_and_malformed_json: exit=1: FAIL: duplicate JSON key 'x' in corpus/normalized/annotations/a.json
test_duplicate_json_keys_and_malformed_json: exit=1: FAIL: malformed JSON in corpus/normalized/annotations/a.json: Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
ok
test_duplicate_key_in_generated_corpus (__main__.CorpusCLI.test_duplicate_key_in_generated_corpus) ... test_duplicate_key_in_generated_corpus: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_duplicate_key_in_generated_corpus: exit=1: FAIL: duplicate JSON key 'status' in /tmp/corpus-cli-xyz_034q/corpus/normalized/generated/corpus.json
ok
test_identity_corruptions (__main__.CorpusCLI.test_identity_corruptions) ... test_identity_corruptions: exit=1: FAIL: identity unit coverage: expected 75 units
test_identity_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in identity map
test_identity_corruptions: exit=1: FAIL: identity parent-child coverage mismatch: require all 72 sources and exact 75 candidate IDs
test_identity_corruptions: exit=1: FAIL: schema identity map/evaluation_role: 'development' was expected
ok
test_missing_and_empty_inputs (__main__.CorpusCLI.test_missing_and_empty_inputs) ... test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-csjkdssr/corpus/normalized/generated/corpus.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-csjkdssr/corpus/normalized/generated/corpus.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-csjkdssr/corpus/normalized/inputs/taxonomy.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-csjkdssr/corpus/normalized/inputs/taxonomy.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-csjkdssr/corpus/normalized/inputs/taxonomy.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-csjkdssr/corpus/normalized/annotations/a.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-csjkdssr/corpus/normalized/annotations/a.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-csjkdssr/corpus/normalized/annotations/a.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-csjkdssr/corpus50/lanes/lane1-dex-lending-cdp-lsd.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-csjkdssr/corpus50/lanes/lane1-dex-lending-cdp-lsd.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-csjkdssr/corpus50/lanes/lane1-dex-lending-cdp-lsd.json
test_missing_and_empty_inputs: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
ok
test_neutral_source_and_identity_binding (__main__.CorpusCLI.test_neutral_source_and_identity_binding) ... test_neutral_source_and_identity_binding: exit=1: FAIL: neutral annotation input does not match identity map, taxonomy or source rows
test_neutral_source_and_identity_binding: exit=1: FAIL: neutral annotation input does not match identity map, taxonomy or source rows
test_neutral_source_and_identity_binding: exit=1: FAIL: neutral annotation input does not match identity map, taxonomy or source rows
ok
test_partial_source_content_even_with_updated_manifest_hash (__main__.CorpusCLI.test_partial_source_content_even_with_updated_manifest_hash) ... test_partial_source_content_even_with_updated_manifest_hash: exit=3: BLOCKED: source row count mismatch: corpus50/lanes/lane1-dex-lending-cdp-lsd.json
ok
test_path_escape (__main__.CorpusCLI.test_path_escape) ... test_path_escape: exit=3: BLOCKED: path escape: ../outside.json
ok
test_positive_reproducible_read_only (__main__.CorpusCLI.test_positive_reproducible_read_only) ... test_positive_reproducible_read_only: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_positive_reproducible_read_only: exit=0: OK check: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_positive_reproducible_read_only: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_positive_reproducible_read_only: exit=1: FAIL: output directory already exists: /tmp/corpus-cli-fndu3kff/corpus/normalized/generated
ok
test_schema_broken_local_reference (__main__.CorpusCLI.test_schema_broken_local_reference) ... test_schema_broken_local_reference: exit=1: FAIL: invalid JSON Schema: unresolved local reference #/$defs/missing
ok
test_schema_is_checked (__main__.CorpusCLI.test_schema_is_checked) ... test_schema_is_checked: exit=1: FAIL: invalid JSON Schema: 'nonsense' is not valid under any of the given schemas
ok
test_source_drift_and_partial_walk (__main__.CorpusCLI.test_source_drift_and_partial_walk) ... test_source_drift_and_partial_walk: exit=3: BLOCKED: source SHA256 mismatch: corpus50/lanes/lane1-dex-lending-cdp-lsd.json
test_source_drift_and_partial_walk: exit=3: BLOCKED: source inventory: expected exactly all three pinned lanes
ok
test_symlink_escape (__main__.CorpusCLI.test_symlink_escape) ... test_symlink_escape: exit=3: BLOCKED: path escape: corpus/normalized/inputs/taxonomy.json
ok
test_unreadable_and_empty_generated (__main__.CorpusCLI.test_unreadable_and_empty_generated) ... test_unreadable_and_empty_generated: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_unreadable_and_empty_generated: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-uzr23u1a/corpus/normalized/generated/crosswalk.csv
test_unreadable_and_empty_generated: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-uzr23u1a/corpus/normalized/generated/crosswalk.csv: [Errno 21] Is a directory: '/tmp/corpus-cli-uzr23u1a/corpus/normalized/generated/crosswalk.csv'
ok

----------------------------------------------------------------------
Ran 15 tests in 7.811s

OK
```
