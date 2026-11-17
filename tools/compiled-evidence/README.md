# Compiled DeFiFormal evidence for macOS arm64

This package replays the six explicit modules in `targets.txt` using the bundled Lean `leanchecker`. It contains their actual compiled import closure, all associated Lean source files, dependency revision and license records, runtime libraries, checksums, and selected accepted evidence. `manifest.json` identifies the exact source revision, checker binaries, platform and scope of each check. The package archive has an external SHA-256 in its publication record; compare that before extraction. Internal checksums detect missing or altered payload bytes, not a maliciously replaced archive plus checksum.

Extract the archive, then run from any directory:

```sh
/bin/sh /absolute/path/defiformal-evidence/replay.sh /private/tmp/my-new-replay-results
```

The results directory must be new and outside the package. This command verifies `SHA256SUMS`, checks a nonempty target inventory, then runs the bundled checker separately for each target with an empty environment except a package-first system PATH and a temporary HOME. Its working directory is unrelated to the repository and package. No repository, author cache, Lean installation, network, Python, Lake, C compiler or dependency installer is required for this replay. Logs and a summary go into the results directory. Exit 0 means all selected modules replayed, exit 3 means required evidence is missing, empty or unreadable, or platform support is unavailable, and exit 1 means bytes or replay results contradict the record.

The supported runtime is macOS arm64. The manifest records the Mach-O minimum macOS version and the actual tested host; older or other platforms are unsupported. The operating system supplies `/bin/sh`, `/usr/bin/shasum` (and its system Perl runtime), `/usr/bin/env`, `/usr/bin/uname`, `/usr/bin/mktemp`, `/usr/bin/tr`, `/usr/bin/dirname`, `/bin/mkdir` and `/bin/rm`, plus `/usr/lib/libSystem.B.dylib` and `/usr/lib/libc++.dylib`. These OS facilities and the bundled Lean runtime are trusted. Availability is checked for the command-line tools. No host Lean binary is selected. Runtime dylib dependencies were inspected during assembly; the required `@rpath` libraries are bundled.

Default `leanchecker` replays the declarations of each selected target against its imported environment. It is the same Lean kernel, **not an external verifier**. The explicit import inventory is `manifest.json`'s `modules`: each entry records its direct metadata imports, artifact parts, source hash and provenance. Imports are trusted during each target replay, including another selected module when imported. The import closure is discovered with Lean `withImportModules` and `readModuleData`, not source-text import matching. No `--fresh` replay of every dependency is claimed. Independent rebuilds are not claimed to produce byte-identical artifacts: the original five-target package review found seven different `.olean` byte hashes while all 2449 source-file hashes matched. That is a historical review observation, not a byte-reproducibility measurement of this enlarged closure. The published checksums identify this particular assembled payload; kernel replay checks its selected declarations. Kernel replay alone permits axioms; the accepted named/full axiom audits are separate evidence.

The selected behavior is the fixed raw1 vault-to-hypothetical-token0-quote workflow and its share-conversion prerequisite, the generic checked-conversion domain, the generic computed Typed deposit correspondence, existing token0 model proofs, and the finite shared-liquidity ordering replay definitions. The ordering module has 12 accepted finite source assertions: both schedules preserve the full declared ledger/capability expectations and have distinct located insufficient-funds refusals. Both branches authenticate Alice; Bob is the right transfer recipient. This archive replays the module definitions and binds the prior source/runtime controls; it does not rerun those 12 source assertions. Historical runtime, refusal and mutation records retain their original dates and scopes. Reading or replaying cached proof artifacts does not execute their source `#eval` controls. The package includes the token0 three-artifact relation and all 101 bound files, including the original source campaign archive. Its 12 source invocations (8 successes, 4 coarse reverts) and 4 model invocations remain separate. The source-refinement obligation remains unproved; there is no deployed equivalence or pool settlement claim.

Optional Python 3 checks are available when Python is installed:

```sh
python3 /absolute/path/defiformal-evidence/recheck.py --verify-only
python3 /absolute/path/defiformal-evidence/evidence/repository/docs/correspondence/token0/verify.py
```

The first additionally checks the exact payload file inventory and metadata closure consistency. The second checks the archived token0 record bindings and ABI/value observations; it does not run EVM. Python is not required by the shell proof replay. Some historical review/result records refer to raw logs not bundled here; those references remain source-revision evidence, not package-alone replay promises. The full token0 101-file binding set is bundled. The selected ordering control records include raw nonempty traces and error diagnostics; zero-byte ancillary streams remain identified by their hashes in the source-revision control records. The immutable original v0.2.0 publication record is included; this six-target refresh has its own source revision and artifact identity. The original P18 validator needs its separately pinned `jsonschema` dependency and is not promised by the bare package.

Assembly uses an already built checkout and pinned native Lean toolchain:

```sh
python3 tools/compiled-evidence/build.py --repo /absolute/checkout \
  --toolchain /absolute/lean-4.33.0-rc2-darwin_aarch64 \
  --output /private/tmp/new-package --archive /private/tmp/new-package.tar.gz
```

The builder does not install dependencies or rebuild/runtime-test source. Target modules are listed explicitly in `targets.json`; add a target there when a later integration needs evidence and regenerate/review the package. It fails on empty targets or missing required artifacts, copies only actual metadata imports, binds current original source bytes to the source revision, and preserves source headers and original licensing. Original repository code follows the scoped root Apache grant; Lean and dependency notices are retained separately. No ownership is inferred from file location.

A new source-bound tag/release establishes this artifact's publication identity; it does not modify `v0.1.0`. Author and reviewer relocations are engineering verification. A real outside developer's setup time and outcome have not been recorded, so the third-party reproduction criterion and corroborated adoption remain open.
