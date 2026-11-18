#!/usr/bin/env python3
"""Build and freshly replay the actual unindexed lending accrual controls."""
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
    'actual_debt_increment',
    'fractional_rate_and_interval',
    'bob_owned_debt',
    'cash_and_all_collateral_frame',
    'healthy_becomes_unhealthy_successfully',
    'already_unhealthy_accrues_without_oracle',
    'same_interval_compounds_again',
    'single_combined_interval_is_different',
    'zero_rate_invoke_only',
    'zero_interval_invoke_only',
    'zero_debt_invoke_only',
    'negative_rate',
    'negative_interval',
    'two_negatives_still_refuse',
    'negative_parameter_zero_increment_still_refuses',
    'invoke_before_guard',
    'positive_increment_requires_supply_right',
    'owner_binding_before_guard',
    'cash_collateral_conservation_debt_supply_increase',
}

class Blocked(Exception):
    pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain', type=Path, required=True, help='installed native Lean4.33.0-rc2 root')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    source = repo/'lean/DefiKernel/Lending/AccrueAudit.lean'
    toolchain = args.toolchain.resolve()
    try:
        data = source.read_bytes()
        if not data:
            raise Blocked('empty accrue source')
        for tool in ['lean','lake']:
            if not os.access(toolchain/'bin'/tool, os.X_OK):
                raise Blocked('native tool unavailable: '+tool)
        cached = repo/'lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Algebra/BigOperators/Group/Finset/Piecewise.olean'
        if not cached.is_file() or not cached.stat().st_size:
            raise Blocked('build the pinned Mathlib finite-sum dependency first')
        version = subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):
            raise Blocked('requires pinned Lean4.33.0-rc2; observed '+version)
        model = repo/'lean/DefiKernel/Lending/Accrue.lean'
        model_data = model.read_bytes()
        if not model_data:
            raise Blocked('empty accrue model')
        roles = (repo/'lean/DefiKernel/Lending/Types.lean').read_bytes()
        if not roles:
            raise Blocked('empty lending role source')
        auxiliary = {}
        for name in ['Support']:
            part = (repo/('lean/DefiKernel/Lending/'+name+'.lean')).read_bytes()
            if not part:
                raise Blocked('empty accrue dependency source: '+name)
            auxiliary[name] = hashlib.sha256(part).hexdigest()
        env = {'PATH': str(toolchain/'bin')+':/usr/bin:/bin', 'HOME': str(Path.home())}
        built = subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Lending.Accrue'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(built.stdout)
        sys.stderr.buffer.write(built.stderr)
        if built.returncode:
            print('FAIL: accrue library build exited '+str(built.returncode),file=sys.stderr)
            return 1
        argv = [str(toolchain/'bin/lake'),'env','lean',str(source)]
        result = subprocess.run(argv,cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        combined = result.stdout+result.stderr
        if b'BLOCKED: empty accrue controls' in combined or b'BLOCKED: duplicate accrue controls' in combined:
            raise Blocked('accrue assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native Lean replay exited '+str(result.returncode),file=sys.stderr)
            return 1
        rows = [line.split() for line in result.stdout.decode().splitlines() if line.startswith('ACCRUE_CONTROL ') and not line.startswith('ACCRUE_CONTROL PASSED ')]
        if not rows:
            raise Blocked('no observed accrue assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected assertion inventory or false comparison',file=sys.stderr)
            return 1
        if result.stdout.decode().splitlines().count('ACCRUE_CONTROL PASSED 21/21')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr)
            return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            source_sha256=hashlib.sha256(data).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),
            roles_sha256=hashlib.sha256(roles).hexdigest(),auxiliary_sha256=auxiliary,scope='21 actual accrue controls; generic effects/accounting/enabled/repeated-interval proofs and axiom/kernel audits are separate'),sort_keys=True))
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
