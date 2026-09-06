# Sprint 3 R2 implementation report

Only scripts/corpus_normalize.py and scripts/test_corpus_normalize.py changed. No schema, raw input, annotation, generated output, documentation, review evidence or commits changed by this task. Files are frozen for parent integration.

Changes: exact overlapping same-facet fixture (A amm/auction; B auction/routing), order-only AGREE record, all seven exact binding paths, custom --data check, no output after blocked builds, specific corruption diagnostics, same-count source edit with updated manifest SHA rejected against neutral context. Manifest source fixtures select entries by path.

Coverage now separates agreed_empty and agreed_nonempty overall and per facet, with an explicit limitation that mutual empty agreement is not positive facet evidence. Synthetic exact totals: 375 decisions, 374 agreements = 372 empty + 2 nonempty; one unresolved difference. Facet records are asserted in full.

Neutral source binding now compares canonical JSON bytes. Regression source true versus neutral 1 passed incorrectly before the fix (exit 0); after the fix it rejects at neutral binding (exit 1). A coherent true/true positive control builds and preserves the arbitrary original field. Derived relative paths use as_posix().

Fresh full command: python3 /home/charl/defiformal/scripts/test_corpus_normalize.py > /tmp/defiformal-sprint3-r2-cli-tests.log 2>&1
Result: exit 0; 18 tests passed in 9.153 seconds.
CLI invocations: {'exit 0': 11, 'exit 1': 39, 'exit 3': 14}

Red command: python3 /home/charl/defiformal/scripts/test_corpus_normalize.py CorpusCLI.test_coverage_distinguishes_empty_agreements CorpusCLI.test_neutral_binding_preserves_original_json_types > /tmp/defiformal-sprint3-r2-red.log 2>&1
Result before implementation: two assertion failures, missing coverage counters and false successful boolean/integer binding.

Mutation sensitivity command: python3 /tmp/defiformal-sprint3-r2-mutants.py > /tmp/defiformal-sprint3-r2-mutants.log 2>&1
Result: exit 0. Three isolated copies of the real CLI were each rejected by the strengthened positive fixture: always-A retained set; dropping every differing retained set; and one-sided rather than symmetric difference. Each mutant completed builds/checks successfully, then failed the expected data assertions. No copied validator was used. All temporary mutant files were outside the repository and automatically removed.

File hashes:
d5de7795be5e0b9e9297f7be2441900fff948ca837657e37482e8938cfe0db88 scripts/corpus_normalize.py
3ef249ce9e9314f59add5f545b3f44a9751f65b28987c20c22b91f561d82cb39 scripts/test_corpus_normalize.py

Full test log:
```text
test_annotation_corruptions (__main__.CorpusCLI.test_annotation_corruptions) ... test_annotation_corruptions: exit=1: FAIL: annotation unit coverage mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: unknown facet label: corpus/normalized/annotations/b.json/unit:lane1:c0:p0/trust
test_annotation_corruptions: exit=1: FAIL: annotation input hash mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: annotator_id mismatch in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0: 'rationale' is a required property
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0/facets/economic_functions: ['exchange', 'exchange'] has non-unique elements
ok
test_coverage_distinguishes_empty_agreements (__main__.CorpusCLI.test_coverage_distinguishes_empty_agreements) ... test_coverage_distinguishes_empty_agreements: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
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
test_duplicate_key_in_generated_corpus: exit=1: FAIL: duplicate JSON key 'status' in /tmp/corpus-cli-dlzg67mq/corpus/normalized/generated/corpus.json
ok
test_identity_corruptions (__main__.CorpusCLI.test_identity_corruptions) ... test_identity_corruptions: exit=1: FAIL: identity unit coverage: expected 75 units
test_identity_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in identity map
test_identity_corruptions: exit=1: FAIL: identity parent-child coverage mismatch: require all 72 sources and exact 75 candidate IDs
test_identity_corruptions: exit=1: FAIL: schema identity map/evaluation_role: 'development' was expected
ok
test_missing_and_empty_inputs (__main__.CorpusCLI.test_missing_and_empty_inputs) ... test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-4f49_b8b/corpus/normalized/generated/corpus.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-4f49_b8b/corpus/normalized/generated/corpus.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-4f49_b8b/corpus/normalized/inputs/taxonomy.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-4f49_b8b/corpus/normalized/inputs/taxonomy.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-4f49_b8b/corpus/normalized/inputs/taxonomy.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-4f49_b8b/corpus/normalized/annotations/a.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-4f49_b8b/corpus/normalized/annotations/a.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-4f49_b8b/corpus/normalized/annotations/a.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-4f49_b8b/corpus50/lanes/lane1-dex-lending-cdp-lsd.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-4f49_b8b/corpus50/lanes/lane1-dex-lending-cdp-lsd.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-4f49_b8b/corpus50/lanes/lane1-dex-lending-cdp-lsd.json
test_missing_and_empty_inputs: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
ok
test_neutral_binding_preserves_original_json_types (__main__.CorpusCLI.test_neutral_binding_preserves_original_json_types) ... test_neutral_binding_preserves_original_json_types: exit=1: FAIL: neutral annotation input does not match identity map, taxonomy or source rows
test_neutral_binding_preserves_original_json_types: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
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
test_positive_reproducible_read_only: exit=0: OK check: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_positive_reproducible_read_only: exit=1: FAIL: output directory already exists: /tmp/corpus-cli-uha_gtgt/corpus/normalized/generated
ok
test_same_count_source_edit_with_updated_manifest_hash (__main__.CorpusCLI.test_same_count_source_edit_with_updated_manifest_hash) ... test_same_count_source_edit_with_updated_manifest_hash: exit=1: FAIL: neutral annotation input does not match identity map, taxonomy or source rows
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
test_unreadable_and_empty_generated: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-snq2h8fn/corpus/normalized/generated/crosswalk.csv
test_unreadable_and_empty_generated: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-snq2h8fn/corpus/normalized/generated/crosswalk.csv: [Errno 21] Is a directory: '/tmp/corpus-cli-snq2h8fn/corpus/normalized/generated/crosswalk.csv'
ok

----------------------------------------------------------------------
Ran 18 tests in 9.153s

OK

```

Mutation discrimination summaries:
DISCRIMINATES: always-A retained set
DISCRIMINATES: drop every differing retained set
DISCRIMINATES: one-sided difference
