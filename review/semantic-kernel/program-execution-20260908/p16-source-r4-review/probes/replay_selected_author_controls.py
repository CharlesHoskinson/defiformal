import runpy,json,sys
from pathlib import Path
R=Path(__file__).resolve().parent.parent;W=Path('/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908')
g=runpy.run_path(str(W/'review/semantic-kernel/uniswap-token0/p16/implementation/grok-r4/controls/run_fault_campaigns.py'),run_name='review_import')
f=g['run_r1'];v=f.__globals__;v['CTRL']=R/'author-control-replay';v['EVIDENCE']=R/'author-control-replay';v['s'].ROOT=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox')
rows=[f(name) for name in ['missing-receipt','crash-partial','timeout']];rows.append(g['run_lean_false']());(R/'logs/selected-author-control-replay.json').write_text(json.dumps(rows,indent=2)+'\n');print([(r['mode'],r['actual_exit']) for r in rows])
