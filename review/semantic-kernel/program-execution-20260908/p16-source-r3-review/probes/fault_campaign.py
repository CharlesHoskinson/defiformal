import sys,os,json
from pathlib import Path
sys.path.insert(0,'/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16')
import p16_common as c
import source_campaign as s
mode=sys.argv[1];ev=Path(sys.argv[2]);os.environ['P16_REVIEW_FAULT']=mode
if mode in ['missing-receipt','malformed-receipt','stale-receipt','unknown-stdout','crash-partial','timeout']:c.RECORDER=Path(__file__).with_name('fault_recorder.py')
if mode=='missing-fixture':
 import shutil
 local=ev/'plan-input';shutil.copytree(c.PLAN_DIR,local)
 data=json.loads((local/'fixtures.json').read_text());data['fixtures']=[r for r in data['fixtures'] if r['id']!='P16-I-REM'];(local/'fixtures.json').write_text(json.dumps(data))
 c.PLAN_DIR=local
if mode=='lean-false':
 original=s.write_source_bindings_lean
 def bad(path):
  original(path);text=path.read_text();old='expectedOk := some 39614081257132168796771975168';assert text.count(old)==1;path.write_text(text.replace(old,'expectedOk := some 0'))
 s.write_source_bindings_lean=bad
raise SystemExit(s.mode_intact(ev))
