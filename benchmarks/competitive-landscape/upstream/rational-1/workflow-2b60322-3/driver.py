"""Replay all new workflow dependencies; the common harness owns scored timing."""
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
ALLOWED_AXIOMS = {'propext', 'Classical.choice', 'Quot.sound'}


def plans():
    return json.loads((BASE / 'case-plan.json').read_text())


def case_plan(case_id):
    declared = json.loads((BASE / 'manifest.json').read_text())['cases']
    if case_id not in declared:
        raise ValueError('Case is not declared by this adapter: ' + case_id)
    return plans()['cases'][case_id]


def classify(record, symbol):
    if record.get('cached'):
        return 'cached_skip'
    if record.get('timeout'):
        return 'timeout'
    output = record.get('stdout', '') + record.get('stderr', '')
    if 'sorryAx' in output or 'declaration uses' in output:
        return 'failed_obligations'
    if record.get('returncode') != 0:
        markers = ['Tactic', 'unsolved goals', 'type mismatch', 'Type mismatch', 'heartbeats', 'tactic']
        return 'failed_obligations' if any(marker in output for marker in markers) else 'malformed'
    matches = re.findall(r"^'" + re.escape(symbol) + r"' depends on axioms: \[([^\]]*)\]$", output, re.M)
    independent = re.findall(r"^'" + re.escape(symbol) + r"' does not depend on any axioms$", output, re.M)
    if len(matches) + len(independent) != 1:
        return 'incomplete'
    if independent:
        return 'success'
    axioms = {part.strip() for part in matches[0].split(',') if part.strip()}
    return 'success' if axioms <= ALLOWED_AXIOMS else 'untrusted_axioms'


def workspace():
    if os.environ.get('MEASUREMENT_OUTPUT'):
        path = Path(os.environ['MEASUREMENT_OUTPUT']) / 'rational-lean'
    elif os.environ.get('XDG_CACHE_HOME'):
        path = Path(os.environ['XDG_CACHE_HOME']) / 'rational-defiformal-workflow'
    else:
        path = setup.root() / 'results/performance-rational/defiformal-workflows-20261106/driver'
    path.mkdir(parents=True, exist_ok=True)
    return path


def invoke(source, work, output=None, timeout=600):
    command = [str(setup.lean()), '-j1']
    portable = ['lean', '-j1']
    if output is not None:
        command += ['-o', str(output)]
        portable += ['-o', str(Path(output).relative_to(work))]
    command.append(str(source))
    portable.append(str(Path(source).relative_to(work)))
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


def module_path(name):
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*', name):
        raise ValueError('Invalid Lean module name')
    return Path(*name.split('.'))


def compile_modules(source, work, modules, symbol=None):
    source, work = Path(source).resolve(), Path(work).resolve()
    if source == work or source.is_relative_to(work):
        raise ValueError('Compilation output must not contain the source tree')
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    if not modules or len(modules) != len(set(modules)):
        raise ValueError('Declare a nonempty ordered dependency chain without duplicates')
    records = []
    for name in modules:
        relative = module_path(name)
        local = work / relative.with_suffix('.lean')
        local.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / relative.with_suffix('.lean'), local)
        record = invoke(local, work, work / relative.with_suffix('.olean'))
        records.append(record)
        if record.get('returncode') != 0 or 'declaration uses' in record.get('stdout', '') + record.get('stderr', ''):
            return records, classify(record, symbol or '')
    return records, classify(records[-1], symbol) if symbol else 'success'


def compile_target(stage, work=None, case_id=None):
    plan = case_plan(case_id)
    if stage not in ('automatic', 'assisted'):
        raise ValueError('Unknown proof stage')
    setup.install()
    work = Path(work) if work is not None else Path(tempfile.mkdtemp(prefix='target-', dir=workspace()))
    records, result = compile_modules(BASE, work, plan[stage], plan['canonical_symbol'])
    return work, records, result


def selected_case():
    cases = json.loads(os.environ['MEASUREMENT_CASES'])
    if len(cases) != 1:
        raise ValueError('A replay/check job must select exactly one case')
    return cases[0]


