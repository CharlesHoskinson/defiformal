from pathlib import Path,PurePosixPath
import json,hashlib,subprocess,datetime,posixpath
r=Path('/home/charl/defiformal');o=Path(__file__).resolve().parent;repo=Path('/home/charl/Moriarty');pin='7307349d0275af6fcb4144e1661d8b59d6b2663a';node=Path('/home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node');ts=Path('/home/charl/.npm-global/lib/node_modules/typescript/lib/typescript.js');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prior=json.loads((r/'review/semantic-kernel/adapters/readiness/p31/manifest.json').read_text());roots=[f['source'] for f in prior['source_files']];pending=roots[:];seen=set();files=[];edges=[];unresolved=[];commands=[];start=datetime.datetime.now(datetime.timezone.utc).isoformat();source=o/'source';source.mkdir(exist_ok=False)
while pending:
 n=pending.pop(0)
 if n in seen:continue
 seen.add(n);assert not n.startswith('../') and not PurePosixPath(n).is_absolute()
 argv=['git','show',pin+':'+n];p=subprocess.run(argv,cwd=repo,capture_output=True);commands.append({'argv':argv,'cwd':str(repo),'exit':p.returncode,'stdout_sha256':hashlib.sha256(p.stdout).hexdigest(),'stderr':p.stderr.decode()})
 if p.returncode:unresolved.append({'path':n,'reason':'git show failed'});continue
 dst=source/n;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(p.stdout);oid=subprocess.check_output(['git','rev-parse',pin+':'+n],cwd=repo,text=True).strip();blob=hashlib.sha1(b'blob '+str(len(p.stdout)).encode()+b'\0'+p.stdout).hexdigest();assert oid==blob
 files.append({'path':n,'bytes':len(p.stdout),'sha256':sha(dst),'git_blob':oid})
 if not n.endswith(('.ts','.tsx','.mts','.cts')):continue
 scan=subprocess.run([str(node),str(o/'scan-imports.cjs')],input=json.dumps({'path':n,'text':p.stdout.decode()}).encode(),capture_output=True);assert scan.returncode==0,scan.stderr.decode();d=json.loads(scan.stdout);assert not d['parse_diagnostics'],d['parse_diagnostics'];unresolved.extend({'from':n,**e} for e in d['unresolved'])
 for e in d['edges']:
  edge={'from':n,**e};specifier=e['specifier']
  if specifier.startswith('.'):
   target=posixpath.normpath(posixpath.join(posixpath.dirname(n),specifier));edge['target']=target;edge['classification']='pinned_relative';pending.append(target)
  elif specifier.startswith('node:'):edge['classification']='node_builtin_host_dependency'
  else:edge['classification']='external_or_absolute';unresolved.append(edge)
  edges.append(edge)
write(o/'commands.json',commands);write(o/'manifest.json',{'schema':'defiformal-p31-source-closure/v1','started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source_pin':pin,'roots':roots,'files':files,'file_count':len(files),'edges':edges,'unresolved':unresolved,'scanner':{'node':str(node),'node_version':subprocess.check_output([str(node),'--version'],text=True).strip(),'node_sha256':sha(node),'typescript_library':str(ts),'typescript_version':d['typescript_version'],'typescript_sha256':sha(ts),'scanner_sha256':sha(o/'scan-imports.cjs'),'capture_sha256':sha(Path(__file__))},'scope':'TypeScript AST static imports/exports, literal dynamic imports/require and new URL resources reachable from13 prior source roots. Does not establish all runtime filesystem or host dependencies, semantic correspondence or adapter acceptance.','acceptance':False});print(json.dumps({'files':len(files),'edges':len(edges),'unresolved':unresolved}));assert not unresolved
