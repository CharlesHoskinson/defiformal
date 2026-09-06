# Independent review and verification record

Implementation used GPT-6 (`gpt-6-astra`) through the stock Codex harness.
Codex launched Grok and Fable's native CLIs directly. Foreman was not invoked.
Reviewer judgments are source analysis, separate from the Lean execution evidence.

## Candidates and observed checks

| Candidate | Observed verification | Scope |
| --- | --- | --- |
| `150c2accb31700d2c7267eb8152b02d36c815605` | Full build exit 0; 25/25 runtime checks; 43 named theorem axiom disclosures; six source mutations discriminated | Original finite pilot |
| `9e9a2bfe6a3c85785fd3fb845bba6c7765481e22` | Full build exit 0; fresh audit exit 0 with 33/33 runtime checks; 51/51 declarations/disclosures; seven source mutations discriminated | Revised examples, tests, scope documentation and portable mutation reproducer |

The revised mutation run captured HEAD `9e9a2bf`, clean input source paths,
per-file hashes, toolchain and dependency hashes, and unchanged inputs after
the run. Other working-tree paths contained documentation/evidence changes;
the result records that dirty state separately from the clean tested inputs.
The parent compared input hashes with the committed candidate objects.

Mutation scope is all 22 current `check`-based acceptance contracts. It does not
mutate `execute` or sequence behavior. Those behaviors have separate direct
acceptance proofs and runtime checks. The unmodified source lift must execute
22 true comparisons before any mutant is judged; each mutant must produce an
explicit false comparison. A compilation error alone is not a detection.

## Native reviewers

| Round | Reviewer requested | Native response identity | Disposition |
| --- | --- | --- | --- |
| R1 | `grok-4.6` | `modelUsage` reports `grok-4.6-build` | Spec pass; implementation pass; no findings |
| R1 | `claude-fable-5-1` | Main response usage reports `claude-fable-5-1`; CLI also reports an auxiliary Haiku call | Spec pass; implementation changes requested |
| R2 | `grok-4.6` | No response; process timed out after 600 seconds | No verdict from this attempt |
| R2 retry | `grok-4.6` | `modelUsage` reports `grok-4.6-build`; native `stopReason` is `end_turn` | Spec pass; implementation pass; requested corrections realized |
| R2 | `claude-fable-5-1` | Main response usage reports `claude-fable-5-1` | Spec pass; implementation pass; all actionable R1 findings resolved |

Both members received the same original bundle within each round. `r1-manifest.json`
and `r2-manifest.json` identify the candidates, reviewed files, evidence and
bundle hashes. Invocation records preserve argv, requested model, timestamps,
process status and native response hash. No GPT response was substituted for
either requested reviewer.

Grok's full R2 invocation timed out with an empty response. The failed invocation
and its empty output are preserved. A targeted retry on the unchanged candidate
uses `r2-grok-retry-bundle.md`: the exact R2 diff, unchanged core, original R2
manifest, and a clearly attributed summary of parent verification. Its separate
manifest identifies the reduced input. This retries the missing follow-up;
it is not a third review of a new implementation.
The retry completed with exit 0. Grok again reported loading an offloaded
prompt, so the empty tool-list request did not establish tool-free execution.

Fable returned a single-turn source review with tools disabled. Grok's native
CLI reported offloading the prompt and reading files despite the requested
empty tool list; its source review does not claim an independent build. The
initial invocation's tool-free description was corrected in the record.
Neither review is represented as an independently executed Lean verification.

## R1 findings and resolution

1. **Policy grants do not bind operations to financial transition shape
   (Fable, medium): confirmed by execution.** The three proposed operations
   are accepted by the original fixture policy. The revised source adds
   accepted checker and post-state witnesses for a vault drain without share
   burn, issuance without deposit, and debt erasure without repayment.
   `lean/README.md` and the fixture documentation explicitly state this limit.
   This adopts the review's minimum correction. A protocol-kind primitive is
   not introduced; capability contracts remain part of the later design.
2. **Mutation input binding and limited suite (Fable, low): addressed.** The
   R1 bundle had a separate source manifest, but the original recipe's results
   lacked direct input hashes/commit binding and tested only fourteen cases.
   The portable revised recipe captures those identities and checks all 22
   current checker contracts. The parent replayed it after the source commit.
3. **Zero-price test did not isolate positivity (Fable, low): confirmed.** Added
   zero-debt/zero-borrow refusal with zero price and an accepted positive-price
   control. Removing only the positive-price conjunct now falsifies exactly
   `isolated_zero_price_refused` in the mutation run.
4. **Audit command, liquidity docstring and disclosure maintenance (Fable,
   low): addressed.** README now names `Audit.lean`; the docstring distinguishes
   eleven requested shares from twenty held. The manual disclosure policy is
   explicit, and the parent checked exact equality of all 51 named theorem
   declarations, listed disclosures and observed axiom output.
5. **Quantity indices are not a complete dimensioned expression language
   (Fable, informational): retained as an open boundary.** Effects and prices
   still use rational values and supplied functions. Typed IR and richer
   dimension/clock/provenance semantics remain migration work.

## Reproduce

From the repository root, with the pinned Lean toolchain and dependencies:

```sh
cd lean
lake build
lake env lean DefiKernel/Audit.lean
cd ..
python3 review/semantic-kernel/2026-09-06/check-mutations.py \
  --repo . --output /tmp/defikernel-mutation-replay
```

The two native review rounds consume their saved `r1-bundle.md` / `r2-bundle.md`;
their exact CLI arguments are recorded in the matching invocation JSON files.
Model judgments can vary on rerun. Source and proof identities are fixed by the
manifests, not by obtaining the same wording from another model call.

Fable R2 retains low-priority follow-ups for an automatic axiom-disclosure gate
and durable evidence/ledger capture. The former is explicit backlog; the latter
is included in the final evidence commit. Its informational notes about the
source-format-dependent extractor and exclusion of execution mutations remain
recorded scope limits, not claims of coverage.

Grok's retry found no correctness regression and passed both dispositions.
One count in its prose is imprecise: it calls eleven audit theorems new, while
the exact named declaration count rises from 43 to 51 (eight new declarations).
The source, disclosure audit and manifest counts govern this record.

The initial migration increment is complete, with both requested reviewers'
follow-ups passed. The final evidence commit adds records and status only;
reviewed implementation bytes remain those of candidate `9e9a2bf`.
Raw bundles, logs and the diff preserve their original whitespace to retain
recorded hashes. Prose whitespace checks exclude those immutable artifacts.
The complete migration, financial policy enforcement, serialized certificates,
general composition, and deployed-contract fidelity remain open.
