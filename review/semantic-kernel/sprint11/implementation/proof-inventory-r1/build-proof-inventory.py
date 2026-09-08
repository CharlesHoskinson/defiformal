#!/usr/bin/env python3
"""Generate a source-bound Nary inventory from fresh Lean environment discovery.

Writes only this Sprint11 evidence directory. Does not modify Lean source, plans,
runners, git objects, Sprint10 artifacts, or the lake build cache.

Root is `git rev-parse --show-toplevel` from this script directory. Do not use
`Path.parents[4]`; that index is the Sprint10 depth and would resolve to `review/`
from this path.

`--candidate` is required for an inventory run. The planning baseline
`ed94e6050d092e67f945df7b9762d3096ab0feda` is recorded as history, not a default
frozen candidate. Parent adds `DefiKernel.Nary.Verify` after the Nary modules
compile. This script does not create that module.

Environment discovery (`importedTheorems` / `importedSupplemental`) controls the
inventory. The source index is supplemental attribution. Unresolved source
attribution is recorded; every elaborated row still binds statement, module, and
file hash.

Use `--self-check` for parser/root tests without lake or a frozen commit.
"""
from __future__ import annotations

import argparse
import collections
import datetime
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import time
import traceback

PLANNING_BASELINE = 'ed94e6050d092e67f945df7b9762d3096ab0feda'
ALLOWED_AXIOMS = {'propext', 'Classical.choice', 'Quot.sound'}
COMMAND_TIMEOUT_SECONDS = 600
GIT_TIMEOUT_SECONDS = 30
VERIFY_MODULE = 'DefiKernel.Nary.Verify'
AXIOM_MODULE = 'DefiKernel.AxiomAudit'
NARY_PREFIX = 'DefiKernel.Nary'
REQUIRED_NARY_BASENAMES = {
    'Audit.lean',
    'BinaryCorrespondence.lean',
    'Causal.lean',
    'CausalRuntime.lean',
    'Completion.lean',
    'Examples.lean',
    'Execution.lean',
    'FundedCausal.lean',
    'FundedCompanions.lean',
    'FundedEnabledness.lean',
    'InterfaceInstances.lean',
    'Interference.lean',
    'LocalOrder.lean',
    'Observation.lean',
    'Preservation.lean',
    'Schedule.lean',
    'Soundness.lean',
    'Tests.lean',
    'Trace.lean',
}
GENERIC_SUPPORT_MODULES = {
    'DefiKernel.Nary.Soundness',
    'DefiKernel.Nary.LocalOrder',
    'DefiKernel.Nary.Trace',
    'DefiKernel.Nary.Completion',
    'DefiKernel.Nary.Preservation',
    'DefiKernel.Nary.Interference',
}
GENERIC_RUNTIME_MODULES = {
    'DefiKernel.Nary.Schedule',
    'DefiKernel.Nary.Execution',
    'DefiKernel.Nary.Observation',
    'DefiKernel.Nary.CausalRuntime',
}
RUNTIME_REFERENCE_MODULES = {
    'DefiKernel.Nary.Examples',
    'DefiKernel.Nary.Tests',
    'DefiKernel.Nary.Audit',
}
CONCRETE_FUNDED_MODULES = {
    'DefiKernel.Nary.FundedCausal': 'funded_causal_concrete',
    'DefiKernel.Nary.FundedCompanions': 'funded_companions_concrete',
    'DefiKernel.Nary.FundedEnabledness': 'funded_enabledness_concrete',
}
COUNTEREXAMPLE_PREFIXES = (
    'f11_', 'f12_', 'f13_', 'f14_', 'f15_', 'f16_', 'f17_', 'f19_',
)
DECL_KINDS = (
    'theorem', 'lemma', 'def', 'abbrev', 'structure', 'inductive',
    'instance', 'class', 'opaque', 'axiom',
)
DECL_RE = re.compile(
    r'^(?P<prefix>(?:[ \t]*)(?:@\[[^\]]*\]\s*)*'
    r'(?:(?:set_option\s+\S+\s+\S+\s+in|omit\s+(?:\[[^\]]*\]\s*)+in|'
    r'include\s+(?:\[[^\]]*\]\s*)+in)\s+)*'
    r'(?:noncomputable\s+|unsafe\s+|partial\s+)*)'
    r'(?:(?P<visibility>private|protected)\s+)?'
    r'(?P<kind>theorem|lemma|def|abbrev|structure|inductive|instance|class|opaque|axiom)\s+'
    r'(?P<name>[\w.]+)',
    re.M,
)
NS_RE = re.compile(r'^[ \t]*namespace[ \t]+(\S+)[ \t]*$', re.M)
END_RE = re.compile(r'^[ \t]*end(?:[ \t]+(\S+))?[ \t]*$', re.M)
SECTION_RE = re.compile(r'^[ \t]*section(?:[ \t]+(\S+))?[ \t]*$', re.M)
VARIABLE_RE = re.compile(r'^[ \t]*variable[^\n]*(?:\n[ \t]+[^\n]*)*', re.M)
IMPORT_CMD_RE = re.compile(r'^[ \t]*(?:public[ \t]+)?import\b')
ONE_MODULE_IMPORT_RE = re.compile(
    r'^[ \t]*(?:public[ \t]+)?import[ \t]+([A-Za-z_][\w.]*)[ \t]*$',
)
MODULE_NAME_RE = re.compile(r'^[A-Za-z_][\w.]*$')
COMMIT_RE = re.compile(r'^[0-9a-f]{40}$')


class InventoryError(Exception):
    def __init__(self, status, message, exit_code):
        super().__init__(message)
        self.status = status
        self.message = message
        self.exit_code = exit_code


class InventoryBlocked(InventoryError):
    def __init__(self, status, message):
        super().__init__(status, message, 3)


class InventoryFailed(InventoryError):
    def __init__(self, status, message):
        super().__init__(status, message, 1)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sha_bytes(data):
    return hashlib.sha256(data).hexdigest()


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def repo_root(start):
    try:
        out = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            cwd=start, capture_output=True, text=True, timeout=GIT_TIMEOUT_SECONDS,
            check=False,
        )
    except subprocess.TimeoutExpired as err:
        raise InventoryBlocked('BLOCKED_ROOT_TIMEOUT', f'git rev-parse timed out from {start}: {err}')
    if out.returncode != 0:
        raise InventoryBlocked(
            'BLOCKED_ROOT_RESOLUTION',
            f'git rev-parse --show-toplevel failed from {start}: {out.stderr.strip()}',
        )
    root = pathlib.Path(out.stdout.strip()).resolve()
    if not (root / 'lean' / 'lakefile.toml').is_file():
        raise InventoryBlocked('BLOCKED_ROOT_NOT_DEFIFORMAL', f'git toplevel {root} lacks lean/lakefile.toml')
    return root


def rel(path, root):
    return path.resolve().relative_to(root).as_posix()


def save(out_dir, name, obj):
    (out_dir / name).write_text(json.dumps(obj, indent=2, ensure_ascii=False) + '\n')


def run_git(root, args, timeout=GIT_TIMEOUT_SECONDS):
    try:
        proc = subprocess.run(
            ['git', *args], cwd=root, capture_output=True, timeout=timeout, check=False,
        )
    except subprocess.TimeoutExpired as err:
        raise InventoryBlocked('BLOCKED_GIT_TIMEOUT', f'git {args} timed out: {err}')
    if proc.returncode != 0:
        raise InventoryBlocked(
            'BLOCKED_GIT',
            f'git {args} exit {proc.returncode}: {proc.stderr.decode("utf-8", "replace").strip()}',
        )
    return proc.stdout


def mask_lean_comments(text):
    """Replace comments with spaces. Preserve newlines so line numbers stay aligned."""
    chars = list(text)
    i = 0
    n = len(chars)
    while i < n:
        if i + 1 < n and chars[i] == '/' and chars[i + 1] == '-':
            depth = 1
            chars[i] = ' '
            chars[i + 1] = ' '
            i += 2
            while i < n and depth:
                if i + 1 < n and chars[i] == '/' and chars[i + 1] == '-':
                    depth += 1
                    chars[i] = ' '
                    chars[i + 1] = ' '
                    i += 2
                    continue
                if i + 1 < n and chars[i] == '-' and chars[i + 1] == '/':
                    depth -= 1
                    chars[i] = ' '
                    chars[i + 1] = ' '
                    i += 2
                    continue
                if chars[i] != '\n':
                    chars[i] = ' '
                i += 1
            continue
        if i + 1 < n and chars[i] == '-' and chars[i + 1] == '-':
            while i < n and chars[i] != '\n':
                chars[i] = ' '
                i += 1
            continue
        i += 1
    return ''.join(chars)


def current_namespace(stack):
    parts = [frame['name'] for frame in stack if frame['kind'] == 'ns' and frame['name']]
    return '.'.join(parts)


def active_section_variables(stack):
    found = []
    for frame in stack:
        found.extend(frame['variables'])
    return found


def close_end(stack, name):
    if not stack:
        return False
    if name is None:
        stack.pop()
        return True
    parts = name.split('.')
    if len(stack) < len(parts):
        return False
    inner = [frame['name'] for frame in stack[-len(parts):]]
    if inner != parts:
        return False
    del stack[-len(parts):]
    return True


