"""Reviewed Lean source roles and executed dependency evidence for workflow-2b60322-3.

This inventory counts physical source once, by its primary role. It does not infer
proof success from dependency output. Failed automatic proof attempts remain automatic;
AI-authored helpers and theorem selection remain assisted. Runtime records retain raw
machine paths, while the portable inventory embeds normalized actual tool output.
"""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

import setup

BASE = Path(__file__).resolve().parent
CATEGORIES = ('model_loc', 'specification_loc', 'guidance_loc', 'shared_helper_loc', 'generated_loc')
SHARED = {
    'LocalContracts': 'local-contracts',
    'ComposeAssisted': 'workflow-composition',
    'WorkflowSequenceProofs': 'first-refusal-sequence',
    'WorkflowControlProofs': 'raw-call-semantics',
}
MODELS = {'WorkflowModel', 'WorkflowControl', 'ComposeModel', 'NetModel', 'ReuseModel'}
# Reviewed declaration-role exceptions. Executed guards have model as their primary role;
# independent domain predicates, mathematical observations and claims are specifications.
SPEC_DECLARATIONS = {
    'WorkflowModel': {'surplus', 'ValidState', 'requiredCapabilities', 'SuccessDomain', 'LocalClaims'},
    'WorkflowControl': {'decodeRaw', 'expectedRefusal', 'RawStepSpec', 'RawExecutionSpec',
                        'R4Canonical', 'R6Canonical', 'adminUpdate', 'R5Canonical'},
    'ComposeModel': {'algebraStep', 'algebraBalances', 'algebraCapabilities', 'AlgebraDomain',
                     'sumIssued', 'sumBurned', 'depositTotal', 'withdrawTotal', 'WorkflowMember',
                     'workflowFootprint', 'LocalTrace', 'CompositionClaims', 'WorkflowClaims',
                     'CallsExecutionSpec', 'ComposeCanonical'},
    'NetModel': {'RecordValid', 'RawMatches', 'GrossAuthority', 'PrefixFunds', 'prefixBalances',
                 'PrefixDomain', 'NetClaims', 'SettlementCanonical', 'SequenceClaims',
                 'SequentialCanonical', 'ValidationCanonical', 'RawSuccessDomain',
                 'RawTotalCanonical', 'AggregateCanonical', 'Canonical'},
    'ReuseModel': {'Canonical'},
}
EXISTING_DECLARATIONS = [
    'DefiKernel.State', 'DefiKernel.Policy', 'DefiKernel.Transition',
    'DefiKernel.Examples.move', 'DefiKernel.Examples.pulse', 'DefiKernel.execute',
    'DefiKernel.execute_ok_iff', 'DefiKernel.applyEffect', 'DefiKernel.total',
    'DefiKernel.execute_accounting', 'DefiKernel.execute_locality',
    'DefiKernel.DebitAuthorized', 'DefiKernel.NonnegativeUpdate',
    'DefiKernel.Accounted', 'DefiKernel.Local', 'DefiKernel.Valid',
]
COUNTING_METHOD = (
    'Executed Lean --deps on every active root Lean source with imported local objects '
    'selected only when their adjacent source hash matches the frozen source. A Lean-aware '
    'nested-comment/string scanner identifies non-comment nonblank physical lines; reviewed '
    'top-level declaration boundaries assign one primary role per line. Operational '
    'guards are model; independent algebraic domains and canonical claims are specification. '
    'Unchanged automatic aesop wrappers are specification. Newly authored proof modules '
    'used by multiple cases are shared helpers, counted once with complete assisted/build '
    'use lists. Single-case proof construction and target theorem applications are guidance. '
    'Imported upstream libraries, infrastructure, witnesses, negative controls, selection '
    'evidence and identical frozen snapshots are inventoried separately, not added to new '
    'proof/model LOC. Source counts use whole compiled module closures, not an inferred '
    'minimal theorem-term dependency slice. AI-authored text is authored guidance, not '
    'compiler-generated source; generated_loc is observed zero.'
)
DECL = re.compile(r'^(?P<kind>def|theorem|lemma|abbrev|structure|inductive|instance)\b(?:\s+(?P<name>[A-Za-z_][A-Za-z0-9_.\']*))?')
TOP = re.compile(r'^(?:import|namespace|end|open|set_option|#print|#check|#eval)\b')


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def lean_code_lines(text):
    """Strip nested /- -/ and -- comments while preserving line numbers and strings."""
    result, out, depth, quoted, escape, i = [], [], 0, False, False, 0
    while i < len(text):
        ch, nxt = text[i], text[i:i + 2]
        if ch == '\n':
            result.append(''.join(out)); out = []; i += 1
            continue
        if depth:
            if nxt == '/-': depth += 1; i += 2
            elif nxt == '-/': depth -= 1; i += 2
            else: i += 1
            continue
        if quoted:
            out.append(ch)
            if escape: escape = False
            elif ch == '\\': escape = True
            elif ch == '"': quoted = False
            i += 1
            continue
        if nxt == '--':
            while i < len(text) and text[i] != '\n': i += 1
            continue
        if nxt == '/-':
            depth = 1; out.append(' '); i += 2
            continue
        out.append(ch)
        if ch == '"': quoted = True
        i += 1
    if out or not text.endswith('\n'): result.append(''.join(out))
    if depth or quoted: raise ValueError('Unclosed Lean comment or string')
    return result


