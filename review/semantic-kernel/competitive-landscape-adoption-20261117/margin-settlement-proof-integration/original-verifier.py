from pathlib import Path
import json,hashlib,shutil,gzip,subprocess,datetime,re,os
root=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal');src=Path('/private/tmp/defiformal-amm-package-source');ev=root/'review/semantic-kernel/competitive-landscape-adoption-20261117/margin-settlement-proof-integration';ev.mkdir();fp=Path('/private/tmp/defiformal-margin-settlement-author/PROOF-FREEZE.json');f=json.loads(fp.read_text());shutil.copy2(fp,ev/'PROOF-FREEZE.json')
for row in f['files']:
 p=Path(f['source_root'])/row['path'];assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'] and p.stat().st_size==row['bytes'];q=src/row['path'];q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');env=dict(os.environ,PATH=str(tc/'bin')+':/usr/bin:/bin');audit=ev/'Audit.lean';audit.write_text('import DefiKernel\n#audit_axioms DefiKernel\n');runs=[];counts={};commands=[('build',[str(tc/'bin/lake'),'build']),('controls',[str(tc/'bin/lake'),'env','lean','DefiKernel/Margin/PaymentSettlementAudit.lean']),('audit',[str(tc/'bin/lake'),'env','lean',str(audit)])]
for module in ['Types','PaymentSettlement','PaymentSettlementAudit']:commands.append(('kernel-'+module,[str(tc/'bin/lake'),'env','leanchecker','-v','DefiKernel.Margin.'+module]))
for name,argv in commands:
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();out=subprocess.run(argv,cwd=src/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);data=out.stdout;stored=name+'.log'+('.gz' if len(data)>50000 else '');(ev/stored).write_bytes(gzip.compress(data,mtime=0) if len(data)>50000 else data);runs.append(dict(name=name,argv=argv,cwd=str(src/'lean'),started_utc=start,exit=out.returncode,raw_sha256=hashlib.sha256(data).hexdigest(),raw_bytes=len(data),stored=stored));assert out.returncode==0,(name,data[-1500:])
 if name=='controls':
  m=re.search(rb'MARGIN_SETTLEMENT_CONTROL PASSED (\d+)/(\d+)',data);assert m and m[1]==m[2] and int(m[1])==22;counts['native_controls']=int(m[1])
 if name=='audit':
  for key,pattern in [('theorems',r'AXIOM AUDIT PASSED: (\d+)/(\d+) theorems; forbidden=0'),('supplemental_declarations',r'AXIOM AUDIT DECLARATIONS PASSED: (\d+)/(\d+) supplemental declarations; forbidden=0')]:
   m=re.search(pattern,data.decode());assert m and m[1]==m[2] and int(m[1])>0;counts[key]=int(m[1])
 print(name,'PASS',flush=True)
(ev/'result.json').write_text(json.dumps(dict(status='PASS',author_baseline=f['baseline'],integration_baseline=subprocess.check_output(['git','rev-parse','HEAD'],cwd=src,text=True).strip(),files=f['files'],runs=runs,counts=counts,forbidden_dependencies=0,scope='Exact frozen actual Typed payment primitive; fresh source controls, full build/root audit and three kernel targets; no completed liquidation or universal source correspondence claim'),indent=2)+'\n');print(counts,flush=True)
