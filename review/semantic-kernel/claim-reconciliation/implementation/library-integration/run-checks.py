#!/usr/bin/env python3
"""Capture actual historical Data export and affected existing-library integration."""
import pathlib,json,hashlib,datetime,subprocess,time
R=pathlib.Path(__file__).resolve().parents[5];B=R/'review/semantic-kernel/claim-reconciliation/implementation';O=B/'data-export-r1';I=B/'library-integration/fresh-r1'
O.mkdir(exist_ok=False);I.mkdir(exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest()
def git(*a):return subprocess.check_output(['git',*a],cwd=R)
C=git('rev-parse','HEAD').decode().strip()
paths=['lean/DefiHistorical/Convex/Data.lean','lean/DefiHistorical/Convex/DataExport.lean','lean/lean-toolchain','lean/lake-manifest.json','lean/lakefile.toml','viz/src/data.ts','formal/v2/tables.mjs']
def snap(ps):
 out={}
 for rel in ps:
  raw=(R/rel).read_bytes();assert raw==git('show',C+':'+rel),rel;out[rel]={'sha256':sha(raw),'bytes':len(raw),'git_blob':git('rev-parse',C+':'+rel).decode().strip()}
 return out
before=snap(paths);tools={}
for name in ['lean','lake']:
 p=pathlib.Path(subprocess.check_output(['lake','env','which',name],cwd=R/'lean',text=True).strip()).resolve();tools[name]={'path':str(p),'sha256':sha(p.read_bytes()),'version':subprocess.check_output([str(p),'--version'],cwd=R/'lean',text=True).strip()}
def run(out,name,argv):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd=R/'lean',capture_output=True,timeout=600);logs={}
 for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
  path=out/(name+label+'.log');path.write_bytes(data);logs[label]={'path':path.name,'sha256':sha(data),'bytes':len(data)}
 record={'command':argv,'cwd':str(R/'lean'),'exit':p.returncode,'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,**logs};(out/(name+'command.json')).write_text(json.dumps(record,indent=2)+'\n');assert p.returncode==0,record;return record,p.stdout
m,raw=run(O,'',['lake','env','lean','DefiHistorical/Convex/DataExport.lean']);payload=json.loads(raw);assert isinstance(payload,dict) and payload['schema_version']==1
p=O/'payload.json';p.write_text(json.dumps(payload,indent=2,ensure_ascii=False)+'\n');freeze=B/'direct-transcription/freeze.json'
m.update({'candidate':C,'source_before':before,'source_after':snap(paths),'tools':tools,'payload':{'path':p.name,'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size},'source_unchanged':before==snap(paths),'transcription_freeze':{'path':str(freeze.relative_to(R)),'sha256':sha(freeze.read_bytes()),'commit':'b3b7bd68fe9af538f7073588b175b7341c2b7462'},'scope':'Actual direct Lean IO export from same Data.edge data used by proof instances, after separate directsourcefreeze. Full comparison and actualm5 thirdcheck are separate.'});(O/'export-record.json').write_text(json.dumps(m,indent=2)+'\n')
print('DataExport PASS',len(payload['symbols']),len(payload['mechanisms']),flush=True)
leanpaths=git('ls-files','-z','lean').decode().strip('\0').split('\0');ibefore=snap(leanpaths);runs=[]
commands=[['lake','build','DefiKernel.Interface.Verify','DefiKernel'],['lake','env','lean','DefiKernel/Interface/Verify.lean'],['lake','env','lean','DefiKernel/Interface/Audit.lean'],['lake','env','lean','DefiKernel/Arithmetic/RuntimeAudit.lean'],['lake','env','lean','DefiKernel/Arithmetic/ProofAudit.lean'],['lake','env','lean','DefiKernel/Arithmetic/Verify.lean'],['lake','env','lean','DefiKernel.lean']]
for n,argv in enumerate(commands):
 record,raw=run(I,f'{n:02d}.',argv);runs.append(record);print(argv[-1],record['exit'],flush=True)
after=snap(leanpaths);assert after==ibefore
report={'status':'PASS','candidate':C,'tools':tools,'source_before':ibefore,'source_after':after,'runs':runs,'source_unchanged':True,'scope':'Fresh affected existing Interface/Arithmetic/root checks after exactunusedthirdlibraryappend. Existingproofandruntimebodybytes unchanged. Earliermutation/controlconfigurationbytes differ and their originalresults retainoldidentities; no blanketwholefileequivalence or newmutationrunclaimed.'};(I/'result.json').write_text(json.dumps(report,indent=2)+'\n');print('INTEGRATION PASS',len(runs),flush=True)
