#!/usr/bin/env python3
"""Deterministic scoped source graph; run with the installed graphify interpreter."""
from collections import Counter
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from graphify.extract import extract, _DISPATCH
from graphify.build import build
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.export import to_json, to_html
from graphify.report import generate

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
EXCLUDED = {'review', 'graphify-out', '.git', '.lake', 'node_modules', 'vendor',
            'dist', 'build', 'generated', '__pycache__', '.venv', 'venv', 'packages'}
CODE = set(_DISPATCH) - {'.md', '.mdx', '.qmd', '.json', '.skill', '.toc'}
CODE |= {'.lean', '.qnt', '.tla', '.sol'}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def save(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def mask_lean(source):
    """Mask nested comments and quoted strings, retaining newlines and columns."""
    chars = list(source)
    i = 0
    while i < len(source):
        start = i
        if source.startswith('/-', i):
            depth = 1
            i += 2
            while i < len(source) and depth:
                if source.startswith('/-', i): depth += 1; i += 2
                elif source.startswith('-/', i): depth -= 1; i += 2
                else: i += 1
            if depth: raise ValueError('unterminated Lean comment')
        elif source.startswith('--', i):
            i = source.find('\n', i)
            if i < 0: i = len(source)
        elif source[i] == '"':
            i += 1
            while i < len(source) and source[i] != '"':
                i += 2 if source[i] == '\\' else 1
            i += 1
        else:
            i += 1
            continue
        chars[start:i] = ['\n' if c == '\n' else ' ' for c in source[start:i]]
    return ''.join(chars)


def family(path):
    parts = Path(path).parts
    directories = parts[:-1]
    return '/'.join(directories[:3] if parts[:2] == ('lean', 'DefiKernel') else directories[:2])


def selected_paths():
    tracked = set(git('ls-files', '-z').decode().split('\0')) - {''}
    untracked = set(git('ls-files', '--others', '--exclude-standard', '-z', '--',
                        'lean/DefiKernel', 'scripts/check_metatheory_mutations.py',
                        'scripts/test_metatheory_mutation_runner.py').decode().split('\0')) - {''}
    return sorted(path for path in tracked | untracked
                  if not any(part in EXCLUDED for part in Path(path).parts)
                  and Path(path).suffix in CODE and (ROOT / path).is_file()
                  and not (ROOT / path).is_symlink()
                  and not any(parent.is_symlink() for parent in (ROOT / path).parents if parent != ROOT))


def check_freshness():
    manifest = json.loads((OUT / 'source-manifest.json').read_text())
    expected = {row['path']: row['sha256'] for row in manifest['source_files']}
    current = selected_paths()
    missing = sorted(set(expected) - set(current))
    added = sorted(set(current) - set(expected))
    changed = [path for path in current if path in expected and sha((ROOT / path).read_bytes()) != expected[path]]
    result = {'fresh': not (missing or added or changed), 'compared_source_count': len(expected),
              'missing': missing, 'added': added, 'changed': changed,
              'method': 'Selected source set and every captured SHA256; HEAD equality alone is insufficient.'}
    print(json.dumps(result, indent=2))
    return 0 if result['fresh'] else 1


def main():
    started = datetime.now(timezone.utc).isoformat()
    head = git('rev-parse', 'HEAD').decode().strip()
    tracked = set(git('ls-files', '-z').decode().split('\0')) - {''}
    untracked = set(git('ls-files', '--others', '--exclude-standard', '-z', '--',
                        'lean/DefiKernel', 'scripts/check_metatheory_mutations.py',
                        'scripts/test_metatheory_mutation_runner.py').decode().split('\0')) - {''}
    selected, excluded = [], []
    for path in sorted(tracked | untracked):
        p = ROOT / path
        if any(part in EXCLUDED for part in p.relative_to(ROOT).parts): continue
        if p.suffix not in CODE: continue
        if p.is_symlink() or any(parent.is_symlink() for parent in p.parents if parent != ROOT):
            excluded.append({'path': path, 'reason': 'symlink not followed'}); continue
        if not p.is_file():
            excluded.append({'path': path, 'reason': 'missing source'}); continue
        selected.append(path)
    assert selected
    blobs = {p: (ROOT / p).read_bytes() for p in selected}
    manifest = []
    for path, raw in blobs.items():
        git_raw = git('show', f'{head}:{path}') if path in tracked else None
        manifest.append({'path': path, 'sha256': sha(raw), 'bytes': len(raw),
                         'tracked': path in tracked,
                         'equals_head': raw == git_raw if git_raw is not None else False,
                         'status': 'tracked HEAD bytes' if raw == git_raw else 'working-tree source; not accepted release',
                         'method': 'Lean import extraction' if path.endswith('.lean') else
                         'graphify AST' if Path(path).suffix in _DISPATCH else 'file inventory only'})
    with tempfile.TemporaryDirectory(prefix='.source-snapshot-', dir=OUT) as temporary:
        snapshot = Path(temporary)
        for path, raw in blobs.items():
            target = snapshot / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        supported = [snapshot / p for p in selected if Path(p).suffix in _DISPATCH]
        ast = extract(supported, root=snapshot, parallel=False)
        # Normalize possible temporary absolute paths before persisting the AST.
        ast = json.loads(json.dumps(ast).replace(str(snapshot) + '/', ''))
    save('ast-extraction.json', ast)
    nodes = [{'id': p, 'label': p, 'source_file': p, 'source_location': 'L1',
              'file_type': 'code', 'family': family(p), 'source_sha256': sha(blobs[p]),
              'source_status': next(m['status'] for m in manifest if m['path'] == p)} for p in selected]
    edges, external, unresolved = [], [], []
    by_id = {n['id']: n for n in ast['nodes']}
    dropped = Counter()
    for edge in ast['edges']:
        left = by_id.get(edge.get('source'), {}).get('source_file')
        right = by_id.get(edge.get('target'), {}).get('source_file')
        if left not in blobs or right not in blobs or left == right:
            dropped['outside-scope-or-within-file'] += 1; continue
        if edge.get('confidence') != 'EXTRACTED':
            dropped['non-extracted-confidence'] += 1; continue
        edges.append({'source': left, 'target': right, 'relation': 'ast_' + edge['relation'],
                      'confidence': 'EXTRACTED', 'source_file': left,
                      'source_location': edge.get('source_location'),
                      'context': 'Graphify AST relationship between source files; not an execution/proof claim.',
                      'weight': 1.0})
    for path in selected:
        if not path.endswith('.lean'): continue
        source = mask_lean(blobs[path].decode())
        for match in re.finditer(r'^[ \t]*(?:public[ \t]+)?import[ \t]+([^\n]+)', source, re.M):
            line = source.count('\n', 0, match.start()) + 1
            for module in match.group(1).split():
                if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*', module):
                    unresolved.append({'file': path, 'line': line, 'token': module}); continue
                target = 'lean/' + module.replace('.', '/') + '.lean'
                if target in blobs:
                    edges.append({'source': path, 'target': target, 'relation': 'imports',
                                  'confidence': 'EXTRACTED', 'source_file': path,
                                  'source_location': f'L{line}', 'context': f'Lean import {module}',
                                  'weight': 1.0})
                else: external.append({'file': path, 'line': line, 'module': module,
                                       'status': 'external or excluded; target content not read'})
    extraction = {'nodes': nodes, 'edges': edges, 'input_tokens': 0, 'output_tokens': 0}
    save('file-extraction.json', extraction)
    graph = build([extraction], directed=True, dedup=False, root=ROOT)
    groups = cluster(graph)
    labels = {key: Counter(graph.nodes[n].get('family', 'source') for n in values).most_common(1)[0][0]
              for key, values in groups.items()}
    scores = score_all(graph, groups)
    hubs = god_nodes(graph)
    import_hubs = sorted([{'file': graph.nodes[n]['source_file'], 'incoming_edges': graph.in_degree(n),
                           'outgoing_edges': graph.out_degree(n)} for n in graph],
                         key=lambda row: (-row['incoming_edges'], row['file']))[:12]
    surprises = surprising_connections(graph, groups)
    questions = suggest_questions(graph, groups, labels)
    to_json(graph, groups, str(OUT / 'graph.json'), force=True, built_at_commit=head,
            community_labels=labels)
    assert graph.number_of_nodes() <= 5000
    to_html(graph, groups, str(OUT / 'graph.html'), community_labels=labels)
    detection = {'total_files': len(selected), 'total_words': sum(len(b.split()) for b in blobs.values()),
                 'files': {'code': selected}}
    report = generate(graph, groups, scores, labels, hubs, surprises, detection,
                      {'input_tokens': 0, 'output_tokens': 0}, str(ROOT), questions,
                      built_at_commit=head)
    freshness = ('## Graph Freshness\n\nThis graph includes uncommitted worktree source. Git HEAD alone does not establish freshness. '
                 'From the repository root, compare the current scoped source-file set and each byte hash with `source-manifest.json`:\n\n'
                 '```bash\n' + sys.executable + ' graphify-out/codebase/build-source-graph.py --check-freshness\n```\n\n'
                 'Rebuild the scoped AST plus Lean-import graph with:\n\n```bash\n' + sys.executable +
                 ' graphify-out/codebase/build-source-graph.py\n```\n\n'
                 'The generic `graphify update .` command does not reproduce this scope or the Lean import extractor.\n\n')
    report = re.sub(r'## Graph Freshness\n.*?(?=## )', lambda _: freshness, report, flags=re.S)
    report = report.replace('- None detected - all connections are within the same source files.',
                            f'- The algorithm selected no surprising connections. All {graph.number_of_edges()} retained edges are cross-file dependencies; absence of a selected surprise does not imply absence of such connections.')
    report = report.replace('## God Nodes (most connected - your core abstractions)\n\n',
                            '## God Nodes (graphify heuristic)\n\nNo qualifying symbol hubs were selected in this file-only graph. Measured file dependency hubs are listed below.\n\n')
    community_rows = sorted(groups.items(), key=lambda pair: (-len(pair[1]), pair[0]))
    multi = [(key, members) for key, members in community_rows if len(members) > 1]
    communities_report = ('## Communities\n\n' + str(len(groups)) + ' structural communities: ' +
                          str(len(multi)) + ' with multiple files and ' + str(len(groups) - len(multi)) +
                          ' singleton communities. Unsupported-source inventory nodes and standalone scripts can be isolated; this is not evidence of semantic independence.\n\n'
                          '| Community | Dominant source family | Files | Raw cohesion | Family composition |\n|---|---|---:|---:|---|\n')
    for key, members in multi:
        composition = Counter(graph.nodes[n].get('family', 'source') for n in members)
        communities_report += f'| {key} | {labels[key]} | {len(members)} | {scores[key]} | ' + ', '.join(f'{name}: {count}' for name, count in composition.most_common()) + ' |\n'
    communities_report += '\nAll community assignments and scores are retained in `graph.json` and `analysis.json`.\n\n'
    report = re.sub(r'## Communities[^\n]*\n.*?(?=## )', lambda _: communities_report, report, flags=re.S)
    full_detect_path = Path('/tmp/defiformal-readme-detection.json')
    full_detect = json.loads(full_detect_path.read_text()) if full_detect_path.exists() else {}
    skipped = full_detect.get('skipped_sensitive', [])
    scope = ('# Source graph scope and limits\n\nThis is a worktree source snapshot, not an accepted release or proof-status graph. '
             'Tracked source plus current untracked DefiKernel Lean modules and the two Metatheory runners are included. '
             'Review artifacts, documents, generated/vendor/build/dependency trees and symlinks are excluded. '
             'The original root graph is unchanged.\n\nGraphify AST extraction is deterministic and uses no model/API. '
             'Only EXTRACTED cross-file AST relationships with both endpoints in the selected source set are aggregated. '
             'These are extractor-reported static relationships, not validated runtime calls. '
             'Lean uses nested-comment/string-masked literal import extraction; it has no Lean AST, call or theorem edges. '
             'Quint and other unsupported source files remain inventory-only nodes. All selected files have nodes even without imports. '
             'Community labels use dominant source families; cohesion values are structural, not semantic quality scores. '
             'Generated questions/connections are navigation suggestions, not independently established semantic claims.\n\n'
             'Extraction model tokens: **0 input / 0 output**. No token-reduction benchmark or external-model comparison was run. '
             'The interactive HTML loads pinned vis-network 9.1.6 from unpkg.com and needs browser network access.\n\n'
             'Full detection flagged these 10 fixture symlinks; none was followed:\n\n' +
             ''.join(f'- `{p}`\n' for p in skipped) + '\n---\n\n')
    hub_report = '\n## File dependency hubs\n\nGraphify god-node scoring returns no qualifying symbol nodes for this file-only graph. The following are measured file in-degrees, not semantic importance scores.\n\n' + ''.join(
        f'- `{row["file"]}`: {row["incoming_edges"]} incoming, {row["outgoing_edges"]} outgoing edges.\n'
        for row in import_hubs)
    (OUT / 'GRAPH_REPORT.md').write_text(scope + report + hub_report)
    changed = [p for p, raw in blobs.items() if not (ROOT / p).is_file() or (ROOT / p).read_bytes() != raw]
    save('source-manifest.json', {'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
         'git_head_at_capture': head, 'graphify_version': importlib.metadata.version('graphifyy'),
         'python': sys.version, 'interpreter': sys.executable, 'source_files': manifest,
         'changed_since_snapshot': changed, 'excluded': excluded, 'skipped_sensitive_full_detection': skipped,
         'lean_external_imports': external, 'lean_unparsed_imports': unresolved,
         'ast_failed_sources': ast.get('failed_sources', []), 'ast_dropped_from_file_graph': dict(dropped),
         'input_tokens': 0, 'output_tokens': 0,
         'reproduce': [sys.executable, str(Path(__file__).relative_to(ROOT))],
         'script_sha256': sha(Path(__file__).read_bytes())})
    save('analysis.json', {'nodes': graph.number_of_nodes(), 'edges': graph.number_of_edges(),
         'communities': len(groups), 'community_labels': labels, 'cohesion': scores,
         'hubs': hubs, 'file_dependency_hubs': import_hubs, 'surprising_connections': surprises, 'suggested_questions': questions,
         'source_families': dict(Counter(family(p) for p in selected)),
         'extensions': dict(Counter(Path(p).suffix for p in selected)),
         'ast_nodes': len(ast['nodes']), 'ast_edges': len(ast['edges']),
         'edge_relations': dict(Counter(d['relation'] for *_, d in graph.edges(data=True)))})
    save('artifact-manifest.json', [{'path': p.name, 'bytes': p.stat().st_size, 'sha256': sha(p.read_bytes())}
                                   for p in sorted(OUT.iterdir()) if p.is_file() and p.name != 'artifact-manifest.json'])
    print(json.dumps({'files': len(selected), 'nodes': graph.number_of_nodes(),
                      'edges': graph.number_of_edges(), 'communities': len(groups),
                      'source_drift': changed, 'ast_failed_sources': ast.get('failed_sources', [])}))


if __name__ == '__main__':
    if sys.argv[1:] == ['--check-freshness']:
        raise SystemExit(check_freshness())
    if sys.argv[1:]:
        raise SystemExit('Only --check-freshness is supported; omit it to rebuild.')
    main()