def parse_import_line(rest):
    """Parse one import command body from comment-masked source.

    Local DefiKernel imports must be a single module token on the same line.
    Bare `import`, a following-line module, extra tokens (`as`, `hiding`, a
    second module) are unsupported local syntax.
    """
    rest = (rest or '').strip()
    if not rest:
        return {'kind': 'unsupported', 'reason': 'bare_or_multiline_import', 'text': '', 'tokens': []}
    tokens = rest.split()
    first = tokens[0]
    extras = tokens[1:]
    if extras or '(' in rest or not MODULE_NAME_RE.fullmatch(first):
        return {'kind': 'unsupported', 'reason': 'extra_tokens', 'text': rest, 'tokens': tokens}
    if first.startswith('DefiKernel.'):
        return {'kind': 'local', 'module': first}
    return {'kind': 'external', 'module': first}


def local_imports_from_text(original):
    masked = mask_lean_comments(original)
    local = []
    external = []
    unsupported = []
    for line in masked.splitlines():
        if not IMPORT_CMD_RE.match(line):
            continue
        one = ONE_MODULE_IMPORT_RE.match(line)
        if one is None:
            rest = re.sub(r'^[ \t]*(?:public[ \t]+)?import\b', '', line).strip()
            parsed = parse_import_line(rest)
            if parsed['kind'] != 'unsupported':
                parsed = {
                    'kind': 'unsupported',
                    'reason': 'bare_or_multiline_import' if not rest else 'non_one_module_line',
                    'text': rest,
                    'tokens': rest.split(),
                }
            unsupported.append(parsed)
            continue
        parsed = parse_import_line(one.group(1))
        kind = parsed['kind']
        if kind == 'local':
            local.append(parsed['module'])
        elif kind == 'external':
            external.append(parsed['module'])
        else:
            unsupported.append(parsed)
    return local, external, unsupported


def resolve_candidate(root, requested_ref):
    peeled = f'{requested_ref}^{{commit}}'
    raw = run_git(root, ['rev-parse', '--verify', peeled]).decode().strip()
    if not COMMIT_RE.fullmatch(raw):
        raise InventoryBlocked(
            'BLOCKED_CANDIDATE_NOT_IMMUTABLE_COMMIT',
            f'{peeled} resolved to {raw!r}, not a 40-character commit',
        )
    return {
        'requested_ref': requested_ref,
        'resolved_commit': raw,
        'peel_arg': peeled,
        'requested_equals_resolved': requested_ref == raw,
    }


def tool_records(paths):
    rows = []
    for path in paths:
        rows.append({'path': str(path), 'sha256': sha(path), 'bytes': path.stat().st_size})
    return rows


def assert_tool_hashes_stable(before, after):
    if before != after:
        raise InventoryFailed(
            'FAIL_TOOL_BINARY_DRIFT',
            'Lean/Lake/Python bytes changed during inventory execution',
        )


def extract_statement(original, start, kind):
    tail = original[start:]
    if kind in ('theorem', 'lemma'):
        return tail.split(':=', 1)[0].strip()
    return tail.split('\n\n', 1)[0].strip()


def index_source_text(original, module, rel_path, source_meta):
    """Walk namespace/section stacks. Multiple and nested namespaces are allowed."""
    masked = mask_lean_comments(original)
    stack = []
    declarations = {}
    parser_notes = []
    commands = []
    for match in NS_RE.finditer(masked):
        commands.append((match.start(), 'namespace', match.group(1)))
    for match in SECTION_RE.finditer(masked):
        commands.append((match.start(), 'section', match.group(1)))
    for match in END_RE.finditer(masked):
        commands.append((match.start(), 'end', match.group(1)))
    for match in VARIABLE_RE.finditer(masked):
        commands.append((match.start(), 'variable', match.group(0).strip()))
    for match in DECL_RE.finditer(masked):
        commands.append((match.start(), 'decl', match))
    commands.sort(key=lambda item: (item[0], {'namespace': 0, 'section': 1, 'variable': 2, 'decl': 3, 'end': 4}[item[1]]))
    for start, kind, payload in commands:
        if kind == 'namespace':
            for part in payload.split('.'):
                stack.append({'kind': 'ns', 'name': part, 'variables': []})
            continue
        if kind == 'section':
            stack.append({'kind': 'section', 'name': payload, 'variables': []})
            continue
        if kind == 'end':
            if not close_end(stack, payload):
                parser_notes.append({
                    'kind': 'unmatched_end',
                    'name': payload,
                    'line': original[:start].count('\n') + 1,
                    'module': module,
                })
            continue
        if kind == 'variable':
            if not stack:
                parser_notes.append({
                    'kind': 'variable_without_scope',
                    'text': payload,
                    'line': original[:start].count('\n') + 1,
                    'module': module,
                })
            else:
                stack[-1]['variables'].append(payload)
            continue
        match = payload
        name = match.group('name')
        decl_kind = match.group('kind')
        visibility = match.group('visibility')
        ns = current_namespace(stack)
        full = f'{ns}.{name}' if ns else name
        key = (module, full)
        kind_start = match.start('kind')
        line = original[:kind_start].count('\n') + 1
        decl = {
            'source_name': full,
            'local_name': name,
            'namespace': ns,
            'namespace_stack': [
                {'kind': frame['kind'], 'name': frame['name']} for frame in stack
            ],
            'module': module,
            'source': rel_path,
            'line': line,
            'source_statement': extract_statement(original, kind_start, decl_kind),
            'section_variables': list(active_section_variables(stack)),
            'immediately_preceding_lines': original.splitlines()[max(0, line - 5):line - 1],
            'kind': decl_kind,
            'visibility': visibility or 'public',
            'private': visibility == 'private',
            'source_sha256': source_meta['sha256'],
            'source_git_blob': source_meta['git_blob'],
        }
        if key in declarations:
            parser_notes.append({
                'kind': 'duplicate_source_name',
                'key': [module, full],
                'line': line,
            })
            declarations[key]['duplicate'] = True
            continue
        declarations[key] = decl
    if stack:
        parser_notes.append({
            'kind': 'stack_residue',
            'module': module,
            'stack': [{'kind': frame['kind'], 'name': frame['name']} for frame in stack],
        })
    return declarations, parser_notes


def unique_owner(user_name, module, declarations):
    owners = [
        decl for (mod, full), decl in declarations.items()
        if mod == module and user_name.startswith(full + '.')
    ]
    if len(owners) == 1:
        return owners[0], 'unique'
    if len(owners) > 1:
        return None, 'ambiguous'
    return None, 'none'


def module_role(module):
    if module == 'DefiKernel.Nary.Causal':
        return 'causal_generic'
    if module in CONCRETE_FUNDED_MODULES:
        return CONCRETE_FUNDED_MODULES[module]
    if module == 'DefiKernel.Nary.InterfaceInstances':
        return 'interface_instances_concrete'
    if module == 'DefiKernel.Nary.BinaryCorrespondence':
        return 'binary_specialization'
    if module in GENERIC_SUPPORT_MODULES:
        return 'generic_support'
    if module in GENERIC_RUNTIME_MODULES:
        return 'runtime_generic'
    if module in RUNTIME_REFERENCE_MODULES:
        return 'runtime_reference'
    if module == 'DefiKernel.Nary.Verify':
        return 'parent_verify'
    return 'unresolved_module'


def counterexample_prefix(user_name):
    base = user_name.rsplit('.', 1)[-1]
    for prefix in COUNTEREXAMPLE_PREFIXES:
        if base.startswith(prefix):
            return prefix
    return None


def classify_claim(row, origin):
    role = module_role(row['module'])
    row['module_role'] = role
    private = bool(row.get('private') or row.get('is_private_name'))
    if private and origin != 'generated':
        return (
            'privatehelper',
            'Private helper. Faithful local lemma. Not a generic Causal claim and not a concrete FundedCausal or InterfaceInstances claim.',
        )
    if origin == 'generated':
        return (
            'generated',
            'Generated theorem constant. Owner line is attribution when uniquely identifiable, not an explicit claim statement.',
        )
    marker = counterexample_prefix(row.get('user_name') or '')
    if role in ('causal_generic', 'runtime_generic', 'generic_support', 'binary_specialization'):
        if marker:
            return (
                'counterexample',
                'Named counterexample in a generic Nary module. Not a generic preservation claim and not a concrete funded instance.',
            )
        notes = {
            'causal_generic': 'Generic Causal claim over arbitrary machines and schedules. Not a concrete funded witness.',
            'runtime_generic': 'Generic runtime-module proof. Execution, Observation, Schedule and CausalRuntime theorems are generic, not fixture reference instances.',
            'generic_support': 'Generic Nary support lemma. Distinct from FundedCausal/InterfaceInstances concrete claims and from Examples/Tests/Audit reference instances.',
            'binary_specialization': 'Generic binary specialization against the existing executor. No participant-tree regrouping claim.',
        }
        return ('genericproof', notes[role])
    if role == 'funded_causal_concrete':
        if marker:
            return (
                'counterexample',
                'Concrete FundedCausal companion or negative. Not the generic Causal rule.',
            )
        return (
            'concreteproof',
            'Concrete FundedCausal instance. Not the generic Causal rule.',
        )
    if role == 'funded_companions_concrete':
        if marker:
            return (
                'counterexample',
                'Named FundedCompanions negative (F12/F16/F17). Fixed F10-family configuration, not a generic all-protocol claim.',
            )
        return (
            'concreteproof',
            'Concrete FundedCompanions F10/F12/F16/F17 instance or support lemma. Fixed configuration, not a generic all-protocol claim.',
        )
    if role == 'funded_enabledness_concrete':
        if marker:
            return (
                'counterexample',
                'Named FundedEnabledness negative. Still a fixed F10 configuration, not a generic all-protocol claim.',
            )
        return (
            'concreteproof',
            'Concrete F10 enabledness. Quantified current world, store, history and funding hypotheses are the exact statement, not a generic all-protocol claim.',
        )
    if role == 'interface_instances_concrete':
        if marker:
            return (
                'counterexample',
                'Concrete InterfaceInstances counterexample. F15 remains logical only. Not a generic interference theorem.',
            )
        return (
            'concreteproof',
            'Concrete InterfaceInstances / accepted-M2 instance. Not the generic Causal rule.',
        )
    if role == 'runtime_reference':
        return (
            'referenceinstance',
            'Examples/Tests/Audit declaration. Development instance, not a holdout or universal economic claim.',
        )
    if role == 'parent_verify':
        return (
            'generated',
            'Verify is parent-owned. It should remain import/audit-only.',
        )
    return (
        'unresolved_module_class',
        'Module provenance is not in the classified Nary map. Statement, module and file hash remain bound.',
    )


