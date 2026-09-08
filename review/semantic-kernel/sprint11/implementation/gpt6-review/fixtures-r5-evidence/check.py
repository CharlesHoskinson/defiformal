from pathlib import Path
import hashlib,json,re,gzip,tarfile,subprocess,time,ast,itertools,difflib
root=Path.cwd();impl=root/'review/semantic-kernel/sprint11/implementation';out=impl/'gpt6-review/fixtures-r5-evidence';ev=impl/'fixtures-r5';cache=Path('/home/charl/.cache/defiformal-sprint11-builds/fixture');inputs={}
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):
 p=Path(p);b=p.read_bytes();inputs[str(p)]={'sha256':sha(b),'bytes':len(b)};return b
def jr(p):return json.loads(read(p))
read(__file__)
before=read(impl/'fixtures-r4/source-snapshot/Tests.lean');after=read(root/'lean/DefiKernel/Nary/Tests.lean')
assert before==read(ev/'source-snapshot-before/Tests.lean')
assert after==read(ev/'source-snapshot/Tests.lean')==read(cache/'DefiKernel/Nary/Tests.lean')
assert sha(before)=='d029f586694a96ed3cdc8accd4bddd90162e36ca6e028dd0ad628da851666512'
assert sha(after)=='b63713488d3997a0ce4c68198a2792caf389a6265c040e3072e72f219bd1d8ca'
(out/'Tests.before.lean.txt').write_bytes(before);(out/'Tests.after.lean.txt').write_bytes(after)
bs=before.decode();ss=after.decode();oldsy=re.findall(r'\(synth "([^"]+)" (\w+)\)',bs);newsy=re.findall(r'\(synth "([^"]+)" (\w+)\)',ss)
assert len(oldsy)==len(newsy) and [m for _,m in oldsy]==[m for _,m in newsy]
snake=lambda s:re.sub(r'([a-z0-9])([A-Z])',r'\1_\2',s).lower()
restored=ss
for (a,m),(b,n) in zip(oldsy,newsy):
 assert b==snake(a) and m==n
 restored=restored.replace(f'(synth "{b}" {m})',f'(synth "{a}" {m})')
helper='/-- Digit-initial schedule tags are prefixed only in the emitted observation name. -/\ndef emitSchedTag (s : List (Fin 3)) : String :=\n  "s" ++ schedTag s\n'
assert restored.count(helper)==1 and restored.count('{emitSchedTag s}')==5
restored=restored.replace(helper,'').replace('{emitSchedTag s}','{schedTag s}')
assert restored.encode()==before
(out/'Tests.restored.lean.txt').write_text(restored)
(out/'independent.diff').write_text(''.join(difflib.unified_diff(bs.splitlines(True),ss.splitlines(True),fromfile='r4',tofile='r5')))
for n in ['Examples','Audit']:
 b=read(root/f'lean/DefiKernel/Nary/{n}.lean');assert b==read(impl/f'fixtures-r4/source-snapshot/{n}.lean')==read(ev/f'source-snapshot/{n}.lean')==read(cache/f'DefiKernel/Nary/{n}.lean')
runner=read(root/'scripts/run_nary_mutations.py');assert sha(runner)=='4528dde870fdb3e4c408e4646f70dcc5f8d31a84623e488103eee528a2e020be'
node=next(x for x in ast.parse(runner).body if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='CHECK_NAME' for t in x.targets));grammar=ast.literal_eval(node.value)
def parse(b):
 rows=[re.fullmatch(r'(nary\.[^:]+): (true|false)',l) for l in b.decode().splitlines()];assert all(rows)
 rows=[m.groups() for m in rows];assert len(rows)==len(dict(rows))==310;return rows
oldout=read(impl/'fixtures-r4/logs/eval-Audit.stdout');newout=read(ev/'logs/eval-Audit.stdout');oldrows=parse(oldout);newrows=parse(newout)
def rename(s):return '.'.join(('s'+t if t[0].isdigit() else snake(t)) for t in s.split('.'))
assert [(rename(n),v) for n,v in oldrows]==newrows
assert all(v=='true' for _,v in newrows)
changed=[(a,b) for (a,_),(b,_) in zip(oldrows,newrows) if a!=b];assert len(changed)==180
assert all(re.fullmatch(grammar,n) for n,_ in newrows)
assert all(rename(n)==n for n,_ in oldrows if re.fullmatch(grammar,n))
assert sum(bool(re.fullmatch(grammar,n)) for n,_ in oldrows)==130
# Same regex logic as frozen runner, including candidate line count.
obs=re.findall(rf'^({grammar}): (true|false)$',newout.decode(),re.M);candidates=re.findall(r'^[A-Za-z0-9_.-]+:',newout.decode(),re.M)
assert len(obs)==len(candidates)==310 and len(dict(obs))==310
assert len(re.findall(rf'^({grammar}): (true|false)$',oldout.decode(),re.M))==130
mapping=[{'old':a,'new':b,'outcome':v,'changed':a!=b} for (a,v),(b,w) in zip(oldrows,newrows)];(out/'independent-bijection.json').write_text(json.dumps(mapping,indent=2)+'\n')
claimed=jr(ev/'label-bijection.json');assert [(x['old'],x['new']) for x in claimed['rows']]==[(x['old'],x['new']) for x in mapping]
# Generate exact name inventory independently from literal source and finite schedules.
static=re.findall(r'\("(nary\.[^"]+)",',ss);tags=['s'+''.join(map(str,s)) for s in sorted(set(itertools.permutations([0,0,1,2])))];expected=static+[f'nary.f09.{c}.{s}' for s,_ in newsy for c in ['candidate','independent']]
expected += [f'nary.f10.sched.{s}.{x}' for s in tags for x in ['final','reserve','monitor']+[f'prefix{i}' for i in range(5)]]
expected += [f'nary.f18.sched.s{"".join(map(str,s))}' for s in itertools.permutations(range(3))]
assert len(expected)==len(set(expected))==310 and set(expected)==set(dict(newrows))
specs=[]
for p in sorted((impl/'runner-r1/specs').glob('M*.json')):
 x=jr(p);names=x['positive_checks']+[n for m in x['mutations'] for n in m['required_false']]
 assert all(n in dict(newrows) and rename(n)==n for n in names)
 for m in x['mutations']:
  src=read(root/'lean'/Path(*m['module'].split('.')).with_suffix('.lean')).decode();assert src.count(m['needle'])==1
 specs.append({'path':str(p.relative_to(root)),'sha256':sha(p.read_bytes()),'exact_names':names})
