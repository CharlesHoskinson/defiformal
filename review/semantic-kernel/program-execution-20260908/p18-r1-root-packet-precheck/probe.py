"""Run the frozen candidate's real validator on an isolated packet selection.

Only PACKETS is redirected. All other consumer code and dependencies are the
frozen candidate's actual files. This is root diagnostic evidence, not Opus review.
"""
from pathlib import Path
import importlib.util
import sys

sys.dont_write_bytecode = True
target = Path(sys.argv[1]).resolve()
packets = Path(sys.argv[2]).resolve()
spec = importlib.util.spec_from_file_location('p18_frozen_validator', target)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.PACKETS = packets
raise SystemExit(module.main())
