from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-margin-funding-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Margin/Funding.lean').read_text();control=(r/'lean/DefiKernel/Margin/FundingAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='/-- Both obligations';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):
 helpers=source[source.index('def signedFundingCharge'):source.index('theorem signedFundingCharge_nonpositive')]
 return source[:source.index(marker)]+helpers+'\nend DefiKernel.Margin.Funding\n'+tail
execute('intact-prefix',prefix(s),0,['FUNDING_OBSERVATION 0 3 8 11 0 0 true','FUNDING_CONTROL PASSED 21/21'])
wrongfee=s.replace('(position.sizeUsd*(latest.fee-position.snapshots.fee)+precision-1)/precision','position.sizeUsd*(latest.fee-position.snapshots.fee)/precision',1)
wrongadvance=s.replace('return (⟨after,before.position⟩','return (⟨after,{before.position with snapshots:=latest}⟩',1)
a=s.index('def holdingTemplate');b=s.index('private def registry',a)
wrongclaim=s[:a]+s[a:b].replace('.claimSecondary .holding','.claimSecondary .owner')+s[b:]
for name,source,label,observation in [('fee_floor_instead_of_ceil',wrongfee,'fee_paid_pending_claims_and_snapshots_preserved','FUNDING_QUOTE 1 2 3'),('premature_snapshot_commit',wrongadvance,'fee_paid_pending_claims_and_snapshots_preserved','FUNDING_OBSERVATION 0 3 8 11 0 0 true'),('collateral_claim_wrong_owner',wrongclaim,'secondary_payment_records_separate_holding_claim','FUNDING_OBSERVATION 0 3 5 14 0 0 true')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'FUNDING_CONTROL '+label+' false','FAIL: actual first funding comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Altered actual Funding implementation prefix imports unchanged accepted PaymentSettlement. Runtime observations with false exact comparisons are distinct from rejection by unchanged full generic proofs. No altered-source cache is used.'),indent=2)+'\n')