assert len(specs)==16
manifest=jr(ev/'final-artifacts.json');listed=set()
for x in manifest['files']:
 p=ev/x['path'];b=read(p);assert sha(b)==x['sha256'] and len(b)==x['bytes'];listed.add(str(Path(x['path'])))
assert listed=={str(p.relative_to(ev)) for p in ev.rglob('*') if p.is_file()}-{'final-artifacts.json'}
archive=impl/'native-worker/fixtures-r5-stage.tar.gz';assert sha(read(archive))=='36658f456df736cf16fe1668bf711c35a0ddac55cfb007b9960c102de40c6811';arc=[]
with tarfile.open(archive) as t:
 for m in t.getmembers():
  if m.isfile():
   b=t.extractfile(m).read();assert read(root/m.name)==b;arc.append({'path':m.name,'sha256':sha(b)})
identity=jr(impl/'native-worker/fixtures-r5.json');assert identity['exit_code']==0
raw=gzip.decompress(read(impl/'native-worker/fixtures-r5.jsonl.gz'));assert sha(raw)==identity['raw_sha256'];ends=[]
for i,l in enumerate(raw.splitlines(),1):
 x=json.loads(l)
 if x.get('type')=='end':ends.append({'line':i,'sessionId':x['sessionId'],'modelUsage_keys':list(x.get('modelUsage',{}))})
assert ends[-1]['sessionId']=='01a07ed5-e45f-70e2-85f6-c621d2aef4f9' and ends[-1]['modelUsage_keys']==['grok-4.6-build']
closure={};pending=['DefiKernel.Nary.Audit'];artifacts=[]
while pending:
 m=pending.pop()
 if m in closure:continue
 rel=Path(*m.split('.')).with_suffix('.lean');p=root/'lean'/rel
 if not p.exists():continue
 b=read(p);assert b==read(cache/rel);closure[m]=sha(b);pending+=re.findall(r'^import\s+([\w.]+)\s*$',b.decode(),re.M)
 stem=cache/'.lake/build/lib/lean'/Path(*m.split('.'))
 for p in sorted(stem.parent.glob(stem.name+'.*')):
  if p.is_file():read(p);artifacts.append(str(p))
for n in ['lean-toolchain','lakefile.toml','lake-manifest.json']:assert read(root/'lean'/n)==read(cache/n)
for n in ['lean','lake']:
 p=Path(subprocess.check_output(['lake','env','which',n],cwd=cache,text=True).strip()).resolve();read(p)
stdin='import DefiKernel.Nary.Audit\n#eval DefiKernel.Nary.Audit.main\n';(out/'replay.stdin.lean.txt').write_text(stdin)
t=time.time();p=subprocess.run(['lake','env','lean','--stdin'],cwd=cache,input=stdin,text=True,capture_output=True,timeout=55)
(out/'replay.stdout').write_text(p.stdout);(out/'replay.stderr').write_text(p.stderr);command={'argv':['lake','env','lean','--stdin'],'cwd':str(cache),'exit':p.returncode,'seconds':time.time()-t,'stdout_sha256':sha(p.stdout.encode())};(out/'replay-command.json').write_text(json.dumps(command,indent=2)+'\n')
assert p.returncode==0 and p.stdout.encode()==newout and p.stderr==''
assert all(sha(Path(p).read_bytes())==r['sha256'] for p,r in inputs.items())
head=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip();commit_bytes=subprocess.check_output(['git','show',head+':lean/DefiKernel/Nary/Tests.lean']);commit_equal=commit_bytes==after
res={'status':'ACCEPT_WITH_LIMITATIONS_RUNTIME_LABEL_REPAIR_ONLY','reviewer':'independent GPT-6 / gpt-6-astra','native_end':ends[-1],'head_observed':head,'head_tests_blob_equals_reviewed':commit_equal,'source_sha256':sha(after),'before_sha256':sha(before),'exact_body_restore':True,'synth_literal_pairs':list(zip(oldsy,newsy)),'emission_schedule_sites':5,'row_count':310,'changed':180,'unchanged':130,'all_old_valid_labels_unchanged':True,'source_name_inventory_exact':True,'runner_sha256':sha(runner),'grammar':grammar,'specs':specs,'manifest_files':len(listed),'archive_files':arc,'runtime_closure':closure,'compiled_artifact_count':len(artifacts),'command':command,'all_inputs_unchanged':True,'inputs':inputs,'limits':['Read-only replay of author fresh compiled artifacts; reviewer did not rebuild','No kernel proof claim for executable comparisons','No production mutation detection credit','No final integrated Sprint11 acceptance']}
(out/'result.json').write_text(json.dumps(res,indent=2)+'\n');print(json.dumps({k:v for k,v in res.items() if k in ['status','head_observed','head_tests_blob_equals_reviewed','row_count','changed','unchanged','manifest_files','compiled_artifact_count','command']},indent=2))
