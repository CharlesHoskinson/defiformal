from pathlib import Path
import json,hashlib,subprocess,datetime,shutil,collections
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p31-zkir-artifact-preparation';v=o/'mock-format-validation';v.mkdir(exist_ok=False);tool=Path('/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/zkir');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();original=o/'compiled/loan-harness/zkir/record0.zkir';doc=json.loads(original.read_text());rows=[]
for label in ['valid-record0','invalid-version','invalid-opcode']:
 d=v/label;d.mkdir();p=d/'input.zkir'
 if label=='valid-record0':p.write_bytes(original.read_bytes())
 else:
  data=json.loads(original.read_text())
  if label=='invalid-version':data['version']={'major':999,'minor':0}
  else:data['instructions'][0]['op']='root_invalid_opcode_control'
  p.write_text(json.dumps(data,indent=2)+'\n')
 cmd=[str(tool),'mock-compile',str(p)];start=now()
 try:
  x=subprocess.run(cmd,cwd=d,capture_output=True,timeout=45);code=x.returncode;stdout=x.stdout;stderr=x.stderr;timeout=False
 except subprocess.TimeoutExpired as e:code=None;stdout=e.stdout or b'';stderr=e.stderr or b'';timeout=True
 (d/'stdout.log').write_bytes(stdout);(d/'stderr.log').write_bytes(stderr);artifacts=[{'path':str(q.relative_to(d)),'bytes':q.stat().st_size,'sha256':h(q)} for q in sorted(d.rglob('*')) if q.is_file() and q.name not in ['input.zkir','stdout.log','stderr.log']]
 rec={'label':label,'argv':cmd,'cwd':str(d),'started_utc':start,'finished_utc':now(),'exit':code,'timeout':timeout,'input_sha256':h(p),'stdout_sha256':h(d/'stdout.log'),'stderr_sha256':h(d/'stderr.log'),'artifacts':artifacts,'expected':'accept in mock mode' if label=='valid-record0' else 'reject malformed interface control'};rows.append(rec);write(v/'commands.json',rows);print(json.dumps({'label':label,'exit':code,'stdout':stdout.decode(errors='replace')[:1800],'stderr':stderr.decode(errors='replace')[:1800],'artifacts':artifacts}),flush=True)
formats=[]
for p in sorted((o/'compiled/loan-harness/zkir').glob('*.zkir')):
 d=json.loads(p.read_text());ops=collections.Counter(x['op'] for x in d['instructions']);fields={}
 for ins in d['instructions']:
  fields.setdefault(ins['op'],set()).update(ins)
 formats.append({'path':str(p.relative_to(o)),'sha256':h(p),'top_level_keys':list(d),'version':d['version'],'num_inputs':d['num_inputs'],'instruction_count':len(d['instructions']),'op_counts':dict(sorted(ops.items())),'observed_op_fields':{k:sorted(vals) for k,vals in sorted(fields.items())}})
write(o/'format-observations.json',{'utc':now(),'artifacts':formats,'scope':'Observed generated subset only; not a complete ZKIR opcode schema or semantics.'});write(v/'receipt.json',{'utc':now(),'tool':str(tool),'tool_sha256':h(tool),'tool_version':subprocess.check_output([str(tool),'--version'],text=True).strip(),'commands':rows,'scope':'Native mock compilation and two format rejection controls only. Any emitted files are mock-mode artifacts, not cryptographic proof/key or settlement evidence.','proofs_generated':False,'adapter_accepted':False});shutil.copy2(__file__,v/'verify.py')
