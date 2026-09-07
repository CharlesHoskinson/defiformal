#!/usr/bin/env python3
"""Retain actual earlier executions only where all relevant source bytes still match."""
import datetime,hashlib,json,pathlib,subprocess
R=pathlib.Path(__file__).resolve().parents[4]
B=R/'review/semantic-kernel/integer-arithmetic';S=R/'review/semantic-kernel/sprint10'
NEW='ddf1ac0e50f2e032385664a0965bab59eef91ea3'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def read(p):return json.loads(p.read_text())
def git(*a):return subprocess.check_output(['git',*a],cwd=R)
def equal(old,paths):
 out={}
 for path in sorted(paths):
  a=git('show',old+':'+path);b=git('show',NEW+':'+path)
  assert a==b==(R/path).read_bytes(),path
  out[path]={'sha256':sha(a),'bytes':len(a),'original_git_blob':git('rev-parse',old+':'+path).decode().strip(),'candidate_git_blob':git('rev-parse',NEW+':'+path).decode().strip(),'equal':True}
 assert out
 return out
common={'lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json'}
rows=[];artifacts={}
def artifact(p):
 artifacts[str(p.relative_to(R))]=sha(p.read_bytes());return read(p)
legacy=artifact(S/'implementation/legacy-dependency-equivalence.json')
for s in legacy['suites']:
 rows.append({'label':s['label'],'actual_execution_candidate':s['actual_execution_candidate'],'closure_basis':s['closure_basis'],'source_bindings':equal(s['actual_execution_candidate'],s['source_closure']),'original_run':s['original_run']})
m=artifact(S/'acceptance/sprint9-regression-carry.json')
rows.append({'label':'metatheory14mutations65controls','actual_execution_candidate':m['actual_execution_candidate'],'source_bindings':equal(m['actual_execution_candidate'],m['source_bindings']),'evidence':m['evidence']})
m=artifact(S/'mutations-r1/source-manifest.json')
paths=set(m['sources'])|common|{'scripts/run_interface_mutations.py','scripts/test_interface_mutation_runner.py','mutations/interface.json'}
rows.append({'label':'interface14mutations65controls','actual_execution_candidate':m['git_head'],'source_bindings':equal(m['git_head'],paths),'evidence':['review/semantic-kernel/sprint10/mutations-r1/results.json','review/semantic-kernel/sprint10/implementation/runner-controls-r1/summary.json']})
for name in ['mutations-r1/results.json','implementation/runner-controls-r1/summary.json']:artifact(S/name)
m=artifact(B/'implementation/runner-controls-r1/summary.json')
paths=common|{str(pathlib.Path(m[k+'_source']).relative_to(R)) for k in ['runner','harness']}
for k in ['runner','harness']: assert sha((R/str(pathlib.Path(m[k+'_source']).relative_to(R))).read_bytes())==m[k+'_sha256']
rows.append({'label':'arithmetic65controls','actual_execution_candidate':m['git_head'],'source_bindings':equal(m['git_head'],paths),'closure_basis':'The unchanged harness generates isolated synthetic Lean fixtures, copies only the pinned configuration, and invokes the unchanged runner. Production arithmetic sources are not control inputs.'})
m=artifact(B/'diagnostics/run-r1/result.json');assert m['status']=='PASS' and m['actual_count']==27968
for path,row in m['source_before'].items():assert sha((R/path).read_bytes())==row['sha256']
for path,h in m['helper_bindings'].items():assert sha((R/path).read_bytes())==h
for path,h in m['outputs'].items():assert sha((B/'diagnostics/run-r1'/path).read_bytes())==h
for path,h in m['tools'].items():assert sha(pathlib.Path(path).read_bytes())==h
rows.append({'label':'arithmetic27968finiteoracle','actual_execution_candidate':m['candidate'],'source_bindings':equal(m['candidate'],m['source_before']),'helper_bindings':m['helper_bindings'],'tool_bindings':m['tools'],'closure_basis':'Diagnostic imports Operations and Fees, whose Arithmetic closure is Word/Rounding/Operations/Fees; all are included along with pinned configuration. Raw records and independent expected output also verified.'})
tools={}
for k,v in legacy['tools'].items():
 path=pathlib.Path(v['path']);assert sha(path.read_bytes())==v['sha256'];tools[k]=v
record={'status':'PASS','candidate':NEW,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'kind':'relevant-source-equivalence-not-new-execution','retained_groups':rows,'all_relevant_inputs_equal':True,'tools':tools,'input_artifacts':artifacts,'checker_sha256':sha(pathlib.Path(__file__).read_bytes()),'scope':'Earlier executions keep their actual Git identities. This is author source/dependency analysis, not rerunning them or independent acceptance. Changed root imports are freshly exercised by integration-r1, not silently included in an unchanged-source claim.'}
(B/'implementation/retained-evidence.json').write_text(json.dumps(record,indent=2)+'\n')
print('PASS',len(rows),'retained groups; actual original identities preserved')
