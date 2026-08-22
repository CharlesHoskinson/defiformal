import json
from pathlib import Path
from graphify.detect import detect
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


ROOT = Path(str(_REPO / "paper"))
result = detect(ROOT / "kg-corpus")
(ROOT / "graphify-out" / ".graphify_detect.json").write_text(
    json.dumps(result, ensure_ascii=False), encoding="utf-8")
print("total_files:", result.get("total_files"))
print("total_words:", result.get("total_words"))
for k, v in result.get("files", {}).items():
    if v:
        print("  " + k + ":", len(v))
print("skipped_sensitive:", result.get("skipped_sensitive"))
