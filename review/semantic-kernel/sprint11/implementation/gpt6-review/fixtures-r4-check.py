"""Independent frozen fixture r3+r4 source/evidence check and read-only Lean replay."""
from pathlib import Path
import hashlib,json,re,gzip,itertools,subprocess,datetime
root=Path(__file__).resolve().parents[5]; out=Path(__file__).resolve().parent
impl=out.parent; cache=Path('/home/charl/.cache/defiformal-sprint11-builds/proof')
inputs={}
def read(p):
 p=Path(p); p=p if p.is_absolute() else root/p
 b=p.read_bytes(); inputs[str(p)]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b),'mtime_ns':p.stat().st_mtime_ns}; return b
def jr(p):return json.loads(read(p))
def sha(b):return hashlib.sha256(b).hexdigest()
def rows(b):
 lines=b.decode().splitlines(); m=[re.fullmatch(r'(nary\.[^:]+): (true|false)',x) for x in lines]
 assert all(m); pairs=[x.groups() for x in m]; assert len(pairs)==len(dict(pairs));return dict(pairs)
read(__file__)
for lane in ['fixtures-r3','fixtures-r4']:
 for p in (impl/lane).rglob('*'):
  if p.is_file():read(p)
ev=impl/'fixtures-r4'; manifest=jr(ev/'final-artifacts.json')
assert manifest['file_count']==len(manifest['files'])==39
listed={str(Path(r['path'])) for r in manifest['files']}
actual={str(p.relative_to(ev)) for p in ev.rglob('*') if p.is_file()}-{'final-artifacts.json'}
assert listed==actual
for r in manifest['files']:
 b=read(ev/r['path']);assert sha(b)==r['sha256'] and len(b)==r['bytes']
old=rows(read(impl/'fixtures-r2/eval-Audit.final.stdout'))
r3=rows(read(impl/'fixtures-r3/logs/eval-Audit.stdout'))
new=rows(read(ev/'logs/eval-Audit.stdout'))
assert len(old)==288 and len(r3)==298 and len(new)==310
assert old.items()<=r3.items()<=new.items() and set(new.values())=={'true'}
assert len(set(r3)-set(old))==10 and len(set(new)-set(r3))==12
assert all(x.startswith('nary.f03.') for x in set(r3)-set(old))
assert all(x.startswith('nary.f07.three-chunk.') for x in set(new)-set(r3))
t=read('lean/DefiKernel/Nary/Tests.lean').decode()
static=re.findall(r'\("(nary\.[^"]+)",',t);synth=re.findall(r'\(synth "([^"]+)"',t)
tags=[''.join(map(str,s)) for s in sorted(set(itertools.permutations([0,0,1,2])))]
expected=static+[f'nary.f09.{c}.{s}' for s in synth for c in ['candidate','independent']]
expected += [f'nary.f10.sched.{s}.{x}' for s in tags for x in ['final','reserve','monitor']+[f'prefix{i}' for i in range(5)]]
expected += [f'nary.f18.sched.{"".join(map(str,s))}' for s in itertools.permutations(range(3))]
assert len(expected)==len(set(expected))==310 and set(expected)==set(new)
for name in ['Examples','Tests','Audit']:
 b=read(f'lean/DefiKernel/Nary/{name}.lean')
 assert b==read(ev/f'source-snapshot/{name}.lean')==read(cache/f'DefiKernel/Nary/{name}.lean')
 r=jr(ev/'source-hashes-after.json')['files'][f'lean/DefiKernel/Nary/{name}.lean']
 assert sha(b)==r['worktree']==r['private']==r['snapshot']
 assert jr(ev/'private-source-hashes.json')['files'][f'lean/DefiKernel/Nary/{name}.lean']['sha256']==sha(b)
 if name!='Tests':assert b==read(impl/f'fixtures-r2/source-snapshot/{name}.lean')
read(impl/'fixtures-r2/source-snapshot/Tests.lean')
# Recursively resolve every local Lean import; compare actual private source bytes.
closure={};pending=['DefiKernel.Nary.Audit']
while pending:
 mod=pending.pop()
 if mod in closure:continue
 rel=mod.replace('.','/')+'.lean'; p=root/'lean'/rel
 if not p.is_file():continue
 b=read(p);assert b==read(cache/rel),mod
 closure[mod]=sha(b)
 pending += re.findall(r'^import\s+([\w.]+)',b.decode(),re.M)
for forbidden in ['BinaryCorrespondence','Causal','FundedCausal','InterfaceInstances','Interference','Preservation','Soundness','Completion','LocalOrder','Trace']:
 assert 'DefiKernel.Nary.'+forbidden not in closure
assert closure['DefiKernel.Nary.Observation']=='154ac0b69fa1a45197a7e9f435ce3ea472280101dcc1d1880df20f266c7316f0'
for name in ['Schedule','Execution','CausalRuntime']:
 assert closure['DefiKernel.Nary.'+name]==sha(read(impl/f'core-r3/source-snapshot/{name}.lean'))