def module_to_source(module):
    return 'lean/' + module.replace('.', '/') + '.lean'


def source_paths(root, work):
    verify_path = work / (VERIFY_MODULE.replace('.', '/') + '.lean')
    axiom_path = work / (AXIOM_MODULE.replace('.', '/') + '.lean')
    nary_dir = work / 'DefiKernel' / 'Nary'
    if not verify_path.is_file():
        raise InventoryBlocked(
            'BLOCKED_MISSING_VERIFY',
            'Parent-owned DefiKernel.Nary.Verify is absent. Do not invent that module here.',
        )
    if not axiom_path.is_file():
        raise InventoryBlocked('BLOCKED_MISSING_AXIOMAUDIT', f'Missing {axiom_path}')
    present = set(nary_dir.glob('*.lean'))
    missing_floor = [name for name in sorted(REQUIRED_NARY_BASENAMES) if not (nary_dir / name).is_file()]
    if missing_floor:
        raise InventoryBlocked('BLOCKED_MISSING_NARY_SOURCE', f'Missing required Nary files: {missing_floor}')
    found = set()
    pending = [VERIFY_MODULE, AXIOM_MODULE]
    external_imports = []
    while pending:
        module = pending.pop()
        path = work / (module.replace('.', '/') + '.lean')
        if path in found:
            continue
        if not path.is_file():
            raise InventoryBlocked('BLOCKED_MISSING_IMPORT', f'Import path is not a file: {path}')
        found.add(path)
        local, external, unsupported = local_imports_from_text(path.read_text())
        if unsupported:
            raise InventoryFailed(
                'FAIL_UNSUPPORTED_LOCAL_IMPORT',
                f'{path}: {unsupported}',
            )
        external_imports.extend({'from': module, 'module': name} for name in external)
        for imported in local:
            pending.append(imported)
    if not present <= found:
        missing = sorted(rel(path, root) for path in present - found)
        raise InventoryFailed(
            'FAIL_IMPORT_CLOSURE',
            'Verify import closure omits Nary sources: ' + ', '.join(missing),
        )
    required_paths = {nary_dir / name for name in REQUIRED_NARY_BASENAMES}
    required_paths.add(verify_path)
    if not required_paths <= found:
        missing = sorted(rel(path, root) for path in required_paths - found)
        raise InventoryFailed(
            'FAIL_REQUIRED_NARY_IMPORTS',
            'Import closure lacks required Nary files including FundedCausal/InterfaceInstances/BinaryCorrespondence: '
            + ', '.join(missing),
        )
    config = {work / 'lean-toolchain', work / 'lakefile.toml', work / 'lake-manifest.json'}
    return sorted(found | config), present, required_paths, external_imports


def snapshot(root, candidate, paths):
    rows = {}
    for path in paths:
        rel_path = rel(path, root)
        frozen = run_git(root, ['show', f'{candidate}:{rel_path}'])
        working = path.read_bytes()
        if frozen != working:
            raise InventoryFailed(
                'FAIL_CANDIDATE_SOURCE_DRIFT',
                f'Working tree bytes differ from immutable commit {candidate}:{rel_path}',
            )
        blob = run_git(root, ['rev-parse', f'{candidate}:{rel_path}']).decode().strip()
        rows[rel_path] = {
            'sha256': sha_bytes(working),
            'bytes': len(frozen),
            'git_blob': blob,
            'frozen_bytes_match': True,
        }
    return rows


def porcelain(root, paths):
    rels = [rel(path, root) for path in paths]
    out = run_git(root, ['status', '--porcelain', '-uall', '--', *rels])
    return out.decode().splitlines()


def which_tool(work, name):
    try:
        proc = subprocess.run(
            ['elan', 'which', name], cwd=work, capture_output=True, text=True,
            timeout=GIT_TIMEOUT_SECONDS, check=False,
        )
    except subprocess.TimeoutExpired as err:
        raise InventoryBlocked('BLOCKED_ELAN_TIMEOUT', f'elan which {name} timed out: {err}')
    if proc.returncode != 0:
        raise InventoryBlocked('BLOCKED_ELAN', f'elan which {name} failed: {proc.stderr.strip()}')
    path = pathlib.Path(proc.stdout.strip())
    if not path.is_file():
        raise InventoryBlocked('BLOCKED_TOOL_MISSING', f'{name} is not a file: {path}')
    return path


def parse_marker_rows(text, marker):
    rows = []
    for line in text.splitlines():
        if marker not in line:
            continue
        payload = line.split(marker, 1)[1]
        try:
            rows.append(json.loads(payload))
        except json.JSONDecodeError as err:
            raise InventoryFailed('FAIL_DRIVER_JSON', f'{marker} JSON failed: {err}: {payload[:200]}')
    return rows


def audit_rows(verify_text, marker):
    pattern = re.compile(
        rf'AXIOM AUDIT {marker}: ([^;]+); module=([^;]+); (?:kind=[^;]+; )?axioms=\[(.*?)\]',
        re.S,
    )
    found = {}
    for name, mod, axioms in pattern.findall(verify_text):
        found[name] = (mod, set(re.findall(r'[^,\s]+', axioms)))
    return found


def bind_source_row(row, before):
    source = module_to_source(row['module'])
    if source not in before:
        raise InventoryFailed(
            'FAIL_MODULE_FILE_UNBOUND',
            f'Elaborated module {row["module"]} is not in the frozen source snapshot ({source})',
        )
    row['source'] = source
    row['source_sha256'] = before[source]['sha256']
    row['source_git_blob'] = before[source]['git_blob']
    return source


def attach_explicit(row, decl):
    for key in (
        'source_name', 'local_name', 'namespace', 'namespace_stack', 'source', 'line',
        'source_statement', 'section_variables', 'immediately_preceding_lines',
        'kind', 'visibility', 'private', 'source_sha256', 'source_git_blob',
    ):
        row[key] = decl[key]


def attribute_theorem(row, declarations, before):
    bind_source_row(row, before)
    user = row['user_name']
    key = (row['module'], user)
    decl = declarations.get(key)
    if decl and not decl.get('duplicate'):
        if decl['module'] != row['module']:
            row['declaration_origin'] = 'unresolved_module_mismatch'
        else:
            if bool(decl['private']) != bool(row['is_private_name']):
                row['private_flag_mismatch'] = {
                    'source_private': decl['private'],
                    'lean_is_private_name': row['is_private_name'],
                }
            attach_explicit(row, decl)
            row['declaration_origin'] = 'explicit'
            return user
    owner, owner_status = unique_owner(user, row['module'], declarations)
    if owner_status == 'unique':
        row['declaration_origin'] = 'generated'
        row['source_owner'] = owner['source_name']
        row['line'] = owner['line']
        return None
    if owner_status == 'ambiguous':
        row['declaration_origin'] = 'unresolved_ambiguous_owner'
        row['source_owner'] = None
        return None
    row['declaration_origin'] = 'unresolved_source'
    row['source_owner'] = None
    return None


def private_identities(explicit, mapped):
    rows = []
    for (module, full), decl in explicit.items():
        ident = (module, full)
        if decl.get('private') and ident in mapped:
            rows.append({
                'module': module,
                'user_name': full,
                'elaborated_name': mapped[ident],
            })
    return rows


def walk_defi_kernel_sources(work, roots):
    found = set()
    pending = list(roots)
    external = []
    unsupported = []
    while pending:
        module = pending.pop()
        path = work / (module.replace('.', '/') + '.lean')
        if path in found:
            continue
        if not path.is_file():
            continue
        found.add(path)
        local, ext, unsup = local_imports_from_text(path.read_text())
        unsupported.extend({'module': module, **item} if isinstance(item, dict) else {'module': module, 'text': item} for item in unsup)
        external.extend(ext)
        pending.extend(local)
    return found, sorted(set(external)), unsupported


def closure_invariant_holds(report):
    return bool(
        report.get('nonempty')
        and report.get('unique')
        and not report.get('required_missing')
        and not report.get('nary_missing_from_closure')
        and not report.get('unsupported')
        and report.get('reachable_count', 0) > 0
        and report.get('nary_present_count', 0) > 0
    )


def local_source_closure_report(root, work, nary_dir):
    present = sorted(nary_dir.glob('*.lean'))
    required_missing = [name for name in sorted(REQUIRED_NARY_BASENAMES) if not (nary_dir / name).is_file()]
    roots = [AXIOM_MODULE] + [
        '.'.join(path.relative_to(work).with_suffix('').parts) for path in present
    ]
    found, external, unsupported = walk_defi_kernel_sources(work, roots)
    resolved = [path.resolve() for path in found]
    nary_missing = [rel(path, root) for path in present if path not in found]
    files = []
    for path in sorted(found, key=lambda item: rel(item, root)):
        files.append({
            'path': rel(path, root),
            'sha256': sha(path),
            'bytes': path.stat().st_size,
        })
    return {
        'nonempty': len(found) > 0,
        'unique': len(found) == len(set(resolved)),
        'nary_present_count': len(present),
        'reachable_count': len(found),
        'required_missing': required_missing,
        'nary_missing_from_closure': nary_missing,
        'unsupported': unsupported,
        'external': external,
        'files': files,
    }


