from pathlib import Path
import json,hashlib,datetime,subprocess,re,os,gzip,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-module-validity-grok-r1';F=O/'original-terminal';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-validity-grok-r1-sandbox');P=O/'private-lean';V=O/'root-verification';T=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
process=read(C/'process.json');orig=read(O/'process.json');assert process['process_exit']==orig['process_exit']==1 and process['sessions']==orig['sessions'] and process['reported_models']==orig['reported_models']==['grok-4.6-build'];assert not Path('/proc',str(read(C/'dispatch.json')['pid'])).exists()
for proc in Path('/proc').iterdir():
 if not proc.name.isdigit():continue
 try:cwd=str((proc/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(proc.name,cwd)
assert h(C/'native.jsonl')==process['log_sha256'] and h(O/'native.jsonl')==orig['log_sha256'];V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');inputs=read(O/'inputs.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
for p,d in read(F/'root-seal.json')['files'].items():
 assert h(F/p)==d,p
 if p!='native.jsonl.gz':assert h(O/p)==d,('parent changed',p)
m=read(C/'MANIFEST.json');assert m['status']=='complete' and m['file_count']==len(m['files'])==15 and m['self_excluding'];assert read(C/'verdict.json')['status']=='complete'
for row in m['files']:assert h(C/row['path'])==row['sha256'] and (C/row['path']).stat().st_size==row['bytes'],row['path']
for row in m['immutable_parent_and_probe_bindings']:
 p=Path(m['path_bases'][row['path_base']])/row['path'];assert h(p)==row['sha256'] and p.stat().st_size==row['bytes'],p
rows=read(C/'commands.json')['commands'];assert len(rows)==7
for row in rows:
 base=F if row['id']!='probe-axioms578' else C;meta=read(base/'logs'/row['id']/'meta.json')
 for k in ['id','argv','cwd','start','end','exit','timed_out']:assert row[k]==meta[k],(row['id'],k)
 for k in ['stdout','stderr']:assert h(base/row[k+'_path'])==row['raw'+k+'_sha256']
 assert row['exit']==0 and not row['timed_out'] and row['end']>=row['start']
private={}
for parent,dirs,names in os.walk(P):
 dirs[:]=[d for d in dirs if d not in ['.lake','.git','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if p.suffix=='.lean' or name in ['lakefile.toml','lake-manifest.json','lean-toolchain']:
   q=S/'lean'/p.relative_to(P);assert q.is_file() and h(p)==h(q),p;private[str(p.relative_to(P))]=h(p)
assert len(private)>13;put(V/'private-source-bindings.json',private)
names=[];counts={}
for module in ['CanonicalJson','Correspondence','Roundtrip']:
 text=(P/f'DefiKernel/Certificates/{module}.lean').read_text();found=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',text,re.M);counts[module]=len(found);names+=['DefiKernel.Certificates.'+n for n in found]
assert counts=={'CanonicalJson':136,'Correspondence':312,'Roundtrip':130}
probe=F/'probes/axioms578/Axioms.lean';assert h(probe)==h(B/'p19-r24-root-inventory/Axioms.lean');argv=[str(T/'lake'),'env',str(T/'lean'),str(probe)];start=now();run=subprocess.run(argv,cwd=P,capture_output=True,timeout=90);(V/'axioms.stdout').write_bytes(run.stdout);(V/'axioms.stderr').write_bytes(run.stderr);put(V/'command.json',{'argv':argv,'cwd':str(P),'started_utc':start,'finished_utc':now(),'exit':run.returncode,'probe_sha256':h(probe),'lean_sha256':h(T/'lean'),'lake_sha256':h(T/'lake'),'stdout_sha256':h(V/'axioms.stdout'),'stderr_sha256':h(V/'axioms.stderr'),'actor':'root','scope':'Root fresh replay using completed independent reviewer build; not another reviewerbuild or liveauthor execution.'});assert run.returncode==0
raw=run.stdout.decode();std=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",raw,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",raw);got=[n for n,a in std]+zero;assert len(got)==len(set(got))==578 and set(got)==set(names) and len(std)==520 and len(zero)==58;assert all(set(a.replace('\n',' ').replace(',',' ').split())<={'propext','Classical.choice','Quot.sound'} for _,a in std);assert run.stdout==(C/'logs/probe-axioms578/stdout').read_bytes()==(B/'p19-r24-root-inventory/axioms.stdout').read_bytes()
original_sources=read(B/'p19-roundtrip-proof-agy-r24-terminal-manifest.json');author=S/'review/semantic-kernel/certificates/p19/implementation/agy-r24-proof';ar=read(author/'commands.json');assert len(ar)==62
for row in ar:
 assert read(author/'logs'/row['id']/'command.json')==row
 for k in ['stdout','stderr']:assert h(author/row[k+'_path'])==row[k+'_sha256']
actualinputs=len(inputs['files']);walk=json_count=None
result={'utc':now(),'status':'completed_root_verified','candidate_archive_sha256':inputs['candidate_archive_sha256'],'input_bindings_verified':actualinputs,'review_manifest_bindings':15,'additional_parent_probe_bindings':len(m['immutable_parent_and_probe_bindings']),'private_lean_source_config_bindings':len(private),'reviewer_commands':7,'reviewer_raw_streams':14,'author_command_records':62,'author_raw_streams':124,'explicit_theorem_counts':counts,'named_total':578,'standard_axioms':520,'zero_axioms':58,'forbidden_axioms':0,'root_probe_equals_reviewer_and_prior_root_stdout':True,'original_exit':1,'original_turn_cap':30,'closeout_exit':1,'closeout_turn_cap':12,'all_five_closeout_reports_complete':True,'reported_models':process['reported_models'],'same_session':process['sessions'][0],'scope':'R24 new28modulevalidity/componentdecoder lemmas usable; fullP19CHANGES_REQUIRED','acceptance':False};put(V/'result.json',result)
adj={**result,'scoped_result':'USABLE28newlemmas includingmoduleToTreeJson_valid fromexistingadmission; nofullP19closure','corrections':['Both native attempts reachedturncaps(exit1); original sixsuccessfulcommands andcloseoutsuccessful578probe plusallfivefinalreports are actualevidence. Capexit1 is not proofcommandfailure or normalexit0. No further closeoutneeded.','Reviewersandboxwalk4925 is not the4467archive count or authoritative4757frozeninputbindings; rootverified exactinputmanifest and200privateLean/configbindings separately.','Extra localcanonicalassumptions onWorlddecoder are componentconditions, not a defect ifderivedfromexistingadmission; fullmodulecompositionremainsmissing.','Author source-manifest has13bindings verified, not15copied inearlierbrief; rootcorrectionpublished separately.','AuthorMANIFEST9match+1stalecommandsbinding and AGYroot_preflightcontrolmislabels remainoriginalevidence defects, not newlyverifiedrootruns.','CompiletargetVerify938jobs has visibleBuiltVerify only; fullDefiKernel notbuilt. Rootaxiomreplay is separatefromreviewerprobe anddoesnotadd anotherindependentreviewer.'],'remaining':['Finishmoduledecoder/depth/scanner proofandexistingEncodeDecodeRoundtripStatement','Noarbitrarystring/rationalcaps, rawtreepermutationequality ordesiredsuccess/domainimagepremises','RemainingP19/P20overlay/schema/hash/expectedIR/host/campaign obligations andfullcoreroadmap'],'next':'R26authorrunning; freshfrozenR25proofauditnext. Preserve exactreviewidentities.','full_P19_accepted':False};put(O/'root-adjudication.json',adj)
for root in [O,C]:
 with (root/'native.jsonl.gz').open('xb') as out:
  with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((root/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name!='native.jsonl':files[str(p.relative_to(O))]=h(p)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_files':len(files),**result}))
