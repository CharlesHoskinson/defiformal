#!/usr/bin/env python3
"""Author research index from retained bytes. No annotation decisions."""
import datetime, hashlib, json, pathlib
BASE=pathlib.Path(__file__).resolve().parent
def sha(data): return hashlib.sha256(data).hexdigest()
def write(name,obj):
    with (BASE/name).open('x') as f: json.dump(obj,f,indent=2);f.write('\n')
units=json.loads((BASE/'selected-units.json').read_text())['units']
sources=json.loads((BASE/'source-index.json').read_text()); source_map={s['id']:s for s in sources}
content=json.loads((BASE/'card-content.json').read_text())
assert len(units)==len(content)==16
# Validate literal anchors before writing any generated cards.
for card in content:
    for sid,quote,claim in card['claims']:
        raw=(BASE/source_map[sid]['text_path']).read_bytes()
        assert quote.encode() in raw,(card['ordinal'],sid,quote)
assessed=[]
pointer_only={'u02-s1','u03-s1','u10-s1','u12-s3'}
for s in sources:
    if not s['transport_success']: category='failed_retrieval_no_credit'
    elif s['role']=='repository_commit_metadata': category='repository_commit_metadata_only'
    elif s['id'] in pointer_only: category='navigation_or_short_orientation_only'
    elif s['id']=='u14-s3': category='repository_title_only'
    else: category='substantive_document_or_readme'
    assessed.append({'id':s['id'],'category':category,'annotation_evidence_accepted':False,
                     'limit':'A README is a retained document, not the implementation tree or deployed code. Navigation, metadata and title-only captures receive no mechanism credit.'})
write('source-assessment.json',assessed)
(BASE/'cards').mkdir(exist_ok=False)
cards=[]
for unit,c in zip(units,content):
    n=c['ordinal']; q=unit['queue']; own=[s for s in sources if s['unit_id']==q['unit_id']]
    claims=[]
    for k,(sid,quote,claim) in enumerate(c['claims'],1):
        s=source_map[sid]; data=(BASE/s['text_path']).read_bytes(); needle=quote.encode(); start=data.index(needle);end=start+len(needle)
        # The quote uses derived-text UTF-8 coordinates; context is separately bound.
        lo=max(0,start-300); hi=min(len(data),end+1500)
        claims.append({'id':f'u{n:02}-c{k}','source_id':sid,'claim':claim,'status':'provisional_source_scoped_reading',
                       'locator':{'path':s['text_path'],'sha256':s['text_sha256'],'byte_start':start,'byte_end_exclusive':end,
                                  'quote':quote,'span_sha256':sha(data[start:end]),'line_start':data[:start].count(b'\n')+1,
                                  'line_end':data[:end].count(b'\n')+1,
                                  'context_start':lo,'context_end_exclusive':hi,'context_sha256':sha(data[lo:hi])},
                       'raw_capture':s['raw_path'],'raw_sha256':s['raw_sha256'],
                       'extraction':s['extraction']})
    card={k:v for k,v in c.items() if k!='claims'}
    card.update({'unit_id':q['unit_id'],'original_label':q['label'],'accepted':False,'identity_resolved':False,
                 'annotation_disposition':'not_performed','deployment_verified':False,
                 'organization_identity':{'canonical_label':q['organization'],'reading':'Brand/protocol/source-maintainer labels are separated from legal entity or issuer identity; no legal entity verified by this batch.'},
                 'original_binding':q,'original_row_snapshot':f'selected-units.json#/units/{n-1}/original_row',
                 'original_residue_preserved':True,'claims':claims,'sources':own,
                 'source_capture_limit':{'distinct_targets':len({s['url'] for s in own}),'maximum_targets':3,'maximum_attempts_each':2},
                 'review_status':'author research preparation; no native or independent acceptance'})
    write(f'cards/u{n:02}.json',card);cards.append(card)
    lines=[f"# {n:02}. {q['label']}",f"\nOriginal unit: `{q['unit_id']}`. **Draft, unaccepted; identity and deployment remain unresolved.**",'\n'+c['identity_candidate'],
           f"\nOriginal row: `{q['source_row_metadata']['source_path']}` `{q['source_row_metadata']['pointer']}`; SHA-256 `{q['source_row_metadata']['source_sha256']}`. Full original row, split rule and residue are preserved in `selected-units.json`, entry {n-1}.",
           '\nOrganization/protocol labels and repository maintainers do not establish a legal issuer, operator or obligor. No entity registry or legal relationship was verified.', '\n## Retained source readings']
    for x in claims:
        l=x['locator'];s=source_map[x['source_id']]
        lines += [f"\n- {x['claim']} Source: [{x['source_id']}]({s['url']}); `{l['path']}` bytes [{l['byte_start']},{l['byte_end_exclusive']}) / lines {l['line_start']}–{l['line_end']}. Full locator, raw hash and extraction recipe: companion JSON."]
    lines+=['\n## Split and dependency candidates']
    lines += ['\n- '+v for v in c['split_candidates']]
    lines += ['\n'+c['dependency_scope'],'\n## Retrieval and source pins']
    for s in own:
        a=next(x for x in assessed if x['id']==s['id']);pin=s.get('commit') or s.get('extraction',{}).get('git_blob')
        lines += [f"\n- `{s['id']}`: {s['final_http_status']}, {s['attempts']} attempt(s); {a['category']}. URL: {s['url']}. "+(f"Document pin: `{pin}` ({'commit' if s.get('commit') else 'Git blob only'})." if pin else 'No implementation/release pin established by this response.')]
    lines+=['\n## Remaining work']+['\n- '+v for v in c['gaps']]
    lines+=['\nNo facets are accepted or transferred from siblings/dependencies. Addresses are documented candidates only. Repository README and Git metadata captures do not establish full source or deployment fidelity.']
    (BASE/f'cards/u{n:02}.md').write_text('\n'.join(lines)+'\n')
write('identity-index.json',{'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'accepted':False,
                           'selection':'First 16 entries of frozen consolidated-01 remaining queue, in stored order',
                           'units':[{'unit_id':c['unit_id'],'label':c['original_label'],'card':f"cards/u{c['ordinal']:02}.json",'accepted':False,'identity_resolved':False,'gaps':c['gaps']} for c in cards],
                           'scope':'Source/identity preparation only; no annotation adjudication, canonical edits, source-tree execution or deployment verification.'})
print('generated',len(cards),'cards;',sum(len(c['claims']) for c in cards),'literal claim locators')
