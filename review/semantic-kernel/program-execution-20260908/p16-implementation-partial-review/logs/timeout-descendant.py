import subprocess,sys,time
from pathlib import Path
p=subprocess.Popen([sys.executable,"-c","import time;time.sleep(10)"])
Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-implementation-partial-review/logs/owned-descendant.pid').write_text(str(p.pid))
time.sleep(10)
