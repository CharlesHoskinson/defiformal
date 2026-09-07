#!/usr/bin/env python3
"""Finite offline verification of batch01 evidence, not financial truth."""
import collections, datetime, hashlib, importlib.util, json, pathlib, subprocess, sys
BASE=pathlib.Path(__file__).resolve().parent
ROOT=BASE.parents[4]
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):return json.loads(p.read_text())
def write(name,obj):
    with (BASE/name).open('x') as f:json.dump(obj,f,indent=2);f.write('\n')
checks=[]
def check(name,ok):
    checks.append({'name':name,'passed':bool(ok)})
    if not ok: raise AssertionError(name)
def pointer(v,p):
    for k in p.strip('/').split('/'):
        k=k.replace('~1','/').replace('~0','~');v=v[int(k)] if isinstance(v,list) else v[k]
    return v
before=read(BASE/'protection-before.json')
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
after=[]
for old in before['paths']:
    p=ROOT/old['path'];current=sha(p.read_bytes())
    check('protected-bytes:'+old['path'],current==old['sha256'])
    obj=subprocess.run(['git','rev-parse',f"{head}:{old['path']}"],cwd=ROOT,text=True,capture_output=True)
    git=obj.stdout.strip() if obj.returncode==0 else None
    if git:
        data=subprocess.check_output(['git','cat-file','blob',git],cwd=ROOT)
        check('after-git-object:'+old['path'],sha(data)==current)
    if old['git_blob_at_head']:
        data=subprocess.check_output(['git','cat-file','blob',old['git_blob_at_head']],cwd=ROOT)
        check('before-git-object:'+old['path'],sha(data)==old['sha256'])
    after.append({'path':old['path'],'sha256':current,'bytes':p.stat().st_size,'git_blob_at_head':git})
write('protection-after.json',{'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':head,
       'head_before':before['head'],'head_moved':head!=before['head'],'paths':after,
       'interpretation':'Git HEAD may move for unrelated commits. Claims remain bound to actual capture times and immutable retained bytes; no run is relabelled.'})
manifest=read(ROOT/'review/semantic-kernel/sprint10/planning/r2-candidate.json')
check('S10-exact-input-count',len(manifest['inputs'])==88)
for x in manifest['inputs']:check('S10:'+x['path'],sha((ROOT/x['path']).read_bytes())==x['sha256'])
selected=read(BASE/'selected-units.json'); queue_path=ROOT/selected['queue_path'];queue=read(queue_path)
check('queue-bytes',sha(queue_path.read_bytes())==selected['queue_sha256'])
check('actual-ordered-first16',[u['queue'] for u in selected['units']]==queue['remaining'][:16])
check('unique-selected-units',len({u['queue']['unit_id'] for u in selected['units']})==16)
for u in selected['units']:
    q=u['queue']; src=q['source_row_metadata'];raw=ROOT/src['source_path']
    check('original-row-hash:'+q['unit_id'],sha(raw.read_bytes())==src['source_sha256'])
    check('original-row-pointer:'+q['unit_id'],pointer(read(raw),src['pointer'])==u['original_row'])
    canonical=q['canonical_record']; p=ROOT/canonical['path']
    check('canonical-hash:'+q['unit_id'],sha(p.read_bytes())==canonical['sha256'])
    record=pointer(read(p),canonical['pointer'])
    check('canonical-unit-pointer:'+q['unit_id'],record['unit_id']==q['unit_id'])
