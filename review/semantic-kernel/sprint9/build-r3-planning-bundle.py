from pathlib import Path
import json, hashlib, subprocess, datetime
r=Path(__file__).resolve().parents[3]
p=Path(__file__).parent/'planning'
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()
prior=json.loads((p/'r2-candidate.json').read_text())
sha=lambda b:hashlib.sha256(b).hexdigest()
continuity=[]
for row in prior['inputs']:
 if not row['path'].startswith(('lean/','scripts/')): continue
 f=r/row['path']; raw=f.read_bytes()
 assert sha(raw)==row['sha256'],f
 assert raw==subprocess.check_output(['git','show',head+':'+row['path']],cwd=r),f
 assert raw==subprocess.check_output(['git','show',prior['candidate']+':'+row['path']],cwd=r),f
 continuity.append({'path':row['path'],'sha256':row['sha256'],'equal_current_and_prior_git_objects':True})
assert continuity and not (r/'lean/DefiKernel/Metatheory').exists()
change=Path('openspec/changes/operational-continuation-congruence')
paths=[Path('AGENTS.md'),change/'proposal.md',change/'design.md',change/'tasks.md']
paths += [f.relative_to(r) for f in sorted((r/change/'specs').glob('*/spec.md'))]
paths += [Path('wiki-llm/sprint-9-operational-continuation-congruence.md')]
paths += [Path('scripts')/x for x in ['check_atomic_mutations.py','test_atomic_mutation_runner.py']]
paths += [Path('lean/DefiKernel')/x for x in ['Composition/Sequence.lean','Composition/Execution.lean','Parallel/Observation.lean']]
paths += [Path('review/semantic-kernel/sprint9/planning')/x for x in ['r3-resolution.md','runner-literal-adaptation-map.json','build-runner-literal-map.py','runner-adaptation-map.json','author-validation.json','scenario-planning-map.json','baseline/gate-evidence.json','r2-gpt6.md','r2-opus.md','r2-opus.invocation.json']]
paths += [Path('review/semantic-kernel/sprint8/mutation-spec.json')]
paths += [Path(x['path']) for x in prior['inputs'] if x['path'].startswith('lean/')]
header=f'''Independent Sprint9 r3 OpenSpec planning audit, including full semantic source for the newly restored Fable reviewer. Candidate {head}. This is closure of three remaining runner clarifications after the full semantic-source r2 planning audit at {prior['candidate']}, bundle {prior['bundle_sha256']}. Both prior full-source reviewers accepted the semantic M1 plan with limitations; native Opus's three required runner changes are included verbatim below with the root resolution. All prior Lean and runner source inputs have been mechanically checked byte-identical in both Git candidates and the workspace. No Metatheory implementation exists. This is not implementation approval by an author, nor a new independent baseline execution.

Review the FULL revised proposal/design/four specs/tasks/scenario map, exact runner/harness and complete literal adaptation inventory supplied here. Determine whether the timeout reading preserves actual inherited behavior, all literal adaptation decisions are covered, unique needles are required at actual new-source sites, and the historical explicit spec path is corrected. Reassess whether revisions introduce a semantic/proof/scope contradiction; the complete prior semantic-source closure is supplied again for independent inspection by native Fable 5.1; source continuity also binds it to the earlier full audits. If this continuation of the prior audit cannot support a substantive verdict, explicitly say so. Do not invent executed checks or promote source inspection into proof. All supplied file bodies are original bytes; source continuity records are host-generated verification evidence, not your independent execution.

The user requires independent nonauthor GPT6 and native Fable 5.1 (medium effort) passes on this SAME revised candidate/bundle before implementation. Native Grok+Fable 5.1 at medium effort will later review code and evidence, following the latest user instruction; completed Opus reports retain their identity. No Foreman. No tools, code edits, external messages or XML. Return substantive plain text starting VERDICT: ACCEPT / ACCEPT WITH LIMITATIONS / REVISE, then BLOCKERS, REQUIRED CHANGES, NONBLOCKING LIMITATIONS and SCOPE CHECK. Distinguish remaining preimplementation blockers from concrete implementation obligations already stated. A passing verdict does not mean new proofs or tests have run.

Verified unchanged semantic source continuity (prior full review retained):
{json.dumps(continuity,indent=2)}
'''
rows=[];parts=[header]
for path in dict.fromkeys(paths):
 data=(r/path).read_bytes(); assert data==subprocess.check_output(['git','show',head+':'+str(path)],cwd=r),path
 h=sha(data);rows.append({'path':str(path),'sha256':h,'rendered_sha256':h,'bytes':len(data),'git_blob':subprocess.check_output(['git','rev-parse',head+':'+str(path)],cwd=r,text=True).strip()})
 parts.append(f'\n\n===== INPUT {path} ORIGINAL_SHA256 {h} RENDERED_SHA256 {h} =====\n'+data.decode())
b=''.join(parts).encode();(p/'r3-bundle.md').write_bytes(b)
m={'candidate':head,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'bundle_sha256':sha(b),'bundle_bytes':len(b),'input_count':len(rows),'inputs':rows,'prior_full_semantic_review_candidate':prior['candidate'],'prior_full_bundle_sha256':prior['bundle_sha256'],'semantic_source_continuity':continuity,'scope':'Focused closure of runner clarifications; full normative plan and exact runner sources; full semantic source supplied; prior full audits retained against unchanged source'}
(p/'r3-candidate.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({k:v for k,v in m.items() if k not in ['inputs','semantic_source_continuity']},indent=2))
