#!/usr/bin/env python3
"""Prepare and validate the Sprint11 grok-gpt6-r1 hashed-local planning package.

Planning-package completeness and integrity only. No Nary implementation,
no Lean/financial regression, and no planning-gate acceptance.
Exit 0: nonempty package holds. Exit 1: property false. Exit 3: check blocked.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
PLAN = ROOT / 'openspec/changes/finite-participant-causal-composition'
BEFORE = OUT / 'before'
OFFICIAL = OUT.parent / 'official-r1'
AUTHOR = OUT.parent / 'accepted-m2-refresh'
SPECS_DIR = OUT / 'appendices' / 'D-mutation-specs'
VALIDATION = OUT / 'validation'

HEAD_EXPECTED = 'ed94e6050d092e67f945df7b9762d3096ab0feda'
PRIOR_OFFICIAL = 'b85c14af7be6e01340a93dcb00b7bad8a10c11ae'
M2_SOURCE = 'b165bc586080d668f689fbc18dfa09eb8739d688'
OFFICIAL_BUNDLE_SHA = 'bac3172259ac20d5da8c6c1085d625f7a56b49753c42ec8a7a232fe1f993b3cc'
OFFICIAL_BUNDLE_BYTES = 3432047
RUNNER_SHA = '48c53785f17b6d63ca8a8e883de2feeb65cd546b4e9b9c93f9db1a672651e1e8'
HARNESS_SHA = 'c0339642ee44f6bad616398c7bce461df1a496f53f76ecc7227078f2be0ba19c'
GPT6_REVIEW_SHA = '348f4c0b32b989ee12e3cd402030f00b36ea884cff5527415612ad44fddbbbbd'

PRODUCTION_MODULES = [
    'DefiKernel.Nary.Schedule',
    'DefiKernel.Nary.Execution',
    'DefiKernel.Nary.Observation',
    'DefiKernel.Nary.CausalRuntime',
    'DefiKernel.Nary.Examples',
    'DefiKernel.Nary.Tests',
    'DefiKernel.Nary.Audit',
]
MUT_NAME = re.compile(r'[a-z][a-z0-9-]*')
CHECK_NAME = re.compile(r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*')
RESERVED = {'control', 'lean-version', 'lean-path', 'git-head', 'git-root-input-status'}
UNCHANGED_PLAN = {
    '.openspec.yaml', 'accepted-api.json', 'dependency-baseline.json', 'proposed-api.json',
    'specs/causal-prefix-evidence/spec.md',
    'specs/finite-binary-continuation-correspondence/spec.md',
    'specs/finite-initialized-interference/spec.md',
}
CHANGED_PLAN = {
    'proposal.md', 'design.md', 'tasks.md', 'fixtures.json', 'planned-mutations.json',
    'runner-adaptation.json',
    'specs/finite-participant-execution/spec.md',
    'specs/finite-participant-regression-evidence/spec.md',
}


class Blocked(Exception):
    pass


class Failed(Exception):
    pass


def utc():
    return datetime.now(timezone.utc).isoformat()


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def rec(path: Path) -> dict:
    raw = path.read_bytes()
    return {'path': str(path.relative_to(ROOT)), 'sha256': sha(raw), 'bytes': len(raw)}


def load(path: Path):
    return json.loads(path.read_text())


def dump(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def git(*args: str) -> str:
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def which(name: str) -> Path:
    found = shutil.which(name)
    if not found:
        raise Blocked(f'tool unavailable: {name}')
    return Path(found)


def verify_rows(rows, label: str) -> int:
    if not rows:
        raise Blocked(f'{label}: empty selection (denominator 0 of 0)')
    missing, mismatched = [], []
    for row in rows:
        path = ROOT / row['path']
        if not path.is_file():
            missing.append(row['path'])
            continue
        raw = path.read_bytes()
        digest = sha(raw)
        if digest != row['sha256'] or ('bytes' in row and len(raw) != row['bytes']):
            mismatched.append({'path': row['path'], 'expected': row['sha256'],
                               'actual': digest, 'actual_bytes': len(raw)})
    n = len(rows)
    if missing:
        raise Blocked(f'{label}: missing {len(missing)} of {n}: {missing[:8]}')
    if mismatched:
        raise Failed(f'{label}: hash mismatch {len(mismatched)} of {n}: {mismatched[:4]}')
    return n


def one_mutant_ok(spec: dict, mutant: dict) -> bool:
    if set(spec) != {'schema_version', 'modules', 'mutations', 'positive_checks'}:
        return False
    if spec['schema_version'] != 1:
        return False
    if spec['modules'] != PRODUCTION_MODULES:
        return False
    if 'DefiKernel.Nary.Audit' not in spec['modules']:
        return False
    if len(spec['mutations']) != 1:
        return False
    m = spec['mutations'][0]
    if set(m) != {'name', 'module', 'needle', 'replacement', 'required_false'}:
        return False
    if m['name'] != mutant['runner_name'] or m['name'] in RESERVED:
        return False
    if not MUT_NAME.fullmatch(m['name']):
        return False
    if m['module'] != mutant['module']:
        return False
    if m['needle'] != mutant['needle'] or m['replacement'] != mutant['replacement']:
        return False
    if m['required_false'] != [mutant['oracle_label']]:
        return False
    if spec['positive_checks'] != [mutant['expected_protected_check']]:
        return False
    if set(spec['positive_checks']) & set(m['required_false']):
        return False
    if not all(CHECK_NAME.fullmatch(x) for x in spec['positive_checks'] + m['required_false']):
        return False
    return True


def unioned_spec_rejected(mutations: list) -> bool:
    """True when a single 16-mutant SPEC with unioned positives is recognized as forbidden."""
    protected = [m['expected_protected_check'] for m in mutations]
    false = [m['oracle_label'] for m in mutations]
    union = []
    for label in protected:
        if label not in union:
            union.append(label)
    spec = {
        'schema_version': 1,
        'modules': PRODUCTION_MODULES,
        'mutations': [{'name': m['runner_name'], 'module': m['module'],
                       'needle': m['needle'], 'replacement': m['replacement'],
                       'required_false': [m['oracle_label']]} for m in mutations],
        'positive_checks': union,
    }
    conflicts = set(union) & set(false)
    if conflicts != {'nary.routing.locals', 'nary.monitor.actual_producer'}:
        return False
    if len(spec['mutations']) != 16:
        return False
    if one_mutant_ok(spec, mutations[0]):
        return False
    return True


def make_spec(mutant: dict) -> dict:
    return {
        'schema_version': 1,
        'modules': list(PRODUCTION_MODULES),
        'mutations': [{
            'name': mutant['runner_name'],
            'module': mutant['module'],
            'needle': mutant['needle'],
            'replacement': mutant['replacement'],
            'required_false': list(mutant['required_false']),
        }],
        'positive_checks': [mutant['expected_protected_check']],
    }


def prepare() -> dict:
    SPECS_DIR.mkdir(parents=True, exist_ok=True)
    (OUT / 'appendices').mkdir(exist_ok=True)
    VALIDATION.mkdir(exist_ok=True)
    pm = load(PLAN / 'planned-mutations.json')
    batching = pm['production_spec_batching']
    spec_rows = []
    for mutant in pm['mutations']:
        spec = make_spec(mutant)
        assert one_mutant_ok(spec, mutant), mutant['id']
        path = SPECS_DIR / f"{mutant['id']}.json"
        dump(path, spec)
        spec_rows.append({
            'id': mutant['id'],
            'runner_name': mutant['runner_name'],
            'spec_path': str(path.relative_to(ROOT)),
            'sha256': sha(path.read_bytes()),
            'bytes': path.stat().st_size,
            'required_false': mutant['required_false'],
            'positive_checks': spec['positive_checks'],
            'module': mutant['module'],
            'fixture': mutant['fixture'],
            'command': (
                'python3 scripts/run_nary_mutations.py --repo ROOT --spec '
                f"{path.relative_to(ROOT)} --out NEW_EXTERNAL_OUTPUT_{mutant['id']} "
                '--timeout-seconds 600'
            ),
            'status': 'planning_contract_not_executed',
        })
    dump(OUT / 'mutation-batching.json', {
        'kind': 'sixteen_separate_one_mutant_production_specs',
        'mode': batching['mode'],
        'forbidden': batching['forbidden'],
        'conflicts': batching['conflicts'],
        'same_site_needles': batching['same_site_needles'],
        'timeout_honesty': batching['timeout_honesty'],
        'unioned_positive_checks_rejected': unioned_spec_rejected(pm['mutations']),
        'inherited_runner_sha256': sha((ROOT / 'scripts/run_interface_mutations.py').read_bytes()),
        'count': len(spec_rows),
        'invocations': spec_rows,
        'aggregate_after': 'all sixteen one-mutant invocations succeed',
        'not_implemented': True,
    })
    api = load(PLAN / 'accepted-api.json')
    closure = load(AUTHOR / 'accepted-runtime-closure.json')
    baseline = load(PLAN / 'dependency-baseline.json')
    dump(OUT / 'appendices' / 'A-normative-map.json', {
        'kind': 'complete_immutable_source_map_not_inlined_bundle',
        'change': str(PLAN.relative_to(ROOT)),
        'files': [rec(p) for p in sorted(PLAN.rglob('*')) if p.is_file()],
        'before_snapshot': str(BEFORE.relative_to(ROOT)),
        'entrypoint': str((OUT / 'ENTRYPOINT.md').relative_to(ROOT)),
        'note': 'Read these paths. Do not ingest official-r1/bundle.md as the review prompt.',
    })
    dump(OUT / 'appendices' / 'B-dependency-index.json', {
        'kind': 'accepted_M2_dependency_hashes_not_new_execution',
        'source_candidate': M2_SOURCE,
        'proposed_api_status': load(PLAN / 'proposed-api.json')['status'],
        'accepted_api': rec(PLAN / 'accepted-api.json'),
        'declarations': [{
            'name': d['name'], 'path': d['path'], 'source_sha256': d['source_sha256'],
            'current_sha256': sha((ROOT / d['path']).read_bytes()),
            'equal_to_accepted_source': sha((ROOT / d['path']).read_bytes()) == d['source_sha256'],
        } for d in api['declarations']],
        'runtime_modules': [{
            **row,
            'current_sha256': sha((ROOT / row['path']).read_bytes()),
            'equal_to_accepted_source': sha((ROOT / row['path']).read_bytes()) == row['sha256'],
        } for row in closure['modules']],
        'baseline_references': baseline.get('baseline_references', []),
        'runner': rec(ROOT / 'scripts/run_interface_mutations.py'),
        'harness': rec(ROOT / 'scripts/test_interface_mutation_runner.py'),
        'lake': [rec(ROOT / p) for p in (
            'lean/lakefile.toml', 'lean/lake-manifest.json', 'lean/lean-toolchain',
            'lean/DefiKernel.lean')],
        'nary_directory_exists': (ROOT / 'lean/DefiKernel/Nary').exists(),
        'composition_port_uniqueness': {
            'path': 'lean/DefiKernel/Composition/Interfaces.lean',
            'sha256': sha((ROOT / 'lean/DefiKernel/Composition/Interfaces.lean').read_bytes()),
            'rule': 'Component.portIds is component-wide unique; validateCatalog requires portIds.Nodup',
        },
    })
    official_manifest = load(OFFICIAL / 'manifest.json')
    dump(OUT / 'appendices' / 'C-historical-evidence.json', {
        'kind': 'historical_identities_not_relabelled_fresh',
        'official_r1': {
            'candidate': PRIOR_OFFICIAL,
            'bundle': rec(OFFICIAL / 'bundle.md'),
            'expected_bundle_sha256': OFFICIAL_BUNDLE_SHA,
            'expected_bundle_bytes': OFFICIAL_BUNDLE_BYTES,
            'fable': {
                'result': 'Prompt is too long',
                'verdict': 'NO_VERDICT',
                'invocation': rec(OFFICIAL / 'review-fable.invocation.json'),
                'response': rec(OFFICIAL / 'review-fable.json'),
                'text': rec(OFFICIAL / 'review-fable.md'),
            },
            'input_count': official_manifest['input_count'],
            'inputs': official_manifest['inputs'],
            'note': 'Hash map only. Do not inline the 3.4MB bundle into a prompt.',
        },
        'author_refresh': {
            'readiness': rec(AUTHOR / 'READINESS.md'),
            'author_validation': rec(AUTHOR / 'author-validation.json'),
            'artifact_manifest': rec(AUTHOR / 'artifact-manifest.json'),
            'note': '682/682 author checks are retained identity, not a fresh rerun.',
        },
        'historical_bridge_ed94': {
            'commit': HEAD_EXPECTED,
            'effect': 'DefiHistorical Convex saturation added; accepted M2 APIs unchanged',
            'defi_historical': rec(ROOT / 'lean/DefiHistorical.lean'),
        },
        'original_plan_review_gpt6': {
            'verdict': 'ACCEPT WITH LIMITATIONS',
            'required_mathematical_fixes': 'none',
            'does_not_accept_this_package': True,
            'report': rec(OUT / 'original-plan-review/gpt6-original-plan-review-r1.md'),
        },
    })
    dump(OUT / 'original-plan-review' / 'advisory-notes.json', {
        'kind': 'gpt6_original_plan_advisory_notes_implementation_dispositions',
        'original_plan_verdict': 'ACCEPT WITH LIMITATIONS',
        'required_mathematical_fixes': 'none',
        'package_gate': 'pending independent GPT-6 review of this recovered package',
        'notes': [
            {
                'id': 1,
                'title': 'Bind mutation batching explicitly',
                'disposition': 'sixteen separate one-mutant SPEC invocations',
                'conflicts': ['nary.routing.locals M01 vs M04/M05/M06/M09/M11/M12',
                              'nary.monitor.actual_producer M13 vs M15'],
                'runner_lines': 'scripts/run_interface_mutations.py schema at 127 and positive_true at 352',
            },
            {
                'id': 2,
                'title': 'F05 catalog-valid parameterized producer',
                'disposition': 'one parameterized transfer producer; component port IDs unique',
                'source': 'lean/DefiKernel/Composition/Interfaces.lean Component.portIds / validateCatalog',
            },
            {
                'id': 3,
                'title': 'Honest timeout evidence',
                'disposition': 'outer invocation record required; TimeoutExpired skips child log write',
                'source': 'scripts/run_interface_mutations.py run() after subprocess.run; harness 1500s write-after-return',
            },
        ],
    })
    dump(OUT / 'findings.json', {
        'kind': 'planning_preparation_findings_not_gate_acceptance',
        'required_mathematical_fixes': 'none per independent GPT-6 original-plan review',
        'corrections_applied': [
            'sixteen separate one-mutant production SPECs; unioned positives forbidden',
            'F05 catalog-valid parameterized producer; expected 6/2 collision values unchanged',
            'timeout honesty: TimeoutExpired does not save child stdout; outer record required',
            'M13/M15 same unique appended-attempt needle; alternative replacements; do not duplicate',
            'planning-gate reviewer binding for this recovered package is independent GPT-6; official-r1 Fable remains NO_VERDICT',
        ],
        'unchanged': [
            'all 16 mutation needles/replacements/oracles/protected checks',
            'all 65 inherited controls and their successor_spec_text',
            'F01-F04 and F06-F19 financial/diagnostic expectations except F05 catalog construction',
            'accepted M2 APIs and 18 runtime module bytes',
            'official-r1 artifacts',
            'proposed-api remains proposed, not existing',
        ],
        'not_done': [
            'Nary Lean implementation',
            'production mutation execution',
            'inherited CLI control execution',
            'Lean/financial regression',
            'planning-gate acceptance',
        ],
    })
    dump(OUT / 'cancelled-attempt.json', {
        'kind': 'non_verdict_cancelled_command',
        'not_a_source_failure': True,
        'not_a_planning_verdict': True,
        'reason': 'First git identity command was cancelled by a headless permission interaction. A later snapshot command was also cancelled before filesystem permission was granted. Subsequent local commands were permitted.',
        'intended_command': 'git rev-parse/status plus original-plan snapshot',
        'subsequent_successful_identity_utc': '2026-09-08T00:55:29Z',
        'subsequent_head': HEAD_EXPECTED,
    })
    porcelain = git('status', '--porcelain', '-uall')
    identity = {
        'kind': 'grok_gpt6_r1_package_identity',
        'utc': utc(),
        'isolated_baseline': HEAD_EXPECTED,
        'head': git('rev-parse', 'HEAD'),
        'branch': git('rev-parse', '--abbrev-ref', 'HEAD'),
        'prior_official_candidate': PRIOR_OFFICIAL,
        'accepted_M2_source': M2_SOURCE,
        'user_role_override': 'have Grok 4.6 do this work and have GPT 6 check',
        'source_author': 'stock GPT-6 agent Hegel (M3 author plan)',
        'package_worker': 'grok-4.6',
        'independent_checker': 'GPT-6',
        'original_plan_review': {
            'reviewer': 'independent nonauthor GPT-6',
            'verdict': 'ACCEPT WITH LIMITATIONS',
            'required_mathematical_fixes': 'none',
            'does_not_accept_this_package': True,
            'report_sha256': sha((OUT / 'original-plan-review/gpt6-original-plan-review-r1.md').read_bytes()),
        },
        'package_review': 'pending',
        'gate_accepted': False,
        'implementation_tasks_checked': False,
        'nary_implemented': False,
        'official_r1_fable': 'NO_VERDICT Prompt is too long',
        'working_tree_porcelain_sha256': sha(porcelain.encode()),
        'working_tree_entry_count': len([ln for ln in porcelain.splitlines() if ln]),
        'plan_files': {
            'unchanged': [rec(PLAN / p) for p in sorted(UNCHANGED_PLAN)],
            'changed': [rec(PLAN / p) for p in sorted(CHANGED_PLAN)],
        },
        'before_manifest': rec(OUT / 'before-manifest.json'),
        'agents': rec(ROOT / 'AGENTS.md'),
    }
    dump(OUT / 'identity.json', identity)
    return identity


def count_scope():
    reqs, scenarios = [], []
    for spec in sorted((PLAN / 'specs').glob('*/spec.md')):
        text = spec.read_text()
        cap = spec.parent.name
        for r in re.finditer(r'^### Requirement: ([^\n]+)\n(.*?)(?=^### Requirement:|\Z)', text, re.M | re.S):
            reqs.append((cap, r.group(1)))
            for s in re.finditer(r'^#### Scenario: ([^\n]+)\n', r.group(2), re.M):
                scenarios.append((cap, r.group(1), s.group(1)))
    tasks = re.findall(r'^- \[([ x])\] (\d+\.\d+) ', (PLAN / 'tasks.md').read_text(), re.M)
    return reqs, scenarios, tasks


def run_command(name: str, args: list[str]) -> dict:
    exe = which(args[0])
    started = utc()
    tick = time.monotonic()
    proc = subprocess.run(args, cwd=ROOT, capture_output=True)
    stdout_path = VALIDATION / f'{name}.stdout.log'
    stderr_path = VALIDATION / f'{name}.stderr.log'
    stdout_path.write_bytes(proc.stdout)
    stderr_path.write_bytes(proc.stderr)
    return {
        'name': name,
        'command': args,
        'cwd': str(ROOT),
        'utc': started,
        'duration_seconds': round(time.monotonic() - tick, 6),
        'exit': proc.returncode,
        'executable': str(exe),
        'executable_sha256': sha(exe.read_bytes()),
        'stdout_sha256': sha(proc.stdout),
        'stderr_sha256': sha(proc.stderr),
        'stdout_bytes': len(proc.stdout),
        'stderr_bytes': len(proc.stderr),
    }


def validate() -> dict:
    checks = []

    def check(name: str, ok: bool, detail=None):
        checks.append({'name': name, 'passed': bool(ok), 'detail': detail})
        if not ok:
            raise Failed(f'{name}: {detail}')

    try:
        if not (OUT / 'identity.json').is_file():
            prepare()
        identity = load(OUT / 'identity.json')
        check('head', git('rev-parse', 'HEAD') == HEAD_EXPECTED, git('rev-parse', 'HEAD'))
        check('no_nary_dir', not (ROOT / 'lean/DefiKernel/Nary').exists())
        check('proposed_api_not_existing',
              'proposed' in load(PLAN / 'proposed-api.json')['status'].lower())
        before = load(OUT / 'before-manifest.json')
        check('before_nonempty', before['count'] == 15, before['count'])
        verify_rows([{'path': r['snapshot'], 'sha256': r['sha256'], 'bytes': r['bytes']}
                     for r in before['files']], 'before_snapshot')
        for row in before['files']:
            rel = Path(row['source']).relative_to(PLAN.relative_to(ROOT))
            current = sha((PLAN / rel).read_bytes())
            if str(rel) in UNCHANGED_PLAN or str(rel).replace('\\', '/') in UNCHANGED_PLAN:
                check('unchanged:' + str(rel), current == row['sha256'], current)
            elif str(rel) in CHANGED_PLAN:
                check('changed_from_before:' + str(rel), current != row['sha256'], current)
            else:
                raise Failed(f'unclassified plan file {rel}')
        preserved = {
            'review/semantic-kernel/sprint11/planning/official-r1/bundle.md':
                (OFFICIAL_BUNDLE_SHA, OFFICIAL_BUNDLE_BYTES),
            'review/semantic-kernel/sprint11/planning/official-r1/manifest.json':
                ('0bcff1adc767f6723b40d417c3c5dc6885b47d419476417c010d6727fd7d2e12', 57184),
            'review/semantic-kernel/sprint11/planning/official-r1/review-fable.invocation.json':
                ('00e301d63e0b1ea20a1c193822256f52b07cef299525d3e108592122ca296cae', 1304),
            'review/semantic-kernel/sprint11/planning/official-r1/review-fable.json':
                ('256f622213d4b1e31a35e24ed590a45ef3e7260cf2320a72cc7efbcb0a2c5f25', 1145),
            'review/semantic-kernel/sprint11/planning/official-r1/review-fable.md':
                ('0ee95d7ef2ddedd758f1d1fa7dca83366a0b5da9176ef119cc3b3d460ecda848', 19),
            'review/semantic-kernel/sprint11/planning/official-r1/review-fable.stderr':
                ('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 0),
        }
        official_rows = [{'path': p, 'sha256': h, 'bytes': b} for p, (h, b) in preserved.items()]
        n_official = verify_rows(official_rows, 'official_r1')
        check('official_r1_count', n_official == 6, n_official)
        check('gpt6_original_review_hash',
              sha((OUT / 'original-plan-review/gpt6-original-plan-review-r1.md').read_bytes())
              == GPT6_REVIEW_SHA)
        review_text = (OUT / 'original-plan-review/gpt6-original-plan-review-r1.md').read_text()
        check('gpt6_original_verdict_present',
              'ACCEPT WITH LIMITATIONS' in review_text and 'Required fixes' in review_text)
        api = load(PLAN / 'accepted-api.json')
        check('accepted_api_candidate', api['source_candidate'] == M2_SOURCE)
        check('accepted_api_decls', len(api['declarations']) == 27, len(api['declarations']))
        for d in api['declarations']:
            raw = (ROOT / d['path']).read_bytes()
            old = subprocess.check_output(['git', 'show', f"{M2_SOURCE}:{d['path']}"], cwd=ROOT)
            check('m2_api:' + d['name'],
                  sha(raw) == d['source_sha256'] and raw == old and d['source_signature'] in raw.decode())
        closure = load(AUTHOR / 'accepted-runtime-closure.json')
        check('runtime_modules', len(closure['modules']) == 18, len(closure['modules']))
        for row in closure['modules']:
            raw = (ROOT / row['path']).read_bytes()
            old = subprocess.check_output(['git', 'show', f"{M2_SOURCE}:{row['path']}"], cwd=ROOT)
            check('runtime:' + row['path'], sha(raw) == row['sha256'] and raw == old)
        runner = ROOT / 'scripts/run_interface_mutations.py'
        harness = ROOT / 'scripts/test_interface_mutation_runner.py'
        check('runner_sha', sha(runner.read_bytes()) == RUNNER_SHA)
        check('harness_sha', sha(harness.read_bytes()) == HARNESS_SHA)
        runner_text = runner.read_text()
        check('runner_global_positive_schema',
              "{'schema_version', 'modules', 'mutations', 'positive_checks'}" in runner_text)
        check('runner_positive_true_enforced',
              "all(checks[name] == 'true' for name in positives)" in runner_text)
        check('runner_timeout_write_after_return',
              'log = proc.stdout + proc.stderr' in runner_text and
              "(out / (label + '.log')).write_text(log)" in runner_text and
              'timeout=args.timeout_seconds' in runner_text)
        check('runner_no_timeoutexpired_handler',
              'TimeoutExpired' not in runner_text)
        pm = load(PLAN / 'planned-mutations.json')
        check('sixteen_mutants', pm['count'] == 16 and len(pm['mutations']) == 16)
        check('batching_mode',
              pm['production_spec_batching']['mode'] == 'sixteen_separate_one_mutant_spec_invocations')
        check('unioned_rejected', unioned_spec_rejected(pm['mutations']))
        fx = load(PLAN / 'fixtures.json')
        check('nineteen_fixtures', fx['count'] == 19 and len(fx['fixtures']) == 19)
        f05 = next(x for x in fx['fixtures'] if x['id'] == 'F05')
        check('f05_parameterized_producer',
              'parameterized transfer producer' in f05['inputs'] and
              'portIds.Nodup' in f05['inputs'])
        check('f05_expectation_preserved',
              'values6/2' in f05['independent_expectation'] and
              'final vault2 budget2 donor0=0 donor1=4 recipients6/2' in f05['independent_expectation'])
        ra = load(PLAN / 'runner-adaptation.json')
        check('sixty_five_controls', len(ra['controls']) == 65)
        check('timeouts', ra['runtime_timeout_seconds'] == 600 and ra['harness_timeout_seconds'] == 1500)
        check('runner_batching_field',
              ra['production_mutation_batching']['mode'] == 'sixteen_separate_one_mutant_spec_invocations')
        reqs, scenarios, tasks = count_scope()
        check('requirements_19', len(reqs) == 19, len(reqs))
        check('scenarios_52', len(scenarios) == 52, len(scenarios))
        check('tasks_35_unchecked',
              len(tasks) == 35 and all(mark == ' ' for mark, _ in tasks),
              {'count': len(tasks), 'checked': sum(mark == 'x' for mark, _ in tasks)})
        batching = load(OUT / 'mutation-batching.json')
        check('sixteen_specs', batching['count'] == 16 and len(batching['invocations']) == 16)
        spec_rows = []
        for mutant, inv in zip(pm['mutations'], batching['invocations']):
            spec_path = ROOT / inv['spec_path']
            spec = load(spec_path)
            check('one_mutant:' + mutant['id'], one_mutant_ok(spec, mutant))
            spec_rows.append(rec(spec_path))
        n_specs = verify_rows(spec_rows, 'mutation_specs')
        check('spec_denominator', n_specs == 16, n_specs)
        design = (PLAN / 'design.md').read_text()
        check('design_one_mutant', 'sixteen separate one-mutant SPEC invocations' in design)
        check('design_timeout_honesty', 'TimeoutExpired' in design and 'child stdout/stderr log only after' in design)
        check('design_f05', 'parameterized transfer producer' in design)
        agents = (ROOT / 'AGENTS.md').read_text()
        check('agents_role_override',
              'have Grok 4.6 do this work and have GPT 6 check' in agents and
              'fable is back online use 5.1 medium effort' in agents)
        check('no_gate_accepted_claim',
              identity['gate_accepted'] is False and identity['package_review'] == 'pending')
        porcelain_before = git('status', '--porcelain', '-uall')
        commands = [
            run_command('openspec-version', ['openspec', '--version']),
            run_command('openspec-strict',
                        ['openspec', 'validate', 'finite-participant-causal-composition',
                         '--strict', '--no-interactive']),
            run_command('git-diff-check',
                        ['git', 'diff', '--check', '--', str(PLAN.relative_to(ROOT))]),
        ]
        for row in commands:
            check('command:' + row['name'], row['exit'] == 0,
                  {'exit': row['exit'], 'stderr_sha256': row['stderr_sha256']})
        porcelain_after = git('status', '--porcelain', '-uall')
        check('openspec_strict_nonempty',
              commands[1]['stdout_bytes'] + commands[1]['stderr_bytes'] > 0 or
              commands[1]['exit'] == 0)
        result = {
            'status': 'PASS',
            'kind': 'package_completeness_integrity_not_planning_acceptance',
            'gate_accepted': False,
            'package_review': 'pending independent GPT-6',
            'utc': utc(),
            'head': git('rev-parse', 'HEAD'),
            'denominator': {
                'checks': len(checks),
                'official_r1_files': n_official,
                'mutation_specs': n_specs,
                'fixtures': 19,
                'mutants': 16,
                'controls': 65,
                'requirements': 19,
                'scenarios': 52,
                'unchecked_tasks': 35,
                'accepted_api_declarations': 27,
                'runtime_modules': 18,
            },
            'passed': len(checks),
            'failed': [],
            'checks': checks,
            'commands': commands,
            'python': {
                'executable': sys.executable,
                'sha256': sha(Path(sys.executable).read_bytes()),
                'version': sys.version,
            },
            'script_sha256': sha(Path(__file__).read_bytes()),
            'porcelain_before_sha256': sha(porcelain_before.encode()),
            'porcelain_after_sha256': sha(porcelain_after.encode()),
            'limits': [
                'No Nary Lean, production mutants, inherited CLI controls, or financial/Lean suites ran.',
                'Official-r1 Fable remains NO_VERDICT. Original-plan GPT-6 ACCEPT WITH LIMITATIONS does not accept this package.',
                'This checker does not set the planning gate accepted.',
            ],
        }
        dump(VALIDATION / 'result.json', result)
        print(json.dumps({k: result[k] for k in
                          ['status', 'gate_accepted', 'package_review', 'passed', 'denominator']},
                         indent=2))
        return result
    except Blocked as exc:
        result = {'status': 'BLOCKED', 'gate_accepted': False, 'reason': str(exc),
                  'checks': checks, 'utc': utc()}
        dump(VALIDATION / 'result.json', result)
        print(json.dumps(result, indent=2))
        raise
    except Failed as exc:
        result = {'status': 'FAIL', 'gate_accepted': False, 'reason': str(exc),
                  'checks': checks, 'utc': utc()}
        dump(VALIDATION / 'result.json', result)
        print(json.dumps(result, indent=2))
        raise


def negative_empty() -> int:
    try:
        verify_rows([], 'empty-selection')
        print('FAIL: empty selection did not block')
        return 1
    except Blocked as exc:
        print(f'BLOCKED empty-selection as required: {exc}')
        dump(VALIDATION / 'negative-empty.json',
             {'status': 'BLOCKED', 'case': 'empty-selection', 'reason': str(exc),
              'denominator': '0 of 0'})
        return 0


def negative_missing() -> int:
    try:
        verify_rows([{'path': 'review/semantic-kernel/sprint11/planning/grok-gpt6-r1/missing-input-does-not-exist.json',
                      'sha256': '0' * 64, 'bytes': 1}], 'missing-input')
        print('FAIL: missing input did not block')
        return 1
    except Blocked as exc:
        print(f'BLOCKED missing-input as required: {exc}')
        dump(VALIDATION / 'negative-missing.json',
             {'status': 'BLOCKED', 'case': 'missing-input', 'reason': str(exc)})
        return 0


def negative_tamper() -> int:
    real = rec(PLAN / 'proposed-api.json')
    tampered = {**real, 'sha256': '0' * 64}
    try:
        verify_rows([tampered], 'integrity-tamper')
        print('FAIL: tampered hash did not fail')
        return 1
    except Failed as exc:
        print(f'FAIL integrity-tamper as required: {exc}')
        dump(VALIDATION / 'negative-tamper.json',
             {'status': 'FAIL', 'case': 'integrity-tamper', 'reason': str(exc),
              'denominator': '1 of 1'})
        return 0
    except Blocked as exc:
        print(f'FAIL: tamper blocked instead of failing: {exc}')
        return 1


def seal() -> dict:
    skip = {'MANIFEST.json'}
    files = []
    for p in sorted(OUT.rglob('*')):
        if not p.is_file():
            continue
        rel = p.relative_to(OUT)
        if rel.name == 'MANIFEST.json':
            continue
        files.append(rec(p))
    manifest = {
        'kind': 'grok_gpt6_r1_package_manifest',
        'gate_accepted': False,
        'package_review': 'pending independent GPT-6',
        'head': git('rev-parse', 'HEAD'),
        'file_count': len(files),
        'files': files,
        'script_sha256': sha(Path(__file__).read_bytes()),
        'utc': utc(),
    }
    dump(OUT / 'MANIFEST.json', manifest)
    print(json.dumps({'file_count': len(files), 'gate_accepted': False}, indent=2))
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare', action='store_true')
    parser.add_argument('--validate', action='store_true')
    parser.add_argument('--negative', choices=['empty-selection', 'missing-input', 'integrity-tamper'])
    parser.add_argument('--seal', action='store_true')
    args = parser.parse_args()
    try:
        if args.negative == 'empty-selection':
            sys.exit(negative_empty())
        if args.negative == 'missing-input':
            sys.exit(negative_missing())
        if args.negative == 'integrity-tamper':
            sys.exit(negative_tamper())
        if args.prepare or not any([args.validate, args.seal, args.negative]):
            prepare()
        if args.validate or not any([args.prepare, args.seal, args.negative]):
            validate()
        if args.seal:
            seal()
    except Blocked as exc:
        print(f'BLOCKED: {exc}', file=sys.stderr)
        sys.exit(3)
    except Failed as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