def imports(path):
    modules = []
    for line in lean_code_lines(path.read_text()):
        if line.startswith('import '): modules.extend(line.split()[1:])
    return modules


def declaration_inventory(module, text, default):
    clean = lean_code_lines(text)
    starts = []
    for index, line in enumerate(clean, 1):
        match = DECL.match(line)
        if match or TOP.match(line): starts.append((index, line, match))
    namespace = ''
    entries, categories, active_category = [], {}, default
    for number, (start, header, match) in enumerate(starts):
        finish = starts[number + 1][0] - 1 if number + 1 < len(starts) else len(clean)
        lines = [i for i in range(start, finish + 1) if clean[i - 1].strip()]
        if not lines: continue
        if header.startswith('namespace '): namespace = header.split()[1]
        category = default
        if module in MODELS:
            if match:
                name = match.group('name')
                if match.group('kind') == 'instance':
                    # These anonymous instances immediately follow their reviewed domain
                    # declaration and implement decidability for that same role.
                    category = active_category
                else:
                    category = 'specification_loc' if name in SPEC_DECLARATIONS[module] else 'model_loc'
            elif header.startswith('end '): category = active_category
            elif module == 'ReuseModel': category = 'specification_loc'
        if match:
            name = match.group('name') or f'<anonymous-instance-at-{start}>'
            qualified = f'{namespace}.{name}' if namespace else name
            entries.append({'name': qualified, 'kind': match.group('kind'), 'line': start,
                            'end_line': finish, 'category': category,
                            'review': 'Reviewed declaration and use: ' + role_reason(module, name, category)})
        active_category = category
        for line in lines:
            if line in categories: raise ValueError('Line assigned twice')
            categories[line] = category
    expected = {i for i, line in enumerate(clean, 1) if line.strip()}
    if set(categories) != expected:
        raise ValueError(f'Unclassified Lean code lines in {module}: {sorted(expected-set(categories))}')
    return entries, categories


def role_reason(module, name, category):
    if category == 'model_loc':
        return 'Operational representation, constructor, decoder, runtime guard or executor; any proof fields/decidability terms belong to that primary operational role.'
    if category == 'specification_loc':
        return 'Independent input domain, algebraic expectation, observation, formal claim or unchanged frozen automatic target wrapper.'
    if category == 'shared_helper_loc':
        return 'New AI-authored proof statement and implementation reused by the listed assisted cases; no automatic-stage import.'
    return 'New case-specific AI proof construction or explicit selection/application of a checked theorem; assisted guidance.'


def closure(module, graph, seen=None):
    found = set() if seen is None else seen
    for dependency in graph.get(module, []):
        if dependency in graph and dependency not in found:
            found.add(dependency); closure(dependency, graph, found)
    return found


