from pathlib import Path
import json,hashlib,re,subprocess,datetime
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-rational-inverse-grok-r1';p=o/'root-verification';sha=lambda q:hashlib.sha256(q.read_bytes()).hexdigest();write=lambda q,d:q.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2028868').exists()
assert (o/'process.json').exists();inputs=json.loads((o/'inputs.json').read_text());sandbox=Path(inputs['sandbox'])
for n,h in inputs['files'].items():assert sha(sandbox/n)==h,n
private=o/'private-lean';sourcehashes={};names=[]
for n in ['CanonicalJson','Encode','Decode','Correspondence','Schema','Check']:
 rel=Path('DefiKernel/Certificates')/(n+'.lean');q=private/rel;assert sha(q)==sha(sandbox/'lean'/rel);sourcehashes[str(rel)]=sha(q)
 if n in ['CanonicalJson','Correspondence']:names+=re.findall(r'^\s*(?:theorem|lemma)\s+(\S+)',q.read_text(),re.M)
assert len(names)==299 and len(set(names))==299
p.mkdir(exist_ok=False)
probe=p/'Axioms299.lean';probe.write_text('import DefiKernel.Certificates.Correspondence\n'+''.join('#print axioms DefiKernel.Certificates.'+n+'\n' for n in names))
write(p/'setup.json',{'schema':'defiformal-root-frozen-review-verification/v1','candidate_archive_sha256':inputs['candidate_archive_sha256'],'frozen_inputs_verified':len(inputs['files']),'reviewer_manifest_pending':True,'source_hashes':sourcehashes,'private_lean':str(private),'declarations':names,'acceptance':False})
tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');argv=[str(tool/'lake'),'env',str(tool/'lean'),str(probe)];st=datetime.datetime.now(datetime.timezone.utc).isoformat();res=subprocess.run(argv,cwd=private,capture_output=True,timeout=120);(p/'axioms299.stdout').write_bytes(res.stdout);(p/'axioms299.stderr').write_bytes(res.stderr)
out=res.stdout.decode();records=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",out,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",out);got=[n for n,_ in records]+zero;want=['DefiKernel.Certificates.'+n for n in names];bad=[{'name':n,'axioms':ax} for n,ax in records if set(x.strip() for x in ax.split(',') if x.strip())-{'propext','Classical.choice','Quot.sound'}]
rec={'schema':'defiformal-root-axiom-audit/v1','started_utc':st,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':argv,'cwd':str(private),'exit':res.returncode,'probe_sha256':sha(probe),'stdout_sha256':sha(p/'axioms299.stdout'),'stderr_sha256':sha(p/'axioms299.stderr'),'axiom_records':len(records),'zero_axiom_records':len(zero),'exact_names_match':set(got)==set(want),'forbidden':bad,'lean_sha256':sha(tool/'lean'),'lake_sha256':sha(tool/'lake'),'acceptance':False};write(p/'axioms299-command.json',rec);print(json.dumps(rec));assert res.returncode==0 and len(got)==299 and set(got)==set(want) and not bad
