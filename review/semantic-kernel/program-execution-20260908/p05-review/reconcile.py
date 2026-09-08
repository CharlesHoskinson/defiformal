#!/usr/bin/env python3
import pathlib,json,re,hashlib,gzip,tarfile,subprocess,datetime,collections
O=pathlib.Path(__file__).resolve().parent
W=pathlib.Path('/home/charl/defiformal-wt-lifecycle-grok-gpt6-20260908')
R=pathlib.Path('/home/charl/defiformal')
N=W/'review/semantic-kernel/program-loop-20260908/native-worker'
sha=lambda b:hashlib.sha256(b).hexdigest()
def save(n,d): (O/n).write_text(json.dumps(d,indent=2)+'\n')
before=json.loads((O/'before.json').read_text())
historical={}
sources={}
for stage,expected in [('capability-foundation-r1','64e03cc18d04fb88cb732d7a3b523bbdefc3be801b311366df245d6dce024f27'),('capability-foundation-r2','7fc31431a2b5d6f0198f8a182fcd31a35b90d323c076c1c0bc000c9a3b30c52a')]:
 archive=N/(stage+'-stage.tar.gz');assert sha(archive.read_bytes())==expected
 with tarfile.open(archive) as t:
  members={m.name:sha(t.extractfile(m).read()) for m in t.getmembers() if m.isfile()}
  for n in ['Origins','Observation','Trace','FoundationChecks']:
   rel=f'lean/DefiKernel/CapabilityProvenance/{n}.lean';sources[(stage,n)]=t.extractfile(rel).read().decode()
  logmember=next(x for x in members if x.endswith('/logs/foundation-compile.stdout.log'))
  raw=t.extractfile(logmember).read().decode()
  labels=re.findall(r'\("(foundation\.[^"]+)"',sources[(stage,'FoundationChecks')])
  emitted=re.findall(r'(foundation\.[A-Za-z0-9.\-]+): (true|false)',raw)
  assert len(labels)==len(set(labels)) and [l for l,v in emitted]==labels and all(v=='true' for l,v in emitted)
 receipt=N/(stage+'.json');rd=json.loads(receipt.read_text());gz=N/(stage+'.jsonl.gz');raw=gzip.decompress(gz.read_bytes());assert sha(raw)==rd['raw_sha256']
 end=[json.loads(l) for l in raw.splitlines() if l.strip() and json.loads(l).get('type')=='end'];assert len(end)==1
 historical[stage]=dict(archive=str(archive),archive_sha256=expected,members=members,source_labels=labels,actual_count=len(labels),emitted_rows=emitted,log_member=logmember,receipt=str(receipt),receipt_sha256=sha(receipt.read_bytes()),compressed_terminal=str(gz),compressed_terminal_sha256=sha(gz.read_bytes()),raw_terminal_sha256=sha(raw),terminal_end=end[0],process_exit_from_retained_root_receipt=rd['exit_code'])
save('historical-bindings.json',historical)
oldlabels=historical['capability-foundation-r1']['source_labels'];newlabels=historical['capability-foundation-r2']['source_labels']
fresh=re.findall(r'^(foundation\.[A-Za-z0-9.\-]+): (true|false)$',(O/'logs/direct-foundationchecks.stdout').read_text(),re.M)
assert [n for n,v in fresh]==newlabels and all(v=='true' for n,v in fresh)
audit=re.findall(r'^P05_REVIEW (CF1\.[^:]+): (true|false)$',(O/'logs/RevocationAudit-r2.stdout').read_text(),re.M)
assert len(audit)==8 and all(v=='true' for n,v in audit)
save('check-inventory.json',dict(baseline=oldlabels,baseline_count=len(oldlabels),candidate=newlabels,candidate_count=len(newlabels),added=[x for x in newlabels if x not in oldlabels],removed=[x for x in oldlabels if x not in newlabels],fresh_rows=fresh,reviewer_rows=audit,reviewer_count=len(audit),historical_author_counts={'r1_report':22,'r2_old_claim':22,'r2_total_claim':29},correction='23 baseline +7 added =30 candidate comparisons;8 reviewer comparisons are separate, not production mutants'))
preserved=[];newtheorems=[];explicit=[]
for name in ['Origins','Observation','Trace','FoundationChecks']:
 old=sources[('capability-foundation-r1',name)];new=sources[('capability-foundation-r2',name)]
 assert old==(W/f'review/semantic-kernel/capability-provenance/implementation/grok-foundation-r2/before/{name}.lean').read_text()
 def headers(s):return {m.group(1):m.group(0) for m in re.finditer(r'^theorem\s+(\S+)\s[\s\S]*?(?=:=)',s,re.M)}
 oh=headers(old);nh=headers(new)
 for n,h in oh.items():
  assert nh.get(n)==h,(name,n)
  preserved.append(dict(module=name,name=n,header_sha256=sha(h.encode()),header=h))
 for n,h in nh.items():
  if n not in oh:newtheorems.append(dict(module=name,name=n,header=h))
 for m in re.finditer(r'^(abbrev|def|inductive|structure|theorem)\s+(\S+)',new,re.M):explicit.append(dict(module=name,kind=m.group(1),name=m.group(2)))
