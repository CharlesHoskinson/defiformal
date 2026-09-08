# Proofs r3 focused independent review

**ACCEPT WITH LIMITATIONS for the six generic proof modules and P1/P2 corrections.** Both required findings in `proof-preliminary.md` are resolved. No blocking semantic issue was found in this bounded layer. This is not acceptance of instantiated financial or causal claims, binary correspondence, runtime mutation evidence, or Sprint11.

GPT-6 reviewed as nonauthor checker. The preserved native stream ends with session `01a07ef5-f614-7763-9d03-72a0d634c862` and actual model-usage key `grok-4.6-build`; requested model `grok-4.6`. Its compressed stream's decompressed SHA256 matches the parent-owned native identity record.

## Exact source and execution evidence

| Module | SHA256 |
| --- | --- |
| Soundness | `8c1969b069ae893a350679963c48f24fac9bf3325645c2a5327317c1360baa23` |
| LocalOrder | `6006dd4610e25603606b86c46ab00fc626680d02fd4604a65af91b9a848111ed` |
| Trace | `10d0d4cb8f9419aa3a7dfb4d0a16204fd7e96d2051d8d9eabbaba39b63c7e94c` |
| Completion | `3563dbb15ae4af53a434cdf2080118b29e65dc3a148c78e4cb2e7336c0649847` |
| Preservation | `dcecd9cd2567260b52b25dc9ca682ea3279f2b745e3e02cf44e70dc4cef15fe9` |
| Interference | `82a0cf1ad4ba38d8c0be3b0c84b92ec54388e582407c510839ad85c7914a93fe` |

Each live module equals its recorded hash, preserved r3 snapshot, and private-cache source. All seven final saved statuses state `exit=0`: one combined six-module build and six fresh source elaborations. Their stderr files are empty; the combined log records successful build completion. Earlier iteration evidence is retained.

Independent command: `lake env lean --stdin`, cwd `/home/charl/.cache/defiformal-sprint11-builds/proof`, using exact stdin saved in `proofs-r3-introspection.lean.txt`. It exited **0**, stderr empty. The 19,254-byte stdout is saved untruncated. It prints full `@` statements and imported axiom dependencies for 21 declarations covering the new cell/history/index results and existing projection, refusal, completion, authority, analyzed-frame and interference claims. All 21 depend only on `propext`, `Classical.choice`, and `Quot.sound`; no `sorryAx` or new assumption appears in these theorem dependencies.

`proofs-r3-inputs.json` records absolute paths, hashes, sizes, mtimes, exact command/stdin binding, all 21 declaration names, axioms, and 33 private local source dependencies. Sources, saved evidence, and captured compiled artifacts were unchanged before/after the command. The manifest has 156 captured inputs; the native identity and compressed stream were captured after the before/after loop. The four private core source files match the preserved core-r3 snapshots. This review does not claim to rebuild imported Mathlib or the later live Observation binary additions.

The first independent Lean inspection exited 1 because checker-supplied `pp.width` is unsupported in this Lean version. Its stdin/stdout/stderr remain as `proofs-r3-introspection-attempt1.*`. Removing only pretty-print options produced the successful run above. A preceding source-evidence probe corrected its parser from bare `0` to the saved `exit=0` status syntax before invoking Lean. Neither issue was a feature proof failure. No root-cache build or feature edit occurred.

## P1: exact signed cell accounting

Preservation:33 defines each successful attempt's cell effect using actual `Interface.receiptCellEffect`; error attempts contribute zero. Machine effects sum over stored attempts. The accepted Interface definition and bridge were inspected: effects are signed receipt deltas at the requested cell, and `Interface.step_receipt_cell` derives the balance equation from an actual successful `executeStep` equation.

Preservation:144–174 gives an arbitrary-entry step/continuation equation:

`post.balance cell = entry.balance cell + (post.cellEffect cell - entry.cellEffect cell)`.

This subtracts pre-entry stored effects and does not charge fabricated or earlier entry receipts again. The accepted-step proof calls `Interface.step_receipt_cell executed cell`; errors and skips preserve the world and add zero. The continuation theorem has no reachability or desired final balance premise.

Preservation:178–194 gives the separate genesis telescope and executable `runPrefix` corollary: current cell balance equals initial cell balance plus actual accumulated signed effects. Reachable is derived from `start` and actual dispatcher step cases; it does not encode the target accounting conclusion. Domain-total supply remains a separate theorem. Thus P1 now accounts for transfer routing at each cell, rather than using total neutrality as its substitute.

## P2: exact history, raw worlds, and indices

Trace:34 defines `ownHistory` by filtering the global attempt prefix for this participant's successful events and flattening their outputs. `Reachable.own_history` proves the current local output list equals that projection.

Trace:441 `Reachable.attempt_exact` takes only genesis reachability and lookup of the actual stored attempt at global index `i`. Its compiled conclusion gives all three facts:

1. `executeStep` at the recorded participant/index/boundary/raw before world, using precisely `ownHistory (attempts.take i) participant`, equals the stored full error/success outcome.
2. The stored attempt index equals the number of preceding successful events of that participant.
3. The strict global attempt prefix forms an `AttemptChain` ending at the attempt's actual before world.

The proof extends real accepted/refused steps and transports old entries through append; it does not assume an existential replacement history or the target trace theorem. `AttemptChain` alone is a structural world-chain relation, while `attempt_exact` supplies the actual execution equation. Their conjunction avoids mistaking mere chained fabricated records for execution.

Trace:336 proves the stronger stored index sequence, `events.map Event.index = List.range events.length`; Trace:373 derives `event.index = n` from actual lookup at local slot `n`. These are stronger than nextIndex equaling event count. `runPrefix` corollaries derive reachability. The statements correctly exclude arbitrary synthetic entry histories; arbitrary-entry continuation remains supported by separate execution laws rather than an unsupported genesis claim.

## Existing layer checks and limits

Interference remains generic over arbitrary `B` with decidable equality, without `Fintype B`. Its local obligation assumes the participant's own invariant and an actual selected invocation success, then requires its own invariant and guarantee. Peer preservation comes separately from cross-inclusion and stability. Initialization is a separate simultaneous premise and the proof inducts over actual reachable steps. `continueRun_invariants` explicitly requires a genesis-reachable entry. No desired final theorem is used as a premise.

Analyzed frames use successful `analyzeAll`, participant coverage/roster and untouched analyzed write union, then derive locality through actual step equations. Predicate frames additionally require real support. Authority refers to each successful attempt's actual before world and participant/index boundary, with a separately derived initial capability-store identity. Local order, branch projection, first-refusal stability and complete exhaustion-or-refusal remain present and were included in the compiled statement checks.

These generic conditional lemmas do not discharge a concrete financial instance by themselves. F18/F19 total/binding instances must prove their own receipt/support/neutrality/paired-effect obligations. The causal witness must independently establish initialized provenance/reserve and actual complete-schedule success. Binary specialization, its runtime direct comparison, integrated fresh build/audit, all sixteen real mutation runs, and final complete imported-axiom coverage remain separate gates. The 21 inspected axiom inventories are a targeted proof-layer check, not the final global inventory.
