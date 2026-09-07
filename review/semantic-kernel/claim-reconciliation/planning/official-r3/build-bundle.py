#!/usr/bin/env python3
import hashlib,json,pathlib,subprocess
R=pathlib.Path(__file__).resolve().parents[5];O=pathlib.Path(__file__).resolve().parent;B=R/'openspec/changes/historical-claim-reconciliation';P=O.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
candidate=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
old=json.loads((P/'official-r2/manifest.json').read_text())
paths={r['path'] for r in old['inputs'] if not r['path'].startswith('openspec/changes/historical-claim-reconciliation/')}
paths|={str(p.relative_to(R)) for p in B.rglob('*') if p.is_file()}
for name in ['official-r2/review-fable.md','official-r2/review-fable.invocation.json','official-r2/gpt6-review/REPORT.md','official-r2/gpt6-review/review.json','official-r2/gate-status.json','official-r3-preparation/REPORT.md','official-r3-preparation/checks.json']:
 paths.add(str((P/name).relative_to(R)))
header=f"""Independently review targeted historical-claim-reconciliation planning correction r3.
Frozen candidate {candidate}. Prior r2 nonauthor GPT-6 ACCEPT WITH LIMITATIONS and Fable NEEDS REVISION are preserved. The gate is closed until both reviewers pass these identical corrected bytes. No implementation or new numerical m5/Lean results are supplied by this revision.

Review the3required and7lesser Fable findings against exact normative source. Changes: accepted S9/S10 vs pendingM3/M4; correct document/enumerate classification and separately bound64th occurrence at paper2539–2542, with deliberate external erratum despite eligibility; separately direct-source-transcribed Lean Data frozen before comparison extractor, plus third comparison to actual unchanged m5 printed distinct edges. Explicit witness CLI, literal L26 Aw + Xf zero parsed subjects, rule/occurrence separation, earlier/current script discrepancy, actual TOML base, library root and raw IO JSON are specified. Verify those are executable rather than circular checks or merely copied data. Prior63sites and historical mathematical environments/sources remain frozen. Counts4cap18req45scenarios27tasks26controls unchanged; one new occurrence is separate from original63.

Preserve unary-instance/full-admissibility boundaries, all-input Lean theorem versus bounded execution, explicit parser/Node translation trust, complete denominator and exit policies, and final nativeGrok/Fable gate. No future M3/M4 API or factual corpus adjudication is assumed. No untouched evaluation credit. Return ACCEPT WITH LIMITATIONS, NEEDS REVISION or REJECT with concrete findings, actual checks and limits. Do not infer new independent execution from captured outputs. No edits or external communication. Both reviewers receive identical bytes.
"""
parts=[header.encode()];rows=[]
for rel in sorted(paths):
 p=R/rel;raw=p.read_bytes();assert subprocess.check_output(['git','show',candidate+':'+rel],cwd=R)==raw,rel
 rendered=(json.dumps(json.loads(raw),ensure_ascii=False,separators=(',',':'))+'\n').encode() if p.suffix=='.json' else raw
 row={'path':rel,'sha256':sha(raw),'bytes':len(raw),'rendered_sha256':sha(rendered),'rendered_bytes':len(rendered),'representation':'lossless_compact_json' if p.suffix=='.json' else 'verbatim_utf8'};rows.append(row)
 parts.extend([('\n\n## INPUT '+rel+'\nSource SHA256 '+sha(raw)+'\nRendered SHA256 '+sha(rendered)+'\n\n').encode(),rendered])
raw=b''.join(parts);(O/'bundle.md').write_bytes(raw)
m={'kind':'openspec-planning-historical-claim-reconciliation-targeted-r3','candidate':candidate,'inputs':rows,'input_count':len(rows),'bundle_sha256':sha(raw),'bundle_bytes':len(raw),'scope':{'capabilities':4,'requirements':18,'scenarios':45,'unchecked_tasks':27,'planned_controls':26}}
(O/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({k:v for k,v in m.items() if k!='inputs'}))
