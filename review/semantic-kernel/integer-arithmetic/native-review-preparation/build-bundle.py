#!/usr/bin/env python3
"""Bind the complete arithmetic source and retained actual evidence for identical native reviews."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,subprocess
R=Path(__file__).resolve().parents[4];B=R/'review/semantic-kernel/integer-arithmetic';O=B/'native-review-r1'
C='ddf1ac0e50f2e032385664a0965bab59eef91ea3'
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):return json.loads(p.read_text())
def git(*a):return subprocess.check_output(['git',*a],cwd=R)
proof=read(B/'proof-inventory-r2/proof-inventory.json');assert proof['candidate']==C and proof['execution']['status']=='PASS'
i=read(B/'integration-r1/verification.json');assert i['candidate']==C and i['all_commands_passed'] and i['source_unchanged'] and all(r['passed'] for r in i['runtime_extraction_checks'])
q=read(B/'implementation/evidence-development/qualification-r4.json');assert q['status']=='PASS'
a=read(B/'implementation/evidence-development/artifact-controls-r2/results.json');assert len(a['cases'])==5 and all(r['passed'] and r['reason_matches'] for r in a['cases'])
t=read(B/'compiler-controls/run-r1/result.json');assert t['passed']
assert read(B/'implementation/retained-evidence.json')['all_relevant_inputs_equal']
assert read(B/'diagnostics/run-r1/result.json')['status']=='PASS'
O.mkdir(exist_ok=False)
compact={k:proof[k] for k in ['candidate','counts','discovery','validation','source_module_count_scope','premise_and_scope_limits']}
compact['theorems']=[]
for row in proof['theorems']:
 x={k:row[k] for k in ['name','module','axioms','category','declaration_origin']};x['statement_sha256']=sha(row['statement'].encode())
 if row['declaration_origin']=='explicit':x['full_elaborated_statement']=row['statement']
 compact['theorems'].append(x)
compact['supplemental']=[{k:row[k] for k in ['name','module','axioms']}|{'statement_sha256':sha(row['statement'].encode())} for row in proof['supplemental']]
compact['scope']='Full explicit types presented; all generated/supplemental full types separately bound in original inventory and raw Lean output.'
(O/'proof-presentation.json').write_text(json.dumps(compact,indent=2)+'\n')
header=f"""Independently review the complete DeFi Kernel checked integer financial arithmetic source and evidence.
SOURCE CANDIDATE {C}. Return VERDICT: ACCEPT, ACCEPT WITH LIMITATIONS, or REVISE, followed by BLOCKERS, REQUIRED CHANGES, LIMITATIONS and CLAIM/SCOPE CHECK. Cite exact declarations/files. Treat author reports as claims, not independent acceptance. No edits or external communication. Both native reviewers receive identical frozen bytes. No independent execution or proof by review is claimed.

Unsigned Word widths are arbitrary; full intermediate products are unbounded; final quotient checks and directed floor/ceiling rounding have independent mathematical characterizations. Fees distinguish gross from on-top and validate natural rates. Asset-indexed conversion uses positive rational scale and exact reverse conversion. Actual registered Typed.execute quote transfers derive evaluation/accounting/domain/writes, retain explicit invoke/debit/net-funding premises, sum coincident effects, and preserve complete capability store. Refusal yields no post-world.

Fresh21-command integration passes45 new runtime labels and1032 total across the kernel. Imported audit307 theorem constants =125explicit(123generic,2finite-reference comparator proofs)+182generated;233supplemental, zero forbidden axioms. Full explicit types below; complete types of generated declarations retained separately. Reference runtime has9helpers, not just the planned7: evaluated/netEffect are explicit actual intermediate data, never caller-supplied target execute equations. Inspect absence of circular full Valid or target execution assumptions.

All12actual production edits compile and falsify designated observations; control plus12variants each have45unique observations,585total. GlobalF01/F03 and separate siblings stay true. Report overlapping false labels honestly. Runtime projection has9Arithmetic roots/13localmodules with4existingTyped dependency files whose proofs remain.37pure cases and8actualTyped workflows compare independent literal results, all16cells and4completecapabilities including tombstone. T01/T02actualnewAPI asset-index compiler pair is distinct from runtime mutation.

