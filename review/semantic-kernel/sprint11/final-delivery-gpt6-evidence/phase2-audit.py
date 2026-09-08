from pathlib import Path
import json,hashlib,subprocess,tarfile
R=Path.cwd();S=R/'review/semantic-kernel/sprint11';D=S/'implementation/delivery-preparation';O=S/'final-delivery-gpt6-evidence';primary=Path('/home/charl/defiformal');C='0c9cc3aa342fb9be47adb92cf5a86505195313b3';inputs={};gitinputs={}
def h(b):return hashlib.sha256(b).hexdigest()
def rd(p):
 b=Path(p).read_bytes();inputs[str(p)]={'sha256':h(b),'bytes':len(b)};return b
def js(p):return json.loads(rd(p))
def gitblob(c,p):
 b=subprocess.check_output(['git','show',c+':'+p],cwd=R);gitinputs[c+':'+p]={'sha256':h(b),'bytes':len(b)};return b
rd(__file__);bk=js(S/'bookkeeping-delivery.json');assert bk['bookkeeping_commit']==bk['remote_head']==C and bk['remote_verified']
for name in ['bookkeeping-commit','bookkeeping-push','bookkeeping-readback','bookkeeping-fetch']:
 d=js(D/(name+'.json'));assert d['exit_code']==0
 for st in ['stdout','stderr']:assert h(rd(D/(name+'.'+st)))==d[st+'_sha256']
assert rd(D/'bookkeeping-readback.stdout').decode()==C+'\trefs/heads/semantic-kernel-pivot\n'
trans=js(O/'transition-check.json')
for p,x in trans['inputs'].items():
 b=rd(p);assert h(b)==x['sha256'];assert gitblob(C,str(Path(p).relative_to(R)))==b
freeze=js(S/'implementation/candidate-source-freeze-r2.json')
for x in freeze['integrated_sources']:assert h(gitblob(C,x['path']))==x['sha256'] and h(rd(primary/x['path']))==x['sha256']
for p in ['scripts/run_nary_mutations.py','scripts/test_nary_mutation_runner.py']:assert gitblob(C,p)==rd(R/p)==rd(primary/p)
p=js(S/'primary-integration.json');assert p['target']==p['primary_after']==C and len(p['tracked_changes'])==10 and len(p['obstructions'])==p['preserved_obstruction_files']==141 and len(p['unrelated_untracked_metadata'])==105
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=primary,text=True).strip()==C
assert subprocess.check_output(['git','branch','--show-current'],cwd=primary,text=True).strip()=='semantic-kernel-pivot'
assert not subprocess.check_output(['git','diff','HEAD','--name-only'],cwd=primary)
assert all(x['exit_code']==0 for x in p['commands']) and p['commands'][1]['argv']==['git','merge','--ff-only',C]
before=js(D/'primary-before.json');assert p['tracked_changes']==before['tracked_before'];assert h(rd(D/'primary-tracked-before.tar.gz'))==before['archive_sha256']
with tarfile.open(D/'primary-tracked-before.tar.gz') as t:
 for x in p['tracked_changes']:
  b=t.extractfile(x['path']).read();assert h(b)==x['sha256'] and len(b)==x['bytes'];assert gitblob(p['preserved_stash_commit'],x['path'])==b
obsroot=Path(p['preservation_root']);false=[]
for command,name in zip(p['commands'],['selective-primary-stash','primary-fast-forward']):
 for st in ['stdout','stderr']:assert h(rd(obsroot/(name+'.'+st)))==command[st+'_sha256']
for name in ['commands.json','before.json','result.json']:rd(obsroot/name)
for x in p['obstructions']:
 b=rd(obsroot/'untracked'/x['path']);assert h(b)==x['sha256'] and len(b)==x['bytes'];incoming=gitblob(C,x['path']);assert (h(incoming)==x['sha256'])==x['matches_incoming'];assert rd(primary/x['path'])==incoming
 if not x['matches_incoming']:false.append(x['path'])
for x in p['unrelated_untracked_metadata']:
 st=(primary/x['path']).stat();assert st.st_size==x['bytes'] and st.st_mtime_ns==x['mtime_ns'];rd(primary/x['path'])
result={'status':'PASS_C_DELIVERY_AND_PRIMARY_INTEGRATION','bookkeeping_commit':C,'primary_HEAD':C,'primary_branch':'semantic-kernel-pivot','tracked_diff_empty':True,'tracked_preserved_in_stash_and_archive':10,'stash_commit':p['preserved_stash_commit'],'obstructions_preserved':141,'obstructions_different_from_incoming':false,'unrelated_untracked_same_size_mtime':105,'unrelated_untracked_bytes_before_not_available':True,'integrated_sources_exact_candidate':164,'inputs':inputs,'git_inputs':gitinputs,'input_drift':[p for p,x in inputs.items() if h(Path(p).read_bytes())!=x['sha256']]};assert not result['input_drift'];(O/'phase2-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k not in ['inputs','git_inputs']},indent=2))
