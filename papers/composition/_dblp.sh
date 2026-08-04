#!/bin/bash
q="$1"; n="${2:-15}"
curl -sL -A "Mozilla/5.0 research-bot" "https://dblp.org/search/publ/api?q=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")&format=json&h=$n" > /tmp/dblp.json
python3 - <<"PY"
import json
try:
    d=json.load(open("/tmp/dblp.json"))
except Exception as e:
    print("PARSE FAIL:", open("/tmp/dblp.json").read()[:300]); raise SystemExit
hits=d.get("result",{}).get("hits",{}).get("hit",[])
for h in hits:
    i=h["info"]
    a=i.get("authors",{}).get("author",[])
    if isinstance(a,dict): a=[a]
    names=", ".join(x["text"] for x in a)[:80]
    print(i.get("year"),"|",i.get("title")[:90],"|",i.get("venue"),"|",names,"|",i.get("ee",""))
PY
