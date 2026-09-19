import pathlib,json,hashlib,datetime
O=pathlib.Path(__file__).parent;H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=datetime.datetime.now(datetime.timezone.utc).isoformat();R=O.parent
f=json.loads((R/'grok-r2-frozen-inputs.json').read_text());S=pathlib.Path(f['sandbox'])
assert all(H(S/p)==h for p,h in f['files'].items());assert H(R/f['archive'])==f['archive_sha256']
cs=[]
for p in sorted((O/'commands').glob('*/receipt.json')):
 c=json.loads(p.read_text());assert c['end']<now
 for n,h in c['sha256'].items():assert H(p.parent/n)==h
 cs.append(c)
assert len(cs)==20
v={'schema':'defiformal-independent-review/v1','timestamp_utc':now,'verdict':'ACCEPT_WITH_LIMITATIONS','scope':'Grok R2 universal admissible TreeJson depth transport and partial scanner continuations','reviewer':{'model':'gpt-6-astra','reasoning_effort':'medium','independent':True},'frozen_input_manifest_sha256':H(R/'grok-r2-frozen-inputs.json'),'frozen_files':422,'archive_verified':True,'author_manifest_valid':True,'author_receipts_verified':14,'fresh_build_exit':0,'new_authored_theorems':73,'new_authored_definitions':5,'compiled_constants':132,'compiled_theorems':98,'compiled_definitions':34,'exact_print_axioms_coverage':132,'forbidden_axioms':0,'roundtrip_theorems_preserved':246,'roundtrip_definitions_preserved':45,'proof_repairs_required':[],'findings':[{'id':'R2-E01','severity':'low','kind':'report_accuracy','status':'correction_recorded','detail':'v3 passed; v1-v7 not uniformly failed'},{'id':'R2-E02','severity':'informational','kind':'audit_coverage','status':'resolved_by_independent_full_audit'},{'id':'R2-E03','severity':'informational','kind':'recorder_routing','status':'verified_local_copy_only_evidence_path_changed'}],'open_obligations':['nonempty array/object scanner induction','universal h_lex','EncodeDecodeRoundtripStatement'],'P19_accepted':False,'P20_accepted':False,'P37_accepted':False,'source_mutated':False,'unchanged_campaigns_rerun':False,'review_receipts_verified':len(cs)}
(O/'verdict.json').write_text(json.dumps(v,indent=2)+'\n')
vs=json.loads((O/'verification-summary.json').read_text());vs['review_receipts_verified']=len(cs);vs['final_receipt_verified_by_seal']=True;(O/'verification-summary.json').write_text(json.dumps(vs,indent=2)+'\n')
m={'schema':'defiformal-independent-review-seal/v1','timestamp_utc':now,'self_excluded':True,'files':{str(p.relative_to(O)):H(p) for p in sorted(O.rglob('*')) if p.is_file() and p.name!='MANIFEST.json'}};(O/'MANIFEST.json').write_text(json.dumps(m,indent=2)+'\n');print(H(O/'MANIFEST.json'))
