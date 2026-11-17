#!/usr/bin/env python3
"""Build and freshly replay the native rounded-payment controls; EVM evidence is separate."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys
LABELS = {'zero_source_residual_shortfall','two_dust_terms','sufficient_primary',
    'pnl_stage_source_residual','positive_secondary_with_dust','positive_secondary_fully_paid',
    'mixed_tokens_fully_paid','zero_cost_preserves_buckets','primary_output_spent_before_collateral',
    'zero_source_residual_is_not_full_payment','ceil_floor_and_residual_are_distinct',
    'paid_secondary_can_still_leave_economic_shortfall'}
class Blocked(Exception): pass
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain',type=Path,required=True)
    args=parser.parse_args();repo=Path(__file__).resolve().parents[1];toolchain=args.toolchain.resolve()
    audit=repo/'lean/DefiKernel/Margin/PaymentAudit.lean';model=repo/'lean/DefiKernel/Margin/Payment.lean'
    try:
        data=audit.read_bytes();model_data=model.read_bytes()
        if not data or not model_data:raise Blocked('empty payment source/model')
        for name in ['lean','lake']:
            if not os.access(toolchain/'bin'/name,os.X_OK):raise Blocked('native tool unavailable: '+name)
        for module in ['Data/Nat/Basic','Tactic/Ring']:
            cache=repo/('lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/'+module+'.olean')
            if not cache.is_file() or not cache.stat().st_size:raise Blocked('build pinned Mathlib dependency: '+module)
        version=subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):raise Blocked('requires pinned Lean4.33.0-rc2; '+version)
        env={'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        result=subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Margin.Payment'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr)
        if result.returncode:
            print('FAIL: payment library build exited '+str(result.returncode),file=sys.stderr);return 1
        result=subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(audit)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr);combined=result.stdout+result.stderr
        if b'BLOCKED: empty payment inventory' in combined or b'BLOCKED: duplicate payment controls' in combined:
            raise Blocked('payment assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native payment replay exited '+str(result.returncode),file=sys.stderr);return 1
        rows=[line.split() for line in result.stdout.decode().splitlines()
            if line.startswith('PAYMENT_CONTROL ') and not line.startswith('PAYMENT_CONTROL PASSED ')]
        if not rows:raise Blocked('no observed payment assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected payment assertion inventory or false comparison',file=sys.stderr);return 1
        if result.stdout.decode().splitlines().count('PAYMENT_CONTROL PASSED 12/12')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr);return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),audit_sha256=hashlib.sha256(data).hexdigest(),
            scope='12 actual native payment controls; generic proof/audit/kernel and bounded historical source-helper campaign are separate'),sort_keys=True))
        return 0
    except (Blocked,FileNotFoundError,PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'');sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native payment replay timeout',file=sys.stderr);return 3
if __name__=='__main__':sys.exit(main())
