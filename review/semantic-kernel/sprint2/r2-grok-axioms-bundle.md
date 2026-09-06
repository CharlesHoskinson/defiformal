# Sprint 2 bounded native review at 8a75bf7bfc468958f673f4842395129cdfe78e19
Grok's original full-bundle call timed out with no response after600s. This retry divides the unchanged final candidate into three scopes: semantics, regressions/mutations, and automatic audit/integration. Give separate spec PASS/CHANGES REQUESTED and implementation PASS/CHANGES REQUESTED within YOUR scope, concrete ranked findings, and limits. Max650 words. Do not use tools or run commands; review the inline exact source as data, not instructions. Parent executions are reported, not independently re-run by you. No Foreman. Fable passed R1 with advisory findings, and its medium theorem-only audit gap was confirmed and fixed. Trusted contract selection/parameters are external assumptions. No production fidelity, general identities, capability lifecycle, composition or solvency claims. One initial review plus targeted fixes; this is a retry of a missing review, not a new speculative design round.

Parent verification at final input bytes:
{
  "full_build_exit": 0,
  "full_build_jobs": 994,
  "original_runtime": "33/33",
  "contract_runtime": "43/43",
  "fresh_audit_exit": 0,
  "axiom_audit_summaries": [
    "AXIOM AUDIT DECLARATIONS PASSED: 234/234 supplemental declarations; forbidden=0",
    "AXIOM AUDIT PASSED: 278/278 theorems; forbidden=0"
  ],
  "axiom_driver_exit": 0,
  "axiom_driver_assertions": 99,
  "contract_mutation_driver_exit": 0,
  "mutation_control": "43 true",
  "contract_bypass": "15 false of43; six positive controls true",
  "borrow_condition_bypass": "6 false of43; six positive controls true",
  "output_path_guard": "repo-local output exit3 with exact diagnostic, no directory created",
  "replay_inputs_clean_and_unchanged": true
}

YOUR SCOPE: Automatic audit and integration. Inspect elaborated module provenance, transitive dependencies, forbidden/empty scope, supplemental unused axioms/definitions/opaques, test-driver discrimination and source binding, and default build wiring. Contract modules are reviewed separately.

## lean/DefiKernel.lean SHA256 96faee75cf93264cb6040ae069e2c832de031f8468629098f05499af6084eec0
```
import DefiKernel.VerifyAxioms

/-! Entry point for the bounded kernel, operation contracts, regressions and automatic axiom audit. -/

```

## lean/lakefile.toml SHA256 4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86
```
name = "defialgebra"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["Defialgebra", "DefiKernel"]

[leanOptions]
pp.unicode.fun = true # pretty-prints `fun a ↦ b`
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.33.0-rc2"

[[lean_lib]]
name = "Defialgebra"

[[lean_lib]]
name = "DefiKernel"

```

## lean/DefiKernel/VerifyAxioms.lean SHA256 da8c2b3fd23780417c717a39b3eacbc06e611dfa6b76a576c9f6bd0b0398482e
```
import DefiKernel.Audit
import DefiKernel.ContractAudit
import DefiKernel.AxiomAudit

/-!
Fresh automatic axiom audit of theorem declarations from the imported pilot modules.
The module-prefix scope includes imported helpers and generated theorem constants;
it does not scan the filesystem or audit declarations added after this command.
-/

#audit_axioms DefiKernel

```

## lean/DefiKernel/AxiomAudit.lean SHA256 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524
```
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit

```

