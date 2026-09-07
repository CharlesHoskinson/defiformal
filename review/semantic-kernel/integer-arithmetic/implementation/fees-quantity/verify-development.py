#!/usr/bin/env python3
"""Capture actual development builds, explicit theorem axiom checks and anchor smoke tests."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).parent / 'final-development'
assert not OUT.exists()
OUT.mkdir()

def sha(raw): return hashlib.sha256(raw).hexdigest()
def save(path, data): path.write_text(json.dumps(data, indent=2)+'\n')
paths = ['lean/DefiKernel/Arithmetic/'+name+'.lean' for name in ['Word','Rounding','Fees','Quantity']]
paths += ['lean/DefiKernel/Typed/Types.lean','lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json']
before = {}
for path in paths:
    raw = (ROOT/path).read_bytes()
    before[path] = {'sha256': sha(raw), 'bytes': len(raw)}
    copy = OUT/'inputs'/path
    copy.parent.mkdir(parents=True, exist_ok=True)
    copy.write_bytes(raw)
commands = []
def run(name, argv):
    tick = time.monotonic(); start = datetime.now(timezone.utc).isoformat()
    result = subprocess.run(argv, cwd=ROOT/'lean', capture_output=True, timeout=600)
    logs = {}
    for label, raw in [('stdout',result.stdout),('stderr',result.stderr)]:
        path = OUT/(name+'.'+label+'.log'); path.write_bytes(raw)
        logs[label] = {'path':path.name,'sha256':sha(raw),'bytes':len(raw)}
    commands.append({'label':name,'argv':argv,'cwd':str(ROOT/'lean'),'started_utc':start,
        'finished_utc':datetime.now(timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,
        'exit':result.returncode,'timeout_seconds':600,'logs':logs})
    save(OUT/'commands.json',commands)
    assert result.returncode == 0, (name,result.stdout.decode(),result.stderr.decode())
    return result.stdout.decode()

version=run('lean-version',['lake','env','lean','--version'])
lean_path=Path(run('lean-path',['lake','env','which','lean']).strip())
run('build',['lake','build','DefiKernel.Arithmetic.Fees','DefiKernel.Arithmetic.Quantity'])
proofs=[]
for module in ['Fees','Quantity']:
    text=(ROOT/f'lean/DefiKernel/Arithmetic/{module}.lean').read_text()
    for name in re.findall(r'^(?:@\[[^\n]*\]\s*)?theorem\s+(\w+)',text,re.M):
        proofs.append(f'DefiKernel.Arithmetic.{module}.{name}')
audit=OUT/'OwnedAxioms.lean'
audit.write_text('import DefiKernel.Arithmetic.Fees\nimport DefiKernel.Arithmetic.Quantity\n'+
    '\n'.join('#print axioms '+name for name in proofs)+'\n')
axioms=run('owned-axioms',['lake','env','lean',str(audit)])
assert 'sorryAx' not in axioms and 'native_decide' not in axioms
records=re.findall(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)",axioms,re.S)
assert len(records)==len(proofs) and set(n for n,_ in records)==set(proofs)
for _,tags in records:
    assert set(re.findall(r'[A-Za-z_][A-Za-z0-9_.]*',tags)) <= {'propext','Classical.choice','Quot.sound'}
fee=(ROOT/'lean/DefiKernel/Arithmetic/Fees.lean').read_text().split('\n-- BEGIN PROOFS\n')[0]
checks='''
end DefiKernel.Arithmetic.Fees
open DefiKernel.Arithmetic DefiKernel.Arithmetic.Fees
private def observe (result : Except Failure (FeeQuote 8)) : Except Failure (Nat × Nat × Nat × Nat) :=
  result.map fun quote ↦ (quote.principal.value, quote.fee.value, quote.charged.value, quote.received.value)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 1 3) = .ok (100, 33, 100, 67))
#eval decide (observe (feeFromGross .up ⟨100, by decide⟩ 1 3) = .ok (100, 34, 100, 66))
#eval decide (observe (feeOnTop .up ⟨100, by decide⟩ 1 3) = .ok (100, 34, 134, 100))
#eval decide (observe (feeOnTop .up ⟨255, by decide⟩ 1 1) = .error .addOverflow)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 300 600) = .ok (100, 50, 100, 50))
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 3 2) = .error .invalidRate)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 1 0) = .error .invalidRate)
#eval decide (feeFromGross .up (⟨0, by decide⟩ : Word 0) 300 600 =
  .ok ⟨⟨0, by decide⟩, ⟨0, by decide⟩, ⟨0, by decide⟩, ⟨0, by decide⟩⟩)
'''
mutations=[('fee-prefix-control',None,None),
 ('fee-prefix-clamped-rate','if den = 0 ∨ num > den then .error .invalidRate else .ok num',
  'if den = 0 then .error .invalidRate else .ok (min num den)'),
 ('fee-prefix-gross-received','let received ← Word.checked .subUnderflow (gross.value - fee.value)',
  'let received ← Word.checked .subUnderflow gross.value')]
measured=[]
for name,needle,replacement in mutations:
    prefix=fee
    if needle:
        assert prefix.count(needle)==1
        prefix=prefix.replace(needle,replacement,1)
    path=OUT/(name+'.lean');path.write_text(prefix+checks)
    raw=run(name,['lake','env','lean',str(path)])
    observations=re.findall(r'^(true|false)$',raw,re.M)
    assert len(observations)==8
    if name=='fee-prefix-control': assert observations==['true']*8
    if name=='fee-prefix-clamped-rate': assert observations[5]=='false'
    if name=='fee-prefix-gross-received': assert observations[0]=='false'
    assert observations[2:4]==['true','true'] and observations[6:]==['true','true']
    measured.append({'name':name,'source_sha256':sha(path.read_bytes()),'observations':observations})
after={path:sha((ROOT/path).read_bytes()) for path in paths}
assert all(before[p]['sha256']==after[p] for p in paths)
save(OUT/'verification.json',{'status':'DEVELOPMENT_PASS_NOT_FINAL_ACCEPTANCE',
    'scope':'Owned module builds, all explicit theorem axiom checks and literal runtime prefix probes; not official package mutation evidence.',
    'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
    'lean':{'path':str(lean_path),'sha256':sha(lean_path.read_bytes()),'version':version.strip()},
    'source_before':before,'source_after':after,'source_unchanged':True,
    'proof_count':len(proofs),'proof_names':proofs,'allowed_axioms':['propext','Classical.choice','Quot.sound'],
    'probes':measured,'builder_sha256':sha(Path(__file__).read_bytes())})
save(OUT/'artifact-inventory.json',[{'path':str(p.relative_to(OUT)),'bytes':p.stat().st_size,
    'sha256':sha(p.read_bytes())} for p in sorted(OUT.rglob('*')) if p.is_file()])
print(json.dumps({'status':'PASS','theorems':len(proofs),'probes':len(measured),'out':str(OUT)}))
