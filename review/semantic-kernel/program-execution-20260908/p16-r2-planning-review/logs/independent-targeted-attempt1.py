from pathlib import Path
from fractions import Fraction
import json,hashlib
w=Path('/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908'); c=w/'openspec/changes/uniswap-token0-p16'
r=Path(__file__).parent
fx={x['id']:x for x in json.loads((c/'fixtures.json').read_text())['fixtures']}
mu={x['id']:x for x in json.loads((c/'planned-mutations.json').read_text())['token0_production_mutants']}
checks=[]
def check(name,ok,detail=None):
 checks.append({'id':name,'pass':bool(ok),'detail':detail});assert ok,name
def inp(k):
 t=fx[k]['inputs'];return int(t['sqrtPX96']),int(t['liquidity']),int(t['amount']),t['add']
def ceilfrac(a,b):
 q=Fraction(a,b);return -(-q.numerator//q.denominator)
Q=2**96;U=2**256;V=2**160
p,l,a,d=inp('P16-I-ZERO-LIQ')
check('new_identity_zero_liquidity',a==0 and l==0 and int(fx['P16-I-ZERO-LIQ']['expected']['ok'])==p)
p,l,a,d=inp('P16-REQ-STRICT');n=l*Q;prod=a*p
check('new_strict_source_refusal',not d and a>0 and prod<U and n<prod)
q=ceilfrac(n*p,(n-prod)%U)
check('strict_mutant_public_one',q==1==int(mu['T0-REQ-SKIP']['mutant_public_strict']['ok']) and (n-prod)%U==int(mu['T0-REQ-SKIP']['mutant_public_strict']['wrapped_denominator']))
p,l,a,d=inp('P16-SAFECAST');n=l*Q;prod=a*p;q=ceilfrac(n*p,n-prod)
check('new_safecast_order',not d and a>0 and prod<U and n>prod and V<=q<U and q==2**222+2**159==int(fx['P16-SAFECAST']['expected']['fullmath_quotient']))
p,l,a,d=inp('P16-ADD-DEN0');n=l*Q
check('new_add_fullmath_den0',d and a>0 and a*p<U and n+a*p==0 and fx['P16-ADD-DEN0']['expected']['error']=='divisionByZero')
p,l,a,d=inp('P16-REQ');n=l*Q
check('equality_not_detection',a>0 and not d and n==a*p and (n-a*p)%U==0 and mu['T0-REQ-SKIP']['equality_baseline_control']=='P16-REQ')
p,l,a,d=inp('P16-WRAP');n=l*Q;prod=a*p;den=(n+prod)%U
check('wrap_partition',d and a>0 and prod<U and n+prod>=U and den<n)
q=ceilfrac(n*p,den);baseline=ceilfrac(n,n//p+a)
check('wrap_mutant_with_source_cast',q<U and q==int(mu['T0-WRAP-SKIP']['mutant_public']['before_bare_uint160']) and q%V==int(mu['T0-WRAP-SKIP']['mutant_public']['ok']) and q%V!=baseline==int(fx['P16-WRAP']['expected']['ok']))
check('checked_add_refuses_wrap',n+prod>=U and (n+prod)%U<n)
p,l,a,d=inp('P16-PROD');n=l*Q;prod=(a*p)%U;den=(n+prod)%U;q=ceilfrac(n*p,den);baseline=ceilfrac(n,n//p+a)
check('prod_skip_keeps_wrap_assignment',a*p==U and prod==0 and den>=n and q==Q==int(mu['T0-PROD-SKIP']['mutant_public']['ok']) and baseline==2**32==int(fx['P16-PROD']['expected']['ok']))
p,l,a,d=inp('P16-ADD-ROUND');n=l*Q;den=n+a*p;q=ceilfrac(n*p,den)
check('floor_discriminates',q==int(fx['P16-ADD-ROUND']['expected']['ok']) and n*p//den==int(mu['T0-FLOOR']['mutant_public']['ok'])==q-1)
p,l,a,d=inp('P16-ADD');n=l*Q;prod=a*p;den=n+prod;q=ceilfrac(n*p,den)
check('ordinary_positive_all_six',a>0 and d and prod<U and den<U and den>=n and n*p%den==0 and q==n*p//den==int(fx['P16-ADD']['expected']['ok']) and q<V,'ID deletion passes nonzero division; wrap/product bypasses preserve already-true guards; checked sum fits; floor is exact; remove edit is outside selected branch')
source=w/'review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol'
s=source.read_text();s=s[s.index('    function getNextSqrtPriceFromAmount0RoundingUp('):s.index('    /// @notice Gets the next sqrt price given a delta of token1')]
anchors={'T0-ID-SKIP':'if (amount == 0) return sqrtPX96;','T0-WRAP-SKIP':'if (denominator >= numerator1)','T0-PROD-SKIP':'if ((product = amount * sqrtPX96) / amount == sqrtPX96)','T0-REQ-SKIP':'require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);','T0-FLOOR':'return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));','T0-CHECKED-ADD':'uint256 denominator = numerator1 + product;'}
for k,v in anchors.items():check('source_edit_anchor_'+k,s.count(v)==1 and mu[k]['language']=='Solidity')
check('identity_source_path',s.index(anchors['T0-ID-SKIP'])<s.index(anchors['T0-PROD-SKIP']) and inp('P16-I-ADD')[2]==0,'After only deleting first return, high-level division by zero is reached; source inspection, not runtime observation')
text=''.join(p.read_text() for p in (c/'specs').glob('*/spec.md'))
tasks=(c/'tasks.md').read_text();mapping=json.loads((c/'scenario-map.json').read_text())
check('inventory_counts',text.count('### Requirement:')==24 and text.count('#### Scenario:')==30 and tasks.count('- [ ]')==20 and tasks.count('- [x]')==0)
result={'scope':'targeted independent finite arithmetic, fixture binding, source-path/anchor inspection and inventory checks; no compiled campaign or proof','checks':checks,'count':len(checks),'failed':sum(not x['pass'] for x in checks),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
(r/'independent-targeted.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'checks':len(checks),'failed':result['failed']}))
