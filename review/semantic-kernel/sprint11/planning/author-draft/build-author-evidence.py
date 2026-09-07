#!/usr/bin/env python3
"""Read provisional M3 inputs; write author-only derived records. Never edits source or S10 inputs."""
from pathlib import Path
import datetime,hashlib,json,re,shutil,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[5]
E=Path(__file__).resolve().parent
C=ROOT/'openspec/changes/finite-participant-causal-composition'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(name,obj):(E/name).write_text(json.dumps(obj,indent=2,ensure_ascii=False)+'\n')
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT).decode().strip()
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert ROOT.name=='defiformal',ROOT
head=git('rev-parse','HEAD')
manifest=ROOT/'review/semantic-kernel/sprint10/planning/r2-candidate.json';frozen=json.loads(manifest.read_text())
assert all(not x['path'].startswith(('openspec/changes/finite-participant-causal-composition/','review/semantic-kernel/sprint11/planning/author-draft/')) for x in frozen['inputs'])
guard=[dict(path=x['path'],expected=x['sha256'],actual=digest(ROOT/x['path'])) for x in frozen['inputs']]
assert all(x['expected']==x['actual'] for x in guard),'S10 bound input drift'
old={x['scenario']:x for x in json.loads((E/'scenario-coverage.json').read_text())['mapping']}
rows=[];reqs=[]
for p in sorted((C/'specs').glob('*/spec.md')):
 text=p.read_text(); cap=p.parent.name
 for reqblock in re.split(r'^### Requirement: ',text,flags=re.M)[1:]:
  reqname=reqblock.splitlines()[0];reqs.append((cap,reqname)); scens=re.split(r'^#### Scenario: ',reqblock,flags=re.M)[1:];assert scens
  for block in scens:
   name=block.splitlines()[0];assert '**WHEN**' in block and '**THEN**' in block
   item=old.get(name,dict(planned_fixture_or_evidence='F09,F10',planned_proof_or_check='fixed-parameter common-prefix equality',status='planned_not_executed'))
   rows.append(dict(id=f'S{len(rows)+1:02}',capability=cap,requirement=reqname,scenario=name,planned_fixture_or_evidence=item['planned_fixture_or_evidence'],planned_proof_or_check=item['planned_proof_or_check'],status='planned_not_executed'))
assert len({x['scenario'] for x in rows})==len(rows)
tasktext=(C/'tasks.md').read_text(); tasks=re.findall(r'^- \[(.)\] (\d+\.\d+) (.+)$',tasktext,re.M);assert tasks and all(x[0]==' ' for x in tasks)
groups={'1':'all capabilities: accepted dependency/planning gate','2':'finite-participant-execution','3':'finite-participant-execution and finite-binary-continuation-correspondence','4':'finite-binary-continuation-correspondence','5':'finite-initialized-interference','6':'causal-prefix-evidence','7':'finite-participant-regression-evidence','8':'finite-participant-regression-evidence'}
fixtures=json.loads((E/'fixtures.json').read_text())['fixtures'];mutants=json.loads((E/'planned-mutations.json').read_text())['mutations']
assert {x['id'] for x in fixtures}=={f'F{i:02}' for i in range(1,20)}
assert {x['id'] for x in mutants}=={f'M{i:02}' for i in range(1,17)}
assert all(x['fixture'] in {f['id'] for f in fixtures} for x in mutants)
write('scenario-coverage.json',dict(status='provisional_author_map_not_independent_review',capabilities=len(list((C/'specs').glob('*/spec.md'))),requirements=len(reqs),scenarios=len(rows),mapping=rows))
write('task-coverage.json',dict(status='all_unchecked_proposed_work',count=len(tasks),tasks=[dict(id=n,text=t,capability_group=groups[n.split('.')[0]],status='unchecked') for _,n,t in tasks]))
source_paths=[
'AGENTS.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md','.claude/skills/defi-footguns/SKILL.md','formal/v3/GATE-REGISTER.md',
'wiki-llm/operational-metatheory-planning-draft.md','wiki-llm/sprint-11-finite-participants-causal-outline.md','graphify-out/graph.json',
'lean/DefiKernel/Parallel/Compatibility.lean','lean/DefiKernel/Parallel/Observation.lean','lean/DefiKernel/Parallel/Execution.lean','lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Composition/Interfaces.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Composition/Contracts.lean','lean/DefiKernel/Typed/Types.lean','lean/DefiKernel/Typed/Authority.lean','lean/DefiKernel/Typed/Transition.lean','lean/DefiKernel/Interleaving/Execution.lean','lean/DefiKernel/Interleaving/Schedule.lean','lean/DefiKernel/Interleaving/Soundness.lean','lean/DefiKernel/Interleaving/LocalOrder.lean','lean/DefiKernel/Interleaving/Preservation.lean','lean/DefiKernel/Interleaving/Interference.lean','lean/DefiKernel/Metatheory/SequentialGroups.lean','lean/DefiKernel/Metatheory/Observation.lean','lean/DefiKernel/Atomic/Settlement.lean','lean/Defialgebra/Nary.lean',
'openspec/changes/operational-interface-binding-preservation/design.md','review/semantic-kernel/sprint10/planning/r2-preparation/dependency-baseline.json','review/semantic-kernel/sprint10/planning/r2-preparation/inherited-controls.json']
bindings=[]
for name in source_paths:
 p=ROOT/name; data=p.read_bytes()
 try:blob=git('rev-parse',f'{head}:{name}');atgit=subprocess.check_output(['git','show',f'{head}:{name}'],cwd=ROOT);matches=data==atgit
 except subprocess.CalledProcessError:blob=None;matches=None
 bindings.append(dict(path=name,bytes=len(data),sha256=digest(p),git_blob=blob,matches_current_git=matches))
