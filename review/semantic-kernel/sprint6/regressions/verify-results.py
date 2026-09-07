#!/usr/bin/env python3
"""Verify nonempty saved regression outcomes and the archived artifact inventory."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path('/home/charl/defiformal')
OUT = ROOT / 'review/semantic-kernel/sprint6/regressions'
RECORD = OUT.parent / 'regression-runs.json'
checks = []


def check(label, value):
    checks.append({'label': label, 'passed': bool(value)})
    if not value:
        raise AssertionError(label)


def read(path):
    return json.loads(path.read_text())


record = read(RECORD)
check('all seven required commands completed successfully', len(record['runs']) == 7 and
      all(x['exit'] == 0 and x['status'] == 'complete' for x in record['runs']))
check('source bytes unchanged during all regressions', record['sources_unchanged'])
binding = read(OUT / 'source-binding.json')
check('all 106 scoped inputs match the frozen Git objects', len(binding) == 106 and
      all(x['matches_candidate'] for x in binding.values()))
for row in record['runs']:
    raw = (OUT.parent / row['log']).read_bytes()
    check(row['label'] + ' full log hash matches', hashlib.sha256(raw).hexdigest() == row['log_sha256'])
outcomes = {}
for label, count, comparisons in [('typed-mutations', 24, 189), ('composition-mutations', 12, 93)]:
    result = read(OUT / label / 'results.json')['results']
    spec = read(OUT / label / 'mutation-spec.json')
    expected = {x['name'] for x in spec['mutations']}
    check(label + ' exact nonempty mutation inventory', len(expected) == count and
          set(result) == expected | {'control'})
    control = result['control']
    check(label + ' unchanged control all true', control['exit'] == 0 and
          len(control['checks']) == comparisons and set(control['checks'].values()) == {'true'})
    for mutation in spec['mutations']:
        variant = result[mutation['name']]
        check(label + '/' + mutation['name'] + ' full inventory and semantic detection',
              variant['exit'] == 1 and set(variant['checks']) == set(control['checks']) and
              all(variant['checks'][x] == 'false' for x in mutation['required_false']) and
              all(variant['checks'][x] == 'true' for x in spec['positive_checks']))
        source = OUT / label / (mutation['name'] + '.lean')
        check(label + '/' + mutation['name'] + ' exact executed generated source',
              hashlib.sha256(source.read_bytes()).hexdigest() == variant['fixture_sha256'])
    outcomes[label] = {'mutants_detected': count, 'comparisons_each': comparisons,
                       'positive_controls_each': len(spec['positive_checks'])}
for label, count in [('composition-runner-controls', 36), ('typed-runner-controls', 17)]:
    summary = read(OUT / label / 'summary.json')
    check(label + ' all actual classifications match', summary['total'] == count and
          summary['passed'] == count and len(summary['cases']) == count and
          all(x['passed'] and x['expected_exit'] == x['actual_exit'] for x in summary['cases']))
    outcomes[label] = {'passed': count, 'total': count}
axiom = read(OUT / 'axiom-controls/results.json')
check('99 actual axiom-audit behavioral assertions pass', axiom['status'] == 'passed' and
      len(axiom['assertions']) == 99 and all(x['passed'] for x in axiom['assertions']))
check('axiom-audit copied source bytes unchanged',
      axiom['source_sha256_before'] == axiom['source_sha256_after'])
outcomes['axiom-controls'] = {'passed': 99, 'total': 99}
typing = read(OUT / 'typing-controls/results.json')
check('one positive and three expected typing refusals', len(typing['runs']) == 4 and
      typing['runs']['positive']['exit'] == 0 and all(
          v['exit'] == 1 for k, v in typing['runs'].items() if k != 'positive'))
check('typing source bytes unchanged', typing['input_sources_unchanged'])
outcomes['typing-controls'] = {'positive': 1, 'expected_type_errors': 3}
corpus = (OUT / 'corpus-controls.log').read_text()
check('20 corpus tests passed', re.search(r'Ran 20 tests in [\d.]+s\n\nOK\s*$', corpus))
outcomes['corpus-controls'] = {'tests_passed': 20,
    'observed_cli_invocations': len(re.findall(r': exit=[013]:', corpus))}
(OUT / 'verified-outcomes.json').write_text(json.dumps({'checks': checks, 'outcomes': outcomes},
                                                       indent=2) + '\n')
print('PASS:', len(checks), 'saved evidence assertions')
print(json.dumps(outcomes, indent=2))
