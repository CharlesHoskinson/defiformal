#!/usr/bin/env python3
"""Size-bounded presentation of the same frozen final-review inputs, retaining full evidence."""
from pathlib import Path
import hashlib,json,datetime
ROOT=Path(__file__).resolve().parents[4]
BASE=ROOT/'review/semantic-kernel/sprint9'
SRC=BASE/'native-review-r2'
OUT=BASE/'native-review-r2-compact'
def sha(b):return hashlib.sha256(b).hexdigest()
m=json.loads((SRC/'candidate.json').read_text())
assert sha((SRC/'bundle.md').read_bytes())==m['bundle_sha256']
for r in m['inputs']:assert sha((ROOT/r['path']).read_bytes())==r['sha256'],r['path']
OUT.mkdir(exist_ok=False)
header='''Review the SAME corrected source and final execution evidence as the canonical full bundle. Return VERDICT: ACCEPT, ACCEPT WITH LIMITATIONS, or REVISE; then BLOCKERS, REQUIRED CHANGES, LIMITATIONS, CLAIM/SCOPE CHECK. No tools, execution, edits or communication. Advisory review, not a mathematical proof. Treat author records as claims to inspect.

The initial native Fable invocation on the identical full bundle rejected context length and gave NO substantive verdict. Grok is reviewing the original full presentation. This compact presentation preserves every source file verbatim, all explicit full theorem statements, all55 scenario rows, actual14-mutant Boolean outcomes, all65 control cases and exact relevant legacy dependency bindings. JSON whitespace is removed. Duplicated per-suite legacy source descriptors refer to the supplied common exact baseline table. Mutation outcome tables use the common ordered148-ID control inventory plus each variant's false-ID list; every other listed ID is true, and reconstruction is checked against all2220 original observations. The3382 passing mechanical legacy assertion labels and repetitive artifact-name/hash lists are omitted from presentation only: their complete immutable originals remain bound in the canonical3683-input manifest. None is an independent mathematical proof. All underlying original files are hash checked before and after native execution; the complete originals are preserved. No different candidate or new execution is substituted.

Targeted source-r1 findings: formerly identical world/history/index/child check expressions now use distinct independently expected financial programs. Receipt-diff retains evaluated amount7→6; the supplemental evaluated-receipt check varies declared reads. FullCursorEq still makes a history reset visible to literal world-chain because its snapshot prefix is lost: actual [world-chain,history-chain] matrix is control[T,T], world-reset[F,T], history-reset[F,F]. Distinct computations and all14 distinct false inventories do not prove an exclusive fault classifier. Six observer mutations are synthetic sensitivity checks; eight routing mutations run real financial/admin workflows. The SupportedGroup comment explicitly separates Prop-valued flatten support from actual recursive execution. Verify has11 transitive Metatheory dependencies; the external driver includes Verify itself as the12th source module.

Final evidence at eec499d613688137a341f3556cd80ca461dd2ee9:16 fresh Lean integration commands;148 new comparisons and888 including existing audits;237 theorem constants=109 explicit(74generic/35concrete)+128generated;342 supplemental=323previous+19fixturedefs; forbidden axioms0. All prior theorem statements/types/axioms unchanged.14production mutants freshly qualify,148 checks per variant,14 designatedfalse,30 globalpositivetrues and14 supplemental siblingtrues;65actual CLI controls=10valid/5violated/50blocked.13legacy suites retain actual c880 execution identity through precise unchanged relevant-source/tool equivalence, NOT rerun at successor. All55 scenarios are supplied; only finalnativeacceptance/delivery is administratively pending until thisreview and the branchpush/archive. Judge substantive source/proof/execution sufficiency before those steps; do not award delivery early.

Scopes: full-cursor simulation and sequential associativity for arbitrary entry cursors; observation omits old raw worlds; contextual substitution only fixed sequential prefixes/suffixes with sameconfig/boundaries. ConfigAgreement is sufficient, not minimal; supported fullregistry/lookup equality, bothvalidcatalogs, all-domainadmins and sharedtypes. Operator lifting keeps commonprograms/worlds/schedules/policies and proves no shared-state commutation or atomic-boundary reassociation. Trustedconfig/store/boundaries/externalobservations, rationalarithmetic, no deployedfidelity/liveness/machinearithmetic/holdouts/generalsolvency. Lexicalproof-tail guard does not analyze arbitrary earlier-defined macros. Preserve limitations and report concrete unresolved findings.
'''
parts=[header];projections=[]
for r in m['inputs']:
 if r.get('presentation'):continue
 path=r['path'];raw=(ROOT/path).read_bytes();representation=raw.decode();rule='verbatim'
 if path.endswith('.json'):
  x=json.loads(raw);rule='lossless JSON whitespace normalization'
  if path.endswith('/regressions/verified-outcomes.json'):
   assert x['all_passed'] and len(x['checks'])==x['assertion_count']==3382 and all(c['passed'] for c in x['checks'])
   x={k:v for k,v in x.items() if k!='checks'}
   rule='3382 passing mechanical assertion labels omitted; counts/outcomes/archive metadata retained; original fully bound'
  elif path.endswith('/implementation/legacy-dependency-equivalence.json'):
   for suite in x['suites']:
    assert all(x['baseline_bindings'][p]==binding for p,binding in suite['source_closure'].items())
    suite['source_closure_paths']=list(suite.pop('source_closure'))
   rule='per-suite source closure descriptors replaced by paths into identical shared baseline_bindings table'
  elif path.endswith('/mutations-r2/results.json'):
   ids=list(x['results']['control']['checks']);assert len(ids)==148
   for name,result in x['results'].items():
    original=result.pop('checks');assert set(original)==set(ids)
    false=[p for p in ids if original[p]=='false']
    assert {p:('false' if p in false else 'true') for p in ids}==original
    result['false_ids']=false;result['every_other_control_inventory_id_is_true']=True
   x['complete_check_inventory_in_order']=ids
   rule='lossless148-ID shared inventory + per-variant false lists; every other inventory ID true; all2220 outcomes reconstructed exactly'
  elif path.endswith('/artifact-inventory.json'):
   assert isinstance(x,list) and x
   x={'artifact_count':len(x),'full_original':r,'presentation':'Full artifact list retained and hash-bound, individual names/hashes omitted from prompt.'}
   rule='repetitive artifact list omitted from presentation; complete immutable original remains bound'
  representation=json.dumps(x,separators=(',',':'),ensure_ascii=False)
  # An identity check for ordinary normalized JSON guards presentation loss.
  if rule=='lossless JSON whitespace normalization':assert json.loads(representation)==json.loads(raw)
 parts.append(f'\n\n===== INPUT {path} ORIGINAL SHA256 {r["sha256"]}; PRESENTATION {rule} =====\n'+representation)
 projections.append({'path':path,'original_sha256':r['sha256'],'rule':rule,'presentation_sha256':sha(representation.encode())})
raw=''.join(parts).encode();(OUT/'bundle.md').write_bytes(raw)
record={'candidate':m['candidate'],'canonical_bundle_sha256':m['bundle_sha256'],'canonical_manifest_sha256':sha((SRC/'candidate.json').read_bytes()),'projection_rules':projections,'builder_sha256':sha(Path(__file__).read_bytes())}
(OUT/'projection.json').write_text(json.dumps(record,indent=2)+'\n')
rows=list(m['inputs'])
for path in [SRC/'candidate.json',SRC/'bundle.md',OUT/'projection.json',Path(__file__)]:
 data=path.read_bytes();rows.append({'path':str(path.relative_to(ROOT)),'sha256':sha(data),'bytes':len(data)})
manifest={'candidate':m['candidate'],'kind':'compact presentation of same final source/evidence; context-limit retry, no prior Fable verdict','captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs':rows,'input_count':len(rows),'bundle_sha256':sha(raw),'bundle_bytes':len(raw),'canonical_bundle_sha256':m['bundle_sha256']}
(OUT/'candidate.json').write_text(json.dumps(manifest,indent=2)+'\n')
print({k:v for k,v in manifest.items() if k!='inputs'})