def case_attribution(plan):
    users = defaultdict(lambda: {'cases': set(), 'stages': set()})
    for case, item in plan['cases'].items():
        for stage in ('automatic', 'assisted'):
            for module in item[stage]:
                users[module]['cases'].add(case); users[module]['stages'].add(stage)
    for module in plan['build_modules']: users[module]['stages'].add('build')
    sources, helpers, declarations = [], [], []
    for module, usage in sorted(users.items()):
        if module in SHARED: default = 'shared_helper_loc'
        elif module.endswith('Automatic') or module == 'ReuseModel': default = 'specification_loc'
        elif module in MODELS: default = 'model_loc'
        else: default = 'guidance_loc'
        path = BASE / (module + '.lean')
        records, line_roles = declaration_inventory(module, path.read_text(), default)
        for item in records:
            item.update(path=path.name, cases=sorted(usage['cases']), stages=sorted(usage['stages']))
        declarations.extend(records)
        for category in CATEGORIES:
            lines = sorted(i for i, role in line_roles.items() if role == category)
            if not lines: continue
            item = dict(path=path.name, category=category, lines=lines,
                        cases=sorted(usage['cases']), stages=sorted(usage['stages']))
            if category == 'shared_helper_loc': item['helper_id'] = SHARED[module]
            sources.append(item)
        if module in SHARED:
            helpers.append({'id': SHARED[module], 'cases': sorted(usage['cases']),
                            'stages': ['assisted', 'build'], 'module': module,
                            'origin': 'newly_authored_ai_proof_helper',
                            'declarations': [x['name'] for x in records]})
    return sources, helpers, declarations


def normalize(text, work, objects):
    replacements = [(str(objects), '<checked-local-modules>'), (str(BASE), '<adapter>'),
                    (str(setup.runtime() / 'lean-4.33.0-rc2-darwin_aarch64'), '<lean-toolchain>'),
                    (str(setup.runtime() / 'upstream/lean/.lake/build/lib/lean'), '<native-module-cache>'),
                    (str(setup.runtime() / 'upstream/lean/.lake/packages'), '<package-cache>'),
                    (str(work), '<attribution-runtime>')]
    for old, new in sorted(replacements, key=lambda x: -len(x[0])): text = text.replace(old, new)
    if '/Users/' in text or '/private/' in text: raise ValueError('Unnormalized machine path in dependency evidence')
    return text


