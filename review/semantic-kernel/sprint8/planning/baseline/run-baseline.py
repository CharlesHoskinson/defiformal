#!/usr/bin/env python3
"""Fresh pre-Atomic baseline; source and execution identity survive unrelated metadata commits."""
from pathlib import Path
import datetime,hashlib,json,os,re,shutil,subprocess,sys,time
R=Path('/home/charl/defiformal');O=R/'review/semantic-kernel/sprint8/planning/baseline'
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def out(argv,cwd=R):return subprocess.check_output(argv,cwd=cwd,text=True).strip()
def save(name,value):(O/name).write_text(json.dumps(value,indent=2)+'\n')
def capture(revision,paths):
 objects={}
 for row in subprocess.check_output(['git','ls-tree','-rz',revision],cwd=R).split(b'\0'):
  if row:
   meta,path=row.split(b'\t',1);objects[path.decode()]=meta.split()[2].decode()
 result={}
 for path in paths:
  raw=(R/path).read_bytes();blob=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
  result[path]={'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw),'git_blob':objects.get(path),'observed_git_blob':blob,'matches_revision':blob==objects.get(path)}
 if not result or not all(x['matches_revision'] for x in result.values()):raise RuntimeError('Nonempty frozen input binding failed')
 return result

def main():
 if (O/'lean-runs.json').exists():raise RuntimeError('Refusing to overwrite baseline execution')
 head=out(['git','rev-parse','HEAD']);allpaths=out(['git','ls-files']).splitlines()
 paths=sorted({p for p in allpaths if p.startswith(('lean/','scripts/','corpus/','corpus50/')) or (p.endswith('.lean') and not p.startswith('review/'))}|{f'review/semantic-kernel/sprint{s}/mutation-spec.json' for s in [4,5,6,7]})
 before=capture(head,paths);save('source-binding-before.json',before)
 (O/'git-status-before.log').write_text(out(['git','status','--porcelain','--untracked-files=all'])+'\n')
 if (R/'lean/DefiKernel/Atomic').exists() or (R/'scripts/check_atomic_mutations.py').exists():raise RuntimeError('Atomic implementation already exists')
 lean=Path(out(['lake','env','which','lean'],R/'lean'));lake=Path(out(['lake','env','which','lake'],R/'lean'));git=Path(shutil.which('git'))
 tools={'python_version':sys.version,'python_executable':sys.executable,'python_executable_sha256':sha(Path(sys.executable)),'lean_version':out([str(lean),'--version']),'lean_executable':str(lean),'lean_executable_sha256':sha(lean),'lake_version':out([str(lake),'--version']),'lake_executable':str(lake),'lake_executable_sha256':sha(lake),'git_version':out([str(git),'--version']),'git_executable':str(git),'git_executable_sha256':sha(git),'orchestrator_sha256':sha(Path(__file__))}
 reference=json.loads((R/'review/semantic-kernel/sprint7/integration-final/lean-runs.json').read_text());commands=[r['argv'] for r in reference['runs']]
 if len(commands)!=12:raise RuntimeError('Expected exactly12 inherited commands')
 record={'actual_initial_revision':head,'accepted_source_context':'bea105ec72e633a2dd66c663b96d0b552e1814a8','started_utc':now(),'commands_expected':12,'source_file_count':len(before),'tools':tools,'runs':[],'no_atomic_implementation_before':True}
 save('lean-runs.json',record)
 for index,argv in enumerate(commands):
  label=f'{index:02}';start=now();starthead=out(['git','rev-parse','HEAD']);t=time.monotonic();p=subprocess.run(argv,cwd=R/'lean',capture_output=True)
  stdout=O/(label+'.stdout.log');stderr=O/(label+'.stderr.log');log=O/(label+'.log');stdout.write_bytes(p.stdout);stderr.write_bytes(p.stderr);log.write_bytes(p.stdout+p.stderr)
  row={'argv':argv,'cwd':str(R/'lean'),'started_utc':start,'finished_utc':now(),'elapsed_seconds':round(time.monotonic()-t,3),'exit':p.returncode,'head_at_start':starthead,'head_at_end':out(['git','rev-parse','HEAD']),'stdout':stdout.name,'stderr':stderr.name,'log':log.name,'stdout_sha256':sha(stdout),'stderr_sha256':sha(stderr),'log_sha256':sha(log),'combined_order':'stdout then stderr'};record['runs'].append(row);save('lean-runs.json',record);print(label,p.returncode,' '.join(argv),flush=True)
 endhead=out(['git','rev-parse','HEAD']);after=capture(endhead,paths);save('source-binding-after.json',after)
 # Compare source bytes across execution even if a concurrent metadata-only commit advanced HEAD.
 stable=all(before[p]['sha256']==after[p]['sha256'] and before[p]['git_blob']==after[p]['git_blob'] for p in paths)
 (O/'git-status-after.log').write_text(out(['git','status','--porcelain','--untracked-files=all'])+'\n')
 record.update({'actual_final_revision':endhead,'finished_utc':now(),'source_unchanged':stable,'all_commands_exit_zero':len(record['runs'])==12 and all(x['exit']==0 for x in record['runs']),'no_atomic_implementation_after':not (R/'lean/DefiKernel/Atomic').exists(),'source_binding_before_sha256':sha(O/'source-binding-before.json'),'source_binding_after_sha256':sha(O/'source-binding-after.json')})
 revisions=sorted({head,endhead}|{r[k] for r in record['runs'] for k in ['head_at_start','head_at_end']});record['observed_revisions']=revisions;record['all_observed_revisions_have_exact_same_source_blobs']=all(capture(rev,paths)==before for rev in revisions)
 if head!=endhead:record['concurrent_git_changes']=out(['git','diff','--name-status',head,endhead]).splitlines()
 save('lean-runs.json',record)
 print('BASELINE COMMANDS COMPLETE',record['all_commands_exit_zero'],'sources stable',stable,flush=True)
 return 0 if record['all_commands_exit_zero'] and stable and record['no_atomic_implementation_after'] else 1
if __name__=='__main__':sys.exit(main())
