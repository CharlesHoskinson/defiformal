#!/usr/bin/env python3
"""Read-only P27 entry byte/worksheet consistency, not EVM execution or entry approval."""
from pathlib import Path
import argparse,hashlib,json,sys
class Blocked(Exception): pass
class Contradicted(Exception): pass
def require(condition,message):
    if not condition: raise Contradicted(message)
def nonempty(path):
    try: value=path.read_bytes()
    except (FileNotFoundError,PermissionError) as error: raise Blocked(str(error)) from error
    if not value: raise Blocked('empty input: '+str(path))
    return value
def payment(k,pc,ps,o,c,s):
    if pc<=0 or ps<=0: raise Blocked('empty/invalid payment denominator')
    a=(k+pc-1)//pc;po=min(o,a);cp=min(c,a-po);r=a-po-cp;b=r*pc//ps;sp=min(s,b)
    return dict(primary_output_paid=po,position_collateral_paid=cp,secondary_paid=sp,
        output_left=o-po,collateral_left=c-cp,secondary_left=s-sp,
        source_remainingCostUsd=(b-sp)*ps,ceil_dust_usd=a*pc-k,
        floor_dust_usd=r*pc-b*ps,economic_shortfall_usd=max(0,k-(po+cp)*pc-sp*ps))
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo-root',type=Path,required=True)
    parser.add_argument('--packet',type=Path,default=Path(__file__).resolve().parent)
    args=parser.parse_args();packet=args.packet;repo=args.repo_root
    try:
        bindings=json.loads(nonempty(packet/'SOURCE-BINDINGS.json'))
        require(bindings['commit']=='a85ea3491c19c93bb4b5a002d9b358fb769b7849','wrong source commit')
        require(bindings['tree']=='0cc923c20087fdfab3659d672af6ce8a02665b19','wrong source tree')
        for name in ['sources','excerpts','prior_preparation_records']:
            if not bindings[name]:raise Blocked('empty binding inventory: '+name)
        sources={}
        for path,row in bindings['sources'].items():
            value=nonempty(repo/path);sources[path]=value
            require(len(value)==row['bytes'] and hashlib.sha256(value).hexdigest()==row['sha256'],'source hash mismatch: '+path)
            require(hashlib.sha1(b'blob '+str(len(value)).encode()+b'\0'+value).hexdigest()==row['git_blob_sha1'],'source Git blob mismatch: '+path)
        for row in bindings['excerpts']:
            value=nonempty(packet/row['excerpt'])
            require(len(value)==row['excerpt_bytes'] and hashlib.sha256(value).hexdigest()==row['excerpt_sha256'],'excerpt hash mismatch: '+row['id'])
            selected=b''.join(sources[row['source_path']].splitlines(keepends=True)[row['first_line']-1:row['last_line']])
            require(value==selected,'excerpt/source line mismatch: '+row['id'])
        for path,row in bindings['prior_preparation_records'].items():
            value=nonempty(repo/path)
            require(len(value)==row['bytes'] and hashlib.sha256(value).hexdigest()==row['sha256'],'preparation record mismatch: '+path)
        terms=bindings['retained_terms'];value=nonempty(repo/terms['path'])
        require(len(value)==terms['bytes'] and hashlib.sha256(value).hexdigest()==terms['sha256'],'retained terms mismatch')
        observations=json.loads(nonempty(packet/'OBSERVATIONS.json'));cases=observations['cases']
        if not cases:raise Blocked('empty observation inventory')
        ids={row['id'] for row in cases}
        expected_ids={'funding_direction_and_asymmetric_rounding','healthy_liquidation_selected_rejection','allowed_full_liquidation_bankruptcy_success','same_shortfall_manual_close_rejects','zero_source_residual_does_not_discharge_exact_cost','both_rounding_terms_are_distinct','sufficient_primary_liquidity_covers_cost','positive_unsettled_pnl_only_becomes_output_on_realization'}
        require(len(cases)==8 and ids==expected_ids and observations['case_count']==8,'unexpected observation inventory')
        for row in cases:
            key=row['id'];i=row['input'];actual=row['expected']
            require(row['source_excerpts'] and all(x in {r['id'] for r in bindings['excerpts']} for x in row['source_excerpts']),'missing observation source binding: '+key)
            if 'cost_usd' in i:
                result=payment(i['cost_usd'],i['primary_min_price'],i['secondary_min_price'],i['output_primary'],i['position_collateral'],i['output_secondary'])
                require(actual.get('payment',actual)==result,'payment worksheet contradiction: '+key)
                paid=(result['primary_output_paid']+result['position_collateral_paid'])*i['primary_min_price']+result['secondary_paid']*i['secondary_min_price']
                require(i['cost_usd']+result['ceil_dust_usd']==paid+result['source_remainingCostUsd']+result['floor_dust_usd'],'payment identity contradiction: '+key)
                if key=='allowed_full_liquidation_bankruptcy_success':
                    require(i['full_size_close'] and (i['liquidation_order'] or i['secondary_adl']) and result['source_remainingCostUsd']>0 and actual['stage_outcome']=='allowed_exceptional_success' and actual['event']=='InsolventClose' and actual['event_step']==i['stage'] and actual['automatic_insurance_credit']==0,'exception worksheet contradiction')
                if key=='allowed_full_liquidation_bankruptcy_success':
                    require(actual['completed_prefix']==[x[0] for x in i['completed_prefix_costs']] and actual['stopped_stage']==i['stage'] and actual['skipped_quoted_costs']==i['later_quoted_costs'] and actual['returned_fee_amounts']==0 and actual['preserved_claimable_long_raw']==i['claimable_long_raw'] and actual['preserved_claimable_short_raw']==i['claimable_short_raw'] and actual['preserved_latest_funding_snapshots']==i['latest_funding_snapshots'],'prefix/claimable worksheet contradiction')
                if key=='same_shortfall_manual_close_rejects':
                    require(not(i['full_size_close'] and (i['liquidation_order'] or i['secondary_adl'])) and actual['error']=='InsufficientFundsToPayForCosts' and actual['error_arguments']==[result['source_remainingCostUsd'],i['stage']],'ordinary rejection contradiction')
            elif key=='funding_direction_and_asymmetric_rounding':
                q=i['denominator']
                if q<=0:raise Blocked('empty/invalid funding denominator')
                require(q==10**45,'funding scale contradiction')
                fee=(i['size_usd']*i['fee_factor_delta']+q-1)//q
                require(actual==dict(fee_collateral_raw=fee,claimable_long_raw=i['size_usd']*i['long_factor_delta']//q,claimable_short_raw=i['size_usd']*i['short_factor_delta']//q,signed_fee_equity_delta_at_primary_price_2=-fee*2,spendable_token_delta=0),'funding worksheet contradiction')
            elif key=='healthy_liquidation_selected_rejection':
                equity=i['collateral_raw']*i['primary_min_price']+i['signed_position_pnl_usd']+i['signed_capped_impact_usd']-i['total_cost_raw']*i['primary_min_price']
                liquidatable=(i['should_validate_min'] and equity<i['min_collateral_usd']) or equity<=0 or equity<i['min_leverage_usd']
                require(not liquidatable and actual==dict(health_equity_usd=equity,is_liquidatable=False,selected_error='PositionShouldNotBeLiquidated',error_arguments=['',equity,i['min_collateral_usd'],i['min_leverage_usd']]),'admission worksheet contradiction')
            elif key=='positive_unsettled_pnl_only_becomes_output_on_realization':
                price=i['pnl_token_max_price']
                if price<=0:raise Blocked('empty/invalid realization denominator')
                paid=i['unsettled_positive_pnl_usd']//price
                require(actual==dict(mark_only_spendable_tokens=i['pre_spendable_tokens'],realization_pool_debit_raw=paid,realization_secondary_output_credit_raw=paid,pnl_realization_dust_usd=i['unsettled_positive_pnl_usd']-paid*price),'realization worksheet contradiction')
        print(json.dumps(dict(status='PASS',source_files=len(sources),excerpts=len(bindings['excerpts']),prior_records=len(bindings['prior_preparation_records']),worksheet_cases=len(cases),scope='Byte/Git-blob/excerpt and proposed-formula worksheet consistency only; no EVM, Lean proof, source refinement or independent entry acceptance'),sort_keys=True))
        return 0
    except (Blocked,KeyError,TypeError,ValueError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except Contradicted as error:
        print('FAIL: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':sys.exit(main())
