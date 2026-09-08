"""Read-only, bounded plan checks; structural success is not semantic acceptance."""
from pathlib import Path
import collections
import datetime
import hashlib
import json
import re
import subprocess
import tarfile

OUT = Path(__file__).resolve().parent
ROOT = Path('/home/charl/defiformal')
WT = Path('/home/charl/defiformal-wt-program-repair-grok-gpt6-20260908')
REL = Path('openspec/changes/reusable-verification-platform-program')
CANDIDATE = WT / REL
BASE = ROOT / 'review/semantic-kernel/full-program-spec-review-20260908/frozen-program'
RUN = OUT.parent
sha = lambda b: hashlib.sha256(b).hexdigest()
load = lambda p: json.loads(p.read_text())
checks = []
def check(name, condition, details=None):
    checks.append({'name': name, 'pass': bool(condition), 'details': details})
def command(argv, cwd=WT):
    p = subprocess.run(argv, cwd=cwd, capture_output=True, text=True)
    return {'argv': argv, 'cwd': str(cwd), 'exit': p.returncode,
            'stdout': p.stdout, 'stderr': p.stderr}
manifest = load(RUN / 'repair-candidate-manifest.json')
files = {str(p.relative_to(CANDIDATE)): sha(p.read_bytes())
         for p in CANDIDATE.rglob('*') if p.is_file()}
check('all_15_candidate_hashes_match_frozen_manifest', files == manifest['files'] and len(files) == 15)
archive = RUN / 'repair-candidate-r1.tar.gz'
archive_hash = sha(archive.read_bytes())
check('archive_hash', archive_hash == 'f4162b193aa0ad2b0884c93652cc6bb4507f443ee96318d96c687199f13f35a2')
with tarfile.open(archive) as tar:
    archived = {}
    for m in tar.getmembers():
        if not m.isfile(): continue
        for rel in files:
            if m.name == rel or m.name.endswith('/' + rel):
                archived[rel] = sha(tar.extractfile(m).read())
check('archive_members_match_candidate', archived == files, len(archived))
index = load(CANDIDATE / 'sprint-index.json')
sprints = {s['id']: s for s in index['sprints']}
check('37_unique_sprint_ids', len(index['sprints']) == len(sprints) == 37)
edges = [(d, s['id']) for s in sprints.values() for d in s['dependencies']]
order = index['recommended_order']
check('hard_edges_exist_and_are_topological', all(a in order and b in order and order.index(a) < order.index(b) for a, b in edges), edges)
task_pattern = r'^- \[([ x])\] (\d+\.\d+[a-z]?) (.*)$'
task_rows = re.findall(task_pattern, (CANDIDATE / 'tasks.md').read_text(), re.M)
tasks = {i: body for mark, i, body in task_rows}
check('179_unique_unchecked_program_tasks', len(task_rows) == len(tasks) == 179 and all(m == ' ' for m, _, _ in task_rows))
base_task_count = len(re.findall(task_pattern, (BASE / 'tasks.md').read_text(), re.M))
counts = {}
coverage = (CANDIDATE / 'coverage.md').read_text()
for p in CANDIDATE.glob('specs/*/spec.md'):
    body = p.read_text()
    counts[p.parent.name] = [len(re.findall(r'^### Requirement:', body, re.M)), len(re.findall(r'^#### Scenario:', body, re.M))]
check('coverage_table_matches_all_six_capabilities', len(counts) == 6 and all(re.search(r'\| ' + re.escape(k) + r' \| ' + str(v[0]) + r' \| ' + str(v[1]) + r' \|', coverage) for k, v in counts.items()), counts)
check('55_requirements_100_scenarios', [sum(v[i] for v in counts.values()) for i in (0, 1)] == [55, 100])
legacy = load(CANDIDATE / 'legacy-task-disposition.json')['tasks']
old = load(BASE / 'legacy-task-disposition.json')['tasks']
project = lambda rows: {(r['package'], r['task_id']): (r['historically_checked'], r['path']) for r in rows}
check('339_original_identity_mark_path_tuples_preserved', len(legacy) == len(project(legacy)) == 339 and project(legacy) == project(old))
packages = collections.defaultdict(list)
source_hashes = {}
for row in legacy: packages[row['path']].append(row)
for path, rows in packages.items():
    p = ROOT / path
    content = p.read_text()
    source_hashes[str(p)] = sha(p.read_bytes())
    source = {i: m == 'x' for m, i, _ in re.findall(task_pattern, content, re.M)}
    mapped = {r['task_id']: r['historically_checked'] for r in rows}
    check('original_task_source:' + rows[0]['package'], source == mapped, len(source))
