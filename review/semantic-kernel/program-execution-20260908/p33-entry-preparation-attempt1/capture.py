from pathlib import Path
import datetime, hashlib, json, re, shutil, subprocess

r=Path('/home/charl/defiformal')
b=r/'review/semantic-kernel/program-execution-20260908'
w=Path('/home/charl/defiformal-wt-corpus-grok-gpt6-20260908')
o=b/'p33-entry-preparation';o.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
start=now();files=[]
def capture(base,rel,origin):
    p=base/rel;q=o/'inputs'/origin/rel;q.parent.mkdir(parents=True,exist_ok=True)
    assert p.is_file() and not p.is_symlink(),p
    shutil.copy2(p,q);assert h(p)==h(q)
    files.append({'origin':origin,'source':str(p),'path':str(q.relative_to(o)),
                  'sha256':h(q),'bytes':q.stat().st_size})
    return q

# Explicit release and policy allowlist; never follow assessment paths in metadata.
context=[
 'review/semantic-kernel/program-execution-20260908/P18-ACCEPTANCE.md',
 'review/semantic-kernel/program-execution-20260908/p18-implementation-grok-r2-candidate-manifest.json',
 'review/semantic-kernel/program-execution-20260908/p18-delivery-r2.json',
 'review/semantic-kernel/program-execution-20260908/P32-READINESS-ACCEPTANCE.json',
 'openspec/changes/reusable-verification-platform-program/tasks.md',
 'openspec/changes/reusable-verification-platform-program/sprint-plan.md',
 'openspec/changes/reusable-verification-platform-program/specs/certificates-adapters-evaluation-publication/spec.md',
 'openspec/changes/reusable-verification-platform-program/contracts/evidence-packet.schema.json',
 'examples/platform-increment/API.md','examples/platform-increment/README.md',
 'examples/platform-increment/VERSION.json','examples/platform-increment/lean/Token0ReleaseExample.lean',
 'lean/lean-toolchain','lean/lakefile.lean','lean/lake-manifest.json']
for p in context:capture(r,p,'primary')
metadata=[
 'corpus/adjudicated/v1/metadata/prior-exposure-ledger.json',
 'corpus/adjudicated/v1/inputs/exposure.json',
 'review/semantic-kernel/program-loop-20260908/corpus-exposure-metadata-contract-gpt6-inputs.json',
 'review/semantic-kernel/program-loop-20260908/corpus-exposure-metadata-contract-gpt6-review.md']
for p in metadata:capture(w,p,'corpus')

# Static dependency navigation of release entry modules. External dependencies
# remain pinned package boundaries, not a claimed full external source closure.
todo=['DefiKernel.ConcentratedLiquidity.Examples'];seen={};edges=[];external=set()
while todo:
    name=todo.pop()
    if name in seen:continue
    rel='lean/'+name.replace('.','/')+'.lean';p=r/rel
    assert p.is_file(),rel
    capture(r,rel,'primary');seen[name]={'path':rel,'sha256':h(p)}
    imports=[]
    for line in p.read_text().splitlines():
        if line.startswith('import '):imports.extend(line.split('--',1)[0].split()[1:])
    for imp in imports:
        edges.append({'from':name,'to':imp})
        if (r/'lean'/Path(imp.replace('.','/')+'.lean')).is_file():todo.append(imp)
        else:external.add(imp)
assert seen and edges
release=read(b/'p18-root-integration-preparation-r2.json')
accepted={x['path']:x['candidate_sha256'] for x in release['files']}
release_checks={p:h(r/p)==accepted[p] for p in context if p.startswith('examples/')}
assert release_checks and all(release_checks.values())
ledger=read(w/metadata[0]);exposure=read(w/metadata[1])
assert len(exposure['units'])==len(set(exposure['units']))==75
assert len(ledger['cases'])==12
assert ledger['assessment_payload_opened'] is False
assert all(c['original_assessment_id']=='unknown' and c['evaluation_role']=='development' for c in ledger['cases'])
write(o/'source-bindings.json',{'started_utc':start,'finished_utc':now(),
 'primary_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip(),
 'corpus_detached_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=w,text=True).strip(),
 'corpus_worktree_bytes_not_assumed_equal_to_head':True,'files':files})
