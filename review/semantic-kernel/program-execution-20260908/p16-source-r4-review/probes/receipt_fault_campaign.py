import sys,os
from pathlib import Path
sys.path.insert(0,'/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16')
import p16_common as c
import source_campaign as s
s.ROOT=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox')
c.RECORDER=Path(__file__).with_name('receipt_fault_relay.py');os.environ['P16_R4_REVIEW_FAULT']=sys.argv[1]
raise SystemExit(s.mode_intact(Path(sys.argv[2])))
