#!/usr/bin/env python3
"""Build and freshly replay the actual pool-funded realization controls; close/source refinement is separate."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys
LABELS = {
    'real_administrative_provision',
    'primary_pool_funded_floor_and_dust',
    'secondary_pool_funded_floor_and_dust',
    'insufficient_actual_pool_refuses',
    'negative_pnl_no_op_without_authority',
    'zero_pnl_no_op_without_authority',
    'positive_pnl_requires_invoke',
    'positive_payment_requires_actual_pool_debit',
    'actor_binding_before_pool_funding',
    'wrong_token_authority_cannot_debit_other_pool',
    'positive_subtoken_pnl_zero_transfer_invoke_only',
    'positive_subtoken_pnl_still_requires_invoke',
    'actual_physical_and_claim_totals_conserve',
    'owner_claims_holding_claims_and_snapshots_frame',
    'marked_pnl_is_distinct_from_close_base_observation',
    'primary_floor_exact_multiple',
    'fully_depleted_pool_remains_nonnegative',
    'negative_pnl_is_not_realized_as_positive_cash',
}
class Blocked(Exception): pass
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain',type=Path,required=True)
    args=parser.parse_args();repo=Path(__file__).resolve().parents[1];toolchain=args.toolchain.resolve()
    audit=repo/'lean/DefiKernel/Margin/RealizationAudit.lean';model=repo/'lean/DefiKernel/Margin/Realization.lean'
    try:
        data=audit.read_bytes();model_data=model.read_bytes()
        dependencies={}
        for name in ['Types','Payment','PaymentSettlement','Funding']:
            part=(repo/('lean/DefiKernel/Margin/'+name+'.lean')).read_bytes()
            if not part:raise Blocked('empty margin dependency source: '+name)
            dependencies[name]=hashlib.sha256(part).hexdigest()
        if not data or not model_data:raise Blocked('empty margin realization source/model')
        for name in ['lean','lake']:
            if not os.access(toolchain/'bin'/name,os.X_OK):raise Blocked('native tool unavailable: '+name)
        for module in ['Data/Nat/Basic','Tactic/Ring','Algebra/BigOperators/Group/Finset/Piecewise']:
            cache=repo/('lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/'+module+'.olean')
            if not cache.is_file() or not cache.stat().st_size:raise Blocked('build pinned Mathlib dependency: '+module)
        version=subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):raise Blocked('requires pinned Lean4.33.0-rc2; '+version)
        env={'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        result=subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Margin.Realization'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr)
        if result.returncode:
            print('FAIL: margin realization library build exited '+str(result.returncode),file=sys.stderr);return 1
        result=subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(audit)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr);combined=result.stdout+result.stderr
        if b'BLOCKED: empty first realization controls' in combined or b'BLOCKED: duplicate realization controls' in combined:
            raise Blocked('margin realization assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native margin realization replay exited '+str(result.returncode),file=sys.stderr);return 1
        rows=[line.split() for line in result.stdout.decode().splitlines()
            if line.startswith('REALIZATION_CONTROL ') and not line.startswith('REALIZATION_CONTROL PASSED ')]
        if not rows:raise Blocked('no observed margin realization assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected margin realization assertion inventory or false comparison',file=sys.stderr);return 1
        if result.stdout.decode().splitlines().count('REALIZATION_CONTROL PASSED 18/18')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr);return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),audit_sha256=hashlib.sha256(data).hexdigest(),
            dependency_sha256=dependencies,scope='18 actual pool-funded realization controls; generic proof/audit/kernel and full P27 lifecycle/source refinement are separate'),sort_keys=True))
        return 0
    except (Blocked,FileNotFoundError,PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'');sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native margin realization replay timeout',file=sys.stderr);return 3
if __name__=='__main__':sys.exit(main())
