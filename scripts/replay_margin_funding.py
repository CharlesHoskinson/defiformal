#!/usr/bin/env python3
"""Build and freshly replay the actual reference funding-stage controls; close/source refinement is separate."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys
LABELS = {
    'real_joint_provisioning',
    'fee_paid_pending_claims_and_snapshots_preserved',
    'positive_pnl_is_not_automatic_spendable_cash',
    'secondary_payment_records_separate_holding_claim',
    'secondary_payment_requires_holding_configuration',
    'missing_holding_invoke',
    'missing_holding_supply',
    'holding_configuration_precedes_holding_invoke',
    'payment_invoke_precedes_holding_configuration',
    'secondary_debit_precedes_holding_configuration',
    'wrong_actor_precedes_payment',
    'wrong_preledger_bucket',
    'secondary_payment_preserves_physical_totals',
    'primary_payment_needs_no_holding_rights_or_configuration',
    'partial_secondary_distinguishes_three_observations',
    'quote_keeps_latest_factors_in_receipt',
    'zero_delta_quote_is_zero',
    'monotonic_snapshot_domain_is_not_a_silent_unsigned_subtraction',
    'zero_size_quote_is_zero',
    'actual_signed_equity_fee_not_double_counted',
    'secondary_receipt_retains_claims_even_with_positive_source_residual',
}
class Blocked(Exception): pass
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain',type=Path,required=True)
    args=parser.parse_args();repo=Path(__file__).resolve().parents[1];toolchain=args.toolchain.resolve()
    audit=repo/'lean/DefiKernel/Margin/FundingAudit.lean';model=repo/'lean/DefiKernel/Margin/Funding.lean'
    try:
        data=audit.read_bytes();model_data=model.read_bytes()
        dependencies={}
        for name in ['Types','Payment','PaymentSettlement']:
            part=(repo/('lean/DefiKernel/Margin/'+name+'.lean')).read_bytes()
            if not part:raise Blocked('empty margin dependency source: '+name)
            dependencies[name]=hashlib.sha256(part).hexdigest()
        if not data or not model_data:raise Blocked('empty margin funding source/model')
        for name in ['lean','lake']:
            if not os.access(toolchain/'bin'/name,os.X_OK):raise Blocked('native tool unavailable: '+name)
        for module in ['Data/Nat/Basic','Tactic/Ring','Algebra/BigOperators/Group/Finset/Piecewise']:
            cache=repo/('lean/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/'+module+'.olean')
            if not cache.is_file() or not cache.stat().st_size:raise Blocked('build pinned Mathlib dependency: '+module)
        version=subprocess.check_output([str(toolchain/'bin/lean'),'--version'],text=True).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'):raise Blocked('requires pinned Lean4.33.0-rc2; '+version)
        env={'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        result=subprocess.run([str(toolchain/'bin/lake'),'build','DefiKernel.Margin.Funding'],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr)
        if result.returncode:
            print('FAIL: margin funding library build exited '+str(result.returncode),file=sys.stderr);return 1
        result=subprocess.run([str(toolchain/'bin/lake'),'env','lean',str(audit)],
            cwd=repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120)
        sys.stdout.buffer.write(result.stdout);sys.stderr.buffer.write(result.stderr);combined=result.stdout+result.stderr
        if b'BLOCKED: empty first funding controls' in combined or b'BLOCKED: duplicate funding controls' in combined:
            raise Blocked('margin funding assertion inventory missing or duplicated')
        if result.returncode:
            print('FAIL: native margin funding replay exited '+str(result.returncode),file=sys.stderr);return 1
        rows=[line.split() for line in result.stdout.decode().splitlines()
            if line.startswith('FUNDING_CONTROL ') and not line.startswith('FUNDING_CONTROL PASSED ')]
        if not rows:raise Blocked('no observed margin funding assertions')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            print('FAIL: unexpected margin funding assertion inventory or false comparison',file=sys.stderr);return 1
        if result.stdout.decode().splitlines().count('FUNDING_CONTROL PASSED 21/21')!=1:
            print('FAIL: missing exact nonempty completion record',file=sys.stderr);return 1
        print(json.dumps(dict(status='PASS',assertions=len(rows),lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),
            model_sha256=hashlib.sha256(model_data).hexdigest(),audit_sha256=hashlib.sha256(data).hexdigest(),
            dependency_sha256=dependencies,scope='21 actual reference funding controls; generic proof/audit/kernel and full P27 lifecycle/source refinement are separate'),sort_keys=True))
        return 0
    except (Blocked,FileNotFoundError,PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except subprocess.TimeoutExpired as error:
        sys.stdout.buffer.write(error.stdout or b'');sys.stderr.buffer.write(error.stderr or b'')
        print('BLOCKED: native margin funding replay timeout',file=sys.stderr);return 3
if __name__=='__main__':sys.exit(main())
