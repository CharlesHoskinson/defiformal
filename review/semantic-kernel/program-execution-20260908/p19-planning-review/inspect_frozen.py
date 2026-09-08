import pathlib,json,hashlib,gzip,tarfile,subprocess,re,shutil
R=pathlib.Path('/home/charl/defiformal');W=pathlib.Path('/home/charl/defiformal-wt-certificates-grok-gpt6-20260908');O=R/'review/semantic-kernel/program-execution-20260908/p19-planning-review';P=W/'openspec/changes/serialized-kernel-certificates';N=W/'review/semantic-kernel/program-loop-20260908/native-worker'
def sha(b):return hashlib.sha256(b).hexdigest()
def save(n,x): (O/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
def packed(x):return json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()
fs={f['id']:f for f in json.loads((P/'fixtures.json').read_text())['fixtures']}
a,b=fs['F25'],fs['F36'];assert a['inputs']['payload']==b['inputs']['payload'];diff=[k for k in a['inputs'] if a['inputs'][k]!=b['inputs'][k]];assert diff==['claimed_next_state']
save('f25-f36-contradiction.json',{'evidence_class':'literal structural comparison; not Lean execution','payloads_equal':True,'payload_normalized_sha256':sha(packed(a['inputs']['payload'])),'input_changed_keys':diff,'F25_claim':a['inputs']['claimed_next_state'],'F36_claim':b['inputs']['claimed_next_state'],'F25_expected':a['expected'],'F36_expected':b['expected'],'correspondence_contract':json.loads((P/'correspondence-theorems.json').read_text())})
rows=[]
for i in ['F09','F17','F18','F19','F23','F40','F47']:
 f=fs[i];p=f['inputs']['payload'];req=p.get('request',p.get('step',{}).get('invocation'));store=p.get('store',p.get('pre',{}).get('capabilities'));op=req['operation'];caps=store['entries'];matches=[j for j in req['capabilityIds'] if j<len(caps) and caps[j]['operation']==op];assert matches==[]
 rows.append({'fixture':i,'request':req,'ctx':p.get('ctx',p.get('boundary',{}).get('ctx')),'store':store,'operation_match_ids':matches,'expected_status':f['expected']['status'],'expected_failure':f['expected']['failure'],'registry_template':next(t['template'] for t in p.get('registry',p.get('config',{}).get('registry'))['entries'] if t['id']==op)})
save('authority-reachability.json',{'evidence_class':'source-shaped necessary-precondition audit, no Lean execution or checker clone','source_rule':'authorizesId requires cap.operation = operation; hasAuthority is ids.any authorizesId; execute tests invoke before template.evaluate/applyEvaluated','rows':rows,'limits':'F47 interface.readAccess is earlier and may correctly refuse intact. Missing operation4 authority invalidates its required successful remaining-kernel premise; does not alone prove mutant undetected.'})
save('f49-judgment-contract.json',{'fixture':fs['F49'],'judgment_contract':json.loads((P/'judgment-contract.json').read_text()),'result_algebra':json.loads((P/'result-algebra.json').read_text()),'finding':'F49 expected accountingCorrect=true although refusal insufficientFunds violates nonnegative post-balance component. Run aggregation must explicitly include failed attempt or document a different scoped family meaning consistently.'})
raw=gzip.decompress((N/'certificates-official-repair-r2.jsonl.gz').read_bytes());events=[json.loads(l) for l in raw.splitlines()];end=[e for e in events if e.get('type')=='end'];receipt=json.loads((N/'certificates-official-repair-r2.json').read_text());assert len(end)==1 and sha(raw)==receipt['raw_sha256'];save('native-identity.json',{'requested_model':'Grok 4.6 per user/current AGENTS and native package identity; actual exact key below','actual_terminal_end':end[0],'terminal_decompressed_sha256':sha(raw),'terminal_compressed_sha256':sha((N/'certificates-official-repair-r2.jsonl.gz').read_bytes()),'root_process_receipt':receipt,'reviewer_requested_model':'gpt-6-astra','reviewer_actual_provider_telemetry':'not separately exposed; no provider telemetry inferred from role'})
# Source import closure, copied independently of cached objects.
roots=['DefiKernel.Typed.Transition','DefiKernel.Composition.Sequence'];seen={}
def visit(mod):
 if mod in seen:return
 p=W/'lean'/pathlib.Path(*mod.split('.')).with_suffix('.lean')
 if not p.exists():return
 imports=re.findall(r'^import\s+(\S+)',p.read_text(),re.M);seen[mod]={'path':str(p.relative_to(W)),'sha256':sha(p.read_bytes()),'imports':imports,'primary_equal':(R/p.relative_to(W)).read_bytes()==p.read_bytes(),'D_blob_equal':subprocess.check_output(['git','show','a12b7cac05a818cc8d35c2ca440b7170a2807e92:'+str(p.relative_to(W))],cwd=W)==p.read_bytes()}
 for x in imports:visit(x)
for x in roots:visit(x)
runtime=list(seen);visit('DefiKernel.Composition.Examples');visit('DefiKernel.Typed.Examples');visit('DefiKernel.AxiomAudit');save('dependency-closure.json',{'runtime_roots':roots,'runtime_modules':runtime,'runtime_count':len(runtime),'with_examples_and_audit_count':len(seen),'modules':seen,'claim':'Copied examples are fixture provenance, not required runtime imports. If imported they add Composition.Preservation and its actual closure. All measured primary bytes and immutable D bytes match.'})
# Retain exact supplementary inputs, including old archive and review. Frozen 72 are already in sandbox.
extra=[R/'AGENTS.md',R/'.claude/skills/defi-footguns/SKILL.md',R/'formal/v3/GATE-REGISTER.md',R/'openspec/changes/reusable-verification-platform-program/tasks.md',R/'openspec/changes/reusable-verification-platform-program/sprint-index.json',R/'openspec/changes/reusable-verification-platform-program/sprint-plan.md',N/'certificates-official-repair-r2.json',N/'certificates-official-repair-r2.jsonl.gz',N/'certificates-official-planning-r1-stage.tar.gz',W/'review/semantic-kernel/program-loop-20260908/certificates-official-r1-gpt6-review.md',W/'review/semantic-kernel/program-loop-20260908/certificates-official-r1-gpt6-inputs.json']
extra += [W/x['path'] for x in seen.values()]
extra += [W/'lean'/x for x in ['lean-toolchain','lakefile.toml','lake-manifest.json']]
manifest={}
for p in extra:
 rel=('primary/' if p.is_relative_to(R) else 'worktree/')+str(p.relative_to(R if p.is_relative_to(R) else W));out=O/'inputs'/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,out);manifest[str(p)]={'snapshot':str(out.relative_to(O)),'sha256':sha(p.read_bytes())}
