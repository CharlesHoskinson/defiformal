from pathlib import Path
import datetime,hashlib,json,re,tarfile,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-tree-text-grok-r1/original-terminal';R=B/'p19-r21-review-original-root-verification';R.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
s=read(O/'root-seal.json');assert len(s['files'])==s['file_count']==55
for n,d in s['files'].items():assert h(O/n)==d,n
cmds=[json.loads(line) for line in (O/'logs/command-index.jsonl').read_text().splitlines() if line.strip()];assert len(cmds)==9 and len({r['id'] for r in cmds})==9
for row in cmds:
 assert read(O/'logs'/row['id']/'meta.json')==row,row['id']
 for stream in ['stdout','stderr']:
  p=O/row[stream+'_path'];assert h(p)==row['raw'+stream+'_sha256'] and p.stat().st_size==row[stream+'_bytes']
m=read(B/'p19-roundtrip-proof-agy-r21-terminal-manifest.json');assert h(B/m['archive'])==m['sha256'];sources=read(O/'logs/frozen-source-hashes.json');names=[]
with tarfile.open(B/m['archive']) as tar:
 for n,row in sources.items():
  data=tar.extractfile('lean/'+n).read();assert hashlib.sha256(data).hexdigest()==row['sha256'] and len(data)==row['bytes'],n
 for name in ['CanonicalJson','Correspondence']:
  text=tar.extractfile('lean/DefiKernel/Certificates/'+name+'.lean').read().decode()
  names+=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',text,re.M)
expected=['DefiKernel.Certificates.'+n for n in names];assert len(expected)==len(set(expected))==448
probe=O/'probes/axioms448/Probe.lean';assert re.findall(r'^#print axioms (\S+)',probe.read_text(),re.M)==expected
meta=read(O/'logs/probe-source-hashes.json');assert h(probe)==meta['axioms448']['sha256']
stdout=(O/'logs/probe-axioms448/stdout').read_text();pairs=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",stdout,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",stdout)
assert len(pairs)==415 and len(zero)==33
assert set(n for n,_ in pairs)|set(zero)==set(expected)
assert all(set(x.strip() for x in a.split(',') if x.strip())<={'propext','Classical.choice','Quot.sound'} for _,a in pairs)
root_stdout=(B/'p19-r21-root-inventory/axioms.stdout').read_bytes();review_stdout=(O/'logs/probe-axioms448/stdout').read_bytes()
assert review_stdout==b'PROBE_AXIOMS_START\n'+root_stdout+b'PROBE_AXIOMS_END\nNAMED=448\n'
root_probe=(B/'p19-r21-root-inventory/Axioms.lean').read_text();actual_probe=probe.read_text()
markers=['#eval IO.println "PROBE_AXIOMS_START"\n','#eval IO.println "PROBE_AXIOMS_END"\n','#eval IO.println "NAMED=448"\n']
for line in markers:assert actual_probe.count(line)==1;actual_probe=actual_probe.replace(line,'')
assert actual_probe==root_probe
build=read(O/'logs/lake-rebuild-correspondence/meta.json');assert build['exit']==0 and build['argv'][-1]=='DefiKernel.Certificates.Correspondence'
build_text=(O/'logs/lake-rebuild-correspondence/stdout').read_text();modules=re.findall(r'Built (DefiKernel\.Certificates\.\w+)',build_text);assert len(modules)==6
assert 'Only 86 of 157 declarations resolved' in (O/'logs/check-axioms-canonicaljson/stdout').read_text()
assert read(O/'logs/check-axioms-canonicaljson/meta.json')['exit']==1
result={'utc':now(),'original_sealed_files_verified':55,'original_command_receipts_verified':9,'original_raw_streams_verified':18,'frozen_source_configuration_hashes_verified':len(sources),'exact_theorem_lemma_count':448,'standard_axiom_records':415,'zero_axiom_records':33,'rebuilt_modules':modules,'target':'DefiKernel.Certificates.Correspondence','build_started_utc':build['start'],'build_finished_utc':build['end'],'scope':'Verified immutable original reviewer receipts/source bindings. This is not final reviewer verdict, new root Lean execution or full P19 acceptance.','root_closeout_brief_correction':'Root closeout brief speculated a set_option line caused different stdout hashes. Exact frozen probe diff instead contains three #eval IO.println marker lines, and these three output lines account for the entire byte difference. There is no set_option difference. Preserve original brief; this record supersedes that causal statement.','failed_inline_helper':'CanonicalJson helper exit1 resolved only86of157; zero complete-file audit credit. Successful exact448 probe supplies proof inventory.','setup_failure':'Initial Python record_cmd import failed before recorder entry; no historical command times/raw streams invented.','final_review_pending':True,'P19_accepted':False}
put(R/'assessment.json',result);shutil.copy2(__file__,R/'verify.py');files={p.name:h(p) for p in R.iterdir() if p.is_file()};put(R/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:v for k,v in result.items() if k not in ['root_closeout_brief_correction','setup_failure','scope','rebuilt_modules']}))
