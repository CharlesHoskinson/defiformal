"""Replay frozen candidate using private Lean cache and fresh reviewer outputs."""
import sys,os
from pathlib import Path
review=Path(__file__).resolve().parents[1]
sys.dont_write_bytecode=True
sys.path.insert(0,str(review/'candidate/scripts/token0_p16'))
import p16_common as c
c.RECORDER=review/'candidate/scripts/token0_p16/record_cmd.py'
if os.environ.get('P16_R6_REVIEW_ERROR'):
 c.RECORDER=Path(__file__).with_name('duplicate_empty_relay.py')
import source_campaign as s
s.ROOT=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox')
raise SystemExit(s.main())
