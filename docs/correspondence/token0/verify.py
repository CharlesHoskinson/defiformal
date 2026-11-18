#!/usr/bin/env python3
"""Read-only pin/observation consistency check; no source execution or refinement proof."""
from pathlib import Path
import argparse
import hashlib
import sys
import json
import re
import tarfile

ARCHIVE_SHA = '8a8a9400e04a63ade06976959faca2a575e8158fa92f31d29e612cdc049ff981'
CASES = {'P16-I-ADD', 'P16-I-REM', 'P16-I-ZERO-LIQ', 'P16-ADD',
         'P16-ADD-ROUND', 'P16-REQ', 'P16-REQ-STRICT', 'P16-REM',
         'P16-SAFECAST', 'P16-ADD-DEN0', 'P16-PROD', 'P16-WRAP'}
MODEL_RUNS = {'p16-r6-lean-bindings', 'p16-r6-runtime-audit',
              'p18-token0-example', 'p18-runtime-audit-consumer'}


class BlockedCheck(Exception):
    """Required evidence is absent or empty."""


def nonempty(condition, message):
    if not condition:
        raise BlockedCheck(message)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def verify(root, record):
    pins = record['bound_files']
    nonempty(bool(pins), 'empty file inventory')
    bound = {}
    for pin in pins:
        name = pin['path']
        require(not Path(name).is_absolute() and '..' not in Path(name).parts,
                'nonrelative pin')
        require(name not in bound, 'duplicate pin')
        data = (root / name).read_bytes()
        nonempty(bool(data) or pin.get('allow_empty') is True, 'empty artifact: ' + name)
        require(len(data) == pin['bytes'] and sha(data) == pin['sha256'], 'drift: ' + name)
        bound[name] = data
    require(sha(bound[record['archive']]) == ARCHIVE_SHA, 'wrong source archive')
    with tarfile.open(root / record['archive']) as archive:
        for pin in pins:
            if 'archive_member' in pin:
                require(archive.extractfile(pin['archive_member']).read() == bound[pin['path']],
                        'archive member mismatch: ' + pin['path'])

    def load(name):
        return json.loads(bound[name])

    compiler = load(record['compiler_record'])
    require(compiler['probe_selector'] == record['relation']['selector'] == '6c84a8a2', 'selector')
    require(compiler['methodIdentifiers']['probe(uint160,uint128,uint256,bool)'] == '6c84a8a2', 'signature')
    folder = Path(record['compiler_record']).parent
    for name, expected in compiler['source_hashes'].items():
        require(sha(bound[str(folder / 'overlay' / name)]) == expected, 'compiler source')
    for field in ['solc_sha256', 'runtime_bytecode_sha256', 'creation_bytecode_sha256']:
        require(compiler[field] == record['tools_recorded'][field], field)
    runtime = bound[str(folder / 'runtime.hex')]
    require(sha(runtime) == compiler['runtime_hex_sha256'], 'runtime text')
    require(sha(bytes.fromhex(runtime.decode().strip().removeprefix('0x'))) == compiler['runtime_bytecode_sha256'], 'runtime bytes')
    model = {}
    for line in bound[record['model_binding_stdout']].decode().splitlines():
        match = re.fullmatch(r'(P16-[A-Z0-9-]+) sqrtP=(\d+) L=(\d+) amount=(\d+) add=(true|false) model=(ok:\d+|error:\w+) match=(true|false)', line)
        if match:
            require(match[1] not in model, 'duplicate model observation')
            model[match[1]] = match.groups()[1:]
    require(set(model) == CASES, 'nonexact model case set')
    runs = record['source_invocations']
    nonempty(bool(runs), 'empty source denominator')
    require(len(runs) == 12 and {r['case'] for r in runs} == CASES, 'nonexact source case set')
    successes = reverts = 0
    for run in runs:
        observation = load(run['observation_record'])
        receipt = load(run['receipt'])
        inputs = run['inputs']
        values = [int(inputs[k]) for k in ['sqrtPX96', 'liquidity', 'amount']]
        require(all(0 <= n < 2**bits for n, bits in zip(values, [160, 128, 256])), 'input bounds')
        require(type(inputs['add']) is bool, 'nonboolean input')
        values.append(int(inputs['add']))
        calldata = bytes.fromhex(bound[run['calldata']].decode().strip().removeprefix('0x'))
        require(len(calldata) == 132 and calldata[:4].hex() == '6c84a8a2', 'calldata framing')
        require([int.from_bytes(calldata[i:i+32], 'big') for i in range(4, 132, 32)] == values, 'calldata/input mismatch')
        require(observation['calldata_hex'].removeprefix('0x') == calldata.hex(), 'recorded calldata')
        require(sha(bound[run['calldata']]) == observation['calldata_sha256'], 'calldata pin')
        require(model[run['case']] == tuple(map(str, values[:3])) + (str(inputs['add']).lower(), run['model_result'], 'true'), 'actual model observation')
        for obj in [observation, receipt]:
            require(not obj['timeout'] and not obj['cancelled'], 'incomplete invocation')
            require(obj['start_utc'] == run['original_start_utc'] and obj['end_utc'] == run['original_end_utc'], 'timestamp')
            require(obj['stdout_sha256'] == sha(bound[run['stdout']]) and obj['stderr_sha256'] == sha(bound[run['stderr']]), 'stream receipt')
        require(receipt['exit'] == observation['process_exit'] == 0 and observation['receipt_valid'], 'process/receipt')
        require(receipt['classification'] == 'ok' and observation['status'] == 'observed', 'infrastructure outcome')
        require(receipt['argv'] == observation['argv'] and receipt['tool']['sha256'] == observation['evm_sha256'] == record['tools_recorded']['evm_sha256'], 'tool/invocation')
        require(observation['runtime_hex_sha256'] == sha(runtime), 'runtime context')
        genesis = str(Path(record['compiler_record']).parents[2] / 'genesis' / 'istanbul-genesis.json')
        require(observation['genesis_sha256'] == sha(bound[genesis]), 'genesis context')
        require(observation['selected_fork'] == 'istanbul' and observation['gas'] == 10000000000, 'fork/gas')
        obs = observation['observation']
        require(obs['class'] == run['semantic_class'] and obs['returndata'] == run['raw_returndata'], 'observation class/data')
        if obs['class'] == 'success':
            data = bytes.fromhex(obs['returndata'].removeprefix('0x'))
            require(len(data) == 32 and int.from_bytes(data, 'big') < 2**160, 'noncanonical success')
            require(run['model_result'] == 'ok:' + str(int.from_bytes(data, 'big')), 'successful relation')
            successes += 1
        else:
            require(obs['class'] == 'evm_revert' and obs['error'] == 'error: execution reverted', 'nonsemantic refusal')
            require(run['model_result'].startswith('error:') and obs['returndata'] == '0x', 'coarse refusal')
            reverts += 1
    models = record['model_only_invocations']
    nonempty(bool(models), 'empty model denominator')
    require(len(models) == 4 and {r['id'] for r in models} == MODEL_RUNS, 'nonexact model invocation set')
    for run in models:
        receipt = load(run['receipt'])
        require(receipt['exit'] == 0 and not receipt['timeout'] and not receipt['cancelled'], 'model invocation incomplete')
        require(receipt['stdout_sha256'] == sha(bound[run['stdout']]), 'model log receipt')
        require(receipt['start_utc'] == run['original_start_utc'] and receipt['end_utc'] == run['original_end_utc'], 'model timestamp')
    require(record['denominators'] == dict(source_invocations=12, source_successes=successes, source_coarse_reverts=reverts, model_only_invocations=4, source_plus_model_invocations=16), 'denominators')
    require((successes, reverts) == (8, 4), 'observation partition')
    theorem = record['model_theorem']
    require(sha(bound[theorem['source']]) == theorem['source_sha256'], 'model theorem source')
    return {'bound_files': len(bound), 'source_successes': successes, 'source_coarse_reverts': reverts, 'model_only_invocations': len(models)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path,
                        default=Path(__file__).with_name('differential-observations.json'))
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    try:
        data = args.manifest.read_bytes()
        nonempty(bool(data), 'empty manifest')
        result = verify(root, json.loads(data))
    except (FileNotFoundError, BlockedCheck) as error:
        print('BLOCKED: ' + str(error), file=sys.stderr)
        return 3
    except ValueError as error:
        print('FAIL: ' + str(error), file=sys.stderr)
        return 1
    print(json.dumps({'status': 'PASS', 'scope': 'pinned bytes and record consistency only', **result}, sort_keys=True))
    return 0


if __name__ == '__main__':
    sys.exit(main())
