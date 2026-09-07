#!/usr/bin/env python3
"""Offline deterministic text views; no browser/JS execution and no new retrieval."""
import base64, hashlib, json, pathlib
import bs4
BASE=pathlib.Path(__file__).resolve().parent
def sha(b): return hashlib.sha256(b).hexdigest()
def extract(raw, role):
    if role=='git_blob_pinned_readme_envelope':
        d=json.loads(raw); data=base64.b64decode(d['content'])
        git=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
        assert git==d['sha']
        return data, {'method':'GitHub contents envelope /content base64 decoded, verified Git blob hash',
                      'git_blob':git,'git_blob_url':d.get('git_url'),'source_commit':None,
                      'pin_limit':'Immutable blob identity only; default-branch response does not identify commit, release or deployment.'}
    if role=='commit_pinned_repository_readme':
        return raw, {'method':'Identity bytes: UTF-8 repository README retained at commit URL'}
    if role=='repository_commit_metadata': return None,{'method':'Metadata JSON only; no semantic evidence credit'}
    soup=bs4.BeautifulSoup(raw,'html.parser')
    main=soup.find('main') or soup.find('article') or soup
    selected=main.name
    for n in main(['script','style','nav','header','footer']): n.decompose()
    text='\n'.join(s.strip() for s in main.get_text('\n').splitlines() if s.strip())+'\n'
    return text.encode(),{'method':'BeautifulSoup html.parser; first main else article else document; remove script/style/nav/header/footer; get_text newline; strip each nonempty line; append LF',
                          'selected_element':selected,'bs4_version':bs4.__version__,
                          'limit':'Derived text coordinates, not raw HTML coordinates; static content only, no JavaScript or linked sources fetched.'}
if __name__=='__main__':
    records=[]; out=BASE/'text';out.mkdir(exist_ok=False)
    for p in sorted((BASE/'captures').glob('*/capture.json')):
        c=json.loads(p.read_text()); a=c['attempts'][-1]; rawpath=p.parent/f"attempt-{a['attempt']}.body"
        r={k:v for k,v in c.items() if k!='attempts'}
        r.update({'capture_record':str(p.relative_to(BASE)),'capture_record_sha256':sha(p.read_bytes()),'transport_success':a['transport_body_success'],
                  'raw_path':str(rawpath.relative_to(BASE)) if rawpath.exists() else None,
                  'raw_sha256':sha(rawpath.read_bytes()) if rawpath.exists() else None,
                  'attempts':len(c['attempts']),'final_http_status':a['curl'].get('http_code')})
        if a['transport_body_success']:
            data,method=extract(rawpath.read_bytes(),c['role']);r['extraction']=method
            if data is not None:
                dest=out/(c['id']+'.txt');dest.write_bytes(data)
                r.update({'text_path':str(dest.relative_to(BASE)),'text_bytes':len(data),'text_sha256':sha(data)})
        records.append(r)
    with (BASE/'source-index.json').open('x') as f:json.dump(records,f,indent=2);f.write('\n')
    print('sources',len(records),'text views',sum('text_path' in r for r in records))
