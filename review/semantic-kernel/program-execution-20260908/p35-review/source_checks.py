from pathlib import Path
import json,subprocess,hashlib,shutil,datetime,gzip
O=Path(__file__).resolve().parent;W=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908'); records=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(label,args,cwd):
 t=datetime.datetime.now(datetime.timezone.utc).isoformat();p=subprocess.run(args,cwd=cwd,capture_output=True,text=True)
 for stream,value in [('stdout',p.stdout),('stderr',p.stderr)]: (O/(label+'.'+stream+'.log')).write_text(value)
 records.append({'label':label,'argv':args,'cwd':str(cwd),'utc':t,'exit_code':p.returncode,'stdout_sha256':sha(O/(label+'.stdout.log')),'stderr_sha256':sha(O/(label+'.stderr.log'))})
 return p
run('conformance',['node','scripts/conformance.mjs'],W/'viz')
run('tsc',['node','node_modules/typescript/bin/tsc','--noEmit'],W/'viz')
run('build-receipt',['node','node_modules/vite/bin/vite.js','build','--outDir',str(O/'rebuilt-dist')],W/'viz')
run('npm-installed',['npm','ls','--all','--json'],W/'viz')
run('node-version',['node','--version'],W/'viz')
run('python-packages',['python3','-m','pip','show','playwright'],W/'viz')
run('print-text',['pdftotext','-layout',str(O/'flat-print.pdf'),str(O/'flat-print.txt')],O)
fix=O/'conformance-fixture'
files=['viz/src/styles.css','viz/src/scene3d.ts','viz/src/main.ts','viz/src/data.ts','viz/package.json','viz/dist/index.html','viz/scripts/conformance.mjs','docs/UNIFIED-DEFI-ELEMENT-TABLE.md']
for f in files:
 (fix/f).parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(W/f,fix/f)
run('fixture-positive',['node','scripts/conformance.mjs'],fix/'viz')
data=fix/'viz/src/data.ts';original=data.read_text();lines=original.splitlines();core=next(i for i,l in enumerate(lines) if 'id: "E001"' in l);cand=next(i for i,l in enumerate(lines) if 'status: "candidate"' in l)
lines[core]=lines[core].replace('status: "core"','status: "candidate"');lines[cand]=lines[cand].replace('status: "candidate"','status: "core"');data.write_text('\n'.join(lines)+'\n')
(O/'status-swap-data.ts').write_text(data.read_text());run('fixture-status-swap',['node','scripts/conformance.mjs'],fix/'viz');data.write_text(original)
doc=fix/'docs/UNIFIED-DEFI-ELEMENT-TABLE.md';md=doc.read_text();doc.write_text(md.replace('| E001 |','| E999 |'));run('fixture-missing-row',['node','scripts/conformance.mjs'],fix/'viz');doc.write_text(md)
run('fixture-restored',['node','scripts/conformance.mjs'],fix/'viz')
records.append({'artifact_sha256':sha(W/'viz/dist/index.html'),'rebuilt_sha256':sha(O/'rebuilt-dist/index.html'),'byte_identical':(W/'viz/dist/index.html').read_bytes()==(O/'rebuilt-dist/index.html').read_bytes(),'raw_bytes':(W/'viz/dist/index.html').stat().st_size,'gzip_bytes_python':len(gzip.compress((W/'viz/dist/index.html').read_bytes()))})
(O/'source-checks.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps(records,indent=2))
