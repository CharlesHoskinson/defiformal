#!/usr/bin/env python3
"""Fresh-source R2 library replay, original-contract relation, audit and kernel replay."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import time

LABELS = {'original_fractional','independent_fractional','unbounded_above_word256',
    'unbounded_independent_denominators','zero_fee_unrounded','reject_word_floor',
    'formal_malformed_first','formal_malformed_second','formal_malformed_third',
    'formal_multiple_malformed','zero_x_before_amount','negative_y_before_amount',
    'negative_x_before_amount','zero_y_before_zero_amount','zero_amount','negative_amount'}

class Blocked(Exception): pass
class Contradicted(Exception): pass

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--toolchain', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True, help='new evidence directory outside repository')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    root = repo/'lean'
    output = args.output.resolve()
    toolchain = args.toolchain.resolve()
    records = []
    hashes = {}
    try:
        if output == repo or repo in output.parents or output.exists():
            raise Blocked('output must be a new directory outside repository')
        output.mkdir(parents=True)
        paths = {'model':root/'DefiKernel/AMM/R2Bridge.lean',
            'controls':root/'DefiKernel/AMM/R2BridgeAudit.lean',
            'original':repo/'benchmarks/competitive-landscape/upstream/rational-1/swap-2b60322-2/SwapModel.lean',
            'relation':repo/'benchmarks/competitive-landscape/library-replays/r2-20261117/OriginalContractRelation.lean'}
        data = {}
        for name,path in paths.items():
            data[name] = path.read_bytes()
            if not data[name]: raise Blocked('empty input: '+name)
            hashes[name] = hashlib.sha256(data[name]).hexdigest()
        for name in ['lean','lake','leanchecker']:
            if not os.access(toolchain/'bin'/name,os.X_OK): raise Blocked('unavailable tool: '+name)
        env = {'PATH':str(toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
        def run(name,argv):
            started = time.time()
            p = subprocess.run([str(x) for x in argv],cwd=root,env=env,
                stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180)
            (output/(name+'.stdout')).write_bytes(p.stdout)
            (output/(name+'.stderr')).write_bytes(p.stderr)
            records.append(dict(name=name,argv=[str(x) for x in argv],cwd=str(root),
                started_unix=started,wall_seconds=time.time()-started,exit=p.returncode,
                stdout_sha256=hashlib.sha256(p.stdout).hexdigest(),stderr_sha256=hashlib.sha256(p.stderr).hexdigest()))
            sys.stdout.buffer.write(p.stdout);sys.stderr.buffer.write(p.stderr)
            if b'BLOCKED:' in p.stdout+p.stderr: raise Blocked('native assertion inventory unavailable: '+name)
            if p.returncode: raise Contradicted('native command failed: '+name)
            return p.stdout.decode()
        version = run('version',[toolchain/'bin/lean','--version']).strip()
        if not version.startswith('Lean (version 4.33.0-rc2,'): raise Blocked('requires pinned Lean4.33.0-rc2')
        run('dependencies',[toolchain/'bin/lake','build','DefiKernel.AMM.Rational','DefiKernel.AxiomAudit'])
        lakepath = run('lake-path',[toolchain/'bin/lake','env','printenv','LEAN_PATH']).strip()
        env['LEAN_PATH'] = str(output)+':'+lakepath
        header = b'import DefiKernel.AMM.R2Bridge\n'
        if not data['controls'].startswith(header): raise Blocked('unrecognized control import boundary')
        replay = data['model']+b'\n'+data['controls'][len(header):]
        (output/'R2Replay.lean').write_bytes(replay)
        seen = run('fresh-source',[toolchain/'bin/lean','-R',output,'-o',output/'R2Replay.olean',output/'R2Replay.lean'])
        rows = [line.split() for line in seen.splitlines() if line.startswith('R2_CONTROL ') and not line.startswith('R2_CONTROL PASSED ')]
        if not rows: raise Blocked('no R2 assertions observed')
        if len(rows)!=len(LABELS) or {row[1] for row in rows}!=LABELS or any(len(row)!=3 or row[2]!='true' for row in rows):
            raise Contradicted('unexpected or false R2 assertion inventory')
        if seen.splitlines().count('R2_CONTROL PASSED 16/16')!=1: raise Contradicted('missing exact R2 completion record')
        (output/'SwapModel.lean').write_bytes(data['original'])
        run('original-model',[toolchain/'bin/lean','-R',output,'-o',output/'SwapModel.olean',output/'SwapModel.lean'])
        relation=data['relation'].replace(b'import DefiKernel.AMM.R2Bridge\n',b'import R2Replay\n')
        (output/'OriginalContractRelation.lean').write_bytes(relation)
        run('original-relation',[toolchain/'bin/lean','-R',output,'-o',output/'OriginalContractRelation.olean',output/'OriginalContractRelation.lean'])
        (output/'Audit.lean').write_text('import R2Replay\nimport OriginalContractRelation\nimport DefiKernel.AxiomAudit\n#audit_axioms R2Replay\n#audit_axioms OriginalContractRelation\n#print axioms DefiKernel.AMM.R2Bridge.canonical\n#print axioms R2OriginalRelation.all_constructor_behavior\n')
        audit = run('audit',[toolchain/'bin/lean','-R',output,output/'Audit.lean'])
        if len(re.findall(r'AXIOM AUDIT PASSED: ([1-9][0-9]*)/\1 theorems; forbidden=0',audit))!=2:
            raise Blocked('two nonempty theorem audits not observed')
        run('kernel-r2',[toolchain/'bin/leanchecker','-v','R2Replay'])
        run('kernel-relation',[toolchain/'bin/leanchecker','-v','OriginalContractRelation'])
        report=dict(status='PASS',assertions=len(rows),input_sha256=hashes,lean_version=version,
            lean_sha256=hashlib.sha256((toolchain/'bin/lean').read_bytes()).hexdigest(),commands=records,
            scope='fresh R2 source + 16 constructor controls + all-constructor original relation; imported libraries trusted by default kernel replay; no JSON parser or performance campaign')
        (output/'result.json').write_text(json.dumps(report,indent=2)+'\n')
        print('R2_REPLAY PASS 16/16; original relation, nonempty audits and kernel targets passed')
        return 0
    except (Blocked,FileNotFoundError,PermissionError,subprocess.TimeoutExpired) as error:
        print('BLOCKED: '+str(error),file=sys.stderr);return 3
    except Contradicted as error:
        print('FAIL: '+str(error),file=sys.stderr);return 1

if __name__=='__main__': sys.exit(main())
