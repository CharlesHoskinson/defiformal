#!/usr/bin/env python3
"""Author-generated M2 planning contracts and mechanical coverage; no proof/audit claims."""
import hashlib, json, re, subprocess, sys
from pathlib import Path
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parents[5]
CHANGE=ROOT/'openspec/changes/operational-interface-binding-preservation'
OUT=Path(__file__).resolve().parent
specs=[]
def capability(name,purpose,requirements): specs.append((name,purpose,requirements))
def req(title,text,tasks,evidence,scenarios): return dict(title=title,text=text,tasks=tasks,evidence=evidence,scenarios=scenarios)
capability('typed-region-accounting','Connect finite typed balance regions to the exact signed effects of actual accepted execution receipts, including boundary transfers and issuance.',[
req('Finite typed region observations','The system SHALL expose finite region sums with set membership, exact domain/asset well-formedness and zero for an empty region. Repeated region declarations MUST NOT duplicate balances; typed interface results MUST state region well-formedness.', ['2.1','5.1'], ['balanceSum_set','region_wellformed','F01','M01'],[
('RA01 Empty region','an empty region is observed in any state','the balance sum and receipt delta are both zero'),
('RA02 Duplicate declarations','the same home/USD Alice cell is inserted twice into a region with Alice6 and Bob4','the region sum is10, not16, and membership remains set-valued'),
('RA03 Typed membership','a region declared home/USD contains an away or EUR cell','the region well-formedness proposition is false; dimensioned preservation cannot omit that premise')]),
req('Exact signed actual receipt accounting','For every actual successful invocation or administrative step, the system SHALL prove post-region sum equals pre-region sum plus the complete signed effect of that actual result receipt. The theorem MUST NOT assume this equation or accept a replacement receipt as its premise.', ['2.2','2.3','5.1'], ['actual_region_accounting','receiptCellEffect_eq','F01','F02','F03','F04','M02','M03','M04','M05'],[
('RA04 Neutral nonzero transfer','actual authorized transfer2 moves Alice6/Bob4 to4/6','the two-cell sum remains10 with effects −2,+2 and net region delta0'),
('RA05 Boundary-crossing transfer','the same actual transfer is observed in singleton Alice region','the sum changes6 to4 and delta is−2 even though whole home/USD supply is0'),
('RA06 Nonzero issuance','actual authorized mint3 credits Bob from4 to7 in the two-cell region','the sum changes10 to13 and receipt delta is+3; no neutral-flow conclusion is inferred'),
('RA07 Repeated targets','the actual receipt contains Alice−1,Alice−2,Bob+3 in that order','the singleton Alice delta is−3, final Alice3/Bob7, and all original receipt entries are retained')]),
req('Administrative balance identity','The system SHALL derive zero region effect for successful issue/revoke receipts and unchanged balances on actual administrative refusal, while retaining exact capability-store changes and refusal reasons.', ['2.3','5.4'], ['administrative_region_identity','F18','M14'],[
('RA08 Issue and revoke','an authenticated administrator issues a capability at fresh ID n then revokes n','all balances stay unchanged, both region deltas are0, and the store appends then tombstones that exact entry'),
('RA09 Refused administration','a non-administrator attempts the same issue','the actual authority refusal retains the input world/store and produces no successful receipt')]),
req('Actual successful prefix accounting','The system SHALL prove telescoping region accounting over actual successful sequential events and global shared-run attempts at every prefix. Refused, skipped and unreachable suffix actions MUST NOT contribute a receipt.', ['2.4','4.1','4.2','5.4'], ['sequential_receipt_fold','shared_receipt_fold','F15','F17','F19','F20'],[
('RA10 Successful prefix followed by refusal','paired debit succeeds from5/5/0 then transfer7 refuses and mint3 is a stopped suffix','the reached ledger is4/4/2, exactly one successful receipt is summed, and failure occurs at absolute index1'),
('RA11 Shared global receipt fold','complete schedule left,right,left executes two paired debits then a left insufficient-funds refusal in region Alice/Bob/Carol','the reached ledger is3/3/4 and exactly the two actual global successful receipts contribute'),
('RA12 Peer continues after refusal','the same F17 branches run under left,left,right from5/5/0','the first paired debit reaches4/4/2, left refusal at local index1 retains4/4/2, then the peer reaches3/3/4 with two actual successful receipts, exact retained left failure and unchanged full store'),
('RA13 Failed suffix skip before peer','left=[op102,op106,op101] and right=[op102] run under left,left,left,right','the failed left mint suffix adds no attempt, receipt or supply; left consumed becomes3 with nextIndex1, and the right peer still reaches3/3/4 with the exact earlier failure retained')])])
capability('interface-total-preservation','Establish initialized interface-total invariants from actual write confinement, shared-flow neutrality and explicit support for declared observations.',[
req('Conditional port-confined conservation','The system SHALL prove unchanged region sum from actual successful receipt writes confined to a declared shared set and zero summed effect over the region intersection with that set. Actual write locality MUST justify the complementary frame; catalog validity or whole-asset supply neutrality alone MUST NOT imply region neutrality.', ['3.1','5.2'], ['confined_neutral_preserves','F01','F02'],[
('IT01 Nonvacuous shared cancellation','Alice−2/Bob+2 are actual nonzero effects inside the region and shared set','the neutral intersection sum and actual confinement establish unchanged total10'),
('IT02 Supply neutrality is insufficient','actual transfer2 leaves the singleton Alice region with whole-asset supply0','the region total drops by2 and the missing region-neutrality premise is explicit'),
('IT03 Complement framed','an actual accepted receipt writes only inside Q','every region cell outside Q is unchanged by actual locality')]),
req('Supported declared total','The system SHALL distinguish a fixed initialized ghost quantity from a state-dependent declared total. For the latter it MUST require value-valued support, actual writes excluding that support and neutral region flow, and MUST prove preservation of the initialized equality.', ['3.2','3.3','5.2'], ['ValueSupports','supported_total_preserves','ghost_total_preserves','F05'],[
('IT04 Fixed declared quantity','initial region sum is10 and each actual permitted step has neutral confined region flow','the fixed declared quantity10 remains equal to the region sum at every prefix'),
('IT05 Private total support','a private home/USD total cell10 supports the declared quantity and actual transfer2 avoids it','both declared quantity and region sum remain10'),
('IT06 Missing initialization','a constant declared quantity11 is compared to entry region sum10 under only neutral later actions','preservation does not establish equality at entry or later; initialization remains required')]),
req('Actual writable-total counterexample','The system SHALL provide a separately valid catalog and an authorized successful transition that changes a writable declared-total observation while leaving the region sum unchanged. A denied access attempt MUST NOT stand in for this counterexample.', ['3.3','5.2'], ['writable_total_counterexample','F06'],[
('IT07 Exposed total changes','the separately exported writable total cell10 receives authorized +1 outside region Alice/Bob','execution succeeds, region stays10, declared total becomes11 and the equality is false'),
('IT08 Exact missing premise','the same accepted write is within shared Q and has zero region flow','the violated support-exclusion premise is identified; the example does not refute the theorem with all premises')]),
req('Initialized operational total lifting','The system SHALL lift local actual-step total obligations through every sequential prefix, accepted recursive sequential-group simulation and existing binary shared prefixes. Local obligations MUST quantify over arbitrary current execution inputs and permitted successful steps, without assuming the desired completed run.', ['3.4','4.1','4.2','4.3','5.4'], ['total_prefix_preservation','total_group_preservation','total_shared_preservation','F16','F17','F19','F20'],[
('IT09 Nonzero-index group','a group starts at index2 with retained history and executes transfer2 followed by the specified snapshot-driven return2','the total stays10 through actual steps at indices2 and3, with nextIndex4 and retained old history'),
('IT10 Shared total invariant','initialized Alice/Bob/Carol region total10 is preserved by each actually selected paired debit and peer refusal','every shared prefix retains total10, including F19 peer continuation after retained4/4/2 refusal and F20 failed-suffix skip before final3/3/4'),
('IT11 Absorbed failure','a sequential cursor has already refused or a selected shared stream is failed or exhausted','the identity transition preserves the reached total without a fabricated successful receipt')])])
capability('global-binding-preservation','Resolve stable globally qualified balance resources and preserve initialized typed equality constraints over actual execution prefixes.',[
req('Exact typed global binding query','The system SHALL resolve endpoints through their exact component and resource-export IDs, validate the actual catalog first, and then process input edges in original order. Per edge it MUST check left resolution, right resolution, domain, asset and balance in that order, returning the exact first failure with zero-based index and relevant names, cells or amounts. A Boolean success projection MUST agree with the exact query.', ['2.5','2.6','5.3'], ['checkBindings_ok_iff','binding_failure_first','F08','F10','F11','F12','F13','M06','M07','M08','M09','M10','M11','M12','M13'],[
('GB01 Exact qualified identity','two valid components both export local port0 but their USD balances are4 and5','the query compares distinct actual cells and reports unequal at the original edge index with amounts4,5'),
('GB02 Missing endpoint kind and side','an edge refers to absent component99 or absent port99 in existing component0','the query distinguishes missingComponent from missingPort and records the exact left/right endpoint and edge index'),
('GB03 Dimensional mismatch','equal numeric balances are linked across USD/EUR or home/away','assetMismatch or domainMismatch is returned; domainMismatch wins when both differ'),
('GB04 Failure precedence','edge0 has unequal resolved balances and edge1 has a missing endpoint','edge0 unequal is returned; within an edge missing left wins over missing right'),
('GB05 Catalog precedes emptiness','a duplicate-component catalog is queried with an empty edge list','configuration failure is returned; the same empty list succeeds for a valid catalog'),
('GB06 Outputs are not live resources','a qualified ID names only a historical output/input port, not a resource export','resource resolution returns missingPort even if a history value exists')]),
req('Binding meaning and actual alias distinction','The system SHALL define agreement as successful typed resolution plus equality for every global edge and prove query acceptance equivalent to catalog validity and that proposition. Existing imports MUST retain exact export-cell identity; distinct exported cells MUST NOT be treated as aliases merely because balances match.', ['2.6','4.4','5.3'], ['Agrees','query_agreement','import_export_identity','F07','F08','F13','F14'],[
('GB07 Positive distinct-cell equality','A and B resolve to distinct USD cells both containing5','agreement holds at entry, with no implied future write discipline'),
('GB08 One-sided accepted write','actual one-sided debit1 changes A5 to4 while B remains5','agreement becomes false after successful execution'),
('GB09 Existing resource alias','a valid import references canonical export A and actual transfer changes its cell6 to4','both views read the same exact cell4 without declaring a duplicate export'),
('GB10 Self binding','a self-edge references a resolving resource in a valid catalog','it succeeds in every state; an unresolved self-edge still reports its endpoint error')]),
req('Initialized actual binding preservation','The system SHALL derive edge preservation from initialized equality and equal actual receipt effects, then prove all global bindings at every sequential and binary shared prefix from initialization and locally quantified actual-step obligations. Refusal/skip identity and administrative balance identity MUST be included; group lifting MUST use accepted actual M1 simulation.', ['4.1','4.2','4.3','4.4','5.3','5.4'], ['paired_effect_preserves','binding_prefix_preservation','binding_group_preservation','binding_shared_preservation','F07','F15','F17','F18','F19','F20'],[
('GB11 Nonzero paired effects','F07 executes one paired-debit receipt from A5/B5/Carol0 and its companion executes an actual M1 seq of two op102 leaves from the same entry','the original case reaches4/4/2; the group prefixes reach4/4/2 then3/3/4 with independently expected full cursors, exact receipts and successful A=B queries at both prefixes, instantiating initialized group-binding preservation'),
('GB12 Sequential refusal retained','the paired step is followed by actual insufficient-funds refusal and stopped suffix','the binding remains4=4 with exact successful prefix and first refusal'),
('GB13 Shared peer progression','F17 runs under left,right,left and companion F19 runs under left,left,right','A=B=3 in both final states; F19 retains the exact left refusal at4/4/2 before the right peer progresses, with both actual histories and the unchanged store'),
('GB14 Administrative or skipped step','an actual administrative transition or failed/exhausted-stream identity occurs','balance bindings remain true while actual capability-store effects are retained')]),
req('Global constraint algebra and scope','The system SHALL prove agreement over list concatenation is conjunction, and prove edge-reorientation, duplicate idempotence, permutation and associativity laws at proposition/query-success level. It MUST transfer initialization and step obligations to prefix invariants while preserving the complete global edge set. It MUST NOT claim identical first-error diagnostics after reordering or participant regrouping from these algebraic laws.', ['4.5','5.3'], ['agrees_append','agrees_reverse','agrees_idempotent','agrees_assoc','agrees_permutation','binding_law_prefix','F09','F10'],[
('GB15 Union and orientation','global edge lists are concatenated, reassociated, duplicated or each edge reversed','agreement has the corresponding conjunction/equivalence law and initialized prefix obligations transport'),
('GB16 Global skip edge','A=C is wholly inside one side of the cut {A,C}|{B}, with amounts4 and5','the actual global query rejects it; the deliberately empty cut-extracted list succeeds and therefore does not represent the same constraint'),
('GB17 Diagnostic distinction','two failing edges are reordered or a failing edge is reversed','success equivalence holds but exact first index/side/amount payloads may change as specified')]),
req('Symmetric closure is sufficient only','The system SHALL prove equal symmetric closures imply equivalent global agreement predicates, and provide a typed valid-catalog counterexample to necessity using transitive equality. It MUST NOT advertise symmetric-closure equality as a complete semantic equivalence checker.', ['4.6','5.3'], ['same_symClosure_sufficient','symClosure_not_necessary','F10'],[
('GB18 Sufficient closure criterion','two global edge sets have equal symmetric closures','their agreement predicates are equivalent for every state under the same catalog'),
('GB19 Redundant transitive edge','E=[A=B,B=C] and F=E+[A=C] use three resolving same-dimension resources','agreement predicates are equivalent for every state although symmetric closures differ'),
('GB20 Independent omitted edge','an independently constraining A=B edge is omitted at balances4,5,5','the query can change from failure to success; redundancy is not inferred from omission alone')])])
capability('interface-binding-regression-evidence','Bind operational interface claims to independent expected observations, genuine compiled source mutations, complete proof inventories and explicit acceptance gates.',[
req('Independent funded observations and negative companions','The implementation SHALL exercise all F01–F20 design fixtures with independent complete expected ledgers, stores, receipts, histories, positions, query payloads and failures relevant to each case. Nonzero neutral flows and actual successful invariant violations MUST be distinguished from refused calls and compiler controls.', ['5.1','5.2','5.3','5.4','5.5'], ['F01-F20','fixture-manifest','runtime-manifest'],[
('RE01 Independent expected data','a financial or binding comparison is registered','its expected data are literal/reference construction independent of the production query/executor; full unspecified ledger cells are explicitly zero'),
('RE02 Broken premise succeeds operationally','the writable-total or one-sided-binding negative is exercised','actual execution succeeds with the specified violating post-state; an access or typing refusal cannot replace it'),
('RE03 Nonempty audit','the new runtime Audit is run','all unique registered comparisons execute, counts and names match their manifest, and absent/empty output is blocked')]),
req('Actual mutation and defensive control evidence','The implementation SHALL execute all fourteen M01–M14 design mutations against copied actual new runtime source. Each accepted detection MUST compile, flip its designated comparison and preserve its specified positive sibling. It MUST execute every inherited accepted predecessor control, including all65 currently inspected cases, with an exact name/source/expected-exit map refreshed before official freeze.', ['6.1','6.2','6.3','6.4'], ['M01-M14','inherited-controls','mutation-report','runner-controls'],[
('RE04 Compiled discriminating mutation','a planned mutation is counted as detected','the full actual runtime closure compiles, its named oracle is false, protected sibling true and real Audit output/exit are saved'),
('RE05 Compiler failure gets no credit','a mutation fails compilation or emits no designated observation','it is blocked or failed evidence, never a financial detection'),
('RE06 Production and proof-tail controls','the inherited parser and real production #eval/IO.userError cases are adapted','all expected accepted/failed/blocked exits and source-bound production outputs are checked; display warnings cannot hide results'),
('RE07 Drift or missing inputs','a source, manifest, required positive or runtime observation is missing or changes during a run','the harness refuses acceptance and preserves exact before/after identities')]),
req('Complete proof and regression evidence','The implementation SHALL capture all imported Interface theorem/supplemental declarations, full elaborated statements, private mappings, source/module identities and actual axiom dependencies. It MUST separate explicit generic results, reference instances, counterexamples and generated constants, and prohibit sorry, custom axioms and native_decide. All accepted prior regression obligations MUST remain discharged with honest run identity.', ['1.3','5.5','7.1','7.2','7.3'], ['proof-inventory','baseline','integration','legacy-regressions'],[
('RE08 Imported proof discovery','Verify elaborates the imported Interface environment','automatic inventory includes private/generated/unused declarations and full statement/axiom information without a hardcoded theorem count'),
('RE09 Exact regression identity','old regression evidence is carried or a suite rerun','actual run revision and relevant dependency equivalence are recorded; old runs are never relabeled fresh'),
('RE10 Protected source preservation','new modules and root import integrate','historical theorem/corpus bytes and required old sources remain preserved, with exact allowed integration changes recorded')]),
req('Dependency and independent acceptance gates','The change SHALL require exact accepted Sprint9 source/evidence/delivery bindings and actual M1 API/control identity, followed by nonauthor GPT-6 and native Fable5.1 medium acceptance of the same frozen S10 plan before implementation. The accepted dependency is source eec499d, source/evidence ec9ed804 and archive/verified remote9908d9b, with full revisions in dependency-baseline.json. Stock GPT-6 implementation MUST then receive native Grok/Fable5.1-medium source/evidence review, requesting `claude-fable-5-1[1m]` with `--effort medium` and recording its actual returned model. No Foreman or independent approval, implementation or completed proof SHALL be inferred from author validation or a planning freeze.', ['1.1','1.2','7.4','8.1','8.2'], ['dependency-gate','planning-audits','native-results','delivery'],[
('RE11 Accepted dependency binding','accepted Sprint9 source/delivery/API evidence is missing or differs from the planning binding','the dependency check blocks the planning gate and implementation until reconciled; author validation is not independent approval'),
('RE12 Reviewer identity','new planning or implementation reviews are executed','requested/reported models and exact reviewed bytes are recorded; unavailable/cancelled providers remain open reviews'),
('RE13 Material finding and delivery','a native finding remains or a required evidence obligation is incomplete','targeted corrections continue without an inferred revision cap; archive/delivery waits for all obligations and verified authorized branch delivery')])])

