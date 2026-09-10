from pathlib import Path
import json,hashlib,subprocess,datetime,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';w=Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909');o=b/'p19-r16-escaped-key-root-check';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert (b/'p19-roundtrip-proof-agy-r16-terminal-manifest.json').exists(),'R16 not terminal/frozen'
assert not Path('/proc/1902759').exists(),'R16 native author still live'
m=read(b/'p19-roundtrip-proof-agy-r16-terminal-manifest.json')
for f in m['files']:assert h(w/f['path'])==f['sha256'],f['path']
o.mkdir(exist_ok=False);probe=o/'Probe.lean';shutil.copy2(b/'p19-escaped-key-control-preparation/attempt3/Probe.lean',probe);tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');argv=[str(tool/'lake'),'env',str(tool/'lean'),str(probe)];st=datetime.datetime.now(datetime.timezone.utc).isoformat();x=subprocess.run(argv,cwd=w/'lean',capture_output=True,timeout=120);(o/'stdout.log').write_bytes(x.stdout);(o/'stderr.log').write_bytes(x.stderr);d={'started_utc':st,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':argv,'cwd':str(w/'lean'),'exit':x.returncode,'candidate_archive_sha256':m['sha256'],'probe_sha256':h(probe),'stdout_sha256':h(o/'stdout.log'),'stderr_sha256':h(o/'stderr.log'),'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),'acceptance':False};write(o/'receipt.json',d)
if x.returncode==0:
 text=x.stdout.decode();decoder=json.JSONDecoder();rows,i=decoder.raw_decode(text);controls,j=decoder.raw_decode(text[i:].lstrip());assert len(rows)==32 and len(controls)==4
 success=[row for row in rows if row.endswith(';scan=ok;decode=ok;parserObject=ok')]
 duplicates_ok=all(';parser=DefiKernel.Certificates.DecodeFailure.duplicateKey' in c for c in controls[:2]);positive_keys_ok=all(c.endswith(';scan=ok;parser=ok') for c in controls[2:])
 write(o/'assessment.json',{'control_character_cases':32,'roundtrip_successes':len(success),'genuine_duplicate_parser_refusals':duplicates_ok,'quote_backslash_positive_controls':positive_keys_ok,'rows':rows,'other_controls':controls,'scope':'Bounded repair check, not formal admissibility or universal byte roundtrip theorem','acceptance':False});assert len(success)==32 and duplicates_ok and positive_keys_ok,'Scanner repair controls not all satisfied'
else:raise SystemExit('Lean probe failed; raw failure retained, no successful repair credit')
for f in m['files']:assert h(w/f['path'])==f['sha256'],f['path']
shutil.copy2(__file__,o/'verify.py');print(json.dumps({'control_character_roundtrips':len(success),'genuine_duplicate_refusals':duplicates_ok,'quote_backslash_controls':positive_keys_ok,'acceptance':False}))