save('source-theorem-preservation.json',dict(r1_named_theorems=len(preserved),unchanged_headers=preserved,new_named_theorems=len(newtheorems),new_theorems=newtheorems,method='All r1 source theorem headers exactly preserved; Trace has additions only, Origins/Observation identical, FoundationChecks existing theorem section unchanged. Nine imported predecessor modules byte-identical to delivered base.'))
save('source-declarations.json',explicit)
inventory=json.loads((O/'inventory.json').read_text());assert inventory and all(not row['forbidden'] for row in inventory)
assert set(row['module'] for row in inventory)==set(before['closure'])
summary=dict(imported_project_modules=len(set(row['module'] for row in inventory)),all_project_declarations=len(inventory),all_project_kinds=dict(collections.Counter(row['kind'] for row in inventory)),candidate_declarations=sum('.CapabilityProvenance.' in row['module'] for row in inventory),candidate_kinds=dict(collections.Counter(row['kind'] for row in inventory if '.CapabilityProvenance.' in row['module'])),source_declarations=len(explicit),source_kinds=dict(collections.Counter(row['kind'] for row in explicit)),source_theorems_by_module=dict(collections.Counter(row['module'] for row in explicit if row['kind']=='theorem')),module_counts=dict(collections.Counter(row['module'] for row in inventory)),transitive_axioms=sorted(set(ax for row in inventory for ax in row['axioms'])),forbidden_dependencies=0)
save('inventory-summary.json',summary)
baseline=W/'review/semantic-kernel/capability-provenance/implementation/grok-foundation-r1/hashes'
protected={}
for name in ['closure-before.json','protected-before.json','normative-before.json','pins-before.json']:
 rows=json.loads((baseline/name).read_text())
 for row in rows:assert sha((W/row['path']).read_bytes())==row['sha256'],row['path']
 protected[name]=dict(count=len(rows),rows=rows)
dep=json.loads((W/'openspec/changes/capability-provenance-isolation/dependency-baseline.json').read_text())
receipts=dep['m3_receipts']['files']+[dep['administrative_primary_integration']]+[v for v in dep['predecessors'].values() if isinstance(v,dict) and 'path' in v]
for row in receipts:assert sha((W/row['path']).read_bytes())==row['sha256'],row['path']
save('dependency-acceptance-binding.json',dict(historical_protection=protected,delivered_receipts=receipts,nine_predecessors_match_primary=all(v['matches_primary'] for k,v in before['closure'].items() if '.CapabilityProvenance.' not in k),missing_required_dependency_acceptance=[],acceptance_basis='Official planning acceptance r2 explicitly accepts bound Sprint9/10/M3 predecessors; exact historical source and delivery receipts rebound. M4 is not a prerequisite.'))
pins={}
for key in ['pinned_lean','pinned_lake']:
 row=dep['lake_pins'][key];assert sha(pathlib.Path(row['path']).read_bytes())==row['sha256'];pins[key]=row
mathlib=W/'lean/.lake/packages/mathlib';pins['mathlib_head']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=mathlib,text=True).strip();assert pins['mathlib_head']==dep['lake_pins']['mathlib_manifest_rev'];pins['fresh_version']=(O/'logs/lean-version.stdout').read_text()
save('tool-bindings.json',pins)
after=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),changed_files={},preserved_counts={})
for key,base in [('worktree',W),('primary',R)]:
 after['changed_files'][key]=[rel for rel,expected in before['preserved_files'][key].items() if sha((base/rel).read_bytes())!=expected];assert not after['changed_files'][key]
 after['preserved_counts'][key]=len(before['preserved_files'][key])
after['worktree_status']=subprocess.check_output(['git','status','--porcelain','-uall'],cwd=W,text=True);after['worktree_status_unchanged']=after['worktree_status']==before['worktree_status'];assert after['worktree_status_unchanged']
after['archive_members_unchanged']=all(sha((W/rel).read_bytes())==expected for rel,expected in before['archive_members'].items());assert after['archive_members_unchanged']
save('after.json',after)
print(json.dumps(dict(inventory=summary,checks={'old':len(oldlabels),'candidate':len(newlabels),'reviewer':len(audit)},old_theorems_preserved=len(preserved),new_theorems=len(newtheorems),preserved=after['preserved_counts']),indent=2))