if __name__=='__main__':
    mode=sys.argv[1] if len(sys.argv)>1 else 'evidence'
    if mode=='specs':
        for name,purpose,requirements in specs:
            p=CHANGE/'specs'/name/'spec.md';p.parent.mkdir(parents=True,exist_ok=True)
            body=f'## Purpose\n\n{purpose}\n\n## ADDED Requirements\n'
            for r in requirements:
                body+=f"\n### Requirement: {r['title']}\n\n{r['text']}\n"
                for name,when,then in r['scenarios']:
                    body+=f'\n#### Scenario: {name}\n- **WHEN** {when}\n- **THEN** {then}\n'
            p.write_text(body)
        sys.exit()
    tasktext=(CHANGE/'tasks.md').read_text()
    tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) (.+)$',tasktext,re.M)
    ids={t[1] for t in tasks}; assert len(ids)==len(tasks) and all(t[0]==' ' for t in tasks)
    rows=[];actual_requirements=[]
    for name,_,requirements in specs:
        text=(CHANGE/'specs'/name/'spec.md').read_text()
        assert re.findall(r'^### Requirement: (.+)$',text,re.M)==[r['title'] for r in requirements]
        assert re.findall(r'^#### Scenario: (.+)$',text,re.M)==[s[0] for r in requirements for s in r['scenarios']]
        for r in requirements:
            actual_body=text.split('### Requirement: '+r['title']+'\n\n',1)[1].split('\n\n#### Scenario:',1)[0]
            r['text']=actual_body
            assert set(r['tasks'])<=ids
            actual_requirements.append(dict(capability=name,requirement=r['title'],normative_text=r['text'],tasks=r['tasks'],evidence=r['evidence']))
            for title,when,then in r['scenarios']:
                assert f'- **WHEN** {when}\n- **THEN** {then}' in text
                rows.append(dict(capability=name,requirement=r['title'],scenario=title,tasks=r['tasks'],planned_evidence=r['evidence'],status='planned_unimplemented'))
    used={t for r in rows for t in r['tasks']}; assert used==ids,(ids-used,used-ids)
    assert len({r['scenario'] for r in rows})==len(rows)
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    inputs=[*sorted(CHANGE.rglob('*.md')),ROOT/'wiki-llm/sprint-10-operational-interface-bindings-outline.md',Path(__file__)]
    manifest=[dict(path=str(p.relative_to(ROOT)),sha256=sha(p),bytes=p.stat().st_size) for p in inputs]
    result=dict(status='planning_author_consistency_only',utc=datetime.now(timezone.utc).isoformat(),observed_head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),inspected_financial_source='eec499d613688137a341f3556cd80ca461dd2ee9',official_freeze=False,independent_planning_gate_performed=False,bounded_constructibility_review='provisional-constructibility-gpt6.md; not official acceptance',implementation_performed=False,dependency='accepted_delivered_Sprint9_eec_source_ec9_evidence_9908_archive_remote',counts=dict(capabilities=len(specs),requirements=len(actual_requirements),scenarios=len(rows),tasks=len(tasks),checked_tasks=0,planned_mutants=14),requirements=actual_requirements,scenarios=rows,tasks=[dict(id=t[1],description=t[2],status='unchecked') for t in tasks],input_manifest=manifest)
    (OUT/'author-coverage.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Planning author coverage','',f"{len(specs)} capabilities; {len(actual_requirements)} requirements; {len(rows)} scenarios; {len(tasks)} unchecked tasks; 14 planned mutations. No implementation or independent approval.",'','| Scenario | Requirement | Tasks | Planned evidence |','|---|---|---|---|']
    for r in rows:lines.append('| '+r['scenario']+' | '+r['requirement']+' | '+', '.join(r['tasks'])+' | '+', '.join(r['planned_evidence'])+' |')
    (OUT/'author-coverage.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(result['counts'],sort_keys=True))