spec=importlib.util.spec_from_file_location('extract_batch01',BASE/'extract.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
sources=read(BASE/'source-index.json'); captures=[]; targets=[]; attempts=[]
for p in sorted(BASE.glob('pass*-plan.json')):targets+=read(p)['targets']
check('nonempty-targets',len(targets)>0)
check('source-target-ID-set',{s['id'] for s in sources}=={t['id'] for t in targets})
check('unique-target-identities',len({t['id'] for t in targets})==len(targets))
for u in selected['units']:
    own=[t for t in targets if t['unit_id']==u['queue']['unit_id']]
    check('bounded-three-targets:'+u['queue']['unit_id'],0<len({t['url'] for t in own})<=3)
for s in sources:
    cp=BASE/s['capture_record'];check('capture-record-hash:'+s['id'],sha(cp.read_bytes())==s['capture_record_sha256'])
    c=read(cp);captures.append(c);check('attempt-bound:'+s['id'],1<=len(c['attempts'])<=2)
    for a in c['attempts']:
        attempts.append(a); cmd=a['command']; key=s['id']+':'+str(a['attempt'])
        for flag,value in [('--max-redirs','5'),('--max-time','30'),('--max-filesize','5242880'),('--proto','=https'),('--proto-redir','=https')]:
            check('command-bound:'+key+flag,cmd[cmd.index(flag)+1]==value)
        check('actual-redirect-bound:'+key,a['curl'].get('num_redirects',0)<=5)
        for f in a['files']:
            raw=(BASE/f['path']).read_bytes();check('capture-file:'+f['path'],sha(raw)==f['sha256'] and len(raw)==f['bytes'])
            if f['path'].endswith('.body'):check('actual-body-bound:'+key,len(raw)<=5242880)
        status=a['curl'].get('http_code',0)
        if a['transport_body_success']:check('transport-success-status:'+key,a['returncode']==0 and 200<=status<300)
    if 'text_path' in s:
        raw=(BASE/s['raw_path']).read_bytes();data,recipe=module.extract(raw,s['role'])
        check('extraction-replay:'+s['id'],data==(BASE/s['text_path']).read_bytes() and sha(data)==s['text_sha256'])
        check('extraction-recipe:'+s['id'],recipe==s['extraction'])
    if s.get('commit'):
        meta=read(BASE/s['commit_source']);ma=meta['attempts'][-1]
        raw=read(BASE/pathlib.Path(s['commit_source']).parent/f"attempt-{ma['attempt']}.body")
        check('commit-pin:'+s['id'],raw['sha']==s['commit'] and '/'+s['commit']+'/' in s['url'])
cards=[read(p) for p in sorted((BASE/'cards').glob('*.json'))]
check('finite-card-coverage',[c['unit_id'] for c in cards]==[u['queue']['unit_id'] for u in selected['units']])
for c in cards:
    check('unaccepted:'+c['unit_id'],not c['accepted'] and not c['identity_resolved'] and not c['deployment_verified'] and c['annotation_disposition']=='not_performed')
    check('nonempty-source-readings:'+c['unit_id'],len(c['claims'])>0)
    for claim in c['claims']:
        l=claim['locator'];raw=(BASE/l['path']).read_bytes();span=raw[l['byte_start']:l['byte_end_exclusive']]
        check('locator-quote:'+claim['id'],span==l['quote'].encode())
        check('locator-hashes:'+claim['id'],sha(raw)==l['sha256'] and sha(span)==l['span_sha256'] and sha(raw[l['context_start']:l['context_end_exclusive']])==l['context_sha256'])
        check('locator-lines:'+claim['id'],raw[:l['byte_start']].count(b'\n')+1==l['line_start'] and raw[:l['byte_end_exclusive']].count(b'\n')+1==l['line_end'])
tools=read(BASE/'tools-before.json')
check('curl-executable-unchanged',sha(pathlib.Path('/usr/bin/curl').read_bytes())==tools['curl_sha256'])
check('python-executable-unchanged',sha(pathlib.Path(sys.executable).read_bytes())==tools['python_sha256'])
check('capture-driver-unchanged',sha((BASE/'capture.py').read_bytes())==tools['capture_script_sha256'])
summary={'units':len(cards),'targets':len(targets),'attempts':len(attempts),
         'failed_targets':sum(not c['attempts'][-1]['transport_body_success'] for c in captures),
         'failed_attempts':sum(not a['transport_body_success'] for a in attempts),
         'text_views':sum('text_path' in s for s in sources),'claim_locators':sum(len(c['claims']) for c in cards),
         'commit_pinned_readmes':sum(s['role']=='commit_pinned_repository_readme' and s['transport_success'] for s in sources),
         'git_blob_pinned_readmes':sum(s['role']=='git_blob_pinned_readme_envelope' and s['transport_success'] for s in sources),
         'capture_categories':dict(collections.Counter(s['category'] for s in read(BASE/'source-assessment.json'))),
         'protected_paths':len(before['paths']),'S10_protected_inputs':len(manifest['inputs'])}
result={'status':'PASS','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks_passed':len(checks),
        'checks':checks,'summary':summary,'head_before':before['head'],'head_after':head,'head_moved':head!=before['head'],
        'accepted':False,'scope':'Offline evidence consistency and retrieval bounds only; not identity acceptance, annotation correctness or deployment fidelity.',
        'command':[sys.executable,str(pathlib.Path(__file__).resolve())],'script_sha256':sha(pathlib.Path(__file__).read_bytes())}
write('verification.json',result)
print(json.dumps({'status':'PASS','checks':len(checks),**summary},indent=2))
