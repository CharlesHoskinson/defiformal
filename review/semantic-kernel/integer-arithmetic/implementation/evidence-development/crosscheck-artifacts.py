#!/usr/bin/env python3
"""Reconcile original copy bindings and copied-artifact archives without replaying Lean."""
from pathlib import Path
import hashlib,json,tarfile
R=Path(__file__).resolve().parents[5];B=R/'review/semantic-kernel/integer-arithmetic'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
for root in [B/'mutations-r1',B/'implementation/runner-controls-r1']:
 manifest=json.loads((root/'import-manifest.json').read_text());n=0
 for item in manifest['copied_files']:
  p=root/item['path'];assert p.is_file() and not p.is_symlink()
  assert sha(p)==item['sha256'] and p.stat().st_size==item['bytes'];n+=1
 write(root/'artifact-crosscheck.json',{'status':'PASS','copied_regular_files':n,'manifest_sha256':sha(root/'import-manifest.json'),'execution_candidate':manifest['actual_execution_candidate'],'checker_sha256':sha(Path(__file__)),'scope':'Every imported original regular artifact remains byte-identical. Derived reports are separately inventoried.'})
for rev in ['r1','r2']:
 root=B/'implementation/evidence-development'/('artifact-controls-'+rev)
 inventory=json.loads((root/'copied-artifact-inventory.json').read_text());n=0
 for case in ['unchanged','A01','A02','A03','A04']:
  rows=[r for r in inventory if r['case']==case]
  with tarfile.open(root/case/'copied-artifacts.tar.gz') as tf:
   assert len(tf.getmembers())==len(rows)
   for row in rows:
    raw=tf.extractfile(row['path']).read();assert hashlib.sha256(raw).hexdigest()==row['sha256'] and len(raw)==row['bytes'];n+=1
 results=json.loads((root/'results.json').read_text())
 if rev=='r2':assert len(results['cases'])==5 and all(c['passed'] for c in results['cases'])
 write(root/'archive-crosscheck.json',{'status':'PASS','archived_regular_files':n,'control_verdict':'PASS' if rev=='r2' else 'RETAINED_FAILED_METADATA_ATTEMPT','checker_sha256':sha(Path(__file__))})
print('PASS: all imported bytes and both archived copied-artifact attempts')
