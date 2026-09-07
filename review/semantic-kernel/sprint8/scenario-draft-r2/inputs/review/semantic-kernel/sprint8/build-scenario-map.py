#!/usr/bin/env python3
"""Create an immutable Atomic scenario snapshot; later acceptance must use a separate overlay."""
import argparse
import datetime
import hashlib
import json
import pathlib
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=pathlib.Path, default=pathlib.Path(__file__).resolve().parents[3])
    parser.add_argument('--out', type=pathlib.Path, required=True)
    parser.add_argument('--integration', default='integration-r1')
    parser.add_argument('--controls', default='implementation/runner-controls')
    parser.add_argument('--coverage-fix', action='store_true', help='Require the six executed precedence checks')
    parser.add_argument('--candidate', help='Read Lean/script source bytes from this exact Git candidate')
    args = parser.parse_args()
    root = args.repo.resolve()
    out = args.out.resolve()
    assert not out.exists(), 'Output must be fresh; preserve prior snapshots'
    base = 'review/semantic-kernel/sprint8/'
    bindings = {}
    input_bytes = {}

    def read(path):
        if args.candidate and (path.startswith('lean/') or path.startswith('scripts/')):
            data = subprocess.check_output(['git', 'show', args.candidate + ':' + path], cwd=root)
        else:
            data = (root / path).read_bytes()
        input_bytes[path] = data
        bindings[path] = {'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
        return data.decode()

    def load(path):
        return json.loads(read(path))

    candidate = args.candidate or subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    planning = load(base + 'planning/coverage.json')['scenarios']
    assert len(planning) == 49 and len({r['id'] for r in planning}) == 49
    inventory = load(base + 'proof-inventory.json')
    assert inventory['candidate'] == candidate
    proofs = {p['name']: p for p in inventory['theorems']}
    runs = load(base + args.integration + '/lean-runs.json')
    assert runs['candidate'] == candidate
    for run in runs['runs']:
        assert run['exit_code'] == 0
        for log in run['logs'].values():
            data = read(base + args.integration + '/' + log['path'])
            assert hashlib.sha256(data.encode()).hexdigest() == log['sha256']
    audit = next(r for r in runs['runs'] if r['argv'][-1] == 'DefiKernel/Atomic/Audit.lean')
    runtime_path = base + args.integration + '/' + audit['logs']['stdout']['path']
    rows = re.findall(r'^(atomic\.[a-z0-9.-]+): (true|false)$', read(runtime_path), re.M)
    runtime = dict(rows)
    assert rows and len(rows) == len(runtime) and all(v == 'true' for v in runtime.values())
    test_path = 'lean/DefiKernel/Atomic/Tests.lean'
    tests = read(test_path).splitlines()
    evidence = {}

    def proof(short):
        name = 'DefiKernel.Atomic.' + short
        row = proofs[name]
        assert hashlib.sha256(read(row['source']).encode()).hexdigest() == row['source_sha256']
        key = 'proof:' + name
        evidence[key] = {k: row[k] for k in ['name', 'category', 'source', 'line', 'statement',
                                             'source_statement', 'section_variables', 'axioms']}
        evidence[key].update(id=key, status='elaborated-at-candidate',
            artifact=base+'proof-inventory.json', scope='Full elaborated premises remain authoritative.')
        return key

    def test(prefix):
        names = [n for n in runtime if n.startswith('atomic.' + prefix)]
        assert names, prefix
        result = []
        for name in names:
            loc = [(i, line) for i, line in enumerate(tests, 1) if '"'+name+'"' in line]
            if not loc:
                stem = next(p for p in ['atomic.observe.request.', 'atomic.observe.receipt.']
                            if name.startswith(p))
                loc = [(i, line) for i, line in enumerate(tests, 1) if '"'+stem+'"' in line]
            assert loc, name
            key = 'runtime:' + name
            evidence[key] = dict(id=key, category='boundedruntime', name=name, source=test_path,
                line=loc[0][0], source_line=loc[0][1], status='true-at-candidate', artifact=runtime_path,
                scope='Finite exact-rational development comparison, not a generic theorem or deployed fidelity.')
            result.append(key)
        return result

    def artifact(label, paths, category, status, scope):
        for path in paths:
            read(base+path)
        key = category+':'+label
        evidence[key] = dict(id=key, category=category, status=status, scope=scope,
                            artifacts=[base+p for p in paths])
        return key

    control_summary = load(base+args.controls+'/summary.json')
    assert control_summary['runner_sha256'] == hashlib.sha256(read('scripts/check_atomic_mutations.py').encode()).hexdigest()
    assert control_summary['harness_sha256'] == hashlib.sha256(read('scripts/test_atomic_mutation_runner.py').encode()).hexdigest()
    controls = artifact('actual-cli-controls', [args.controls+'/summary.json', args.controls+'/REPORT.md', args.controls+'/artifact-inventory.json'],
        'compilercontrol', '65-controls-recorded' if args.coverage_fix else '63-controls-recorded',
        '52 retained plus11 proof-tail cases; with coverage-fix, two further production-form #eval cases. Synthetic Lean fixtures. Byte-bound driver/harness; '
        'executed before production freeze at recorded Git revision. Lexical guard is not arbitrary macro expansion.')
    blocked = artifact('first-production-attempt', ['mutation-attempts/r1-audit-protocol/BLOCKED.json'],
        'mutation', 'blocked-protocol-mismatch',
        'Unchanged control129 true; first mutant compiled but numeric failure protocol was not met. '
        'Exit3; zero accepted production detections. Preserve this first attempt.')
    mutation_spec = artifact('18-edit-spec', ['mutation-spec.json',
        'implementation/mutation-development/static-applicability.json'], 'sourceinspection',
        'static-only', 'Exact-once intended source edits; no production acceptance inferred.')
    reg = load(base+'regression-runs.json')
    legacy = artifact('legacy-runs', ['regression-runs.json', 'regressions/README.md'],
        'boundedregression', 'recorded-at-' + reg['source_revision'],
        'Eleven legacy suites; exact commands, exits and per-artifact crosschecks remain authoritative.')
    gate = load(base+'planning/gate.json')
    assert gate['planning_reviews_passed'] is True
    planning_gate = artifact('planning-gate', ['planning/gate.json', 'planning/ADJUDICATION.md'],
        'advisory', 'planning-accepted', 'Planning review of its recorded candidate; not implementation acceptance.')
    proof_audit = artifact('imported-inventory', ['proof-inventory.json', 'proof-inventory-execution.json',
        'proof-inventory-verify.log'], 'importedproofaudit', 'recorded-at-candidate',
        'Imported declarations, exact types, axiom sets and supplemental categories; source regex is not inventory authority.')
    integration = artifact('full-build', [args.integration+'/lean-runs.json'], 'compilercontrol',
        'passed-at-candidate', 'Saved full lake build, Atomic Audit, Atomic Verify and root Verify commands.')
    mapping = {}

    def add(n, ps=(), ts=(), extra=(), pending=(), note=''):
        mapping[f'A{n:02}'] = dict(evidence=[proof(p) for p in ps] +
            [key for t in ts for key in test(t)] + list(extra), pending=list(pending), note=note)

    add(1, ['admit_of_checks'], ['fixture.order.commit'], note='Both branches share a funded vault; admission has no disjoint-footprint premise.')
    add(2, ['admit_ok'], ['admission.left', 'admission.right'], note='Left malformed suffix wins before right/policy/count checks despite an earlier unaffordable draw.')
    add(3, ['checkPolicy_ok_iff'], ['admission.lane.', 'admission.participant.', 'admission.schedule.'], pending=['Compound duplicate-participant/uncovered/count fixture is only a draft; ordered source logic inspected.'])
    add(4, ['admit_ok'], ['fixture.empty', 'admission.schedule.'])
    add(5, ['interleaving_advance_attempt'], ['fixture.live.complete'])
    add(6, ['runPrefix_prefix'], ['fixture.history.both.own'], note='Exact snapshots2/3 persist while current balances become5/8; generic imported execution correspondence supplies the operational link.')
    add(7, ts=['fixture.history.peer.only', 'fixture.history.own', 'fixture.history.funded.literal'])
    add(8, ['runAtomic_commit_authority'], ['fixture.boundary.local', 'fixture.capability.'], note='Boundary authenticity is trusted input; theorem checks actual branch/local index and pre-store authority.')
    add(9, ['advance_aborted', 'continueRun_aborted'], ['fixture.abort.first.'])
    add(10, ['runAtomic_noncommit_identity'], ['fixture.abort.middle.'])
    add(11, ['advance_outstanding', 'Reachable.cash_owed'], ['fixture.supply.lane.after.draw', 'fixture.supply.lane.diagnostic'])
    add(12, ts=['fixture.settlement.draw.return', 'fixture.supply.nonlane'], note='Independent complete world, receipt/output event, label, schedule and supply expectations.')
    add(13, ['runAtomic_noncommit_identity'], ['fixture.abort.outputs', 'fixture.abort.supply', 'fixture.followup.'])
    add(14, ['observationEq_iff'], ['observe.'], pending=['Two production observation mutants remain pending after blocked first run.'])
    add(15, ts=['fixture.order.commit', 'fixture.order.abort'])
    add(16, ['runPrefix_prefix', 'continueRun_prefix', 'interleaving_advance_appended'])
    add(17, ['advance_aborted', 'continueRun_aborted'])
    add(18, ['runPrefix_complete_active_exhaustion', 'runAtomic_commit_interleaving'])
    add(19, ['step_receipt_balance', 'accepted_cash_owed', 'Reachable.cash_owed', 'runPrefix_cash_owed'], ['fixture.settlement.draw.prefix', 'fixture.supply.lane.after.draw.table'], note='Valid policy, distinct participants, coverage and actual receipt execution premises are retained; policy-rejected successful steps are included.')
    add(20, ['runAtomic_commit_cash'], ['fixture.settlement.draw.return'])
    add(21, ['InvariantFixtures.scalar_netting_counterexample'], ['fixture.settlement.cross.principal'], note='Concrete table counterexample plus separate reachable runtime fixture; no global-netting conservation claim.')
    add(22, ['runAtomic_noncommit_identity'], ['fixture.abort.first.public', 'fixture.abort.middle.public', 'fixture.abort.outputs', 'fixture.abort.supply'])
    add(23, ['runAtomic_accounting', 'runAtomic_store', 'runAtomic_nonnegative', 'runAtomic_commit_authority', 'runAtomic_commit_before_store'], ['fixture.supply.nonlane', 'fixture.capability.'])
    add(24, ['runAtomic_commit_locality', 'runAtomic_commit_predicate_frame', 'runAtomic_analyzed_predicate_frame', 'InvariantFixtures.draw_return_public_invariant', 'InvariantFixtures.missing_frame_support_counterexample', 'InvariantFixtures.empty_support_is_false'], ['fixture.collateral'], note='Generic frame requires support. Reference collateral9 instance and finite counterexample remain separately classified.')
    add(25, ['runAtomic_commit_of_interleaving', 'runAtomic_commit_iff_interleaving', 'runAtomic_commit_interleaving'], ['fixture.settlement.draw.return'], note='Reverse premises are actual underlying successful attempts, lane-supply admission and independent attempt-fold clearance, not an Atomic outcome assumption.')
    add(26, ['InvariantFixtures.underlying_success_does_not_imply_commit'])
    add(27, ['runAtomic_two_invariants', 'InvariantFixtures.draw_return_local_obligation', 'InvariantFixtures.collateral_cross', 'InvariantFixtures.collateral_stable', 'InvariantFixtures.collateral_initialized', 'InvariantFixtures.draw_return_public_invariant', 'InvariantFixtures.draw_return_diagnostic_invariant', 'InvariantFixtures.nonempty_transient_invariant'], note='Initialized local/cross/stability premises remain explicit; concrete collateral instance is not the generic theorem.')
    add(28, ts=['fixture.', 'admission.', 'observe.'], extra=[integration])
    add(29, extra=[proof_audit, integration])
    add(30, extra=[mutation_spec, blocked], pending=['All18 production mutations must pass detection qualification on a new frozen candidate.'])
    add(31, extra=[controls, blocked], pending=['Production designated-false/protected-true and full-inventory evidence pending.'], note='Compile-only failure is blocked, not detection; survivor, partial inventory and required-still-true cases exercise real CLI.')
    add(32, extra=[controls])
    add(33, extra=[controls, blocked], pending=['Fresh final production Git/source/spec/driver/artifact binding after Audit fix.'], note='Actual source drift between execution phases, spec drift and output safeguards have CLI controls.')
    add(34, extra=[legacy, integration], pending=['If final candidate changes, record precise runtime-closure equivalence or rerun required regressions.'])
    add(35, extra=[planning_gate])
    add(36, extra=[planning_gate], pending=['Final native implementation/evidence review verdicts and exact candidate adjudication.'], note='Unavailable reviewer stays open; no approval is inferred from a pending or failed invocation.')
    add(37, pending=['Final native acceptance, adjudication, archive overlay, commit, push and verified remote identity.'])
    add(38, ['checkPolicy_lanes_nodup', 'firstDuplicate_none_iff'], ['admission.lane.'])
    add(39, ['checkPolicy_participants_nodup', 'checkPolicy_covers', 'uncoveredFrom_none_iff'], ['admission.participant.', 'admission.extra.participant'])
    add(40, ['InvariantFixtures.nonempty_transient_invariant'], ['fixture.settlement.draw.prefix', 'fixture.settlement.credit.prefix'], note='Actual configured-lane nonzero outstanding7 or credit−1. Empty-lane batch success is excluded as transient settlement evidence.')
    add(41, ['updateOutstanding_own', 'Reachable.outstanding_fold'], ['fixture.settlement.draw.return', 'fixture.settlement.draw.prefix', 'fixture.settlement.clear.table'])
    add(42, ['updateOutstanding_zero_effect', 'Reachable.outstanding_fold'], ['fixture.settlement.repeated.', 'fixture.settlement.noop'])
    add(43, ['Reachable.cash_owed'], ['fixture.settlement.credit.'], note='Signed outstanding permits intermediate credit−1; spendable balances remain nonnegative.')
    add(44, ['residuals_eq_nil_iff'], ['fixture.settlement.under', 'fixture.settlement.over'], note='Under+1 and over−1; over-return is funded by Alice initial1 plus draw7.')
    add(45, ['InvariantFixtures.scalar_netting_counterexample', 'mem_residuals_iff'], ['fixture.settlement.cross.principal'])
    add(46, ['mem_residuals_iff'], ['fixture.settlement.cross.asset', 'fixture.settlement.cross.domain'])
    add(47, ['residuals_eq_filterMap_product', 'residuals_keys_nodup', 'mem_residuals_iff'], ['fixture.settlement.last.lane', 'fixture.settlement.last.participant'])
    add(48, ['checkSupply_none_iff', 'advance_outstanding'], ['fixture.supply.lane.'], pending=['Two simultaneous violating supply lanes with reversed policy order remains draft-only.'], note='Current production checkSupply uses ordered find?; existing actual mint is at a nonvault cell and draw-first case retains outstanding7.')
    add(49, ['runAtomic_accounting'], ['fixture.supply.nonlane'], note='SHARE supply3 commits while configured USD settlement clears; full public supply/accounting compared.')
    if args.coverage_fix:
        mapping['A03']['evidence'] += test('admission.precedence.')
        mapping['A03']['pending'] = []
        mapping['A48']['evidence'] += test('fixture.supply.first.lane.')
        mapping['A48']['pending'] = []
        mapping['A48']['note'] += ' Both simultaneous-violation policy orders now compare exact abort and complete diagnostics after draw7.'
    assert set(mapping) == {r['id'] for r in planning}
    result = []
    for row in planning:
        read(row['path'])
        item = {**row, **mapping[row['id']]}
        item['status'] = 'pending' if item['pending'] else 'evidence-mapped-at-candidate'
        assert item['evidence'] or item['pending']
        result.append(item)
    read('review/semantic-kernel/sprint8/build-scenario-map.py')
    out.mkdir(parents=True)
    for path, data in input_bytes.items():
        target = out / 'inputs' / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    def save(name, value):
        (out/name).write_text(json.dumps(value, indent=2, ensure_ascii=False)+'\n')
    save('scenario-to-evidence.json', dict(schema_version=1, kind='immutable-draft-scenario-map',
        candidate=candidate, captured_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        acceptance=False, scenarios=result, evidence=list(evidence.values()), input_bindings=bindings,
        overlay_rule='Never rewrite this snapshot. A later final overlay must bind this file SHA256 and '
        'supply exact new candidate/artifact evidence for each changed status; preserve archive originals.'))
    pending = [dict(id=r['id'], scenario=r['scenario'], pending=r['pending']) for r in result if r['pending']]
    save('coverage.json', dict(candidate=candidate, scenario_count=len(result),
        evidence_count=len(evidence), runtime_inventory_count=len(runtime),
        mapped_count=len(result)-len(pending), pending_count=len(pending), pending=pending,
        acceptance=False, tests_coverage_gaps=[] if args.coverage_fix else ['A03 compound precedence', 'A48 first violating lane tie'],
        production_mutation_status='BLOCKED first attempt; no accepted detections'))
    save('artifact-inventory.json', {str(p.relative_to(out)): dict(sha256=hashlib.sha256(p.read_bytes()).hexdigest(),
        bytes=p.stat().st_size) for p in sorted(out.rglob('*')) if p.is_file()})
    print(json.dumps(dict(out=str(out), scenarios=len(result), evidence=len(evidence), pending=len(pending))))


if __name__ == '__main__':
    main()
