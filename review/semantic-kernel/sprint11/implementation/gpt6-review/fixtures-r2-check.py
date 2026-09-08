"""Read-only source/evidence checks; writes only its GPT-6 review result manifest."""
import gzip
import hashlib
import itertools
import json
import re
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[5]
review = Path(__file__).resolve().parent
ev = review.parent / 'fixtures-r2'
inputs = {}

def read(p):
    p = Path(p)
    if not p.is_absolute():
        p = root / p
    b = p.read_bytes()
    inputs[str(p)] = {'sha256': hashlib.sha256(b).hexdigest(), 'bytes': len(b),
                      'mtime_ns': p.stat().st_mtime_ns}
    return b

def jread(p):
    return json.loads(read(p))

t = read('lean/DefiKernel/Nary/Tests.lean').decode()
ex = read('lean/DefiKernel/Nary/Examples.lean').decode()
read('lean/DefiKernel/Nary/Audit.lean')
read(review / 'fixture-preliminary.md')
read('openspec/changes/finite-participant-causal-composition/design.md')
for p in ev.iterdir():
    if p.is_file():
        read(p)
static = re.findall(r'\("(nary\.[^"]+)",', t)
synth = re.findall(r'\(synth "([^"]+)"', t)
tags = [''.join(map(str, s)) for s in sorted(set(itertools.permutations([0, 0, 1, 2])))]
expected = static + [f'nary.f09.{c}.{s}' for s in synth for c in ['candidate', 'independent']]
expected += [f'nary.f10.sched.{s}.{x}' for s in tags
             for x in ['final', 'reserve', 'monitor'] + [f'prefix{i}' for i in range(5)]]
expected += [f'nary.f18.sched.{"".join(map(str,s))}' for s in itertools.permutations(range(3))]
matches = [re.fullmatch(r'(nary\.[^:]+): (true|false)', s)
           for s in read(ev / 'eval-Audit.final.stdout').decode().splitlines()]
assert all(matches)
pairs = [x.groups() for x in matches]
actual = dict(pairs)
assert len(expected) == len(set(expected)) == len(pairs) == len(actual) == 288
assert set(expected) == set(actual)
assert all(v == 'true' for v in actual.values())
fixtures = jread('openspec/changes/finite-participant-causal-composition/fixtures.json')
f10 = next(x for x in fixtures['fixtures'] if x['id'] == 'F10')
literals = []
for s in f10['twelve_literal_schedule_oracles']:
    for r in s['independent_prefix_expectations']:
        literals.append((s['schedule'], r['participant'], r['own_index'], r['operation'],
                         r['before_main_usd'], r['after_main_usd'], bool(r['outputs']),
                         r['monitor'].lower(), r['locals_nextIndex_and_consumed']))
rx = r'⟨(\[[0-9, ]+\]), (\d+), (\d+), (\d+), (\[[0-9, ]+\]), (\[[0-9, ]+\]), (true|false), \.(\w+), (\[[0-9, ]+\])⟩'
parsed = []
for m in re.finditer(rx, ex):
    a = m.groups()
    parsed.append((json.loads(a[0]), int(a[1]), int(a[2]), int(a[3]), json.loads(a[4]),
                   json.loads(a[5]), a[6] == 'true', a[7], json.loads(a[8])))
assert parsed == literals and len(literals) == 48
private = Path('/home/charl/.cache/defiformal-sprint11-builds/fixture/DefiKernel/Nary')
for manifest in ['worktree-source-hashes.json', 'private-source-hashes.json']:
    for p, v in jread(ev / manifest)['files'].items():
        b = read(p)
        assert hashlib.sha256(b).hexdigest() == v['sha256'] and len(b) == v['bytes']
        assert read(ev / 'source-snapshot' / Path(p).name) == b
        assert read(private / Path(p).name) == b
core_dependencies = {}
for name in ['Schedule', 'Execution', 'Observation', 'CausalRuntime']:
    p = review.parent / 'core-r3/source-snapshot' / (name + '.lean')
    snapshot = read(p)
    core_dependencies[name] = {
        'private_matches_core_r3': read(private / (name + '.lean')) == snapshot,
        'live_matches_core_r3': read('lean/DefiKernel/Nary/' + name + '.lean') == snapshot}
for name in ['lake-build-final', 'eval-Audit.final']:
    assert read(ev / (name + '.status')).strip() == b'0'
    assert read(ev / (name + '.stderr')) == b''
assert b'Build completed successfully' in read(ev / 'lake-build-final.stdout')
prior_false = re.findall(r'^(nary\.[^:]+): false$',
                        read(ev / 'eval-Audit.attempt1.stdout').decode(), re.M)
assert prior_false == ['nary.refusal.peer_continues', 'nary.refusal.attempt', 'nary.f07.skip-no-attempt']
mutations = jread('openspec/changes/finite-participant-causal-composition/planned-mutations.json')['mutations']
assert len(mutations) == 16
for m in mutations:
    assert all(actual[label] == 'true' for label in m['required_false'])
    assert actual[m['expected_protected_check']] == 'true'
identity = jread(review.parent / 'native-worker/fixtures-r2.json')
native = gzip.decompress(read(identity['records'][0]['path']))
assert hashlib.sha256(native).hexdigest() == identity['records'][0]['raw_sha256']
terminal = [json.loads(line) for line in native.splitlines() if json.loads(line).get('type') == 'end'][-1]
assert terminal['sessionId'] == '01a07ed5-e45f-70e2-85f6-c621d2aef4f9'
assert terminal['stopReason'] == 'end_turn'
assert set(terminal['modelUsage']) == {'grok-4.6-build'}
for path, before in inputs.items():
    p = Path(path)
    assert hashlib.sha256(p.read_bytes()).hexdigest() == before['sha256']
    assert p.stat().st_mtime_ns == before['mtime_ns']
result = {'utc': datetime.now(timezone.utc).isoformat(), 'scope': 'read-only fixture source/evidence review; no Lean execution',
          'command': 'python3 review/semantic-kernel/sprint11/implementation/gpt6-review/fixtures-r2-check.py',
          'cwd': str(root), 'inventory': {'literal_ids': len(static), 'synthetic_variants': len(synth),
          'synthetic_ids': 2*len(synth), 'f10_ids': 96, 'f18_generated_ids': 6, 'total_unique': 288,
          'true': 288, 'false': 0, 'expected_ids': sorted(expected), 'actual_rows': pairs},
          'literal_f10_rows_exact': 48, 'prefix_comparisons': 60, 'mutation_contracts_labels_present_true': 16,
          'three_fixture_sources_match_live_private_snapshot_manifests': True,
          'core_dependencies': core_dependencies, 'preserved_prior_false': prior_false,
          'native_terminal': terminal, 'inputs': inputs, 'input_bytes_and_mtime_unchanged_during_check': True,
          'prior_probe_errors': ['wrong formal path corrected to lean', 'telemetry type result corrected to end',
                                 'required_false is a list; corrected scalar probe'],
          'limits': ['no fresh checker Lean/build run', 'F03 direct binary comparison open',
                     'not production mutation execution', 'not generic or financial proof acceptance']}
(review / 'fixtures-r2-inputs.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: v for k, v in result.items() if k not in ['inputs', 'inventory', 'native_terminal']}, indent=2))
print('288/288 exact nonempty unique expected inventory; 48/48 literal rows; 16/16 prescribed labels true')
