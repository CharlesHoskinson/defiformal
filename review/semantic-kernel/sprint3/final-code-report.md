# Final initial-review remediation: split payloads and schema relations

Only the three assigned files changed; they are frozen for parent integration. No source inputs, annotations, generated outputs, documentation, review records or commits were changed by this task.

The CLI now enforces the split dimension as well as IDs: Liquity v1/v2 require source_label V1/V2 and the exact shared provisional Liquity product. Ondo suffixes require the exact distinct provisional products and labels from the frozen map.

Five coherent corruptions update the temporary identity map, neutral input and both synthetic annotation hashes together: duplicate Liquity version, suffix-swapped Liquity versions, wrong shared Liquity product, duplicate Ondo product and suffix-swapped Ondo products. All five previously built successfully. All five now return 1 with the specific split version/product diagnostic and leave no output directory. The full original-source controls still build/check successfully.

The Draft 2020-12 schema now requires AGREE to have provisional_agreement status and no unresolved labels; INTERSECTION_UNRESOLVED must have unresolved_difference status and nonempty unresolved labels. Two annotation references are required in a/b order via prefixItems. Real generated-data mutations test duplicate references and both statuses/label-cardinality branches. Before this schema change they reached the deterministic projection check; now diagnostics show schema rejection first. The existing false-agreement test was updated accordingly.

Red command:
python3 /home/charl/defiformal/scripts/test_corpus_normalize.py CorpusCLI.test_coherent_split_payload_corruptions CorpusCLI.test_adjudication_schema_and_distinct_annotation_refs > /tmp/defiformal-sprint3-splits-red.log 2>&1
Observed: exit 1; 10 expected red assertions across five incorrectly successful identity corruptions and five schema checks not yet enforced.

Fresh final command:
python3 /home/charl/defiformal/scripts/test_corpus_normalize.py > /tmp/defiformal-sprint3-final-cli-tests.log 2>&1
Observed: exit 0; 20 tests in 11.300 seconds. All tests execute the actual CLI in isolated complete-source fixture repositories.

CLI counts: {'exit 0': 13, 'exit 1': 49, 'exit 3': 14}

f7f00d7c80ba11ef80d268910066a47896538c223511f5588009487ecf3f9ecc scripts/corpus_normalize.py
0c3ef8580a44b81b9d55cd2e9cd03d74580d2ee722d5acd57609f0a94faf278f scripts/test_corpus_normalize.py
2b7e2fb94db8247293bb974465204ba9ed7d8359560238c26ce3ca0dbd860fab corpus/normalized/corpus.schema.json

Schema bytes changed, so parent must regenerate actual artifacts to refresh their schema binding. No additional reviewer round was started.

