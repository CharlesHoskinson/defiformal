"""Pinned native-library replay; the shared harness owns scored timing."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

import setup

BASE = Path(__file__).resolve().parent
DECLARED_CASES = tuple(json.loads((BASE / 'manifest.json').read_text())['cases'])
ALLOWED_AXIOMS = {'propext', 'Classical.choice', 'Quot.sound'}
CASE_FILES = {
    'R1-TRANSFER': ('Model', 'Automatic', 'Assisted', 'RationalTransfer'),
    'R2-SWAP': ('SwapModel', 'SwapAutomatic', 'SwapAssisted', 'RationalSwap'),
}


def classify(record, case_id='R1-TRANSFER'):
    if record.get('cached'):
        return 'cached_skip'
    if record.get('timeout'):
        return 'timeout'
    output = record.get('stdout', '') + record.get('stderr', '')
    if 'sorryAx' in output or 'declaration uses' in output:
        return 'failed_obligations'
    if record.get('returncode') != 0:
        if any(marker in output for marker in ['Tactic', 'unsolved goals', 'type mismatch', 'Type mismatch', 'heartbeats']):
            return 'failed_obligations'
        return 'malformed'
    namespace = CASE_FILES[case_id][3]
    match = re.search(r"^'" + namespace + r"\.canonical' depends on axioms: \[([^\]]*)\]$", output, re.M)
    if not match:
        return 'incomplete'
    axioms = {part.strip() for part in match.group(1).split(',') if part.strip()}
    return 'success' if axioms <= ALLOWED_AXIOMS else 'untrusted_axioms'


def workspace():
    if os.environ.get('MEASUREMENT_OUTPUT'):
        path = Path(os.environ['MEASUREMENT_OUTPUT']) / 'rational-lean'
    elif os.environ.get('XDG_CACHE_HOME'):
        path = Path(os.environ['XDG_CACHE_HOME']) / 'rational-defiformal'
    else:
        path = setup.root() / 'results/performance-rational/defiformal-preparation-20261106/driver'
    path.mkdir(parents=True, exist_ok=True)
    return path


def invoke(source, work, output=None, timeout=600):
    command = [str(setup.lean()), '-j1']
    portable = ['lean', '-j1']
    if output is not None:
        command += ['-o', str(output)]
        portable += ['-o', Path(output).name]
    command.append(str(source))
    portable.append(Path(source).name)
    started = time.monotonic()
    try:
        result = subprocess.run(command, cwd=work, env=setup.environment(work),
                                capture_output=True, text=True, timeout=timeout)
        return dict(command=portable, returncode=result.returncode, stdout=result.stdout,
                    stderr=result.stderr, elapsed_seconds=time.monotonic() - started,
                    source_sha256=setup.digest(source))
    except subprocess.TimeoutExpired as exc:
        def decoded(value):
            return value.decode(errors='replace') if isinstance(value, bytes) else (value or '')
        return dict(command=portable, returncode=None, timeout=True, stdout=decoded(exc.stdout),
                    stderr=decoded(exc.stderr), elapsed_seconds=time.monotonic() - started,
                    source_sha256=setup.digest(source))


def compile_target(stage, work=None, case_id='R1-TRANSFER'):
    if case_id not in DECLARED_CASES:
        raise ValueError('Case is not declared by this origin-specific adapter')
    setup.install()
    work = Path(work) if work is not None else Path(tempfile.mkdtemp(prefix='target-', dir=workspace()))
    work.mkdir(parents=True, exist_ok=True)
    model_name, automatic, assisted, _ = CASE_FILES[case_id]
    target = automatic if stage == 'automatic' else assisted
    for name in [model_name, target]:
        shutil.copyfile(BASE / (name + '.lean'), work / (name + '.lean'))
        (work / (name + '.olean')).unlink(missing_ok=True)
    model = invoke(work / (model_name + '.lean'), work, work / (model_name + '.olean'))
    if model['returncode'] != 0:
        return work, [model], 'malformed'
    proof = invoke(work / (target + '.lean'), work, work / (target + '.olean'))
    return work, [model, proof], classify(proof, case_id)


def prepare():
    setup.install()
    target = workspace() / 'measured-target'
    if target.exists():
        shutil.rmtree(target)
    target.mkdir()


def measure():
    stage = os.environ['MEASUREMENT_STAGE']
    cases = json.loads(os.environ['MEASUREMENT_CASES'])
    assert len(cases) == 1
    case_id = cases[0]
    work, records, result = compile_target(stage, workspace() / 'measured-target', case_id)
    print(json.dumps(records))
    outcome = {'success': 'success', 'failed_obligations': 'inconclusive', 'timeout': 'timeout'}.get(result, 'error')
    payload = dict(outcome=outcome, verification_executed=True)
    if result == 'success':
        model_name, automatic, assisted, _ = CASE_FILES[case_id]
        target = automatic if stage == 'automatic' else assisted
        payload['proof_artifacts'] = export_artifacts(case_id, stage, 'replay', work, [model_name, target])
    else:
        payload['proof_artifact_unavailability'] = dict(status='unavailable',
            explanation='The attempted procedure did not produce an accepted canonical target module.')
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload))


def build():
    work = workspace() / 'measured-target'
    records = []
    for name in [module for case in DECLARED_CASES for module in (CASE_FILES[case][0], CASE_FILES[case][2])]:
        shutil.copyfile(BASE / (name + '.lean'), work / (name + '.lean'))
        records.append(invoke(work / (name + '.lean'), work, work / (name + '.olean')))
    print(json.dumps(records))
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(dict(
        outcome='success' if all(result['returncode'] == 0 for result in records) else 'error', verification_executed=True)))


def check_proof(case_id, work):
    model_name, _, assisted, _ = CASE_FILES[case_id]
    modules = [model_name, assisted]
    paths = [Path(work) / (name + '.olean') for name in modules]
    before = {p.name: setup.digest(p) for p in paths}
    env = setup.environment(work)
    env['LEAN_NUM_THREADS'] = '1'
    records = []
    for name in modules:
        started = time.monotonic()
        result = subprocess.run([str(setup.lean().parent / 'leanchecker'), '-v', name],
            cwd=work, env=env, capture_output=True, text=True, timeout=600)
        records.append(dict(command=['leanchecker', '-v', name], returncode=result.returncode,
            stdout=result.stdout, stderr=result.stderr, elapsed_seconds=time.monotonic() - started))
        assert result.returncode == 0 and result.stdout.splitlines().count('replaying ' + name) == 1, records
    assert before == {p.name: setup.digest(p) for p in paths}, 'Independent checker changed proof artifacts'
    return dict(outcome='success', verification_executed=True, checked_modules=modules,
        runs=records, artifact_sha256=before,
        boundary='Separate leanchecker invocation replays all new model/helper/target module declarations from existing olean artifacts without source tactics. Same Lean kernel implementation; pinned imported libraries remain trusted; --fresh is not used.')


def check_prepare():
    prepare()
    cases = json.loads(os.environ['MEASUREMENT_CASES'])
    assert len(cases) == 1
    _, records, result = compile_target('assisted', workspace() / 'measured-target', cases[0])
    assert result == 'success', records
    print(json.dumps(dict(prepared=True, runs=records)))


def independent_check():
    cases = json.loads(os.environ['MEASUREMENT_CASES'])
    assert len(cases) == 1
    work = workspace() / 'measured-target'
    payload = check_proof(cases[0], work)
    payload['proof_artifacts'] = export_artifacts(cases[0], 'assisted', 'check', work, payload['checked_modules'])
    print(json.dumps(payload))
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload))


def export_artifacts(case_id, stage, action, work, names):
    root = Path(os.environ['MEASUREMENT_OUTPUT'])
    target = root / 'proofs' / (case_id + '-' + stage + '-' + action + '-' + os.environ['MEASUREMENT_RUN_INDEX'])
    target.mkdir(parents=True, exist_ok=True)
    entries = []
    for name in names:
        for source in Path(work).glob(name + '.olean*'):
            copied = target / source.name
            shutil.copyfile(source, copied)
            entries.append(dict(path=str(copied.relative_to(root)),
                format='lean-4.33.0-rc2-olean-compiled-module', root='results', role='target'))
    return entries


if __name__ == '__main__':
    {'setup': setup.install, 'prepare': prepare, 'measure': measure, 'build': build,
     'check-prepare': check_prepare, 'check': independent_check}[sys.argv[1]]()
