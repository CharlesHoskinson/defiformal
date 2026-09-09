import sys,json,hashlib
from pathlib import Path
root=Path(sys.argv[1]);out=Path(sys.argv[2])
sys.dont_write_bytecode=True;sys.path.insert(0,str(root/'scripts/token0_p16'))
from p16_evm import classify_evm_stdout
cases=[]
for error,klass in [('error: execution reverted','evm_revert'),('error: invalid opcode: INVALID','evm_exception')]:
 for count in (0,1,2):
  cases.append((f'{klass}_payloads_{count}', '\n'+('0x\n'*count)+error+'\n',klass if count<2 else 'unknown_output',0,False))
word='0x'+'0'*63+'1'
cases.extend([
 ('success',word+'\n','success',0,False),
 ('duplicate_abi',word+'\n'+word+'\n','unknown_output',0,False),
 ('duplicate_error','error: execution reverted\nerror: execution reverted\n','unknown_output',0,False),
 ('mixed_abi_empty',word+'\n0x\n','unknown_output',0,False),
 ('unknown_error','error: unrecognized diagnostic failure\n','unknown_output',0,False),
 ('extra_text','0x\nerror: execution reverted\nextra\n','unknown_output',0,False),
 ('failed_process','error: execution reverted\n','process_failure',1,False),
 ('timeout','error: execution reverted\n','process_timeout',0,True),
])
rows=[]
for name,text,want,code,timeout in cases:
 got=classify_evm_stdout(text,code,timeout)
 rows.append({'name':name,'stdout':text,'expected_class':want,'actual':got,'pass':got['class']==want})
report={'source':str(root/'scripts/token0_p16/p16_evm.py'),'source_sha256':hashlib.sha256((root/'scripts/token0_p16/p16_evm.py').read_bytes()).hexdigest(),'kind':'direct_parser_controls_not_production_mutants','checks':rows,'passed':sum(r['pass'] for r in rows),'total':len(rows)}
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ('source_sha256','passed','total')}))
raise SystemExit(0 if all(r['pass'] for r in rows) else 1)
