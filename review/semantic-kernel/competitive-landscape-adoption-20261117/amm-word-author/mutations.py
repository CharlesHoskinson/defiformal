from pathlib import Path
import subprocess,datetime,time,hashlib,json
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-word-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');model=(r/'lean/DefiKernel/AMM/Checked.lean').read_text();controls=(e/'Controls.lean').read_text();prefix=model.split('/-- Full success domain:')[0]+'\nend DefiKernel.AMM.Checked\n';tail='\n'.join(controls.splitlines()[1:]);runs=[]
def run(name,source,code,diagnostics):
 path=e/(name+'.lean');path.write_text(source);argv=[str(tc/'bin/lake'),'env','lean',str(path)];start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/(name+'.log')).write_bytes(p.stdout);assert p.returncode==code,(name,p.returncode,p.stdout[-700:]);assert all(text.encode() in p.stdout for text in diagnostics),(name,p.stdout[-700:]);runs.append(dict(name=name,argv=argv,cwd=str(r/'lean'),started_utc=start,wall_seconds=time.monotonic()-tick,exit=p.returncode,source_sha256=hashlib.sha256(source.encode()).hexdigest(),required_diagnostics=diagnostics,output_sha256=hashlib.sha256(p.stdout).hexdigest()));print(name,p.returncode,flush=True)
run('intact-api-prefix',prefix+tail,0,['WORD_CONTROL PASSED 15/15'])
mutations={
 'early-fee-floor':('  wideMul amount (feeDifference fee)', '''  wideMul (⟨amount.value - amount.value * fee.numerator.value / fee.denominator.value,
    lt_of_le_of_lt (Nat.sub_le _ _) amount.bound⟩ : Word 256) fee.denominator'''),
 'missing-denominator-input':('wideAdd (scaledReserve pool fee) (weightedInput amount fee)', 'wideAdd (scaledReserve pool fee) (weightedInput (⟨0, by decide⟩ : Word 256) fee)'),
 'output-ceiling':('Rounding.divideNat .down (numerator pool amount fee).value', 'Rounding.divideNat .up (numerator pool amount fee).value')}
for name,(old,new) in mutations.items():
 assert old in prefix,(name,old)
 run(name+'-runtime-prefix',prefix.replace(old,new,1)+tail,1,['WORD_CONTROL zero_output_without_early_fee_rounding false','FAIL: Word control comparison'])
 run(name+'-full-proofs',model.replace(old,new,1),1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(model.encode()).hexdigest(),control_source_sha256=hashlib.sha256(controls.encode()).hexdigest(),runs=runs,scope='Runtime probes use the actual Checked API prefix and actual controls with self-import removed. Wide range proofs remain in that prefix. Full model mutants retain unchanged domain/correspondence/product proofs and fail compilation. Imported intact Checked.olean is not used for mutant observations.'),indent=2)+'\n');print('PASS',len(runs),'mutation commands')
