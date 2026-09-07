#!/usr/bin/env python3
"""Bounded research-only captures; not a production corpus collector."""
import concurrent.futures, hashlib, json, pathlib, subprocess, sys, time, datetime
BASE = pathlib.Path(__file__).resolve().parent
ROOT = BASE.parents[4]
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p, obj):
    with p.open('x') as f: json.dump(obj, f, indent=2); f.write('\n')
def capture(t):
    folder = BASE/'captures'/t['id']; folder.mkdir(parents=True, exist_ok=False)
    attempts=[]
    for n in (1,2):
        stem=folder/f'attempt-{n}'
        body=stem.with_suffix('.body'); headers=stem.with_suffix('.headers')
        cmd=['/usr/bin/curl','--location','--max-redirs','5','--max-time','30',
             '--connect-timeout','15','--max-filesize','5242880','--proto','=https',
             '--proto-redir','=https','--header','Accept-Encoding: identity',
             '--user-agent','DeFiFormal-IdentityResearch/1.0 (bounded public-source capture)',
             '--silent','--show-error','--dump-header',str(headers),'--output',str(body),
             '--write-out','%{json}',t['url']]
        start=utc(); tick=time.monotonic()
        try:
            p=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=35)
            rc=p.returncode; out=p.stdout; err=p.stderr
        except subprocess.TimeoutExpired as e:
            rc=124; out=e.stdout or b''; err=(e.stderr or b'')+b'\nOuter 35s process watchdog expired.'
        stem.with_suffix('.stdout').write_bytes(out); stem.with_suffix('.stderr').write_bytes(err)
        try: meta=json.loads(out)
        except Exception: meta={}
        size=body.stat().st_size if body.exists() else 0
        ok=rc==0 and 200<=meta.get('http_code',0)<300 and 0<size<=5242880
        item={'attempt':n,'started_utc':start,'ended_utc':utc(),'wall_seconds':time.monotonic()-tick,
              'command':cmd,'returncode':rc,'curl':meta,'transport_body_success':ok,
              'substantive_status':'requires_manual_inspection' if ok else 'retrieval_failed_no_evidence_credit',
              'files':[{ 'path':str(p.relative_to(BASE)), 'bytes':p.stat().st_size,'sha256':sha(p)}
                       for p in [body,headers,stem.with_suffix('.stdout'),stem.with_suffix('.stderr')] if p.exists()]}
        attempts.append(item); write(stem.with_suffix('.json'),item)
        if ok: break
    result={**t,'attempts':attempts,'accepted':False}; write(folder/'capture.json',result)
    print(t['id'],attempts[-1]['returncode'],attempts[-1]['curl'].get('http_code'),flush=True)
    return result
if __name__=='__main__':
    plan=pathlib.Path(sys.argv[1]); targets=json.loads(plan.read_text())['targets']
    existing=[]
    for p in (BASE/'captures').glob('*/capture.json'): existing.append(json.loads(p.read_text()))
    for unit in {t['unit_id'] for t in targets}:
        urls={t['url'] for t in existing+targets if t['unit_id']==unit}
        assert len(urls)<=3,(unit,len(urls))
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool: list(pool.map(capture,targets))
