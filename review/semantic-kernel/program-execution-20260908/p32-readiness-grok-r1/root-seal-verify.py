from pathlib import Path
import datetime, hashlib, json, gzip, shutil

b = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o = b / 'p32-readiness-grok-r1'
h = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
read = lambda p: json.loads(p.read_text())
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
assert not (o / 'root-seal.json').exists()
dispatch, process = read(o / 'dispatch.json'), read(o / 'process.json')
assert not Path('/proc', str(dispatch['pid'])).exists()
assert process['log_sha256'] == h(o / 'native.jsonl')
assert process['reported_models'] == ['grok-4.6-build']
assert process['sessions'] == ['01a08c54-fa68-77d1-8e33-7eca99c195ad']
inputs = read(o / 'inputs.json'); sandbox = Path(inputs['sandbox'])
assert len(inputs['files']) == 58
for n, digest in inputs['files'].items(): assert h(sandbox / n) == digest, n
manifest = read(o / 'MANIFEST.json')
assert len(manifest['files']) == manifest['file_count'] == 28
for n, digest in manifest['files'].items(): assert h(o / n) == digest, n
streams, tools = 0, {}
for c in read(o / 'commands.json')['commands']:
    assert c['exit'] == 0, c['id']
    for key in ['stdout', 'stderr']:
        p, digest = c.get(key + '_path'), c.get(key + '_sha256')
        if p is not None and digest is not None:
            assert h(Path(p)) == digest, (c['id'], key)
            streams += 1
    if c.get('tool_path') and c.get('tool_sha256'):
        assert h(Path(c['tool_path'])) == c['tool_sha256'], c['id']
        tools[c['tool_path']] = c['tool_sha256']
verdict = read(o / 'verdict.json')
assert verdict['decision'] == 'ACCEPT_WITH_LIMITATIONS' and not verdict['changes_required']
for task, record in verdict['per_task'].items():
    if task == '33.7': continue
    p = b / 'p32-readiness-preparation' / record['record']
    assert h(p) == record['record_sha256']
    r = read(p)
    assert r['status'] == record['status']
probe = o / 'probes/p32-audit-probes-grok46-high-native-r1-20260910'
cross = read(probe / 'evm-crosscheck.json')
assert cross['pins_equal'] and cross['helpers_equal']
assert len(cross['closure_rows']) == 7
for row in cross['closure_rows']:
    assert row['pin_sha256'] == row['upstream_sha256'] == row['inputs_upstream']
    if row['overlay_path']:
        assert h(Path(row['overlay_path'])) == row['pin_sha256'] == row['source_hashes_json']
summary = read(probe / 'summary.json')
for key in ['all_seven_pin_upstream_match', 'compile_settings_equal_standard_json',
            'genesis_hashes_agree', 'runtime_bytecode_identities_agree', 'inputs_unchanged']:
    assert summary[key], key
with (o / 'native.jsonl.gz').open('xb') as f:
    with gzip.GzipFile(filename='', mode='wb', fileobj=f, mtime=0) as g:
        g.write((o / 'native.jsonl').read_bytes())
record = {'schema': 'defiformal-p32-root-adjudication/v1',
    'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'decision': 'ACCEPT_READINESS_RECORDS_WITH_LIMITATIONS',
    'accepted_tasks': ['33.1', '33.2', '33.3', '33.4', '33.5', '33.6', '33.7'],
    'scope': 'Six scoped readiness records and independent review, not six available platforms or P34 execution.',
    'requested_model': dispatch['requested_model'], 'reported_models': process['reported_models'],
    'sessions': process['sessions'], 'process_exit': process['process_exit'],
    'terminal_interpretation': 'Turn cap reached after all five final artifacts were written. No reporting continuation needed.',
    'metadata_correction': 'Reviewer reported returned model/session unknown while live; root terminal telemetry now binds the actual identity. Historical report preserved.',
    'verified_input_bindings': 58, 'verified_report_bindings': 28,
    'verified_command_stream_bindings': streams, 'verified_tools': tools,
    'receipt_limits': 'Probe summary is structured output, not a separately captured parent raw stdout stream; parent stderr was not retained. In-process checks are labelled in commands.json. Two version subprocesses have raw stdout and stderr.',
    'full_p32_all_environments_available': False, 'full_p34_accepted': False,
    'whole_program_complete': False, 'new_financial_execution': False,
    'held_assessment_payloads_selected_or_read': False,
    'remaining': ['Pin verified source/deployment/toolchain for the five blocked environments.',
                  'P33 API freeze and actual P34 success/refusal execution remain open.']}
write(o / 'root-adjudication.json', record)
shutil.copy2(__file__, o / 'root-seal-verify.py')
files = {str(p.relative_to(o)): h(p) for p in sorted(o.rglob('*'))
         if p.is_file() and p.name not in ['native.jsonl', 'root-seal.json']}
write(o / 'root-seal.json', {'utc': record['utc'], 'files': files,
    'file_count': len(files), 'native_uncompressed_sha256': process['log_sha256'],
    'acceptance_scope': record['scope'], 'whole_program_complete': False})
print(json.dumps({'sealed_files': len(files), 'input_bindings': 58,
    'report_bindings': 28, 'command_stream_bindings': streams,
    'decision': record['decision']}))
