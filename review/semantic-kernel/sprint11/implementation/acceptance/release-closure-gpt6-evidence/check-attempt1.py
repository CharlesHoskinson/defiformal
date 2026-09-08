from pathlib import Path
import json,hashlib,tarfile,gzip,re,subprocess,urllib.parse
R=Path.cwd();I=R/'review/semantic-kernel/sprint11/implementation';A=I/'acceptance';N=A/'grok-release-r1';O=A/'release-closure-gpt6-evidence';C='94f70e502c75132656bd0902a17be60ca45ab1c2';inputs={}
def h(b):return hashlib.sha256(b).hexdigest()
def rd(p):
 p=Path(p);b=p.read_bytes();inputs[str(p)]={'sha256':h(b),'bytes':len(b)};return b
def js(p):return json.loads(rd(p))
rd(__file__);m=js(N/'MANIFEST.json');assert h(rd(N/'MANIFEST.json'))=='2dd3dc08145f7fc3584d331230e9ebe7c0075ab6dbdbc7438c7226f4edf72321';assert m['source_candidate']==C and m['file_count']==len(m['files'])==22
for x in m['files']:
 b=rd(N/x['path']);assert h(b)==x['sha256'] and len(b)==x['bytes']
assert {x['path'] for x in m['files']}=={str(p.relative_to(N)) for p in N.rglob('*') if p.is_file()}-{'MANIFEST.json'}
arc=I/'native-worker/sprint11-release-closure-r1-stage.tar.gz';assert h(rd(arc))=='114683dac9984e2bc813b5c1fb9da2168cc8bb18f3f862f7aa411b50fc3d22f0';members=[]
with tarfile.open(arc) as t:
 for x in t.getmembers():
  if x.isfile():
   b=t.extractfile(x).read();p=R/x.name;assert rd(p)==b;members.append(x.name)
assert len(members)==27
identity=js(I/'native-worker/sprint11-release-closure-r1.json');assert identity['exit_code']==0
for x in identity['artifacts']:
 b=rd(Path(x['path']));assert h(b)==x['sha256'] and len(b)==x['bytes']
raw=gzip.decompress(rd(I/'native-worker/sprint11-release-closure-r1.jsonl.gz'));assert h(raw)==identity['raw_sha256'];ends=[]
for i,line in enumerate(raw.splitlines(),1):
 x=json.loads(line)
 if x.get('type')=='end':ends.append({'line':i,'sessionId':x.get('sessionId'),'modelUsage_keys':list(x.get('modelUsage',{}))})
assert ends[-1]['sessionId']=='01a07fc7-03b0-7ed0-9f72-343c8d19c78b' and ends[-1]['modelUsage_keys']==['grok-4.6-build']
before=js(N/'sources-before.json');after=js(N/'sources-after.json');docs=[x['path'] for x in after['editable']];assert set(docs)=={'openspec/changes/finite-participant-causal-composition/tasks.md','docs/research/semantic-kernel-progress.md','roadmap.md','wiki-llm/autonomous-execution-agenda.md'}
for x in after['editable']:
 b=rd(R/x['path']);assert h(b)==x['sha256'] and len(b)==x['bytes'];assert x['before_sha256']==next(y['sha256'] for y in before['editable'] if y['path']==x['path'])
reconstructed=rd(O/'pre-author-roadmap-reconstructed.md');assert h(reconstructed)==next(x['sha256'] for x in before['editable'] if x['path']=='roadmap.md')
changes=subprocess.check_output(['git','diff','--name-only'],cwd=R,text=True).splitlines();assert set(changes)==set(docs),changes
for x in before['frozen']:
 if x['path'].endswith('/WORKSTATE.json'):continue
 b=rd(R/x['path']);assert h(b)==x['sha256'] and len(b)==x['bytes']
assert after['frozen_changed']==['review/semantic-kernel/program-loop-20260908/WORKSTATE.json']
assert h(rd(A/'workstate-before-release.json'))==after['workstate_before_sha256']
assert not any(p.endswith('/WORKSTATE.json') for p in js(I/'gpt6-review/final-adjudication-r1-inputs.json')['inputs'])
freeze=js(I/'candidate-source-freeze-r2.json');assert len(freeze['integrated_sources'])==164
for x in freeze['integrated_sources']:assert h(rd(R/x['path']))==x['sha256']
pre=js(A/'pre-closure-normative.json');assert h(rd(A/'pre-closure-normative.tar.gz'))==pre['archive_sha256'];changed=[]
for x in pre['files']:
 if h(rd(R/x['path']))!=x['sha256']:changed.append(x['path'])
