#!/usr/bin/env python3
"""Run a native reviewer on a frozen source/evidence bundle without tool access."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--provider', choices=['grok', 'fable'], required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--bundle', type=Path, required=True)
    parser.add_argument('--prefix', type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    data = args.bundle.read_bytes()
    assert digest(data) == manifest['bundle_sha256']
    def unchanged():
        return all(digest((ROOT / row['path']).read_bytes()) == row['sha256']
                   for row in manifest['inputs'])
    assert manifest['inputs'] and unchanged()
    assert not list(args.prefix.parent.glob(args.prefix.name + '.*')), 'Review prefix already exists'
    args.prefix.parent.mkdir(parents=True, exist_ok=True)
    if args.provider == 'fable':
        requested = 'claude-fable-5-1[1m]'
        argv = ['claude', '--print', '--model', requested, '--effort', 'medium',
                '--output-format', 'json', '--tools', '', '--strict-mcp-config',
                '--mcp-config', '{"mcpServers":{}}', '--setting-sources', '',
                '--disable-slash-commands', '--no-session-persistence']
    else:
        requested = 'grok-4.6'
        argv = ['grok', '--model', requested, '--reasoning-effort', 'medium',
                '--no-subagents', '--disable-web-search', '--tools', '',
                '--output-format', 'json', '--prompt-file', str(args.bundle.resolve())]
    cli = Path(shutil.which(argv[0])).resolve()
    version = subprocess.run([argv[0], '--version'], capture_output=True, text=True, timeout=30)
    meta = {'provider': args.provider, 'requested_model': requested, 'effort': 'medium',
            'candidate': manifest['candidate'], 'bundle_sha256': digest(data), 'argv': argv,
            'started_utc': datetime.now(timezone.utc).isoformat(),
            'review_kind': manifest['kind'], 'no_independent_execution_claimed': True,
            'cli': {'path': str(cli), 'sha256': digest(cli.read_bytes()),
                    'version_exit': version.returncode, 'version': version.stdout+version.stderr}}
    def write(suffix, raw):
        Path(str(args.prefix) + suffix).write_bytes(raw)
    def save():
        write('.invocation.json', (json.dumps(meta, indent=2)+'\n').encode())
    save()
    started = time.monotonic()
    try:
        proc = subprocess.run(argv, cwd=ROOT, input=data if args.provider == 'fable' else None,
                              capture_output=True, timeout=1500)
        response, errors = proc.stdout, proc.stderr
        meta['exit_code'] = proc.returncode
    except subprocess.TimeoutExpired as error:
        response, errors = error.stdout or b'', error.stderr or b''
        meta.update(exit_code=None, status='timeout; no accepted verdict')
    write('.json', response)
    write('.stderr', errors)
    meta.update(finished_utc=datetime.now(timezone.utc).isoformat(),
                elapsed_seconds=round(time.monotonic()-started, 3),
                response_sha256=digest(response), response_bytes=len(response),
                inputs_unchanged=unchanged(), bundle_unchanged=digest(args.bundle.read_bytes())==digest(data))
    final = ''
    try:
        parsed = json.loads(response)
        meta['reported_models'] = list(parsed.get('modelUsage', {}))
        meta['is_error'] = parsed.get('is_error')
        final = parsed.get('result' if args.provider == 'fable' else 'text', '')
        assert isinstance(final, str) and final.strip(), 'No substantive final response'
        write('.md', (final+'\n').encode())
    except Exception as error:
        meta['parse_error'] = str(error)
    save()
    print(json.dumps({k:meta.get(k) for k in ['provider','exit_code','reported_models',
         'is_error','inputs_unchanged','bundle_unchanged','parse_error']}, indent=2), flush=True)
    print(final[:1800], flush=True)
    return 0 if (meta.get('exit_code') == 0 and not meta.get('is_error') and final
                 and meta['inputs_unchanged'] and meta['bundle_unchanged']) else 3

if __name__ == '__main__':
    raise SystemExit(main())
