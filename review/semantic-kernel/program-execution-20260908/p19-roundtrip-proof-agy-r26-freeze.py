import datetime,gzip,hashlib,json,subprocess,tarfile,os
from pathlib import Path
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908'
w=Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
process_path=b/'p19-roundtrip-proof-agy-r26-process.json'
if not process_path.exists():
    raise SystemExit('Freeze blocked: terminal process receipt missing; live work remains untouched.')
process=read(process_path)
dispatch=read(b/'p19-roundtrip-proof-agy-r26-dispatch.json')
assert not Path('/proc') .joinpath(str(dispatch['pid'])).exists(),'Native author PID still present'
assert not (b/'p19-roundtrip-proof-agy-r26-terminal-manifest.json').exists()
live=[]
for p in Path('/proc').iterdir():
    if not p.name.isdigit():continue
    try:
        cwd=(p/'cwd').resolve();name=(p/'comm').read_text().strip()
    except (OSError,RuntimeError):continue
    if (str(cwd).startswith(str(w)) or str(cwd).startswith('/tmp/p19-mirror')) and name in ['lean','lake','agy','python3','python','node']:
        live.append({'pid':int(p.name),'name':name,'cwd':str(cwd)})
assert not live,live
prior=read(b/'p19-implementation-agy-r1-partial-manifest.json')
planning=[f for f in prior['files'] if f['path'] not in prior['new_implementation_files']]
for f in planning:assert sha(w/f['path'])==f['sha256'],f['path']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=w,text=True).strip()==prior['base_commit'], 'Detached source base moved'
previous=read(b/'p19-roundtrip-proof-agy-r25-terminal-manifest.json')
prior_evidence=[f for f in previous['files'] if f['path'].startswith('review/semantic-kernel/certificates/p19/implementation/')]
for f in prior_evidence:assert sha(w/f['path'])==f['sha256'], 'Frozen historical author evidence changed: '+f['path']

files={f['path'] for f in planning}
excluded_cache_dirs=[]
for directory in ['lean/DefiKernel/Certificates','review/semantic-kernel/certificates/p19/implementation']:
    for parent,dirs,names in os.walk(w/directory):
        for name in list(dirs):
            if name in ['.lake','.git','__pycache__']:
                excluded_cache_dirs.append(str((Path(parent)/name).relative_to(w)))
                dirs.remove(name)
        for name in names:
            p=Path(parent)/name
            if p.is_symlink():
                excluded_cache_dirs.append(str(p.relative_to(w)))
                continue
            if p.is_file():files.add(str(p.relative_to(w)))
for pattern in ['*certificate*', 'run_all_p19_mutations.py']:
    for p in (w/'scripts').glob(pattern):
        if p.is_file():files.add(str(p.relative_to(w)))
records=[{'path':n,'sha256':sha(w/n),'bytes':(w/n).stat().st_size} for n in sorted(files)]
arc=b/'p19-roundtrip-proof-agy-r26-terminal.tar.gz'
with tarfile.open(arc,'w:gz') as t:
    for f in records:t.add(w/f['path'],arcname=f['path'],recursive=False)
for f in records:assert sha(w/f['path'])==f['sha256'],f['path']
with tarfile.open(arc) as t:
    for f in records:assert hashlib.sha256(t.extractfile(f['path']).read()).hexdigest()==f['sha256']
log=Path(dispatch['log']);loghash=sha(log)
assert loghash==process['log_sha256'], 'Terminal native log changed'
init_events=[]
for line in log.read_text().splitlines():
    try:event=json.loads(line)
    except json.JSONDecodeError:continue
    if event.get('event')=='init':init_events.append(event)
assert len(init_events)==1, 'Expected one fresh native author init'
write(b/'p19-roundtrip-proof-agy-r26-native-init.json',init_events[0])
with (b/'p19-roundtrip-proof-agy-r26-native.jsonl.gz').open('wb') as out:
    with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as g:g.write(log.read_bytes())
assert len(process['sessions'])==1, process['sessions']
conversation_id=process['sessions'][0]
scratch=Path('/home/charl/.gemini/antigravity-cli/brain')/conversation_id/'scratch'
scratchfiles=[p for p in scratch.rglob('*') if p.is_file() and not p.is_symlink()]
scratchfiles += [p for p in Path('/tmp').glob('p19*') if p.is_file() and p.suffix in ['.lean','.py','.json','.log']]
for n in ['test_soundness_addition.lean','run_all_16.py']:
    if (Path('/tmp')/n).is_file():scratchfiles.append(Path('/tmp')/n)
scratchfiles=sorted(set(scratchfiles))
scratcharc=b/'p19-roundtrip-proof-agy-r26-terminal-scratch.tar.gz'
with tarfile.open(scratcharc,'w:gz') as t:
    for p in scratchfiles:t.add(p,arcname=str(p).lstrip('/'),recursive=False)
mirrorrecord=None
historical_mirror=previous.get('historical_mutation_source_repository')
record={'schema':'defiformal-p19-terminal-author-freeze/v1','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'worktree':str(w),'base_commit':prior['base_commit'],'archive':arc.name,'sha256':sha(arc),'files':records,'file_count':len(records),'historical_planning_files_unchanged':len(planning),'root_AGENTS_delta_excluded':True,'requested_model':'gemini-3.8-flash-high','native_init':'p19-roundtrip-proof-agy-r26-native-init.json','reported_models':process['reported_models'],'conversation_id':conversation_id,'native_process_exit':process['process_exit'],'native_process_receipt':'p19-roundtrip-proof-agy-r26-process.json','native_log_sha256':loghash,'native_gzip_sha256':sha(b/'p19-roundtrip-proof-agy-r26-native.jsonl.gz'),'terminal_scratch_archive_sha256':sha(scratcharc),'terminal_scratch_files':{str(p):sha(p) for p in scratchfiles},'mutation_source_repository':mirrorrecord,'assessment':'terminal_snapshot_pending_root_completeness_assessment','acceptance':False,'whole_program_complete':False}
record['excluded_rebuildable_cache_paths']=excluded_cache_dirs
record['previous_author_evidence_files_unchanged']=len(prior_evidence)
record['historical_mutation_source_repository']=historical_mirror
record['new_full_mutation_campaign_verified']=False
record['scratch_scope']='Native conversation scratch plus retained p19-named temporary diagnostics; inclusion does not claim fresh execution'
record['skill_resumption_record']='agy-grok-lean4-resumption-20260910.json'
write(b/'p19-roundtrip-proof-agy-r26-terminal-manifest.json',record)
print(json.dumps({'file_count':len(records),'archive_sha256':record['sha256'],'assessment':record['assessment'],'acceptance':False}))
