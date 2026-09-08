#!/usr/bin/env python3
"""Freeze native P01 r3 after terminal completion; do not infer acceptance."""
import datetime,difflib,gzip,hashlib,json,pathlib,subprocess,tarfile
X=pathlib.Path(__file__).resolve().parent
W=pathlib.Path('/home/charl/defiformal-wt-sprint12-grok-gpt6-20260908')
C=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260908')
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
old=json.loads((X/'p01/inputs.json').read_text())
events=[]
for line in (C/'p01-author-r3.jsonl').read_text().splitlines():
    try: events.append(json.loads(line))
    except json.JSONDecodeError: pass
ends=[e for e in events if e.get('type')=='end']
assert len(ends)==1, 'Native author has not returned one terminal event'
terminal=ends[0]
changed=[p for p,v in old['project_import_closure'].items() if h(W/p)!=v]
allowed={'lean/DefiKernel/Nary/Tree/Recovery.lean','lean/DefiKernel/Nary/Tree/RecoveryChecks.lean','lean/DefiKernel/Nary/Tree/Compatibility.lean','lean/DefiKernel/Nary/Tree/DisjointRuntime.lean'}
assert set(changed)<=allowed,changed
for p,v in old['config_hashes'].items():assert h(W/p)==v,p
sources={str(p.relative_to(W)):h(p) for p in sorted((W/'lean/DefiKernel/Nary/Tree').glob('*.lean'))}
assert set(old['tree_files'])<=set(sources)
closure=dict(old['project_import_closure']);closure.update(sources)
# Traverse any new source imports and bind every local imported source.
seen=set(); order=[]
def visit(rel):
    if rel in seen:return
    seen.add(rel);p=W/rel
    for line in p.read_text().splitlines():
        if line.startswith('import '):
            for mod in line[7:].split():
                q=pathlib.Path('lean')/pathlib.Path(*mod.split('.'));q=q.with_suffix('.lean')
                if (W/q).is_file():visit(str(q))
    closure[rel]=h(p);order.append(rel)
for rel in sources:visit(rel)
author=W/'review/semantic-kernel/sprint12/implementation/grok-p01-repair-r3'
assert (author/'REPORT.md').is_file() and (author/'result.json').is_file(),'Author evidence absent'
archive=X/'p01-candidate-r3.tar.gz';assert not archive.exists(),'Do not overwrite frozen archive'
with tarfile.open(archive,'w:gz') as out:
    for rel in sources:out.add(W/rel,arcname=rel)
    for p in sorted(author.rglob('*')):
        if p.is_file():out.add(p,arcname=str(p.relative_to(W)))
diff=[]
with tarfile.open(old['archive']) as prior:
    for rel in changed:
        before=prior.extractfile(rel).read().decode().splitlines(True)
        diff.extend(difflib.unified_diff(before,(W/rel).read_text().splitlines(True),fromfile='r2/'+rel,tofile='r3/'+rel))
(X/'p01-candidate-r3.diff').write_text(''.join(diff))
result={'timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat(),'worktree':str(W),'archive':str(archive),'archive_sha256':h(archive),'native_terminal':terminal,'process_exit':0,'tree_files':sources,'project_import_closure':closure,'dependency_order':order,'config_hashes':old['config_hashes'],'changed_sources':changed,'new_sources':sorted(set(sources)-set(old['tree_files'])),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=W,text=True).strip(),'cache_assignment':'exclusive independent GPT6 re-review; native author finished','prior_review':str(X/'p01/REVIEW.md'),'independent_acceptance':False}
(X/'p01-candidate-r3-manifest.json').write_text(json.dumps(result,indent=2)+'\n')
for ext in ['jsonl','stderr']:
    p=C/('p01-author-r3.'+ext)
    with gzip.open(X/(p.name+'.gz'),'wb') as out:out.write(p.read_bytes())
print(json.dumps({'archive_sha256':result['archive_sha256'],'changed':changed,'new':result['new_sources'],'stop_reason':terminal.get('stopReason')}))
