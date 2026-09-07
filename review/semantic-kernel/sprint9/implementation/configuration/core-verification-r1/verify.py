#!/usr/bin/env python3
import datetime,hashlib,json,pathlib,re,shutil,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[5];OUT=pathlib.Path(__file__).resolve().parent;LEAN=ROOT/'lean'
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
modules=['Configuration','ConfigurationGroups','OperatorLifting'];paths=[LEAN/'DefiKernel/Metatheory'/f'{m}.lean' for m in modules]
files={};old=[]
def capture(p):
 rel=p.relative_to(ROOT).as_posix()
 if rel in files:return
 files[rel]={'sha256':sha(p),'bytes':p.stat().st_size}
 for name in re.findall(r'^import (DefiKernel\.[A-Za-z0-9_.]+)$',p.read_text(),re.M):
  dep=LEAN/(name.replace('.','/')+'.lean');capture(dep)
for p in paths:capture(p)
for p in [LEAN/'lean-toolchain',LEAN/'lakefile.toml',LEAN/'lake-manifest.json']:
 files[p.relative_to(ROOT).as_posix()]={'sha256':sha(p),'bytes':p.stat().st_size}
base='99e2e2c61a1a3c5249026921efdc6cd41ac8f21d'
for rel,binding in files.items():
 if '/Metatheory/' not in rel:
  data=subprocess.check_output(['git','show',f'{base}:{rel}'],cwd=ROOT)
  assert hashlib.sha256(data).hexdigest()==binding['sha256'],rel
  old.append({'path':rel,'revision':base,'sha256':binding['sha256']})
names=[]
for p in paths:
 source=p.read_text();assert source.count('-- BEGIN PROOFS')==1
 assert not re.search(r'\b(sorry|axiom|native_decide)\b',source),p
 names += ['DefiKernel.Metatheory.'+n for n in re.findall(r'^(?:@\[simp\] )?theorem ([A-Za-z0-9_.]+)',source,re.M)]
assert names and len(names)==len(set(names))
audit=OUT/'Audit.lean';audit.write_text('import DefiKernel.Metatheory.ConfigurationGroups\nimport DefiKernel.Metatheory.OperatorLifting\nimport DefiKernel.AxiomAudit\n\n#audit_axioms DefiKernel.Metatheory\n\n'+'\n'.join('#print axioms '+n for n in names)+'\n')
commands=[]
def run(args,label):
 begin=now();t=time.monotonic();p=subprocess.run(args,cwd=LEAN,capture_output=True,timeout=600)
 stdout=OUT/(label+'.stdout');stderr=OUT/(label+'.stderr');stdout.write_bytes(p.stdout);stderr.write_bytes(p.stderr)
 commands.append({'argv':args,'cwd':str(LEAN),'started_utc':begin,'finished_utc':now(),'wall_seconds':time.monotonic()-t,'timeout_seconds':600,'exit':p.returncode,'stdout':stdout.name,'stdout_sha256':sha(stdout),'stderr':stderr.name,'stderr_sha256':sha(stderr)})
 assert p.returncode==0,(label,p.stdout.decode()[-1000:],p.stderr.decode())
 return p.stdout.decode()
lake=shutil.which('lake');version=run([lake,'env','lean','--version'],'pinned-version')
run([lake,'build',*[f'DefiKernel.Metatheory.{m}' for m in modules]],'build')
output=run([lake,'env','lean',str(audit)],'audit')
for name in names:assert name in output,name
assert 'forbidden=0' in output or 'forbidden 0' in output or 'forbidden: 0' in output,output[-1000:]
for p in paths:run(['/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.5/bin/lean4-skills-sorry-analyzer',str(p),'--report-only','--format=json'],'sorry-'+p.stem)
for rel,binding in files.items():assert sha(ROOT/rel)==binding['sha256'],rel
result={'status':'targeted_author_verification_passed','utc':now(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'own_theorem_names':names,'own_theorem_count':len(names),'source_bindings_before_after':files,'old_inputs_equal_accepted_source':old,'commands':commands,'pinned_version':version.strip(),'gate_sha256':sha(ROOT/'review/semantic-kernel/sprint9/planning/gate.json'),'literal_plugin_preflight':'passed before implementation; LSP used first','scope':'owned generic configuration/group/operator proofs; imported audit also sees actual SequentialGroups dependency; no runtime fixture/mutation/full-project acceptance claim','development_failures':'initial LSP snapshots record missing final rfl/let reduction and getElem helper misuse; all repaired with statements unchanged','model':'requested stock GPT-6; independent build telemetry unavailable','no_foreman':True}
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'own_theorems':len(names),'bound_files':len(files),'old_preserved':len(old),'commands':len(commands),'status':result['status']}))
