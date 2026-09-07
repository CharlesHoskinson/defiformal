#!/usr/bin/env python3
"""Extractive coverage index for unaccepted identity research."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib,json,subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
BASE=HERE.parent
def sha(data):return hashlib.sha256(data).hexdigest()
def load(p):return json.loads(p.read_bytes())
def binding(p):
    b=p.read_bytes();return {'path':str(p.relative_to(ROOT)),'sha256':sha(b),'bytes':len(b)}
def save(name,value):
    with (HERE/name).open('x') as f:json.dump(value,f,ensure_ascii=False,indent=2);f.write('\n')

def main():
    queue_path=BASE.parent/'source-research/consolidated-01/remaining-research-queue.json'
    queue=load(queue_path);remaining=queue['remaining']
    cards=[];checks=[]
    def check(name,test):
        checks.append({'check':name,'passed':bool(test)});assert test,name
    one=BASE/'batch01'
    for row in load(one/'identity-index.json')['units']:
        p=one/row['card'];c=load(p)
        check('batch01_unaccepted:'+c['unit_id'],c['accepted'] is False and c['identity_resolved'] is False and c['deployment_verified'] is False)
        cards.append({'unit_id':c['unit_id'],'label':c['original_label'],'card':binding(p),'pointer':'',
            'proposed_boundary':c['identity_candidate'],'remaining_gaps':c['gaps'],'accepted':False})
    p=BASE/'batch02/provisional-cards.json'
    for n,c in enumerate(load(p)['cards']):
        check('batch02_unaccepted:'+c['unit_id'],c['identity_accepted'] is False and c['deployment_verified'] is False)
        cards.append({'unit_id':c['unit_id'],'label':c['original_label'],'card':binding(p),'pointer':f'/cards/{n}',
            'proposed_boundary':c['proposed_product_scope'],'remaining_gaps':c['remaining_gaps'],'accepted':False})
    p=BASE/'batch03/cards.json'
    for n,c in enumerate(load(p)['cards']):
        check('batch03_unaccepted:'+c['unit_id'],c['accepted_identity'] is False and c['verified_deployment'] is False)
        cards.append({'unit_id':c['unit_id'],'label':c['original_label'],'card':binding(p),'pointer':f'/cards/{n}',
            'proposed_boundary':c['proposed_boundary'],'remaining_gaps':c['unresolved_residue'],'accepted':False})
    check('exact51ordered_queue_cover',[c['unit_id'] for c in cards]==[q['unit_id'] for q in remaining] and len(cards)==51)
    check('unique51units',len({c['unit_id'] for c in cards})==51)
    supplement=BASE/'supplement01/cards.json'
    for n,c in enumerate(load(supplement)['cards']):
        target=next(x for x in cards if x['unit_id']==c['unit_id'])
        target.setdefault('supplements',[]).append({'card':binding(supplement),'pointer':f'/cards/{n}',
            'status':c['status'],'observation':c['observation'],'accepted':False})
    artifacts=[]
    for batch in ['batch01','batch02','batch03','supplement01']:
        manifest=BASE/batch/'artifact-manifest.json';m=load(manifest)
        entries=m.get('files',m.get('artifacts',[]))
        check('nonempty_manifest:'+batch,bool(entries))
        for row in entries:
            p=ROOT/row['path']
            if not p.is_file():p=BASE/batch/row['path']
            check('artifact:'+str(p.relative_to(ROOT)),p.is_file() and sha(p.read_bytes())==row['sha256'])
        artifacts.append({'batch':batch,'manifest':binding(manifest),'report':binding(BASE/batch/'REPORT.md')})
    # Preserve overlapping URL observations rather than treating them as independent sources.
    captures=[]
    for r in load(one/'source-index.json'):
        captures.append({'batch':'batch01','url':r['url'],'attempts':r['attempts'],'capture_record':str((one/r['capture_record']).relative_to(ROOT))})
    for p in sorted((BASE/'batch02/captures').glob('*/capture.json')):
        r=load(p);captures.append({'batch':'batch02','url':r['url'],'attempts':len(r['attempts']),'capture_record':str(p.relative_to(ROOT))})
    for batch in ['batch03','supplement01']:
        for r in load(BASE/batch/'retrievals.json')['records']:
            captures.append({'batch':batch,'url':r['requested_url'],'attempts':len(r['attempts']),
                'capture_record':str((BASE/batch/'responses'/(r['source_id']+'.json')).relative_to(ROOT))})
    groups={}
    for row in captures:groups.setdefault(row['url'],[]).append(row)
    counts={'original_development_units':75,'previous_dispute_packet_units':len(queue['covered_but_unaccepted']),
        'new_identity_card_units':len(cards),'supplemental_unit_observations':4,
        'capture_target_occurrences':len(captures),'distinct_requested_urls':len(groups),
        'attempts':sum(r['attempts'] for r in captures),'accepted_identities':0,'verified_deployments':0}
    check('all75have_research_packet',counts['previous_dispute_packet_units']==24 and len(cards)==51)
    save('index.json',{'status':'RESEARCH_COVERAGE_NOT_IDENTITY_ACCEPTANCE','queue_binding':binding(queue_path),
        'counts':counts,'cards':cards,'artifact_sets':artifacts,
        'scope':'The 24 earlier dispute-packet units are not certified complete identity cards. All original75 remain development and unresolved wherever their source/version/deployment obligations remain unmet.'})
    save('capture-index.json',{'status':'SOURCE_OBSERVATIONS_NOT_INDEPENDENT_CORROBORATION','records':captures,
        'duplicate_requested_url_groups':{u:v for u,v in groups.items() if len(v)>1}})
    for name in ['review/semantic-kernel/sprint10/planning/r2-candidate.json',
                 'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/manifest.json']:
        for row in load(ROOT/name)['inputs']:check('held:'+row['path'],sha((ROOT/row['path']).read_bytes())==row['sha256'])
    save('verification.json',{'status':'PASS_EXTRACTIVE_COVERAGE','utc':datetime.now(timezone.utc).isoformat(),
        'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'checks':checks,
        'check_count':len(checks),'counts':counts,'helper_sha256':sha(Path(__file__).read_bytes())})
    print(json.dumps({'checks':len(checks),**counts}))

if __name__=='__main__':main()
