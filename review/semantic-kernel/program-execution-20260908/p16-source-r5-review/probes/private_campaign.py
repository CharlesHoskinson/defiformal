import sys
from pathlib import Path
sys.path.insert(0,'/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16')
import source_campaign as s
s.ROOT=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox')
raise SystemExit(s.main())
