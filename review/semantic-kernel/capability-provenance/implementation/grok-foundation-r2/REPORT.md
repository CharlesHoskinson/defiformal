# Capability provenance foundation r2

Native Grok 4.6 author. Independent GPT-6 is the checker and is not this turn. No Foreman. No commit, push, task-checkbox closure, or self-acceptance.

r1 remains historical. Frozen r1 archive `review/semantic-kernel/program-loop-20260908/native-worker/capability-foundation-r1-stage.tar.gz` SHA-256 `64e03cc18d04fb88cb732d7a3b523bbdefc3be801b311366df245d6dce024f27`. Live r1 source bytes were snapshotted under `before/` and matched r1 `owned-source.json`. GPT-6 r1 review was not present at start; no diagnostic findings to apply.

## Bound

Finish the three r1 REPORT query/revocation results for assigned tasks 2.1–2.6 / 3.1–3.2 / 4.1–4.2. Isolation, F01–F20, mutations, Audit/Verify, and root import stay later.

| File | r2 SHA-256 | vs r1 |
| --- | --- | --- |
| `Origins.lean` | `2ff9ba9d09a698335c8051e3bb7a7fc0239d8a1120ef622f979d3bc1c84ccf89` | unchanged |
| `Observation.lean` | `79110900be9d394dfe0ff8ae58c48047f958e9142c83401e15242da4dcd5e667` | unchanged |
| `Trace.lean` | `784cabc720b7b094281a374718d5090ffc2a0ace41c3dd2559328f0fc95f8ff4` | updated |
| `FoundationChecks.lean` | `49c6416a8bcca2903209a8f39730f7bfc87e499092abf8f4dde07c89b534b3f5` | updated |

Head `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. Accepted Typed/Composition/Atomic/Nary, root `DefiKernel.lean`, plans, and harness were not edited. 65 Metatheory controls were not rerun: bound old dependencies unchanged.

## Closed r1 remaining results

### 1. `originOf` completeness iff

`originOf_iff` under actual `TraceSound` and `RootsAccepted`:

```
originOf initial events id = some origin ↔ OriginAt … id origin
```

Covers `.initial` and `.issued` (full grant, absolute index). Issued completeness uses `originAt_issued_not_initial` (so initial lookup is none), `issuedOrigin_of_unique`, and `originAt_unique` on actual issue receipts. No “query returns the desired value” premise. Forged event lists remain data-only: `issuedOrigin` can still read them; `OriginAt` requires the issue equation.

### 2. `currentAuthorityOrigin` iff on initialized cursors

Runtime algorithm (no trace, not a certificate):

`currentAuthorityOrigin_eq_some_iff`: `some (id, origin)` iff `ids = pref ++ id :: rest`, every `pref` ID fails **current** `authorizesId`, `id` authorizes, and `originOf` is `some origin`.

Initialized correspondence:

- `currentAuthorityOrigin_iff`: same first-ID prefix, current `authorizesId`, and `OriginAt` (origin proved, not assumed).
- `currentAuthorityOrigin_none_iff`: `none` iff every requested ID fails current `authorizesId` (authorized IDs have origins on a valid trace).
- `currentAuthorityOrigin_of_hasAuthority`: existential `hasAuthority` implies the query returns the **first** authorizing requested ID, which may differ from an arbitrary witness.

Does not assume ID uniqueness or initial=current store equality.

### 3. Prefix revoke → dead at final

`trace_prefix_revoke_dead_at_final`: a successful `.revoke rid` event in an initialized prefix has a dead tombstone at the event result **and** at the final store, same grant. Uses `stepSound_preserves_dead` on the suffix, not a renamed desired conclusion.

`issued_after_revoke_fresh`: a later successful issue of an equal grant uses a strictly larger fresh ID (`nid ≠ rid`) and the revoked ID stays dead.

`refused_admin_inert_suffix` is `continueRun_failed` under a located failure.

## Foundation checks

Original 22 names remain and still pass. Seven added independent literals, all true (29/29):

- two equal grants → IDs 0 and 1, issued origins at indices 0 and 1
- after issue/revoke/issue: `originOf` 0 still issued; current authority on `[0]` is none; `[0,1]` returns first live ID 1 at index 2
- old ID dead, new ID live, same grant; rejected-admin suffix inert

Corollary instances: `issuedCursor_originOf_iff`, `nonempty_dead_originOf_iff`, `twoIssue_originOf_iff`, `reissue_current_none_iff`.

## Axioms and inventory

`#print axioms` on the new theorems: only `propext`, `Classical.choice`, `Quot.sound`. No `sorry` / `native_decide` / custom `axiom` in owned source. Declaration inventory: 158 names, 91 theorems.

Failed compile attempts kept under `failed-attempts/`.

## Assigned P/I coverage for this slice

| Tasks | Status |
| --- | --- |
| 2.1 OriginAt / RootsAccepted | r1, unchanged |
| 2.2 causal completeness / unique | r1 `originAt_complete` / `originAt_unique` |
| 2.3 allocation, persistence, distinct IDs, nonreuse | r1 count/persist + r2 `issued_after_revoke_fresh` and duplicate-grant checks |
| 2.4 initially dead + later revoked tombstones | r1 `trace_dead_stays_dead` + r2 prefix-revoke theorem |
| 2.5 current pre-store invoke/debit/supply origins | r1 `accepted_invoke_current_authority` |
| 2.6 rejected admin prefix, precedence, inert suffix | r1 advance/error lemmas + r2 named inert suffix |
| 3.1 originOf / currentAuthorityOrigin iff | this r2 |
| 3.2 auditRun delegation | r1 |
| 4.1–4.2 observation policy / capEq / viewEq | r1, Origins/Observation bytes unchanged |

Not claimed: Isolation (4.3–4.6), F01–F20, mutations, production Audit/Verify, root import.

This is a complete assigned-foundation candidate for independent GPT-6, not implementation acceptance.