splits = [r for r in legacy if r['disposition'] == 'split']
check('34_split_rows_have_nonempty_owned_contributions', len(splits) == 34 and all(r.get('whole_task_closure') == 'all_contributions' and len(r.get('contributions', [])) >= 2 and {c['sprint'] for c in r['contributions']} == set(r['owner_sprint'].split('+')) and all(c['sprint'] in sprints and c['scope'].strip() for c in r['contributions']) for r in splits))
gate = index['resource_gates']['two_case_reuse']
required = {'one_common_harness_engine_executing_both_cases', 'named_shared_financial_lemma_or_contract', 'named_shared_executor_result', 'token0_library_to_kernel_bridge', 'both_case_adapters_on_that_executor_result', 'measured_case_two_definitions_assumptions_interfaces_effort'}
check('resource_id_resolves_to_stronger_platform_predicate', gate['id'] == 'P17' and gate['predicate'] == sprints['P17']['platform_reuse_predicate'] == sprints['P17']['platform_reuse']['predicate'] == 'P17.platform_reuse' and required == set(sprints['P17']['platform_reuse']['requires']) and all(sprints[f'P{i:02}']['resource_gate'] == 'P17' for i in range(21, 30)))
check('arithmetic_only_does_not_open_gate_and_P30_not_required', sprints['P17']['arithmetic_reuse']['opens_resource_gate'] is False and gate['p30_dependency'] is False and sprints['P17']['platform_reuse']['p30_dependency'] is False)
check('conditional_composition_preserved', gate['composition_instance'] == sprints['P17']['platform_reuse']['composition_instance'] == 'required_if_composition_integration_claimed')
check('P09_manifest_reference_resolves', sprints['P10']['conditional_dependencies']['collect_task_2.4'] == ['P09.6.1'] and sprints['P09']['legacy_mapping']['sub_delivery']['original_task'] == '6.1' and '6.1' in sprints['P09']['legacy_mapping']['tasks'])
check('corpus_no_hard_cycle_or_P16_barrier', sprints['P09']['dependencies'] == sprints['P10']['dependencies'] == ['P08'] and sprints['P16']['dependencies'] == ['P15'])
join_ids = ['7.1', '7.2', '7.3', '7.4', '8.1', '8.2', '8.3']
check('all_seven_corpus_join_ids_require_both_contributions', all(r['disposition'] == 'split' and r['owner_sprint'] == 'P09+P10' for r in legacy if r['package'] == 'corpus-provenance-adjudication' and r['task_id'] in join_ids) and sprints['P09']['legacy_mapping']['not_owned_as_successful_exit'] == sprints['P10']['legacy_mapping']['whole_package_join'] == join_ids)
matrix = load(CANDIDATE / 'proof-obligation-dependency-matrix.json')
check('all_eight_adapter_references_exist_and_name_correct_adapter', all(v['readiness_task'] in tasks and v['implementation_task'] in tasks and (k if k != 'proof-carrying-transaction' else k) in tasks[v['implementation_task']] for k, v in matrix['adapter_obligations'].items()))
check('P20_contributes_R18', 'R18' in sprints['P20']['roadmap_ids'] and re.search(r'^\| R18 .*P19, P20', coverage, re.M))
check('P12_mixed_class', sprints['P12']['evidence_class'] == 'mixed_behavior')
check('no_revision_self_acceptance', index['schema']['revision']['sets_review_gate_accepted'] is False)
root_evidence = ROOT / 'review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts'
locators = {}
for f, a, b in [('libraries/SwapMath.sol', 87, 89), ('UniswapV3Pool.sol', 608, 613)]:
    p = root_evidence / f
    source_hashes[str(p)] = sha(p.read_bytes())
    locators[f] = {'lines': [a,b], 'text': '\n'.join(p.read_text().splitlines()[a-1:b])}
check('cap_and_SPL_source_locators', '!exactIn && amountOut > uint256(-amountRemaining)' in locators['libraries/SwapMath.sol']['text'] and "'SPL'" in locators['UniswapV3Pool.sol']['text'], locators)
before_status = command(['git', 'status', '--porcelain', '-uall'])
strict = command(['openspec', 'validate', 'reusable-verification-platform-program', '--strict'])
after_status = command(['git', 'status', '--porcelain', '-uall'])
check('OpenSpec_strict', strict['exit'] == 0, strict)
check('strict_does_not_mutate_worktree', before_status['stdout'] == after_status['stdout'])
after_files = {str(p.relative_to(CANDIDATE)): sha(p.read_bytes()) for p in CANDIDATE.rglob('*') if p.is_file()}
check('candidate_still_frozen_after_checks', after_files == files)
report = {'scope': 'Bounded structural/reference checks only; manual semantic findings are separate.', 'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'python': command(['python3', '--version']), 'openspec': command(['openspec', '--version']), 'candidate_head': command(['git', 'rev-parse', 'HEAD']), 'candidate_manifest_sha256': sha((RUN / 'repair-candidate-manifest.json').read_bytes()), 'archive_sha256': archive_hash, 'candidate_files': files, 'source_hashes': source_hashes, 'base_task_count': base_task_count, 'checks': checks, 'passes': sum(c['pass'] for c in checks), 'failures': sum(not c['pass'] for c in checks)}
(OUT / 'checks.json').write_text(json.dumps(report, indent=2) + '\n')
(OUT / 'openspec-strict.log').write_text(json.dumps(strict, indent=2) + '\n')
print(json.dumps({'passes': report['passes'], 'failures': report['failures'], 'base_task_count': base_task_count, 'failed': [c for c in checks if not c['pass']]}, indent=2))
raise SystemExit(1 if report['failures'] else 0)
