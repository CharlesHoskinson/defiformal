import pathlib,json,hashlib,re
out=pathlib.Path(__file__).parent; root=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r5')
frozen=json.loads((out.parent/'grok-r5-frozen-inputs.json').read_text())
bad=[p for p,h in frozen['files'].items() if not (root/p).is_file() or hashlib.sha256((root/p).read_bytes()).hexdigest()!=h]
result={'frozen_files':len(frozen['files']),'mismatches':bad,'archive_match':hashlib.sha256((out.parent/frozen['archive']).read_bytes()).hexdigest()==frozen['archive_sha256']}
print(json.dumps(result,indent=2));(out/'input-verification.json').write_text(json.dumps(result,indent=2)+'\n');assert not bad and result['archive_match']
