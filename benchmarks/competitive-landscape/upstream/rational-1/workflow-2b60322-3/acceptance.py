"""Executed universal proofs, witnesses, semantic mutants and protocol controls."""
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile

import setup
from driver import BASE, case_plan, check_proof, classify, compile_modules, compile_target, invoke, workspace


def executed(record):
    assert record.get('returncode') == 0 and not record.get('timeout'), record


def witness_markers(record, expected):
    executed(record)
    lines = record.get('stdout', '').splitlines()
    assert all(lines.count('WITNESS ' + name + ' passed') == 1 for name in expected), record
    assert not any('FAILED' in line for line in lines), record


def counterexample_pair(original, mutant, label):
    executed(original)
    executed(mutant)
    for record, verdict in [(original, 'true'), (mutant, 'false')]:
        lines = record.get('stdout', '').splitlines()
        assert lines.count('CONTROL ' + label + ' ' + verdict) == 1, record
        assert sum(line.startswith('CONTROL ' + label + ' ') for line in lines) == 1, record


def replace_source(text, change):
    assert change['find'] and change['find'] != change['replace'], change
    assert change['count'] > 0 and text.count(change['find']) == change['count'], change
    return text.replace(change['find'], change['replace'])


def portable(value, work):
    text = json.dumps(value, indent=2)
    paths = {str(Path(path).resolve()) for path in [work, BASE, workspace(), setup.runtime()]}
    for path in sorted(paths, key=len, reverse=True):
        text = text.replace(path, '<runtime>')
    return text