def dependency_evidence(work, modules, graph, reuse):
    evidence_path = work / 'lean-deps-portable.json'
    current = {module: digest(BASE / (module + '.lean')) for module in modules}
    if reuse and evidence_path.exists():
        record = json.loads(evidence_path.read_text())
        if record['source_hashes'] != current: raise ValueError('Cannot reuse dependency evidence after source change')
        return record
    objects = work / 'matched-local-modules'; objects.mkdir(parents=True, exist_ok=True)
    needed = sorted({item for deps in graph.values() for item in deps if item in graph})
    candidates = defaultdict(list)
    preparation = setup.root() / 'results/performance-rational/defiformal-workflows-20261106'
    # Python rglob follows no directory symlinks here; only read actual preparation outputs.
    for path in preparation.rglob('*.olean'):
        if objects in path.parents: continue
        if path.stem in needed and path.with_suffix('.lean').is_file():
            if digest(path.with_suffix('.lean')) == current[path.stem]: candidates[path.stem].append(path)
    provenance = []
    for module in needed:
        options = sorted(candidates[module])
        if not options: raise RuntimeError('No compiled local module with matching source: ' + module)
        source = options[0]; target = objects / (module + '.olean'); shutil.copyfile(source, target)
        provenance.append({'module': module, 'source_sha256': current[module],
                           'olean_sha256': digest(target), 'selection': 'Existing actual compiled object; adjacent source byte-identical to current source.'})
    env = setup.environment(objects)
    raw, portable = [], []
    for module in modules:
        source = BASE / (module + '.lean')
        command = [str(setup.lean()), '--deps', str(source)]
        began = time.monotonic()
        run = subprocess.run(command, cwd=BASE, env=env, capture_output=True, text=True, timeout=120)
        item = {'module': module, 'command': command, 'returncode': run.returncode,
                'stdout': run.stdout, 'stderr': run.stderr, 'elapsed_seconds': time.monotonic()-began,
                'source_sha256': current[module]}
        raw.append(item)
        portable.append(dict(item, command=['lean', '--deps', source.name],
                             stdout=normalize(run.stdout, work, objects), stderr=normalize(run.stderr, work, objects)))
        if run.returncode:
            (work / 'lean-deps-raw.json').write_text(json.dumps(raw, indent=2)+'\n')
            raise RuntimeError('Lean --deps failed for ' + module)
        actual_local = sorted(set(re.findall(r'<checked-local-modules>/([A-Za-z_][A-Za-z0-9_]*)\.olean', portable[-1]['stdout'])))
        expected_local = sorted(item for item in graph[module] if item in graph)
        if actual_local != expected_local:
            raise ValueError(f'Lean/parser import mismatch for {module}: {actual_local} != {expected_local}')
    (work / 'lean-deps-raw.json').write_text(json.dumps(raw, indent=2)+'\n')
    record = {'status': 'completed', 'tool': 'Lean --deps', 'executed_at': datetime.now(timezone.utc).isoformat(),
              'source_hashes': current, 'matched_local_objects': provenance, 'runs': portable,
              'meaning': 'Actual Lean import resolution, not proof checking or theorem success. Absolute paths are normalized to documented portable placeholders; raw outputs are retained in preparation runtime.'}
    evidence_path.write_text(json.dumps(record, indent=2)+'\n')
    return record


