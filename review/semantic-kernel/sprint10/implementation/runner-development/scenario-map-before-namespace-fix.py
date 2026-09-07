#!/usr/bin/env python3
"""Capture immutable author coverage snapshots; source presence is not final proof acceptance."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
SPEC = ROOT / 'openspec/changes/operational-interface-binding-preservation/specs'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return json.loads(path.read_text())
def save(path,obj): path.write_text(json.dumps(obj,indent=2)+'\n')
# Explicit content mappings. Names are checked against actual source below.
MAP = {}
def add(key,proofs='',runtime='',tasks='',mutants='',notes='',gaps=''):
    MAP[key] = dict(proofs=proofs.split(),runtime=runtime.split(),tasks=tasks.split(),mutants=mutants.split(),notes=notes,gaps=gaps)
add('RA01','balanceSum_empty receiptDelta_empty','region.empty','2.1 5.1','M01')
add('RA02','','region.duplicate','2.1 5.1',notes='Set semantics need the exact duplicate-insertion companion; a plain two-cell region is insufficient.',gaps='duplicate-insertion-runtime')
add('RA03','TypedTotalContract step_typed_total_preserved Fixtures.region_wellFormed','region.bad-domain region.bad-asset','2.1',notes='General untyped sum equalities need no well-formedness; typed total API retains the premise explicitly.',gaps='malformed-region-negative-runtime')
add('RA04','step_receipt_region','region.transfer-full region.transfer-total region.transfer-effects region.neutral-delta','2.2 2.3 5.1','M01 M02 M04')
add('RA05','step_receipt_region','region.transfer-out region.singleton-total region.transfer-supply','2.2 3.1','M02 M05')
add('RA06','step_receipt_region','region.mint-full region.mint region.mint-total','2.2 5.1','M04')
add('RA07','receiptCellEffect_eq_receiptEffect step_receipt_region','region.repeated-full region.repeated region.repeated-total','2.2 5.1','M03')
add('RA08','issue_region_unchanged revoke_region_unchanged receiptDelta_issued receiptDelta_revoked','admin.issue-full admin.revoke-full admin.complete-cursor admin.issued-delta admin.revoked-delta','2.3 5.4','M14')
add('RA09','advance_accounting_suffix','admin.unauthorized admin.unauthorized-cursor','2.3 5.4',notes='Refusal has no successful StepResult; actual cursor identity retains world while failure records refusal.')
add('RA10','continueRun_accounting_suffix continueRun_accounting','group.refusal-suffix group.refusal-total','2.4 4.1 5.4')
add('RA11','interleaving_runPrefix_accounting','shared.refusal-last shared.receipts shared.receipt-flow','2.4 4.2 5.4')
add('RA12','interleaving_continueRun_accounting_suffix','shared.peer-after-refusal shared.refused-prefix shared.receipts','2.4 4.2 5.4')
add('RA13','interleaving_advance_accounting_suffix','shared.failed-suffix-skipped shared.skipped-prefix shared.no-mint-supply','2.4 4.2 5.4')
add('IT01','step_region_neutral Fixtures.transfer_confined Fixtures.transfer_neutral','region.transfer-total region.transfer-effects','3.1')
add('IT02','step_receipt_region','region.transfer-out region.transfer-supply','3.1 5.2','M05',notes='Concrete accepted boundary-flow counterexample to whole-supply sufficiency.')
add('IT03','step_effect_outside_writes step_effect_outside receiptDelta_eq_inter','region.transfer-full','3.1',notes='The generic locality proof covers every complement cell; full finite execution is only an instance.')
add('IT04','sequential_ghost_total_preserved sequential_prefix_preserves','region.transfer-total','3.2',notes='The prefix theorem quantifies count; apply the local total rule with constant value and initialized10.')
add('IT05','step_value_frame step_total_preserved Fixtures.total_value_supported Fixtures.f05_obligations Fixtures.f05_every_prefix','region.private-total-full region.private-total','3.2 5.2')
add('IT06','sequential_ghost_total_preserved','region.missing-initialization','3.2 5.2',notes='Initialization remains a theorem premise; require explicit11-versus10 neutral-step counterexample.',gaps='missing-initialization-runtime')
add('IT07','','region.exposed-total-full region.exposed-total-counterexample','3.3 5.2',notes='Actual successful op105 violates the supported-value relation; finite counterexample theorem is separately required.',gaps='F06-counterexample-proof-instance')
add('IT08','step_total_preserved','region.exposed-total-counterexample','3.3 5.2',notes='Need exact WritesWithin/NeutralOn and failed support-exclusion witness in F06 instance.',gaps='F06-exact-missing-support-premise')
add('IT09','group_accounting group_total_preserved continueRun_outputs_suffix','group.snapshot-first group.snapshot-complete group.snapshot-total group.snapshot-new-receipts group.snapshot-flow','4.3 5.4',notes='Arbitrary entry cursor, no genesis TraceSound; F16 is total/history evidence, not initialized A=B.')
add('IT10','interleaving_total_preserved interleaving_prefix_typed_total_preserved','shared.all-prefix-totals shared.peer-after-refusal shared.failed-suffix-skipped','4.2 5.4')
add('IT11','advance_preserves interleaving_advance_preserves','group.refusal-suffix shared.failed-suffix-skipped shared.skipped-prefix','3.4 4.1 4.2',notes='Generic advance cases include failed and exhausted identity; finite F20 exercises failed suffix only.')
add('GB01','resolveExport_iff distinct_exports_nonalias checkBindings_ok_iff','binding.unequal','2.5 2.6','M10')
add('GB02','checkEdge_error_iff checkBindings_first_failure','binding.missing-port binding.missing-component-left binding.missing-component-right binding.later-index','2.5 2.6','M11')
add('GB03','checkEdge_error_iff','binding.asset binding.domain binding.domain-before-asset binding.dimension-amounts','2.5','M08 M09')
add('GB04','checkEdgesFrom_error_iff checkBindings_first_failure','binding.first-failure binding.left-before-right','2.5 2.6','M12')
add('GB05','checkBindings_error_iff','binding.invalid-empty binding.valid-empty','2.5','M13')
add('GB06','resolveExport_iff','binding.input-not-resource binding.output-not-resource','2.5 2.6',notes='Qualified input/output IDs are not resource exports; history lookup is distinct.')
add('GB07','checkBindings_ok_iff bindingsHold_iff','group.paired-entry binding.hold-success','2.6 5.3')
add('GB08','checkBindings_ok_iff','binding.one-sided-full binding.unequal binding.hold-failure','4.4 5.3','M06 M07')
add('GB09','valid_import_resolution','binding.import-source binding.import-after-write','2.6 4.4 5.3')
add('GB10','edgeAgrees_self checkEdge_error_iff','binding.self-edge binding.unresolved-self','2.6 4.4',gaps='unresolved-self-runtime')
add('GB11','step_binding_preserved Fixtures.paired_nonzero_effects Fixtures.f07_local_rule Fixtures.f07_group_initialized_preservation','binding.paired-full binding.paired-effects group.paired-first group.paired-complete group.paired-first-binding group.paired-complete-binding','4.1 4.3 4.4 5.3')
add('GB12','sequential_prefix_bindings_preserved','group.refusal-suffix','4.1 5.4',notes='Full expected4/4/2 world plus generic initialized prefix theorem; exact refused suffix retained.')
add('GB13','interleaving_prefix_bindings_preserved','shared.refusal-last shared.peer-after-refusal shared.all-prefix-bindings','4.2 5.4')
add('GB14','effectPaired_issued effectPaired_revoked interleaving_advance_preserves','admin.issue-full admin.revoke-full shared.failed-suffix-skipped','4.2 4.4 5.4')
add('GB15','agrees_append agrees_reverse_edges agrees_duplicate agrees_perm agrees_assoc localBindings_append localBindings_reverse localBindings_duplicate localBindings_perm localBindings_assoc','binding.duplicate binding.reverse','4.5',notes='Local obligation transport plus generic prefix lifting supplies initialized corollaries; success equivalence only.')
add('GB16','','binding.global-edge binding.cut-extraction binding.cut-omission-counterexample','4.5 5.3',notes='Actual global query compared with explicitly cut-extracted empty list; no three-participant executor.')
add('GB17','bindingsHold_perm bindingsHold_reverse checkBindings_first_failure','binding.reverse binding.first-failure','4.5',notes='Exact ordered diagnostics can change even with equal success predicates.')
add('GB18','agrees_of_symClosure_eq localBindings_symClosure','','4.6')
add('GB19','agrees_transitive_extension symClosure_transitive_extension_ne Fixtures.f10_all_state_equivalence Fixtures.f10_distinct_symmetric_closures','binding.existing-port binding.transitive-redundant binding.distinct-closures','4.6 5.3',notes='Fixture proof quantifies every state in the concrete finite universe; sufficient-only closure result is generic.')
add('GB20','','binding.transitive-negative binding.valid-empty','4.6 5.3',notes='Independent edge can constrain states; no necessity or complete-equivalence checker claimed.')
add('RE01','','fixture.twenty-cells fixture.seventeen-capabilities region.transfer-full region.repeated-full group.snapshot-complete shared.peer-after-refusal','5.1 5.2 5.3 5.4',notes='Source inspection of literal expected records and full comparators, plus actual development execution; final source review pending.')
add('RE02','','region.exposed-total-full region.exposed-total-counterexample binding.one-sided-full binding.unequal','5.2 5.3')
add('RE03','','','5.5',notes='Audit numeric protocol, full financial inventory and actual pinned command; final frozen run pending.')
add('RE04','','','6.1 6.3',mutants=' '.join(f'M{i:02}' for i in range(1,15)),notes='All14 official mutation variants pending committed source freeze.')
add('RE05','','','6.2 6.4',notes='Actual65 control suite pending; development2 production forms passed but do not satisfy whole suite.')
add('RE06','','','6.2',notes='Preserve exact65 accepted CLI cases including both production #eval forms and proof scanner limits.')
add('RE07','','','6.2 6.4',notes='Actual source/spec/driver/HEAD drift and nonempty inventory/output protections; official cases pending.')
add('RE08','','','5.5 7.1',notes='Verify dynamic imported theorem/supplemental inventory, actual types/axioms and declaration provenance pending final run.')
add('RE09','','','1.3 7.2',notes='Fresh or exact relevant-source-equivalent legacy evidence with honest execution identity pending.')
add('RE10','','','7.3',notes='Only authorized root integration and new Interface source; final preservation reconciliation pending.')
add('RE11','','','1.1 1.2',notes='Accepted S9 dependency manifest and both planning verdicts bound before source implementation.')
add('RE12','','','1.2 7.4',notes='Planning gate substantive; implementation/evidence native Grok/Fable reviews still pending.')
add('RE13','','','7.4 8.1 8.2',notes='Final adjudication/archive/remote delivery pending; no inferred review-round cap.')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--financial-inventory',type=Path,required=True)
    args=parser.parse_args();out=args.out.resolve();assert not out.exists();assert out.is_relative_to(ROOT)
    source_files=sorted((ROOT/'lean/DefiKernel/Interface').glob('*.lean'))
    symbols={};source_bindings=[]
    for path in source_files:
        raw=path.read_bytes();text=raw.decode();namespace=re.search(r'^namespace (\S+)',text,re.M).group(1)
        source_bindings.append({'path':str(path.relative_to(ROOT)),'sha256':sha(raw),'bytes':len(raw)})
        for match in re.finditer(r'^(?:@\[[^\n]*\]\s*)?(theorem|def|abbrev)\s+(\S+)',text,re.M):
            kind,name=match.group(1),match.group(2);full=namespace+'.'+name;end=text.find(':=',match.start());statement=text[match.start():end if end>=0 else match.end()].strip()
            symbols[full]={'name':full,'kind':kind,'path':str(path.relative_to(ROOT)),'line':text[:match.start()].count('\n')+1,'source_sha256':sha(raw),'source_declaration_header':statement,'header_scope':'source syntax, not full elaborated theorem type or completed compiler evidence','category':'finite_instance' if '.Fixtures.' in full else 'generic_proof' if kind=='theorem' else 'runtime_definition'}
    tests=(ROOT/'lean/DefiKernel/Interface/Tests.lean').read_text();label_refs={}
    for m in re.finditer(r'\("(interface\.[^"]+)"',tests):label_refs[m.group(1)]={'name':m.group(1),'path':'lean/DefiKernel/Interface/Tests.lean','line':tests[:m.start()].count('\n')+1,'source_sha256':sha(tests.encode())}
    finance=read(args.financial_inventory);inventory=finance['runtime_inventory'];source_match={p:sha((ROOT/p).read_bytes())==(v if isinstance(v,str) else v['sha256']) for p,v in finance['sources'].items()}
    rows=[];spec_bindings=[]
    for path in sorted(SPEC.glob('*/spec.md')):
        raw=path.read_bytes();text=raw.decode();spec_bindings.append({'path':str(path.relative_to(ROOT)),'sha256':sha(raw),'bytes':len(raw)})
        matches=list(re.finditer(r'^#### Scenario: (\w+) (.+)$',text,re.M))
        for i,m in enumerate(matches):
            key=m.group(1);rule=MAP[key];requirement=list(re.finditer(r'^### Requirement: (.+)$',text[:m.start()],re.M))[-1].group(1);body=text[m.end():matches[i+1].start() if i+1<len(matches) else len(text)].split('### Requirement:')[0].strip()
            proof_refs=[];missing=[]
            for name in rule['proofs']:
                full='DefiKernel.Interface.'+name
                if full in symbols:proof_refs.append(symbols[full])
                else:missing.append('proof:'+full)
            runtime=[]
            for name in rule['runtime']:
                full='interface.'+name
                if full in label_refs:runtime.append({**label_refs[full],'development_observed':full in inventory,'development_source_binding_matches':all(source_match.values()),'official_frozen_evidence':'pending'})
                else:missing.append('runtime:'+full)
            pending=['final_source/proof_inventory','native_final_reviews','delivery']
            if rule['mutants']:pending+=['official14_mutation_suite_and_sibling_matrix']
            if key.startswith('RE'):pending+=['official_evidence_gate_for_'+key]
            rows.append({'id':key,'title':m.group(2),'requirement':requirement,'spec_path':str(path.relative_to(ROOT)),'spec_line':text[:m.start()].count('\n')+1,'spec_sha256':sha(raw),'normative_scenario':body,'tasks':rule['tasks'],'proof_source_refs':proof_refs,'runtime_refs':runtime,'mutants':rule['mutants'],'notes':rule['notes'],'explicit_gap_followup':rule['gaps'],'missing_source_refs':missing,'pending_evidence':pending,'status':'IMPLEMENTATION_COVERAGE_DRAFT_NOT_FINAL_ACCEPTANCE'})
    assert len(rows)==len(MAP)==57 and len({r['id'] for r in rows})==57
    gate=ROOT/'review/semantic-kernel/sprint10/planning/r2-gate-acceptance.json'
    result={'kind':'immutable_author_scenario_coverage_snapshot','utc':datetime.now(timezone.utc).isoformat(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'scope':'Current worktree source coverage with actual development runtime inventory; no official proof/mutation/control/source-review pass inferred.','scenario_count':57,'source_bindings':source_bindings,'spec_bindings':spec_bindings,'development_inventory':{'path':str(args.financial_inventory),'sha256':sha(args.financial_inventory.read_bytes()),'count':len(inventory),'sources_match_current':source_match},'planning_gate':{'path':str(gate.relative_to(ROOT)),'sha256':sha(gate.read_bytes()),'status':read(gate)['status']},'rows':rows,'future_artifact_slots':{'proof_inventory':None,'official_mutations':None,'official_controls':None,'legacy_regressions':None,'native_source_review':None,'native_evidence_review':None,'delivery':None},'script_sha256':sha(Path(__file__).read_bytes())}
    out.mkdir(parents=True);save(out/'scenario-map.json',result)
    text=f'# Sprint10 initial scenario coverage\n\nAll57 exact normative scenarios are mapped to current source declarations, runtime IDs and planned evidence. This is author coverage, not final acceptance. Development inventory contains{len(inventory)} names; current source bindings match={all(source_match.values())}. Official14 mutants,65 controls, final imported proof inventory, native review and delivery remain pending.\n\n| Scenario | Source proofs | Runtime labels | Missing source |\n|---|---:|---:|---|\n'
    for row in rows:text+=f'| {row["id"]} {row["title"]} | {len(row["proof_source_refs"])} | {len(row["runtime_refs"])} | {", ".join(row["missing_source_refs"]) or "—"} |\n'
    text+='\nFlagged narrow follow-ups: duplicate region insertion, malformed-region negative values, missing-initialization neutral-step companion, unresolved self-edge, and F06 counterexample proof with exact failed support-exclusion premise. These are recorded before requested authors finish them; later snapshots must bind their actual new source instead of silently changing this snapshot.\n'
    (out/'coverage.md').write_text(text)
    save(out/'artifact-inventory.json',[{'path':p.name,'bytes':p.stat().st_size,'sha256':sha(p.read_bytes())} for p in sorted(out.iterdir())])
    print(json.dumps({'rows':57,'runtime_names':len(inventory),'missing_source_refs':sum(len(r['missing_source_refs']) for r in rows),'output':str(out)}))

if __name__=='__main__':main()
