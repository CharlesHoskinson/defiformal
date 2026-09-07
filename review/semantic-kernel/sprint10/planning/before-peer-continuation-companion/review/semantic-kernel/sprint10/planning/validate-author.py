#!/usr/bin/env python3
"""Bounded provisional author validation. Does not run Lean, mutations or native reviews."""
import hashlib, json, re, runpy, shutil, subprocess, sys
from pathlib import Path
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[4]; OUT=Path(__file__).resolve().parent
CHANGE=ROOT/'openspec/changes/operational-interface-binding-preservation'
now=lambda:datetime.now(timezone.utc).isoformat()
sha=lambda b:hashlib.sha256(b).hexdigest()
record=lambda p:dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=sha(p.read_bytes()))
started=now();head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
planfiles=[*sorted(CHANGE.rglob('*')),ROOT/'wiki-llm/sprint-10-operational-interface-bindings-outline.md',OUT/'build-author-evidence.py',Path(__file__)]
planfiles=[p for p in planfiles if p.is_file()]
before={str(p.relative_to(ROOT)):record(p) for p in planfiles}
commands=[]
def command(argv,name):
    begin=now();r=subprocess.run(argv,cwd=ROOT,text=True,capture_output=True)
    for kind,value in [('stdout',r.stdout),('stderr',r.stderr)]: (OUT/f'{name}.{kind}').write_text(value)
    commands.append(dict(argv=argv,cwd=str(ROOT),started_utc=begin,finished_utc=now(),exit=r.returncode,stdout=record(OUT/f'{name}.stdout'),stderr=record(OUT/f'{name}.stderr')))
    assert r.returncode==0,(name,r.stderr)
    return r.stdout
command([sys.executable,str(OUT/'build-author-evidence.py')],'coverage')
exe=Path(shutil.which('openspec')).resolve()
version=command([str(exe),'--version'],'openspec-version').strip()
command([str(exe),'validate','operational-interface-binding-preservation','--strict'],'strict-validation')
status=json.loads(command([str(exe),'status','--change','operational-interface-binding-preservation','--json'],'status'))
runner=ROOT/'scripts/test_atomic_mutation_runner.py'
ns=runpy.run_path(str(runner),run_name='provisional_m2_control_inspection')
cases=ns['cases'](); names=[c['name'] for c in cases]
assert len(names)==len(set(names)) and len(names)==65
controls=dict(status='catalog_inspected_only_not_executed',source=record(runner),refresh='replace predecessor identity with accepted M1 and retain all current65 plus every accepted added control before official freeze',cases=[dict(old_name=c['name'],planned_new_name=c['name'].replace('atomic','interface'),expected_exit=c['exit'],message=c.get('message'),production_form=bool(c.get('production_audit'))) for c in cases])
(OUT/'inherited-controls.json').write_text(json.dumps(controls,indent=2)+'\n')
source_paths=['lean/DefiKernel/Typed/Types.lean','lean/DefiKernel/Typed/Authority.lean','lean/DefiKernel/Typed/Transition.lean','lean/DefiKernel/Composition/Interfaces.lean','lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Composition/Contracts.lean','lean/DefiKernel/Composition/Preservation.lean','lean/DefiKernel/Atomic/Policy.lean','lean/DefiKernel/Atomic/Settlement.lean','lean/DefiKernel/Interleaving/Soundness.lean','lean/DefiKernel/Interleaving/Interference.lean','lean/Defialgebra/Interface.lean','lean/Defialgebra/Nary.lean','lean/lean-toolchain','lean/lakefile.toml','scripts/test_atomic_mutation_runner.py']
source=[];base='a52fb748272fdc08f07d4ad8d2e2a06805b92dd6'
for rel in source_paths:
    p=ROOT/rel
    if not p.exists() and rel=='lean/lakefile.toml': rel='lean/lakefile.lean';p=ROOT/rel
    revision=head if rel.startswith('scripts/') else base
    data=p.read_bytes();git=subprocess.check_output(['git','show',f'{revision}:{rel}'],cwd=ROOT)
    assert data==git,rel
    source.append({**record(p),'git_revision':revision,'git_blob':subprocess.check_output(['git','rev-parse',f'{revision}:{rel}'],cwd=ROOT,text=True).strip(),'matches_git_bytes':True})
