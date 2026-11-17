from pathlib import Path
import subprocess,time,json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-settlement-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/AMM/Settlement.lean').read_text();controls=(r/'lean/DefiKernel/AMM/SettlementAudit.lean').read_text();tail='\n'.join(controls.splitlines()[1:]);marker='theorem full_store_authorities';runs=[]
def execute(name,source,code,required):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();start=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==code and all(v.encode() in q.stdout for v in required),(name,q.returncode,q.stdout[-1000:]);runs.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=start,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=required,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.AMM.Settlement\n'+tail
execute('intact-prefix',prefix(s),0,['SETTLEMENT_OBSERVATION 3 12 20/11 200/11','SETTLEMENT_CONTROL PASSED 15/15'])
a=s.index('  deltas := [');b=s.index('  supplyDeltas :=',a);block=s[a:b];changedAsset=s[:a]+block.replace('⟨.y,','⟨.x,')+s[b:]
a=s.index('def quotePool');b=s.index('\ndef template',a);block=s[a:b];changedQuote=s[:a]+block.replace('⟨pre.balance (.pool, .pool, .x), pre.balance (.pool, .pool, .y)⟩','⟨pre.balance (.pool, .pool, .y), pre.balance (.pool, .pool, .x)⟩')+s[b:]
for name,source,observation in [('output-in-wrong-asset',changedAsset,'SETTLEMENT_OBSERVATION 53/11 112/11 0 20'),('swapped-quote-reserves',changedQuote,'SETTLEMENT_OBSERVATION 3 12 10/21 410/21')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'SETTLEMENT_CONTROL fee_retained_actual_four_balances false','FAIL: actual settlement comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(controls.encode()).hexdigest(),runs=runs,scope='Actual source API prefixes omit own-module import and all semantic proofs; intact Typed/Rational imports. Both mutants execute successfully to explicitly recorded incorrect ledgers, producing false comparison and exit1. Full-source unchanged proof rejections are separate.'),indent=2)+'\n')
