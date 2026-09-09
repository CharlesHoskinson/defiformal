import sys,os
from pathlib import Path
sys.dont_write_bytecode=True
os.environ['PYTHONDONTWRITEBYTECODE']='1'
sys.path.insert(0,'/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909/scripts/platform_engine')
import common
common.EVIDENCE=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p17-root-vault-campaign-r1')
import vault_campaign
raise SystemExit(vault_campaign.main())
