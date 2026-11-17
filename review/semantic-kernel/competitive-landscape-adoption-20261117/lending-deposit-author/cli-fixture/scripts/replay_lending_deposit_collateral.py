#!/usr/bin/env python3
"""Build and freshly replay the actual borrower-bound collateral deposit controls."""
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
    'actual_free_to_own_custody',
    'fractional_deposit',
    'deposit_entire_free_balance',
    'bob_owned_custody',
    'unhealthy_deposit_needs_no_oracle',
    'deposit_need_not_restore_health',
    'cash_debt_and_other_owner_frame',
    'zero_quantity_invoke_only',
    'negative_quantity',
    'insufficient_free_collateral',
    'locked_balance_does_not_fund_free_debit',
    'invoke_before_guard',
    'free_debit_authority',
    'other_borrower_debit_right_is_insufficient',
    'owner_binding_before_guard',
    'all_asset_totals_conserved_no_supply',
}

class Blocked(Exception):
    pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain', type=Path, required=True, help='installed native Lean4.33.0-rc2 root')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    source = repo/'lean/DefiKernel/Lending/DepositCollateralAudit.lean'
    toolchain = args.toolchain.resolve()
    try:
        data = source.read_bytes()
        if not data:
            raise Blocked('empty deposit source')
        for tool in ['lean','lake']:
            if not os.access(toolchain/'bin'/tool, os.X_OK):
                raise Blocked('native tool unavailable: '+tool)
        cached = repo/'lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Algebra/BigOperators/Group/Finset/Piecewise.olean'
        if not cached.is_file() or not cached.stat().st_size:
            raise Blocked('build the pinned Mathlib finite-sum dependency first')
        version = subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):
            raise Blocked('requires pinned Lean4.33.0-rc2; observed '+version)
        model = repo/'lean/DefiKernel/Lending/DepositCollateral.lean'
        model_data = model.read_bytes()
        if not model_data:
            raise Blocked('empty deposit model')
        roles = (repo/'lean/DefiKernel/Lending/Types.lean').read_bytes()
        if not roles:
            raise Blocked('empty lending role source')
        auxiliary = {}
        for name in ['Support']:
            part = (repo/('lean/DefiKernel/Lending/'+name+'.lean')).read_bytes()
            if not part:
                raise Blocked('empty deposit dependency source: '+name)
            auxiliary[name] = hashlib.sha256(part).hexdigest()
        env = {'PATH': str(toolchain/'bin')+':/usr/bin:/bin', 'HOME': str(Path.home())}
        built = subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Lending.DepositCollateral'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(built.stdout)
        sys.stderr.buffer.write(built.stderr)
        if built.returncode:
            print('FAIL: deposit library build exited '+str(built.returncode),file=sys.stderr)
            return 1
        argv = [str(toolchain/'bin/lake'),'env','lean',str(source)]
        result = subprocess.run(argv,cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        combined = result.stdout+result.stderr
        if b'BLOCKED: empty deposit controls' in combined or b'BLOCKED: duplicate deposit controls' in combined:
            raise Blocked('deposit assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native Lean replay exited '+str(result.returncode),file=sys.stderr)
            return 1
        rows = [line.split() for line in result.stdout.decode().splitlines() if line.startswith('DEPOSIT_CONTROL ') and not line.startswith('DEPOSIT_CONTROL PASSED ')]
        if not rows:
            raise Blocked('no observed deposit assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected assertion inventory or false comparison',file=sys.stderr)
            return 1
        if result.stdout.decode().splitlines().count('DEPOSIT_CONTROL PASSED 18/18')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr)
            return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            source_sha256=hashlib.sha256(data).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),
            roles_sha256=hashlib.sha256(roles).hexdigest(),auxiliary_sha256=auxiliary,scope='18 actual deposit controls; generic effects/accounting/funded/health proofs and axiom/kernel audits are separate'),sort_keys=True))
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