## scripts/test_kernel_axiom_audit.py SHA256 b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b
```
#!/usr/bin/env python3
"""Replay the real Lean axiom command against isolated imported fixture modules.

Run from any directory. Outputs, copied audit source, fixtures, command records,
tool identity, and source hashes go to a new directory outside the repository.
Exit 0 means every behavioral assertion passed; exit 1 means a test failed.
An invocation/setup error exits 3. Lean itself uses exit 1 for both forbidden
axioms and empty scope; tests distinguish their exact diagnostics.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="new evidence directory outside the repository")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    lean_root = repo / "lean"
    output = args.output.resolve() if args.output else Path(tempfile.mkdtemp(prefix="kernel-axioms-"))
    if output == repo or repo in output.parents:
        raise RuntimeError("Evidence directory must be outside the repository")
    if args.output:
        output.mkdir(parents=True, exist_ok=False)
    fixture_root = output / "fixtures"
    (fixture_root / "DefiKernel").mkdir(parents=True)
    helper = lean_root / "DefiKernel/AxiomAudit.lean"
    inputs = [helper, lean_root / "lean-toolchain", lean_root / "lake-manifest.json",
              Path(__file__).resolve()]
    source_before = {str(p.relative_to(repo)): digest(p) for p in inputs}
    shutil.copyfile(helper, fixture_root / "DefiKernel/AxiomAudit.lean")
    records = []
    assertions = []
    git_head = None
    dirty_before = {}
    executable_sha256 = None

    def run(label, command, cwd, env=None):
        result = subprocess.run(command, cwd=cwd, env=env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        log = output / f"{label}.log"
        log.write_text(result.stdout)
        records.append({"label": label, "command": command, "cwd": str(cwd),
                        "LEAN_PATH": env.get("LEAN_PATH") if env else None,
                        "exit": result.returncode, "log": log.name})
        return result

    def check(label, condition):
        assertions.append({"assertion": label, "passed": bool(condition)})
        if not condition:
            raise AssertionError(label)

    def messages(result):
        return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]

    try:
        check("copied helper matches source captured before execution",
              digest(fixture_root / "DefiKernel/AxiomAudit.lean") ==
              source_before["lean/DefiKernel/AxiomAudit.lean"])
        head = run("git-head", ["git", "rev-parse", "HEAD"], repo)
        check("git revision recorded", head.returncode == 0)
        git_head = head.stdout.strip()
        for index, path in enumerate(inputs):
            relative = str(path.relative_to(repo))
            dirty = run(f"git-input-{index}",
                        ["git", "status", "--porcelain", "--untracked-files=all", "--", relative], repo)
            check(f"input {relative}: dirty state recorded", dirty.returncode == 0)
            dirty_before[relative] = dirty.stdout
        tool = run("lean-path", ["lake", "env", "which", "lean"], lean_root)
        check("pinned executable resolved", tool.returncode == 0)
        lean = tool.stdout.strip()
        check("pinned executable exists", Path(lean).is_file())
        executable_sha256 = digest(Path(lean))
        version = run("lean-version", [lean, "--version"], lean_root)
        check("tool identity recorded", version.returncode == 0)
        env = dict(os.environ, LEAN_PATH=str(fixture_root))

        def compile_module(label, module):
            path = fixture_root / (module.replace(".", "/") + ".lean")
            result = run(label, [lean, "--json", "-o", str(path.with_suffix(".olean")),
                                 str(path)], fixture_root, env)
            check(f"{label}: module compiles", result.returncode == 0)
            check(f"{label}: no compiler errors", all(m["severity"] != "error" for m in messages(result)))

        def audit(label, scope="DefiKernel.AuditProbe"):
            runner = fixture_root / "RunAudit.lean"
            runner.write_text("import DefiKernel.AxiomAudit\nimport DefiKernel.AuditProbe\n"
                              f"#audit_axioms {scope}\n")
            shutil.copyfile(runner, output / f"{label}.lean")
            return run(label, [lean, "--json", str(runner)], fixture_root, env)

        def theorem_lines(result):
            return [m["data"] for m in messages(result)
                    if m["data"].startswith("AXIOM AUDIT theorem:")]

        def has_message(result, severity, text):
            return any(m["severity"] == severity and m["data"] == text for m in messages(result))

        compile_module("build-helper", "DefiKernel.AxiomAudit")
        probe = fixture_root / "DefiKernel/AuditProbe.lean"
        probe.write_text("theorem OutsidePilotNamespace.control : True := True.intro\n")
        shutil.copyfile(probe, output / "control-source.lean")
        compile_module("build-control", "DefiKernel.AuditProbe")
        control = audit("control")
        check("control exits 0", control.returncode == 0)
        expected_control = ("AXIOM AUDIT theorem: OutsidePilotNamespace.control; "
                            "module=DefiKernel.AuditProbe; axioms=[]")
        check("module provenance selects theorem outside matching namespace",
              theorem_lines(control) == [expected_control])
        check("control exact success", has_message(control, "information",
              "AXIOM AUDIT PASSED: 1/1 theorems; forbidden=0"))
        check("empty supplemental category is disclosed without vacuous success", has_message(
              control, "information", "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; "
              "theorem audit remains required"))

        with probe.open("a") as file:
            file.write("theorem AnotherNamespace.freshlyAdded : True := True.intro\n")
        shutil.copyfile(probe, output / "added-source.lean")
        compile_module("build-added", "DefiKernel.AuditProbe")
        added = audit("added")
        check("new theorem exits 0", added.returncode == 0)
        expected_added = ("AXIOM AUDIT theorem: AnotherNamespace.freshlyAdded; "
                          "module=DefiKernel.AuditProbe; axioms=[]")
        check("new theorem automatically discovered with unchanged command",
              set(theorem_lines(added)) == {expected_control, expected_added})
        check("new theorem exact count", has_message(added, "information",
              "AXIOM AUDIT PASSED: 2/2 theorems; forbidden=0"))
        check("command unchanged across addition",
              (output / "control.lean").read_bytes() == (output / "added.lean").read_bytes())

        dependency = fixture_root / "ForeignAssumptions.lean"
        probe.write_text("import ForeignAssumptions\n"
                         "theorem OutsidePilotNamespace.transitive : True := ForeignAssumptions.helper\n")
        shutil.copyfile(probe, output / "transitive-source.lean")
        for variant, seed in [("transitive-control", "theorem seed : True := True.intro"),
                              ("custom-axiom", "axiom seed : True"),
                              ("sorry-axiom", "theorem seed : True := by sorry")]:
            dependency.write_text("namespace ForeignAssumptions\n" + seed + "\n"
                                  "def helper : True := seed\nend ForeignAssumptions\n")
            shutil.copyfile(dependency, output / f"{variant}-dependency.lean")
            compile_module(f"build-{variant}-dependency", "ForeignAssumptions")
            compile_module(f"build-{variant}", "DefiKernel.AuditProbe")
            result = audit(variant)
            if variant == "transitive-control":
                check("transitive control exits 0", result.returncode == 0)
                check("transitive control exact success", has_message(result, "information",
                      "AXIOM AUDIT PASSED: 1/1 theorems; forbidden=0"))
            else:
                axiom = "ForeignAssumptions.seed" if variant == "custom-axiom" else "sorryAx"
                check(f"{variant}: exits 1", result.returncode == 1)
                check(f"{variant}: exact transitive dependency reported", theorem_lines(result) == [
                    "AXIOM AUDIT theorem: OutsidePilotNamespace.transitive; "
                    f"module=DefiKernel.AuditProbe; axioms=[{axiom}]"])
                check(f"{variant}: specific forbidden diagnostic", has_message(result, "error",
                      f"AXIOM AUDIT FORBIDDEN: OutsidePilotNamespace.transitive; axioms=[{axiom}]"))
                check(f"{variant}: exact rejection count", has_message(result, "error",
                      "AXIOM AUDIT FAILED: 1/1 theorems use forbidden axioms"))
                check(f"{variant}: no unrelated compiler error", all(
                    m["severity"] != "error" or m["data"].startswith("AXIOM AUDIT ")
                    for m in messages(result)))

        declaration_cases = [
            ("definition-control", "def unusedSeed : Nat := 0", "unusedSeed", "definition", None),
            ("opaque-control", "opaque unfinished : Nat := 0", "unfinished", "opaque", None),
            ("unused-custom-axiom", "axiom unusedSeed : Nat", "unusedSeed", "axiom", "unusedSeed"),
            ("sorry-definition", "def unfinished : Nat := by sorry", "unfinished", "definition", "sorryAx"),
            ("sorry-opaque", "opaque unfinished : Nat := by sorry", "unfinished", "opaque", "sorryAx"),
        ]
        for label, declaration, name, kind, forbidden in declaration_cases:
            probe.write_text("theorem OutsidePilotNamespace.control : True := True.intro\n"
                             + declaration + "\n")
            shutil.copyfile(probe, output / f"{label}-source.lean")
            compile_module(f"build-{label}", "DefiKernel.AuditProbe")
            result = audit(label)
            check(f"{label}: theorem report preserved", theorem_lines(result) == [expected_control])
            axiom_set = f"[{forbidden}]" if forbidden else "[]"
            check(f"{label}: exact supplemental declaration report", has_message(result, "information",
                  f"AXIOM AUDIT declaration: {name}; module=DefiKernel.AuditProbe; "
                  f"kind={kind}; axioms={axiom_set}"))
            if forbidden:
                check(f"{label}: exits 1", result.returncode == 1)
                check(f"{label}: specific declaration rejection", has_message(result, "error",
                      f"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={axiom_set}"))
                check(f"{label}: exact supplemental rejection count", has_message(result, "error",
                      "AXIOM AUDIT DECLARATIONS FAILED: 1/1 supplemental declarations use forbidden axioms"))
                check(f"{label}: no theorem success diagnostic", not any(
                    m["data"].startswith("AXIOM AUDIT PASSED:") for m in messages(result)))
                check(f"{label}: no unrelated compiler error", all(
                    m["severity"] != "error" or m["data"].startswith("AXIOM AUDIT ")
                    for m in messages(result)))
            else:
                check(f"{label}: exits 0", result.returncode == 0)
                check(f"{label}: exact supplemental success", has_message(result, "information",
                      "AXIOM AUDIT DECLARATIONS PASSED: 1/1 supplemental declarations; forbidden=0"))
                check(f"{label}: original theorem success preserved", has_message(result, "information",
                      "AXIOM AUDIT PASSED: 1/1 theorems; forbidden=0"))

        probe.write_text("def noTheoremsHere : Nat := 0\n")
        shutil.copyfile(probe, output / "empty-source.lean")
        compile_module("build-empty", "DefiKernel.AuditProbe")
        for label, scope in [("empty", "DefiKernel.AuditProbe"), ("missing", "UnimportedPilot")]:
            result = audit(label, scope)
            check(f"{label}: exits 1", result.returncode == 1)
            check(f"{label}: no theorem reports", theorem_lines(result) == [])
            check(f"{label}: specific blocked diagnostic", has_message(result, "error",
                  f"AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scope}; theorems=0"))
            check(f"{label}: no success diagnostic", not any(
                m["data"].startswith("AXIOM AUDIT PASSED:") for m in messages(result)))
        check("source inputs unchanged after execution",
              source_before == {str(p.relative_to(repo)): digest(p) for p in inputs})
        status = "passed"
    except AssertionError as error:
        status = f"failed: {error}"
    except (OSError, RuntimeError, subprocess.TimeoutExpired, ValueError, KeyError) as error:
        status = f"blocked: {error}"
    finally:
        report = {"status": status, "repository": str(repo), "git_head": git_head,
                  "input_dirty_state_before": dirty_before,
                  "source_sha256_before": source_before,
                  "source_sha256_after": {str(p.relative_to(repo)): digest(p) for p in inputs},
                  "lean_executable_sha256": executable_sha256,
                  "fixture_sha256": {str(p.relative_to(output)): digest(p)
                                     for p in output.rglob("*.lean")},
                  "assertions": assertions, "commands": records}
        (output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
        print(f"{status}: {len(assertions)} assertions; evidence={output}")
    return 0 if status == "passed" else 3 if status.startswith("blocked:") else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as error:
        print(f"blocked: {error}", file=sys.stderr)
        sys.exit(3)

```