write('context-bindings.json',dict(status='read_context_not_accepted_M3_source_or_full_import_closure',utc=now(),observed_head=head,accepted_M1_source='eec499d613688137a341f3556cd80ca461dd2ee9',accepted_M1_archive='9908d9b56be2d5ed2b58a16fa8d28b23f33733ff',M2='pending_accepted_delivery_API_and_baseline_refresh',inputs=bindings,limitations=['No Nary implementation exists; names are proposed.','Historical graph and S11 outline are context; stale Opus selection in outline is superseded by current AGENTS.','No M3 runtime, proof, mutant, control or independent review executed.','Existing65 control identity is predecessor context, not final accepted S10 mapping or M3 execution.']))
commands=[['openspec','validate','finite-participant-causal-composition','--strict','--no-interactive'],['openspec','status','--change','finite-participant-causal-composition','--json'],['git','diff','--check','--','openspec/changes/finite-participant-causal-composition','review/semantic-kernel/sprint11/planning/author-draft'],['graphify','query','nary interface composition invariant','--budget','1200']]
runs=[]
for index,cmd in enumerate(commands,1):
 exe=Path(shutil.which(cmd[0])).resolve();exe_binding=dict(requested=cmd[0],resolved_path=str(exe),sha256=digest(exe))
 start=now();tic=time.monotonic();p=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=60);dur=time.monotonic()-tic
 out=E/f'check-{index:02}.stdout.log';err=E/f'check-{index:02}.stderr.log';out.write_bytes(p.stdout);err.write_bytes(p.stderr)
 runs.append(dict(command=cmd,executable=exe_binding,cwd=str(ROOT),started_utc=start,finished_utc=now(),duration_seconds=dur,exit_code=p.returncode,stdout=dict(path=str(out.relative_to(ROOT)),sha256=digest(out)),stderr=dict(path=str(err.relative_to(ROOT)),sha256=digest(err))))
 assert p.returncode==0,(cmd,p.stderr.decode())
# git diff cannot inspect untracked draft files, so check their whitespace directly as well.
for p in [*C.rglob('*.md'),*E.glob('*.md')]:
 assert all(line.rstrip()==line for line in p.read_text().splitlines()),p
post=[dict(path=x['path'],expected=x['sha256'],actual=digest(ROOT/x['path'])) for x in frozen['inputs']]
assert all(x['expected']==x['actual'] for x in post)
write('s10-input-guard-after.json',dict(utc=now(),candidate=frozen['candidate'],count=len(post),all_unchanged=True,checks=post))
write('author-validation.json',dict(status='provisional_author_checks_passed_not_official_freeze_or_gate',utc=now(),observed_head=head,counts=dict(capabilities=len(list((C/'specs').glob('*/spec.md'))),requirements=len(reqs),scenarios=len(rows),unchecked_tasks=len(tasks),fixtures=len(fixtures),planned_mutants=len(mutants),existing_predecessor_controls=65),M2_dependency='pending_accepted_delivery_and_API_control_baseline_refresh',reviews='none_requested_for_M3',author_generator=dict(path=str(Path(__file__).relative_to(ROOT)),sha256=digest(Path(__file__)),python_path=str(Path(sys.executable).resolve()),python_sha256=digest(Path(sys.executable).resolve()),python_version=sys.version),actual_runs=runs,S10_frozen_inputs_unchanged=len(post),graph_query_limit='Historical positive-program graph only; no current n-ary kernel API inferred.',tests='No Lean or runtime tests were run; this validates authored planning artifacts only.'))
artifacts=[]
for p in sorted([*C.rglob('*'),*E.glob('*')]):
 if p.is_file() and p.name!='artifacts.json':artifacts.append(dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=digest(p)))
write('artifacts.json',dict(status='provisional_author_snapshot',utc=now(),artifacts=artifacts))
print(json.dumps({'capabilities':len(list((C/'specs').glob('*/spec.md'))),'requirements':len(reqs),'scenarios':len(rows),'tasks':len(tasks),'fixtures':len(fixtures),'planned_mutants':len(mutants),'S10_inputs_unchanged':len(post)}))
