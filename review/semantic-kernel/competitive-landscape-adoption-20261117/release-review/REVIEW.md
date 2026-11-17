# Independent release-preparation review

**ACCEPT_WITH_LIMITATIONS** for the six-file release-preparation candidate. No blocking repair is required. No tag or published release is accepted or claimed by this review; publication still requires green CI at the actual release candidate.

Exact baseline: `6ebed6bf2af7bb753ab26085cc934cfc5dfd321a`. Candidate digest: `aceda4c824ad07ade48d6961cff51cd3e1eaf1b9165a44e6453d462bdd650657`, computed as SHA-256 of `json.dumps(files, sort_keys=True)`. All six file hashes match FREEZE.json. The candidate changes only LICENSE, CONTRIBUTING.md, THIRD_PARTY_NOTICES.md, README.md, benchmarks/competitive-landscape/README.md and docs/releases/v0.1.0.md. No Lean, adapter source or historical notice bytes changed.

Requested reviewer: `gpt-6-astra`, medium reasoning. No provider-returned model identity or attested effort is exposed to this independent Codex subagent; actual identity is unavailable rather than inferred. This is a document/provenance review, not a legal opinion or exhaustive legal audit. No build was rerun for these six documentation files.

## Verification and assessment

The recorded user instruction authorizes Apache-2.0 for original DeFiFormal code/proofs and specifically the selected 168 IOG adapter files, while preserving third-party terms and attribution and forbidding ownership inference. The candidate follows that scope. It does not extend the authorization to the entire assessment repository or historical third-party source captures. The six named original copyright notices identify Charles Hoskinson in the actual source headers, which remain byte-identical. Unnamed holders remain unnamed; IOG authorship attribution is explicitly not a copyright-ownership claim.

LICENSE matches the retained official Apache text byte-for-byte, 11,358 bytes, SHA-256 `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`. The appendix's unfilled example fields remain canonical license instructions, not an invented project copyright notice. Author evidence records retrieval from `https://www.apache.org/licenses/LICENSE-2.0.txt`; this review verified the retained text/hash, not a second live fetch.

Independently verified all 168 adapter provenance hashes, all six named source copyright notices against the baseline, all 60 relative Markdown targets, the exact six-file change set and `git diff --check`. The six embedded native snapshots were already verified against their source revision in the import review and are unchanged here; author verification also records the six comparisons. The current origin is `https://github.com/stefan-contiu/defiformal`; the new clone/contribution/release links use that delivery fork and `semantic-kernel-pivot`. Relative release-note links correctly resolve from docs/releases, including the README example anchor.

The third-party index is explicitly non-exhaustive and conservatively excludes historical third-party material from the project grant. Its linked source license headings match the described AGPL, GPL, MIT, Apache and Business Source License texts; the Curve rights-reserved text and IBC NOTICE are preserved and linked. The table does not silently infer conversion of a dated license, overwrite individual file exceptions or replace retained notices. This review does not independently establish ownership or redistribution rights beyond the supplied authorization and preserved source records.

The contribution guide uses the pinned toolchain/build path, existing fresh CI audit and real positive/negative controls. It retains the forbidden-proof rules, exact evidence identity requirements and separation of proof, bounded execution and measurement. The release notes correctly retain theorem premises, trusted inputs, cache boundaries, incomplete roadmap and deployed-fidelity limits, and explicitly leave outside reproduction open. They do not label internal replay as external reproduction or turn imported benchmark models into new kernel proofs. No unsupported broad release/proof completion claim was found.

## Nonblocking finding and publication limits

The release-note title and opening accurately describe a preparation with no tag/release yet. If the exact text is published as v0.1.0, that opening becomes stale. Prefer lifecycle-neutral reader-facing wording before tagging, with the actual tag/release record serving as publication authority. Any such edit needs a new hash and focused wording review; this verdict binds only the current six-file bytes. Keep the proof, source, dependency and outside-reproduction limitations unchanged.

Root reports hosted CI run 44046339435 passed at the baseline revision. That does not establish CI success for the future six-file release candidate. Tag/publish only after review of final bytes and green CI at that actual candidate. I.4 remains open because no outside developer reproduction record exists. The historical-license index remains an index, not an exhaustive legal clearance of the repository.

Required repairs for preparation: none. Reviewer changed no candidate file or task checkbox. Findings/fixes: one lifecycle-wording recommendation; no fix included in this reviewed freeze.
