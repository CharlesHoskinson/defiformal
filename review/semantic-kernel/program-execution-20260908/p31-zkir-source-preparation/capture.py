from pathlib import Path
import datetime, hashlib, json, shutil, tarfile, urllib.request

r = Path('/home/charl/defiformal')
o = r / 'review/semantic-kernel/program-execution-20260908/p31-zkir-source-preparation'
o.mkdir(exist_ok=False)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
receipts = []

def fetch(url, name):
    dest = o / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    start = now()
    req = urllib.request.Request(url, headers={'User-Agent': 'DeFiFormal-source-evidence/1.0'})
    try:
        with urllib.request.urlopen(req, timeout=45) as response:
            body = response.read()
            dest.write_bytes(body)
            rec = {'url': url, 'resolved_url': response.url, 'status': response.status,
                   'started_utc': start, 'finished_utc': now(), 'path': name,
                   'bytes': len(body), 'sha256': sha(dest)}
    except Exception as e:
        receipts.append({'url': url, 'started_utc': start, 'finished_utc': now(), 'error': str(e)})
        write(o / 'fetch-receipts.json', receipts)
        raise
    receipts.append(rec)
    write(o / 'fetch-receipts.json', receipts)
    return dest

api = 'https://api.github.com/repos/midnightntwrk/midnight-ledger'
crate = fetch('https://static.crates.io/crates/midnight-zkir/midnight-zkir-2.1.0.crate', 'midnight-zkir-2.1.0.crate')
metadata = json.loads(fetch('https://crates.io/api/v1/crates/midnight-zkir/2.1.0', 'crate-metadata.json').read_text())
assert sha(crate) == metadata['version']['checksum']
with tarfile.open(crate) as t:
    t.extractall(o / 'crate', filter='data')
root = o / 'crate/midnight-zkir-2.1.0'
vcs = json.loads((root / '.cargo_vcs_info.json').read_text())
commit = vcs['git']['sha1']
tag = json.loads(fetch(api + '/git/ref/tags/crate-zkir-2.1.0', 'crate-tag-ref.json').read_text())
tagobject = json.loads(fetch(tag['object']['url'], 'crate-tag-object.json').read_text())
release = json.loads(fetch(api + '/git/ref/tags/zkir-2.1.0', 'binary-release-tag-ref.json').read_text())
ledger = json.loads(fetch(api + '/git/ref/tags/ledger-8.0.2', 'ledger-tag-ref.json').read_text())
tree = json.loads(fetch(api + '/git/trees/' + commit + '?recursive=1', 'crate-commit-tree.json').read_text())
assert not tree.get('truncated')
crate_files = {str(p.relative_to(root)): sha(p) for p in root.rglob('*') if p.is_file()}
write(o / 'discovery.json', {'utc': now(), 'crate': 'midnight-zkir', 'version': '2.1.0',
    'crate_checksum_verified': True, 'crate_sha256': sha(crate), 'crate_vcs': vcs,
    'crate_tag_object': tagobject, 'binary_release_tag_object': release['object'],
    'ledger_tag_object': ledger['object'], 'crate_files': crate_files,
    'installed_binary_source_identity_proved': False, 'semantic_contract_accepted': False,
    'note': 'Published crate version matches observed tool version; source-to-installed-binary binding and semantic contract still require verification.',
    'acceptance': False})
shutil.copy2(__file__, o / 'capture.py')
print(json.dumps({'crate_commit': commit, 'crate_files': len(crate_files),
    'crate_tag_target': tagobject.get('object'), 'binary_tag_target': release['object']['sha'],
    'ledger_tag_target': ledger['object']['sha'],
    'relevant_tree_paths': [x['path'] for x in tree['tree'] if x['type'] == 'blob' and
        (x['path'].startswith('zkir/') or x['path'].startswith('spec/') and
         any(w in x['path'].lower() for w in ['zkir', 'proof', 'circuit']))]}))