65actualsyntheticCLI controls ran at144e8b5686742fb285881c0d0c589417ff635cac:10/5/50exitclasses. They retain their actual revision via relevantclosure/binary equivalence.27968independentPythondivmod/actualLean width4 comparisons likewise retain144e. A01–A04are actual copied-artifact CLI rejections with a passing unchanged sibling; saved-artifact consistency is not cryptographic execution attestation or arbitrary tamper resistance. Failed development helper/Acontrol attempts are preserved. Dynamicproofinventoryr1 failed because importing ProofAudit does not replay its log; r2 freshly runs ProofAudit+Verify+fulltypeexporter. No proof source changed for the correction.

Earlier13legacy suites(c880), S9(eec) and S10(b165) mutation/control evidence remain exact earlier executions, with checked relevantinputequivalence. Newrootintegration is fresh. The build uses an incremental pinned cache, not a full clean rebuilding of all imported proofs. No deployedmachinecode/chainrefinement, concentratedliquidity, externaloracletruth, liveness or genericsolvency. Nativeacceptance/specsync/archive/branchdelivery remain open pending this gate. Other corpus/historical/M3work is outside this source candidate.
"""
parts=[header];rows=[];seen=set()
def bind(p,present=False,source=False):
 rel=str(p.relative_to(R))
 if rel in seen:return
 seen.add(rel);raw=p.read_bytes();row={'path':rel,'sha256':sha(raw),'bytes':len(raw),'presentation':'full bytes in bundle' if present else 'hash-bound retained artifact'}
 if source:
  assert git('show',C+':'+rel)==raw,rel;row['git_blob']=git('rev-parse',C+':'+rel).decode().strip()
 rows.append(row)
 if present:
  rendered=(json.dumps(json.loads(raw),ensure_ascii=False,separators=(',',':'))+'\n') if p.suffix=='.json' else raw.decode()
  row['rendered_sha256']=sha(rendered.encode());parts.append('\n\n===== INPUT '+rel+' SHA256 '+row['sha256']+' =====\n'+rendered)
source=set(proof['source_bindings'])|{'lean/DefiKernel.lean','scripts/check_integer_arithmetic_mutations.py','scripts/test_integer_arithmetic_runner.py','mutations/integer-arithmetic.json'}
source|={str(p.relative_to(R)) for p in (R/'openspec/changes/checked-integer-financial-arithmetic').rglob('*') if p.is_file()}
for rel in sorted(source):bind(R/rel,True,True)
for rel in ['scripts/check_integer_arithmetic_evidence.py','scripts/check_integer_arithmetic_oracle.py']:bind(R/rel,True)
present=['EVIDENCE.md','planning/official-r1/gate-status.json','planning/official-r1/review-gpt6/report.md','planning/official-r1/review-fable-after-reset.md','implementation/planning-review-disposition.md','implementation/financial/full-development-r2/runtime-inventory.json','implementation/financial/full-development-r2/actual-projection-inventory.json','implementation/retained-evidence.json','integration-r1/verification.json','integration-r1/lean-runs.json','integration-r1/01.stdout.log','proof-inventory-r2/proof-inventory-execution.json','native-review-r1/proof-presentation.json','mutations-r1/results.json','mutations-r1/source-manifest.json','implementation/runner-controls-r1/summary.json','implementation/evidence-development/qualification-r4.json','implementation/evidence-development/artifact-controls-r2/results.json','compiler-controls/run-r1/result.json','diagnostics/run-r1/result.json']
# Require measured scenario coverage, not a planned map.
coverage=B/'coverage-measured-r1';assert coverage.is_dir() and list(coverage.glob('*.json')),'Missing final measured scenario coverage'
for p in sorted(coverage.rglob('*')):
 if p.is_file():bind(p,True)
for rel in present:bind(B/rel,True)
for folder in ['mutations-r1','implementation','integration-r1','proof-inventory-r1','proof-inventory-r2','compiler-controls','diagnostics','coverage-measured-r1']:
 for p in sorted((B/folder).rglob('*')):
  if p.is_file() and not p.is_symlink():bind(p)
raw=''.join(parts).encode();(O/'bundle.md').write_bytes(raw)
m={'candidate':C,'working_head':git('rev-parse','HEAD').decode().strip(),'kind':'Arithmetic complete source/proof/runtime/mutation/control evidence; nativeacceptance pending','captured_utc':datetime.now(timezone.utc).isoformat(),'inputs':rows,'input_count':len(rows),'bundle_sha256':sha(raw),'bundle_bytes':len(raw),'builder_sha256':sha(Path(__file__).read_bytes())}
(O/'candidate.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({k:v for k,v in m.items() if k!='inputs'},indent=2))