write(o/'p18-api-dependencies.json',{'kind':'static_release_api_dependency_navigation',
 'root_module':'DefiKernel.ConcentratedLiquidity.Examples','modules':seen,'edges':edges,
 'external_imports':sorted(external),'external_boundary':'Pinned by lean-toolchain and lake-manifest; external source closure not copied or rebuilt.',
 'accepted_release_file_hashes_match':release_checks,'compiled_in_this_capture':False,
 'final_evaluated_api_set_declared':False,'freeze_accepted':False})
write(o/'exposure-boundary.json',{'kind':'metadata_only_entry_summary',
 'development_unit_ids':exposure['units'],'development_count':75,
 'prior_report_labels':[{'label':c['id'],'original_assessment_id':c['original_assessment_id'],
  'evaluation_role':c['evaluation_role'],'unresolved_aliases':c['unresolved_aliases']} for c in ledger['cases']],
 'report_label_count':12,'disjoint_population_claim':False,'combined_denominator':None,
 'held_payloads_selected':False,'held_payloads_read':False,
 'metadata_historical_payload_digest_is_not_new_verification':True,
 'later_selection_requires_identity_alias_and_prior_exposure_review':True})
(o/'README.md').write_text('''# P33 entry preparation

P18 is accepted, satisfying the named P33 entry dependency. This packet captures the existing public release API, its local Lean import dependencies, evidence schema, toolchain/package pins, and the previously reviewed metadata-only exposure ledger. It does not declare the final evaluated API set or accept a freeze.

The four captured P18 public release files match their accepted candidate hashes. Local imports are static navigation; no build or new proof was run. External imports remain explicit boundaries bound to the package/toolchain pins. P19 drafts and the unrelated backlog are not silently added to an evaluated API set. The eventual author must declare the actual evaluation scope, include at least the accepted P18 APIs, and bind every additional evaluated kernel/schema/library dependency.

The exposure input has75 development unit IDs. The separate ledger has12 REPORT labels with unknown original assessment IDs and unresolved aliases. These are not a disjoint87-case population, new normalized units, or untouched cases. The ledger contains historical inventory references to an assessment payload; this capture never follows those paths or rehashes that payload. No held payload was selected or read.

Next AGY implementation: produce the P33 freeze manifest and exposure-audited replacement policy, meaningful promotion-refusal controls (including renamed/versioned aliases), and invalidation rules for later evaluated API changes. Fresh Grok must review the exact freeze/policy bytes before P34 independent selection. Missing environment pins remain explicit P32/P34 gaps; EVM results cannot score another environment. Preparation neither changes the P19 author priority nor dispatches a second author.
''')
(o/'queued-author-brief.txt').write_text('''Future AGY P33 author: use this source-bound entry packet after the current P19 author/review work, without starting a second substantive author. P18 dependency is accepted. Implement tasks34.1-34.3 and prepare independent34.4 review. Declare actual evaluated APIs at least P18 plus each additional API actually evaluated; do not freeze the whole unrelated backlog or assume a token0-only evaluation proves whole-platform generality. Bind kernel/schema/library, imports, toolchain and packages to exact hashes. Preserve current75 development IDs and all descendants/descriptions/aliases as exposed. Prior12 REPORT labels remain exposure metadata, original assessment IDs unknown; no75+12 disjoint denominator. Never open held assessment payloads during freeze/planning. Add real negative promotion tests including changed names/version IDs and unresolved alias review, positive eligible synthetic controls, and freeze-version invalidation controls. Do not fabricate eligibility or select assessment cases. Full P34 requires independent selection after accepted freeze and nonempty success/refusal per required environment. Source/toolchain gaps stay blocked. All production implementation uses native AGY Gemini3.8FlashHigh high and fresh Grok4.6 high review; no Foreman, subagents, windows, branches, commits or pushes. This queued brief is administrative context, not a dispatch or accepted policy.
''')
shutil.copy2(__file__,o/'capture.py')
record={'utc':now(),'status':'prepared_not_dispatched','hard_dependency':'accepted P18',
 'captured_files':len(files),'local_lean_modules':len(seen),'static_import_edges':len(edges),
 'p33_tasks_accepted':[],'held_payloads_read':False,'acceptance':False,
 'files':{str(p.relative_to(o)):h(p) for p in sorted(o.rglob('*')) if p.is_file()}}
write(o/'root-seal.json',record)
print(json.dumps({k:v for k,v in record.items() if k!='files'}))