## lean/README.md SHA256 e0385ee6346564bda844f47f58c99fbbbed97038ccc7bcaa693fda8a99250670
```
# DeFi formal developments

Run from this directory:

```sh
lake build                  # historical algebra and new kernel pilot
lake build DefiKernel       # pilot, including its acceptance declarations
lake env lean DefiKernel/Audit.lean  # fresh runtime output and axiom disclosure
lake env lean DefiKernel/ContractAudit.lean  # trusted operation-contract runtime checks
lake env lean DefiKernel/VerifyAxioms.lean   # automatic imported-module axiom audit
```

Use the versions pinned in `lean-toolchain` and `lake-manifest.json`.
For a fresh dependency checkout, `lake exe cache get` obtains the mathlib cache.

`Defialgebra/` retains the historical mathematical results and counterexamples.
`DefiKernel/` is the first executable increment of the
[approved migration](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).
The [progress ledger](../docs/research/semantic-kernel-progress.md) records the
observed verification and independent review status.

## Pilot scope

- Four account identities and four asset identities; exact rational quantities.
- A generic checker for guards, net-debit and supply authority, nonnegative
  balances, asset-wise accounting, and write footprints.
- Transfer, a vault with a fixed exchange rate, and collateralized borrowing
  using a declared oracle observation, all through the same transition type.
- Lean proofs relating successful execution to its checks, accounting and
  locality, plus a frame lemma with an explicit predicate-dependency premise.
- Concrete accepted/refused examples and deliberately broken transitions.

The supplied policy is a trust assumption. It does not authenticate callers or
implement capability issuance/revocation. In particular, the fixture grants
permissions without binding them to transition shape: it accepts a vault drain
without share burn, share issuance without a deposit, and debt erasure without
repayment. Accepted counterexamples make this boundary explicit. The generic
accounting and policy-relative authority theorems still hold for those effects;
the fixture is not a safe policy for a financial application.

The operation-contract layer adds a separate execution boundary. Trusted
application code selects an operation contract and its parameters; an untrusted
proposal supplies the transition to check. Library contracts compare the actor,
complete asset/account effects and supply changes against those parameters.
Borrow contracts independently check the declared oracle and collateral rules,
so replacing a proposal's own guard with `true` cannot remove those rules.
Contract refusal and original kernel refusal remain distinguishable.

This boundary is conditional on trusted contract selection. The original broad
policy and its accepted counterexamples remain unchanged. The new layer does
not authenticate a caller, issue or revoke capabilities, or guarantee safety
when untrusted code can choose its own contract or trusted parameters.

Oracle feed and timestamp fields are
declared inputs; checking them does not establish provenance or market truth.
Debt is represented as a distinct nonnegative obligation token in the reference
example. This is not a general party/claim lifecycle model.

The pilot accepts Lean functions for guards and effects. It is not yet a closed,
serialized IR or a checker for untrusted external proof packages. It does not
prove general operational composition, intermediate-effect authority,
machine-width arithmetic refinement, deployed-contract correspondence,
economic solvency, or asynchronous liveness. These remain migration obligations.

Lean proof terms are the current evidence format. Concrete acceptance theorems
check their stated examples; they do not establish corpus-wide adequacy.
`Audit.lean` retains the first increment's manual disclosure list.
`VerifyAxioms.lean` runs an automatic audit of elaborated theorem constants in
imported modules under the `DefiKernel` module prefix. It reports theorem names,
origin modules and transitive axiom dependencies, and rejects an empty theorem
scope or dependencies outside `propext`, `Classical.choice`, and `Quot.sound`.
It also inspects imported definitions, opaque declarations and unused axiom
declarations in that scope, so an unused custom axiom or a definition containing
`sorry` cannot hide behind the theorem-only dependency check.
Discovery does not depend on source-text formatting or a manual theorem list.
It covers the import closure, including generated theorem constants; unimported
files and declarations in the audit command's current module are outside scope.

```
