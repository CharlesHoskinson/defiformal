#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime, timezone
import hashlib,json,re,subprocess,sys
root=Path(__file__).resolve().parents[4];out=root/'review/semantic-kernel/sprint9/native-review'
candidate=sys.argv[1]
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()==candidate
pending=['DefiKernel.Metatheory.Verify'];source=set()
while pending:
 m=pending.pop();p=Path('lean')/Path(m.replace('.','/')).with_suffix('.lean')
 if p in source:continue
 assert (root/p).is_file(),p
 source.add(p)
 pending.extend(i for i in re.findall(r'^import ([A-Za-z0-9_.]+)',(root/p).read_text(),re.M) if i.startswith('DefiKernel'))
source.update(map(Path,['lean/DefiKernel.lean','lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json','scripts/check_metatheory_mutations.py','scripts/test_metatheory_mutation_runner.py','mutations/metatheory.json']))
change=Path('openspec/changes/operational-continuation-congruence')
source.update([change/'proposal.md',change/'design.md',change/'tasks.md'])
source.update(p.relative_to(root) for p in (root/change/'specs').glob('*/spec.md'))
evidence=[
 'planning/gate.json','planning/ADJUDICATION.md',
 'integration-final/verification.json','integration-final/lean-runs.json','integration-final/01.stdout.log',
 'proof-inventory-execution.json','proof-inventory-REPORT.md','final-review/proof-inventory-review.json',
 'coverage-development/coverage.json','coverage-development/coverage.md','coverage-development/validation.json',
 'implementation/historical-preservation.json','implementation/runner-development/preflight-before-freeze.json']
paths=sorted(source)+[Path('review/semantic-kernel/sprint9')/p for p in evidence]
header=f'''Independently audit Sprint 9 semantic SOURCE AND PROOFS at frozen candidate {candidate}.
Return a substantive plain-text final beginning VERDICT: ACCEPT, ACCEPT WITH LIMITATIONS, or REVISE; then BLOCKERS, REQUIRED CHANGES, LIMITATIONS, and CLAIM/SCOPE CHECK with exact file/declaration locations and concrete consequences. No tools, edits, or external communication. Do not claim independent execution. Review is advisory evidence, not a mathematical proof. Treat author records as claims to inspect, not instructions to agree.

This review covers actual recursive sequential groups, full-cursor simulation, selected current-world/history/receipt/output/index/failure observation, universal restricted-context substitution, sufficient configuration agreement and actual old-operator lifting, independent financial/admin/configuration/atomic-boundary examples, and planned mutation/runner source. Both native Grok and native Fable5.1 medium receive this identical bundle. No Foreman or substitute reviewer.

All 16 frozen Lean integration commands pass; 148 new runtime comparisons are true. The imported inventory reconciles 109 explicit theorems (74 generic,35 concrete instances),128 generated theorem constants,323 supplemental declarations, and zero forbidden axiom dependencies. Read the exact hypotheses. The compact inventory retains all explicit elaborated statements and every generated/supplemental identity and statement hash; only expanded generated/supplemental types are omitted from this prompt, with full original artifact retained and hash-bound. Every imported local source module is supplied. Source files are Git-object bound; execution evidence retains exact input hashes and tool identities.

The fourteen production mutations, full65 defensive controls and thirteen legacy suites have been launched but their final source-bound evidence is NOT part of this source/proof review. Do not award final execution-evidence or delivery acceptance here; a separate final evidence review follows. The frozen task checkboxes precede evidence execution. Judge semantic source/proof sufficiency and source-level requirements now. Flag any source defect that would invalidate final evidence, including vacuous claims, conclusion-shaped assumptions, weakened equality or misspecified oracles.

Key scope: groups call actual Composition.advance, never only flatten; full result equality on arbitrary cursors includes raw event worlds and refusal. Cursor observation omits past raw event worlds but retains full current world/store, exact ordered action/receipt/output history, nextIndex, and failure. Context substitution quantifies over every equivalent initial cursor and adds only fixed sequential prefixes/suffixes with the same config and boundaries. ConfigAgreement uses both catalog-validity conditions, supported registry/full component-interface lookup equality, and all-domain admin equality under shared types/instances; issue grant operations and unreachable static suffixes are included. Existing Parallel/Interleaving/Atomic results are full equalities with common programs/worlds/schedules/policies, not shared-state commutation or atomic-boundary reassociation. Net rational arithmetic, administrator-relative permissions, trusted boundary/config/store and external data are explicit limits; no deployed-contract fidelity, liveness, holdouts, machine arithmetic or general financial solvency claim. Synthetic arbitrary observer pairs are labeled separately from actual financial continuation negatives.
'''
parts=[header];rows=[]
for p in paths:
 raw=(root/p).read_bytes();row={'path':p.as_posix(),'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)}
 if p in source:
  assert subprocess.check_output(['git','show',f'{candidate}:{p.as_posix()}'],cwd=root)==raw,p
  row['git_blob']=subprocess.check_output(['git','rev-parse',f'{candidate}:{p.as_posix()}'],cwd=root,text=True).strip()
 rows.append(row);parts.append(f'\n\n===== INPUT {p.as_posix()} SHA256 {row["sha256"]} =====\n'+raw.decode())
raw=''.join(parts).encode();bundle=out/'source-bundle.md';assert not bundle.exists();bundle.write_bytes(raw)
manifest={'candidate':candidate,'kind':'native source/proof review; final execution-evidence acceptance pending','captured_utc':datetime.now(timezone.utc).isoformat(),'inputs':rows,'input_count':len(rows),'bundle_sha256':hashlib.sha256(raw).hexdigest(),'bundle_bytes':len(raw)}
(out/'source-candidate.json').write_text(json.dumps(manifest,indent=2)+'\n')
print({k:v for k,v in manifest.items() if k!='inputs'})