Full final CLI log:
```text
test_adjudication_schema_and_distinct_annotation_refs (__main__.CorpusCLI.test_adjudication_schema_and_distinct_annotation_refs) ... test_adjudication_schema_and_distinct_annotation_refs: exit=0: OK build: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
test_adjudication_schema_and_distinct_annotation_refs: exit=1: FAIL: schema corpus.json/units/0/annotation_refs/1/annotator_id: 'b' was expected
test_adjudication_schema_and_distinct_annotation_refs: exit=1: FAIL: schema corpus.json/adjudications/0/status: 'provisional_agreement' was expected
test_adjudication_schema_and_distinct_annotation_refs: exit=1: FAIL: schema corpus.json/adjudications/0/unresolved_labels: maxItems=0; observed length=1
test_adjudication_schema_and_distinct_annotation_refs: exit=1: FAIL: schema corpus.json/adjudications/2/status: 'unresolved_difference' was expected
test_adjudication_schema_and_distinct_annotation_refs: exit=1: FAIL: schema corpus.json/adjudications/2/unresolved_labels: minItems=1; observed length=0
test_adjudication_schema_and_distinct_annotation_refs: exit=0: OK check: 72 source rows; 75 candidate units; 375 facet decisions; 374 provisional agreements; 1 unresolved differences. No semantic accuracy claim.
ok
test_annotation_corruptions (__main__.CorpusCLI.test_annotation_corruptions) ... test_annotation_corruptions: exit=1: FAIL: annotation unit coverage mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: unknown facet label: corpus/normalized/annotations/b.json/unit:lane1:c0:p0/trust
test_annotation_corruptions: exit=1: FAIL: annotation input hash mismatch: corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: annotator_id mismatch in corpus/normalized/annotations/b.json
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0: 'rationale' is a required property
test_annotation_corruptions: exit=1: FAIL: schema corpus/normalized/annotations/b.json/annotations/0/facets/economic_functions: ['exchange', 'exchange'] has non-unique elements
ok
test_coherent_split_payload_corruptions (__main__.CorpusCLI.test_coherent_split_payload_corruptions) ... test_coherent_split_payload_corruptions: exit=1: FAIL: identity split version mismatch: unit:lane1:c2:p4:v2
test_coherent_split_payload_corruptions: exit=1: FAIL: identity split version mismatch: unit:lane1:c2:p4:v1
test_coherent_split_payload_corruptions: exit=1: FAIL: identity split product mismatch: unit:lane1:c2:p4:v1
test_coherent_split_payload_corruptions: exit=1: FAIL: identity split product mismatch: unit:lane3:c0:p0:ousg
test_coherent_split_payload_corruptions: exit=1: FAIL: identity split product mismatch: unit:lane3:c0:p0:usdy
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
test_derived_corruptions: exit=1: FAIL: schema corpus.json/adjudications/2/status: 'provisional_agreement' was expected
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
test_duplicate_key_in_generated_corpus: exit=1: FAIL: duplicate JSON key 'status' in /tmp/corpus-cli-nond4tll/corpus/normalized/generated/corpus.json
ok
test_identity_corruptions (__main__.CorpusCLI.test_identity_corruptions) ... test_identity_corruptions: exit=1: FAIL: identity unit coverage: expected 75 units
test_identity_corruptions: exit=1: FAIL: duplicate unit_id 'unit:lane1:c0:p0' in identity map
test_identity_corruptions: exit=1: FAIL: identity parent-child coverage mismatch: require all 72 sources and exact 75 candidate IDs
test_identity_corruptions: exit=1: FAIL: schema identity map/evaluation_role: 'development' was expected
ok
test_missing_and_empty_inputs (__main__.CorpusCLI.test_missing_and_empty_inputs) ... test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-av7ld267/corpus/normalized/generated/corpus.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-av7ld267/corpus/normalized/generated/corpus.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-av7ld267/corpus/normalized/inputs/taxonomy.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-av7ld267/corpus/normalized/inputs/taxonomy.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-av7ld267/corpus/normalized/inputs/taxonomy.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-av7ld267/corpus/normalized/annotations/a.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-av7ld267/corpus/normalized/annotations/a.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-av7ld267/corpus/normalized/annotations/a.json
test_missing_and_empty_inputs: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-av7ld267/corpus50/lanes/lane1-dex-lending-cdp-lsd.json: [Errno 2] No such file or directory: '/tmp/corpus-cli-av7ld267/corpus50/lanes/lane1-dex-lending-cdp-lsd.json'
test_missing_and_empty_inputs: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-av7ld267/corpus50/lanes/lane1-dex-lending-cdp-lsd.json
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
test_positive_reproducible_read_only: exit=1: FAIL: output directory already exists: /tmp/corpus-cli-9j8gs439/corpus/normalized/generated
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
test_unreadable_and_empty_generated: exit=3: BLOCKED: empty required input: /tmp/corpus-cli-o_okg4bo/corpus/normalized/generated/crosswalk.csv
test_unreadable_and_empty_generated: exit=3: BLOCKED: missing/unreadable required input /tmp/corpus-cli-o_okg4bo/corpus/normalized/generated/crosswalk.csv: [Errno 21] Is a directory: '/tmp/corpus-cli-o_okg4bo/corpus/normalized/generated/crosswalk.csv'
ok

----------------------------------------------------------------------
Ran 20 tests in 11.300s

OK
```