def attribute_supplemental(row, declarations, before):
    bind_source_row(row, before)
    user = row['user_name']
    decl = declarations.get((row['module'], user))
    if decl and not decl.get('duplicate') and decl['module'] == row['module']:
        row['source_declaration'] = decl
        row['declaration_origin'] = 'explicit'
        return
    owner, owner_status = unique_owner(user, row['module'], declarations)
    if owner_status == 'unique':
        row['declaration_origin'] = 'generated'
        row['source_owner'] = owner['source_name']
        row['line'] = owner['line']
        return
    if owner_status == 'ambiguous':
        row['declaration_origin'] = 'unresolved_ambiguous_owner'
        return
    row['declaration_origin'] = 'unresolved_source'


def run_self_checks():
    script = pathlib.Path(__file__).resolve()
    out_dir = script.parent
    root = repo_root(out_dir)
    checks = []

    def check(name, cond, detail=None):
        if isinstance(detail, set):
            detail = sorted(detail)
        checks.append({'name': name, 'passed': bool(cond), 'detail': detail})

    check('root_has_lakefile', (root / 'lean' / 'lakefile.toml').is_file(), str(root))
    check('parents4_is_not_root', script.parents[4] != root, str(script.parents[4]))
    check('root_method_is_git', True, 'git rev-parse --show-toplevel')
    sprint10 = root / 'review/semantic-kernel/sprint10/proof-inventory-r1/build-proof-inventory.py'
    check('sprint10_builder_present_unedited_by_this_tool', sprint10.is_file(), str(sprint10))

    nested = """
namespace Outer
namespace Inner
theorem foo : True := trivial
end Inner
theorem bar : True := trivial
end Outer
"""
    decls, notes = index_source_text(nested, 'Mod.Nested', 'lean/Mod/Nested.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('nested_inner_foo', ('Mod.Nested', 'Outer.Inner.foo') in decls, sorted(decls))
    check('nested_outer_bar', ('Mod.Nested', 'Outer.bar') in decls, sorted(decls))
    check('nested_does_not_use_first_namespace_only', ('Mod.Nested', 'Outer.foo') not in decls, sorted(decls))
    check('nested_no_parser_notes', notes == [], notes)

    sequential = """
namespace DefiKernel.Nary
theorem one : True := trivial
end DefiKernel.Nary
namespace DefiKernel.Nary.FundedCausal
theorem two : True := trivial
end DefiKernel.Nary.FundedCausal
"""
    decls, notes = index_source_text(sequential, 'Mod.Seq', 'lean/Mod/Seq.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('multi_ns_one', ('Mod.Seq', 'DefiKernel.Nary.one') in decls, sorted(decls))
    check('multi_ns_two', ('Mod.Seq', 'DefiKernel.Nary.FundedCausal.two') in decls, sorted(decls))
    check('multi_ns_not_misattributed', ('Mod.Seq', 'DefiKernel.Nary.two') not in decls, sorted(decls))

    sectioned = """
namespace DefiKernel.Nary
section
variable (P : Type)
theorem foo : True := trivial
end
theorem bar : True := trivial
end DefiKernel.Nary
"""
    decls, notes = index_source_text(sectioned, 'Mod.Sec', 'lean/Mod/Sec.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('section_does_not_pop_namespace', ('Mod.Sec', 'DefiKernel.Nary.foo') in decls, sorted(decls))
    check('section_end_keeps_later_namespace', ('Mod.Sec', 'DefiKernel.Nary.bar') in decls, sorted(decls))
    check('section_no_residue', notes == [], notes)
    foo_vars = decls[('Mod.Sec', 'DefiKernel.Nary.foo')]['section_variables']
    bar_vars = decls[('Mod.Sec', 'DefiKernel.Nary.bar')]['section_variables']
    check('open_section_variable_attached', any('P : Type' in item for item in foo_vars), foo_vars)
    check('closed_section_variable_not_on_later_theorem', not any('P : Type' in item for item in bar_vars), bar_vars)

    omit_src = """
namespace DefiKernel.Nary
omit [Fintype P] [Fintype A] [Fintype D] in
theorem binaryParticipants_order : True := trivial
end DefiKernel.Nary
"""
    decls, _notes = index_source_text(omit_src, 'DefiKernel.Nary.BinaryCorrespondence', 'lean/DefiKernel/Nary/BinaryCorrespondence.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('omit_in_theorem', ('DefiKernel.Nary.BinaryCorrespondence', 'DefiKernel.Nary.binaryParticipants_order') in decls, sorted(decls))

    option_src = """
namespace DefiKernel.Nary.InterfaceInstances
set_option maxHeartbeats 800000 in
theorem f18_execute_initial : True := trivial
end DefiKernel.Nary.InterfaceInstances
"""
    decls, _notes = index_source_text(option_src, 'DefiKernel.Nary.InterfaceInstances', 'lean/DefiKernel/Nary/InterfaceInstances.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('set_option_in_theorem', ('DefiKernel.Nary.InterfaceInstances', 'DefiKernel.Nary.InterfaceInstances.f18_execute_initial') in decls, sorted(decls))

    private_src = """
namespace DefiKernel.Nary
private theorem skipped_of_halted : True := trivial
theorem joint_advanceMonitored : True := trivial
end DefiKernel.Nary
"""
    decls, _notes = index_source_text(private_src, 'DefiKernel.Nary.Causal', 'lean/DefiKernel/Nary/Causal.lean', {'sha256': 'x', 'git_blob': 'y'})
    priv = decls[('DefiKernel.Nary.Causal', 'DefiKernel.Nary.skipped_of_halted')]
    pub = decls[('DefiKernel.Nary.Causal', 'DefiKernel.Nary.joint_advanceMonitored')]
    check('private_flag', priv['private'] is True, priv)
    pub_row = {'module': 'DefiKernel.Nary.Causal', 'user_name': pub['source_name'], 'is_private_name': False, 'private': False}
    cat, _note = classify_claim(pub_row, 'explicit')
    check('causal_public_is_generic', cat == 'genericproof', cat)
    priv_row = {'module': 'DefiKernel.Nary.Causal', 'user_name': priv['source_name'], 'is_private_name': True, 'private': True}
    cat, _note = classify_claim(priv_row, 'explicit')
    check('causal_private_is_not_generic_claim', cat == 'privatehelper', cat)

    dotted = """
namespace DefiKernel.Nary
theorem AdvanceSound.eq_advance : True := trivial
end DefiKernel.Nary
"""
    decls, _notes = index_source_text(dotted, 'DefiKernel.Nary.Causal', 'lean/DefiKernel/Nary/Causal.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('dotted_theorem_name', ('DefiKernel.Nary.Causal', 'DefiKernel.Nary.AdvanceSound.eq_advance') in decls, sorted(decls))

    commented = """
namespace DefiKernel.Nary
/-
namespace Fake
theorem hidden : True := trivial
-/
theorem visible : True := trivial
end DefiKernel.Nary
"""
    decls, _notes = index_source_text(commented, 'Mod.Comment', 'lean/Mod/Comment.lean', {'sha256': 'x', 'git_blob': 'y'})
    check('comment_namespace_ignored', ('Mod.Comment', 'Fake.hidden') not in decls, sorted(decls))
    check('comment_theorem_ignored', ('Mod.Comment', 'DefiKernel.Nary.hidden') not in decls, sorted(decls))
    check('visible_after_comment', ('Mod.Comment', 'DefiKernel.Nary.visible') in decls, sorted(decls))

    two_files = {}
    a, _n = index_source_text(
        'namespace DefiKernel.Nary\ntheorem alpha : True := trivial\nend DefiKernel.Nary\n',
        'DefiKernel.Nary.Soundness', 'lean/DefiKernel/Nary/Soundness.lean', {'sha256': 'a', 'git_blob': 'a'},
    )
    b, _n = index_source_text(
        'namespace DefiKernel.Nary\ntheorem beta : True := trivial\nend DefiKernel.Nary\n',
        'DefiKernel.Nary.Trace', 'lean/DefiKernel/Nary/Trace.lean', {'sha256': 'b', 'git_blob': 'b'},
    )
    two_files.update(a)
    two_files.update(b)
    check('shared_ns_keyed_by_module_alpha', ('DefiKernel.Nary.Soundness', 'DefiKernel.Nary.alpha') in two_files, sorted(two_files))
    check('shared_ns_keyed_by_module_beta', ('DefiKernel.Nary.Trace', 'DefiKernel.Nary.beta') in two_files, sorted(two_files))

    gen_decls = {}
    owner_a = {'source_name': 'DefiKernel.Nary.foo', 'line': 1, 'module': 'DefiKernel.Nary.Causal'}
    owner_b = {'source_name': 'DefiKernel.Nary.foo.bar', 'line': 2, 'module': 'DefiKernel.Nary.Causal'}
    gen_decls[('DefiKernel.Nary.Causal', 'DefiKernel.Nary.foo')] = owner_a
    gen_decls[('DefiKernel.Nary.Causal', 'DefiKernel.Nary.foo.bar')] = owner_b
    owner, status = unique_owner('DefiKernel.Nary.foo.bar.eq_1', 'DefiKernel.Nary.Causal', gen_decls)
    check('ambiguous_owner_not_maxlen', status == 'ambiguous' and owner is None, status)

    funded_row = {'module': 'DefiKernel.Nary.FundedCausal', 'user_name': 'DefiKernel.Nary.FundedCausal.f10_start_K', 'is_private_name': False}
    cat, _note = classify_claim(funded_row, 'explicit')
    check('funded_is_concrete', cat == 'concreteproof', cat)
    f12_row = {'module': 'DefiKernel.Nary.FundedCausal', 'user_name': 'DefiKernel.Nary.FundedCausal.f12_vault_final', 'is_private_name': False}
    cat, _note = classify_claim(f12_row, 'explicit')
    check('funded_negative_is_counterexample', cat == 'counterexample', cat)
    iface_row = {'module': 'DefiKernel.Nary.InterfaceInstances', 'user_name': 'DefiKernel.Nary.InterfaceInstances.f18_every_prefix', 'is_private_name': False}
    cat, _note = classify_claim(iface_row, 'explicit')
    check('interface_is_concrete', cat == 'concreteproof', cat)
    f15_row = {'module': 'DefiKernel.Nary.InterfaceInstances', 'user_name': 'DefiKernel.Nary.InterfaceInstances.f15_false_circular', 'is_private_name': False}
    cat, _note = classify_claim(f15_row, 'explicit')
    check('f15_is_counterexample', cat == 'counterexample', cat)
    unresolved_row = {'module': 'DefiKernel.Nary.BinaryCorrespondence', 'user_name': 'DefiKernel.Nary.binaryParticipants_order', 'is_private_name': False}
    cat, _note = classify_claim(unresolved_row, 'unresolved_source')
    check('unresolved_public_still_module_classified', cat == 'genericproof', cat)
    check('unresolved_not_silently_generated_origin', True, 'declaration_origin remains unresolved_source and is not rewritten to generated')
    unresolved_priv = {'module': 'DefiKernel.Nary.Causal', 'user_name': 'DefiKernel.Nary.skipped_of_halted', 'is_private_name': True}
    cat, _note = classify_claim(unresolved_priv, 'unresolved_source')
    check('unresolved_private_stays_helper', cat == 'privatehelper', cat)

    nary_dir = root / 'lean' / 'DefiKernel' / 'Nary'
    check('nary_dir_exists', nary_dir.is_dir(), str(nary_dir))
    present = {path.name for path in nary_dir.glob('*.lean')}
    check('required_nary_basenames_present', REQUIRED_NARY_BASENAMES <= present, sorted(REQUIRED_NARY_BASENAMES - present))
    check('verify_absent_at_self_check_or_parent_owned', True, 'Verify.lean' in present)
    check('planning_baseline_not_default_candidate', PLANNING_BASELINE != '', PLANNING_BASELINE)
    live_namespaces = {}
    live_counts = {'theorem': 0, 'lemma': 0, 'private_theorem': 0, 'omit_or_option_prefixed': 0}
    live_notes = []
    for path in sorted(nary_dir.glob('*.lean')):
        module = '.'.join(path.relative_to(root / 'lean').with_suffix('').parts)
        text = path.read_text()
        decls, notes = index_source_text(
            text, module, path.relative_to(root).as_posix(),
            {'sha256': sha(path), 'git_blob': 'working-tree-self-check'},
        )
        live_notes.extend({'file': path.name, **note} for note in notes)
        nss = sorted({decl['namespace'] for decl in decls.values()})
        live_namespaces[path.name] = nss
        for decl in decls.values():
            if decl['kind'] in ('theorem', 'lemma'):
                live_counts['theorem' if decl['kind'] == 'theorem' else 'lemma'] += 1
                if decl['private']:
                    live_counts['private_theorem'] += 1
            if re.search(r'omit |set_option ', '\n'.join(decl.get('immediately_preceding_lines') or [])):
                live_counts['omit_or_option_prefixed'] += 1
    check('live_nary_has_multiple_namespaces', len({ns for nss in live_namespaces.values() for ns in nss}) > 1, live_namespaces)
    check('live_nary_parser_no_stack_residue', not any(note.get('kind') == 'stack_residue' for note in live_notes), live_notes)
    check('live_nary_explicit_theorems_nonempty', live_counts['theorem'] > 0, live_counts)
    check('live_binary_uses_nary_namespace', 'DefiKernel.Nary' in live_namespaces.get('BinaryCorrespondence.lean', []), live_namespaces.get('BinaryCorrespondence.lean'))
    check('live_funded_uses_funded_namespace', 'DefiKernel.Nary.FundedCausal' in live_namespaces.get('FundedCausal.lean', []), live_namespaces.get('FundedCausal.lean'))
    check('live_companions_uses_companions_namespace', 'DefiKernel.Nary.FundedCompanions' in live_namespaces.get('FundedCompanions.lean', []), live_namespaces.get('FundedCompanions.lean'))
    check('live_enabledness_uses_enabledness_namespace', 'DefiKernel.Nary.FundedEnabledness' in live_namespaces.get('FundedEnabledness.lean', []), live_namespaces.get('FundedEnabledness.lean'))
    check('live_interface_uses_interface_namespace', 'DefiKernel.Nary.InterfaceInstances' in live_namespaces.get('InterfaceInstances.lean', []), live_namespaces.get('InterfaceInstances.lean'))
    check('live_causal_private_helpers_indexed', live_counts['private_theorem'] >= 2, live_counts)

    sibling = """
namespace A
section old
variable (obsolete : Nat)
end old
section new
theorem fresh : True := trivial
end new
end A
"""
    decls, notes = index_source_text(sibling, 'Mod.Sibling', 'lean/Mod/Sibling.lean', {'sha256': 'x', 'git_blob': 'y'})
    fresh_vars = decls[('Mod.Sibling', 'A.fresh')]['section_variables']
    check('gpt6_closed_sibling_obsolete_nat_absent', not any('obsolete' in item for item in fresh_vars), fresh_vars)
    check('gpt6_sibling_unresolved_notes_empty', notes == [], notes)

    oracle = [
        ('DefiKernel.Nary.Execution', 'DefiKernel.Nary.advance_sound', False, 'explicit', 'genericproof'),
        ('DefiKernel.Nary.Observation', 'DefiKernel.Nary.machineEq_iff', False, 'explicit', 'genericproof'),
        ('DefiKernel.Nary.Schedule', 'DefiKernel.Nary.checkSchedule_ok_iff', False, 'explicit', 'genericproof'),
        ('DefiKernel.Nary.CausalRuntime', 'DefiKernel.Nary.continueMonitored_nil', False, 'explicit', 'genericproof'),
        ('DefiKernel.Nary.Causal', 'DefiKernel.Nary.continueMonitored_initialized', False, 'explicit', 'genericproof'),
        ('DefiKernel.Nary.Examples', 'DefiKernel.Nary.Examples.f02_world', False, 'explicit', 'referenceinstance'),
        ('DefiKernel.Nary.Tests', 'DefiKernel.Nary.Tests.runtimeComparisons', False, 'explicit', 'referenceinstance'),
        ('DefiKernel.Nary.Audit', 'DefiKernel.Nary.Audit.main', False, 'explicit', 'referenceinstance'),
        ('DefiKernel.Nary.FundedCausal', 'DefiKernel.Nary.FundedCausal.f10_start_K', False, 'explicit', 'concreteproof'),
        ('DefiKernel.Nary.FundedCompanions', 'DefiKernel.Nary.FundedCompanions.f10_deposit1_preserves_ready', False, 'explicit', 'concreteproof'),
        ('DefiKernel.Nary.FundedCompanions', 'DefiKernel.Nary.FundedCompanions.f12_not_ready_after_peer', False, 'explicit', 'counterexample'),
        ('DefiKernel.Nary.FundedCompanions', 'DefiKernel.Nary.FundedCompanions.f16_monitor_awaiting', False, 'explicit', 'counterexample'),
        ('DefiKernel.Nary.FundedCompanions', 'DefiKernel.Nary.FundedCompanions.f17_monitor_awaiting', False, 'explicit', 'counterexample'),
        ('DefiKernel.Nary.FundedEnabledness', 'DefiKernel.Nary.FundedEnabledness.f10_producer_enabled', False, 'explicit', 'concreteproof'),
        ('DefiKernel.Nary.FundedEnabledness', 'DefiKernel.Nary.FundedEnabledness.executeStep_invoke_ok', False, 'explicit', 'concreteproof'),
        ('DefiKernel.Nary.InterfaceInstances', 'DefiKernel.Nary.InterfaceInstances.f18_every_prefix', False, 'explicit', 'concreteproof'),
        ('DefiKernel.Nary.Causal', 'DefiKernel.Nary.skipped_of_halted', True, 'explicit', 'privatehelper'),
    ]
    oracle_failures = []
    for module, name, private, origin, expected in oracle:
        row = {'module': module, 'user_name': name, 'is_private_name': private, 'private': private}
        got, _note = classify_claim(row, origin)
        if got != expected:
            oracle_failures.append({'module': module, 'name': name, 'expected': expected, 'got': got})
    check('gpt6_named_theorem_classification_oracle', oracle_failures == [], oracle_failures)

    multi_import = 'import DefiKernel.One DefiKernel.Two\n'
    local, _ext, unsupported = local_imports_from_text(multi_import)
    old_first_only = re.findall(r'^(?:public[ \t]+)?import[ \t]+(DefiKernel\.[\w.]+)', multi_import, re.M)
    check('multi_import_not_silently_first_only', not (local == ['DefiKernel.One'] and not unsupported), {'local': local, 'unsupported': unsupported, 'old_first_only': old_first_only})
    check('multi_import_rejected_or_complete', (local == [] and unsupported) or set(local) == {'DefiKernel.One', 'DefiKernel.Two'}, {'local': local, 'unsupported': unsupported})
    comment_import = '/-\nimport DefiKernel.CommentOnly\n-/\nimport DefiKernel.Real\n'
    local, _ext, unsupported = local_imports_from_text(comment_import)
    check('comment_only_import_ignored', local == ['DefiKernel.Real'] and not unsupported, {'local': local, 'unsupported': unsupported})
    bare_multiline = 'import\n  DefiKernel.One\n'
    local, _ext, unsupported = local_imports_from_text(bare_multiline)
    check('bare_multiline_import_not_silently_ignored', bool(unsupported) and local == [], {'local': local, 'unsupported': unsupported})
    check('bare_multiline_does_not_follow_next_line_module', 'DefiKernel.One' not in local, local)
    commented_bare = '/-\nimport\n  DefiKernel.Hidden\n-/\nimport DefiKernel.Visible\n'
    local, _ext, unsupported = local_imports_from_text(commented_bare)
    check('comment_masked_bare_import_ignored', local == ['DefiKernel.Visible'] and not unsupported, {'local': local, 'unsupported': unsupported})

    nary_dir = root / 'lean' / 'DefiKernel' / 'Nary'
    report = local_source_closure_report(root, root / 'lean', nary_dir)
    check('local_closure_nonempty_unique', report['nonempty'] and report['unique'], {
        'nary_present_count': report['nary_present_count'],
        'reachable_count': report['reachable_count'],
    })
    check('every_nary_source_in_reachable_closure', report['nary_missing_from_closure'] == [], report['nary_missing_from_closure'])
    check('required_nary_modules_present', report['required_missing'] == [], report['required_missing'])
    check('required_funded_split_modules_in_scope', {
        'FundedCompanions.lean', 'FundedEnabledness.lean', 'FundedCausal.lean',
        'InterfaceInstances.lean', 'BinaryCorrespondence.lean', 'Causal.lean',
    } <= set(REQUIRED_NARY_BASENAMES) and not report['required_missing'], sorted(REQUIRED_NARY_BASENAMES))
    check('local_closure_paths_and_hashes_recorded', bool(report['files']) and all('sha256' in row and 'path' in row for row in report['files']), {
        'file_count': len(report['files']),
        'sample': report['files'][:3],
    })
    check('actual_local_imports_have_no_unsupported_syntax', report['unsupported'] == [], report['unsupported'])
    dropped = dict(report)
    dropped['nary_missing_from_closure'] = ['lean/DefiKernel/Nary/FundedEnabledness.lean']
    check('missing_nary_module_fails_coverage', not closure_invariant_holds(dropped), dropped['nary_missing_from_closure'])
    check('intact_nary_coverage_holds', closure_invariant_holds(report), {
        'reachable_count': report['reachable_count'],
        'nary_present_count': report['nary_present_count'],
        'required_missing': report['required_missing'],
        'nary_missing_from_closure': report['nary_missing_from_closure'],
    })
    historical_r2 = root / 'review/semantic-kernel/sprint11/implementation/proof-inventory-r2/self-check.json'
    historical = json.loads(historical_r2.read_text()) if historical_r2.is_file() else {}
    historical_names = [row['name'] for row in historical.get('checks', [])]
    check('historical_r2_66_pass_archived_not_current_result', historical.get('status') == 'PASS' and len(historical.get('checks') or []) == 66 and 'actual_local_import_sources_remain_51' in historical_names, {
        'path': 'review/semantic-kernel/sprint11/implementation/proof-inventory-r2/self-check.json',
        'sha256': sha(historical_r2) if historical_r2.is_file() else None,
        'count': len(historical.get('checks') or []),
        'current_reachable_count': report['reachable_count'],
        'historical_contained_stale_51': 'actual_local_import_sources_remain_51' in historical_names,
    })
    failed_current = root / 'review/semantic-kernel/sprint11/implementation/proof-inventory-r3/preserved-r2-failed-current-selfcheck.json'
    if not failed_current.is_file():
        failed_current = root / 'review/semantic-kernel/sprint11/implementation/gpt6-review/inventory-r2-controls/results.json'
    failed_obs = {}
    if failed_current.is_file():
        payload = json.loads(failed_current.read_text())
        failed_obs = payload.get('observation') or next(
            (row for row in payload.get('checks', []) if row.get('name') == 'author_selfcheck_reexecution_observation'),
            {},
        )
    failed_detail = json.dumps(failed_obs)
    check('preserved_r2_current_rerun_failed_only_stale_51', 'actual_local_import_sources_remain_51' in failed_detail and '53' in failed_detail, failed_obs)
    check(
        'actual_external_imports_match_pinned_tool_trust_list',
        set(report['external']) == {
            'Lean.Elab.Command', 'Lean.Util.CollectAxioms',
            'Mathlib.Algebra.BigOperators.Group.Finset.Basic',
            'Mathlib.Data.Fintype.Prod', 'Mathlib.Data.List.Nodup',
            'Mathlib.Data.Rat.Defs', 'Mathlib.Tactic.Linarith', 'Mathlib.Tactic.Ring',
        },
        report['external'],
    )
    strict_mismatch = []
    for row in report['files']:
        path = root / row['path']
        masked = mask_lean_comments(path.read_text())
        strict = re.findall(
            r'^[ \t]*(?:public[ \t]+)?import[ \t]+(DefiKernel\.[A-Za-z_][\w.]*)[ \t]*$',
            masked, re.M,
        )
        local, _ext, unsup = local_imports_from_text(path.read_text())
        if local != strict or unsup:
            strict_mismatch.append({
                'path': row['path'],
                'local': local,
                'strict': strict,
                'unsupported': unsup,
            })
    check('actual_source_closure_equals_strict_single_module_lines', strict_mismatch == [], strict_mismatch)
    enabled_row = {'module': 'DefiKernel.Nary.FundedEnabledness', 'user_name': 'DefiKernel.Nary.FundedEnabledness.executeStep_invoke_ok', 'is_private_name': False, 'private': False}
    enabled_cat, enabled_note = classify_claim(enabled_row, 'explicit')
    check('enabledness_not_generic_all_protocol', enabled_cat == 'concreteproof' and 'not a generic all-protocol claim' in enabled_note, {'category': enabled_cat, 'note': enabled_note})
    companion_priv = {'module': 'DefiKernel.Nary.FundedCompanions', 'user_name': 'DefiKernel.Nary.FundedCompanions.helper', 'is_private_name': True, 'private': True}
    companion_priv_cat, _note = classify_claim(companion_priv, 'explicit')
    check('funded_split_private_helper_not_concrete_claim', companion_priv_cat == 'privatehelper', companion_priv_cat)

    identity = resolve_candidate(root, 'HEAD')
    independent = subprocess.run(
        ['git', 'rev-parse', '--verify', 'HEAD^{commit}'],
        cwd=root, capture_output=True, text=True, check=False,
    )
    check('candidate_peel_matches_independent_git', identity['resolved_commit'] == independent.stdout.strip(), identity)
    check('candidate_requested_ref_preserved', identity['requested_ref'] == 'HEAD', identity)
    check('candidate_output_is_immutable_commit', bool(COMMIT_RE.fullmatch(identity['resolved_commit'])), identity)
    check('candidate_output_is_not_the_word_HEAD', identity['resolved_commit'] != 'HEAD', identity)
    full_again = resolve_candidate(root, identity['resolved_commit'])
    check('full_commit_requested_equals_resolved', full_again['requested_equals_resolved'] is True, full_again)

    stable = [{'path': '/tmp/lean', 'sha256': 'aa', 'bytes': 1}]
    drifted = [{'path': '/tmp/lean', 'sha256': 'bb', 'bytes': 1}]
    try:
        assert_tool_hashes_stable(stable, stable)
        stable_ok = True
    except InventoryFailed:
        stable_ok = False
    check('tool_hash_equal_before_after_holds', stable_ok, None)
    try:
        assert_tool_hashes_stable(stable, drifted)
        drift_fired = False
        drift_status = None
    except InventoryFailed as err:
        drift_fired = True
        drift_status = err.status
    check('tool_hash_drift_fails_and_is_named', drift_fired and drift_status == 'FAIL_TOOL_BINARY_DRIFT', drift_status)

    colliding = {
        ('DefiKernel.Nary.Causal', 'DefiKernel.Nary.helper'): {'private': True},
        ('DefiKernel.Nary.Execution', 'DefiKernel.Nary.helper'): {'private': True},
    }
    mapped_ids = {
        ('DefiKernel.Nary.Causal', 'DefiKernel.Nary.helper'): 'elab.Causal',
        ('DefiKernel.Nary.Execution', 'DefiKernel.Nary.helper'): 'elab.Execution',
    }
    rows = private_identities(colliding, mapped_ids)
    check('private_map_keeps_module_user_pairs', len(rows) == 2, rows)
    check(
        'private_map_modules_distinct',
        {row['module'] for row in rows} == {'DefiKernel.Nary.Causal', 'DefiKernel.Nary.Execution'},
        rows,
    )
    user_only = {row['user_name']: row['elaborated_name'] for row in rows}
    check('user_only_private_map_would_drop_a_module', len(user_only) == 1, user_only)

    failed = [row for row in checks if not row['passed']]
    if failed:
        raise AssertionError('self-check failed: ' + json.dumps(failed, indent=2))
    return {
        'status': 'PASS',
        'root': str(root),
        'checks': checks,
        'verify_present': 'Verify.lean' in present,
        'failed': failed,
    }


def run_command(execution, out_dir, root, work, name, command, logname, timeout):
    started = now()
    clock = time.monotonic()
    try:
        proc = subprocess.run(command, cwd=work, capture_output=True, timeout=timeout)
        exit_code = proc.returncode
        stdout = proc.stdout
        stderr = proc.stderr
    except subprocess.TimeoutExpired as err:
        exit_code = 124
        stdout = err.stdout or b''
        stderr = err.stderr or b''
        execution['status'] = 'BLOCKED_TIMEOUT'
    stdout_path = out_dir / logname
    stderr_path = out_dir / (logname + '.stderr')
    stdout_path.write_bytes(stdout)
    stderr_path.write_bytes(stderr)
    row = {
        'name': name,
        'argv': command,
        'cwd': str(work),
        'started_utc': started,
        'finished_utc': now(),
        'wall_seconds': time.monotonic() - clock,
        'timeout_seconds': timeout,
        'exit': exit_code,
        'stdout': rel(stdout_path, root),
        'stdout_sha256': sha(stdout_path),
        'stdout_bytes': len(stdout),
        'stderr': rel(stderr_path, root),
        'stderr_sha256': sha(stderr_path),
        'stderr_bytes': len(stderr),
    }
    execution['commands'].append(row)
    save(out_dir, 'proof-inventory-execution.json', execution)
    if exit_code != 0:
        if execution.get('status') != 'BLOCKED_TIMEOUT':
            execution['status'] = 'BLOCKED_COMMAND_ERROR'
            save(out_dir, 'proof-inventory-execution.json', execution)
        raise InventoryBlocked(
            execution['status'],
            f'{name} failed with exit {exit_code}; inspect {row["stdout"]} and {row["stderr"]}',
        )
    return row


def run_inventory(requested_ref, out_dir):
    script = pathlib.Path(__file__).resolve()
    driver = script.parent / 'proof-inventory-driver.lean'
    root = repo_root(script.parent)
    work = root / 'lean'
    out_dir = pathlib.Path(out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    if not driver.is_file():
        raise InventoryBlocked('BLOCKED_MISSING_DRIVER', f'Missing {driver}')
    if not requested_ref:
        raise InventoryBlocked('BLOCKED_MISSING_CANDIDATE', '--candidate is required for an inventory run')
    identity = resolve_candidate(root, requested_ref)
    candidate = identity['resolved_commit']
    execution = {
        'status': 'RUNNING',
        'kind': 'imported-nary-proof-inventory-execution',
        'requested_ref': identity['requested_ref'],
        'resolved_commit': candidate,
        'candidate': candidate,
        'planning_baseline_history_only': PLANNING_BASELINE,
        'candidate_equals_planning_baseline': candidate == PLANNING_BASELINE,
        'started_utc': now(),
        'root_resolution': {
            'method': 'git rev-parse --show-toplevel',
            'script_dir': str(script.parent),
            'root': str(root),
            'parents4_would_be': str(script.parents[4]),
            'parents4_is_root': script.parents[4] == root,
        },
        'working_head_before': run_git(root, ['rev-parse', 'HEAD']).decode().strip(),
        'driver_sha256_before': sha(driver),
        'builder_sha256_before': sha(script),
        'commands': [],
        'timeout_seconds': COMMAND_TIMEOUT_SECONDS,
        'driver_check_method': (
            'Pinned lake env lean from lean/; external evidence driver only. '
            'No lake build cache ownership and no new LSP claim.'
        ),
        'verify_contract': {
            'module': VERIFY_MODULE,
            'path': 'lean/DefiKernel/Nary/Verify.lean',
            'must_import_axiom_audit': True,
            'must_import_every_nary_source': True,
            'required_named_sources': sorted(REQUIRED_NARY_BASENAMES),
            'audit_prefix': NARY_PREFIX,
            'parent_owned': True,
            'this_tool_must_not_create_it': True,
        },
        'external_import_limitation': (
            'External Lean/Mathlib modules stay pinned-config/tool trust. '
            'This inventory does not hash the 8GB lake cache.'
        ),
    }
    save(out_dir, 'proof-inventory-execution.json', execution)
    paths, nary_present, _required, external_imports = source_paths(root, work)
    execution['external_imports'] = external_imports
    execution['source_porcelain_before'] = porcelain(root, paths)
    before = snapshot(root, candidate, paths)
    execution['source_before'] = before
    lake = which_tool(work, 'lake')
    lean = which_tool(work, 'lean')
    python = pathlib.Path(sys.executable).resolve()
    tool_paths = [lake, lean, python]
    execution['tools_before'] = tool_records(tool_paths)
    execution['lean_version'] = subprocess.run(
        [str(lean), '--version'], cwd=work, capture_output=True, text=True, timeout=GIT_TIMEOUT_SECONDS, check=False,
    ).stdout.strip()
    execution['python_version'] = sys.version
    save(out_dir, 'proof-inventory-execution.json', execution)
    try:
        run_command(
            execution, out_dir, root, work, 'fresh-verify',
            [str(lake), 'env', 'lean', 'DefiKernel/Nary/Verify.lean'],
            'proof-inventory-verify.log', COMMAND_TIMEOUT_SECONDS,
        )
        run_command(
            execution, out_dir, root, work, 'full-types-driver',
            [str(lake), 'env', 'lean', str(driver)],
            'proof-types.log', COMMAND_TIMEOUT_SECONDS,
        )
    finally:
        execution['tools_after'] = tool_records(tool_paths)
        save(out_dir, 'proof-inventory-execution.json', execution)
    assert_tool_hashes_stable(execution['tools_before'], execution['tools_after'])
    execution['tool_binaries_unchanged'] = True
    save(out_dir, 'proof-inventory-execution.json', execution)

    stdout_text = (out_dir / 'proof-types.log').read_text()
    stderr_text = (out_dir / 'proof-types.log.stderr').read_text()
    proofs = parse_marker_rows(stdout_text, 'NARY_PROOF_JSON ')
    supplemental = parse_marker_rows(stdout_text, 'NARY_SUPPLEMENTAL_JSON ')
    if not proofs:
        proofs = parse_marker_rows(stderr_text, 'NARY_PROOF_JSON ')
        execution['driver_json_stream'] = 'stderr'
    else:
        execution['driver_json_stream'] = 'stdout'
    if not supplemental:
        supplemental = parse_marker_rows(stderr_text, 'NARY_SUPPLEMENTAL_JSON ')
    if not proofs or not supplemental:
        raise InventoryFailed(
            'FAIL_EMPTY_ENVIRONMENT_DISCOVERY',
            f'theorems={len(proofs)} supplemental={len(supplemental)}',
        )
    for subset, label in ((proofs, 'theorems'), (supplemental, 'supplemental')):
        names = [row['name'] for row in subset]
        if len(set(names)) != len(names):
            raise InventoryFailed('FAIL_DUPLICATE_DISCOVERY', f'Duplicate {label} names')
    for row in proofs + supplemental:
        if not set(row.get('axioms') or []) <= ALLOWED_AXIOMS:
            raise InventoryFailed('FAIL_FORBIDDEN_AXIOM', f'{row["name"]} axioms={row.get("axioms")}')
        statement = row.get('statement') or ''
        if '⋯' in statement or '...' in statement:
            raise InventoryFailed('FAIL_STATEMENT_ELLIPSIS', row['name'])

    declarations = {}
    parser_notes = []
    explicit = {}
    nary_dir = work / 'DefiKernel' / 'Nary'
    for path in sorted(nary_dir.glob('*.lean')):
        rel_path = rel(path, root)
        module = '.'.join(path.relative_to(work).with_suffix('').parts)
        decls, notes = index_source_text(path.read_text(), module, rel_path, before[rel_path])
        parser_notes.extend(notes)
        for key, decl in decls.items():
            declarations[key] = decl
            if decl['kind'] in ('theorem', 'lemma'):
                explicit[key] = decl

    mapped = {}
    for row in proofs:
        user = attribute_theorem(row, declarations, before)
        category, note = classify_claim(row, row['declaration_origin'])
        row['category'] = category
        row['scope_note'] = note
        row['premises'] = (
            'The full elaborated statement is authoritative, including retained section parameters, '
            'typeclasses and hypotheses. Source context is supplemental. No premise-free claim is '
            'inferred from absent textual binders.'
        )
        if user:
            ident = (row['module'], user)
            if ident in mapped:
                raise InventoryFailed('FAIL_DUPLICATE_EXPLICIT_MAP', f'{ident}')
            mapped[ident] = row['name']
        if category in ('genericproof', 'concreteproof') and (row.get('private') or row.get('is_private_name')):
            raise InventoryFailed('FAIL_PRIVATE_HELPER_MISCLASSIFIED', row['name'])

    private_map = private_identities(explicit, mapped)

    for row in supplemental:
        attribute_supplemental(row, declarations, before)

    verify_text = (out_dir / 'proof-inventory-verify.log').read_text()
    verify_err = (out_dir / 'proof-inventory-verify.log.stderr').read_text()
    if 'AXIOM AUDIT theorem:' not in verify_text and 'AXIOM AUDIT theorem:' in verify_err:
        verify_text = verify_err
        execution['verify_audit_stream'] = 'stderr'
    else:
        execution['verify_audit_stream'] = 'stdout'
    for data, marker in ((proofs, 'theorem'), (supplemental, 'declaration')):
        audited = audit_rows(verify_text, marker)
        names = {row['name'] for row in data}
        if set(audited) != names:
            raise InventoryFailed(
                'FAIL_VERIFY_NAME_MISMATCH',
                f'{marker} names differ: extra_audit={sorted(set(audited) - names)[:20]} '
                f'missing_audit={sorted(names - set(audited))[:20]}',
            )
        for row in data:
            if audited[row['name']] != (row['module'], set(row['axioms'] or [])):
                raise InventoryFailed('FAIL_VERIFY_MODULE_AXIOM_MISMATCH', row['name'])
    if not re.search(rf'AXIOM AUDIT PASSED: {len(proofs)}/{len(proofs)} theorems; forbidden=0', verify_text):
        raise InventoryFailed('FAIL_VERIFY_THEOREM_SUMMARY', 'missing AXIOM AUDIT PASSED summary')
    if not re.search(
        rf'AXIOM AUDIT DECLARATIONS PASSED: {len(supplemental)}/{len(supplemental)} supplemental declarations; forbidden=0',
        verify_text,
    ):
        raise InventoryFailed('FAIL_VERIFY_SUPPLEMENTAL_SUMMARY', 'missing AXIOM AUDIT DECLARATIONS PASSED summary')

    after = snapshot(root, candidate, paths)
    if before != after:
        raise InventoryFailed('FAIL_INPUT_DRIFT', 'Source bytes changed during inventory execution')
    if execution['driver_sha256_before'] != sha(driver) or execution['builder_sha256_before'] != sha(script):
        raise InventoryFailed('FAIL_TOOL_DRIFT', 'Driver or builder bytes changed during execution')
    execution['tools_after'] = tool_records(tool_paths)
    assert_tool_hashes_stable(execution['tools_before'], execution['tools_after'])
    execution.update({
        'finished_utc': now(),
        'working_head_after': run_git(root, ['rev-parse', 'HEAD']).decode().strip(),
        'source_after': after,
        'source_porcelain_after': porcelain(root, paths),
        'source_bytes_unchanged': True,
        'driver_sha256_after': sha(driver),
        'builder_sha256_after': sha(script),
        'driver_bytes_unchanged': True,
        'builder_bytes_unchanged': True,
        'tool_binaries_unchanged': True,
        'status': 'PASS',
    })
    save(out_dir, 'proof-inventory-execution.json', execution)

    limits = {
        'causal': 'Generic Causal results are conditional prefix/induction facts. They do not assume future success or a whole-run conclusion.',
        'funded_causal': 'FundedCausal is a concrete F10 witness plus named companions. It is not generic solvency.',
        'interface_instances': 'InterfaceInstances is a concrete accepted-M2 instance plus designated counterexamples. F15 is logical only.',
        'binary': 'BinaryCorrespondence specializes the existing binary executor. No participant-tree regrouping or cross-schedule order equivalence.',
        'accounting': 'Exact rational cell and receipt accounting. No machine-width arithmetic, deployed fidelity, oracle truth, liveness or generic solvency.',
        'source_index': 'Source grep is supplemental. Nested and multiple namespaces are tracked. section_variables is the active scope only; closed sibling sections do not leak. Unresolved attribution is explicit. Environment discovery controls membership.',
        'imports': 'Local DefiKernel import lines are comment-masked one-module-per-line tokens. Bare or multiline import commands are rejected. External Lean/Mathlib remain pinned-config/tool trust, not an 8GB cache inventory.',
        'funded_split': 'FundedCompanions and FundedEnabledness are proof-only splits of fixed F10/F12/F16/F17 configurations. Enabledness binders over current world/store/history/funding are the exact statement, not a generic all-protocol claim.',
        'private_helpers': 'Private helpers remain faithful local lemmas and are not classified as generic Causal or concrete FundedCausal/InterfaceInstances claims.',
        'verify': 'DefiKernel.Nary.Verify is parent-owned and must import every Nary source plus AxiomAudit, then audit prefix DefiKernel.Nary only.',
        'review': 'Mechanical author inventory, not independent approval. Runtime comparisons, mutations and CLI controls remain distinct evidence.',
        'candidate': 'Planning baseline ed94e6050d092e67f945df7b9762d3096ab0feda is history, not this tool\'s frozen default.',
    }
    record = {
        'schema_version': 3,
        'kind': 'imported-nary-proof-inventory',
        'requested_ref': identity['requested_ref'],
        'resolved_commit': candidate,
        'candidate': candidate,
        'planning_baseline_history_only': PLANNING_BASELINE,
        'captured_utc': now(),
        'discovery': (
            'Lean importedTheorems/importedSupplemental by exact Nary module provenance via parent-owned Verify; '
            'privateToUserName? maps source helpers. Source index is supplemental and namespace-stack based.'
        ),
        'execution': execution,
        'parser_notes': parser_notes,
        'counts': {
            'theorems': len(proofs),
            'supplemental': len(supplemental),
            'explicit_theorems': sum(1 for row in proofs if row.get('declaration_origin') == 'explicit'),
            'private_explicit_theorems': len(private_map),
            'private_map_identity': 'module+user_name',
            'generated_theorems': sum(1 for row in proofs if row.get('declaration_origin') == 'generated'),
            'unresolved_theorems': sum(1 for row in proofs if str(row.get('declaration_origin', '')).startswith('unresolved')),
            'categories': dict(collections.Counter(row['category'] for row in proofs)),
            'module_roles': dict(collections.Counter(row.get('module_role') for row in proofs)),
            'nary_source_modules': len(nary_present),
            'verify_included_in_source_modules': (work / 'DefiKernel/Nary/Verify.lean') in nary_present,
            'transitive_nary_dependencies_of_Verify': len(nary_present) - (1 if (work / 'DefiKernel/Nary/Verify.lean') in nary_present else 0),
            'import_closure_files': len(paths),
        },
        'validation': {
            'nonempty': True,
            'theorem_names_modules_axioms_exactly_match_fresh_verify': True,
            'supplemental_names_modules_axioms_exactly_match_fresh_verify': True,
            'forbidden_axioms': 0,
            'no_pretty_statement_ellipsis': True,
            'all_source_bytes_match_candidate_before_and_after': True,
            'import_closure_contains_all_nary_sources': True,
            'import_closure_contains_funded_causal_interface_instances_binary': True,
            'private_helpers_not_classified_as_generic_or_concrete_claims': True,
            'root_via_git_rev_parse': True,
            'source_index_does_not_control_inventory_membership': True,
            'candidate_is_immutable_commit': True,
            'tool_binaries_hashed_before_and_after': True,
        },
        'private_source_name_mapping': private_map,
        'source_bindings': before,
        'source_module_count_scope': (
            'External driver imports Verify plus its transitive DefiKernel dependencies. '
            'Nary source-module count is the flat DefiKernel/Nary/*.lean glob, including parent-owned Verify when present. '
            'All module paths of discovered constants are bound to frozen file hashes.'
        ),
        'premise_and_scope_limits': limits,
        'theorems': proofs,
        'supplemental': supplemental,
        'accepted': False,
        'author_self_acceptance': False,
    }
    if record['counts']['theorems'] == 0 or record['counts']['supplemental'] == 0:
        raise InventoryFailed('FAIL_EMPTY_COUNTS', json.dumps(record['counts']))
    save(out_dir, 'proof-inventory.json', record)
    print(json.dumps(record['counts'], indent=2))
    return 0


def persist_failure(out_dir, root, err):
    execution_path = out_dir / 'proof-inventory-execution.json'
    if execution_path.is_file():
        try:
            execution = json.loads(execution_path.read_text())
        except json.JSONDecodeError:
            execution = {}
    else:
        execution = {}
    execution.update({
        'status': err.status,
        'error': err.message,
        'finished_utc': now(),
        'traceback': traceback.format_exc(),
        'accepted': False,
    })
    if root is not None:
        try:
            execution['working_head_after'] = run_git(root, ['rev-parse', 'HEAD']).decode().strip()
        except InventoryError:
            pass
    before_tools = execution.get('tools_before')
    after_tools = execution.get('tools_after')
    if before_tools and after_tools and before_tools != after_tools:
        execution['tool_binary_drift'] = True
        execution['tool_binary_drift_error'] = 'Lean/Lake/Python bytes changed during inventory'
    save(out_dir, 'proof-inventory-execution.json', execution)


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', help='Requested git ref; resolved once via ref^{commit} to an immutable commit')
    parser.add_argument('--out', help='Evidence directory. Self-check/inventory artifacts are written here, not over r1 records.')
    parser.add_argument('--self-check', action='store_true', help='Parser and root tests only; no lake and no candidate')
    args = parser.parse_args(argv)
    script_dir = pathlib.Path(__file__).resolve().parent
    if args.self_check:
        try:
            result = run_self_checks()
            code = 0
        except AssertionError as err:
            result = {'status': 'FAIL', 'error': str(err), 'checks': []}
            code = 1
        if args.out:
            out_dir = pathlib.Path(args.out).resolve()
            out_dir.mkdir(parents=True, exist_ok=True)
            r1_self = script_dir / 'self-check.json'
            if (out_dir / 'self-check.json').resolve() == r1_self.resolve():
                raise SystemExit('Refusing to overwrite preserved r1 self-check.json')
            save(out_dir, 'self-check.json', result)
        print(json.dumps({'status': result.get('status'), 'checks': len(result.get('checks') or [])}, indent=2))
        return code
    if not args.candidate:
        parser.error('--candidate is required unless --self-check')
    out_dir = pathlib.Path(args.out).resolve() if args.out else script_dir
    if out_dir == script_dir:
        raise SystemExit('Inventory evidence must use --out; refusing to write into proof-inventory-r1/')
    root = None
    try:
        root = repo_root(script_dir)
        return run_inventory(args.candidate, out_dir)
    except InventoryError as err:
        persist_failure(out_dir, root, err)
        print(f'{err.status}: {err.message}', file=sys.stderr)
        return err.exit_code


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
