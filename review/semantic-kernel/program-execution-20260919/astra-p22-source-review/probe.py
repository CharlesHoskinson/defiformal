import hashlib, json, pathlib, tarfile, sys
B=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-p22-source')
M=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-p22-source-inputs.json')
def sha(b): return hashlib.sha256(b).hexdigest()
def validate(data, expected):
    actual=sha(data)
    if actual != expected: raise ValueError(f'sha256 mismatch: {actual} != {expected}')
    return actual
if sys.argv[1]=='bindings':
    m=json.loads(M.read_text()); r=json.loads((B/'source-entry/readiness.json').read_text())
    for name, expected in m['files'].items():
        print('INPUT',name,validate((B/name).read_bytes(),expected))
    sm=json.loads((B/'source-entry/manifest.json').read_text())
    for name, expected in sm['files'].items(): validate((B/'source-entry'/name).read_bytes(),expected)
    print('SOURCE ENTRY',len(sm['files']))
    a=B/'source-entry'/r['archive']; validate(a.read_bytes(),r['archive_sha256'])
    with tarfile.open(a) as tf:
        members={x.name:x for x in tf.getmembers() if x.isfile()}
        print('ARCHIVE MEMBERS',list(members))
        for name, meta in r['files'].items():
            b=(B/'source-entry/upstream'/name).read_bytes()
            validate(b,meta['sha256']); assert len(b)==meta['bytes']
            blob=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
            assert blob==meta['git_blob']
            matches=[n for n in members if n==name or n.endswith('/'+name)]
            assert len(matches)==1,(name,matches)
            assert tf.extractfile(members[matches[0]]).read()==b
            print('BLOB_ARCHIVE',name,blob,len(b))
    for name, expected in r['development_material'].items():
        print('HISTORICAL',name,validate((B/'historical-development'/name).read_bytes(),expected))
    name=r['source_file']; b=(B/'source-entry/upstream'/name).read_bytes(); expected=r['files'][name]['sha256']
    print('CONTROL_INTACT',validate(b,expected))
    altered=bytearray(b); altered[0]^=1
    try: validate(bytes(altered),expected)
    except ValueError as e: print('CONTROL_ALTERED_REJECTED',str(e))
    else: raise AssertionError('changed byte accepted')
elif sys.argv[1]=='read':
    for name in sys.argv[2:]:
        p=B/name
        print('\nFILE',name,'SHA256',sha(p.read_bytes()))
        for i,line in enumerate(p.read_text().splitlines(),1): print(f'{i}: {line}')
