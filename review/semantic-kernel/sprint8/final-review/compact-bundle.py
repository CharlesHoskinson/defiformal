from pathlib import Path
import json,hashlib,shutil
out=Path(__file__).parent;r=out.parents[3]
def sha(b):return hashlib.sha256(b).hexdigest()
m=json.loads((out/'candidate.json').read_text());raw=(out/'bundle.md').read_text();header=raw.split('\n\n===== INPUT ',1)[0]
parts=[header+'\n\nPRESENTATION NOTE: This is the same complete96 input artifacts as the original native review bundle, without deleting any input, field or value. JSON inputs are rendered in compact JSON; original byte hashes and rendered hashes are separately recorded. All non-JSON inputs are literal bytes. Rendering changes whitespace only at the JSON representation level; each parsed JSON value is checked equal. The original full bundle and failed Opus context-limit attempt remain preserved.\n'];rows=[]
for x in m['inputs']:
 p=r/x['path'];data=p.read_bytes();assert sha(data)==x['sha256'];rendered=data
 if p.suffix=='.json':
  rendered=json.dumps(json.loads(data),separators=(',',':'),ensure_ascii=False).encode();assert json.loads(rendered)==json.loads(data)
 y={**x,'rendered_sha256':sha(rendered),'rendered_bytes':len(rendered),'presentation':'compact JSON; parsed value equal' if p.suffix=='.json' else 'literal original'};rows.append(y)
 parts.append(f'\n\n===== INPUT {x["path"]} ORIGINAL_SHA256 {x["sha256"]} RENDERED_SHA256 {y["rendered_sha256"]} =====\n'+rendered.decode())
b=''.join(parts).encode();(out/'bundle-compact.md').write_bytes(b)
m.update(inputs=rows,bundle_bytes=len(b),bundle_sha256=sha(b),presentation='Same original96 input bytes; compact JSON rendering preserves every parsed field and value',original_bundle_sha256=sha((out/'bundle.md').read_bytes()));(out/'candidate-compact.json').write_text(json.dumps(m,indent=2)+'\n');print(len(b),sha(b))
