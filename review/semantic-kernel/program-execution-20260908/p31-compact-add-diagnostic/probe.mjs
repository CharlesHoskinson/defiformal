import {pureCircuits} from './compiled/contract/index.js';
const max=(1n<<128n)-1n;
const rows=[];
for(const [id,a,b,expected] of [['zero',0n,0n,0n],['max-plus-zero',max,0n,max],['last-valid-sum',max-1n,1n,max],['one-overflow',max,1n,null],['max-plus-max',max,max,null]]) {
 let value=null,error=null;
 try {value=pureCircuits.checkedAdd(a,b);} catch(e) {error={name:e.name,message:e.message};}
 const passed=expected===null ? error!==null && error.message.includes('cast from Field or Uint value to smaller Uint value failed') : error===null && value===expected;
 rows.push({id,a:String(a),b:String(b),expected:expected===null?'overflow refusal':String(expected),value:value===null?null:String(value),error,passed});
}
console.log(JSON.stringify({rows,passed:rows.filter(x=>x.passed).length,total:rows.length},null,2));
if(rows.some(x=>!x.passed))process.exitCode=1;