save('input-snapshots.json',manifest)
# Old synthetic records must be byte-exact copies, not rewritten acceptance.
old={}
with tarfile.open(N/'certificates-official-planning-r1-stage.tar.gz') as t:
 for m in t.getmembers():
  if m.isfile():old[m.name]=sha(t.extractfile(m).read())
h=[]
for p in (W/'review/semantic-kernel/certificates/planning/grok-gpt6-official-r2/historical-r1-synthetic-controls').glob('*'):
 matches=[k for k,v in old.items() if v==sha(p.read_bytes())];h.append({'path':str(p.relative_to(W)),'sha256':sha(p.read_bytes()),'exact_r1_members':matches})
save('historical-preservation.json',{'r1_archive_sha256':sha((N/'certificates-official-planning-r1-stage.tar.gz').read_bytes()),'r1_archive_members':old,'synthetic_controls':h,'old_review_retained':True})
print(json.dumps({'fixture_authority_rows':len(rows),'same_kernel_payload_hash':sha(packed(a['inputs']['payload'])),'dependency_count':len(seen),'runtime_count':len(runtime),'source_matches_primary_and_D':all(v['primary_equal'] and v['D_blob_equal'] for v in seen.values()),'native_end':end[0]['stopReason'],'input_snapshots':len(manifest),'synthetic_records':len(h)},indent=2))
