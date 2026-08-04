import urllib.request, urllib.parse, json, time, sys, os
UA={"User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36"}

def get(url, tries=5, wait=6):
    for i in range(tries):
        try:
            r=urllib.request.Request(url, headers=UA)
            return urllib.request.urlopen(r, timeout=60).read()
        except Exception as e:
            sys.stderr.write("[%d] %s :: %s\n"%(i,e,url)); time.sleep(wait*(i+1))
    return None

def s2(query, limit=6):
    u="https://api.semanticscholar.org/graph/v1/paper/search?"+urllib.parse.urlencode(
        {"query":query,"limit":limit,"fields":"title,year,authors,venue,externalIds,openAccessPdf"})
    b=get(u)
    return json.loads(b) if b else None

if __name__=="__main__":
    for q in sys.argv[1:]:
        d=s2(q)
        print("=== "+q)
        if not d:
            print("  FAILED"); continue
        for p in d.get("data",[]):
            oa=(p.get("openAccessPdf") or {}).get("url")
            au=", ".join(a.get("name","") for a in (p.get("authors") or [])[:4])
            print("  %s | %s | %s | %s"%(p.get("year"),p.get("title"),au,p.get("venue")))
            print("     ids=%s"%p.get("externalIds"))
            print("     OA=%s"%oa)
        sys.stdout.flush()
        time.sleep(4)
