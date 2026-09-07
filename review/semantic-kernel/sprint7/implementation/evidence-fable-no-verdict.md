I'll do a few read-only Git and hash checks against the frozen candidates before writing the verdict.


<invoke name="Bash">
<invoke name="command">cd /home/charl/defiformal && git rev-parse bea105ec72e633a2dd66c663b96d0b552e1814a8 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c && echo "--- diff 6de24fe..bea105e" && git diff --name-status 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c bea105ec72e633a2dd66c663b96d0b552e1814a8 && echo "--- Verify diff" && git diff 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c bea105ec72e633a2dd66c663b96d0b552e1814a8 -- lean/DefiKernel/Interleaving/Verify.lean && echo "--- Completion sha at bea105e" && git show bea105ec72e633a2dd66c663b96d0b552e1814a8:lean/DefiKernel/Interleaving/Completion.lean | sha256sum && echo "--- driver/spec/harness sha at 6de24fe" && for f in scripts/check_interleaving_mutations.py scripts/test_interleaving_mutation_runner.py review/semantic-kernel/sprint7/mutation-spec.json; do printf '%s ' "$f"; git show 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c:$f | sha256sum; done && echo "--- same blob at both revisions for 28 closure inputs" && for f in lean/DefiKernel/Interleaving/Schedule.lean lean/DefiKernel/Parallel/Compatibility.lean lean/DefiKernel/Composition/Execution.lean lean/DefiKernel/Composition/Interfaces.lean lean/DefiKernel/Typed/Transition.lean lean/DefiKernel/Typed/Expr.lean lean/DefiKernel/Typed/Types.lean lean/DefiKernel/Typed/Authority.lean lean/DefiKernel/Composition/Contracts.lean lean/DefiKernel/Interleaving/Execution.lean lean/DefiKernel/Parallel/Observation.lean lean/DefiKernel/Composition/Sequence.lean lean/DefiKernel/Parallel/Execution.lean lean/DefiKernel/Interleaving/Examples.lean lean/DefiKernel/Parallel/Examples.lean lean/DefiKernel/Typed/Examples.lean lean/DefiKernel/Interleaving/ScheduleTests.lean lean/DefiKernel/Interleaving/Tests.lean lean/DefiKernel/Parallel/ObservationTests.lean lean/DefiKernel/Composition/Examples.lean lean/DefiKernel/Composition/Preservation.lean lean/DefiKernel/Interleaving/Audit.lean lean/lean-toolchain lean/lake-manifest.json lean/lakefile.toml scripts/check_interleaving_mutations.py scripts/test_interleaving_mutation_runner.py review/semantic-kernel/sprint7/mutation-spec.json; do a=$(git rev-parse 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c:$f); b=$(git rev-parse bea105ec72e633a2dd66c663b96d0b552e1814a8:$f); h=$(git rev-parse HEAD:$f); [ "$a" = "$b" ] && [ "$b" = "$h" ] && echo "SAME $f" || echo "DIFF $f $a $b $h"; done</invoke>
</invoke>
<invoke name="Bash">
<invoke name="command">cd /home/charl/defiformal && echo "--- evidence artifact hashes" && sha256sum review/semantic-kernel/sprint7/mutations/summary.json review/semantic-kernel/sprint7/mutations/results.json review/semantic-kernel/sprint7/mutations/source-manifest.json review/semantic-kernel/sprint7/mutations/control.log review/semantic-kernel/sprint7/integration-final/01.log review/semantic-kernel/sprint7/integration-final/02.log review/semantic-kernel/sprint7/integration/01.log review/semantic-kernel/sprint7/runner-controls/summary.json review/semantic-kernel/sprint7/regressions/source-binding.json review/semantic-kernel/sprint7/proof-types.log review/semantic-kernel/sprint7/proof-inventory.json 2>&1 && echo "--- mutant fixture/log hashes vs results.json" && python3 - <<'EOF'
import json,hashlib,pathlib
d=pathlib.Path('review/semantic-kernel/sprint7/mutations')
r=json.load(open(d/'results.json'))
runs={x['label']:x for x in r['runs']}
bad=0
for label,res in r['results'].items():
    fx=hashlib.sha256((d/(label+'.lean')).read_bytes()).hexdigest()
    lg=hashlib.sha256((d/(label+'.log')).read_bytes()).hexdigest()
    ok = fx==res['fixture_sha256'] and lg==runs[label]['log_sha256']
    if not ok: bad+=1; print('MISMATCH',label)
    # recount false from log
    lines=(d/(label+'.log')).read_text().splitlines()
    obs=[l for l in lines if l.endswith(': true') or l.endswith(': false')]
    false=sorted(l[:-7] for l in obs if l.endswith(': false'))
    if len(obs)!=116 or false!=res['false_comparisons']: bad+=1; print('LOGDIFF',label,len(obs))
spec=json.load(open('review/semantic-kernel/sprint7/mutation-spec.json'))
ctrl=(d/'control.lean').read_text()
for m in spec['mutations']:
    mut=(d/(m['name']+'.lean')).read_text()
    exp=ctrl.replace(m['needle'],m['replacement'],1)
    if ctrl.count(m['needle'])!=1 or exp!=mut: bad+=1; print('EDIT MISMATCH',m['name'])
    res=r['results'][m['name']]
    if not set(m['required_false'])<=set(res['false_comparisons']): bad+=1; print('REQ MISSING',m['name'])
    if any(res['checks'][p]!='true' for p in spec['positive_checks']): bad+=1; print('POS FAIL',m['name'])
print('mutation reconciliation problems:',bad)
EOF
echo "--- runner control classification recount" && python3 - <<'EOF'
import json,collections
s=json.load(open('review/semantic-kernel/sprint7/runner-controls/summary.json'))
c=collections.Counter(x['actual_exit'] for x in s['cases'])
print(len(s['cases']),c,all(x['passed'] and x['actual_exit']==x['expected_exit'] and x['expected_message'] in x['cli_output'] for x in s['cases']))
EOF
echo "--- axiom audit totals in final 02.log" && grep -E 'AXIOM AUDIT (PASSED|DECLARATIONS PASSED)' review/semantic-kernel/sprint7/integration-final/02.log && grep -c 'AXIOM AUDIT theorem:' review/semantic-kernel/sprint7/integration-final/02.log && grep -E 'sorryAx|ofReduceBool' review/semantic-kernel/sprint7/integration-final/02.log | wc -l && grep -n 'Completion' review/semantic-kernel/sprint7/integration-final/02.log | head</invoke>
</invoke>
<invoke name="Bash">
<invoke name="command">cd /home/charl/defiformal && echo "--- Completion theorems' dependencies exist at bea105e" && git grep -n -E 'theorem (runPrefix_consumed|Reachable\.active_index|Reachable\.failure_index|runPrefix_reachable)' bea105ec72e633a2dd66c663b96d0b552e1814a8 -- lean/DefiKernel/Interleaving | sed 's/^bea105ec72e633a2dd66c663b96d0b552e1814a8://' && git show bea105ec72e633a2dd66c663b96d0b552e1814a8:lean/DefiKernel/Interleaving/Soundness.lean | grep -n -A6 'theorem runPrefix_consumed' && echo "--- worktree vs candidate for Lean sources" && git diff --stat bea105ec72e633a2dd66c663b96d0b552e1814a8 HEAD -- lean scripts | tail -3; git status --porcelain -- lean scripts | head</invoke>
</invoke>
</invoke>
