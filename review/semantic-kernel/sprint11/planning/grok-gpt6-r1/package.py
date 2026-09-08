#!/usr/bin/env python3
"""Prepare and read-only-check the Sprint11 grok-gpt6-r1 frozen planning package.

Planning-package completeness and integrity only. No Nary implementation,
no Lean/financial regression, and no planning-gate acceptance.

--prepare writes deterministic derived artifacts and a one-time invocation record.
--seal writes MANIFEST.json (no self-hash) and ANCHOR.json (external trust anchor).
--check is read-only: stored hashes, exact path/ID sets, uniqueness. No writes.
Exit 0: nonempty sealed package holds. Exit 1: property false. Exit 3: blocked.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path

HEAD_EXPECTED = 'ed94e6050d092e67f945df7b9762d3096ab0feda'
PRIOR_OFFICIAL = 'b85c14af7be6e01340a93dcb00b7bad8a10c11ae'
M2_SOURCE = 'b165bc586080d668f689fbc18dfa09eb8739d688'
OFFICIAL_BUNDLE_SHA = 'bac3172259ac20d5da8c6c1085d625f7a56b49753c42ec8a7a232fe1f993b3cc'
OFFICIAL_BUNDLE_BYTES = 3432047
RUNNER_SHA = '48c53785f17b6d63ca8a8e883de2feeb65cd546b4e9b9c93f9db1a672651e1e8'
HARNESS_SHA = 'c0339642ee44f6bad616398c7bce461df1a496f53f76ecc7227078f2be0ba19c'
GPT6_REVIEW_SHA = '348f4c0b32b989ee12e3cd402030f00b36ea884cff5527415612ad44fddbbbbd'
DEFECTIVE_CHECKER_SHA = '4507692c99a169783615b80b267357b495bf8b3fd698b0039abb6fa05b7bfec5'
PACKAGE_REL = 'review/semantic-kernel/sprint11/planning/grok-gpt6-r1'
PLAN_REL = 'openspec/changes/finite-participant-causal-composition'
CHANGE_NAME = 'finite-participant-causal-composition'
OPENSPEC_STRICT_STDOUT = "Change 'finite-participant-causal-composition' is valid\n"
OPENSPEC_VERSION_PREFIX = '1.10.0'

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
UNCHANGED_PLAN = (
    '.openspec.yaml', 'accepted-api.json', 'dependency-baseline.json', 'proposed-api.json',
    'specs/causal-prefix-evidence/spec.md',
    'specs/finite-binary-continuation-correspondence/spec.md',
    'specs/finite-initialized-interference/spec.md',
)
CHANGED_PLAN = (
    'proposal.md', 'design.md', 'tasks.md', 'fixtures.json', 'planned-mutations.json',
    'runner-adaptation.json',
    'specs/finite-participant-execution/spec.md',
    'specs/finite-participant-regression-evidence/spec.md',
)
PLAN_FILES = tuple(sorted(UNCHANGED_PLAN + CHANGED_PLAN))
FIXTURE_IDS = tuple(f'F{i:02d}' for i in range(1, 20))
MUTATION_IDS = tuple(f'M{i:02d}' for i in range(1, 17))
OFFICIAL_R1_FILES = (
    'review/semantic-kernel/sprint11/planning/official-r1/bundle.md',
    'review/semantic-kernel/sprint11/planning/official-r1/manifest.json',
    'review/semantic-kernel/sprint11/planning/official-r1/review-fable.invocation.json',
    'review/semantic-kernel/sprint11/planning/official-r1/review-fable.json',
    'review/semantic-kernel/sprint11/planning/official-r1/review-fable.md',
    'review/semantic-kernel/sprint11/planning/official-r1/review-fable.stderr',
)
LAKE_FILES = (
    'lean/lakefile.toml', 'lean/lake-manifest.json', 'lean/lean-toolchain', 'lean/DefiKernel.lean',
)
AUTHOR_FILES = (
    'review/semantic-kernel/sprint11/planning/accepted-m2-refresh/READINESS.md',
    'review/semantic-kernel/sprint11/planning/accepted-m2-refresh/author-validation.json',
    'review/semantic-kernel/sprint11/planning/accepted-m2-refresh/artifact-manifest.json',
    'review/semantic-kernel/sprint11/planning/accepted-m2-refresh/accepted-runtime-closure.json',
)
CITED_DOCS = (
    'docs/superpowers/specs/2026-09-06-semantic-kernel-design.md',
    'docs/research/semantic-kernel-progress.md',
    '.claude/skills/defi-footguns/SKILL.md',
    'formal/v3/GATE-REGISTER.md',
    'review/semantic-kernel/sprint11/planning/official-preparation/build-bundle.py',
    'review/semantic-kernel/sprint11/planning/official-preparation/prepare.py',
    'review/semantic-kernel/sprint11/planning/official-preparation/current-context.json',
)
ORIGINAL_AGENTS_REL = f'{PACKAGE_REL}/original-official-bytes/AGENTS.md'
DETERMINISTIC_PACKAGE_FILES = tuple(
    [
        'identity.json',
        'mutation-batching.json',
        'findings.json',
        'appendices/A-normative-map.json',
        'appendices/B-dependency-index.json',
        'appendices/C-historical-evidence.json',
        'original-plan-review/advisory-notes.json',
    ] + [f'appendices/D-mutation-specs/{i}.json' for i in MUTATION_IDS]
)


class Blocked(Exception):
    pass


class Failed(Exception):
    pass


class Ctx:
    def __init__(self, root: Path, package: Path):
        self.root = root.resolve()
        self.out = package.resolve()
        self.plan = self.root / PLAN_REL
        self.before = self.out / 'before'
        self.official = self.root / 'review/semantic-kernel/sprint11/planning/official-r1'
        self.author = self.root / 'review/semantic-kernel/sprint11/planning/accepted-m2-refresh'
        self.specs = self.out / 'appendices' / 'D-mutation-specs'
        self.validation = self.out / 'validation'
        self.inventory = self.out / 'source-inventory.json'
        self.manifest = self.out / 'MANIFEST.json'
        self.anchor = self.out / 'ANCHOR.json'
        self.script = Path(__file__).resolve()


def default_ctx() -> Ctx:
    script = Path(__file__).resolve()
    return Ctx(script.parents[5], script.parent)


def utc() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def rec(ctx: Ctx, path: Path) -> dict:
    raw = path.read_bytes()
    return {'path': str(path.relative_to(ctx.root)), 'sha256': sha(raw), 'bytes': len(raw)}


def load(path: Path):
    return json.loads(path.read_text())


def dump_det(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def git(ctx: Ctx, *args: str) -> str:
    return subprocess.check_output(['git', *args], cwd=ctx.root, text=True).strip()


def git_available(ctx: Ctx) -> bool:
    return (ctx.root / '.git').exists() or (ctx.root / '.git').is_file()


def which(name: str) -> Path:
    found = shutil.which(name)
    if not found:
        raise Blocked(f'tool unavailable: {name}')
    return Path(found)


def unique(seq):
    return len(seq) == len(set(seq))


def verify_rows(ctx: Ctx, rows, label: str) -> int:
    if not rows:
        raise Blocked(f'{label}: empty selection (denominator 0 of 0)')
    paths = [row['path'] for row in rows]
    if len(paths) != len(set(paths)):
        dup = sorted({p for p in paths if paths.count(p) > 1})
        raise Failed(f'{label}: duplicate inventory paths {dup[:8]}')
    missing, mismatched = [], []
    for row in rows:
        path = ctx.root / row['path']
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


def require_exact_set(actual, expected, label: str) -> None:
    actual_t = tuple(actual)
    expected_t = tuple(expected)
    if not unique(actual_t):
        raise Failed(f'{label}: duplicate entries in actual list')
    if not unique(expected_t):
        raise Failed(f'{label}: duplicate entries in expected list')
    if len(actual_t) != len(expected_t) or set(actual_t) != set(expected_t):
        missing = sorted(set(expected_t) - set(actual_t))
        extra = sorted(set(actual_t) - set(expected_t))
        raise Failed(f'{label}: set mismatch missing={missing[:8]} extra={extra[:8]} '
                     f'len_actual={len(actual_t)} len_expected={len(expected_t)}')


def one_mutant_ok(spec: dict, mutant: dict) -> bool:
    if set(spec) != {'schema_version', 'modules', 'mutations', 'positive_checks'}:
        return False
    if spec['schema_version'] != 1 or spec['modules'] != PRODUCTION_MODULES:
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
    return all(CHECK_NAME.fullmatch(x) for x in spec['positive_checks'] + m['required_false'])


def unioned_spec_rejected(mutations: list) -> bool:
    protected = [m['expected_protected_check'] for m in mutations]
    false = [m['oracle_label'] for m in mutations]
    union = list(dict.fromkeys(protected))
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
    return not one_mutant_ok(spec, mutations[0])


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


def count_scope(ctx: Ctx):
    reqs, scenarios = [], []
    for spec in sorted((ctx.plan / 'specs').glob('*/spec.md')):
        text = spec.read_text()
        cap = spec.parent.name
        for r in re.finditer(r'^### Requirement: ([^\n]+)\n(.*?)(?=^### Requirement:|\Z)',
                             text, re.M | re.S):
            reqs.append((cap, r.group(1)))
            for s in re.finditer(r'^#### Scenario: ([^\n]+)\n', r.group(2), re.M):
                scenarios.append((cap, r.group(1), s.group(1)))
    tasks = re.findall(r'^- \[([ x])\] (\d+\.\d+) ', (ctx.plan / 'tasks.md').read_text(), re.M)
    return reqs, scenarios, tasks


def run_captured(ctx: Ctx, args: list[str]) -> dict:
    exe = which(args[0])
    proc = subprocess.run(args, cwd=ctx.root, capture_output=True)
    return {
        'command': args,
        'cwd': str(ctx.root),
        'exit': proc.returncode,
        'executable': str(exe),
        'executable_sha256': sha(exe.read_bytes()),
        'stdout': proc.stdout.decode('utf-8', 'replace'),
        'stderr': proc.stderr.decode('utf-8', 'replace'),
        'stdout_sha256': sha(proc.stdout),
        'stderr_sha256': sha(proc.stderr),
        'stdout_bytes': len(proc.stdout),
        'stderr_bytes': len(proc.stderr),
    }


def expected_plan_paths() -> list[str]:
    return [f'{PLAN_REL}/{rel}' for rel in PLAN_FILES]


def expected_before_paths() -> list[str]:
    return [f'{PACKAGE_REL}/before/{rel}' for rel in PLAN_FILES]


def unique_extend(dst: list[str], items) -> None:
    for item in items:
        if item not in dst:
            dst.append(item)


def write_original_agents_snapshot(ctx: Ctx) -> None:
    snap = ctx.out / 'original-official-bytes' / 'AGENTS.md'
    snap.parent.mkdir(parents=True, exist_ok=True)
    if git_available(ctx):
        blob = subprocess.check_output(
            ['git', 'show', f'{HEAD_EXPECTED}:AGENTS.md'], cwd=ctx.root)
        snap.write_bytes(blob)
    elif not snap.is_file():
        raise Blocked('original AGENTS.md snapshot missing and git unavailable')


def declared_authoritative_paths(ctx: Ctx) -> dict:
    """Expected source paths from cited inventories, not from rows just written."""
    official = load(ctx.official / 'manifest.json')
    baseline = load(ctx.plan / 'dependency-baseline.json')
    api = load(ctx.plan / 'accepted-api.json')
    closure = load(ctx.author / 'accepted-runtime-closure.json')
    official_inputs = [r['path'] for r in official['inputs']]
    if len(official_inputs) != 154 or not unique(official_inputs) or official.get('input_count') != 154:
        raise Failed(f'official-r1 manifest is not 154 unique inputs: {len(official_inputs)}')
    baseline_refs = [r['path'] for r in baseline['baseline_references']]
    if len(baseline_refs) != 11 or not unique(baseline_refs):
        raise Failed(f'baseline_references is not 11 unique paths: {len(baseline_refs)}')
    api_paths = []
    unique_extend(api_paths, [d['path'] for d in api['declarations']])
    runtime_paths = [row['path'] for row in closure['modules']]
    expected = []
    unique_extend(expected, expected_plan_paths())
    unique_extend(expected, expected_before_paths())
    unique_extend(expected, official_inputs)
    unique_extend(expected, OFFICIAL_R1_FILES)
    unique_extend(expected, baseline_refs)
    unique_extend(expected, api_paths)
    unique_extend(expected, runtime_paths)
    unique_extend(expected, AUTHOR_FILES)
    unique_extend(expected, CITED_DOCS)
    unique_extend(expected, LAKE_FILES)
    unique_extend(expected, [
        'openspec/config.yaml',
        'AGENTS.md',
        'scripts/run_interface_mutations.py',
        'scripts/test_interface_mutation_runner.py',
        'lean/DefiKernel/Composition/Interfaces.lean',
        f'{PACKAGE_REL}/before-manifest.json',
        f'{PACKAGE_REL}/original-plan-review/gpt6-original-plan-review-r1.md',
        f'{PACKAGE_REL}/original-plan-review/gpt6-original-plan-inputs-r1.json',
        f'{PACKAGE_REL}/package.py',
        ORIGINAL_AGENTS_REL,
    ])
    return {
        'expected_paths': expected,
        'official_r1_input_paths': official_inputs,
        'baseline_reference_paths': baseline_refs,
        'accepted_api_source_paths': api_paths,
        'runtime_module_paths': runtime_paths,
        'official_index': {r['path']: r for r in official['inputs']},
        'baseline_index': {r['path']: r for r in baseline['baseline_references']},
    }


def collect_source_rows(ctx: Ctx, declared: dict) -> list[dict]:
    rows = []
    seen = set()
    official_index = declared['official_index']

    def klass_for(rel: str) -> str:
        if rel in expected_plan_paths():
            return 'plan'
        if rel in expected_before_paths():
            return 'plan-before'
        if rel in OFFICIAL_R1_FILES:
            return 'official-r1'
        if rel in declared['baseline_reference_paths']:
            return 'baseline-reference'
        if rel in declared['accepted_api_source_paths']:
            return 'accepted-api-source'
        if rel in declared['runtime_module_paths']:
            return 'runtime-module'
        if rel in AUTHOR_FILES:
            return 'author-refresh'
        if rel in CITED_DOCS:
            return 'cited-doc'
        if rel in LAKE_FILES:
            return 'lake'
        if rel == ORIGINAL_AGENTS_REL:
            return 'original-official-bytes'
        if rel.startswith(f'{PACKAGE_REL}/appendices/') or rel.endswith('mutation-batching.json') \
                or rel.endswith('findings.json') or rel.endswith('identity.json') \
                or rel.endswith('advisory-notes.json'):
            return 'package-derived'
        if rel.endswith('package.py'):
            return 'package-checker'
        return 'bound-source'

    def annotate_official(row: dict) -> dict:
        orig = official_index.get(row['path'])
        if not orig:
            return row
        row = dict(row)
        row['original_official_r1'] = {
            'sha256': orig['sha256'], 'bytes': orig['bytes'], 'candidate': PRIOR_OFFICIAL,
        }
        if row['sha256'] == orig['sha256'] and row['bytes'] == orig['bytes']:
            row['official_r1_status'] = 'unchanged'
        else:
            row['official_r1_status'] = 'current_binding'
            if row['path'] == 'AGENTS.md':
                row['original_bytes_from'] = ORIGINAL_AGENTS_REL
            elif row['path'].startswith(PLAN_REL + '/'):
                rel = row['path'][len(PLAN_REL) + 1:]
                row['original_bytes_from'] = f'{PACKAGE_REL}/before/{rel}'
            else:
                raise Failed(f'changed official-r1 input has no original-byte snapshot: {row["path"]}')
        return row

    for rel in declared['expected_paths']:
        if rel in seen:
            continue
        path = ctx.root / rel
        if not path.is_file():
            raise Blocked(f'source missing while building inventory: {rel}')
        seen.add(rel)
        row = annotate_official({**rec(ctx, path), 'class': klass_for(rel)})
        rows.append(row)
    return rows


def prepare(ctx: Ctx) -> dict:
    ctx.specs.mkdir(parents=True, exist_ok=True)
    (ctx.out / 'appendices').mkdir(exist_ok=True)
    write_original_agents_snapshot(ctx)
    pm = load(ctx.plan / 'planned-mutations.json')
    batching = pm['production_spec_batching']
    spec_rows = []
    for mutant in pm['mutations']:
        spec = make_spec(mutant)
        if not one_mutant_ok(spec, mutant):
            raise Failed(f'generated spec invalid: {mutant["id"]}')
        path = ctx.specs / f"{mutant['id']}.json"
        dump_det(path, spec)
        spec_rows.append({
            'id': mutant['id'],
            'runner_name': mutant['runner_name'],
            'spec_path': str(path.relative_to(ctx.root)),
            'sha256': sha(path.read_bytes()),
            'bytes': path.stat().st_size,
            'required_false': mutant['required_false'],
            'positive_checks': spec['positive_checks'],
            'module': mutant['module'],
            'fixture': mutant['fixture'],
            'command': (
                'python3 scripts/run_nary_mutations.py --repo ROOT --spec '
                f"{path.relative_to(ctx.root)} --out NEW_EXTERNAL_OUTPUT_{mutant['id']} "
                '--timeout-seconds 600'
            ),
            'status': 'planning_contract_not_executed',
        })
    dump_det(ctx.out / 'mutation-batching.json', {
        'kind': 'sixteen_separate_one_mutant_production_specs',
        'mode': batching['mode'],
        'forbidden': batching['forbidden'],
        'conflicts': batching['conflicts'],
        'same_site_needles': batching['same_site_needles'],
        'timeout_honesty': batching['timeout_honesty'],
        'unioned_positive_checks_rejected': unioned_spec_rejected(pm['mutations']),
        'inherited_runner_sha256': sha((ctx.root / 'scripts/run_interface_mutations.py').read_bytes()),
        'count': len(spec_rows),
        'ids': [row['id'] for row in spec_rows],
        'invocations': spec_rows,
        'aggregate_after': 'all sixteen one-mutant invocations succeed',
        'not_implemented': True,
    })
    api = load(ctx.plan / 'accepted-api.json')
    closure = load(ctx.author / 'accepted-runtime-closure.json')
    baseline = load(ctx.plan / 'dependency-baseline.json')
    plan_files = [rec(ctx, ctx.plan / rel) for rel in PLAN_FILES]
    dump_det(ctx.out / 'appendices' / 'A-normative-map.json', {
        'kind': 'complete_immutable_source_map_not_inlined_bundle',
        'change': PLAN_REL,
        'expected_paths': expected_plan_paths(),
        'files': plan_files,
        'before_snapshot': str(ctx.before.relative_to(ctx.root)),
        'entrypoint': f'{PACKAGE_REL}/ENTRYPOINT.md',
        'note': 'Read these paths. Do not ingest official-r1/bundle.md as the review prompt.',
    })
    dump_det(ctx.out / 'appendices' / 'B-dependency-index.json', {
        'kind': 'accepted_M2_dependency_hashes_not_new_execution',
        'source_candidate': M2_SOURCE,
        'proposed_api_status': load(ctx.plan / 'proposed-api.json')['status'],
        'accepted_api': rec(ctx, ctx.plan / 'accepted-api.json'),
        'declarations': [{
            'name': d['name'], 'path': d['path'], 'source_sha256': d['source_sha256'],
            'current_sha256': sha((ctx.root / d['path']).read_bytes()),
            'equal_to_accepted_source': sha((ctx.root / d['path']).read_bytes()) == d['source_sha256'],
        } for d in api['declarations']],
        'runtime_modules': [{
            'path': row['path'], 'sha256': row['sha256'], 'bytes': row['bytes'],
            'current_sha256': sha((ctx.root / row['path']).read_bytes()),
            'equal_to_accepted_source': sha((ctx.root / row['path']).read_bytes()) == row['sha256'],
        } for row in closure['modules']],
        'baseline_references': baseline.get('baseline_references', []),
        'runner': rec(ctx, ctx.root / 'scripts/run_interface_mutations.py'),
        'harness': rec(ctx, ctx.root / 'scripts/test_interface_mutation_runner.py'),
        'lake': [rec(ctx, ctx.root / p) for p in LAKE_FILES],
        'nary_directory_exists': (ctx.root / 'lean/DefiKernel/Nary').exists(),
        'composition_port_uniqueness': {
            'path': 'lean/DefiKernel/Composition/Interfaces.lean',
            'sha256': sha((ctx.root / 'lean/DefiKernel/Composition/Interfaces.lean').read_bytes()),
            'rule': 'Component.portIds is component-wide unique; validateCatalog requires portIds.Nodup',
        },
    })
    official_manifest = load(ctx.official / 'manifest.json')
    dump_det(ctx.out / 'appendices' / 'C-historical-evidence.json', {
        'kind': 'historical_identities_not_relabelled_fresh',
        'official_r1': {
            'candidate': PRIOR_OFFICIAL,
            'files': [rec(ctx, ctx.root / p) for p in OFFICIAL_R1_FILES],
            'expected_bundle_sha256': OFFICIAL_BUNDLE_SHA,
            'expected_bundle_bytes': OFFICIAL_BUNDLE_BYTES,
            'fable': {
                'result': 'Prompt is too long',
                'verdict': 'NO_VERDICT',
            },
            'input_count': official_manifest['input_count'],
            'inputs': official_manifest['inputs'],
            'note': 'Hash map only. Do not inline the 3.4MB bundle into a prompt.',
        },
        'author_refresh': {
            'files': [rec(ctx, ctx.root / p) for p in AUTHOR_FILES],
            'note': '682/682 author checks are retained identity, not a fresh rerun.',
        },
        'historical_bridge_ed94': {
            'commit': HEAD_EXPECTED,
            'effect': 'DefiHistorical Convex saturation added; accepted M2 APIs unchanged',
        },
        'original_plan_review_gpt6': {
            'verdict': 'ACCEPT WITH LIMITATIONS',
            'required_mathematical_fixes': 'none',
            'does_not_accept_this_package': True,
            'report': rec(ctx, ctx.out / 'original-plan-review/gpt6-original-plan-review-r1.md'),
        },
        'defective_checker_preserved': {
            'path': f'{PACKAGE_REL}/attempt-defective-checker-r1/package.py',
            'sha256': DEFECTIVE_CHECKER_SHA,
            'note': 'Self-hashing --validate attempt. Not the sealed checker.',
        },
    })
    dump_det(ctx.out / 'original-plan-review' / 'advisory-notes.json', {
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
            },
            {
                'id': 2,
                'title': 'F05 catalog-valid parameterized producer',
                'disposition': 'one parameterized transfer producer; component port IDs unique',
            },
            {
                'id': 3,
                'title': 'Honest timeout evidence',
                'disposition': 'outer invocation record required; TimeoutExpired skips child log write',
            },
        ],
    })
    dump_det(ctx.out / 'findings.json', {
        'kind': 'planning_preparation_findings_not_gate_acceptance',
        'required_mathematical_fixes': 'none per independent GPT-6 original-plan review',
        'corrections_applied': [
            'sixteen separate one-mutant production SPECs; unioned positives forbidden',
            'F05 catalog-valid parameterized producer; expected 6/2 collision values unchanged',
            'timeout honesty: TimeoutExpired does not save child stdout; outer record required',
            'M13/M15 same unique appended-attempt needle; alternative replacements; do not duplicate',
            'planning-gate reviewer binding for this recovered package is independent GPT-6; official-r1 Fable remains NO_VERDICT',
            'read-only --check of sealed stored hashes; MANIFEST has external ANCHOR trust anchor',
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
    cancelled = ctx.out / 'cancelled-attempt.json'
    if not cancelled.is_file():
        dump_det(cancelled, {
            'kind': 'non_verdict_cancelled_command',
            'not_a_source_failure': True,
            'not_a_planning_verdict': True,
            'reason': 'Headless permission interaction cancelled snapshot commands.',
            'subsequent_head': HEAD_EXPECTED,
        })
    fx = load(ctx.plan / 'fixtures.json')
    ra = load(ctx.plan / 'runner-adaptation.json')
    reqs, scenarios, tasks = count_scope(ctx)
    identity = {
        'kind': 'grok_gpt6_r1_package_identity',
        'isolated_baseline': HEAD_EXPECTED,
        'head': HEAD_EXPECTED,
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
            'report_sha256': GPT6_REVIEW_SHA,
        },
        'package_review': 'pending',
        'gate_accepted': False,
        'implementation_tasks_checked': False,
        'nary_implemented': False,
        'official_r1_fable': 'NO_VERDICT Prompt is too long',
        'plan_files': {
            'unchanged': [rec(ctx, ctx.plan / p) for p in sorted(UNCHANGED_PLAN)],
            'changed': [rec(ctx, ctx.plan / p) for p in sorted(CHANGED_PLAN)],
        },
        'before_manifest': rec(ctx, ctx.out / 'before-manifest.json'),
        'agents': rec(ctx, ctx.root / 'AGENTS.md'),
        'exact_ids': {
            'fixtures': list(FIXTURE_IDS),
            'mutations': list(MUTATION_IDS),
            'controls': [x['id'] for x in ra['controls']],
            'tasks': [tid for _, tid in tasks],
        },
        'scope': {
            'requirements': len(reqs),
            'scenarios': len(scenarios),
            'tasks': len(tasks),
            'fixtures': len(fx['fixtures']),
            'mutations': len(pm['mutations']),
            'controls': len(ra['controls']),
        },
    }
    dump_det(ctx.out / 'identity.json', identity)
    invoc = ctx.out / 'invocation.json'
    if not invoc.is_file():
        dump_det(invoc, {
            'kind': 'one_time_invocation_metadata_not_a_deterministic_artifact',
            'utc': utc(),
            'python': sys.version,
            'note': 'Preserved on first prepare. Later prepares must not rewrite this file.',
        })
    declared = declared_authoritative_paths(ctx)
    source_rows = collect_source_rows(ctx, declared)
    for rel in DETERMINISTIC_PACKAGE_FILES:
        path = ctx.out / rel
        source_rows.append({**rec(ctx, path), 'class': 'package-derived'})
    expected_paths = list(declared['expected_paths'])
    unique_extend(expected_paths, [f'{PACKAGE_REL}/{rel}' for rel in DETERMINISTIC_PACKAGE_FILES])
    require_exact_set([row['path'] for row in source_rows], expected_paths,
                      'inventory rows vs declared authoritative paths')
    dump_det(ctx.inventory, {
        'kind': 'sealed_source_inventory',
        'head': HEAD_EXPECTED,
        'expected_plan_paths': expected_plan_paths(),
        'expected_before_paths': expected_before_paths(),
        'expected_official_r1_input_paths': declared['official_r1_input_paths'],
        'expected_baseline_reference_paths': declared['baseline_reference_paths'],
        'expected_fixture_ids': list(FIXTURE_IDS),
        'expected_mutation_ids': list(MUTATION_IDS),
        'expected_control_ids': [x['id'] for x in ra['controls']],
        'expected_task_ids': [tid for _, tid in tasks],
        'expected_paths': expected_paths,
        'rows': source_rows,
        'row_count': len(source_rows),
        'note': 'expected_paths is the union of cited inventories (official-r1 154, baseline_references, accepted APIs, cited docs). Stored hashes. --check must not rec() current bytes as expected values.',
    })
    return identity


def check_inventory_structure(inventory: dict) -> None:
    if not isinstance(inventory, dict):
        raise Blocked('inventory is not an object')
    rows = inventory.get('rows')
    if not isinstance(rows, list):
        raise Blocked('inventory rows missing')
    if not rows:
        raise Blocked('empty inventory (denominator 0 of 0)')
    paths = [row.get('path') for row in rows]
    if any(not p for p in paths):
        raise Failed('inventory row missing path')
    if not unique(paths):
        dup = sorted({p for p in paths if paths.count(p) > 1})
        raise Failed(f'duplicate inventory paths: {dup[:8]}')
    expected = inventory.get('expected_paths')
    if not isinstance(expected, list) or not expected:
        raise Blocked('inventory expected_paths missing or empty')
    if not unique(expected):
        raise Failed('duplicate expected_paths in inventory')
    require_exact_set(paths, expected, 'inventory rows vs expected_paths')


def check_sealed(ctx: Ctx) -> dict:
    """Read-only sealed check. Does not create, write or repair files."""
    checks = []

    def note(name: str, ok: bool, detail=None):
        checks.append({'name': name, 'passed': bool(ok), 'detail': detail})
        if not ok:
            raise Failed(f'{name}: {detail}')

    if ctx.inventory.is_file() is False:
        raise Blocked('source-inventory.json missing')
    if ctx.manifest.is_file() is False:
        raise Blocked('MANIFEST.json missing')
    if ctx.anchor.is_file() is False:
        raise Blocked('ANCHOR.json missing; MANIFEST has no self-hash')
    inventory = load(ctx.inventory)
    check_inventory_structure(inventory)
    n_inv = verify_rows(ctx, inventory['rows'], 'source-inventory')
    note('source_inventory_nonempty', n_inv > 0, n_inv)
    declared = declared_authoritative_paths(ctx)
    expected_full = list(declared['expected_paths'])
    unique_extend(expected_full, [f'{PACKAGE_REL}/{rel}' for rel in DETERMINISTIC_PACKAGE_FILES])
    require_exact_set(inventory['expected_paths'], expected_full,
                      'inventory expected_paths vs cited inventories')
    require_exact_set(inventory['expected_official_r1_input_paths'],
                      declared['official_r1_input_paths'], 'official-r1 154 input paths')
    require_exact_set(inventory['expected_baseline_reference_paths'],
                      declared['baseline_reference_paths'], 'baseline_reference paths')
    official_status = [r for r in inventory['rows'] if 'official_r1_status' in r]
    require_exact_set([r['path'] for r in official_status], declared['official_r1_input_paths'],
                      'inventory official-r1 annotated rows')
    unchanged_official = [{'path': r['path'], 'sha256': r['original_official_r1']['sha256'],
                           'bytes': r['original_official_r1']['bytes']}
                          for r in official_status if r['official_r1_status'] == 'unchanged']
    changed_official = [r for r in official_status if r['official_r1_status'] == 'current_binding']
    if len(unchanged_official) + len(changed_official) != 154:
        raise Failed(f'official-r1 identity split {len(unchanged_official)}+{len(changed_official)} != 154')
    n_un = verify_rows(ctx, unchanged_official, 'official-r1-unchanged-original-hashes')
    note('official_r1_unchanged', n_un == len(unchanged_official), n_un)
    n_ch = verify_rows(ctx, [{'path': r['path'], 'sha256': r['sha256'], 'bytes': r['bytes']}
                             for r in changed_official], 'official-r1-current-bindings')
    note('official_r1_current_bindings', n_ch == len(changed_official), n_ch)
    for row in changed_official:
        snap = ctx.root / row['original_bytes_from']
        if not snap.is_file():
            raise Blocked(f'original-byte snapshot missing: {row["original_bytes_from"]}')
        if sha(snap.read_bytes()) != row['original_official_r1']['sha256']:
            raise Failed(f'original-byte snapshot does not match official-r1 hash: {row["path"]}')
        if row['sha256'] == row['original_official_r1']['sha256']:
            raise Failed(f'current_binding relabelled original hash as current: {row["path"]}')
    baseline_rows = [{'path': r['path'], 'sha256': r['sha256'], 'bytes': r['bytes']}
                     for r in inventory['rows'] if r.get('class') == 'baseline-reference']
    require_exact_set([r['path'] for r in baseline_rows], declared['baseline_reference_paths'],
                      'baseline-reference inventory rows')
    n_base = verify_rows(ctx, baseline_rows, 'baseline_references')
    note('baseline_references', n_base == 11, n_base)
    cited_rows = [r for r in inventory['rows'] if r['path'] in CITED_DOCS]
    require_exact_set([r['path'] for r in cited_rows], CITED_DOCS, 'cited docs')
    n_cited = verify_rows(ctx, cited_rows, 'cited-docs')
    note('cited_docs', n_cited == len(CITED_DOCS), n_cited)
    require_exact_set(inventory['expected_plan_paths'], expected_plan_paths(), 'expected_plan_paths')
    require_exact_set(inventory['expected_before_paths'], expected_before_paths(), 'expected_before_paths')
    require_exact_set(inventory['expected_fixture_ids'], FIXTURE_IDS, 'expected_fixture_ids')
    require_exact_set(inventory['expected_mutation_ids'], MUTATION_IDS, 'expected_mutation_ids')
    plan_rows = [r for r in inventory['rows'] if r.get('class') == 'plan']
    require_exact_set([r['path'] for r in plan_rows], expected_plan_paths(), 'plan rows')
    before_rows = [r for r in inventory['rows'] if r.get('class') == 'plan-before']
    require_exact_set([r['path'] for r in before_rows], expected_before_paths(), 'before rows')

    appendix_a = load(ctx.out / 'appendices' / 'A-normative-map.json')
    require_exact_set([r['path'] for r in appendix_a['files']], expected_plan_paths(), 'appendix A paths')
    require_exact_set(appendix_a['expected_paths'], expected_plan_paths(), 'appendix A expected_paths')
    if len(appendix_a['files']) != len(PLAN_FILES):
        raise Failed(f'appendix A length {len(appendix_a["files"])} != {len(PLAN_FILES)}')
    n_a = verify_rows(ctx, appendix_a['files'], 'appendix-A')
    note('appendix_A_frozen_rows', n_a == len(PLAN_FILES), n_a)

    batching = load(ctx.out / 'mutation-batching.json')
    require_exact_set(batching['ids'], MUTATION_IDS, 'mutation-batching ids')
    if len(batching['invocations']) != 16 or len(batching['invocations']) != batching['count']:
        raise Failed('mutation-batching count/len mismatch')
    stored_specs = []
    pm = load(ctx.plan / 'planned-mutations.json')
    require_exact_set([m['id'] for m in pm['mutations']], MUTATION_IDS, 'planned mutation ids')
    if pm['count'] != len(pm['mutations']) or len(pm['mutations']) != 16:
        raise Failed('planned-mutations declared count != list length')
    for mutant, inv in zip(pm['mutations'], batching['invocations']):
        if inv['id'] != mutant['id']:
            raise Failed(f'mutation-batching order mismatch {inv["id"]} vs {mutant["id"]}')
        spec = load(ctx.root / inv['spec_path'])
        if not one_mutant_ok(spec, mutant):
            raise Failed(f'spec contract broken: {mutant["id"]}')
        stored_specs.append({'path': inv['spec_path'], 'sha256': inv['sha256'], 'bytes': inv['bytes']})
    n_specs = verify_rows(ctx, stored_specs, 'mutation_specs_stored_hashes')
    note('mutation_specs_stored', n_specs == 16, n_specs)

    fx = load(ctx.plan / 'fixtures.json')
    fids = [x['id'] for x in fx['fixtures']]
    if fx['count'] != len(fx['fixtures']):
        raise Failed('fixtures declared count != list length')
    require_exact_set(fids, FIXTURE_IDS, 'fixture ids')
    ra = load(ctx.plan / 'runner-adaptation.json')
    cids = [x['id'] for x in ra['controls']]
    if len(ra['controls']) != 65 or len(cids) != 65:
        raise Failed('control list length is not 65')
    require_exact_set(cids, inventory['expected_control_ids'], 'control ids vs inventory')
    if not unique(cids):
        raise Failed('duplicate control ids')

    before = load(ctx.out / 'before-manifest.json')
    if before['count'] != len(before['files']):
        raise Failed('before-manifest declared count != list length')
    bsnaps = [r['snapshot'] for r in before['files']]
    require_exact_set(bsnaps, expected_before_paths(), 'before snapshot paths')
    verify_rows(ctx, [{'path': r['snapshot'], 'sha256': r['sha256'], 'bytes': r['bytes']}
                      for r in before['files']], 'before_snapshot')
    for row in before['files']:
        rel = str(Path(row['source']).relative_to(PLAN_REL))
        current = sha((ctx.plan / rel).read_bytes())
        if rel in UNCHANGED_PLAN:
            if current != row['sha256']:
                raise Failed(f'unchanged plan drifted: {rel}')
        elif rel in CHANGED_PLAN:
            if current == row['sha256']:
                raise Failed(f'changed plan unexpectedly equals before: {rel}')
        else:
            raise Failed(f'unclassified plan file {rel}')

    official_rows = []
    for p in OFFICIAL_R1_FILES:
        match = next(r for r in inventory['rows'] if r['path'] == p)
        official_rows.append(match)
    n_off = verify_rows(ctx, official_rows, 'official_r1')
    note('official_r1_exact', n_off == 6, n_off)
    bundle = next(r for r in official_rows if r['path'].endswith('bundle.md'))
    if bundle['sha256'] != OFFICIAL_BUNDLE_SHA or bundle['bytes'] != OFFICIAL_BUNDLE_BYTES:
        raise Failed('official-r1 bundle identity drifted')

    reqs, scenarios, tasks = count_scope(ctx)
    if len(reqs) != 19 or not unique(reqs):
        raise Failed(f'requirements not exact unique 19: {len(reqs)}')
    if len(scenarios) != 52 or not unique(scenarios):
        raise Failed(f'scenarios not exact unique 52: {len(scenarios)}')
    task_ids = [tid for _, tid in tasks]
    require_exact_set(task_ids, inventory['expected_task_ids'], 'task ids')
    if len(tasks) != 35 or any(mark != ' ' for mark, _ in tasks):
        raise Failed('tasks are not 35 unchecked')
    note('scope_exact', True, {'requirements': 19, 'scenarios': 52, 'tasks': 35})

    if (ctx.root / 'lean/DefiKernel/Nary').exists():
        raise Failed('Nary implementation directory exists')
    if 'proposed' not in load(ctx.plan / 'proposed-api.json')['status'].lower():
        raise Failed('proposed-api is not labelled proposed')
    identity = load(ctx.out / 'identity.json')
    if identity.get('gate_accepted') is not False or identity.get('package_review') != 'pending':
        raise Failed('identity claims gate acceptance or completed package review')
    if identity.get('utc') or 'working_tree_porcelain_sha256' in identity:
        raise Failed('identity embeds non-deterministic invocation metadata')

    appendix_c = load(ctx.out / 'appendices' / 'C-historical-evidence.json')
    n_c = verify_rows(ctx, appendix_c['official_r1']['files'], 'appendix-C-official-r1')
    note('appendix_C_official', n_c == 6, n_c)
    verify_rows(ctx, appendix_c['author_refresh']['files'], 'appendix-C-author')

    appendix_b = load(ctx.out / 'appendices' / 'B-dependency-index.json')
    unique_api, seen = [], set()
    for d in appendix_b['declarations']:
        if d['path'] in seen:
            continue
        seen.add(d['path'])
        unique_api.append({'path': d['path'], 'sha256': d['source_sha256']})
    if len(unique_api) != 6:
        raise Failed(f'accepted-api unique source files {len(unique_api)} != 6')
    verify_rows(ctx, unique_api, 'appendix-B-api-sources')
    runtime_rows = [{'path': r['path'], 'sha256': r['sha256'], 'bytes': r['bytes']}
                    for r in appendix_b['runtime_modules']]
    if len(runtime_rows) != 18 or not unique([r['path'] for r in runtime_rows]):
        raise Failed('runtime modules not exact unique 18')
    verify_rows(ctx, runtime_rows, 'appendix-B-runtime')
    if not appendix_b.get('baseline_references'):
        raise Failed('appendix B omitted baseline_references')
    n_bref = verify_rows(ctx, appendix_b['baseline_references'], 'appendix-B-baseline-references')
    note('appendix_B_baseline_references', n_bref == 11, n_bref)

    review = ctx.out / 'original-plan-review/gpt6-original-plan-review-r1.md'
    if sha(review.read_bytes()) != GPT6_REVIEW_SHA:
        raise Failed('original-plan GPT-6 review bytes drifted')

    if git_available(ctx):
        head = git(ctx, 'rev-parse', 'HEAD')
        if head != HEAD_EXPECTED:
            raise Failed(f'HEAD {head} != {HEAD_EXPECTED}')
        diff = run_captured(ctx, ['git', 'diff', '--check', '--', PLAN_REL])
        if diff['exit'] != 0:
            raise Failed(f'git diff --check failed: {diff["stderr"][:200]}')
        note('git_head_and_diff', True, head)

    openspec_v = run_captured(ctx, ['openspec', '--version'])
    if openspec_v['exit'] != 0 or not openspec_v['stdout'].startswith(OPENSPEC_VERSION_PREFIX):
        raise Blocked(f'openspec version unavailable or unexpected: {openspec_v}')
    strict = run_captured(ctx, ['openspec', 'validate', CHANGE_NAME, '--strict', '--no-interactive'])
    if CHANGE_NAME not in strict['command'] or '--strict' not in strict['command']:
        raise Failed('openspec command did not select the finite-participant change')
    if strict['exit'] != 0:
        raise Failed(f'openspec strict exit {strict["exit"]}')
    if strict['stdout'] != OPENSPEC_STRICT_STDOUT:
        raise Failed({'wanted': OPENSPEC_STRICT_STDOUT, 'got': strict['stdout'],
                      'bytes': strict['stdout_bytes']})
    if CHANGE_NAME not in strict['stdout'] or 'is valid' not in strict['stdout']:
        raise Failed('openspec stdout missing selected change validity')
    note('openspec_strict_exact', True,
         {'stdout': strict['stdout'], 'selected': CHANGE_NAME, 'bytes': strict['stdout_bytes']})

    anchor = load(ctx.anchor)
    if 'manifest_sha256' not in anchor or 'inventory_sha256' not in anchor:
        raise Blocked('ANCHOR.json missing trust-anchor fields')
    manifest_raw = ctx.manifest.read_bytes()
    inventory_raw = ctx.inventory.read_bytes()
    if sha(manifest_raw) != anchor['manifest_sha256']:
        raise Failed('MANIFEST.json does not match ANCHOR.manifest_sha256')
    if sha(inventory_raw) != anchor['inventory_sha256']:
        raise Failed('source-inventory.json does not match ANCHOR.inventory_sha256')
    if len(manifest_raw) != anchor.get('manifest_bytes', len(manifest_raw)):
        raise Failed('MANIFEST byte length does not match ANCHOR')
    note('anchor_external', True, {
        'manifest_sha256': anchor['manifest_sha256'],
        'inventory_sha256': anchor['inventory_sha256'],
        'note': 'MANIFEST does not contain its own hash. Hash MANIFEST.json independently.',
    })
    manifest = load(ctx.manifest)
    files = manifest.get('files')
    if not isinstance(files, list) or not files:
        raise Blocked('MANIFEST files empty (denominator 0 of 0)')
    mpaths = [row['path'] for row in files]
    if str(ctx.manifest.relative_to(ctx.root)) in mpaths:
        raise Failed('MANIFEST lists itself; self-hash is forbidden')
    if str(ctx.anchor.relative_to(ctx.root)) in mpaths:
        raise Failed('MANIFEST lists ANCHOR.json; trust anchor must stay external')
    if not unique(mpaths):
        raise Failed('duplicate MANIFEST paths')
    if manifest.get('file_count') != len(files):
        raise Failed('MANIFEST file_count != len(files)')
    n_man = verify_rows(ctx, files, 'MANIFEST')
    required_pkg = [
        f'{PACKAGE_REL}/package.py',
        f'{PACKAGE_REL}/ENTRYPOINT.md',
        f'{PACKAGE_REL}/REPORT.md',
        f'{PACKAGE_REL}/STATUS.json',
        f'{PACKAGE_REL}/source-inventory.json',
        f'{PACKAGE_REL}/identity.json',
        f'{PACKAGE_REL}/mutation-batching.json',
        f'{PACKAGE_REL}/findings.json',
        f'{PACKAGE_REL}/appendices/A-normative-map.json',
    ] + [f'{PACKAGE_REL}/appendices/D-mutation-specs/{i}.json' for i in MUTATION_IDS]
    missing_pkg = [p for p in required_pkg if p not in set(mpaths)]
    if missing_pkg:
        raise Failed(f'MANIFEST omitted required package files: {missing_pkg[:8]}')
    note('manifest_stored_hashes', n_man == len(files), n_man)

    result = {
        'status': 'PASS',
        'kind': 'sealed_read_only_package_check_not_planning_acceptance',
        'gate_accepted': False,
        'package_review': 'pending independent GPT-6',
        'head_expected': HEAD_EXPECTED,
        'denominator': {
            'checks': len(checks),
            'source_inventory_rows': n_inv,
            'appendix_A': n_a,
            'mutation_specs': n_specs,
            'official_r1': n_off,
            'manifest_files': n_man,
            'fixtures': 19,
            'mutants': 16,
            'controls': 65,
            'requirements': 19,
            'scenarios': 52,
            'unchecked_tasks': 35,
        },
        'passed': len(checks),
        'failed': [],
        'checks': checks,
        'openspec': {
            'command': strict['command'],
            'exit': strict['exit'],
            'stdout': strict['stdout'],
            'executable': strict['executable'],
            'executable_sha256': strict['executable_sha256'],
        },
        'anchor': {
            'path': str(ctx.anchor.relative_to(ctx.root)),
            'manifest_sha256': anchor['manifest_sha256'],
            'inventory_sha256': anchor['inventory_sha256'],
        },
        'limits': [
            '--check writes no files.',
            'No Nary Lean, production mutants, inherited CLI controls, or financial/Lean suites ran.',
            'This checker does not set the planning gate accepted.',
        ],
    }
    return result


def emit_check(ctx: Ctx) -> int:
    try:
        result = check_sealed(ctx)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0
    except Blocked as exc:
        print(json.dumps({'status': 'BLOCKED', 'gate_accepted': False, 'reason': str(exc)},
                         indent=2, ensure_ascii=False))
        print(f'BLOCKED: {exc}', file=sys.stderr)
        return 3
    except Failed as exc:
        print(json.dumps({'status': 'FAIL', 'gate_accepted': False, 'reason': str(exc)},
                         indent=2, ensure_ascii=False))
        print(f'FAIL: {exc}', file=sys.stderr)
        return 1
    except FileNotFoundError as exc:
        print(json.dumps({'status': 'BLOCKED', 'gate_accepted': False,
                          'reason': f'missing input: {exc}'}, indent=2, ensure_ascii=False))
        print(f'BLOCKED: missing input: {exc}', file=sys.stderr)
        return 3
    except json.JSONDecodeError as exc:
        print(json.dumps({'status': 'BLOCKED', 'gate_accepted': False,
                          'reason': f'malformed inventory/manifest JSON: {exc}'},
                         indent=2, ensure_ascii=False))
        print(f'BLOCKED: malformed JSON: {exc}', file=sys.stderr)
        return 3


def skip_name(path: Path) -> bool:
    return path.name == '__pycache__' or path.suffix == '.pyc' or path.name == 'MANIFEST.json' \
        or path.name == 'ANCHOR.json'


def seal(ctx: Ctx) -> dict:
    files = []
    for p in sorted(ctx.out.rglob('*')):
        if not p.is_file() or skip_name(p) or any(part == '__pycache__' for part in p.parts):
            continue
        files.append(rec(ctx, p))
    if not files:
        raise Blocked('seal: empty package file list')
    if not unique([r['path'] for r in files]):
        raise Failed('seal: duplicate package paths')
    manifest = {
        'kind': 'grok_gpt6_r1_package_manifest',
        'gate_accepted': False,
        'package_review': 'pending independent GPT-6',
        'head': HEAD_EXPECTED,
        'file_count': len(files),
        'files': files,
        'script_sha256': sha(ctx.script.read_bytes()),
        'note': 'This file does not contain its own hash. Compare its SHA-256 to ANCHOR.json.',
    }
    dump_det(ctx.manifest, manifest)
    inventory_raw = ctx.inventory.read_bytes()
    manifest_raw = ctx.manifest.read_bytes()
    anchor = {
        'kind': 'external_trust_anchor_not_a_self_hash',
        'manifest_path': str(ctx.manifest.relative_to(ctx.root)),
        'manifest_sha256': sha(manifest_raw),
        'manifest_bytes': len(manifest_raw),
        'inventory_path': str(ctx.inventory.relative_to(ctx.root)),
        'inventory_sha256': sha(inventory_raw),
        'inventory_bytes': len(inventory_raw),
        'head': HEAD_EXPECTED,
        'note': 'Independently hash MANIFEST.json and source-inventory.json. Do not trust a hash stored inside MANIFEST.json.',
    }
    dump_det(ctx.anchor, anchor)
    print(json.dumps({
        'file_count': len(files),
        'gate_accepted': False,
        'manifest_sha256': anchor['manifest_sha256'],
        'inventory_sha256': anchor['inventory_sha256'],
        'anchor_path': str(ctx.anchor.relative_to(ctx.root)),
    }, indent=2))
    return anchor


def copy_bound(ctx: Ctx, dest_root: Path) -> None:
    """Copy union of stored source-inventory paths and MANIFEST files, plus
    inventory, manifest and anchor themselves (inventory is not a self-row)."""
    inventory = load(ctx.inventory)
    manifest = load(ctx.manifest)
    paths = [ctx.root / row['path'] for row in inventory['rows']]
    paths.extend(ctx.root / row['path'] for row in manifest['files'])
    paths.extend([ctx.manifest, ctx.anchor, ctx.inventory])
    seen = set()
    for src in paths:
        if not src.is_file():
            raise Blocked(f'copy_bound missing {src}')
        rel = src.relative_to(ctx.root)
        if str(rel) in seen:
            continue
        seen.add(str(rel))
        dst = dest_root / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)


def run_check_copy(ctx: Ctx, dest_root: Path) -> dict:
    pkg = dest_root / PACKAGE_REL
    script = pkg / 'package.py'
    cmd = [sys.executable, str(script), '--check', '--root', str(dest_root), '--package', str(pkg)]
    proc = subprocess.run(cmd, cwd=dest_root, capture_output=True)
    return {
        'command': cmd,
        'exit': proc.returncode,
        'stdout': proc.stdout.decode('utf-8', 'replace'),
        'stderr': proc.stderr.decode('utf-8', 'replace'),
        'stdout_sha256': sha(proc.stdout),
        'stderr_sha256': sha(proc.stderr),
        'stdout_bytes': len(proc.stdout),
        'stderr_bytes': len(proc.stderr),
    }


def rewrite_anchor_inventory(dest_root: Path) -> None:
    pkg = dest_root / PACKAGE_REL
    inv = pkg / 'source-inventory.json'
    anc = pkg / 'ANCHOR.json'
    anchor = load(anc)
    raw = inv.read_bytes()
    anchor['inventory_sha256'] = sha(raw)
    anchor['inventory_bytes'] = len(raw)
    dump_det(anc, anchor)


def record_controls(ctx: Ctx) -> dict:
    ctx.validation.mkdir(parents=True, exist_ok=True)
    outdir = ctx.validation / 'controls'
    cases = []

    def remember(name: str, dest: Path, result: dict, expect: int):
        row = {
            'name': name,
            'expected_exit': expect,
            'matched': result['exit'] == expect,
            **result,
        }
        cases.append(row)
        return row

    with tempfile.TemporaryDirectory(prefix='sprint11-pkg-check-') as tmp:
        tmp = Path(tmp)
        base = tmp / 'base'
        copy_bound(ctx, base)

        def clone(name: str) -> Path:
            dest = tmp / name
            shutil.copytree(base, dest)
            return dest

        sibling = clone('valid')
        remember('valid-unchanged-sibling', sibling, run_check_copy(ctx, sibling), 0)

        missing = clone('missing')
        (missing / PLAN_REL / 'proposed-api.json').unlink()
        remember('missing-source', missing, run_check_copy(ctx, missing), 3)

        changed = clone('changed')
        p = changed / PLAN_REL / 'proposed-api.json'
        p.write_bytes(p.read_bytes() + b'\n')
        remember('changed-bytes', changed, run_check_copy(ctx, changed), 1)

        spec = clone('spec')
        sp = spec / PACKAGE_REL / 'appendices/D-mutation-specs/M01.json'
        sp.write_bytes(sp.read_bytes() + b' ')
        remember('changed-spec', spec, run_check_copy(ctx, spec), 1)

        appendix = clone('appendix')
        ap = appendix / PACKAGE_REL / 'appendices/A-normative-map.json'
        data = load(ap)
        data['note'] = 'mutated appendix for negative control'
        dump_det(ap, data)
        remember('changed-appendix', appendix, run_check_copy(ctx, appendix), 1)

        empty = clone('empty')
        invp = empty / PACKAGE_REL / 'source-inventory.json'
        inv = load(invp)
        inv['rows'] = []
        dump_det(invp, inv)
        rewrite_anchor_inventory(empty)
        remember('empty-inventory', empty, run_check_copy(ctx, empty), 3)

        dup = clone('dup')
        invp = dup / PACKAGE_REL / 'source-inventory.json'
        inv = load(invp)
        inv['rows'] = list(inv['rows']) + [inv['rows'][0]]
        dump_det(invp, inv)
        rewrite_anchor_inventory(dup)
        remember('duplicate-inventory', dup, run_check_copy(ctx, dup), 1)

        omitted = clone('omitted')
        invp = omitted / PACKAGE_REL / 'source-inventory.json'
        inv = load(invp)
        inv['rows'] = [r for r in inv['rows'] if r['path'] != expected_plan_paths()[0]]
        dump_det(invp, inv)
        rewrite_anchor_inventory(omitted)
        remember('omitted-inventory', omitted, run_check_copy(ctx, omitted), 1)

        cited = clone('missing-cited')
        (cited / 'docs/superpowers/specs/2026-09-06-semantic-kernel-design.md').unlink()
        remember('missing-cited-design', cited, run_check_copy(ctx, cited), 3)

        tamper = clone('tamper-baseline')
        br = declared_authoritative_paths(ctx)['baseline_reference_paths'][0]
        tp = tamper / br
        tp.write_bytes(tp.read_bytes() + b'\n')
        remember('changed-baseline-reference', tamper, run_check_copy(ctx, tamper), 1)

    if outdir.exists():
        shutil.rmtree(outdir)
    outdir.mkdir()
    for row in cases:
        dump_det(outdir / f"{row['name']}.json", row)
        (outdir / f"{row['name']}.stdout.log").write_text(row['stdout'])
        (outdir / f"{row['name']}.stderr.log").write_text(row['stderr'])

    summary = {
        'kind': 'subprocess_check_negative_controls_on_temp_copies',
        'gate_accepted': False,
        'all_matched': all(c['matched'] for c in cases),
        'cases': [{'name': c['name'], 'exit': c['exit'], 'expected_exit': c['expected_exit'],
                   'matched': c['matched'], 'stdout_bytes': c['stdout_bytes'],
                   'stderr_bytes': c['stderr_bytes'], 'stdout_sha256': c['stdout_sha256'],
                   'stderr_sha256': c['stderr_sha256'], 'command': c['command']} for c in cases],
    }
    dump_det(outdir / 'summary.json', summary)
    print(json.dumps({'all_matched': summary['all_matched'],
                      'cases': [(c['name'], c['exit'], c['expected_exit']) for c in cases]},
                     indent=2))
    if not summary['all_matched']:
        raise Failed('one or more subprocess --check controls did not match expected exits')
    return summary


def prove_reproducible(ctx: Ctx) -> dict:
    ctx.validation.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='sprint11-pkg-prep-') as tmp:
        tmp = Path(tmp)
        left, right = tmp / 'a', tmp / 'b'
        for dest in (left, right):
            dest.mkdir()
            # Minimal package inputs needed for prepare: before/, original-plan-review, package.py
            for rel in ['before', 'original-plan-review']:
                shutil.copytree(ctx.out / rel, dest / PACKAGE_REL / rel, dirs_exist_ok=True)
            for name in ['before-manifest.json', 'cancelled-attempt.json', 'package.py']:
                src = ctx.out / name
                if src.is_file():
                    (dest / PACKAGE_REL).mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src, dest / PACKAGE_REL / name)
            # Overlay the rest of bound sources from the real root via copy of needed parents
            # Prepare reads plan/deps from --root, writes to --package.
        # Use the real root as --root so plan/deps are identical; write into two package dirs.
        # Copy before/ and original-plan-review into those package dirs already done, but
        # --package must live under dest for relative ROOT mapping... prepare uses ctx.root
        # for rec() of package files, so --root must be dest and package under dest.
        # Copy bound sources into both dest trees, then prepare.
        copy_bound(ctx, left)
        copy_bound(ctx, right)
        # Remove derived outputs so prepare recreates them.
        for dest in (left, right):
            pkg = dest / PACKAGE_REL
            for rel in DETERMINISTIC_PACKAGE_FILES:
                path = pkg / rel
                if path.is_file():
                    path.unlink()
            invoc = pkg / 'invocation.json'
            if invoc.is_file():
                invoc.unlink()
            cmd = [sys.executable, str(pkg / 'package.py'), '--prepare',
                   '--root', str(dest), '--package', str(pkg)]
            proc = subprocess.run(cmd, cwd=dest, capture_output=True)
            if proc.returncode != 0:
                raise Failed(f'prepare copy failed: {proc.stderr.decode()} {proc.stdout.decode()}')
        # First prepare on left created invocation.json; run prepare again on left to prove freeze.
        pkg_left = left / PACKAGE_REL
        first_invoc = (pkg_left / 'invocation.json').read_bytes()
        time.sleep(0.01)
        proc = subprocess.run([sys.executable, str(pkg_left / 'package.py'), '--prepare',
                               '--root', str(left), '--package', str(pkg_left)],
                              cwd=left, capture_output=True)
        if proc.returncode != 0:
            raise Failed(f'second prepare failed: {proc.stderr.decode()}')
        second_invoc = (pkg_left / 'invocation.json').read_bytes()
        pairs = []
        identical = True
        for rel in DETERMINISTIC_PACKAGE_FILES:
            a = (left / PACKAGE_REL / rel).read_bytes()
            b = (right / PACKAGE_REL / rel).read_bytes()
            same = a == b
            identical = identical and same
            pairs.append({'path': rel, 'identical': same, 'sha256': sha(a), 'bytes': len(a)})
        result = {
            'kind': 'two_prepare_deterministic_identity',
            'identical_declared_deterministic_files': identical,
            'files': pairs,
            'invocation_frozen_on_second_prepare': first_invoc == second_invoc,
            'invocation_sha256': sha(first_invoc),
        }
        dump_det(ctx.validation / 'reproducible.json', result)
        print(json.dumps({
            'identical_declared_deterministic_files': identical,
            'invocation_frozen_on_second_prepare': first_invoc == second_invoc,
            'file_count': len(pairs),
        }, indent=2))
        if not identical or first_invoc != second_invoc:
            raise Failed('prepare was not deterministic or rewrote invocation.json')
        return result


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path)
    parser.add_argument('--package', type=Path)
    parser.add_argument('--prepare', action='store_true')
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--validate', action='store_true',
                        help='Alias of --check (read-only). Does not write.')
    parser.add_argument('--seal', action='store_true')
    parser.add_argument('--record-controls', action='store_true')
    parser.add_argument('--prove-reproducible', action='store_true')
    return parser.parse_args()


def main():
    args = parse_args()
    base = default_ctx()
    root = args.root.resolve() if args.root else base.root
    package = args.package.resolve() if args.package else base.out
    ctx = Ctx(root, package)
    try:
        if args.check or args.validate:
            sys.exit(emit_check(ctx))
        if args.prepare:
            prepare(ctx)
            print(json.dumps({'prepared': True, 'inventory': str(ctx.inventory.relative_to(ctx.root))},
                             indent=2))
            return
        if args.prove_reproducible:
            prove_reproducible(ctx)
            return
        if args.record_controls:
            record_controls(ctx)
            return
        if args.seal:
            seal(ctx)
            return
        print('Specify --prepare, --seal, --check, --record-controls or --prove-reproducible',
              file=sys.stderr)
        sys.exit(3)
    except Blocked as exc:
        print(f'BLOCKED: {exc}', file=sys.stderr)
        sys.exit(3)
    except Failed as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