def prepare():
    setup.install()
    target = workspace() / 'measured-target'
    if target.exists():
        shutil.rmtree(target)
    target.mkdir()


def export_artifacts(case_id, stage, action, work, modules):
    root = Path(os.environ['MEASUREMENT_OUTPUT'])
    target = root / 'proofs' / (case_id + '-' + stage + '-' + action + '-' + os.environ['MEASUREMENT_RUN_INDEX'])
    target.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((BASE / 'manifest.json').read_text())
    helpers = {entry['path'] for entry in manifest['sources']
               if entry['category'] == 'shared_helper_loc'}
    entries = []
    for name in modules:
        relative = module_path(name)
        role = ('target' if name == modules[-1] else
                'shared_helper' if str(relative.with_suffix('.lean')) in helpers else 'dependency')
        for source in (Path(work) / relative.parent).glob(relative.name + '.olean*'):
            copied = target / source.relative_to(work)
            copied.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, copied)
            entries.append(dict(path=str(copied.relative_to(root)), root='results',
                                format='lean-4.33.0-rc2-olean-compiled-module', role=role))
    return entries


def measure():
    stage, case_id = os.environ['MEASUREMENT_STAGE'], selected_case()
    work, records, result = compile_target(stage, workspace() / 'measured-target', case_id)
    print(json.dumps(records))
    outcome = {'success': 'success', 'failed_obligations': 'inconclusive', 'timeout': 'timeout'}.get(result, 'error')
    payload = dict(outcome=outcome, verification_executed=True)
    if result == 'success':
        payload['proof_artifacts'] = export_artifacts(case_id, stage, 'replay', work, case_plan(case_id)[stage])
    else:
        payload['proof_artifact_unavailability'] = dict(status='unavailable',
            explanation='The attempted procedure did not produce an accepted canonical target module.')
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload))


def build():
    records, result = compile_modules(BASE, workspace() / 'measured-target', plans()['build_modules'])
    print(json.dumps(records))
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(dict(
        outcome='success' if result == 'success' else 'error', verification_executed=True)))


def check_proof(case_id, work):
    modules = case_plan(case_id)['assisted']
    paths = [Path(work) / module_path(name).with_suffix('.olean') for name in modules]
    before = {str(p.relative_to(work)): setup.digest(p) for p in paths}
    env = setup.environment(work)
    env['LEAN_NUM_THREADS'] = '1'
    records = []
    for name in modules:
        started = time.monotonic()
        result = subprocess.run([str(setup.lean().parent / 'leanchecker'), '-v', name],
            cwd=work, env=env, capture_output=True, text=True, timeout=600)
        records.append(dict(command=['leanchecker', '-v', name], returncode=result.returncode,
            stdout=result.stdout, stderr=result.stderr, elapsed_seconds=time.monotonic() - started))
        if result.returncode != 0 or result.stdout.splitlines().count('replaying ' + name) != 1:
            raise AssertionError(records)
    if before != {str(p.relative_to(work)): setup.digest(p) for p in paths}:
        raise AssertionError('Independent checker changed proof artifacts')
    return dict(outcome='success', verification_executed=True, checked_modules=modules,
        runs=records, artifact_sha256=before,
        boundary='Separate leanchecker invocations replay every new model/helper/target module without source tactics. Same Lean kernel; pinned imported libraries trusted; --fresh is not used.')


def check_prepare():
    prepare()
    _, records, result = compile_target('assisted', workspace() / 'measured-target', selected_case())
    if result != 'success':
        raise AssertionError(records)
    print(json.dumps(dict(prepared=True, runs=records)))


def independent_check():
    case_id, work = selected_case(), workspace() / 'measured-target'
    payload = check_proof(case_id, work)
    payload['proof_artifacts'] = export_artifacts(case_id, 'assisted', 'check', work, payload['checked_modules'])
    print(json.dumps(payload))
    Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload))


if __name__ == '__main__':
    {'setup': setup.install, 'prepare': prepare, 'measure': measure, 'build': build,
     'check-prepare': check_prepare, 'check': independent_check}[sys.argv[1]]()
