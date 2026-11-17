# Independent adapter-import implementation review

**ACCEPT_WITH_LIMITATIONS** for the pinned import and portable wrapper only. No blocking repairs remain. This accepts neither CI, new kernel financial proofs, wider dependent tasks, release nor outside reproduction.

## Exact candidate and identity

Reviewed final freeze: `FREEZE-r2.json`, source digest `805f6fe6a80265856f2187391f901dead9ccbbea455b128e85817302c8cd96b9` (SHA-256 of `json.dumps(files, sort_keys=True)`). All 173 file hashes independently match. The original frozen digest was `d2ed216b8c9ff7c99775a3933150d6e42f2b124be5258ff31d79c3312aa7a0de`. Only README.md changed in r2, correcting timeout-output retention; implementation bytes are unchanged. Original README hash `dd664e02e64fe78044f07f14b39187b4b3ca68702eabcabc9694cb3ff1430a9d`; final hash `c78c95c2c76afc41ca4052e4fc3e3ad008bc16294064959d33477a038f4292bd`.

All 168 upstream files were independently compared byte-for-byte with their recorded Git objects at assessment revision `1ced5fe1e0a83d665184bb496bea01bcb9940449`. Recorded sizes and hashes match. All seven native dependency source hashes match DeFiFormal Git objects at `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda`. The other five files are wrapper, tests, documentation and provenance records. No historical theorem or imported adapter file changed.

Requested reviewer: `gpt-6-astra`, medium reasoning. The independent Codex subagent has no provider-returned model identifier or attested reasoning setting available; actual identity is unavailable and not inferred from the request. The reviewer made no root source edits or task-checkbox changes.

## Independent verification

Created `/private/tmp/defiformal-adapter-review` from the frozen candidate and used separate output `/private/tmp/defiformal-adapter-review-results`. The compiler and prepared dependency tree were used read-only; no historical-runtime mode was requested.

- Seven wrapper tests pass under `/opt/homebrew/bin/python3` 3.14.3. Controls cover intact inventory, missing/modified/extra/empty sources, output overlap, invalid adapter, wrong compiler version, disabled assertions and missing tools.
- `verify-sources` passes with denominator 168.
- Focused `transfer / R1-TRANSFER / proof` passes: fresh model/assisted compilation, canonical axiom classification, and two successful leanchecker module replays. Artifacts are hashed and unchanged across checker invocation. This is actual execution of the final implementation bytes.
- Recomputed all 173 source hashes after execution; unchanged. The later README-only r2 change was separately verified.
- Initial commands accidentally selected system Python 3.9.6 in the temporary directory and failed before verification because `hashlib.file_digest` is unavailable. This is below the documented Python 3.11 prerequisite. Those attempts provide no pass credit; the successful runs use explicit Python 3.14.3.

Compiler identity: Lean 4.33.0-rc2, arm64-apple-darwin24.6.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Compiler SHA-256 `1b370cfcbf44e80d1b004ab1b1ab9a4c73951f9f7c242140bcff9bc577576554`; leanchecker SHA-256 `257f505f8241ab595c6b557d661fd832dbdace6839ab35d9d1600b3dcbce5880`. Exact commands and raw result structure are recoverable from the wrapper, independent summary, test logs and proof output saved beside this review.

## Author evidence inspected, with provenance limits

Inspected completed `/private/tmp/defiformal-adapter-author/proof-replays/summary.json` and all 13 raw proof outputs. Each reports successful proof checking; 67 module replay invocations have zero return codes and exactly one matching replay marker each. These include repeated modules across workloads, not 67 unique mathematical results. Nonempty artifact maps are retained. `author-proof-evidence-inspection.json` binds these raw outputs by hash.

That full campaign started before the final wrapper metadata freeze and its summary lacks the final entrypoint/Python identity fields. It is pre-freeze/mixed-wrapper supporting adapter evidence, **not** an exact-final-wrapper full-13 execution claim. No retrospective wrapper hash is fabricated. The independent final-wrapper transfer proof above supplies direct final implementation execution. The author's final-wrapper transfer parser output also records successful classifications of success, failed obligations, incomplete, malformed, timeout and cached-skip cases. Any newly started full campaign is outside this verdict until independently recorded as completed; this review gives it no credit.

## Contract assessment and limits

The wrapper checks exact nonempty source inventory before and after public runs, checks pinned native source bytes and mathlib manifest revision, records tool hashes, validates selected cases/checks, and requires both subprocess success and the expected JSON status. It refuses optimized Python so upstream assertions remain active. Canonical proof handling requires actual elaboration and axiom classification before kernel replay. Exceptions, invalid selections, absent dependencies and timeouts cannot become a successful empty run.

Normal replay redirects setup/install/environment functions in memory rather than modifying upstream bytes, uses fresh disjoint output, disables bytecode writes, isolates each check in a subprocess, and keeps generated adapter artifacts out of source and dependency trees. Optional historical-runtime writes are separately documented and were not exercised in this review.

The documentation accurately distinguishes benchmark models and adapted-library workloads, retained negative cases, fresh replay, measurement, kernel proof, and deployed fidelity. The imported compiled mathlib/native cache remains trusted: verified source bytes do not authenticate arbitrary cached oleans. `leanchecker` uses the same kernel and trusts imports; this is neither an independent kernel implementation nor a full dependency rebuild. Platform portability follows explicit paths and dependency inputs, but only Darwin arm64 was executed here. The all-kinds default campaign, all mutations, historical trust mode and outside onboarding were not independently rerun by this reviewer.

One nonblocking finding was corrected: the first README said every check retained full stdout/stderr, but wrapper-level timeouts discard partial output. Final README states that limit correctly. No code repair was needed; timeout still fails safely. Successful proof reports contain checker details and artifact hashes but do not retain every successful compilation diagnostic; their scope should not be advertised as a complete compilation transcript.

The supplied original report remains historical evidence. Import acceptance does not close II.2/IV.1, prove new financial correspondence, establish deployed-source refinement or constitute outside reproduction. Root must retain these limits when integrating and recording task 1.2 availability.
