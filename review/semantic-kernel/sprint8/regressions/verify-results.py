#!/usr/bin/env python3
"""Independently reconcile eleven saved suites, source bindings, and copied artifacts."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path('/home/charl/defiformal')
OUT = ROOT / 'review/semantic-kernel/sprint8/regressions'
RECORD = OUT.parent / 'regression-runs.json'
checks = []


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text())


def check(label, value):
    checks.append({'label': label, 'passed': bool(value)})
    if not value:
        raise AssertionError(label)


record = read(RECORD)
expected_labels = {'typed-mutations', 'composition-mutations', 'parallel-mutations',
                   'typed-runner-controls', 'composition-runner-controls',
                   'parallel-runner-controls', 'axiom-controls', 'typing-controls', 'corpus-controls',
                   'interleaving-mutations', 'interleaving-runner-controls'}
check('exact eleven required suites completed', len(record['runs']) == 11 and
      {r['label'] for r in record['runs']} == expected_labels and
      all(r['exit'] == 0 and r['status'] == 'complete' for r in record['runs']))
prior = read(ROOT / 'review/semantic-kernel/sprint7/regression-runs.json')
for earlier in prior['runs']:
    current = next(r for r in record['runs'] if r['label'] == earlier['label'])
    expected_command = [part.replace(prior['scratch_root'], record['scratch_root'])
                        for part in earlier['command']]
    check(earlier['label'] + ' exact previous command array with fresh output path',
          current['command'] == expected_command)
check('at most three suite subprocesses configured', record['max_parallel_subprocesses'] == 3)
check('source bytes unchanged during regressions', record['sources_unchanged'])
binding = read(OUT / 'source-binding.json')
check('nonempty exact frozen Git binding', len(binding) == record['input_count'] > 0 and
      all(v['matches_candidate'] for v in binding.values()))
check('before after identities match', binding == read(OUT / 'source-binding-after.json'))
for row in record['runs']:
    check(row['label'] + ' frozen HEAD retained',
          row['head_at_start'] == row['head_at_end'] == record['source_revision'])
    check(row['label'] + ' complete log hashes',
          sha(OUT.parent / row['log']) == row['log_sha256'] and
          sha(OUT.parent / row['stdout_log']) == row['stdout_sha256'] and
          sha(OUT.parent / row['stderr_log']) == row['stderr_sha256'])
    check(row['label'] + ' executed script bytes retained', row['script_unchanged'])

outcomes = {}
name_re = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'
for label, count, comparisons, title in [('typed-mutations', 24, 189, 'Typed'),
        ('composition-mutations', 12, 93, 'Composition'), ('parallel-mutations', 14, 131, 'Parallel'),
        ('interleaving-mutations', 14, 116, 'Interleaving')]:
    result = read(OUT / label / 'results.json')['results']
    spec = read(OUT / label / 'mutation-spec.json')
    manifest = read(OUT / label / 'source-manifest.json')
    expected = {v['name'] for v in spec['mutations']}
    check(label + ' exact mutation inventory', len(expected) == count and
          set(result) == expected | {'control'})
    control = result['control']
    check(label + ' nonempty all-true control', control['exit'] == 0 and
          len(control['checks']) == comparisons and set(control['checks'].values()) == {'true'})
    check(label + ' actual source binding', manifest['git_head'] == record['source_revision'] and
          manifest['input_sources_unchanged'] and manifest['sources'] and
          all(binding[p]['sha256'] == h for p, h in manifest['sources'].items()))
    for variant_name, variant in result.items():
        log = (OUT / label / (variant_name + '.log')).read_text()
        observed = re.findall(rf'^({name_re}): (true|false)$', log, re.M)
        check(label + '/' + variant_name + ' full observed inventory',
              len(observed) == comparisons and len(dict(observed)) == comparisons and
              dict(observed) == variant['checks'] and set(dict(observed)) == set(control['checks']))
        check(label + '/' + variant_name + ' generated source hash',
              sha(OUT / label / (variant_name + '.lean')) == variant['fixture_sha256'])
        if variant_name == 'control':
            continue
        mutation = next(m for m in spec['mutations'] if m['name'] == variant_name)
        check(label + '/' + variant_name + ' designated false and protected true',
              variant['exit'] == 1 and
              all(variant['checks'][n] == 'false' for n in mutation['required_false']) and
              all(variant['checks'][n] == 'true' for n in spec['positive_checks']))
        false = [n for n, v in observed if v == 'false']
        errors = [line for line in log.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)]
        check(label + '/' + variant_name + ' runtime failure only', bool(false) and
              len(errors) == 1 and
              errors[0].endswith(f'error: {title} runtime comparisons failed: {len(false)}'))
    outcomes[label] = {'mutants_detected': count, 'comparisons_each': comparisons,
                       'protected_positives_each': len(spec['positive_checks'])}

for label, count in [('composition-runner-controls', 36), ('typed-runner-controls', 17),
                     ('parallel-runner-controls', 45), ('interleaving-runner-controls', 52)]:
    summary = read(OUT / label / 'summary.json')
    check(label + ' actual nonempty case classifications', summary['total'] == count and
          summary['passed'] == count and len(summary['cases']) == count and
          len({c['name'] for c in summary['cases']}) == count and
          all(c['passed'] and c['expected_exit'] == c['actual_exit'] for c in summary['cases']))
    check(label + ' current source and executable identity',
          summary['git_head'] == record['source_revision'] and
          summary['lean_executable_sha256'] == record['tools']['lean_executable_sha256'] and
          sha(Path(summary['runner_source'])) == summary['runner_sha256'] and
          sha(Path(summary['harness_source'])) == summary['harness_sha256'])
    for case in summary['cases']:
        log = OUT / label / Path(case['log']).name
        check(label + '/' + case['name'] + ' copied actual CLI log hash',
              log.is_file() and sha(log) == case['log_sha256'])
    outcomes[label] = {'passed': count, 'total': count, 'kind': 'actual CLI classifications'}

axiom = read(OUT / 'axiom-controls/results.json')
check('99 actual axiom-control assertions', axiom['status'] == 'passed' and
      len(axiom['assertions']) == 99 and all(a['passed'] for a in axiom['assertions']))
check('axiom source unchanged and candidate bound', axiom['git_head'] == record['source_revision'] and
      axiom['source_sha256_before'] == axiom['source_sha256_after'] and
      all(binding[p]['sha256'] == h for p, h in axiom['source_sha256_before'].items()))
outcomes['axiom-controls'] = {'passed': 99, 'total': 99, 'kind': 'audit behavioral controls'}

typing = read(OUT / 'typing-controls/results.json')
check('typing positive plus exact three negatives', set(typing['runs']) ==
      {'positive', 'mixed-assets', 'reversed-price', 'implicit-debt-conversion'} and
      typing['runs']['positive']['exit'] == 0 and
      all(v['exit'] == 1 for k, v in typing['runs'].items() if k != 'positive'))
for name, row in typing['runs'].items():
    log = (OUT / 'typing-controls' / (name + '.log')).read_text()
    check('typing/' + name + ' log and source binding',
          sha(OUT / 'typing-controls' / (name + '.log')) == row['log_sha256'] and
          sha(OUT / 'typing-controls' / (name + '.lean')) == row['fixture_sha256'])
    check('typing/' + name + ' expected actual diagnostic',
          'typing_positive: true' in log if name == 'positive' else 'type mismatch' in log.lower())
check('typing source unchanged', typing['input_sources_unchanged'] and
      typing['git_head'] == record['source_revision'])
outcomes['typing-controls'] = {'executed_positive': 1, 'expected_compiler_type_errors': 3,
                              'financial_counterexamples': 0}
corpus = (OUT / 'corpus-controls.log').read_text()
cli_count = len(re.findall(r': exit=[013]:', corpus))
check('20 corpus tests and 76 actual CLI invocations',
      re.search(r'Ran 20 tests in [\d.]+s\n\nOK\s*$', corpus) and cli_count == 76)
outcomes['corpus-controls'] = {'tests_passed': 20, 'observed_cli_invocations': cli_count}

archive_count = 0
for copy_file in sorted(OUT.glob('*-copy-integrity.json')):
    copied = read(copy_file)
    check(copy_file.stem + ' nonempty complete copies', copied['files_and_links'] and
          all(x['matches'] for x in copied['files_and_links'].values()))
    for archive in copied['nested_git_archives']:
        archive_count += 1
        path = OUT / archive['archive']
        check(archive['archive'] + ' archive hash', sha(path) == archive['sha256'])
        with tarfile.open(path, 'r') as tar:
            observed = {m.name.removeprefix('.git/'): hashlib.sha256(tar.extractfile(m).read()).hexdigest()
                        for m in tar.getmembers() if m.isfile()}
        check(archive['archive'] + ' exact nested Git bytes', observed == archive['file_sha256'])
check('four nested fixture Git archives and no embedded repos', archive_count == 4 and
      not list(OUT.rglob('.git')))
manifest = read(OUT / 'artifact-manifest.json')
check('nonempty artifact manifest hash', manifest and
      sha(OUT / 'artifact-manifest.json') == record['artifact_manifest_sha256'])
for name, item in manifest.items():
    path = OUT / name
    check('artifact/' + name, path.is_symlink() and str(path.readlink()) == item['symlink']
          if 'symlink' in item else path.is_file() and sha(path) == item['sha256'])
summary = {'source_revision': record['source_revision'], 'checks': checks,
           'assertion_count': len(checks), 'all_passed': all(c['passed'] for c in checks),
           'outcomes': outcomes, 'nested_git_archives': archive_count,
           'artifact_manifest_entries': len(manifest)}
(OUT / 'verified-outcomes.json').write_text(json.dumps(summary, indent=2) + '\n')
print('PASS:', len(checks), 'saved evidence assertions')
print(json.dumps(outcomes, indent=2))
