from pathlib import Path
import importlib.util, json, copy
root=Path('/private/tmp/defiformal-ci-author')
p=root/'docs/correspondence/token0/verify.py'
spec=importlib.util.spec_from_file_location('token0_check',p);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
original=json.loads(p.with_name('differential-observations.json').read_text())
print('intact',module.verify(root,original))
mutations={
 'missing pinned artifact':lambda m:m['bound_files'][0].update(path='docs/correspondence/token0/THIS-FILE-DOES-NOT-EXIST'),
 'changed expected bytes':lambda m:m['bound_files'][0].update(sha256='0'*64),
 'empty artifact forbidden':lambda m:next(x for x in m['bound_files'] if x['bytes']==0).pop('allow_empty'),
 'empty source denominator':lambda m:m.update(source_invocations=[]),
 'wrong source outcome':lambda m:m['source_invocations'][0].update(semantic_class='evm_revert'),
 'wrong successful model value':lambda m:m['source_invocations'][0].update(model_result='ok:1'),
}
for name,mutate in mutations.items():
 candidate=copy.deepcopy(original);mutate(candidate)
 try:module.verify(root,candidate)
 except (ValueError,FileNotFoundError,KeyError) as e:print('REJECTED',name,type(e).__name__,str(e))
 else:raise AssertionError('accepted negative control: '+name)
print('PASS: intact and all 6 negative controls')
