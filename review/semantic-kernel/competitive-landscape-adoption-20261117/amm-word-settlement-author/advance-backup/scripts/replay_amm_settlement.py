#!/usr/bin/env python3
"""Build and freshly replay the actual rational AMM Typed settlement controls."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess
import sys

LABELS = {'actual_revoked_pool_debit', 'all_input_funded_exactly', 'zero_x_reserve', 'fee_retained_actual_four_balances', 'zero_y_reserve', 'actual_pool_debit_authority', 'full_fee', 'quote_before_typed_authority', 'zero_fee_unrounded_four_balances', 'negative_fee', 'actual_trader_insufficient_funds', 'negative_amount', 'zero_amount', 'actual_trader_debit_authority', 'actual_invoke_authority'}

class Blocked(Exception):
    pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain', type=Path, required=True, help='installed native Lean4.33.0-rc2 root')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    source = repo/'lean/DefiKernel/AMM/SettlementAudit.lean'
    toolchain = args.toolchain.resolve()
    try:
        data = source.read_bytes()
        if not data:
            raise Blocked('empty AMM settlement source')
        for tool in ['lean','lake']:
            if not os.access(toolchain/'bin'/tool, os.X_OK):
                raise Blocked('native tool unavailable: '+tool)
        cached = repo/'lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Tactic/FieldSimp.olean'
        if not cached.is_file() or not cached.stat().st_size:
            raise Blocked('build the pinned Mathlib FieldSimp dependency first')
        version = subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):
            raise Blocked('requires pinned Lean4.33.0-rc2; observed '+version)
        model = repo/'lean/DefiKernel/AMM/Settlement.lean'
        model_data = model.read_bytes()
        if not model_data:
            raise Blocked('empty AMM settlement model')
        env = {'PATH': str(toolchain/'bin')+':/usr/bin:/bin', 'HOME': str(Path.home())}
        built = subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.AMM.Settlement'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(built.stdout)
        sys.stderr.buffer.write(built.stderr)
        if built.returncode:
            print('FAIL: AMM settlement library build exited '+str(built.returncode),file=sys.stderr)
            return 1
        argv = [str(toolchain/'bin/lake'),'env','lean',str(source)]
        result = subprocess.run(argv,cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        combined = result.stdout+result.stderr
        if b'BLOCKED: empty settlement controls' in combined or b'BLOCKED: duplicate settlement controls' in combined:
            raise Blocked('AMM settlement assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native Lean replay exited '+str(result.returncode),file=sys.stderr)
            return 1
        rows = [line.split() for line in result.stdout.decode().splitlines() if line.startswith('SETTLEMENT_CONTROL ') and not line.startswith('SETTLEMENT_CONTROL PASSED ')]
        if not rows:
            raise Blocked('no observed AMM settlement assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected assertion inventory or false comparison',file=sys.stderr)
            return 1
        if result.stdout.decode().splitlines().count('SETTLEMENT_CONTROL PASSED 15/15')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr)
            return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            source_sha256=hashlib.sha256(data).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),scope='15 finite controls; generic funded success, native reserve correspondence and per-asset Typed conservation are separate declarations'),sort_keys=True))
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
