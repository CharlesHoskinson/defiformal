# P19 host artifact repair review

**ACCEPT for integration — exact three-file host validator/export/records candidate.** Independent Astra incremental review. Both prior blockers are fixed; no remaining blocker within the stated host-identity scope. This supersedes the original rejection only for the candidate bound by `../p19-host-artifact-candidate.json`; the original review and raw counterexamples remain preserved.

Candidate SHA-256:

- `scripts/verify_certificate_host.py`: `7449fd078a3cb948efa45d9ccd23942e6f089f96b2ca4c5e04a7aff3ff8fd532`
- `lean/DefiKernel/Certificates/HostIdentityExport.lean`: `acf4af5867bb3889622a246af161dcdf2c9fa7d4a5ee732129c7d41130c09c88`
- `lean/DefiKernel/Certificates/trusted-host-records.json`: `77855deefbeb8b45ce1b33ef2d228700662b4d5edb9cce1753f1887549e2f376`

Only the Python validator changed. It now checks the reviewed imported TrustedHost artifact and invokes absolute Lean/Lake executables with checked digests. The artifact pin is independently supported by the prior main/author/private equality and reviewer rebuild using recorded Lake setup: `27b0f65e94341cff5556b20eea38189e9d98f460a3cc04fd643059694a90e7b6`. It is not inferred from an exporter source-hash assertion.

Independent actual checks, with full argv, cwd, exits and stdout/stderr hashes in `artifact-controls.json` and corresponding `artifact-*.stdout/.stderr`:

- Intact: exit 0.
- B1: preserved poisoned TrustedHost.olean plus matching hostile host JSON: exit 1, imported artifact digest mismatch.
- B2: preserved fake `.lake/build/bin/lean` plus matching hostile host JSON: exit 1, JSON git disagrees with the actual exported constant.
- Restored intact: exit 0. Candidate default CLI also exits 0 (`artifact-default-cli-command.json`).

The source/JSON inventory comparisons, library-record requirements and malformed-export parser are unchanged by this patch. Reuse the original independent missing/empty/substituted library, arithmetic drift, TrustedHost source drift, comment-spoof, export-failure and malformed-export checks in `controls.json`; author artifact-fix controls provide additional corroboration, not a substitute for independent B1/B2 checks.

Relative-path finding is nonblocking for this frozen configuration: the validator resolves relative LEAN_PATH entries against Python cwd, but pinned Lake puts absolute dependency/build paths before user-supplied paths. The mandatory canonical artifact exists and is checked. An actual appended relative path containing the prior hostile artifact, with matching hostile JSON, still rejects at the git comparison. See `artifact-relative-control.json` and `artifact-relative-effective-path.stdout`. No acceptance bypass was demonstrated; a future change to search-path construction needs review.

Companion-artifact scope: this pinned TrustedHost is a legacy non-`module` artifact. Lean Environment.lean:2045–2051 uses its main .olean IR; module-system .ir parts do not replace that IR. The independent exporter trace opened only TrustedHost.olean and exited 0 (`trustedhost-artifact-read-trace.log`). The validator additionally refuses discovered TrustedHost.ir files. New module-system artifact layouts require a new binding decision.

Trust boundary: usable on the pinned Linux Lean 4.33.0-rc2 installation, with trusted Python/OS, toolchain libraries and existing transitive build cache. This is not an attestation of every dependency binary or protection against concurrent hostile filesystem mutation. Lean/Lake executable pins and this exact artifact are portable only where bytes match; no fallback is promised. This review accepts neither runtime checker claims, all P19/P20, nor a fixture campaign.

All candidate hashes remain exact. The private artifact and control JSON were restored and the fake executable removed; see `artifact-final-identities.json`. No candidate, main or author source edits, broad rebuilds, commits, or archives were made.
