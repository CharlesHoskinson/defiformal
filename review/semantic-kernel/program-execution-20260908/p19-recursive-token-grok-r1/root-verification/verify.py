from pathlib import Path
import json,hashlib,datetime,subprocess,re,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-recursive-token-grok-r1';R=O/'root-verification';R.mkdir(exist_ok=False);read=lambda p:json.loads(p.read_text());h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not Path('/proc/2163507').exists();process=read(O/'process.json');assert process['process_exit']==1 and process['terminal_events'][-1]['num_turns']==35;assert h(O/'native.jsonl')==process['log_sha256']
manifest=read(O/'MANIFEST.json');assert len(manifest['files'])==manifest['file_count']==46
for row in manifest['files']:assert h(O/row['path'])==row['sha256'] and (O/row['path']).stat().st_size==row['bytes'],row['path']
inputs=read(O/'inputs.json');S=Path(inputs['sandbox'])
for n,digest in inputs['files'].items():assert h(S/n)==digest,n
W=O/'private-lean';candidate=read(B/'p19-roundtrip-proof-agy-r20-terminal-manifest.json');private_sources=0
for row in candidate['files']:
 if row['path'].startswith('lean/DefiKernel/Certificates/'):
  assert h(W/row['path'].removeprefix('lean/'))==row['sha256'],row['path'];private_sources+=1
commands=read(O/'commands.json')['commands'];assert len(commands)==8
for row in commands:
 meta=read(O/'logs'/row['id']/'meta.json')
 for k in ['argv','cwd','start','end','exit']:assert meta[k]==row[k],(row['id'],k)
 for stream in ['stdout','stderr']:assert h(O/row[stream+'_path'])==row['raw'+stream+'_sha256']
 if row.get('probe_sha256'):assert h(O/row['probe'])==row['probe_sha256']
A=S/'review/semantic-kernel/certificates/p19/implementation/agy-r20-proof';author=read(A/'commands.json');assert len(author)==9
for row in author:
 for stream in ['stdout','stderr']:assert h(A/row['raw'+stream])==row[stream+'_sha256']
 if row.get('probe'):assert h(A/row['probe'])==row['probe_sha256']
names=[]
for module in ['CanonicalJson','Correspondence']:names+=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',(W/f'DefiKernel/Certificates/{module}.lean').read_text(),re.M)
assert len(names)==len(set(names))==418;thms={'DefiKernel.Certificates.'+n for n in names};probe=O/'probes/axioms434/Probe.lean';qnames=re.findall(r'^#print axioms (\S+)',probe.read_text(),re.M);assert len(qnames)==len(set(qnames))==434;extras=set(qnames)-thms;assert len(extras)==16 and thms<=set(qnames)
rootprobe=R/'Probe434.lean';shutil.copy2(probe,rootprobe);tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');argv=[str(tool/'lake'),'env',str(tool/'lean'),str(rootprobe)];start=now();run=subprocess.run(argv,cwd=W,capture_output=True,timeout=180);end=now();(R/'stdout').write_bytes(run.stdout);(R/'stderr').write_bytes(run.stderr);put(R/'command.json',{'argv':argv,'cwd':str(W),'started_utc':start,'finished_utc':end,'exit':run.returncode,'probe_sha256':h(rootprobe),'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),'stdout_sha256':h(R/'stdout'),'stderr_sha256':h(R/'stderr')});assert run.returncode==0 and run.stdout==(O/'logs/probe-axioms434/stdout').read_bytes() and not run.stderr
text=run.stdout.decode();pairs=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",text,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",text);maps={n:sorted(x.strip() for x in a.split(',') if x.strip()) for n,a in pairs};maps.update({n:[] for n in zero});assert set(maps)==set(qnames);assert all(set(a)<={'propext','Classical.choice','Quot.sound'} for a in maps.values());assert sum(bool(maps[n]) for n in thms)==390 and sum(not maps[n] for n in thms)==28;assert len(pairs)==391 and len(zero)==43
build=(O/'logs/lake-rebuild-correspondence/stdout').read_text();rebuilt=re.findall(r'Built (DefiKernel\.Certificates\.\w+)',build);assert len(rebuilt)==6
result={'utc':now(),'input_bindings_verified':len(inputs['files']),'manifest_bindings_verified':46,'private_certificate_sources_verified':private_sources,'reviewer_commands_verified':8,'reviewer_raw_streams_verified':16,'author_raw_streams_verified':18,'root_probe_stdout_byte_equal_reviewer':True,'source_theorem_lemma_count':418,'source_standard':390,'source_none':28,'all_named_including_defs':434,'all_standard':391,'all_none':43,'extra_definitions':sorted(extras),'rebuilt_modules':rebuilt,'review_report_correction':'REVIEW section1 says Soundness/Tests/Verify/Audit were deleted and rebuilt as consumers. Actual target Correspondence rebuilds six certificate modules and replays Schema; it does not rebuild those four downstream modules. Do not credit them as newly rebuilt.','failed_inline_axiom_helper':'exit1 Only86of126 declarations resolved; retained zero credit. Successful exact434 #print probe provides the axiom evidence.','new_scope_cautions':['TreeJson depth64 is not implied by ExprCanonical alone; derive emitted structural depth from unchanged whole IR admissibility.','packedValueToTreeJson is inner bool/rat Expr literal payload, not production encodePackedValue unit/value object.'],'full_byte_module_inverse_accepted':False,'P19_accepted':False}
put(R/'assessment.json',result);shutil.copy2(__file__,R/'verify.py');files={p.name:h(p) for p in R.iterdir() if p.is_file()};put(R/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:v for k,v in result.items() if k not in ['extra_definitions','rebuilt_modules','new_scope_cautions','review_report_correction','failed_inline_axiom_helper']}))
