from pathlib import Path
import subprocess,os,time,datetime,json,hashlib
p=Path(__file__).resolve().parent;env=dict(os.environ)
env.update(GOTOOLCHAIN='local',CGO_ENABLED='0',GOBIN=str(p/'bin'),GOPATH=str(p/'gopath'),GOCACHE=str(p/'gocache'),GOMODCACHE=str(p/'gomodcache'),GOPROXY='https://proxy.golang.org',GOSUMDB='sum.golang.org')
a=[str(p/'runtime/go/bin/go'),'install','github.com/ethereum/go-ethereum/cmd/evm@v1.15.11'];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat()
with (p/'build-evm.stdout').open('wb') as o,(p/'build-evm.stderr').open('wb') as e:q=subprocess.run(a,env=env,cwd=p,stdout=o,stderr=e,timeout=600)
(p/'build-evm.json').write_text(json.dumps(dict(argv=a,cwd=str(p),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,environment={k:env[k] for k in ['GOTOOLCHAIN','CGO_ENABLED','GOBIN','GOPATH','GOCACHE','GOMODCACHE','GOPROXY','GOSUMDB']},stdout_sha256=hashlib.sha256((p/'build-evm.stdout').read_bytes()).hexdigest(),stderr_sha256=hashlib.sha256((p/'build-evm.stderr').read_bytes()).hexdigest()),indent=2)+'\n');print('go install exit',q.returncode);raise SystemExit(q.returncode)
