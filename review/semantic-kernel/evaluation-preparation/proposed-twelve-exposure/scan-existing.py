#!/usr/bin/env python3
"""Read existing tracked text only; write a new bounded exposure inventory here."""
import hashlib
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
PATTERNS = {
    'dYdX Chain': r'\bdydx(?:[ -]*(?:chain|v[34]))?\b',
    'Osmosis': r'\bosmosis\b',
    'DeepBookV3': r'\bdeepbook(?:[ -]*v?3)?\b',
    'THORChain': r'\bthor[ -]?chain\b',
    'Velocity': r'\bvelocity\b',
    'Kamino': r'\bkamino\b',
    'Euler V2': r'\beuler(?:[ -]*v[12])?\b|\bEVC\b',
    'Term Finance': r'\bterm[ _-]+finance\b',
    'UMA Optimistic Oracle': r'\buma\b|\boptimistic[ _-]+oracle\b',
    'Nexus Mutual': r'\bnexus(?:[ _-]+mutual)?\b',
    'Lightning Network': r'\blightning(?:[ _-]+network)?\b',
    'Balancer V3': r'\bbalancer(?:[ _-]*v[23])?\b',
}
SUFFIXES = {'.md', '.txt', '.json', '.jsonl', '.yaml', '.yml', '.toml', '.csv',
            '.lean', '.qnt', '.mjs', '.js', '.ts', '.py', '.sh', '.log', '.tex'}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    assert ROOT.name == 'defiformal'
    target = OUT / 'all-name-matches.jsonl'
    assert not target.exists(), 'Preserve this audit; do not overwrite its inventory.'
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    names = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    patterns = {name: re.compile(pattern, re.I) for name, pattern in PATTERNS.items()}
    files, skipped, counts = [], [], {name: 0 for name in PATTERNS}
    with target.open('w') as out:
        for name in names:
            if not name:
                continue
            p = ROOT / name
            if any(part in {'.git', '.lake', 'node_modules', 'vendor', 'dist', 'build'}
                   for part in p.relative_to(ROOT).parts) or OUT in p.parents:
                continue
            if p.is_symlink():
                skipped.append({'path': name, 'reason': 'symlink_not_followed'})
                continue
            if p.suffix not in SUFFIXES or not p.is_file():
                continue
            raw = p.read_bytes()
            try:
                text = raw.decode('utf-8')
            except UnicodeDecodeError:
                skipped.append({'path': name, 'reason': 'not_utf8_text'})
                continue
            files.append({'path': name, 'bytes': len(raw), 'sha256': sha(raw)})
            for number, line in enumerate(text.splitlines(), 1):
                for case, pattern in patterns.items():
                    matches = list(pattern.finditer(line))
                    if not matches:
                        continue
                    counts[case] += len(matches)
                    spans = [{'column': m.start() + 1, 'matched_text': m.group(),
                              'context': line[max(0, m.start()-100):m.end()+180]}
                             for m in matches]
                    out.write(json.dumps({'case': case, 'path': name, 'line': number,
                                          'line_sha256': sha(line.encode()),
                                          'occurrences': spans}, ensure_ascii=False)+'\n')
    manifest = {'status': 'lexical_discovery_not_untouched_certification', 'utc':
                datetime.now(timezone.utc).isoformat(), 'head': head,
                'source_selection': 'git ls-files, existing regular UTF-8 text; no untracked or external sources',
                'patterns': PATTERNS, 'excluded_components': ['.git', '.lake', 'node_modules',
                'vendor', 'dist', 'build', 'this audit output'],
                'matches_are_not_alias_certification': True, 'files': files,
                'file_count': len(files), 'skipped': skipped, 'lexical_counts': counts}
    (OUT/'scan-inputs.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps({'files': len(files), 'lexical_occurrences': counts,
                      'matches_sha256': sha(target.read_bytes())}))


if __name__ == '__main__':
    main()
