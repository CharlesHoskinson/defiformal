# P26 IBC source-preparation audit

Continuing session `01a08d48-bd88-7c83-b189-1f491bc7e5df`. This is reporting closeout of the original 20-turn audit, not a second reviewer. Requested model: native Grok 4.6 high. Original actual model: `grok-4.6-build`. Closeout actual model follows this run's native telemetry.

**Verdict (source preparation only): usable.** Observation mapping is required. Changes are not required for packet identity. P26, P29, and tasks 27.1–27.3 are not accepted. This closeout does not accept the review package as a completed program gate.

## Path bases

- Parent (immutable): `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p26-source-grok-r1`
- Original cap outputs: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p26-source-grok-r1/original-terminal`
- Closeout write: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p26-source-grok-r1/closeout`
- Frozen sandbox (not re-accessed in closeout): `/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox`
- Packet: `.../p26-ibc-source-preparation`
- Root verifier evidence: `.../p26-ibc-root-verification`

Cited selected-source paths below are relative to that packet `source/` tree.

## Scope

Observed official ibc-go main HEAD commit `8a7d8134b7f7cedb3a2809ad3797717f38e44293`, tree `d9c9af96ebb809bf6eab6bd6c93989ec86dc71a8`. Not a deployed chain identity. Root packet seals 44 files, including 33 selected source/config/reference-test files and 15 static navigation anchors. Four Go test files were retained without execution. Full archive has 1890 regular members; only 33 selected Git blob identities were claimed checked. Original archive SHA-256 `19bb3a2a613695e843c9534fa8cae44aa3b8ccfd0fb20c92cc6df8280abf8f9e` (26505290 bytes). Historical cache path was remapped to the sandbox archive; live cache was not followed.

No import closure is claimed. Go 1.26.5 / ibc-go v11 / SDK v0.55.0 / CometBFT v0.40.0 are source declarations, not installed runtime identities. Root verification is source-identity evidence, not proof or runtime execution. The original 38 identity checks and 30 excerpts are source inspection and hash evidence only.

## Original cap and closeout

Original process exit 1, stop reason `cancelled`, 20 turns, finished `2026-09-10T21:54:55.903620+00:00` (`original-terminal/process.json`). At cap, `verdict.json` and `findings.json` were substantive; `REVIEW.md`, `commands.json`, and `MANIFEST.json` were placeholders. Closeout writes only under `closeout/`. Parent and sandbox were not mutated. No new probes, builds, downloads, or sandbox access.

## Identity result

Recorded identity probe (`original-terminal/raw/identity_probe.command.json`): argv `/usr/bin/python3.14` plus `probes/identity_probe.py`; cwd the frozen sandbox; start `2026-09-10T21:52:02.272251+00:00`; end `2026-09-10T21:52:03.485576+00:00`; exit 0; 38 checks; 0 failures; empty check false; altered in-memory `packet.go` byte rejected with `source byte identity mismatch`; source file unmodified. Exit 0 is not used alone: the denominator is 38 and the negative control fired.

Commit, tree, HTTP 200 bindings, archive hash/size/1890 members, 33 source bytes, 33 Git blobs, 33 archive members, 15 anchors, go.mod declarations, and root-verifier seals reproduced against the sandbox archive.

## Required observation mapping

Ordinary unordered duplicate receipts and older ordered receive sequences return `ErrNoOpMsg` internally (`packet.go:199-206`, `224-229`). Public `RecvPacket` maps that to `MsgRecvPacketResponse{Result: NOOP}, nil` and returns before the application callback (`msg_server.go:439-441`). Ack and timeout have corresponding public NOOP paths (`msg_server.go:605`, `505`). TimeoutOnClose also NOOPs ordinary duplicates (`timeout.go:196-202`, `msg_server.go:551-553`) and must be retained; it is not a navigation anchor.

Earlier guards can run first. Channel not OPEN, elapsed receive timeout, and proof failure are actual errors. Sequence below `recvStartSequence` returns `ErrPacketReceived` (`packet.go:190-191`). Ordered future sequence returns `ErrPacketSequenceOutOfOrder` (`packet.go:234-237`). Do not invent a transaction-error model for ordinary replay. If 27.1's required executor-refusal scenario cannot be instantiated faithfully, select a different workflow or freeze an explicit reviewed mapping.

Successful ack deletes the source packet commitment (`packet.go:437`) before the application ack callback. Ordinary timeout requires maturity at proof height/time (`timeout.go:68-71`) and verified remote non-receipt (ordered next-sequence proof vs unordered `VerifyPacketReceiptAbsence`, `timeout.go:91-110`). Empty local commitment is NOOP, not the entire timeout guard. `timeoutExecuted` deletes the commitment and closes an ordered channel (`timeout.go:135-141`).

ICS-20 successful ack does not refund (`relay.go:220-224`). Error ack and timeout refund by unescrow or voucher remint according to asset origin (`relay.go:225-228`, `235-242`, `277-291`). Refund can fail, including blocked sender (`relay.go:261-262`) and unescrow failure (`relay.go:316-321`). Packet README says “blocked recipient”; the refund guard is sender. Receive blocks a blocked receiver. Pin the sender guard in 27.1.

Verified misbehaviour freezes Tendermint client state and returns success (`client.go:60-74`, `update.go:211-217`). That is not automatic packet refund. `SendPacket` requires Active (`packet.go:61-62`). `VerifyMembership` requires Active (`02-client/keeper/keeper.go:343-344`). RecvPacket's `VerifyPacketCommitment` uses that membership helper after earlier guards. This does **not** prove that a frozen client blocks every recv, timeout, or ack: ack and timeout empty-commitment NOOP paths run before proof verification, and other guards can run first. Unordered timeout/TimeoutOnClose call `VerifyPacketReceiptAbsence`; that nonmembership implementation was not excerpted and is not proved by the membership Active check alone. `RecoverClient` (`client.go:118-145`) can restore a non-Active subject from an Active substitute without refunding pending packets. Keep freeze, recovery, and proof-status assumptions explicit.

Local SDK nested caches are not remote rollback. RecvPacket writes the receipt via `CacheContext` `writeFn` before the application callback (`msg_server.go:433-458`). Timeout writes then calls `OnTimeoutPacket` on the parent context (`msg_server.go:497-516`). Local transaction abort is not undoing the counterparty.

Oracle, custody, legal, sequencing, finality, and proof authenticity remain explicit future contract obligations.

## Remaining program work

Task 27.1 still needs a concrete workflow and frozen observation/assumption contract plus independent review. Tasks 27.2 and 27.3 need Lean implementation and proofs, first-delivery success, replay refusal, double-terminal mutation, and a source-independent two-terminal negative. P29 complete cross-domain accounting is separate and after P26. No narrowed substitute acceptance. Full roadmap unchanged.

## Command record limits

`python_identity` has `original-terminal/raw/python_identity.command.json` and no raw stdout/stderr file; hashes absent from that record are not invented. Two parent shells (directory setup; later hasher) have exit 0 and no captured UTC. Capture scripts, Makefile, Go tests, and network were not executed. See `commands.json`.
