from pathlib import Path
import json,hashlib,tarfile,re,collections,subprocess,difflib
S=Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r3');O=Path(__file__).parent;R=O.parent
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((R/'grok-r3-frozen-inputs.json').read_text());assert all(H(S/p)==h for p,h in f['files'].items())
assert H(R/f['archive'])==f['archive_sha256']
with tarfile.open(R/f['archive']) as t:
 d={x.name.removeprefix('./'):hashlib.sha256(t.extractfile(x).read()).hexdigest() for x in t.getmembers() if x.isfile()}
assert all(d.get(p)==h for p,h in f['files'].items())
old=json.loads((R/'grok-r2-frozen-inputs.json').read_text());changed=[p for p,h in old['files'].items() if p.startswith('lean/') and H(S/p)!=h];assert changed==['lean/DefiKernel/Certificates/Lexical.lean'],changed
p='lean/DefiKernel/Certificates/Lexical.lean';a=(S/'baseline-grok-r2'/p).read_text();b=(S/p).read_text()
ops=difflib.SequenceMatcher(None,a.splitlines(True),b.splitlines(True)).get_opcodes();assert all(x[0] in ['equal','insert'] for x in ops)
D=lambda s:[{'kind':m[1],'name':m[2]} for m in re.finditer(r'^\s*(?:private\s+)?(theorem|def|lemma|abbrev)\s+([^\s(:]+)',re.sub(r'/\-.*?\-/|--[^\n]*','',s,flags=re.S),re.M)]
# Strip block and line comments separately to avoid DOTALL line-comment overreach.
def decls(s):
 s=re.sub(r'/\-.*?\-/','',s,flags=re.S);s=re.sub(r'--[^\n]*','',s)
 return [{'kind':m[1],'name':m[2]} for m in re.finditer(r'^\s*(?:private\s+)?(theorem|def|lemma|abbrev)\s+([^\s(:]+)',s,re.M)]
auth=decls(b);prior=decls(a);new=[r for r in auth if r not in prior];assert len(auth)==116 and len(new)==53
rt=decls((S/'lean/DefiKernel/Certificates/Roundtrip.lean').read_text());counts=dict(collections.Counter(x['kind'] for x in rt));assert counts=={'def':45,'theorem':246},counts
(O/'inventory.json').write_text(json.dumps(dict(full_lexical=auth,new_R3=new,R2=prior,roundtrip=counts,changed_sources=changed,all_existing_lexical_bytes_preserved=True),indent=2))
P=S/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r3'
m=json.loads((P/'MANIFEST.json').read_text());bad=[]
for row in m['files']:
 p=S/row['path'] if row['path'].startswith('lean/') else P/row['path']
 if H(p)!=row['sha256'] or p.stat().st_size!=row['bytes']:bad.append(str(p))
assert not bad,bad
sm=json.loads((P/'source-manifest.json').read_text());assert all(H(S/p)==r['sha256'] for p,r in sm['sources'].items())
commands=json.loads((P/'commands.json').read_text());assert len(commands)==8
for c in commands:
 assert c==json.loads((P/'logs'/c['id']/'command.json').read_text())
 for st in ['stdout','stderr']:assert H(P/c[st+'_path'])==c[st+'_sha256']
 assert c['source_sha256_before']==c['source_sha256_after']
 assert c['started_utc'] < c['finished_utc'] < sm['timestamp_utc']
for ident in ['build-lexical-checkbytes','build-verify-final','print-axioms-final']:
 c=next(c for c in commands if c['id']==ident)
 assert all(H(S/p)==h for p,h in c['source_sha256_after'].items())
 if ident=='print-axioms-final':assert list(c['probe_inputs'].values())==[H(P/'probes/PrintAxioms.lean')]
# No author worktree reads: binary and recorder identities use installed/root recorder only.
for c in commands:
 assert H(Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lean'))==c['lean_sha256']
 assert H(Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake'))==c['lake_sha256']
 assert H(R/'record-author-r3-command.py')==c['recorder_sha256']
pins=[]
for p in json.loads((S/'lean/lake-manifest.json').read_text())['packages']:
 q=S/'lean/.lake/packages'/p['name'];head=subprocess.check_output(['git','-C',str(q),'rev-parse','HEAD'],text=True).strip();assert head==p['rev'];pins.append({'name':p['name'],'rev':head})
assert len(pins)==9
summary=dict(frozen_files=475,archive_sha256=f['archive_sha256'],author_manifest_bindings=len(m['files']),source_bindings=len(sm['sources']),commands={c['id']:c['exit'] for c in commands},author_seal_after_all_commands=True,final_source_receipts_match=True,private_dependency_pins=pins,author_seal_missing_subprocess_telemetry=True,roundtrip=counts,new_authored=53,full_authored=116)
(O/'evidence-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
