from pathlib import Path
import json,hashlib,subprocess,time,datetime,re
p=Path(__file__).resolve().parent;t=Path('/private/tmp/defiformal-p27-tools-author');methods=json.loads((p/'method-identifiers.json').read_text());compiled=json.loads((p/'standard-output-r2.json').read_text());errors=compiled['contracts']['P27BranchProbe.sol']['P27ErrorSignatures']['evm']['methodIdentifiers'];rows=[]
word=lambda n:(n%(2**256)).to_bytes(32,'big')
def words(values):return b''.join(map(word,values))
def string(s):
 b=s.encode();return word(len(b))+b+b'\0'*((-len(b))%32)
def financial(signature,static,tail=''):return bytes.fromhex(errors[signature])+words(static)+string(tail)
healthy=financial('PositionShouldNotBeLiquidated(string,int256,int256,int256)',[128,13,1,4])
def insuff(n,step):return financial('InsufficientFundsToPayForCosts(uint256,string)',[n,64],step)
health='selectedHealth(uint256[5],int256[2],bool,bool)';reason='healthReason(uint256[5],int256[2])';empty='emptyFees(uint256[8])';early='early(uint256[8],uint256[3],bool,bool,uint8)';fund='fundingStage(uint256[9])'
healthyIn=[5,3,1,1,4,2,-1];minIn=[1,3,2,1,4,0,0];zeroIn=[0,3,0,0,0,0,0];leverageIn=[1,3,0,1,4,0,0];fees=[5,7,11,13,17,19,23,18];projection=[0,7,11,13,17,19,0,0,2,3]
cases=[
('healthy_liquidation_refusal',health,healthyIn+[1,0],'financial_revert',healthy),
('healthy_liquidation_adl_does_not_bypass_guard',health,healthyIn+[1,1],'financial_revert',healthy),
('ordinary_route_omits_selected_liquidation_guard',health,healthyIn+[0,0],'successful_value',words([13,1,4])),
('ordinary_adl_route_omits_selected_liquidation_guard',health,healthyIn+[0,1],'successful_value',words([13,1,4])),
('min_collateral_liquidatable',health,minIn+[1,0],'successful_value',words([-3,1,4])),
('zero_equity_liquidatable',health,zeroIn+[1,0],'successful_value',words([0,0,0])),
('leverage_liquidatable',health,leverageIn+[1,0],'successful_value',words([3,1,4])),
('healthy_reason_empty',reason,healthyIn,'successful_value',words([0,64])+string('')),
('min_collateral_priority_reason',reason,minIn,'successful_value',words([1,64])+string('min collateral')),
('nonpositive_equity_priority_reason',reason,zeroIn,'successful_value',words([1,64])+string('< 0')),
('leverage_priority_reason',reason,leverageIn,'successful_value',words([1,64])+string('min collateral for leverage')),
('actual_empty_fees_retains_claims_snapshots_prices',empty,fees,'successful_value',words(projection)),
('full_liquidation_allowed_exception_projection',early,fees+[10,10,4,1,0,0],'successful_value',words([1]+projection)),
('full_adl_allowed_exception_projection',early,fees+[10,10,7,0,1,3],'successful_value',words([1]+projection)),
('full_liquidation_adl_allowed_exception_projection_after_admission',early,fees+[10,10,4,1,1,2],'successful_value',words([1]+projection)),
('ordinary_full_close_residual_refusal',early,fees+[10,10,4,0,0,1],'financial_revert',insuff(4,'pnl')),
('partial_liquidation_residual_refusal',early,fees+[10,9,4,1,0,0],'financial_revert',insuff(4,'funding')),
('partial_adl_residual_refusal',early,fees+[10,9,7,0,1,3],'financial_revert',insuff(7,'impact')),
('positive_funding_primary_helper_and_branch',fund,[1,0,10**45+1,3,2,0,3,0,0],'successful_value',words([2,2,0,0,0,0])),
('positive_funding_secondary_helper_and_branch',fund,[1,0,10**45+1,3,2,0,0,3,1],'successful_value',words([2,0,3,0,1,3])),
('partial_funding_secondary_helper_and_branch',fund,[1,0,10**45+1,3,2,0,0,1,1],'successful_value',words([2,0,1,4,1,1])),
('secondary_funding_missing_holding_refusal',fund,[1,0,10**45+1,3,2,0,0,3,0],'financial_revert',bytes.fromhex(errors['EmptyHoldingAddress()'])),
('funding_underflow_arithmetic_domain_failure',fund,[0,1,1,3,2,0,0,0,0],'arithmetic_panic',bytes.fromhex('4e487b71')+word(0x11))]
assert len(cases)==23
for name,method,args,classification,expected in cases:
 d=p/'invocations'/name;d.mkdir(parents=True);calldata=bytes.fromhex(methods[method])+words(args);(d/'input.hex').write_text(calldata.hex()+'\n');argv=[str(t/'bin/evm'),'run','--prestate',str(t/'cancun-genesis.json'),'--codefile',str(p/'runtime.hex'),'--inputfile',str(d/'input.hex'),'--sender','0x'+'11'*20,'--receiver','0x'+'22'*20];clock=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=20);(d/'stdout.bin').write_bytes(q.stdout);(d/'stderr.bin').write_bytes(q.stderr);lines=q.stdout.decode().splitlines();match=re.fullmatch('0x([0-9a-f]*)',lines[0] if lines else '');assert match and q.returncode==0 and not q.stderr,(name,q.returncode,q.stdout,q.stderr);actual=bytes.fromhex(match[1]);semantic_success=len(lines)==1
 assert semantic_success==(classification=='successful_value') and (semantic_success or (len(lines)==2 and lines[1].strip()=='error: execution reverted')),(name,q.stdout)
 record=dict(name=name,method=method,arguments=args,classification=classification,pass_=actual==expected,expected_raw_hex=expected.hex(),actual_raw_hex=actual.hex(),process_exit=q.returncode,semantic_success=semantic_success,argv=argv,cwd=str(Path.cwd()),started_utc=started,wall_seconds=time.monotonic()-clock,runtime_sha256=hashlib.sha256(bytes.fromhex((p/'runtime.hex').read_text().strip())).hexdigest(),runtime_file_sha256=hashlib.sha256((p/'runtime.hex').read_bytes()).hexdigest(),calldata_sha256=hashlib.sha256(calldata).hexdigest(),input_file_sha256=hashlib.sha256((d/'input.hex').read_bytes()).hexdigest(),stdout_sha256=hashlib.sha256(q.stdout).hexdigest(),stderr_sha256=hashlib.sha256(q.stderr).hexdigest(),evm_sha256=hashlib.sha256((t/'bin/evm').read_bytes()).hexdigest(),genesis_sha256=hashlib.sha256((t/'cancun-genesis.json').read_bytes()).hexdigest());(d/'record.json').write_text(json.dumps(record,indent=2)+'\n');rows.append(record);print(name,classification,record['pass_'],flush=True);assert record['pass_'],(name,actual.hex(),expected.hex())
assert len(rows)==23 and all(x['pass_'] for x in rows)
(p/'campaign.json').write_text(json.dumps(dict(status='PASS',source_commit='a85ea3491c19c93bb4b5a002d9b358fb769b7849',successful_values=16,financial_reverts=6,arithmetic_panics=1,scope='Fresh conditional branch adapter with exact source excerpts/declared upstream stubs and unchanged pure library helpers. No original handler/storage/events/deployed-equivalence or universal simulation claim.',runs=rows),indent=2)+'\n')
