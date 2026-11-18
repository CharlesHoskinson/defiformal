# Independent minimal-CI implementation review

**ACCEPT_WITH_LIMITATIONS** for integration of the workflow. No required repairs. I.1 is not complete until a passing GitHub-hosted run is visible at the delivered revision; this review does not claim that run occurred.

Candidate: `.github/workflows/lean.yml` SHA-256 `b4814a81c7708da605c78dc71da10e4cdc935758a7e8b2a06abcf8876827326c`, against baseline `4ad62410ae8479679272736278f4f6a56a4062e7`. Independently recomputed the workflow hash and matched FREEZE.json. Only CI configuration is accepted; no theorem, audit implementation or library changes are included.

Requested checker: `gpt-6-astra`, medium reasoning. No provider-returned model identifier or attested effort is exposed to this independent Codex subagent; actual model identity remains unavailable. This review inspects exact source and execution evidence; it did not rerun the full build or mutate the author/root build trees.

## Configuration assessment

The workflow triggers on every push to `semantic-kernel-pivot`, on pull requests targeting it, and on manual dispatch. There is no path filter, success-swallowing condition, continue-on-error setting or concurrency cancellation. It checks out the event candidate with read-only contents permissions. “Every push” means the pushed event revision; it is not a separate verification of each intermediate commit in a batch push.

Both top-level actions use immutable commit references. The actual [checkout definition](https://github.com/actions/checkout/blob/11d5960a326750d5838078e36cf38b85af677262/action.yml) and [Lean action definition](https://github.com/leanprover/lean-action/blob/ba3fdfe5c4476c925da13bf11a005ddb47e47aee/action.yml) were fetched at those revisions. The Lean action's pinned config script honors `build: true`; its build script runs plain `lake build` and propagates failure. The project directory is `lean`, so its committed lean-toolchain and Lake manifest govern Lean/mathlib. The default targets at this baseline are `Defialgebra` and `DefiKernel`. This is the full default project build, not a claim to build every historical or unimported file in the repository.

After the build, a newly generated temporary file imports `DefiKernel` and executes `#audit_axioms DefiKernel` via `lake env lean`. The audit command is freshly elaborated on every successful build even when Lake restores cached modules. Bash failure propagation makes a nonzero audit exit fail the step/job. The command rejects empty imported theorem scope and forbidden transitive dependencies, including supplemental definitions, opaque constants and unused axioms. Existing real-Lean audit controls run separately afterward in RUNNER_TEMP. There is no new orchestration framework.

## Evidence verified

- Author's 99 audit-control assertions pass. Independently checked that all four before/after source hashes are unchanged and match the exact baseline, all recorded command logs exist, and raw clean/forbidden/empty diagnostics support the outcomes. Forbidden custom/sorry dependencies and empty/missing scopes are rejected; clean controls pass. Exact hashes are in `audit-control-inspection.json`.
- Root reports its separate baseline build completed with exit 0 and 1,200 jobs. I inspected the successful completion in build-restored.log; this is root-executed evidence, not an independently repeated build.
- Author's local production command campaign passes. The extracted audit shell matches the workflow after YAML indentation removal and trailing blank-line normalization. Clean full `lake build` exits 0. Fresh production audit exits 0 and reports 7,751/7,751 theorems plus 8,702/8,702 supplemental declarations, forbidden=0.
- The deliberate isolated `Core.lean` custom-axiom addition compiles successfully. Both the exact production audit and `lake build` then exit 1 with `AXIOM AUDIT DECLARATION FORBIDDEN: DefiKernel.CIRejectedAxiom`. Thus this is a content-sensitive production-path failure, not just a setup failure or a test of a copied algorithm.
- Core is restored byte-for-byte to the baseline; restored build and audit both exit 0 with the same nonempty audit counts. Workflow hash and Git dirty-state snapshot are unchanged. I independently compared restored Core with its Git object. `production-evidence-inspection.json` retains command records and raw-log hashes.

Local tool: Lean 4.33.0-rc2, arm64-apple-darwin24.6.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; compiler SHA-256 `1b370cfcbf44e80d1b004ab1b1ab9a4c73951f9f7c242140bcff9bc577576554`. Author controls execute on Darwin; the configured GitHub runner is Ubuntu. That distinction is retained.

## Acceptance limits

Hosted execution, action download/setup, Linux dependencies and visible passing status at the delivery revision remain to be demonstrated after integration. The local deliberate-defect campaign establishes rejection by the production commands, not a hosted negative run. No task checkbox was changed by this reviewer.

The audit covers imported modules with the `DefiKernel` module prefix, using module provenance rather than declaration names. It excludes unimported files, declarations in the temporary current module, other namespaces' independently unused declarations, and unselected historical targets. Counts include inherited/generated declarations and are not counts of independent financial claims. Standard allowed axioms remain `propext`, `Classical.choice`, `Quot.sound`; no financial/deployed equivalence claim follows from this audit.

The pinned project build may reuse Lake/mathlib caches; “fresh audit” does not mean a clean rebuild of the dependency closure. `ubuntu-latest`, the action's Elan installer bootstrap from its master URL, and external cache availability are not byte-pinned by this workflow. These are disclosed execution/reproducibility limits, not silent changes to the committed Lean/mathlib pins. The current threat model does not require redesigning the upstream action.

No blocker found. Integrate this exact configuration, preserve local positive/negative evidence, inspect the hosted run, and close I.1 only when its remaining hosted criterion is satisfied.
