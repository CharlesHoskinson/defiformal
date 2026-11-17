#!/usr/bin/env python3
"""Build and freshly replay the actual oracle-guarded collateral withdrawal and five-operation coherence controls."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess
import sys

LABELS = {
    'real_provisioning_alice',
    'real_provisioning_bob',
    'actual_locked_to_own_free',
    'fractional_withdrawal',
    'bob_owned_position',
    'cash_debt_other_owner_frame',
    'remaining_collateral_health_boundary',
    'remaining_collateral_not_prestate_health',
    'free_collateral_does_not_back_debt',
    'over_locked_refuses_guard',
    'zero_quantity_still_rejects_unhealthy',
    'zero_quantity_healthy_invoke_only',
    'zero_exposure_still_requires_positive_price',
    'negative_price',
    'negative_quantity',
    'missing_oracle',
    'missing_oracle_eager_negative_quantity',
    'wrong_oracle_unit',
    'wrong_feed_key',
    'future_timestamp',
    'stale_timestamp',
    'oldest_fresh_boundary',
    'invoke_before_oracle_evaluation',
    'custody_debit_authority',
    'guard_before_debit_authority',
    'owner_binding_before_oracle_evaluation',
    'all_asset_totals_conserved',
}
LIFECYCLE_LABELS = {
    'actually_issued_13_noncolliding_operation_scoped_capabilities',
    'deposit_stage',
    'borrow_stage',
    'accrual_stage',
    'repayment_stage',
    'withdrawal_final_exact_ledger',
    'final_asset_totals_debt_supply_reconciled',
    'borrow_ids_do_not_authorize_withdrawal',
}

class Blocked(Exception):
    pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain', type=Path, required=True, help='installed native Lean4.33.0-rc2 root')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    source = repo/'lean/DefiKernel/Lending/WithdrawCollateralAudit.lean'
    toolchain = args.toolchain.resolve()
    try:
        data = source.read_bytes()
        if not data:
            raise Blocked('empty withdraw source')
        lifecycle = repo/'lean/DefiKernel/Lending/LifecycleAudit.lean'
        lifecycle_data = lifecycle.read_bytes()
        if not lifecycle_data:
            raise Blocked('empty lifecycle source')
        for tool in ['lean','lake']:
            if not os.access(toolchain/'bin'/tool, os.X_OK):
                raise Blocked('native tool unavailable: '+tool)
        cached = repo/'lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Algebra/BigOperators/Group/Finset/Piecewise.olean'
        if not cached.is_file() or not cached.stat().st_size:
            raise Blocked('build the pinned Mathlib finite-sum dependency first')
        version = subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):
            raise Blocked('requires pinned Lean4.33.0-rc2; observed '+version)
        model = repo/'lean/DefiKernel/Lending/WithdrawCollateral.lean'
        model_data = model.read_bytes()
        if not model_data:
            raise Blocked('empty withdraw model')
        roles = (repo/'lean/DefiKernel/Lending/Types.lean').read_bytes()
        if not roles:
            raise Blocked('empty lending role source')
        auxiliary = {}
        for name in ['Oracle','Support','Borrow','Repay','Accrue','DepositCollateral']:
            part = (repo/('lean/DefiKernel/Lending/'+name+'.lean')).read_bytes()
            if not part:
                raise Blocked('empty withdraw dependency source: '+name)
            auxiliary[name] = hashlib.sha256(part).hexdigest()
        env = {'PATH': str(toolchain/'bin')+':/usr/bin:/bin', 'HOME': str(Path.home())}
        built = subprocess.run([str(toolchain/'bin/lake'),'build'] + ['DefiKernel.Lending.'+name for name in ['WithdrawCollateral','Borrow','Repay','Accrue','DepositCollateral']],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(built.stdout)
        sys.stderr.buffer.write(built.stderr)
        if built.returncode:
            print('FAIL: withdraw library build exited '+str(built.returncode),file=sys.stderr)
            return 1
        argv = [str(toolchain/'bin/lake'),'env','lean',str(source)]
        result = subprocess.run(argv,cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        combined = result.stdout+result.stderr
        if b'BLOCKED: empty withdraw controls' in combined or b'BLOCKED: duplicate withdraw controls' in combined:
            raise Blocked('withdraw assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native Lean replay exited '+str(result.returncode),file=sys.stderr)
            return 1
        rows = [line.split() for line in result.stdout.decode().splitlines() if line.startswith('WITHDRAW_CONTROL ') and not line.startswith('WITHDRAW_CONTROL PASSED ')]
        if not rows:
            raise Blocked('no observed withdraw assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected assertion inventory or false comparison',file=sys.stderr)
            return 1
        if result.stdout.decode().splitlines().count('WITHDRAW_CONTROL PASSED 27/27')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr)
            return 1
        lifecycle_result = subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(lifecycle)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(lifecycle_result.stdout)
        sys.stderr.buffer.write(lifecycle_result.stderr)
        combined = lifecycle_result.stdout+lifecycle_result.stderr
        if b'BLOCKED: empty lifecycle controls' in combined or b'BLOCKED: duplicate lifecycle controls' in combined:
            raise Blocked('lifecycle assertion inventory missing or duplicated')
        if lifecycle_result.returncode:
            print('FAIL: native lifecycle replay exited '+str(lifecycle_result.returncode),file=sys.stderr)
            return 1
        lifecycle_rows = [line.split() for line in lifecycle_result.stdout.decode().splitlines()
            if line.startswith('LIFECYCLE_CONTROL ') and not line.startswith('LIFECYCLE_CONTROL PASSED ')]
        if not lifecycle_rows:
            raise Blocked('no observed lifecycle assertions')
        if len(lifecycle_rows)!=len(LIFECYCLE_LABELS) or {row[1] for row in lifecycle_rows}!=LIFECYCLE_LABELS or any(len(row)!=3 or row[2]!='true' for row in lifecycle_rows):
            print('FAIL: unexpected lifecycle assertion inventory or false comparison',file=sys.stderr)
            return 1
        if lifecycle_result.stdout.decode().splitlines().count('LIFECYCLE_CONTROL PASSED 8/8')!=1:
            print('FAIL: missing exact nonempty lifecycle completion record',file=sys.stderr)
            return 1
        print(json.dumps(dict(status='PASS',withdraw_assertions=len(rows),lifecycle_assertions=len(lifecycle_rows),
            lean_version=version,lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            source_sha256=hashlib.sha256(data).hexdigest(),
            lifecycle_sha256=hashlib.sha256(lifecycle_data).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),
            roles_sha256=hashlib.sha256(roles).hexdigest(),auxiliary_sha256=auxiliary,
            scope='27 actual withdrawal controls plus 8 actual finite five-operation coherence controls; generic proofs and axiom/kernel audits are separate'),sort_keys=True))
        return 0
    except (Blocked,FileNotFoundError,PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr)
        return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'')
        sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native replay timeout',file=sys.stderr)
        return 3


if __name__=='__main__':
    sys.exit(main())