mutations=jr('openspec/changes/finite-participant-causal-composition/planned-mutations.json')['mutations']
assert len(mutations)==16
needles=[]
for m in mutations:
 b=read(m['path']).decode();assert b.count(m['needle'])==1
 assert all(new[x]=='true' for x in m['required_false']) and new[m['expected_protected_check']]=='true'
 needles.append({'id':m['id'],'needle_count':1,'required_false':m['required_false'],'protected':m['expected_protected_check']})
terminals={}
for lane in ['fixtures-r3','fixtures-r4']:
 identity=jr(impl/f'native-worker/{lane}.json'); assert identity['exit_code']==0
 for record in identity['records']:
  packed=read(record['path']);raw=gzip.decompress(packed)
  assert sha(packed)==record['sha256'] and sha(raw)==record['raw_sha256'] and len(raw)==record['raw_bytes']
  if record['path'].endswith('.jsonl.gz'):
   end=[json.loads(x) for x in raw.splitlines() if json.loads(x).get('type')=='end'][-1]
   assert end['sessionId']=='01a07ed5-e45f-70e2-85f6-c621d2aef4f9' and end['stopReason']=='end_turn'
   assert set(end['modelUsage'])=={'grok-4.6-build'};terminals[lane]=end
 for cmd in jr(impl/lane/'runtime-result.json')['commands']:
  assert cmd['exit']==0
  assert read(impl/lane/cmd.get('status',cmd['stdout'].replace('.stdout','.status'))).strip() in [b'0',b'eval:0',b'build:0']
  assert read(impl/lane/cmd['stderr'])==b''
assert read(ev/'logs/first-pass/eval-Audit.stdout')==read(ev/'logs/eval-Audit.stdout')
prior_false=re.findall(r'^(nary\.[^:]+): false$',read(impl/'fixtures-r2/eval-Audit.attempt1.stdout').decode(),re.M)
assert len(prior_false)==3
# Snapshot all local compiled artifacts before running stdin, not rebuilding them.
artifacts={}
for mod in closure:
 stem=cache/'.lake/build/lib/lean'/mod.replace('.','/')
 for p in stem.parent.glob(stem.name+'.*'):
  if p.is_file():read(p);artifacts[str(p)]=inputs[str(p)]
stdin='import DefiKernel.Nary.Audit\n#eval DefiKernel.Nary.Audit.main\n'
(out/'fixtures-r4-replay.stdin.lean').write_text(stdin)
p=subprocess.run(['lake','env','lean','--stdin'],cwd=cache,input=stdin,text=True,capture_output=True,timeout=55)
(out/'fixtures-r4-replay.stdout').write_text(p.stdout);(out/'fixtures-r4-replay.stderr').write_text(p.stderr)
assert p.returncode==0,(p.returncode,p.stderr,p.stdout[-2000:])
assert rows(p.stdout.encode())==new and p.stdout.encode()==read(ev/'logs/eval-Audit.stdout')
for path,r in inputs.items():
 pth=Path(path);assert sha(pth.read_bytes())==r['sha256'] and pth.stat().st_mtime_ns==r['mtime_ns'],path
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'frozen runtime source and evidence only; read-only imported artifact replay, no build',
 'command':{'argv':['lake','env','lean','--stdin'],'cwd':str(cache),'stdin':stdin,'exit':p.returncode,'stdout_sha256':sha(p.stdout.encode()),'stderr_bytes':len(p.stderr)},
 'manifest_complete':39,'inventory':{'old':288,'r3':298,'final':310,'literal_ids':len(static),'synthetic':2*len(synth),'f10':96,'f18_generated':6,'all_true':True,'all_old_ids_retained':True,'r3_added':sorted(set(r3)-set(old)),'r4_added':sorted(set(new)-set(r3)),'exact_rows':new},
 'runtime_closure':closure,'mutation_contracts':needles,'native_terminal':terminals,'prior_r2_false_preserved':prior_false,
 'input_bytes_and_mtime_unchanged':True,'compiled_artifacts_snapshot_count':len(artifacts),'inputs':inputs,
 'limits':['No fresh rebuild of imported compiled modules','No production mutation execution','No financial proof acceptance','No complete Sprint11 integration verdict'],
 'prior_probe_errors':['Nonexistent mutations.json read failed; corrected to planned-mutations.json','Initial script assumed r3 status key; r3 actual status file derived from logged stdout basename; and labeled eval:0/build:0 status format; corrected before Lean replay']}
(out/'fixtures-r4-inputs.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'manifest':39,'inventory':310,'old_ids_preserved':288,'runtime_closure':len(closure),'inputs_unchanged':len(inputs),'artifacts':len(artifacts),'replay_exit':p.returncode,'stdout_sha256':sha(p.stdout.encode())},indent=2))