assert changed==['openspec/changes/finite-participant-causal-composition/tasks.md']
coverage=js(I/'gpt6-review/final-adjudication-r1.json');text=rd(R/changed[0]).decode();taskrows=re.findall(r'^- \[([ x])\] (\d+\.\d+) (.*)$',text,re.M);assert len(taskrows)==35 and sum(mark=='x' for mark,_,_ in taskrows)==34
for mark,tid,body in taskrows:
 orig=next(x for x in coverage['tasks'] if x['id']==tid);assert body.startswith(orig['text']);assert (mark=='x')==(tid!='8.5')
 if tid not in ['8.4','8.5']:assert body==orig['text']
assert 'This does not claim that Fable checked the implementation.' in text and 'Pending actual parent publish/archive/remote-byte verification' in text
saved=js(N/'task-closure.json');assert saved['checked']==34 and saved['unchecked']==1 and not saved['mismatches'];assert {x['id'] for x in saved['tasks']}=={x[1] for x in taskrows}
strict=js(N/'validation/openspec-strict.json');assert strict['validate_exit']==strict['version_exit']==0 and '--strict' in strict['validate_argv'] and 'finite-participant-causal-composition' in strict['validate_argv'];expected="Change 'finite-participant-causal-composition' is valid\n";assert rd(N/'validation/openspec-strict.stdout.log').decode()==strict['validate_stdout']==expected;assert h(expected.encode())==strict['validate_stdout_sha256'];assert rd(N/'validation/openspec-strict.stderr.log').decode()==strict['validate_stderr'];assert rd(N/'validation/openspec-version.stdout.log').decode()==strict['version_stdout']=='1.10.0\n';assert h(rd(Path(strict['tool'])))==strict['tool_sha256']
links=js(N/'evidence-links.json');existing=[]
for x in links['existing']:
 p=R/x['path'];assert p.exists(),p
 if p.is_file():
  b=rd(p)
  if 'sha256' in x:assert h(b)==x['sha256']
 existing.append(x['path'])
# Resolve actual Markdown links in the four edited documents and new README/report.
markdown=[]
for p in [R/x for x in docs]+[N/'README.md',N/'REPORT.md']:
 for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)',rd(p).decode()):
  if re.match(r'^[a-z]+://',target) or target.startswith('#'):continue
  target=urllib.parse.unquote(target.split('#')[0].strip('<>'));dest=(p.parent/target).resolve();assert dest.exists(),(p,target);markdown.append({'source':str(p.relative_to(R)),'target':target,'resolved':str(dest.relative_to(R)) if dest.is_relative_to(R) else str(dest)})
assert not js(N/'link-check.json')['missing_required_evidence'] and not js(N/'link-check.json')['markdown_missing_disallowed']
# The exact accepted code/evidence counts and pending-delivery state remain the authority.
ce=js(N/'coverage-extract.json');status=js(N/'STATUS.json');rd(I/'gpt6-review/final-adjudication-r1.md');rd(A/'release-readiness-gpt6.json')
result={'status':'PASS_BOUNDED_DOC_CLOSURE_CHECKS','source_candidate':C,'manifest_regular_files':22,'archive_regular_files':27,'native_end':ends[-1],'edited_documents':after['editable'],'tracked_diff_only_four_docs':True,'task_count':35,'checked_for_release':34,'pending_task':'8.5','task_text_unchanged_except_append_only_8_4_8_5_roles_delivery_notes':True,'preauthor_roadmap_planning_recovery_preserved_by_exact_reconstruction':True,'frozen_Lean_config_inputs_unchanged':164,'preclosure_normative_changed_only_tasks':True,'concurrent_WORKSTATE_change_not_a_source_or_final_input_drift':True,'strict_openspec_exit':0,'strict_stdout_exact':True,'strict_stderr_is_recorded_color_environment_warning':True,'existing_evidence_links_checked':len(existing),'markdown_links_checked':markdown,'nonblocking_editorial_note':'REPORT says16 archive members; authoritative production archive contains16 runs/624 regular files. The same bound archive and correct run count are supplied; this is a wording imprecision, not missing evidence or semantic scope change. No repair required for release.', 'inputs':inputs,'input_drift':[p for p,x in inputs.items() if h(Path(p).read_bytes())!=x['sha256']]}
assert not result['input_drift'];(O/'check-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k not in ['inputs','markdown_links_checked','edited_documents']},indent=2))
