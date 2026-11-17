from pathlib import Path
import json,subprocess,hashlib,time,datetime,re
p=Path(__file__).resolve().parent;t=Path('/private/tmp/defiformal-p27-tools-author');origin=Path('/private/tmp/defiformal-margin-payment-author/source-helper');methods=json.loads((origin/'method-identifiers.json').read_text());runs=[]
fund='fundingAmount(uint256,uint256,uint256,bool)';pay='payCost(uint256,uint256,uint256,uint256,uint256,uint256)'
cases=[('fee_ceil_positive_remainder',fund,[1,0,10**45+1,1],[2]),('long_claim_floor',fund,[2,0,10**45+1,0],[2]),('short_claim_floor',fund,[3,0,10**45+1,0],[3]),('fee_snapshot_delta',fund,[11,10,10**45+1,1],[2]),('claim_snapshot_delta',fund,[13,10,10**45+1,0],[3]),('zero_delta_fee',fund,[10,10,10**45+1,1],[0]),('zero_size_fee',fund,[1,0,0,1],[0])]
failures=[]
for name,method,values,expected in cases+failures:
 calldata=methods[method]+''.join(f'{v:064x}' for v in values);dest=p/'invocations'/name;dest.mkdir(parents=True);(dest/'input.hex').write_text(calldata+'\n');argv=[str(t/'bin/evm'),'run','--prestate',str(t/'cancun-genesis.json'),'--codefile',str(origin/'runtime.hex'),'--inputfile',str(dest/'input.hex'),'--sender','0x'+'11'*20,'--receiver','0x'+'22'*20];started=datetime.datetime.now(datetime.timezone.utc).isoformat();clock=time.monotonic();q=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=20);(dest/'stdout.bin').write_bytes(q.stdout);(dest/'stderr.bin').write_bytes(q.stderr);text=q.stdout.decode();lines=text.splitlines();match=re.fullmatch(r'0x([0-9a-f]*)',lines[0] if lines else '');assert match and q.returncode==0 and not q.stderr,(name,q.returncode,text,q.stderr);raw=bytes.fromhex(match[1]);actual=None
 if isinstance(expected,list):
  assert len(lines)==1 and len(raw)==32*len(expected),(name,text)
  actual=[int.from_bytes(raw[i:i+32],'big') for i in range(0,len(raw),32)];passed=actual==expected;classification='successful_helper_value'
 else:
  assert 'error: execution reverted' in text,(name,text)
  passed=raw==bytes.fromhex('4e487b71')+expected.to_bytes(32,'big');actual=dict(panic_code=int.from_bytes(raw[4:],'big'),raw_revert_hex=raw.hex());classification='arithmetic_failure_outside_admissible_financial_domain'
 record=dict(name=name,method=method,arguments=values,expected=expected,actual=actual,classification=classification,pass_=passed,argv=argv,cwd=str(Path.cwd()),started_utc=started,wall_seconds=time.monotonic()-clock,exit=q.returncode,calldata_sha256=hashlib.sha256(bytes.fromhex(calldata)).hexdigest(),runtime_sha256=hashlib.sha256(bytes.fromhex((origin/'runtime.hex').read_text().strip())).hexdigest(),evm_sha256=hashlib.sha256((t/'bin/evm').read_bytes()).hexdigest(),genesis_sha256=hashlib.sha256((t/'cancun-genesis.json').read_bytes()).hexdigest(),stdout_sha256=hashlib.sha256(q.stdout).hexdigest(),stderr_sha256=hashlib.sha256(q.stderr).hexdigest());(dest/'record.json').write_text(json.dumps(record,indent=2)+'\n');runs.append(record);print(name,classification,actual,passed,flush=True);assert passed,name
assert len(runs)==7
(p/'campaign.json').write_text(json.dumps(dict(status='PASS',successful_helper_invocations=7,arithmetic_failure_invocations=0,runs=runs,scope='Actual unchanged internal source helpers through pinned wrapper runtime under Cancun. No full GMX admission, exceptional event/handler, deployed identity or universal source refinement claim.'),indent=2)+'\n')
