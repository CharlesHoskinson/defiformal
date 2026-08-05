import json
from pathlib import Path
from graphify.detect import detect

ROOT = Path("/root/DefiElements/paper")
result = detect(ROOT / "kg-corpus")
(ROOT / "graphify-out" / ".graphify_detect.json").write_text(
    json.dumps(result, ensure_ascii=False), encoding="utf-8")
print("total_files:", result.get("total_files"))
print("total_words:", result.get("total_words"))
for k, v in result.get("files", {}).items():
    if v:
        print("  " + k + ":", len(v))
print("skipped_sensitive:", result.get("skipped_sensitive"))
