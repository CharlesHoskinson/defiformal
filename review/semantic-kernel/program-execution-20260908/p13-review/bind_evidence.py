#!/usr/bin/env python3
import datetime, gzip, hashlib, json, pathlib, re, shutil, subprocess, tarfile
OUT=pathlib.Path(__file__).resolve().parent
ROOT=pathlib.Path('/home/charl/defiformal')
CAND=pathlib.Path('/home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate')
NATIVE=pathlib.Path('/home/charl/defiformal-wt-honest-gate-grok-gpt6-20260908/review/semantic-kernel/program-loop-20260908/native-worker')
sha=lambda b:hashlib.sha256(b).hexdigest()
def parse(data):
    txt=data.decode()
    summaries=re.findall(r'^===== negtest-reporting: (\d+) caught, (\d+) missed =====$',txt,re.M)
    caught=len(re.findall(r'^  CAUGHT ',txt,re.M))
    missed=len(re.findall(r'^  MISSED ',txt,re.M))
    assert len(summaries)==1 and [caught,missed]==list(map(int,summaries[0]))
    return dict(caught=caught,missed=missed,assertions=caught+missed,missed_lines=[l for l in txt.splitlines() if l.startswith('  MISSED ')],stdout_sha256=sha(data))
history={}
for name in ['honest-gate-closeout-r1','honest-gate-clean-closeout-r2']:
    archive=NATIVE/(name+'-stage.tar.gz')
    receipt=json.loads((NATIVE/(name+'.json')).read_text())
    gz=NATIVE/(name+'.jsonl.gz')
    raw=gzip.decompress(gz.read_bytes())
    assert sha(raw)==receipt['raw_sha256']
    members={}; runs=[]
    with tarfile.open(archive) as tar:
        for m in tar.getmembers():
            if m.isfile(): members[m.name]=sha(tar.extractfile(m).read())
        source=tar.extractfile('formal/v3/negtest-reporting.sh').read()
        assert source==(CAND/'formal/v3/negtest-reporting.sh').read_bytes()
        for m in tar.getmembers():
            if m.isfile() and m.name.endswith('/stdout.txt') and '/execution/' in m.name:
                data=tar.extractfile(m).read()
                if b'===== negtest-reporting:' in data:
                    run=parse(data)
                    run['member']=m.name
                    run['exit']=int(tar.extractfile(str(pathlib.PurePosixPath(m.name).parent/'exit.txt')).read())
                    runs.append(run)
    history[name]=dict(archive=str(archive),archive_sha256=sha(archive.read_bytes()),member_sha256=members,runs=runs,receipt=str(NATIVE/(name+'.json')),receipt_sha256=sha((NATIVE/(name+'.json')).read_bytes()),jsonl_gz=str(gz),jsonl_gz_sha256=sha(gz.read_bytes()),decompressed_sha256=sha(raw),receipt_raw_hash_matches=True,process_exit_from_retained_receipt=receipt['exit_code'])
fresh=parse((OUT/'logs/harness.stdout').read_bytes())
fresh.update(json.loads((OUT/'harness-command.json').read_text()))
fresh['stderr_sha256']=sha((OUT/'logs/harness.stderr').read_bytes())
fresh['stderr_bytes']=(OUT/'logs/harness.stderr').stat().st_size
(OUT/'harness-parse.json').write_text(json.dumps(fresh,indent=2)+'\n')
(OUT/'historical-bindings.json').write_text(json.dumps(history,indent=2)+'\n')
old=json.loads((OUT/'r1-candidate-closure.json').read_text())['code_inputs_now']
closure={}
for rel, meta in old.items():
    a=sha((CAND/rel).read_bytes()); b=sha((ROOT/rel).read_bytes())
    assert a==meta['sha256']
    closure[rel]=dict(historical_sha256=meta['sha256'],candidate_sha256=a,primary_sha256=b,candidate_matches_historical=True,primary_matches_candidate=a==b)
before=json.loads((OUT/'before.json').read_text())
final={}
for key,base in [('candidate_files',CAND),('primary_files',ROOT)]:
    now={p:sha((base/p).read_bytes()) for p in before[key]}
    final[key+'_count']=len(now)
    final[key+'_changed']=[p for p in now if now[p]!=before[key][p]]
    assert not final[key+'_changed']
final['candidate_status']=subprocess.check_output(['git','status','--porcelain'],cwd=CAND,text=True)
final['candidate_head']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=CAND,text=True).strip()
final['primary_head']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
final['tmp_exists']=pathlib.Path('/tmp/negtest-reporting').exists()
assert not final['candidate_status'] and not final['tmp_exists']
final['sole_source_delta']=subprocess.check_output(['git','diff','HEAD^','HEAD','--name-only'],cwd=CAND,text=True).splitlines()
assert final['sole_source_delta']==['formal/v3/negtest-reporting.sh']
final['utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
(OUT/'current-dependency-binding.json').write_text(json.dumps(dict(historical_code_inputs=closure,bound_reporting_input_count=len(before['candidate_files']),current_primary_differences=before['primary_candidate_differences'],final_preservation=final),indent=2)+'\n')
patch=subprocess.check_output(['git','diff','HEAD^','HEAD','--','formal/v3/negtest-reporting.sh'],cwd=CAND)
(OUT/'candidate-source.diff').write_bytes(patch)
toolrows=[]
for cmd in [['bash','--version'],['node','--version'],['python3','--version'],['pdflatex','--version'],['bibtex','--version'],['git','--version']]:
    run=subprocess.run(cmd,capture_output=True,text=True,timeout=10)
    toolrows.append(dict(argv=cmd,path=shutil.which(cmd[0]),exit=run.returncode,stdout=run.stdout,stderr=run.stderr))
(OUT/'tool-identities.json').write_text(json.dumps(toolrows,indent=2)+'\n')
print(json.dumps(dict(fresh=fresh,historical_runs={k:v['runs'] for k,v in history.items()},final=final),indent=2))
