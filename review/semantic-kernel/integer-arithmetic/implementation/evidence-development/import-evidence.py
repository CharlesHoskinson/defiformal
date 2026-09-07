#!/usr/bin/env python3
"""Copy finished actual run artifacts hash-exactly, without nested Git trees or symlinks."""
import argparse,hashlib,json,os,tarfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--external',type=Path,required=True);p.add_argument('--dest',type=Path,required=True);a=p.parse_args()
x=a.external.resolve();d=a.dest.resolve();assert not d.exists();inv=json.loads((x/'invocation.json').read_text());assert inv['status']=='FINISHED' and inv['actual_exit']==0
assert inv['git_head_unchanged'] and all(inv['inputs_unchanged'].values());d.mkdir(parents=True)
sha=lambda b:hashlib.sha256(b).hexdigest();copied=[];excluded=[]
def copy(old,new):
 raw=old.read_bytes();new.parent.mkdir(parents=True,exist_ok=True);new.write_bytes(raw);assert new.read_bytes()==raw
 copied.append({'path':str(new.relative_to(d)),'original_path':str(old),'sha256':sha(raw),'bytes':len(raw)})
for base,dirs,files in os.walk(x/'run',followlinks=False):
 base=Path(base)
 for name in list(dirs):
  path=base/name
  if name=='.git' or path.is_symlink():
   archive=None
   if name=='.git' and not path.is_symlink():
    archive=str(path.relative_to(x/'run')).replace('/','-')+'.tar.gz'
    with tarfile.open(d/archive,'w:gz') as t:t.add(path,arcname='fixture-git')
   excluded.append({'path':str(path),'archive':archive,'reason':'nested Git archived' if archive else 'symlink not followed','target':os.readlink(path) if path.is_symlink() else None});dirs.remove(name)
 for name in files:
  path=base/name
  if path.is_symlink():excluded.append({'path':str(path),'reason':'symlink not followed','target':os.readlink(path)});continue
  copy(path,d/path.relative_to(x/'run'))
copy(x/'invocation.json',d/'invocation.json')
for label in ['stdout','stderr']:
 assert sha((x/(label+'.log')).read_bytes())==inv[label+'_sha256'];copy(x/(label+'.log'),d/('suite.'+label+'.log'))
manifest={'kind':inv['kind'],'actual_execution_candidate':inv['frozen_source'],'original_run_root':str(x/'run'),'original_external_root':str(x),'copied_files':copied,'excluded':excluded,'importer_sha256':sha(Path(__file__).read_bytes()),'status':'HASH_EXACT_COPY_NOT_SEMANTIC_ACCEPTANCE'}
(d/'import-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'files':len(copied),'excluded':len(excluded),'dest':str(d)}))
