from pathlib import Path
import datetime, hashlib, json, shutil, urllib.request, zipfile

o = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-compact-release-binding')
o.mkdir(exist_ok=False)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
receipts = []

def fetch(url, name):
    p = o / name
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
    return json.loads(data)

api = 'https://api.github.com/repos/midnightntwrk/compact'
release = fetch(api + '/releases/tags/compactc-v0.31.1', 'release.json')
ref = fetch(api + '/git/ref/tags/compactc-v0.31.1', 'tag-ref.json')
obj = ref['object']
if obj['type'] == 'tag':
    obj = fetch(obj['url'], 'tag-object.json')['object']
assert obj['type'] == 'commit'
tree = fetch(api + '/git/trees/' + obj['sha'] + '?recursive=1', 'source-tree.json')
assert not tree.get('truncated')
asset = next(x for x in release['assets'] if x['name'] == 'compactc_v0.31.1_x86_64-unknown-linux-musl.zip')
install = Path('/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl')
archive = install / 'artifact.zip'
archive_sha = sha(archive)
assert asset['digest'] == 'sha256:' + archive_sha
assert asset['size'] == archive.stat().st_size
files = []
with zipfile.ZipFile(archive) as z:
    for name in z.namelist():
        data = z.read(name)
        digest = hashlib.sha256(data).hexdigest()
        p = install / name
        files.append({'member': name, 'bytes': len(data), 'archive_member_sha256': digest,
                      'installed_path': str(p), 'installed_sha256': sha(p), 'exact_match': sha(p) == digest})
assert all(x['exact_match'] for x in files)
write(o / 'binding.json', {'utc': now(), 'release_url': release['html_url'], 'release_tag': release['tag_name'],
    'source_tag_commit': obj['sha'], 'asset_id': asset['id'], 'asset_url': asset['browser_download_url'],
    'asset_api_digest': asset['digest'], 'archive_path': str(archive), 'archive_sha256': archive_sha,
    'archive_bytes': archive.stat().st_size, 'matches_github_release_asset_digest': True, 'files': files,
    'archive_redownloaded': False, 'source_rebuild_performed': False, 'source_to_binary_equivalence_proved': False,
    'acceptance': False})
shutil.copy2(__file__, o / 'capture.py')
print(json.dumps({'source_commit': obj['sha'], 'archive_matches_release_digest': True,
    'installed_members_match': len(files), 'relevant_source_paths': [x['path'] for x in tree['tree']
        if x['type'] == 'blob' and any(v in x['path'].lower() for v in ['zkir', 'flake', 'release', 'build', 'lock'])]}))
