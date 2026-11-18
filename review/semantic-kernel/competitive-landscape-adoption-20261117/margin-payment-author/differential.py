from pathlib import Path
import json,hashlib
p=Path(__file__).resolve().parent;s=p/'source-helper';raw=(p/'fresh-controls.log').read_bytes();text=raw.decode();inputs={};outputs={}
for line in text.splitlines():
 if line.startswith('PAYMENT_NATIVE_INPUT '):
  _,name,values=line.split();assert name not in inputs;inputs[name]=[int(x) for x in values.split(',')]
 if line.startswith('PAYMENT_NATIVE_CASE '):
  _,name,values=line.split();assert name not in outputs;outputs[name]=[int(x) for x in values.split(',')]
assert len(inputs)==len(outputs)==9 and set(inputs)==set(outputs)
source=json.loads((s/'campaign.json').read_text());rows=[]
for row in source['runs']:
 if not row['name'] in inputs:continue
 d=s/'invocations'/row['name'];stdout=(d/'stdout.bin').read_bytes();stderr=(d/'stderr.bin').read_bytes();assert hashlib.sha256(stdout).hexdigest()==row['stdout_sha256'] and hashlib.sha256(stderr).hexdigest()==row['stderr_sha256'];assert not stderr and row['classification']=='successful_helper_value';value=stdout.decode().strip();assert value.startswith('0x') and len(bytes.fromhex(value[2:]))==192;actual=[int(value[2+i:2+i+64],16) for i in range(0,384,64)];assert actual==row['actual']==outputs[row['name']] and row['arguments']==inputs[row['name']];rows.append(dict(name=row['name'],input=inputs[row['name']],source_actual=actual,native_actual=outputs[row['name']],source_record_sha256=hashlib.sha256((d/'record.json').read_bytes()).hexdigest()))
assert len(rows)==9
(p/'differential.json').write_text(json.dumps(dict(status='PASS',actual_payment_pairs=9,rows=rows,native_log_sha256=hashlib.sha256(raw).hexdigest(),source_campaign_sha256=hashlib.sha256((s/'campaign.json').read_bytes()).hexdigest(),scope='Nine exact actual NativePayment/EVM-helper input-output pairs only. Funding observations and arithmetic failures separate; not universal source refinement or full handler execution'),indent=2)+'\n');print('PASS 9/9 exact actual native/source payment input-output pairs')
