import pathlib, json, hashlib, datetime, sys
O=pathlib.Path(__file__).parent
B=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-p22-source')
M=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-p22-source-inputs.json')
def h(b): return hashlib.sha256(b).hexdigest()
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def write(name,obj): (O/name).write_text(json.dumps(obj,indent=2)+'\n')
start=now()
# Revalidate the exact frozen inputs before sealing; no source execution.
m=json.loads(M.read_text())
assert len(m['files'])==23
for name, expected in m['files'].items(): assert h((B/name).read_bytes())==expected,name
write('input-manifest-copy.json',m)
findings=[
 {'id':'P22-S01','severity':'acceptance_obligation','title':'Preserve successful residual return and distinct stop reasons','source':'StableSwap3Pool.vy:195-218','required':'Keep zero sum, adjacent guard and exhausted return distinct; prove cap without assuming convergence.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S02','severity':'acceptance_obligation','title':'Constructor amplification is not bounded by ramp assertions','source':'StableSwap3Pool.vy:118-163,702-714','required':'Freeze initial amplification/time domain or model exceptional arithmetic; do not infer constructor guards from ramp_A.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S03','severity':'acceptance_obligation','title':'Three-coin uint256 and normalization correspondence remains open','source':'StableSwap3Pool.vy:76-82,175-218','required':'Preserve coin order, sequential rounding, all intermediate bounds and positive executed denominators.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S04','severity':'historical_scope_limit','title':'Two-coin models change success/failure and stopping behavior','source':'curveD.qnt:7-48;curve_reconcile.py:16-43','required':'Do not reuse as unchanged three-coin execution; account for fabricated nonpositive-input success and early cycle/zero-denominator returns.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S05','severity':'acceptance_obligation','title':'Actual refusal must belong to a declared endpoint','source':'StableSwap3Pool.vy:359-365,533;source-bound-library-families/spec.md:139-149','required':'Select an actual caller guard or compile-bound arithmetic failure; never call exhaustion a revert.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S06','severity':'evidence_limit','title':'Source pin bytes verified; execution, deployment and ancestry not authenticated here','source':'source-entry/readiness.json','required':'Retain acquisition attestation boundary and obtain compiler/runtime evidence for campaigns.','blocks_source_preparation':False,'blocks_P22_completion':True},
 {'id':'P22-S07','severity':'review_record_limit','title':'Initial orientation calls predate complete command recording','required':'Use recorded probes for substantive evidence; do not infer exact initial UTC/raw streams.','blocks_source_preparation':False,'blocks_P22_completion':False}
]
write('findings.json',{'scope':'source_preparation_only','findings':findings})
write('verdict.json',{'verdict':'ACCEPT_WITH_LIMITATIONS','scope':'frozen P22 source preparation suitability only','advisory':True,'mathematical_proof':False,'requested_model':'gpt-6-astra','requested_reasoning_effort':'medium','harness_assigned_model':'gpt-6-astra','independent_provider_telemetry':None,'input_manifest_sha256':h(M.read_bytes()),'input_count':23,'source_entry_bindings_verified':11,'upstream_blob_archive_bindings_verified':6,'historical_sha_bindings_verified':4,'same_validator_altered_byte_control':'intact accepted; altered byte rejected','source_preparation_blockers':[],'P22_accepted':False,'tasks':{'23.1':'open','23.2':'open','23.3':'open'},'compiler_executed':False,'source_execution':False,'convergence_proven':False,'residual_witness_executed':False,'historical_commit_ancestry_reverified':False,'upstream_commit_tree_membership_reverified':False,'review_record_limitation':'Initial cat/mkdir tool calls lack exact UTC intervals and complete retained raw streams; substantive probes have complete records.'})
initial=[
 ['cat','/home/charl/.agents/skills/superpowers/skills/using-superpowers/SKILL.md'],
 ['cat',str(B/'historical-brief.txt')],
 ['cat',str(M)],
 ['cat',str(B/'current-contract/AGENTS.md'),'/home/charl/.agents/skills/graphify/SKILL.md'],
 ['cat',str(B/'source-entry/manifest.json')],
 ['mkdir','-p',str(O)],
 ['cat',str(B/'source-entry/readiness.json')]
]
records=[json.loads(p.read_text()) for p in sorted(O.glob('*.command.json'))]
assert len(records)==7,len(records)
assert all(r['exit']==0 for r in records)
for r in records:
    for stream in ['stdout','stderr']: assert h((O/r[stream]).read_bytes())==r[stream+'_sha256']
write('commands.json',{'schema':'p22-review-commands/v1','substantive_probes':records,'initial_orientation_calls':[{'argv':a,'cwd':'/home/charl','start_utc':None,'end_utc':None,'exit':0,'raw_sha256':None,'limitation':'Observed in tool transcript; exact timestamps and complete original raw streams not captured'} for a in initial],'authoring_tools':{'tool':'apply_patch','purpose':'Create review-only probe, recorder, report and finalizer; patches are preserved in conversation tool transcript; exact tool timestamps not exposed'},'finalizer':{'argv':[sys.executable,str(O/'finalize.py')],'cwd':'/home/charl','start_utc':start,'checks_end_utc':now(),'exit_expected':0,'exit_actual':'see final exec tool response','script_sha256':h(pathlib.Path(__file__).read_bytes()),'python_executable_sha256':h(pathlib.Path(sys.executable).read_bytes()),'raw_stream_capture':'Final manifest hash printed to tool transcript; no self-referential raw-stream hash claimed'},'source_hashes':'input-manifest-copy.json and per-file read probe headers','failed_probes':[],'expected_negative_control':'bindings.stdout retains altered-byte validator rejection','display_truncation':'Some tool displays truncated; all timed probe stdout/stderr files are complete'})
manifest={'schema':'p22-source-review-manifest/v1','utc':now(),'self_excluding':True,'files':{str(p.relative_to(O)):h(p.read_bytes()) for p in sorted(O.rglob('*')) if p.is_file() and p.name!='MANIFEST.json'}}
write('MANIFEST.json',manifest)
print(json.dumps({'status':'sealed','files':len(manifest['files']),'manifest_sha256':h((O/'MANIFEST.json').read_bytes()),'source_preparation_blockers':[],'P22_accepted':False}))
