#!/usr/bin/env python3
"""Read-only source lifts; mutations apply only to reviewer-owned function copies."""
import hashlib, json, pathlib, re, subprocess

OUT = pathlib.Path(__file__).resolve().parent
CAND = pathlib.Path('/home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate')
DEST = OUT / 'targeted'
DEST.mkdir(exist_ok=False)
src = (CAND / 'formal/v3/loop2gate.sh').read_text()
harness = (CAND / 'formal/v3/negtest-reporting.sh').read_text()

def lift(name):
    lines = src.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if re.match(r'^' + name + r'\s*\(\)\s*\{', line)]
    assert len(starts) == 1
    start = starts[0]
    end = next(i for i in range(start + 1, len(lines)) if lines[i].rstrip('\n') == '}')
    body = ''.join(lines[start:end+1])
    assert len(re.findall(r'^\w+\s*\(\)\s*\{', body, re.M)) == 1
    assert not re.search(r'^(echo|one |want "|===== )', body, re.M)
    return body

intact = lift('blocked_out') + lift('want')
needle = 'if [ "${rc:-1}" = "0" ] && '
assert intact.count(needle) == 1
mutant = intact.replace(needle, 'if ', 1)
(DEST / 'intact-fns.sh').write_text(intact)
(DEST / 'mutated-fns.sh').write_text(mutant)
# Exact candidate assertion block, bounded by the two adjacent review comments.
block = harness.split('# (i) want()\'s ok-path must require rc=0.', 1)[1].split('# F3:', 1)[0]
block = block[block.index('if [ ! -s '):]
(DEST / 'candidate-assertion-block.sh').write_text(block)
# Retain exact production aggregate exit logic after the final git/HEAD output.
exit_logic = src[src.index('if [ "$fail" -ne 0 ]; then\n'):]
(DEST / 'production-exit-logic.sh').write_text(exit_logic)
cases = [
    ('positive', 'intact', 'pairs: 1830', 0, 0, '  ok   witness'),
    ('content-negative', 'intact', 'pairs: 1830', 7, 1, '  FAIL witness'),
    ('blocked', 'intact', 'Error: EACCES', 3, 3, '  BLOCKED witness'),
    ('missing-needle', 'intact', 'pairs: 1829', 0, 1, '  FAIL witness'),
    ('mutant-positive-control', 'mutated', 'pairs: 1830', 0, 0, '  ok   witness'),
    ('mutant-dead-false-positive', 'mutated', 'pairs: 1830', 7, 0, '  ok   witness'),
]
rows = []
for name, variant, output, code, expected, text in cases:
    driver = f'''set -uo pipefail
declare -A HOUT HRC
HOUT[pairs]="{output}"; HRC[pairs]={code}
fail=0; blkd=0
. "{DEST / (variant + '-fns.sh')}"
want "witness" 'pairs: 1830' pairs
''' + exit_logic
    path = DEST / (name + '.sh')
    path.write_text(driver)
    run = subprocess.run(['/usr/bin/bash', str(path)], cwd=CAND, capture_output=True, text=True, timeout=10)
    (DEST / (name + '.stdout')).write_text(run.stdout)
    (DEST / (name + '.stderr')).write_text(run.stderr)
    passed = run.returncode == expected and text in run.stdout and not run.stderr
    rows.append(dict(name=name, argv=['/usr/bin/bash', str(path)], cwd=str(CAND), exit=run.returncode, expected_exit=expected, expected_text=text, passed=passed))

# Run the exact repaired candidate block with real assertion helpers, both on
# the real source lift and the one-hunk mutant. Helpers are lifted verbatim.
helpers = []
for name in ['caught', 'missed', 'want_not', 'want_has']:
    # The candidate uses one-line helper definitions.
    matches = [line for line in harness.splitlines() if re.match(r'^' + name + r'\s*\(\)\s*\{', line)]
    assert len(matches) == 1 and matches[0].endswith('}')
    helpers.append(matches[0])
for variant, expected, expected_caught, expected_missed in [('intact', 0, 4, 0), ('mutated', 1, 2, 2)]:
    fixture = DEST / (variant + '-assertions')
    (fixture / 'attrib').mkdir(parents=True)
    (fixture / 'attrib/fns.sh').write_text(intact if variant == 'intact' else mutant)
    driver = 'set -uo pipefail\npass=0; fail=0\n' + '\n'.join(helpers) + f'\nFX="{fixture}"\n' + block + '\n[ "$fail" -eq 0 ]\n'
    path = DEST / (variant + '-assertions.sh')
    path.write_text(driver)
    run = subprocess.run(['/usr/bin/bash', str(path)], cwd=CAND, capture_output=True, text=True, timeout=10)
    (DEST / (variant + '-assertions.stdout')).write_text(run.stdout)
    (DEST / (variant + '-assertions.stderr')).write_text(run.stderr)
    caught = len(re.findall(r'^  CAUGHT ', run.stdout, re.M))
    missed = len(re.findall(r'^  MISSED ', run.stdout, re.M))
    passed = run.returncode == expected and caught == expected_caught and missed == expected_missed and not run.stderr
    rows.append(dict(name=variant+'-candidate-assertions', argv=['/usr/bin/bash', str(path)], cwd=str(CAND), exit=run.returncode, expected_exit=expected, caught=caught, missed=missed, passed=passed))

result = dict(source_sha256=hashlib.sha256(src.encode()).hexdigest(), harness_sha256=hashlib.sha256(harness.encode()).hexdigest(), rows=rows, all_passed=all(r['passed'] for r in rows), limitation='Six targeted wrapper executions and two executions of the exact candidate assertion block; not an additional full harness campaign. Mutant expected false-positive is a control; its rejection is demonstrated by the exact candidate assertion block.')
(OUT / 'targeted-results.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
raise SystemExit(0 if result['all_passed'] else 1)
