# Sprint 5 native review adjudication

Implementation uses GPT-6 through the stock Codex harness. Reviews use the native
Grok and Fable CLIs, with no Foreman. Review is advisory source analysis, not an
independent Lean build or mathematical proof.

Initial source candidate: `ba3661f3e875ef6c48e71300fec339d333dab697`.
Revised source candidate: `28ba18c446f72084ff11b4d125dccf93bf8f4162`.

## Initial reviews and remediation

Both providers reviewed interfaces/contracts and execution/preservation separately.
All four initial reviews returned ACCEPT WITH LIMITATIONS, with explicit dissent
that integration must close shared-access and isolation-evidence gaps. That dissent
is retained in the raw responses; the initial reviews alone do not close acceptance.

| Finding | Resolution in revised candidate |
| --- | --- |
| Duplicate or self-declared exports could bypass read-only imports | Require globally unique exported cells and disjoint export/import cells within each component; add conflicting-provider and self-import negative controls |
| Output snapshots could read another domain | Require selected outputs to match the registered operation domain; test the otherwise-visible cross-domain negative |
| Component access checks lacked a proof bridge | Prove the bridge from accepted interface checks to receipt writes and `canWrite`-conditional component locality; foreign-private identification remains demonstrated by bounded configured workflows |
| Administrative authority was implicit in step relations | Add explicit `TraceSound.administration`; invocation receipt rights remain separate |
| Interface-only/adapter-only tests did not establish composed refusal behavior | Add full-world, store, receipt, output, index, and refusal comparisons for private/shared/read-only interference and output routing; integrate all 93 comparisons |
| Initial reports did not evidence the whole new import closure | Save the revised full build, eight fresh verification commands, imported axiom audit, and exact source hashes in `build-verification.json` |
| Argument resolution wording overstated the current syntax | Document principal/party-list resolution, static output validation, and the catalog-authorship assumption |
| A runtime comparison was described as a proof | Correct the interface report to call it a check; distinguish theorem inventory from executed comparisons |

No false confidentiality claim is added: interface checks cover declared and
syntactically collected reads, and successful permitted writes. Environment truth,
configuration authenticity, and capability-store provenance remain assumptions.
The unchanged typed expression implementation and authority APIs are supplied to
the final review so their collector and scope behavior can be inspected directly.

The generic initialization/contract theorem retains explicit local and boundary
premises. The concrete collateral frame theorem discharges its protected-write
premise by kernel reduction. The separate boundary-contract fixture uses time as
an explicit assumption and monotone collateral as its guarantee; it does not use
time as a financial price. Nonnegativity is supplied by proof-carrying states and
is not counted as an additional invariant-discovery result.

The mutation projection boundary in `Sequence.lean` was moved above proof-only
relations so the executable projection does not depend on omitted step proofs.
This changes projection organization, not accepted Lean execution semantics.

## Final review

Fable's combined follow-up returns ACCEPT WITH LIMITATIONS. It confirms closure
of conflicting export permissions, cross-domain output snapshots, the receipt
write proof chain, and explicit administrative authority. It asks for a direct
commit-object comparison and a narrower description of private isolation.
`commit-source-verification.json` records actual `git show`/object-ID checks for
27 inputs against source candidate `28ba18c446f72084ff11b4d125dccf93bf8f4162` and
the executed manifests; all match. This bridges earlier dirty execution-start
HEADs without relabeling their historical records. The runner-control report now
distinguishes its initial revision from its final 36-case revision.

The component-locality theorem proves unchanged cells whose selected component's
`canWrite` predicate is false. It does not additionally prove a generic theorem
identifying every foreign private cell as denied by every valid catalog. That
identification is checked in the funded composed private/shared/read-only fixtures.
No general private-state noninterference result is claimed. The frame theorem's
explicit support and write-disjointness premises retain their full stated proof.

The 12 mutations include interface write-check bypass, not read-check bypass or
separate removal of each new structural catalog check. Those structural changes
have negative runtime siblings. The fixtures do not discriminate re-evaluating a
receipt against a different state when effects are state-independent; the generic
extraction/correspondence proofs supply that guarantee for accepted source.
These mutation limits are recorded rather than called complete branch coverage.

Grok's final combined review also returns ACCEPT WITH LIMITATIONS. It finds no
remaining source defect that reopens the exporter, snapshot-domain, composed
write, or administrative-authorization findings. It confirms that output access
is enforced by catalog validation before execution, while the standalone
`checkAccess` helper alone does not validate output selections. Receipt writes
are the declared footprint; successful actual effects are contained in it by
`writesOK`.

Both required final reviews examined the same frozen source and bundle. Exact
requested/reported model identities, timestamps, hashes, exits, and raw response
paths are in `review-summary.json` and the individual invocation records. Grok
requested `grok-4.6` and reported `grok-4.6-build`. Fable requested and reported
`claude-fable-5-1`; its native usage also records an auxiliary Haiku call. We do
not relabel that usage or claim either provider independently ran Lean.

An additional, optional Fable review of the later commit-binding documentation
returned a provider credit-limit error (exit 1). It remains an unavailable optional
review, not an approval. The two required final reviews had already completed.
The stock harness directly verified the 27 committed inputs; that evidence and
the narrowed claim language resolve the records findings by adjudication, without
attributing approval of the added artifact to Fable. No implementation bytes
changed after the reviewed candidate.

The independent artifact check records 990 assertions and zero failures in
`integrity.json`. It reconstructed mutant fixtures and checked saved artifacts;
it did not rerun the suites. The corpus regression log records 20 tests but has
no separate complete input-source manifest; preserved baseline file identities
and this limitation remain explicit.

No blocking source finding or required review remains open. Accepted scope is
conditional sequential preservation and the stated finite reference evidence.
Broader isolation, provenance, composition, and deployed fidelity remain roadmap
work. Delivery is recorded separately in `delivery.json` after the branch push.
