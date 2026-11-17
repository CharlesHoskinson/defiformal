#!/usr/bin/env python3
"""Build and freshly replay the actual selected close-prefix controls; close/source refinement is separate."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys
LABELS = {
    'simple_zero_equity_real_provision',
    'simple_zero_equity_admitted_funding_ten_from_collateral_ten',
    'genuine_shared_eight_capability_provisioning',
    'admitted_two_cash_legs_then_actual_ordered_payments',
    'funded_healthy_liquidation_refuses',
    'secondary_adl_does_not_bypass_healthy_liquidation_guard',
    'allowed_bankruptcy_retains_prefix_skipped_costs_and_claims',
    'ordinary_full_close_shortfall_refuses',
    'partial_liquidation_not_exceptionally_allowed',
    'insufficient_preparation_pool_refuses',
    'second_positive_cash_leg_uses_remaining_same_pool',
    'zero_source_residual_does_not_mean_economic_payment',
    'pnl_stops_before_fees_impact_and_diff',
    'secondary_fees_zero_residual_empties_charges_not_claims',
    'ordinary_route_can_pay_healthy_position',
    'ordinary_full_adl_allows_exception_after_funding',
    'partial_adl_does_not_enable_exception',
    'holding_configuration_precedes_financial_early_return',
    'initial_raw_bucket_binding_precedes_source_guard',
    'fractional_custody_is_not_a_raw_integer_bucket',
    'funding_needs_real_invoke_when_no_preparation',
    'healthy_guard_remains_selected_before_reference_payment_authority',
    'unused_realization_and_holding_rights_may_be_absent',
    'secondary_preparation_is_actual_selected_pool_transfer',
    'recipient_gains_do_not_assume_zero_prebalance',
    'actual_totals_and_pending_owner_claims_frame',
}
class Blocked(Exception): pass
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain',type=Path,required=True)
    args=parser.parse_args();repo=Path(__file__).resolve().parents[1];toolchain=args.toolchain.resolve()
    audit=repo/'lean/DefiKernel/Margin/CloseAudit.lean';model=repo/'lean/DefiKernel/Margin/Close.lean'
    try:
        data=audit.read_bytes();model_data=model.read_bytes()
        dependencies={}
        for name in ['Types','Payment','PaymentSettlement','Funding','Realization']:
            part=(repo/('lean/DefiKernel/Margin/'+name+'.lean')).read_bytes()
            if not part:raise Blocked('empty margin dependency source: '+name)
            dependencies[name]=hashlib.sha256(part).hexdigest()
        if not data or not model_data:raise Blocked('empty margin close source/model')
        for name in ['lean','lake']:
            if not os.access(toolchain/'bin'/name,os.X_OK):raise Blocked('native tool unavailable: '+name)
        for module in ['Data/Nat/Basic','Tactic/Ring','Algebra/BigOperators/Group/Finset/Piecewise']:
            cache=repo/('lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/'+module+'.olean')
            if not cache.is_file() or not cache.stat().st_size:raise Blocked('build pinned Mathlib dependency: '+module)
        version=subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):raise Blocked('requires pinned Lean4.33.0-rc2; '+version)
        env={'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        result=subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Margin.Close'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr)
        if result.returncode:
            print('FAIL: margin close library build exited '+str(result.returncode),file=sys.stderr);return 1
        result=subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(audit)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr);combined=result.stdout+result.stderr
        if b'BLOCKED: empty first close controls' in combined or b'BLOCKED: duplicate close controls' in combined:
            raise Blocked('margin close assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native margin close replay exited '+str(result.returncode),file=sys.stderr);return 1
        rows=[line.split() for line in result.stdout.decode().splitlines()
            if line.startswith('CLOSE_CONTROL ') and not line.startswith('CLOSE_CONTROL PASSED ')]
        if not rows:raise Blocked('no observed margin close assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected margin close assertion inventory or false comparison',file=sys.stderr);return 1
        if result.stdout.decode().splitlines().count('CLOSE_CONTROL PASSED 26/26')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr);return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),audit_sha256=hashlib.sha256(data).hexdigest(),
            dependency_sha256=dependencies,scope='26 actual selected close-prefix controls; generic proof/audit/kernel and full P27 lifecycle/source refinement are separate'),sort_keys=True))
        return 0
    except (Blocked,OSError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'');sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native margin close replay timeout',file=sys.stderr);return 3
if __name__=='__main__':sys.exit(main())