def role_for(path, measured):
    name = path.relative_to(BASE).as_posix()
    if name.startswith('upstream/'): return 'existing_upstream_source'
    if name.startswith(('reuse/foundation-source/', 'reuse/extension-source/')): return 'frozen_source_snapshot_duplicate'
    if name.startswith('reuse/'): return 'reuse_evidence'
    if name.startswith('mutants/'): return 'acceptance_negative_control'
    if name.startswith('selection/'): return 'frozen_automatic_selection_evidence'
    if path.stem in measured and path.suffix == '.lean': return 'measured_lean_source'
    if path.suffix == '.lean': return 'acceptance_witness_or_fixture'
    if name.startswith(('acceptance', 'test_')) or name == 'mutations.json': return 'acceptance_infrastructure'
    if name == 'attribution.py': return 'source_attribution_infrastructure'
    return 'adapter_configuration_infrastructure_or_evidence'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--runtime-dir', type=Path,
                        default=setup.root() / 'results/performance-rational/defiformal-workflows-20261106/foundation/attribution')
    parser.add_argument('--reuse-deps', action='store_true', help='Rehash files without rerunning unchanged source dependency evidence.')
    args = parser.parse_args(); work = args.runtime_dir.resolve(); work.mkdir(parents=True, exist_ok=True)
    assert [i+1 for i,x in enumerate(lean_code_lines('-- only\n/- outer /- inner -/ -/\ndef x := "--not-comment" -- inline\n')) if x.strip()] == [3]
    plan = json.loads((BASE/'case-plan.json').read_text())
    sources, helpers, declarations = case_attribution(plan)
    modules = sorted(p.stem for p in BASE.glob('*.lean'))
    graph = {module: imports(BASE/(module+'.lean')) for module in modules}
    for case, item in plan['cases'].items():
        for stage in ('automatic','assisted'):
            expected = closure(item[stage][-1], graph) | {item[stage][-1]}
            if expected != set(item[stage]): raise ValueError(f'Case plan is not exact import closure: {case}/{stage}: {sorted(expected ^ set(item[stage]))}')
            if stage == 'automatic' and expected & SHARED.keys(): raise ValueError('Automatic stage imports new proof guidance')
    evidence = dependency_evidence(work, modules, graph, args.reuse_deps)
    cases = {}
    for case, item in plan['cases'].items():
        assisted = set(item['assisted'])
        cases[case] = {'automatic_modules': item['automatic'], 'assisted_modules': item['assisted'],
                       'shared_helpers': sorted(SHARED[x] for x in assisted & SHARED.keys()),
                       'case_specific_guidance_modules': sorted(x for x in assisted if x not in MODELS and x not in SHARED),
                       'foundation_target_dependency': 'R3N4Assisted' if case == 'R8-REUSE' else None}
    for helper in helpers:
        module = helper['module']; imported = closure(module, graph)
        helper['local_import_closure'] = sorted(imported)
        helper['shared_helper_dependencies'] = sorted(SHARED[x] for x in imported & SHARED.keys())
    measured = {Path(x['path']).stem for x in sources}; files = []
    for path in sorted(BASE.rglob('*')):
        if not path.is_file() or '__pycache__' in path.parts or path.suffix in {'.pyc','.olean','.ir'}: continue
        relative = path.relative_to(BASE).as_posix()
        if relative in {'manifest.json','source-inventory.json'} or 'effort' in path.name.lower(): continue
        entry = {'path': relative, 'sha256': digest(path), 'bytes': path.stat().st_size,
                 'role': role_for(path, measured)}
        if entry['role'] == 'frozen_source_snapshot_duplicate':
            entry['duplicate_of'] = path.name
            if digest(BASE/path.name) != entry['sha256']: raise ValueError('Frozen snapshot differs from its source: '+relative)
        files.append(entry)
    totals = {c: sum(len(x['lines']) for x in sources if x['category']==c) for c in CATEGORIES}
    record = {'schema_version':1, 'review_method': COUNTING_METHOD,
              'manual_review': {'actor':'workflow_foundation','status':'reviewed',
                               'scope':'All source-bearing root Lean declarations; operational versus formal-specification boundaries; actual module import case/stage closures; duplicate snapshots and acceptance exclusions.',
                               'mixed_role_policy':'One primary role per physical line; runtime guards and decidability code counted as model, even when also mentioned by specifications. Proof helper statements and their proofs counted together as assistance.'},
              'language_tool_evidence':evidence, 'files':files, 'attribution':sources, 'helpers':helpers,
              'declarations':declarations, 'case_dependency_closures':cases, 'local_import_graph':graph,
              'existing_library_declarations':EXISTING_DECLARATIONS,
              'native_boundary':'Core financial effects/check/apply/accounting/locality and Examples.move/pulse are reused. The typed Composition/Atomic/Authority frameworks are not imported or measured. Canonical control/composition/net wrappers and proof guidance are newly authored.',
              'totals':totals,
              'exclusions':{'manifest.json':'Intentionally excluded to avoid circular hashes: manifest consumes attribution output and is frozen separately by admission.',
                            'source-inventory.json':'Self-hash excluded; admission/archive fingerprints this file externally.',
                            'mutable_effort_records':'Files whose names include effort are excluded during integration. Final manifest effort_refs and the independent admission/archive input fingerprints bind their final bytes; no source LOC is omitted.',
                            'infrastructure_acceptance_snapshots':'Inventoried and hashed, never counted as duplicate new model/proof LOC.',
                            'upstream':'Existing pinned dependency work, not new-source LOC.',
                            'generated_loc':'Observed zero generated target source; AI-authored proofs counted as guidance/helpers.'}}
    (BASE/'source-inventory.json').write_text(json.dumps(record,indent=2)+'\n')
    fragment={'sources':sources,'helpers':helpers,'source_counting_method':COUNTING_METHOD,
              'source_inventory':{'path':'source-inventory.json','sha256':digest(BASE/'source-inventory.json')},
              'totals':totals,'case_dependency_closures':cases}
    (work.parent/'manifest-attribution.json').write_text(json.dumps(fragment,indent=2)+'\n')
    print(json.dumps({'status':'completed','lean_dependency_runs':len(evidence['runs']),
                      'source_entries':len(sources),'helpers':len(helpers),'declarations':len(declarations),
                      'totals':totals,'inventory_sha256':digest(BASE/'source-inventory.json')}))


if __name__ == '__main__': main()
