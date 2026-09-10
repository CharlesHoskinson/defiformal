from pathlib import Path
import json,hashlib,datetime,subprocess,shutil,re
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p19-precedence-repair-grok-r1';v=o/'root-verification';w=o/'private-lean';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2073996').exists();assert (v/'axioms311-command.json').exists()
commands=json.loads((o/'commands.json').read_text())['commands'];manifest=json.loads((o/'MANIFEST.json').read_text());assert len(manifest['files'])==57
for f in manifest['files']:assert h(o/f['path'])==f['sha256'] and (o/f['path']).stat().st_size==f['bytes']
for c in commands:
 assert c['exit']==0
 assert h(o/c['log'])==c['rawstdout_sha256'];assert h(o/c['stderr'])==c['rawstderr_sha256']
def pairs(text):
 p={n:sorted(x.strip() for x in a.split(',') if x.strip()) for n,a in re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",text,re.S)}
 p.update({n:[] for n in re.findall(r"'([^']+)' does not depend on any axioms",text)});return p
assert pairs((v/'axioms311.stdout').read_text())==pairs((o/'logs/probe-axioms311/stdout').read_text())
tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');checks=[]
for label in ['mixed-six','c0-controls','unterminated','runtime-acceptance']:
 p=v/label;p.mkdir(exist_ok=False);src=o/'probes'/label/'Probe.lean';shutil.copy2(src,p/'Probe.lean');argv=[str(tool/'lake'),'env',str(tool/'lean'),str(p/'Probe.lean')];start=now();x=subprocess.run(argv,cwd=w,capture_output=True,timeout=120);(p/'stdout').write_bytes(x.stdout);(p/'stderr').write_bytes(x.stderr);end=now();expected=h(o/'logs'/('probe-'+label)/'stdout');rec={'started_utc':start,'finished_utc':end,'argv':argv,'cwd':str(w),'exit':x.returncode,'probe_sha256':h(p/'Probe.lean'),'stdout_sha256':h(p/'stdout'),'stderr_sha256':h(p/'stderr'),'expected_stdout_sha256':expected,'matches_reviewer_stdout':h(p/'stdout')==expected,'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),'acceptance':False};put(p/'receipt.json',rec);assert x.returncode==0 and rec['matches_reviewer_stdout'];checks.append({'probe':label,**rec})
put(v/'comparison.json',{'utc':now(),'reviewer_root_axiom_pairs_equal':True,'named_declarations':311,'reviewer_manifest_bindings_verified':57,'reviewer_rawstream_bindings_verified':2*len(commands),'controls':checks,'qualification':'The1048576 probe tests ByteArray.size against the threshold only. It does not call scanLexical/checkBytes at that exact size, so no successful max-size decoding is established.1048577 refusal and four malformed checker outcomes were executed.','acceptance':False})
shutil.copy2('/tmp/defiformal-p19-precedence-repair-root-verify.py',v/'verify-axioms.py');shutil.copy2(__file__,v/'verify-controls.py');put(v/'root-seal.json',{'files':{str(p.relative_to(v)):h(p) for p in v.rglob('*') if p.is_file() and p.name!='root-seal.json'},'acceptance':False});print(json.dumps({'root_names':311,'manifest_bindings':57,'rawstream_bindings':2*len(commands),'control_probes_matching':len(checks)}))
