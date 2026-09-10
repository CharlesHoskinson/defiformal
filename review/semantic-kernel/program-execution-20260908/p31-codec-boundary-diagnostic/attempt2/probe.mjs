import { canonicalEncode, canonicalDecode, decodeCanonicalRecord } from '../../../adapters/readiness/p31/source/experiments/moriarty-language/src/codec.ts';
const observations=[];
function accept(id, f, expected) { const value=f(); const passed=JSON.stringify(value)===JSON.stringify(expected); observations.push({id,kind:'success',value,expected,passed}); }
function refuse(id, f, expected) { let code=null; try { f(); } catch(e) { code=e.code ?? e.name; } observations.push({id,kind:'refusal',code,expected,passed:code===expected}); }
accept('numeric-looking-string-preserved',()=>canonicalEncode('1'),'"1"');
accept('boolean-preserved',()=>canonicalEncode(true),'true');
accept('generic-decoder-preserves-unvalidated-fields',()=>canonicalDecode('{"amount":"1","extra":true}'),{amount:'1',extra:true});
refuse('numeric-JSON-value',()=>canonicalDecode('{"amount":1}'),'NON_CANONICAL_VALUE');
refuse('null-JSON-value',()=>canonicalDecode('{"amount":null}'),'NON_CANONICAL_VALUE');
refuse('duplicate-key',()=>canonicalDecode('{"amount":"1","amount":"2"}'),'NON_CANONICAL_BYTES');
refuse('noncanonical-key-order',()=>canonicalDecode('{"z":true,"a":"1"}'),'NON_CANONICAL_BYTES');
refuse('closed-record-missing-validator',()=>decodeCanonicalRecord('{"amount":"1"}'),'NON_CANONICAL_VALUE');
console.log(JSON.stringify({observations,passed:observations.filter(x=>x.passed).length,total:observations.length},null,2));
if(observations.some(x=>!x.passed))process.exitCode=1;
