#!/usr/bin/env python3
"""Assess only this separately captured source-gap pass."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib,json
from bs4 import BeautifulSoup

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def sha(data):return hashlib.sha256(data).hexdigest()
def save(name,obj):
    with (HERE/name).open('x') as out:json.dump(obj,out,ensure_ascii=False,indent=2);out.write('\n')

ASSESSMENTS={
 'unit:lane3:c1:p2': ('source_gap',[],
    'The separate Hegic application URL also failed twice. Search-engine text is only a discovery lead; no new retained page supports identity or version.'),
 'unit:lane3:c2:p3': ('provisional_source_boundary',[
     ('93dc932ee9a321f2',17,25),('d0cef6d101af52cd',32,34),('d0cef6d101af52cd',58,64),
     ('d0cef6d101af52cd',91,103),('d0cef6d101af52cd',112,121)],
    'The 2024 launch article names Paxos Digital Singapore as issuer and Paxos Global as distribution partner. The captured EU whitepaper names Paxos Issuance Europe Oy, distinguishes EEA and non-EEA redemption counterparties, and subjects requests to compliance review. Its page header says June 24, 2026 while its internal date field says2026-05-04; both are retained. It explicitly says the whitepaper has not been approved by a competent EU authority. These are source assertions, not independently verified legal status, enforceability, reserves or current holder eligibility. Do not collapse the token, issuer jurisdictions and distribution network.'),
 'unit:lane3:c3:p2': ('provisional_source_boundary',[
     ('539c1d9ec42a2479',1,2),('539c1d9ec42a2479',16,22),('813a6ee939569a02',1,21)],
    'Azuro documentation describes a pool-based prediction protocol, separate SDK/DAO branches, and configurable Pool/LP/Access/Betting Engine contracts. The original landing shell is still insufficient on its own; these supplemental pages supply the mechanism-level description. No specific release, deployed pool or claimed unrestricted access has been verified. Do not infer every prediction market uses an orderbook.'),
 'unit:lane3:c3:p3': ('provisional_source_boundary',[('e421b739f71cd6a3',8,21)],
    'Steakhouse’s homepage identifies risk-curated Morpho vaults, advisory services and a separate Grove link. It supports a source-scoped curator/product boundary but does not resolve a particular mandate, legal entity, vault deployment, cap or guardian authority. Keep both original Steakhouse rows and their residue until overlap is independently adjudicated.'),
}

def main():
    targets=json.loads((HERE/'targets.json').read_bytes())['units']
    records=json.loads((HERE/'retrievals.json').read_bytes())['records']
    by_id={r['source_id']:r for r in records}
    checks=[]
    def check(name,test):
        checks.append({'check':name,'passed':bool(test)})
        assert test,name
    cards=[]
    for unit in targets:
        status,refs,observation=ASSESSMENTS[unit['unit_id']]
        locators=[]
        for sid,start,end in refs:
            record=by_id[sid];a=record['attempts'][-1];ext=a['extraction']
            data=(ROOT/ext['path']).read_bytes();lines=data.decode().splitlines()
            check('source_for_unit:'+sid,record['requested_url'] in unit['target_urls'])
            check('locator_bounds:'+sid,1<=start<=end<=len(lines))
            excerpt='\n'.join(lines[start-1:end])
            locators.append({'source_id':sid,'requested_url':record['requested_url'],
                'capture_path':a['capture_path'],'capture_sha256':a['body_sha256'],
                'derived_path':ext['path'],'derived_sha256':ext['sha256'],
                'line_start':start,'line_end':end,'excerpt':excerpt,'excerpt_sha256':sha(excerpt.encode())})
        cards.append({**unit,'status':status,'observation':observation,'locators':locators,
            'accepted_identity':False,'verified_deployment':False,'accepted_facet_changes':[],
            'evaluation_role':'development','prior_packet_unchanged':True})
    before=json.loads((HERE/'before.json').read_bytes())
    for path,digest in before['protected'].items():check('protected:'+path,sha((ROOT/path).read_bytes())==digest)
    for record in records:
        check('attempt_budget:'+record['source_id'],1<=len(record['attempts'])<=2)
        for attempt in record['attempts']:
            if attempt['status']=='failed_no_support':continue
            data=(ROOT/attempt['capture_path']).read_bytes()
            check('raw_bytes:'+record['source_id'],sha(data)==attempt['body_sha256'] and len(data)==attempt['body_bytes'])
            ext=attempt.get('extraction')
            if ext:
                out=(ROOT/ext['path']).read_bytes();soup=BeautifulSoup(data,'html.parser')
                for tag in soup(['script','style','noscript','svg']):tag.decompose()
                root=soup.find('main') or soup.find('article') or soup.body or soup
                check('extraction_replay:'+record['source_id'],root.get_text('\n',strip=True).encode()==out and sha(out)==ext['sha256'])
    save('cards.json',{'status':'UNACCEPTED_RESEARCH_SUPPLEMENT','cards':cards})
    save('verification.json',{'status':'PASS_OFFLINE_NOT_ADJUDICATION','utc':datetime.now(timezone.utc).isoformat(),
        'checks':checks,'counts':{'checks':len(checks),'units':len(cards),'urls':len(records),
            'attempts':sum(len(r['attempts']) for r in records),'locators':sum(len(c['locators']) for c in cards),
            'protected_files':len(before['protected'])},'helper_sha256':sha(Path(__file__).read_bytes())})
    print(json.dumps({'checks':len(checks),'units':len(cards),'locators':sum(len(c['locators']) for c in cards)}))

if __name__=='__main__':main()
