from pathlib import Path
import json,hashlib,subprocess,re,tarfile,datetime
R=Path.cwd();S=R/'review/semantic-kernel/sprint11';I=S/'implementation';D=I/'delivery-preparation';O=S/'final-delivery-gpt6-evidence';C='94f70e502c75132656bd0902a17be60ca45ab1c2';A='3e736fb0bb45885a49689cdc44a3db0f82987acd';B='681362d88a47bb27d925b5af50bbef86283b1a57';inputs={};gitinputs={}
def h(b):return hashlib.sha256(b).hexdigest()
def rd(p):
 b=Path(p).read_bytes();inputs[str(p)]={'sha256':h(b),'bytes':len(b)};return b
def js(p):return json.loads(rd(p))
def gitblob(c,p):
 b=subprocess.check_output(['git','show',c+':'+p],cwd=R);gitinputs[c+':'+p]={'sha256':h(b),'bytes':len(b)};return b
rd(__file__);delivery=js(S/'delivery.json');archive=js(S/'archive-delivery.json');assert delivery['source_candidate']==C and delivery['source_evidence_commit']==delivery['remote_head']==A;assert archive['archive_commit']==archive['remote_head']==B and archive['source_evidence_commit']==A
commands=[]
for name in ['source-evidence-commit','source-evidence-push','source-delivery-readback','source-delivery-fetch','archive-commit','archive-push','archive-readback','archive-fetch']:
 d=js(D/(name+'.json'));assert d['exit_code']==0
 for stream in ['stdout','stderr']:assert h(rd(D/(name+'.'+stream)))==d[stream+'_sha256']
 commands.append({'name':name,'argv':d['argv'],'exit':0})
assert rd(D/'source-delivery-readback.stdout').decode()==A+'\trefs/heads/semantic-kernel-pivot\n';assert rd(D/'archive-readback.stdout').decode()==B+'\trefs/heads/semantic-kernel-pivot\n'
for prev,nxt in [(C,A),(A,B)]:assert subprocess.run(['git','merge-base','--is-ancestor',prev,nxt],cwd=R).returncode==0
m=js(D/'release-file-manifest-r1.json');assert h(rd(D/'release-file-manifest-r1.json'))==delivery['release_manifest_sha256'];assert len(m['files'])==2658 and len({x['path'] for x in m['files']})==2658
# Read exact published immutable commit blobs through one cat-file subprocess.
proc=subprocess.Popen(['git','cat-file','--batch'],cwd=R,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
for x in m['files']:
 key=A+':'+x['path'];proc.stdin.write((key+'\n').encode());proc.stdin.flush();hdr=proc.stdout.readline().decode().strip().split();assert hdr[1]=='blob',hdr;size=int(hdr[2]);digest=hashlib.sha256();left=size
 while left:
  b=proc.stdout.read(min(left,1024*1024));assert b;digest.update(b);left-=len(b)
 assert proc.stdout.read(1)==b'\n';assert size==x['bytes'] and digest.hexdigest()==x['sha256'],x['path'];gitinputs[key]={'sha256':digest.hexdigest(),'bytes':size}
proc.stdin.close();assert proc.wait()==0
freeze=js(I/'candidate-source-freeze-r2.json');assert len(freeze['integrated_sources'])==164
for x in freeze['integrated_sources']:
 assert h(rd(R/x['path']))==x['sha256'] and h(gitblob(A,x['path']))==x['sha256'] and h(gitblob(B,x['path']))==x['sha256']
for p in ['scripts/run_nary_mutations.py','scripts/test_nary_mutation_runner.py']:assert gitblob(C,p)==gitblob(A,p)==gitblob(B,p)==rd(R/p)
ai=js(S/'archive-integrity-r1.json');assert len(ai['files'])==15;specs=[]
for x in ai['files']:
 a=gitblob(A,x['original_path']);b=gitblob(B,x['archive_path']);assert a==b and h(a)==x['sha256'] and len(a)==x['bytes']
 if '/specs/' in x['archive_path']:
  main='openspec/specs/'+x['archive_path'].split('/specs/')[1];bmain=gitblob(B,main);assert bmain==rd(R/main);src=a.decode();target=bmain.decode();start=src.index('### Requirement:');assert src[start:].strip()==target[target.index('### Requirement:'):].strip();specs.append(main)
assert len(specs)==5
at=gitblob(B,'openspec/changes/archive/2026-09-08-finite-participant-causal-composition/tasks.md').decode();assert len(re.findall(r'^- \[x\]',at,re.M))==34 and len(re.findall(r'^- \[ \]',at,re.M))==1
for name,n in [('archive-action',None),('archive-validation',33),('archive-task-validation',8)]:
 d=js(S/(name+'.json'));assert d['exit_code']==0
 for st in ['stdout','stderr']:assert h(rd(S/(name+'.'+st)))==d[st+'_sha256']
 actual=json.loads(rd(S/(name+'.stdout')));assert actual==d['result']
 if n:assert d['result']['summary']['totals']=={'items':n,'passed':n,'failed':0} and all(x['valid'] for x in d['result']['items'])
# Historical native and pre-closure snapshots retain their accepted immutable bytes.
nativearc=I/'native-worker/sprint11-release-closure-r1-stage.tar.gz';assert h(rd(nativearc))=='114683dac9984e2bc813b5c1fb9da2168cc8bb18f3f862f7aa411b50fc3d22f0';pre=js(I/'acceptance/pre-closure-normative.json');pretar=I/'acceptance/pre-closure-normative.tar.gz';assert h(rd(pretar))==pre['archive_sha256']
with tarfile.open(pretar) as t:
 for x in pre['files']:
  b=t.extractfile(x['path']).read();assert h(b)==x['sha256'] and len(b)==x['bytes']
assert h(rd(I/'gpt6-review/final-adjudication-r1.md'))=='b2e46b5c962b9a205a2a0cc085ed0fc388d281a4cade1bcc6744cbb7e98b36cd'
result={'status':'PROVISIONAL_DELIVERY_A_B_VERIFIED_C_AND_PRIMARY_PENDING','source_candidate':C,'source_evidence_delivery':A,'archive_delivery':B,'source_evidence_blobs_verified':2658,'integrated_sources_unchanged':164,'archive_files_equal_A_B':15,'main_specs_synchronized':5,'historical_archive_checked_tasks':34,'saved_validation_main_specs':33,'saved_validation_archived_changes':8,'native_preclosure_archive_preserved':True,'commands':commands,'inputs':inputs,'git_inputs':gitinputs,'input_drift':[p for p,x in inputs.items() if h(Path(p).read_bytes())!=x['sha256']]};assert not result['input_drift'];(O/'phase1-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k not in ['inputs','git_inputs','commands']},indent=2))
