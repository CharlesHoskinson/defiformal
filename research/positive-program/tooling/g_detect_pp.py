import json
from pathlib import Path
from graphify.detect import detect

ROOT = Path("/root/DefiElements/research/positive-program")
GO = ROOT / "graphify-out"
GO.mkdir(exist_ok=True)
result = detect(ROOT)
(GO / ".graphify_detect.json").write_text(
    json.dumps(result, ensure_ascii=False), encoding="utf-8")
print("total_files:", result.get("total_files"))
print("total_words:", result.get("total_words"))
for k, v in result.get("files", {}).items():
    if v:
        print("  " + k + ":", len(v))
        for f in v:
            print("     ", f)
