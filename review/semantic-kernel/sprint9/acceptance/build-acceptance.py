#!/usr/bin/env python3
"""Record inspected native verdicts and reconcile current status without altering frozen evidence."""
from pathlib import Path
from datetime import datetime,timezone
import copy,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[4]
BASE=ROOT/'review/semantic-kernel/sprint9'
OUT=BASE/'acceptance'
SOURCE='eec499d613688137a341f3556cd80ca461dd2ee9'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def save(name,x):(OUT/name).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
reviews=[]
for provider,folder in [('grok','native-review-r2'),('fable','native-review-r2-compact')]:
 p=BASE/folder/f'final-{provider}'
 meta=read(Path(str(p)+'.invocation.json')); report=Path(str(p)+'.md')
 assert meta['candidate']==SOURCE and meta['exit_code']==0 and not meta.get('is_error')
 assert meta['inputs_unchanged'] and meta['bundle_unchanged']
 assert re.search(r'VERDICT: ACCEPT WITH LIMITATIONS',report.read_text())
 reviews.append({'provider':provider,'requested_model':meta['requested_model'],'reported_models':meta['reported_models'],'effort':meta['effort'],'candidate':SOURCE,'bundle_sha256':meta['bundle_sha256'],'verdict':'ACCEPT WITH LIMITATIONS','report':str(report.relative_to(ROOT)),'report_sha256':sha(report),'invocation':str(Path(str(p)+'.invocation.json').relative_to(ROOT)),'invocation_sha256':sha(Path(str(p)+'.invocation.json')),'scope':'corrected source and completed execution evidence; advisory inspection, no independent execution'})
original=BASE/'final-review-r2/scenario-map-review.json';x=read(original);assert x['candidate']==SOURCE and len(x['scenarios'])==55
rows=copy.deepcopy(x['scenarios'])
for row in rows:
 row['historical_development_record']={'source':str(original.relative_to(ROOT)),'source_sha256':sha(original),'status':row.pop('development_status',None),'pending_text':row.pop('development_pending_text',None),'scope':'Historical pre-execution annotation only; not current pending work.'}
 row['review_acceptance']={'candidate':SOURCE,'reviews':[r['report'] for r in reviews]}
 row['pending']=''
 if row['id']=='S9-044':
  row['status']='native_accepted_delivery_pending';row['pending']='Authorized branch push and OpenSpec archive verification.'
 else:row['status']='accepted_with_recorded_limits'
assert len({r['id'] for r in rows})==55 and all('development_pending_text' not in r for r in rows)
assert all(a['id']==b['id'] and a['then']==b['then'] for a,b in zip(rows,x['scenarios']))
record={'candidate':SOURCE,'accepted_utc':datetime.now(timezone.utc).isoformat(),'substantive_source_and_evidence_accepted':True,'delivery_complete':False,'reviews':reviews,'presentation':'Grok accepted the complete canonical bundle739723; Fable initial same-bundle attempt exceeded1M context and gave no verdict. Fable accepted projection831494 of identical underlying source/evidence, retaining every source verbatim and exact complete runtime outcomes. Presentation rules and canonical3683-input bindings retained. No source or execution substitution.','closed_final_findings':[{'id':'Fable-R1','resolution':'Current scenario status excludes historical development pending prose; original frozen records preserved, historical prose explicitly scoped separately in accepted-scenarios.json.'},{'id':'Fable-R2','resolution':'Only two global positives are enforced by the production runner. Fourteen per-mutant siblings are separately measured and checked in postexecution evidence reconciliation, not runner-protected controls.'},{'id':'Fable-R3','resolution':'EVIDENCE.md displays actual world/history matrix T/T,F/T,F/F. Explanation of literal continuation after history reset is source reasoning, not an additional measured oracle or diagonal classifier.'}],'actual_execution_identities':{'Lean_integration_proof_mutations_controls':SOURCE,'legacy13':'c880acf62944746ff9a376afc0c0050702f037f7; exact relevant-source/tool equivalence to successor'},'original_scenario_projection':{'path':str(original.relative_to(ROOT)),'sha256':sha(original)},'scenario_count':55,'limits':[v for v in x['limits'] if v != 'No native acceptance or delivery claimed.']}
save('acceptance.json',record)
save('accepted-scenarios.json',{'candidate':SOURCE,'frozen_projection':record['original_scenario_projection'],'current_status_scope':'Native accepted; delivery/archival still pending. Historical annotations have no current pending meaning.','scenarios':rows})
print('Native acceptance recorded;55 exact claims retained; delivery remains pending')
