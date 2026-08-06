# Convention 6h — caller authority

**Every re-spec must model who may call each state-changing action, or declare
the omission explicitly with the contract line it drops.**

Status: proposed. Sits alongside convention 6g (dependency parity) in
`P2-CONTRACT`.

---

## Why this is not optional

Three independent findings converged on it:

1. **`GATE-1.1B-PAIR4.md`** — the deferred-claim cluster (`WITHDRAWAL_QUEUE`,
   `DelayedExit`, `ASYNC_REQUEST_CLAIM`, `TWO_PHASE_CUSTODIAN_REQUEST`) differs in
   exactly one place: what opens the gate. The separating law is autonomy — can
   the holder claim without another party's cooperation. **0 of 17 gate-opening
   actions model any caller**, so all four score autonomous and the law cannot be
   evaluated. Phase 1 is blocked on this.
2. **`DELETION-11.md`** — 4 confirmed deletions where an action's own comment
   asserts a restriction its code does not model (`coinbase.mint` "onlyCallers",
   `usdc.configureMinter`, `wbtc.confirmMint`, `wbtc.rejectMint`). All three
   affected specs are outside `P2-SCOPE`'s ten.
3. **`REFUTER-DELEGATED-ALLOCATION.md`** — the corpus's most-confirmed gap is a
   mechanism *defined* by caller authority, and it has never been formalised
   because there is no way to write it down.

## The convention

For every external state-changing function a re-spec covers, the spec must do
one of:

**(a) Model it.** Take the caller as an explicit argument and guard it against
modelled authority state:

    action confirmMint(caller: str, id: int): bool = all {
      caller == custodian,        // Factory.sol:54 onlyCustodian
      ...
    }

Authority state (`custodian`, `isAllocator`, `curator`, `owner`) is `var`, not a
constant, whenever the contract lets it change — otherwise the *granting* of
authority, which is itself a mechanism, is deleted.

**(b) Declare the omission**, in the spec header, naming the contract line and
the direction:

    AUTHORITY OMITTED:
      confirmMint  Factory.sol:54  onlyCustodian
        (E<=) one custodian, modelled as a constant; the spec cannot express
        custodian replacement, so `submitGuardian`-style transitions are absent.

A declared omission is a restriction the reviewer can see. An undeclared one is
indistinguishable from a mechanism that never existed. **`wbtc.addMintRequest`
hardcoding `requester: MERCHANT` is what (b) looks like when done accidentally;
`wbtc.confirmMint` taking `(id: int)` is what a deletion looks like — and today
a reviewer cannot tell them apart.**

## Scope, and what it costs

**Not** a demand that every spec model full RBAC. The obligation is one line per
state-changing action: name the caller and the guard, or name the omission.

Branching cost is bounded. Authority is usually a small enumerated set — one
custodian, one curator, a two-element allocator set — so convention 8a's cap of 8
enumerated values per `nondet` is not threatened. Where a role is genuinely
open-ended, model two principals: one holding the role and one not. That is
enough to host every witness the autonomy law needs.

## Lint

Half is mechanisable, as with 6g:

- **D7a** — an action whose doc comment matches `only[A-Z]\w+` /
  `msg.sender ==` / "permissioned" / "authorized" and whose signature has no
  caller-ish parameter and whose body reads no authority state.
- **D7b** — a spec with an `AUTHORITY OMITTED` block naming an action that does
  not exist, or an action guarded against authority state the spec never writes.

`sigma/deletion11_scan.py` is a working prototype of D7a. **Two cautions from
building it**, both of which cost a false-positive round:

- `owner` is a *field* of `QueueItem` / `AsyncRequest` / `CustodianRequest`.
  Matching it as a caller check scores `r.owner` and `hd.owner` — record reads —
  as authority guards. Require a non-field position.
- `usdc.mint` models its authority via `canMintWithAllowance(isMinter,
  minterAllowed, minter, amount)` with a lowercase `minter` parameter. A detector
  keyed to `caller`/`sender` alone reports it as a deletion. Accept any
  parameter that is subsequently used in a guard against authority state.

The classification itself is not mechanisable — deciding whether a given
omission is a legitimate `(E<=)` restriction needs the contract. As with 6g, that
half is a reviewer checklist:

1. Does the contract restrict this function to a role?
2. Does the spec model the role, or declare the omission with the line?
3. If modelled: can the role itself change on-chain, and does the spec allow it?

## Cost of adopting it late

The ten v2 re-specs are already written and none carries authority. Retrofitting
is real work. The alternative is that 2.2's twenty-one new specs inherit the
defect, and Phase 1 stays blocked on a corpus that grew without ever gaining the
one thing it needs.


---

## 6h addendum — the surjectivity test, and the FROZEN verdict

Both came out of applying 6h to the ten re-specs; see `sigma/APEX-LIQUIDATE.md`
and `sigma/SURJECTIVITY.md`.

### When is an OMITTED entry sound?

> An omission is `(E<=)`-safe iff the **transition** is reachable by an arbitrary
> principal along some path — not iff the function is directly callable.

Relay patterns are surjective and safe to omit: apex's `Margin.liquidate` is
`routerMap`-gated but reached by any user through an open `Router.liquidate`;
huma's `distributeProfit` requires the caller to *be* the `Credit` contract, yet
any borrower's `makePayment` causes it.

Role grants are not surjective and are **unsound** to omit:
`uniswap_v2.setFeeTo` (`feeToSetter`, a closed cycle), `huma.disburse`
(`LENDER_ROLE`, granted by a pool operator), `huma.closePool`
(`onlyPoolOwnerOrHumaOwner`).

### A third verdict

> **FROZEN** — the guard is present, but the authority is a constant where the
> contract mutates it.

`huma.qnt:463`'s `pure val LENDERS` is the example: lender status is guarded, and
the contract grants and revokes it via `addApprovedLender`/`removeApprovedLender`
(`onlyPoolOperator`). Freezing is sound as an `(E<=)` restriction on role
configurations **and deletes the grant mechanism**, which is `Perm`'s first law.

**FROZEN is where a mandate hides.** A frozen role set cannot exhibit a
grant witness, so the permission coordinate is present but cannot be shown to be
contingent.

### Known defect in the tooling

`phase2/auth_scan.py` scores MODELLED on a caller-ish first parameter, not on a
guard against **mutable** authority state, so it reports FROZEN entries as
MODELLED. huma's four are FROZEN. The MODELLED count is inflated accordingly and
must not be quoted until the scan distinguishes `var` from `pure val`.
