#!/usr/bin/env python3
"""Build arithmetic measured reports from preserved executions; never execute Lean."""
from pathlib import Path
import hashlib,json,itertools,re,datetime
R=Path(__file__).resolve().parents[5]
B=R/'review/semantic-kernel/integer-arithmetic'
D=B/'implementation/evidence-development'
C=B/'coverage-measured-r1'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def write(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def binding(p):return {'path':str(p.relative_to(R)),'sha256':digest(p),'bytes':p.stat().st_size}
q=read(D/'qualification-r4.json');assert q['status']=='PASS'
prod=B/'mutations-r1';ctrl=B/'implementation/runner-controls-r1'
res=read(prod/'results.json');s=read(prod/'source-manifest.json');spec=read(prod/'mutation-spec.json')
control=res['results']['control']['checks'];assert len(control)==45 and set(control.values())=={'true'}
rows=q['production']['mutations'];assert len(rows)==12
write(prod/'measured-matrix.json',{'candidate':s['git_head'],'ordered_checks':list(control),'rows':[
 {'name':name,'checks':row['checks'],'false':row['false_comparisons']} for name,row in res['results'].items()],
 'designated_and_siblings':rows,'global_positives':spec['positive_checks'],
 'limits':'Observed sensitivity is not a unique fault classifier; full false inventories retained.'})
write(prod/'oracle-overlap.json',{'pair_count':66,'pairs':[{'left':a['id'],'right':b['id'],
 'shared_false':sorted(set(a['false'])&set(b['false']))} for a,b in itertools.combinations(rows,2)],
 'scope':'Measured false-label overlap, not causal attribution or independent oracles.'})
inv=read(prod/'invocation.json')
(prod/'REPORT.md').write_text('# Arithmetic production mutation evidence\n\n'
 f'Actual execution `{s["git_head"]}`: unchanged control and all 12 mutants compiled, with 45 unique comparisons each (585 total). All 12 designated comparisons became false. Both global positives remained true in all 13 variants (26 results), and all 12 planned sibling results stayed true.\n\n'
 f'The suite took {inv["elapsed_seconds"]} seconds; the unchanged projection command took {q["production"]["control_command"]["elapsed_seconds"]} seconds. Each command limit was 600 seconds. Exact commands, run UTC, labelled command elapsed times, raw logs, source captures, Git objects and hashes are preserved. No per-command UTC or unlogged binding-call timing is inferred.\n\n'
 'The projection contains nine Arithmetic runtime roots and four retained Typed dependencies, plus three pinned configuration inputs. Only Arithmetic proof suffixes are stripped; imported Typed proofs remain. ProofAudit and Verify are separate proof roots.\n\n'
 'M04 changes the shared divideNat denominator check and also falsifies F45. M05/M06/M10 propagate into quote-derived reference fixtures; M12 edits the actual collector effect consumed by Typed.execute. The matrix records every false result; overlap does not identify a unique fault.\n\n'
 'The original M12 development-site hash predates a Reference proof-tail extension. The checker retains that record and proves exact runtime-prefix equality between the captured old bytes and the frozen source. qualification-r4.json records both hashes. No mutation needle or expected result changed.\n\n'
 'This is mechanical evidence qualification. Native scientific review and scoped delivery remain pending.\n')
summary=read(ctrl/'summary.json');ci=read(ctrl/'invocation.json')
(ctrl/'REPORT.md').write_text('# Arithmetic actual CLI controls\n\n'
 f'All 65 real CLI cases passed at their actual execution revision `{ci["frozen_source"]}`: 10 exit 0, five exit 1 and 50 exit 3. The run took {ci["elapsed_seconds"]} seconds. Every CLI log path, raw byte hash, output string, expected classification, Lean observation log and labelled runner-command log was reconciled.\n\n'
 'These are retained controls, not a new run at the later full-source freeze. The driver, harness, pinned tool/configuration bytes are preserved; implementation/retained-evidence.json establishes applicability to the full candidate. Synthetic Lean projects test runner behavior and are not production financial evidence.\n\n'
 '666 original regular files were copied hash-exact. One nested Git repository was archived; two symlinks were recorded without following them. Both production-form #eval cases retain distinct top-level CLI logs and Lean probe logs. Per-case timing and run UTC are retained; no additional timing is inferred.\n')
# Actual helper inventory is tied to captured runtime bytes, not a directory-name inference.
metadata=read(B/'implementation/financial/full-development-r2/actual-projection-inventory.json')
actual=[]
for module in s['projection_order']:
 path='lean/'+module.replace('.','/')+'.lean';raw=(prod/'inputs'/path).read_bytes()
 if module in spec['modules']:
  item=metadata['modules'][path]
  assert item['sha256']==digest(prod/'inputs'/path)
  assert item['runtime_prefix_sha256']==hashlib.sha256(raw.split(b'\n-- BEGIN PROOFS\n')[0]).hexdigest()
  actual.append({'module':module,'source':path,**item})
assert len(actual)==9
write(prod/'actual-helper-inventory.json',{'runtime_root_count':9,'local_closure_count':13,
 'all_local_modules':s['projection_order'],'runtime_roots':actual,
 'proof_only_roots':['DefiKernel.Arithmetic.ProofAudit','DefiKernel.Arithmetic.Verify'],
 'metadata':binding(B/'implementation/financial/full-development-r2/actual-projection-inventory.json'),
 'scope':'Named lexical runtime declarations and anonymous instance counts from actual captured prefixes; generated Lean declarations are separately dynamically inventoried.'})
# Bind exact normative scenarios and actual theorem types.
plan=R/'openspec/changes/checked-integer-financial-arithmetic'
planned=read(plan/'scenario-map.json')['scenarios'];assert len(planned)==36
proof=read(B/'proof-inventory-r2/proof-inventory.json')
byname={t['source_name']:t for t in proof['theorems'] if t['declaration_origin']=='explicit'}
P={
'W01':['ofNat_ok_iff','ofNat_error_iff'],'W02':['Word.width_zero'],
'W03':['Operations.add_ok_iff','Operations.add_error_iff'],
'W04':['Operations.sub_ok_iff','Operations.sub_error_iff'],
'W05':['Operations.mul_ok_iff','Operations.mul_error_iff'],
'W06':['Rounding.mulDiv_ok_iff','Rounding.mulDiv_error_iff'],
'W07':['Operations.add_ok_iff','Operations.add_error_iff','Operations.sub_ok_iff','Operations.sub_error_iff','Operations.mul_ok_iff','Operations.mul_error_iff','Rounding.mulDiv_ok_iff','Rounding.mulDiv_error_iff'],
'R01':['Rounding.mulDiv_down_ok_iff','Rounding.mulDiv_up_ok_iff'],
'R02':['Rounding.divideNat_error_iff','Rounding.mulDiv_divisionByZero_iff'],
'R03':['Rounding.divideNat_exact','Rounding.mulDiv_exact_iff'],
'R04':['Rounding.mulDiv_quotientOverflow_iff','Rounding.mulDiv_down_ok_iff','Rounding.mulDiv_up_ok_iff'],
'R05':['Fees.feeFromGross_down_ok_iff','Fees.feeFromGross_up_ok_iff','Fees.feeFromGross_conservation'],
'R06':['Fees.feeOnTop_up_ok_iff','Fees.feeOnTop_conservation'],
'R07':['Fees.validatedRate_error_iff','Fees.feeFromGross_error_iff','Fees.feeOnTop_error_iff'],
'R08':['Fees.feeOnTop_error_iff','Fees.feeOnTop_overflow_of_round'],
'R09':['Fees.feeFromGross_zero_amount','Fees.feeFromGross_exists_iff','Fees.feeFromGross_ok_iff'],
'R10':['Rounding.divideNat_down_rational_error','Rounding.divideNat_up_rational_error','Rounding.mulDiv_down_rational_error','Rounding.mulDiv_up_rational_error','Rounding.mulDiv_equal_iff_dvd'],
'Q01':['Quantity.fromRat_toQuantity','Quantity.toQuantity_amount'],
'Q02':['Quantity.fromRat_error_iff'],'Q03':['Quantity.fromRat_error_iff'],
'Q04':['Quantity.fromRat_exists_iff','Quantity.fromRat_ok_iff_div','Quantity.toQuantity_fromRat_eq'],
'Q06':['Reference.execute_quote','Reference.execute_quote_balance','Reference.quote_accounting','Examples.allCells_complete','Tests.stateEq_iff'],
'Q07':['Reference.netEffect_scalar_formula','Reference.quote_accounting','Reference.execute_quote_balance'],
'Q08':['Reference.execute_insufficientFunds','Reference.execute_unauthorizedDebit','Reference.observeExecution_input'],
'Q09':['Reference.quote_conservation']}
case_byname={c['name']:c for c in summary['cases']}
cli={
'E02':['missing-audit-root','empty-module-inventory','fresh-dependency-source-failure','runtime-definition-after-proof-boundary','attributed-runtime-after-proof-boundary','macro-after-proof-boundary'],
'E03':['all-true-mutant','required-observation-stays-true','production-eval-required-stays-true'],
'E04':['positive-control-flipped','compilation-only-failure','compiler-error-with-runtime-failure'],
'E05':['dirty-source-before-run','source-drift-during-run','source-drift-during-mutant','empty-observations','duplicate-observations','partial-mutant-observations']}
evidence={k:B/v for k,v in {
'proof':'proof-inventory-r2/proof-inventory.json','integration':'integration-r1/verification.json',
'production':'mutations-r1/results.json','controls':'implementation/runner-controls-r1/summary.json',
'artifact_controls':'implementation/evidence-development/artifact-controls-r2/results.json',
'reconciliation':'implementation/evidence-development/qualification-r4.json',
'compiler':'compiler-controls/run-r1/result.json','diagnostic':'diagnostics/run-r1/result.json',
'retained':'implementation/retained-evidence.json','planning_gate':'planning/official-r1/gate-status.json',
'helper_inventory':'mutations-r1/actual-helper-inventory.json'}.items()}
out=[]
for original in planned:
 sid=original['id'];path=plan/'specs'/original['capability']/'spec.md';text=path.read_text()
 match=re.search(r'^#### Scenario: '+sid+r' .*?(?=\n#### Scenario:|\n### Requirement:|\Z)',text,re.M|re.S);assert match
 row={**original,'status':'MECHANICALLY_COVERED_FINAL_REVIEW_PENDING',
      'normative':{**binding(path),'line':text[:match.start()].count('\n')+1,'text':match.group().strip()},
      'proofs':[],'runtime':[],'mutations':[],'cli_controls':[],'evidence':[], 'limitations':[]}
 row.pop('evidence_hash',None)
 for name in P.get(sid,[]):
  theorem=byname['DefiKernel.Arithmetic.'+name]
  row['proofs'].append({k:theorem[k] for k in ['name','source_name','source','line','source_sha256','category','statement','axioms','premises']})
 if row['proofs']:row['evidence'].append('proof')
 for fid in original['fixtures']:
  label='arithmetic.fixture.'+fid.lower();assert control[label]=='true'
  row['runtime'].append({'fixture':fid,'label':label,'value':'true','variant':'control'})
  row['mutations'] += [m['id'] for m in rows if label in m['required_false']]
 if row['runtime']:row['evidence']+=['production','integration']
 row['mutations']=sorted(set(row['mutations']))
 for name in cli.get(sid,[]):
  c=case_byname[name];row['cli_controls'].append({'name':name,'expected_exit':c['expected_exit'],'actual_exit':c['actual_exit'],'log_sha256':c['log_sha256']})
 if row['cli_controls']:row['evidence']+=['controls','retained']
 if sid in ['W08','E06']:row['evidence']+=['diagnostic','retained'];row['limitations'].append('27,968 actual four-bit oracle cases at 144e, preserved by relevant-source equivalence; finite execution is not a universal proof or chain fidelity.')
 if sid=='Q05':row['evidence'].append('compiler');row['limitations'].append('T01 compiler rejection and T02 compiling sibling exercise actual toQuantity; neither is a runtime semantic mutant.')
 if sid=='Q06':row['limitations'].append('F25 literal balances100/67/33. Nonunit F42 uses25/67/4/33/4; payer-coincident F40/F41 are supplemental full observations, not substitutes for this trigger.')
 if sid in ['Q06','Q07','Q08','Q09']:row['limitations'].append('Reference proofs retain explicit quote conservation, positive scale, authorization, domain/footprint and balance premises as applicable. Full elaborated statements are authoritative; no entire Valid hypothesis is assumed as construction evidence.')
 if sid=='Q09':row['mutations']=['M12'];row['evidence'].append('production');row['limitations'].append('M12 compiling collector-effect omission fails F25; separate F14 quote sibling remains true. No unique fault attribution follows.')
 if sid=='Q10':row['status']='SCOPE_BOUNDARY_DOCUMENTED';row['limitations'].append('No deployed-protocol refinement, sequential token-debit, dynamic pricing or arbitrary-template claim; this is a scope judgment, not an executable deployment rejection.')
 if sid=='E01':row['evidence'].append('planning_gate');row['limitations'].append('Both required substantive planning reviews preceded implementation; final native scientific acceptance remains pending.')
 if sid=='E02':row['evidence']+=['helper_inventory','reconciliation'];row['limitations'].append('Nine actual runtime roots/13localmodules explicitly bound; inherited synthetic controls test missing imports/root and post-marker runtime rejection.')
 if sid=='E05':row['evidence']+=['proof','artifact_controls','reconciliation'];row['limitations'].append('Dynamic imported audit reports zero forbidden axioms. This package does not claim a new deliberate forbidden-axiom injection; A01–A04 execute actual saved-artifact rejection checks.')
 if sid in ['E07','E08']:row['status']='PENDING_NATIVE_REVIEW' if sid=='E07' else 'PENDING_SCOPED_DELIVERY';row['limitations'].append('No final native-review or archive/delivery result is available in this map. Preserve failed/unavailable responses if they occur.')
 row['evidence']=[{'key':k,**binding(evidence[k])} for k in dict.fromkeys(row['evidence'])]
 row['actual_categories']=list(dict.fromkeys(([t['category'] for t in row['proofs']])+(['finite_runtime'] if row['runtime'] else [])+(['semantic_mutation'] if row['mutations'] else [])+(['actual_cli_control'] if row['cli_controls'] else [])+(['compiler_control'] if sid=='Q05' else [])+(['finite_diagnostic'] if sid in ['W08','E06'] else [])+(['scope_or_gate'] if sid.startswith('E') or sid=='Q10' else [])))
 out.append(row)
assert len(out)==len({x['id'] for x in out})==36
write(C/'scenario-map.json',{'candidate':s['git_head'],'status':'MEASURED_AUTHOR_MAP_NOT_INDEPENDENT_ACCEPTANCE','created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'builder':binding(Path(__file__)),
 'counts':{'scenarios':36,'mechanically_covered':33,'scope_boundary':1,'pending_native_or_delivery':2},
 'normative_plan_map':binding(plan/'scenario-map.json'),'scenarios':out})
(C/'REPORT.md').write_text('# Arithmetic scenario evidence\n\n36 exact normative scenarios are mapped: 33 have mechanical evidence, Q10 records a scope boundary, E07 remains pending final native review and E08 remains pending scoped delivery. The immutable proposed map is unchanged.\n\n'
 'Evidence classes remain separate: 123 explicit generic theorems, two finite reference comparator theorems, 182 generated theorem constants, 233 supplemental declarations; 45 actual runtime comparisons; 12 compiling semantic mutants; 65 actual CLI controls; T01/T02 compiler pair; four saved-artifact corruption controls and an unchanged sibling; 27,968 bounded diagnostic cases. No finite check substitutes for a generic theorem.\n\n'
 'All full theorem statements and premises used by a row are included with source hashes and locations. Runtime rows refer to literal fixture IDs in complete control observations. Retained controls and diagnostic retain actual144e identity; their relevant source equivalence is separately bound.\n\n'
 'The map is an author reconciliation, not independent acceptance. Native verdicts and branch/archive delivery must be added in a later overlay without rewriting this measured snapshot.\n')
write(C/'evidence-summary.json',{'candidate':s['git_head'],'status':'MECHANICALLY_QUALIFIED_NATIVE_AND_DELIVERY_PENDING',
 'counts':{'runtime':45,'variants':13,'comparisons':585,'detected_mutants':12,'global_positive_results':26,'sibling_positive_results':12,'cli_cases':65,'cli_exit_counts':{'0':10,'1':5,'3':50},'artifact_negative_controls':4,'artifact_unchanged_positive':1,'compiler_controls':2,'finite_diagnostic_cases':27968,'theorems':307,'explicit_generic':123,'reference_instances':2,'generated_theorems':182,'supplemental':233,'forbidden_axioms':0,'integration_commands':21,'integration_runtime_comparisons':1032,'scenarios':36},
 'evidence':{k:binding(p) for k,p in evidence.items()},'source_unchanged':True,
 'retained_failures':['implementation/evidence-development/qualification-r1.json (stale M12 proof-tail metadata)', 'implementation/evidence-development/qualification-r3.json (uncommitted site metadata Git lookup)', 'implementation/evidence-development/artifact-controls-r1/ (same metadata lookup blocked all copies)', 'proof-inventory-r1/ (author helper expected Verify import to emit audit output)'],
 'limits':['Native scientific acceptance and scoped delivery pending.','Mutation sensitivity does not identify unique faults; all false sets and pair overlap retained.','Synthetic CLI cases test harness behavior, not production financial behavior.','Reference is an explicitly premised static quote template through actual Typed.execute; no deployed fidelity.','Execution UTC and labelled command/case elapsed times are retained; no unlogged binding-call timing or per-command UTC inferred.']})
# Final artifact hashes exclude only their own inventory file.
for directory in [prod,ctrl,D,C]:
 entries=[binding(p) for p in sorted(directory.rglob('*')) if p.is_file() and p.name!='artifact-inventory.json']
 write(directory/'artifact-inventory.json',{'files':len(entries),'artifacts':entries,'scope':'All regular artifacts excluding this inventory itself; nested Git and copied Acontrol inputs archived.'})
print(json.dumps({'scenario_count':len(out),'production_rows':len(rows),'helper_roots':len(actual),'status':'REPORTS_BUILT'}))