(OUT/'source-context.json').write_text(json.dumps(dict(status='provisional_pre_M1_source_inspection',observed_head=head,inspected_revision=base,bindings=source,required_refresh='accepted delivered Sprint9 actual group-simulation/API/control closure'),indent=2)+'\n')
design=(CHANGE/'design.md').read_text()
mutants=[]
for line in design.splitlines():
    if re.match(r'^\| M\d\d \|',line):
        _,mid,site,oracle,positive,_=[s.strip() for s in line.split('|')]
        mutants.append(dict(id=mid,planned_site=site,designated_comparison=oracle,protected_sibling=positive,status='planned_not_executed'))
assert [m['id'] for m in mutants]==[f'M{i:02}' for i in range(1,15)]
(OUT/'planned-mutations.json').write_text(json.dumps(dict(status='design_only_no_detection_claim',mutants=mutants),indent=2)+'\n')
coverage=json.loads((OUT/'author-coverage.json').read_text())
assert coverage['counts']['checked_tasks']==0
assert not (ROOT/'lean/DefiKernel/Interface').exists()
assert not (ROOT/'lean/DefiKernel/Verify.lean').exists()
assert all('TODO' not in p.read_text() and 'TBD' not in p.read_text() for p in CHANGE.rglob('*.md'))
assert 'Fable' not in ''.join(p.read_text() for p in CHANGE.rglob('*.md'))
assert 'private-total and deliberately exposed-total variants are separate valid catalogs' in design.lower()
assert 'Region home/USD {Alice,Bob,Carol}' in design
assert len(re.findall(r'^\| F\d\d \|',design,re.M))==18
# Independent arithmetic consistency only; these are not executed kernel fixtures.
assert [6-2,4+2]==[4,6] and (4+6)==10
assert [6-1-2,4+3]==[3,7] and -1-2==-3
assert [5-1,5-1,0+2]==[4,4,2] and sum([4,4,2])==10
assert [5-2,5-2,0+4]==[3,3,4] and sum([3,3,4])==10
assert 10+1==11 and 6+4==10
assert 4+4/2==6 and 6-4/2==4
assert 4-7<0 and 3-7<0
assert all((ROOT/r['path']).read_bytes()==subprocess.check_output(['git','show',f"{r['git_revision']}:{r['path']}"],cwd=ROOT) for r in source)
after={str(p.relative_to(ROOT)):record(p) for p in planfiles}; assert before==after
checks=dict(strict_openspec_passed=True,all_tasks_unchecked=True,all_requirements_and_scenarios_mapped=True,all_tasks_covered=True,concrete_mutation_pairs14=True,fixture_contracts18=True,actual_control_catalog65_inspected_not_run=True,arithmetic_consistency_only=True,selected_sources_match_inspected_git_before_after=True,plan_inputs_unchanged_during_validation=True,Interface_source_absent=True,real_root_target=True,no_native_review_performed=True,no_implementation_performed=True,official_freeze_not_performed=True,accepted_Sprint9_dependency_remains_required=True)
result=dict(status='provisional_author_validation_passed_independent_gate_not_performed',started_utc=started,finished_utc=now(),observed_head=head,counts={**coverage['counts'],'fixture_contracts':18,'inspected_controls':len(cases)},checks=checks,commands=commands,tools=dict(openspec_path=str(exe),openspec_sha256=sha(exe.read_bytes()),openspec_version=version,python_path=str(Path(sys.executable).resolve()),python_sha256=sha(Path(sys.executable).resolve().read_bytes()),python_version=sys.version),plan_bindings=before,source_context='source-context.json',author_only=True,remaining_gates=['accepted and delivered Sprint9','actual M1 API/source/control refresh','official planning bundle freeze','nonauthor GPT-6 and native Opus planning acceptance','implementation and all proof/runtime/mutation/regression evidence','native Grok/Opus source/evidence acceptance','archive and verified delivery'])
(OUT/'author-validation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(status=result['status'],counts=result['counts'],checks=len(checks)),sort_keys=True))
