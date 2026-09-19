import pathlib,json,hashlib,shutil,tarfile,datetime
A=pathlib.Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909'); O=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919'); S=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r4')
E=pathlib.Path('review/semantic-kernel/certificates/p19/implementation/grok-20260919-r4')
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
old=json.loads((O/'grok-r3-frozen-inputs.json').read_text()); base=json.loads((O/'grok-r4-start-baseline.json').read_text())
files={}; origins={}; mismatches=[]
def copy(p,r,origin):
 assert p.is_file() and not p.is_symlink(),str(p)
 q=S/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);files[str(r)]=h(q);origins[str(r)]=origin;assert h(p)==h(q)
for r in set(old['files'])|set(base['files']):
 p=A/r
 if p.exists():copy(p,pathlib.Path(r),'author_terminal')
 else:copy(pathlib.Path(old['sandbox'])/r,pathlib.Path(r),'inherited_R3_evidence')
for root in ['lean','scripts','openspec/changes/serialized-certificates','openspec/changes/reusable-verification-platform-program',str(E),'review/semantic-kernel/certificates/p19/implementation/agy-r5/mutant-specs']:
 for p in (A/root).rglob('*'):
  if p.is_file() and not p.is_symlink() and not set(p.relative_to(A).parts)&{'.lake','.git','__pycache__','node_modules'}:copy(p,p.relative_to(A),'author_terminal')
sm=json.loads((A/E/'source-manifest.json').read_text())
for r,v in sm['files'].items():
 copy(A/r,pathlib.Path(r),'author_terminal_source_manifest')
 if h(A/r)!=v['sha256']:mismatches.append('source:'+r)
m=json.loads((A/E/'MANIFEST.json').read_text())
for r,v in m['files'].items():
 if not (A/E/r).is_file() or h(A/E/r)!=v['sha256']:mismatches.append('evidence:'+r)
for p in pathlib.Path('/tmp/p19-r4-mutants-all').rglob('*'):
 if p.is_file():copy(p,pathlib.Path('root-supplement/mutants-all')/p.relative_to('/tmp/p19-r4-mutants-all'),'external_terminal_mutant_evidence')
for n in ['AGENTS.md','.claude/skills/defi-footguns/SKILL.md','formal/v3/GATE-REGISTER.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md']:
 copy(A/n,pathlib.Path(n),'author_terminal_instructions')
changes=[r for r,sha in files.items() if r in base['files'] and sha!=base['files'][r]]
archive=O/'grok-r4-frozen-source.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for r in sorted(files):t.add(S/r,arcname=r,recursive=False)
d={'schema':'defiformal-frozen-review-input/v1','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'candidate':'Grok20260919R4 P19 runtime/evidence and partial P20','requested_model':'grok-4.6','reported_model':'grok-4.6-build','process_exit':0,'sandbox':str(S),'files':files,'origins':origins,'count':len(files),'changed_baseline_sources':changes,'archive':archive.name,'archive_sha256':h(archive),'author_manifest_sha256':h(A/E/'MANIFEST.json'),'author_manifest_mismatches':mismatches,'baseline':'grok-r4-start-baseline.json','external_evidence_note':'Full /tmp/p19-r4-mutants-all copied under root-supplement/mutants-all; author seal covers only author selected receipt subset. No acceptance inferred.','acceptance':False}
(O/'grok-r4-frozen-inputs.json').write_text(json.dumps(d,indent=2)+'\n')
print(json.dumps({k:d[k] for k in ['count','archive_sha256','author_manifest_mismatches','changed_baseline_sources']},indent=2))
