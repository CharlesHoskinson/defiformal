from pathlib import Path
import hashlib,json,os,re,subprocess,time

repo=Path('/private/tmp/defiformal-ci-author')
evidence=Path('/private/tmp/defiformal-ci-author-evidence')
lean=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64/bin/lean')
env=os.environ.copy()
env['PATH']=str(lean.parent)+os.pathsep+env.get('PATH','')
env['RUNNER_TEMP']=str(evidence/'runner-temp')
Path(env['RUNNER_TEMP']).mkdir(exist_ok=True)
core=repo/'lean/DefiKernel/Core.lean'
original=core.read_bytes()
records=[]

def digest(data):return hashlib.sha256(data).hexdigest()
def status():
 return subprocess.check_output(['git','status','--porcelain','-uall'],cwd=repo,text=True)
initial_status=status()
workflow=repo/'.github/workflows/lean.yml'
workflow_hash=digest(workflow.read_bytes())
version=subprocess.check_output([str(lean),'--version'],text=True).strip()

def run(label,command):
 started=time.monotonic()
 result=subprocess.run(command,cwd=repo/'lean',env=env,capture_output=True,text=True)
 (evidence/(label+'.log')).write_text(result.stdout+result.stderr)
 record=dict(label=label,command=command,cwd=str(repo/'lean'),returncode=result.returncode,
             elapsed_seconds=time.monotonic()-started,log=label+'.log',core_sha256=digest(core.read_bytes()))
 records.append(record)
 print(json.dumps(record),flush=True)
 (evidence/'production-results.json').write_text(json.dumps(dict(status='running',commands=records),indent=2)+'\n')
 return result

audit=['bash','-e','-o','pipefail',str(evidence/'workflow-step-2.sh')]
result_status='failed'
try:
 before=run('production-build-control',['lake','build'])
 assert before.returncode==0,'unchanged full build failed'
 control=run('production-audit-control',audit)
 assert control.returncode==0,'unchanged production audit failed'
 assert re.search(r'AXIOM AUDIT PASSED: ([1-9][0-9]*)/\1 theorems; forbidden=0',control.stdout), 'nonempty audit success absent'
 core.write_bytes(original+b'\n-- Deliberate isolated CI rejection control; never integrated.\naxiom DefiKernel.CIRejectedAxiom : True\n')
 (evidence/'production-mutant-Core.lean').write_bytes(core.read_bytes())
 compiled=run('production-compile-mutant',['lake','env','lean','-o','.lake/build/lib/lean/DefiKernel/Core.olean','DefiKernel/Core.lean'])
 assert compiled.returncode==0,'mutant must compile before the audit rejects it'
 rejected=run('production-audit-rejected',audit)
 marker='AXIOM AUDIT DECLARATION FORBIDDEN: DefiKernel.CIRejectedAxiom'
 assert rejected.returncode!=0 and marker in rejected.stdout,'production audit failed to reject actual custom axiom'
 rejected_build=run('production-build-rejected',['lake','build'])
 assert rejected_build.returncode!=0 and marker in rejected_build.stdout,'production build failed to reject actual custom axiom'
 result_status='passed'
finally:
 core.write_bytes(original)
 restored_build=run('production-build-restored',['lake','build'])
 restored_audit=run('production-audit-restored',audit)
 restored_status=status()
 source_unchanged=core.read_bytes()==original and workflow_hash==digest(workflow.read_bytes()) and initial_status==restored_status
 if restored_build.returncode or restored_audit.returncode or not source_unchanged:result_status='failed'
 summary=dict(status=result_status,base_revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),
              workflow_sha256=workflow_hash,core_sha256=digest(original),source_unchanged=source_unchanged,
              status_before=initial_status,status_after=restored_status,lean_version=version,
              lean_sha256=digest(lean.read_bytes()),commands=records,
              scope='Local production commands from frozen workflow. GitHub-hosted action execution remains separate. No benchmark timings or full imported dependency rebuild claimed.')
 (evidence/'production-results.json').write_text(json.dumps(summary,indent=2)+'\n')
 print(json.dumps({'status':result_status,'source_unchanged':source_unchanged}),flush=True)
 if result_status!='passed':raise SystemExit(1)
