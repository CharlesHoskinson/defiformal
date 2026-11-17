"""Execute universal proofs, concrete witnesses, mutations, and parser/cache controls."""
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

import setup
from driver import BASE, CASE_FILES, DECLARED_CASES, check_proof, classify, compile_target, invoke, workspace

def portable(value, work):
    text = json.dumps(value, indent=2)
    for path in [work, BASE, workspace(), setup.runtime()]:
        text = text.replace(str(path), '<runtime>')
    return text


def run(kind, case_id='R1-TRANSFER'):
    if case_id not in DECLARED_CASES:
        raise ValueError('Case is not declared by this origin-specific adapter')
    setup.install()
    work = Path(tempfile.mkdtemp(prefix=kind + '-', dir=workspace()))
    records = []
    attachments = {}
    model_name, automatic, assisted, namespace = CASE_FILES[case_id]
    witness_name = 'Witnesses' if case_id == 'R1-TRANSFER' else 'SwapWitnesses'
    payload = dict(schema_version=1, check=kind, case_id=case_id, status='passed')
    if kind == 'canonical':
        _, automatic_runs, automatic_result = compile_target('automatic', work / 'automatic', case_id)
        _, assisted_runs, result = compile_target('assisted', work / 'assisted', case_id)
        assert result == 'success', assisted_runs
        records = [dict(stage='automatic', classification=automatic_result, runs=automatic_runs),
            dict(stage='assisted', classification=result, runs=assisted_runs)]
        payload.update(domain='canonical_EXACT_RATIONAL', obligations_complete=True)
    elif kind == 'witnesses':
        shutil.copyfile(BASE / (model_name + '.lean'), work / (model_name + '.lean'))
        shutil.copyfile(BASE / (witness_name + '.lean'), work / (witness_name + '.lean'))
        model = invoke(work / (model_name + '.lean'), work, work / (model_name + '.olean'))
        witness = invoke(work / (witness_name + '.lean'), work)
        expected = (['transfer_fractional', 'transfer_self', 'transfer_zero', 'transfer_unbounded']
            if case_id == 'R1-TRANSFER' else ['swap_fractional', 'swap_unbounded'])
        assert model['returncode'] == witness['returncode'] == 0, [model, witness]
        assert all('WITNESS ' + name + ' passed' in witness['stdout'] for name in expected), witness
        records = [model, witness]
        payload['witnesses'] = expected
    elif kind == 'mutants' and case_id == 'R1-TRANSFER':
        source = (BASE / 'Model.lean').read_text()
        original = 'effect := DefiKernel.Examples.move asset.native source target amount'
        assert source.count(original) == 1
        mutations = {
            'missing_debit': 'effect := DefiKernel.Examples.pulse (target, asset.native) amount',
            'self_alias_overwrite': 'effect := fun cell => if cell = (target, asset.native) then amount else if cell = (source, asset.native) then -amount else 0',
        }
        for label, replacement in mutations.items():
            target = work / label
            target.mkdir()
            changed = source.replace(original, replacement)
            (target / 'Model.lean').write_text(changed)
            witness_source = (BASE / 'Witnesses.lean').read_text().split('def main : IO Unit :=')[0]
            call = 'send fractional "bob" (2/7)' if label == 'missing_debit' else 'send selfState "alice" (1/3)'
            expected = 'transferredExactly (' + call + ') ' + ('fractional .bob (2/7) (3/7) (2/7)' if label == 'missing_debit' else 'selfState .alice (1/3) (1/3) 0')
            counterexample = witness_source + f'\n#eval {expected}\n#eval match {call} with\n  | .refused reason _ => reprStr reason\n  | .success _ => "unexpected-success"\nend RationalTransfer.Witnesses\n'
            (target / 'Counterexample.lean').write_text(counterexample)
            model = invoke(target / 'Model.lean', target, target / 'Model.olean')
            observed = invoke(target / 'Counterexample.lean', target)
            assert model['returncode'] == observed['returncode'] == 0, [model, observed]
            assert observed['stdout'].splitlines()[0] == 'false', observed
            assert 'nativeFailure' in observed['stdout'] and 'accounting' in observed['stdout'], observed
            records.append(dict(mutant=label, model=model, counterexample=observed,
                discrimination='The modified transition compiles; the real native accounting check rejects the defective effect on the canonical positive witness.'))
            attachments[label + '-Model.lean'] = changed
            attachments[label + '-Counterexample.lean'] = counterexample
        payload.update(status='rejected', reason='checked_rejection', mutants=list(mutations))
    elif kind == 'mutants':
        source = (BASE / 'SwapModel.lean').read_text()
        original = 'let output ← BinaryOp.eval (BinaryOp.divide (Asset := Unit) .scalar) numerator reserveX'
        assert source.count(original) == 1
        mutations = {
            'rounded_swap': original + '\n  let output : ℚ := ↑(Rat.floor output)',
            'wrong_swap_denominator': original.replace('numerator reserveX', 'numerator x'),
        }
        for label, replacement in mutations.items():
            target = work / label
            target.mkdir()
            changed = source.replace(original, replacement)
            (target / 'SwapModel.lean').write_text(changed)
            counterexample = 'import SwapModel\nopen RationalSwap\n#eval decide (swap (.exact (1/3)) (.exact (7/5)) (.exact (2/9)) = .success (14/25) (5/9) (21/25))\n#eval swap (.exact (1/3)) (.exact (7/5)) (.exact (2/9))\n#eval match swap (.exact (1/3)) (.exact (7/5)) (.exact (2/9)) with\n | .success _ x y => decide (x*y = (1/3 : ℚ)*(7/5))\n | .refused _ => false\n'
            (target / 'Counterexample.lean').write_text(counterexample)
            model = invoke(target / 'SwapModel.lean', target, target / 'SwapModel.olean')
            observed = invoke(target / 'Counterexample.lean', target)
            assert model['returncode'] == observed['returncode'] == 0, [model, observed]
            assert observed['stdout'].splitlines()[0] == 'false' and observed['stdout'].splitlines()[-1] == 'false', observed
            assert 'Result.success' in observed['stdout'], observed
            records.append(dict(mutant=label, model=model, counterexample=observed,
                discrimination='The altered native-arithmetic composition compiles and returns a concrete successful but incorrect fractional result, violating exact output and product equality.'))
            attachments[label + '-SwapModel.lean'] = changed
            attachments[label + '-Counterexample.lean'] = counterexample
        payload.update(status='rejected', reason='counterexample', mutants=list(mutations))
    elif kind == 'parser':
        _, actual, result = compile_target('assisted', work, case_id)
        assert result == 'success', actual
        fixtures = {'success': actual[-1]}
        for expected, source in {
            'failed_obligations': f'import {model_name}\nexample : False := by aesop\n',
            'incomplete': f'import {model_name}\n#check {namespace}.Canonical\n',
            'malformed': 'import MissingDependency\n',
        }.items():
            path = work / (expected + '.lean')
            path.write_text(source)
            fixtures[expected] = invoke(path, work)
        slow = work / 'Slow.lean'
        slow.write_text(f'import {model_name}\n#eval IO.sleep 2000\n')
        fixtures['timeout'] = invoke(slow, work, timeout=0.05)
        assert (work / (assisted + '.olean')).exists()
        fixtures['cached_skip'] = dict(actual[-1], cached=True)
        outcomes = {key: classify(value, case_id) for key, value in fixtures.items()}
        assert outcomes == {key: key for key in fixtures}, (outcomes, fixtures)
        hole = work / 'Hole.lean'
        hole.write_text(f'import {model_name}\nnamespace {namespace}\ntheorem canonical : Canonical := by sorry\n#print axioms canonical\nend {namespace}\n')
        rejected_hole = invoke(hole, work)
        assert classify(rejected_hole, case_id) == 'failed_obligations', rejected_hole
        custom = work / 'CustomAxiom.lean'
        custom.write_text(f'import {model_name}\nnamespace {namespace}\naxiom injected : Canonical\ntheorem canonical : Canonical := injected\n#print axioms canonical\nend {namespace}\n')
        rejected_axiom = invoke(custom, work)
        assert classify(rejected_axiom, case_id) == 'untrusted_axioms', rejected_axiom
        records = [dict(fixtures=fixtures, outcomes=outcomes, rejected_hole=rejected_hole, rejected_axiom=rejected_axiom)]
        payload['fixtures'] = outcomes
    elif kind == 'trust':
        lock = json.loads((BASE / 'native-lock.json').read_text())
        for name, expected in lock['files'].items():
            assert setup.digest(setup.runtime() / name) == expected, name
        for name, expected in lock['snapshots'].items():
            assert setup.digest(BASE / name) == expected, name
        for name in [model_name + '.lean', assisted + '.lean', automatic + '.lean']:
            source = (BASE / name).read_text()
            assert not any(marker in source for marker in ['sorry', 'admit', 'axiom ', 'unsafe ', 'native_decide']), name
        _, records, result = compile_target('assisted', work, case_id)
        assert result == 'success', records
        records.append(dict(independent_check=check_proof(case_id, work)))
        records.append(dict(native_files_checked=len(lock['files']), native_lock_sha256=setup.digest(BASE / 'native-lock.json'),
            boundary='Pinned Lean binary, native Core/Examples source and olean hashes verified. Precompiled mathlib closure is a trusted dependency from the checksummed offline archive. Universal theorem depends only on standard propext, Classical.choice, Quot.sound.'))
    elif kind == 'cache':
        for number in range(2):
            target = work / str(number)
            target.mkdir()
            assert not (target / (assisted + '.olean')).exists()
            _, actual, result = compile_target('assisted', target, case_id)
            assert result == 'success' and (target / (assisted + '.olean')).is_file(), actual
            records.append(dict(attempt=number, runs=actual, target_sha256=setup.digest(target / (assisted + '.olean'))))
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
    run(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else 'R1-TRANSFER')
