#!/usr/bin/env python3
"""Offline byte, coordinate and scope checks for a research-only packet."""
from pathlib import Path
import hashlib
import json
import subprocess
from datetime import datetime, timezone
from bs4 import BeautifulSoup

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
checks = []

def sha(data):
    return hashlib.sha256(data).hexdigest()

def check(name, value):
    checks.append({'check':name, 'passed':bool(value)})
    assert value, name

def pointer(value, path):
    for part in path.strip('/').split('/'):
        value = value[int(part)] if isinstance(value,list) else value[part.replace('~1','/').replace('~0','~')]
    return value

def load(path):
    return json.loads(path.read_bytes())

def main():
    units = load(HERE/'selected-units.json')['units']
    cards = load(HERE/'cards.json')['cards']
    queue = load(ROOT/'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json')['remaining'][32:51]
    check('exact19queue_units',[u['unit_id'] for u in units] == [u['unit_id'] for u in queue] and len(units)==19)
    check('exact19cards',[c['unit_id'] for c in cards]==[u['unit_id'] for u in units])
    before = load(HERE/'before.json')
    for path,digest in before['protected'].items():
        check('protected:'+path,sha((ROOT/path).read_bytes())==digest)
    records = load(HERE/'retrievals.json')['records']
    check('26distinct_target_urls',len(records)==26 and len({r['requested_url'] for r in records})==26)
    durations=[]
    observations=[]
    for unit in units:
        check('url_budget:'+unit['unit_id'],0<len(set(unit['target_urls']))<=3)
        original={}
        for key in ['canonical_record','source_row']:
            binding=unit[key]; data=(ROOT/binding['path']).read_bytes()
            check('original_hash:'+unit['unit_id']+key,sha(data)==binding['sha256'] and len(data)==binding['bytes'])
            original[key]=pointer(json.loads(data),binding['pointer'])
        check('original_unit_id:'+unit['unit_id'],original['canonical_record']['unit_id']==unit['unit_id'])
        annotations=[]
        for ref in original['canonical_record']['annotation_refs']:
            data=(ROOT/ref['path']).read_bytes()
            check('annotation_hash:'+unit['unit_id']+ref['annotator_id'],sha(data)==ref['sha256'])
            annotations.append({'binding':ref,'original':pointer(json.loads(data),ref['pointer'])})
        observations.append({'unit_id':unit['unit_id'],'originals':original,'annotations':annotations,
            'status':'EXTRACTIVE_ORIGINAL_CONTEXT_NOT_CHILD_FACET_ASSIGNMENT'})
    for record in records:
        key=record['source_id']
        check('source_id:'+key,sha(record['requested_url'].encode())[:16]==key)
        check('response_record:'+key,load(HERE/'responses'/(key+'.json'))==record)
        check('attempt_budget:'+key,1<=len(record['attempts'])<=2)
        for a in record['attempts']:
            duration=(datetime.fromisoformat(a['finished_utc'])-datetime.fromisoformat(a['started_utc'])).total_seconds()
            durations.append(duration)
            check('positive_attempt_duration:'+key,duration>=0)
            if a['status']=='failed_no_support':
                check('failed_has_error:'+key, bool(a.get('error')))
                continue
            data=(ROOT/a['capture_path']).read_bytes()
            check('capture_bytes:'+key,len(data)==a['body_bytes'] and sha(data)==a['body_sha256'])
            check('body_bound:'+key,len(data)<=5*1024*1024)
            ext=a.get('extraction')
            if ext:
                extracted=(ROOT/ext['path']).read_bytes()
                check('extraction_hash:'+key,sha(extracted)==ext['sha256'] and len(extracted)==ext['bytes'])
                soup=BeautifulSoup(data,'html.parser')
                for tag in soup(['script','style','noscript','svg']): tag.decompose()
                selected=soup.find('main') or soup.find('article') or soup.body or soup
                check('fresh_extraction_replay:'+key,selected.get_text('\n',strip=True).encode()==extracted)
    for card in cards:
        check('unaccepted:'+card['unit_id'],card['accepted_identity'] is False and card['verified_deployment'] is False and card['verified_code_pin'] is False and not card['accepted_facet_changes'])
        check('development_only:'+card['unit_id'],card['evaluation_role']=='development' and card['inherited_facets_from_parent'] is False)
        for locator in card['locators']:
            data=(ROOT/locator['derived_path']).read_bytes()
            check('locator_file:'+card['unit_id'],sha(data)==locator['derived_sha256'])
            lines=data.decode().splitlines();start=locator['line_start'];end=locator['line_end']
            check('locator_bounds:'+card['unit_id'],1<=start<=end<=len(lines))
            excerpt='\n'.join(lines[start-1:end])
            check('locator_exact:'+card['unit_id'],excerpt==locator['excerpt'] and sha(excerpt.encode())==locator['excerpt_sha256'])
    result={'status':'PASS_OFFLINE_PROVENANCE_NOT_FACTUAL_ACCEPTANCE','checks':checks,
        'counts':{'checks':len(checks),'units':len(units),'urls':len(records),
            'attempts':sum(len(r['attempts']) for r in records),'locators':sum(len(c['locators']) for c in cards),
            'failed_targets':sum(r['status']=='failed_no_support' for r in records),
            'protected_files':len(before['protected'])},
        'observed_attempt_seconds':{'min':min(durations),'max':max(durations)},
        'timeout_scope':'urllib timeout30 bounds blocking socket operations, not total wall-clock duration across redirects and reads.',
        'head_before':before['head'],'head_after':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'verified_utc':datetime.now(timezone.utc).isoformat(),'helper_sha256':sha(Path(__file__).read_bytes())}
    for name,value in [('observations.json',{'status':'UNMODIFIED_ORIGINAL_CONTEXT','units':observations}),('verification.json',result)]:
        with (HERE/name).open('x') as handle: json.dump(value,handle,ensure_ascii=False,indent=2);handle.write('\n')
    print(json.dumps({k:v for k,v in result.items() if k!='checks'}))

if __name__=='__main__': main()
