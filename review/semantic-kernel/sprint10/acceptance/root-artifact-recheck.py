from pathlib import Path
import json,hashlib,re,collections
b=Path('/home/charl/defiformal/review/semantic-kernel/sprint10');out=b/'acceptance'
def sha(raw):return hashlib.sha256(raw).hexdigest()
r=json.loads((b/'mutations-r1/results.json').read_text()); specs=json.loads(Path('/home/charl/defiformal/mutations/interface.json').read_text())
print(specs.keys())
for name,result in r['results'].items():
 raw=(b/'mutations-r1'/f'{name}.log').read_bytes();pairs=re.findall(r'^([^:\n]+): (true|false)$',raw.decode(),re.M)
 assert len(pairs)==len(dict(pairs))==99
 assert dict(pairs)==result['checks']; assert sha(raw)==next(x['log_sha256'] for x in r['runs'] if x['label']==name)
assert len(r['results'])==15
control=json.loads((b/'implementation/runner-controls-r1/summary.json').read_text()); counts=collections.Counter()
for case in control['cases']:
 path=b/'implementation/runner-controls-r1'/Path(case['log']).relative_to('/tmp/sprint10-official-controls-r1/run')
 raw=path.read_bytes(); assert sha(raw)==case['log_sha256'];assert raw.decode()==case['cli_output'];assert case['actual_exit']==case['expected_exit'];assert case['expected_message'] in raw.decode();counts[case['actual_exit']]+=1
assert len({c['name'] for c in control['cases']})==65 and dict(counts)=={0:10,1:5,3:50}
(out/'root-artifact-recheck.json').write_text(json.dumps({'status':'PASS','candidate':'b165bc586080d668f689fbc18dfa09eb8739d688','reviewer':'root, nonauthor of mutation runner adaptation and saved-artifact reconciler','fresh_executions':False,'actual_saved_log_comparisons_reparsed':1485,'complete_unique_runtime_inventories':15,'actual_cli_log_path_hash_output_exit_message_checks':65,'exit_counts':dict(counts),'source_scope':'Independent saved-artifact reparse; native reviews are separate.','script_sha256':sha(Path(__file__).read_bytes())},indent=2)+'\n')
print('PASS root independent artifact reparse')
