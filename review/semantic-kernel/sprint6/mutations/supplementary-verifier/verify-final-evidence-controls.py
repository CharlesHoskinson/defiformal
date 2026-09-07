#!/usr/bin/env python3
"""Real CLI controls for the supplementary artifact verifier; never invoke Lean."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

p = argparse.ArgumentParser()
p.add_argument('--repo', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
repo, out = a.repo.resolve(), a.out.resolve()
assert not out.exists() and not out.is_relative_to(repo)
out.mkdir(parents=True)
evidence = repo / 'review/semantic-kernel/sprint6'
runner = evidence / 'mutations/verify-final-evidence.py'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return json.loads(p.read_text())
def write(p, value): p.write_text(json.dumps(value, indent=2) + '\n')
records = []
for name, expect, message in [
    ('intact', 0, 'VERIFIED'),
    ('altered-source', 1, 'Git object'),
    ('partial-mutant-log', 1, 'complete inventory'),
    ('false-protected-comparison', 1, 'five protected positives true'),
    ('false-control-exit', 1, 'expected exit'),
    ('false-funded-history', 1, 'history funded values'),
]:
    production = evidence / 'mutations/final-fae07ca'
    controls = evidence / 'runner-controls/final-fae07ca'
    history = evidence / 'mutations/history-diagnostics'
    if name in ('altered-source', 'partial-mutant-log', 'false-protected-comparison'):
        production = out / (name + '-production')
        shutil.copytree(evidence / 'mutations/final-fae07ca', production)
        summary = read(production / 'summary.json')
        if name == 'altered-source':
            m = read(production / 'source-manifest.json')
            relative = 'lean/DefiKernel/Parallel/Compatibility.lean'
            source = production / 'inputs' / relative
            source.write_bytes(source.read_bytes() + b'\n-- controlled artifact tamper\n')
            m['sources'][relative] = m['sources_after'][relative] = sha(source)
            write(production / 'source-manifest.json', m)
            summary['source_manifest_sha256'] = sha(production / 'source-manifest.json')
        else:
            results = read(production / 'results.json')
            label = 'omit-reverse-conflict'
            log = production / (label + '.log')
            if name == 'partial-mutant-log':
                log.write_text(log.read_text().replace('parallel.observe.empty: true\n', ''))
            else:
                positive = 'parallel.compat.catalog-positive'
                log.write_text(log.read_text().replace(positive + ': true', positive + ': false').replace(
                    'Parallel runtime comparisons failed: 1', 'Parallel runtime comparisons failed: 2'))
                results['results'][label]['checks'][positive] = 'false'
                results['results'][label]['false_comparisons'] = sorted(
                    results['results'][label]['false_comparisons'] + [positive])
            for r in results['runs']:
                if r['label'] == label: r['log_sha256'] = sha(log)
            write(production / 'results.json', results)
            summary['results_sha256'] = sha(production / 'results.json')
        write(production / 'summary.json', summary)
    if name == 'false-control-exit':
        controls = out / (name + '-controls')
        shutil.copytree(evidence / 'runner-controls/final-fae07ca', controls)
        summary = read(controls / 'summary.json')
        summary['cases'][0]['actual_exit'] = 3
        write(controls / 'summary.json', summary)
        write(controls / 'cases.json', summary['cases'])
        invocation = read(controls / 'invocation.json')
        invocation['summary_sha256'] = sha(controls / 'summary.json')
        write(controls / 'invocation.json', invocation)
    if name == 'false-funded-history':
        history = out / (name + '-history')
        shutil.copytree(evidence / 'mutations/history-diagnostics', history)
        records_json = read(history / 'results.json')
        mutant = records_json[1]
        log = history / 'leak-peer-output-history.log'
        log.write_text(log.read_text().replace('alice_usd=2 bob_usd=8', 'alice_usd=3 bob_usd=7'))
        mutant['log_sha256'] = sha(log)
        mutant['diagnostic_lines'] = [x.replace('alice_usd=2 bob_usd=8', 'alice_usd=3 bob_usd=7') for x in mutant['diagnostic_lines']]
        mutant['expected_diagnostic'] = mutant['diagnostic_lines'][0]
        write(history / 'results.json', records_json)
    command = [sys.executable, str(runner), '--repo', str(repo), '--production', str(production),
               '--controls', str(controls), '--history', str(history), '--out', str(out / (name + '-result'))]
    proc = subprocess.run(command, text=True, capture_output=True, timeout=120)
    log = proc.stdout + proc.stderr
    (out / (name + '.log')).write_text(log)
    record = {'name': name, 'command': command, 'expected_exit': expect, 'actual_exit': proc.returncode,
              'expected_message': message, 'passed': proc.returncode == expect and message in log,
              'log_sha256': hashlib.sha256(log.encode()).hexdigest()}
    records.append(record)
    print(name, record['passed'], 'exit', proc.returncode, flush=True)
write(out / 'summary.json', {'kind': 'supplementary-verifier-cli-controls',
                             'verifier_sha256': sha(runner) if runner.exists() else None,
                             'harness_sha256': sha(Path(__file__)), 'total': len(records),
                             'passed': sum(r['passed'] for r in records), 'cases': records})
sys.exit(0 if all(r['passed'] for r in records) else 1)
