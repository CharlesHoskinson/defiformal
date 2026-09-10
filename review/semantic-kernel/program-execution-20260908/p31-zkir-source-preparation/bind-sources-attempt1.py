from pathlib import Path
import datetime, hashlib, json, shutil, urllib.request

o = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-zkir-source-preparation')
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
read = lambda p: json.loads(p.read_text())
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
receipts = read(o / 'fetch-receipts.json')

def fetch(url, name):
    p = o / name
    assert not p.exists(), name
    p.parent.mkdir(parents=True, exist_ok=True)
    start = now()
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'DeFiFormal-source-evidence/1.0'})
        with urllib.request.urlopen(req, timeout=45) as response:
            data = response.read()
            p.write_bytes(data)
            rec = {'url': url, 'resolved_url': response.url, 'status': response.status,
                   'started_utc': start, 'finished_utc': now(), 'path': name,
                   'bytes': len(data), 'sha256': sha(p)}
    except Exception as e:
        receipts.append({'url': url, 'started_utc': start, 'finished_utc': now(), 'error': str(e)})
        write(o / 'fetch-receipts.json', receipts)
        raise
    receipts.append(rec)
    write(o / 'fetch-receipts.json', receipts)
    return p

d = read(o / 'discovery.json')
api = 'https://api.github.com/repos/midnightntwrk/midnight-ledger'
commits = {'crate-vcs': d['crate_vcs']['git']['sha1'],
           'crate-tag': d['crate_tag_object']['object']['sha'],
           'binary-tag': d['binary_release_tag_object']['sha'],
           'ledger-tag': d['ledger_tag_object']['sha']}
trees = {'crate-vcs': read(o / 'crate-commit-tree.json')}
for name, commit in commits.items():
    if name == 'crate-vcs': continue
    trees[name] = read(fetch(api + '/git/trees/' + commit + '?recursive=1', name + '-tree.json'))
    assert not trees[name].get('truncated')
root = o / 'crate/midnight-zkir-2.1.0'
comparisons = []
for path in sorted(root.rglob('*')):
    if not path.is_file(): continue
    local = str(path.relative_to(root))
    if local in ['Cargo.toml', 'Cargo.lock', '.cargo_vcs_info.json']: continue
    remote = 'zkir/' + ('Cargo.toml' if local == 'Cargo.toml.orig' else local)
    data = path.read_bytes()
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    row = {'crate_path': local, 'git_path': remote, 'crate_sha256': sha(path), 'computed_git_blob': blob, 'commits': {}}
    for name, tree in trees.items():
        entry = next((x for x in tree['tree'] if x['path'] == remote), None)
        row['commits'][name] = {'commit': commits[name], 'blob': entry['sha'] if entry else None,
                                'matches_crate': entry is not None and entry['sha'] == blob}
    assert row['commits']['crate-vcs']['matches_crate'], remote
    comparisons.append(row)
for name in ['LICENSE', 'Cargo.toml', 'README.md']:
    fetch('https://raw.githubusercontent.com/midnightntwrk/midnight-ledger/' + commits['crate-vcs'] + '/' + name, 'upstream-root/' + name)
release = read(fetch(api + '/releases/tags/zkir-2.1.0', 'binary-release.json'))
write(o / 'source-comparison.json', {'utc': now(), 'commits': commits, 'files': comparisons,
    'installed_binary_sha256': sha(Path('/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/zkir')),
    'installed_binary_source_identity_proved': False, 'acceptance': False})
shutil.copy2(__file__, o / 'bind-sources.py')
print(json.dumps({'comparisons': comparisons, 'assets': [
    {k: x.get(k) for k in ['name', 'size', 'digest', 'browser_download_url']} for x in release['assets']]}))
