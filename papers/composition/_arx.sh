#!/bin/bash
q="$1"; n="${2:-15}"
python3 - "$q" "$n" <<"PY"
import sys,urllib.parse,urllib.request,re,html
q,n=sys.argv[1],sys.argv[2]
url="http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)+"&max_results="+n
d=urllib.request.urlopen(url,timeout=60).read().decode()
for e in d.split("<entry>")[1:]:
    def g(t):
        m=re.search(r"<%s>(.*?)</%s>"%(t,t),e,re.S)
        return html.unescape(m.group(1)).strip().replace("\n"," ") if m else ""
    print(g("published")[:10],"|",g("title")[:100],"|",g("id"))
PY