def run(kind, case_id):
    plan = case_plan(case_id)
    catalog = json.loads((BASE / 'acceptance-catalog.json').read_text())
    setup.install()
    work = Path(tempfile.mkdtemp(prefix=kind + '-', dir=workspace()))
    records, attachments = [], {}
    payload = dict(schema_version=1, check=kind, case_id=case_id, status='passed')
    symbol = plan['canonical_symbol']
    imports = ''.join('import ' + name + '\n' for name in plan['model_modules'])
    if kind == 'canonical':
        _, automatic, auto_result = compile_target('automatic', work / 'automatic', case_id)
        _, assisted, result = compile_target('assisted', work / 'assisted', case_id)
        assert result == 'success', assisted
        records = [dict(stage='automatic', classification=auto_result, runs=automatic),
                   dict(stage='assisted', classification=result, runs=assisted)]
        payload.update(domain='canonical_EXACT_RATIONAL', obligations_complete=True)
    elif kind == 'witnesses':
        modules = plan['witness_modules']
        records, result = compile_modules(BASE, work / 'execution', modules)
        assert result == 'success', records
        expected = catalog['witnesses'][case_id]
        witness_markers(records[-1], expected)
        payload['witnesses'] = expected
    elif kind == 'mutants':
        mutations = json.loads((BASE / 'mutations.json').read_text())['cases'][case_id]
        assert set(mutations) == set(catalog['mutants'][case_id]), mutations
        for label, mutation in mutations.items():
            probe_path = BASE / mutation['probe']
            probe = probe_path.read_text()
            source = work / label / 'source'
            source.mkdir(parents=True)
            modules = mutation.get('model_modules', plan['model_modules'])
            for name in modules:
                shutil.copyfile(BASE / (name + '.lean'), source / (name + '.lean'))
            (source / 'Counterexample.lean').write_text(probe)
            original, result = compile_modules(source, work / label / 'original',
                                              [*modules, 'Counterexample'])
            assert result == 'success', original
            for change in mutation['changes']:
                target = source / change['file']
                changed = replace_source(target.read_text(), change)
                target.write_text(changed)
                attachments[label + '-' + target.name] = changed
            observed, result = compile_modules(source, work / label / 'mutated',
                                              [*modules, 'Counterexample'])
            assert result == 'success', observed
            counterexample_pair(original[-1], observed[-1], label)
            records.append(dict(mutant=label, original=original, mutated=observed,
                                discrimination=mutation['discrimination']))
            attachments[label + '-Counterexample.lean'] = probe
        payload.update(status='rejected', reason='counterexample', mutants=list(mutations))
    elif kind == 'parser':
        target, actual, result = compile_target('assisted', work / 'execution', case_id)
        assert result == 'success', actual
        fixtures = {'success': actual[-1]}
        for expected, source in {
            'failed_obligations': imports + 'example : False := by aesop\n',
            'incomplete': imports + '#check ' + plan['canonical_type'] + '\n',
            'malformed': 'import MissingDependency\n',
        }.items():
            path = target / (expected + '.lean')
            path.write_text(source)
            fixtures[expected] = invoke(path, target)
        slow = target / 'Slow.lean'
        slow.write_text(imports + '#eval IO.sleep 2000\n')
        fixtures['timeout'] = invoke(slow, target, timeout=0.05)
        fixtures['cached_skip'] = dict(actual[-1], cached=True)
        outcomes = {key: classify(value, symbol) for key, value in fixtures.items()}
        assert outcomes == {key: key for key in fixtures}, (outcomes, fixtures)
        hole = target / 'Hole.lean'
        hole.write_text(imports + 'theorem ' + symbol + ' : ' + plan['canonical_type'] +
                        ' := by sorry\n#print axioms ' + symbol + '\n')
        rejected_hole = invoke(hole, target)
        assert classify(rejected_hole, symbol) == 'failed_obligations', rejected_hole
        custom = target / 'CustomAxiom.lean'
        custom.write_text(imports + 'axiom workflowInjected : ' + plan['canonical_type'] + '\n' +
                          'theorem ' + symbol + ' : ' + plan['canonical_type'] +
                          ' := workflowInjected\n#print axioms ' + symbol + '\n')
        rejected_axiom = invoke(custom, target)
        assert classify(rejected_axiom, symbol) == 'untrusted_axioms', rejected_axiom
        records = [dict(actual=actual, fixtures=fixtures, outcomes=outcomes,
                        rejected_hole=rejected_hole, rejected_axiom=rejected_axiom)]
        payload['fixtures'] = outcomes
    elif kind == 'trust':
        lock = json.loads((BASE / 'native-lock.json').read_text())
        for name, expected in lock['files'].items():
            assert setup.digest(setup.runtime() / name) == expected, name
        for name, expected in lock['snapshots'].items():
            assert setup.digest(BASE / name) == expected, name
        for module in set(plan['automatic'] + plan['assisted']):
            source = (BASE / (module + '.lean')).read_text()
            # This additional source guard complements actual target axiom output.
            code = '\n'.join(line.split('--', 1)[0] for line in source.splitlines())
            assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', code), module
        target, records, result = compile_target('assisted', work / 'execution', case_id)
        assert result == 'success', records
        records.append(dict(independent_check=check_proof(case_id, target)))
        records.append(dict(native_lock_sha256=setup.digest(BASE / 'native-lock.json'),
                            files_checked=len(lock['files']), snapshots_checked=len(lock['snapshots']),
                            boundary=lock['boundary']))
    elif kind == 'cache':
        for number in range(2):
            target, actual, result = compile_target('assisted', work / str(number), case_id)
            assert result == 'success', actual
            records.append(dict(attempt=number, runs=actual,
                artifact_sha256={name: setup.digest(target / (name + '.olean')) for name in plan['assisted']}))
    else:
        raise ValueError(kind)
    evidence_root = Path(os.environ.get('RATIONAL_ACCEPTANCE_EVIDENCE_ROOT', str(BASE)))
    relative = Path('acceptance-output') / case_id / kind
    destination = evidence_root / relative
    destination.mkdir(parents=True, exist_ok=True)
    (destination / 'records.json').write_text(portable(records, work) + '\n')
    payload['evidence'] = [str(relative / 'records.json')]
    for name, source in attachments.items():
        (destination / name).write_text(source)
        payload['evidence'].append(str(relative / name))
    print(json.dumps(payload))


if __name__ == '__main__':
    run(sys.argv[1], sys.argv[2])
