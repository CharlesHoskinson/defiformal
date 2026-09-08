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
RUNTIME_EXECUTABLE_MODULES = {
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
IMPORT_RE = re.compile(r'^(?:public[ \t]+)?import[ \t]+(DefiKernel\.[\w.]+)', re.M)


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
    parts = [name for kind, name in stack if kind == 'ns' and name]
    return '.'.join(parts)


def close_end(stack, name):
    if not stack:
        return False
    if name is None:
        stack.pop()
        return True
    parts = name.split('.')
    if len(stack) < len(parts):
        return False
    inner = [frame[1] for frame in stack[-len(parts):]]
    if inner != parts:
        return False
    del stack[-len(parts):]
    return True


def extract_statement(original, start, kind):
    tail = original[start:]
    if kind in ('theorem', 'lemma'):
        return tail.split(':=', 1)[0].strip()
    return tail.split('\n\n', 1)[0].strip()


def index_source_text(original, module, rel_path, source_meta):
    """Walk namespace/section stacks. Multiple and nested namespaces are allowed."""
    masked = mask_lean_comments(original)
    stack = []
    variables = []
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
                stack.append(('ns', part))
            continue
        if kind == 'section':
            stack.append(('section', payload))
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
            variables.append((tuple(stack), payload, current_namespace(stack)))
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
            'namespace_stack': [list(frame) for frame in stack],
            'module': module,
            'source': rel_path,
            'line': line,
            'source_statement': extract_statement(original, kind_start, decl_kind),
            'section_variables': [text for frames, text, _ns in variables if len(frames) <= len(stack)],
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
            'stack': [list(frame) for frame in stack],
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
    if module == 'DefiKernel.Nary.FundedCausal':
        return 'funded_causal_concrete'
    if module == 'DefiKernel.Nary.InterfaceInstances':
        return 'interface_instances_concrete'
    if module == 'DefiKernel.Nary.BinaryCorrespondence':
        return 'binary_specialization'
    if module in GENERIC_SUPPORT_MODULES:
        return 'generic_support'
    if module in RUNTIME_EXECUTABLE_MODULES:
        return 'runtime_executable'
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
    if role == 'causal_generic':
        return (
            'genericproof',
            'Generic Causal claim over arbitrary machines and schedules. Not a concrete funded witness.',
        )
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
    if role == 'binary_specialization':
        return (
            'genericproof',
            'Generic binary specialization against the existing executor. No participant-tree regrouping claim.',
        )
    if role == 'generic_support':
        return (
            'genericproof',
            'Generic Nary support lemma. Distinct from the Causal generic rule and from FundedCausal/InterfaceInstances concrete claims.',
        )
    if role in ('runtime_executable', 'runtime_reference'):
        return (
            'referenceinstance',
            'Runtime or fixture declaration. Development instance, not a holdout or universal economic claim.',
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
    while pending:
        module = pending.pop()
        path = work / (module.replace('.', '/') + '.lean')
        if path in found:
            continue
        if not path.is_file():
            raise InventoryBlocked('BLOCKED_MISSING_IMPORT', f'Import path is not a file: {path}')
        found.add(path)
        for imported in IMPORT_RE.findall(path.read_text()):
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
    return sorted(found | config), present, required_paths


def snapshot(root, candidate, paths):
    rows = {}
    for path in paths:
        rel_path = rel(path, root)
        frozen = run_git(root, ['show', f'{candidate}:{rel_path}'])
        working = path.read_bytes()
        if frozen != working:
            raise InventoryFailed(
                'FAIL_CANDIDATE_SOURCE_DRIFT',
                f'Working tree bytes differ from {candidate}:{rel_path}',
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
    check('live_interface_uses_interface_namespace', 'DefiKernel.Nary.InterfaceInstances' in live_namespaces.get('InterfaceInstances.lean', []), live_namespaces.get('InterfaceInstances.lean'))
    check('live_causal_private_helpers_indexed', live_counts['private_theorem'] >= 2, live_counts)
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


def run_inventory(candidate):
    script = pathlib.Path(__file__).resolve()
    out_dir = script.parent
    driver = out_dir / 'proof-inventory-driver.lean'
    root = repo_root(out_dir)
    work = root / 'lean'
    if not driver.is_file():
        raise InventoryBlocked('BLOCKED_MISSING_DRIVER', f'Missing {driver}')
    if not candidate:
        raise InventoryBlocked('BLOCKED_MISSING_CANDIDATE', '--candidate is required for an inventory run')
    execution = {
        'status': 'RUNNING',
        'kind': 'imported-nary-proof-inventory-execution',
        'candidate': candidate,
        'planning_baseline_history_only': PLANNING_BASELINE,
        'candidate_equals_planning_baseline': candidate == PLANNING_BASELINE,
        'started_utc': now(),
        'root_resolution': {
            'method': 'git rev-parse --show-toplevel',
            'script_dir': str(out_dir),
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
    }
    save(out_dir, 'proof-inventory-execution.json', execution)
    paths, nary_present, _required = source_paths(root, work)
    execution['source_porcelain_before'] = porcelain(root, paths)
    before = snapshot(root, candidate, paths)
    execution['source_before'] = before
    lake = which_tool(work, 'lake')
    lean = which_tool(work, 'lean')
    python = pathlib.Path(sys.executable).resolve()
    execution['tools'] = [{'path': str(path), 'sha256': sha(path)} for path in (lake, lean, python)]
    execution['lean_version'] = subprocess.run(
        [str(lean), '--version'], cwd=work, capture_output=True, text=True, timeout=GIT_TIMEOUT_SECONDS, check=False,
    ).stdout.strip()
    execution['python_version'] = sys.version
    save(out_dir, 'proof-inventory-execution.json', execution)

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
            if user in mapped:
                raise InventoryFailed('FAIL_DUPLICATE_EXPLICIT_MAP', user)
            mapped[user] = row['name']
        if category in ('genericproof', 'concreteproof') and (row.get('private') or row.get('is_private_name')):
            raise InventoryFailed('FAIL_PRIVATE_HELPER_MISCLASSIFIED', row['name'])

    private_map = {}
    for (_module, full), decl in explicit.items():
        if decl['private'] and full in mapped:
            private_map[full] = mapped[full]

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
        'status': 'PASS',
    })
    save(out_dir, 'proof-inventory-execution.json', execution)

    limits = {
        'causal': 'Generic Causal results are conditional prefix/induction facts. They do not assume future success or a whole-run conclusion.',
        'funded_causal': 'FundedCausal is a concrete F10 witness plus named companions. It is not generic solvency.',
        'interface_instances': 'InterfaceInstances is a concrete accepted-M2 instance plus designated counterexamples. F15 is logical only.',
        'binary': 'BinaryCorrespondence specializes the existing binary executor. No participant-tree regrouping or cross-schedule order equivalence.',
        'accounting': 'Exact rational cell and receipt accounting. No machine-width arithmetic, deployed fidelity, oracle truth, liveness or generic solvency.',
        'source_index': 'Source grep is supplemental. Nested and multiple namespaces are tracked. Unresolved attribution is explicit. Environment discovery controls membership.',
        'private_helpers': 'Private helpers remain faithful local lemmas and are not classified as generic Causal or concrete FundedCausal/InterfaceInstances claims.',
        'verify': 'DefiKernel.Nary.Verify is parent-owned and must import every Nary source plus AxiomAudit, then audit prefix DefiKernel.Nary only.',
        'review': 'Mechanical author inventory, not independent approval. Runtime comparisons, mutations and CLI controls remain distinct evidence.',
        'candidate': 'Planning baseline ed94e6050d092e67f945df7b9762d3096ab0feda is history, not this tool\'s frozen default.',
    }
    record = {
        'schema_version': 3,
        'kind': 'imported-nary-proof-inventory',
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
    save(out_dir, 'proof-inventory-execution.json', execution)


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', help='Root-authorized frozen commit; all source bytes must match')
    parser.add_argument('--self-check', action='store_true', help='Parser and root tests only; no lake and no candidate')
    args = parser.parse_args(argv)
    out_dir = pathlib.Path(__file__).resolve().parent
    if args.self_check:
        result = run_self_checks()
        save(out_dir, 'self-check.json', result)
        print(json.dumps({'status': result['status'], 'checks': len(result['checks'])}, indent=2))
        return 0
    if not args.candidate:
        parser.error('--candidate is required unless --self-check')
    root = None
    try:
        root = repo_root(out_dir)
        return run_inventory(args.candidate)
    except InventoryError as err:
        persist_failure(out_dir, root, err)
        print(f'{err.status}: {err.message}', file=sys.stderr)
        return err.exit_code


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
