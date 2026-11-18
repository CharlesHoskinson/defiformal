#!/usr/bin/env python3
"""Build and freshly replay the actual Typed three-bucket payment controls; lifecycle/source refinement is separate."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys
LABELS = {
    'real_administrative_provision',
    'actual_bound_bucket_payments',
    'actual_positive_secondary_dust_shortfall',
    'actual_positive_secondary_fully_paid',
    'primary_output_priority',
    'partial_cost_retains_positive_source_residual',
    'zero_transfers_retain_economic_shortfall',
    'zero_cost_invoke_only',
    'unused_secondary_right_may_be_absent',
    'wrong_quote_primary_output',
    'wrong_quote_position_collateral',
    'wrong_quote_secondary_even_when_unused',
    'zero_quote_cannot_ignore_actual_funds',
    'fractional_bucket_not_raw_integer',
    'invoke_before_binding_guard',
    'actor_binding_before_guard',
    'actual_primary_output_debit_authority',
    'actual_position_debit_authority',
    'actual_secondary_debit_authority',
    'claim_counters_are_not_spendable_buckets',
    'physical_and_claim_totals_conserved',
    'unrelated_pool_owner_and_claims_frame',
}
class Blocked(Exception): pass
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain',type=Path,required=True)
    args=parser.parse_args();repo=Path(__file__).resolve().parents[1];toolchain=args.toolchain.resolve()
    audit=repo/'lean/DefiKernel/Margin/PaymentSettlementAudit.lean';model=repo/'lean/DefiKernel/Margin/PaymentSettlement.lean'
    try:
        data=audit.read_bytes();model_data=model.read_bytes()
        dependencies={}
        for name in ['Types','Payment']:
            part=(repo/('lean/DefiKernel/Margin/'+name+'.lean')).read_bytes()
            if not part:raise Blocked('empty margin dependency source: '+name)
            dependencies[name]=hashlib.sha256(part).hexdigest()
        if not data or not model_data:raise Blocked('empty margin settlement source/model')
        for name in ['lean','lake']:
            if not os.access(toolchain/'bin'/name,os.X_OK):raise Blocked('native tool unavailable: '+name)
        for module in ['Data/Nat/Basic','Tactic/Ring','Algebra/BigOperators/Group/Finset/Piecewise']:
            cache=repo/('lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/'+module+'.olean')
            if not cache.is_file() or not cache.stat().st_size:raise Blocked('build pinned Mathlib dependency: '+module)
        version=subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):raise Blocked('requires pinned Lean4.33.0-rc2; '+version)
        env={'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        result=subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Margin.PaymentSettlement'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr)
        if result.returncode:
            print('FAIL: margin settlement library build exited '+str(result.returncode),file=sys.stderr);return 1
        result=subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(audit)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr);combined=result.stdout+result.stderr
        if b'BLOCKED: empty margin settlement controls' in combined or b'BLOCKED: duplicate margin settlement controls' in combined:
            raise Blocked('margin settlement assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native margin settlement replay exited '+str(result.returncode),file=sys.stderr);return 1
        rows=[line.split() for line in result.stdout.decode().splitlines()
            if line.startswith('MARGIN_SETTLEMENT_CONTROL ') and not line.startswith('MARGIN_SETTLEMENT_CONTROL PASSED ')]
        if not rows:raise Blocked('no observed margin settlement assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected margin settlement assertion inventory or false comparison',file=sys.stderr);return 1
        if result.stdout.decode().splitlines().count('MARGIN_SETTLEMENT_CONTROL PASSED 22/22')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr);return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),audit_sha256=hashlib.sha256(data).hexdigest(),
            dependency_sha256=dependencies,scope='22 actual Typed payment controls; generic proof/audit/kernel and full P27 lifecycle/source refinement are separate'),sort_keys=True))
        return 0
    except (Blocked,FileNotFoundError,PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'');sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native margin settlement replay timeout',file=sys.stderr);return 3
if __name__=='__main__':sys.exit(main())
