# P17 concrete planning acceptance

Root adopts the exact native Opus ACCEPT_WITH_LIMITATIONS verdict for candidate `fe36fb051a97aac8ca3f7cdfec037d4faf9351fa0447c909f2353504d921f0fe`: 67 files (19 planning, 23 retained r1 evidence, 25 r2 evidence). This accepts the concrete source-entry/reuse design only. Grok 4.6 authored (reported `grok-4.6-build`, process 0/end_turn); native Claude requested `opus`, reported `claude-opus-5`, process 0, session `592b28fb-72ff-4f06-ae10-bd25d0c59855`, finished 2026-09-09T17:19:46.407494+00:00. The existing GPT-6 review retains its original identity. User authorization supersedes historical future-reviewer flags; frozen plan/checklist/evidence bytes remain unchanged.

R1–R3 are closed for planning. Independent review ran strict OpenSpec (0), intact 199 checks (0), wrong literal (1), empty/unavailable (3), a source-derived model with 82 checks over 16 fixtures, and 21 falsifying controls with intact controls. Root verified all 67 candidate files and 91 input/output evidence hashes, final report/native log hashes and actual terminal receipt before adoption. These are planning checks and evidence binding, not Lean proofs or EVM execution. The review verdict's static `utc` field is not the execution time; the native process receipt supplies actual start/finish times.

## Complete post-state interpretation adopted verbatim

the JSON `expected.post` dictionaries are sparse assertions, despite design prose calling them complete. The complete selected post-state is the fixed pre-state plus the source/mock changes: entry debits sender USDS, credits vault USDS, consumes finite allowance, credits receiver shares and increases share supply; exit debits owner shares/share supply, consumes finite share allowance when applicable, debits vault USDS and credits receiver USDS. All other observed cells are unchanged in this stable-time domain. This is the complete common transition rule used for this acceptance; it does not permit omitting observed cells from future comparison.

## Native Opus section 7 adopted verbatim

**#1 — sparse `expected.post`, all other observed cells unchanged. SOUND; adoptable only if the
GPT-6 wording is recorded verbatim, and it does not retire repair RR-2.**

Soundness is independently established, not assumed: 9/9 success fixtures have every omitted observed
cell unchanged under my source-derived model, and control `c6` proves that check fires. GPT-6's wording
is precise enough to adopt — it states the complete transition (entry debits sender USDS, credits vault
USDS, consumes the finite allowance, credits receiver shares, increases share supply; exit debits owner
shares and share supply, consumes the finite share allowance when applicable, debits vault USDS,
credits receiver USDS; all other observed cells unchanged in this stable-time domain) and explicitly
adds that it *"does not permit omitting observed cells from future comparison."*

But it is **not explicit in the candidate**, and this is not a gloss over a silence: `design.md §6`
affirmatively states the opposite. An editorial interpretation that contradicts a sentence in the
artifact is a correction, and per `defi-footguns` a stated limitation is a claim like any other.
Adopt it for this freeze **and** carry RR-2, so the artifact and its interpretation do not permanently
disagree. One caveat on the wording: no success fixture exercises the "consumes the finite share
allowance when applicable" clause (F5), so that clause is currently vacuous.

**#2 — the overwritten initial failed diagnostic. SOUND as to substance; NOT explicit enough as
stated, and it understates the problem.**

GPT-6 correctly identifies the contradiction and correctly rules the concrete failure record
authoritative over the opening denial. But its `verdict.json` records `required_edits: []`, which
leaves a receipt that denies its own content standing in the accepted bytes; and it does not note that
`REPORT.md` and `commands.json` omit the failure too, nor does it test whether the narrowing was
legitimate. I did test it (F1): the narrowing is substantively correct and the r1 requirement is not
violated. Adopt the interpretation with that reconstruction attached and with RR-1 required, not as a
no-edit gloss.


## Binding implementation repairs and gates

RR-1 through RR-5 in [the native review](p17-planning-r2-opus-review/REVIEW.md) bind the implementation candidate. The reviewer's reconstruction is retained at `p17-planning-r2-opus-review/work/checks/prenarrow_recon.py` with its manifest-bound output. It establishes why narrowing the original control predicate was legitimate; it does not recreate the overwritten failed execution artifact. Correct the historical failed-attempt account explicitly, all 19 post-state observations, zero-asset allowance rationale, missing falsifying controls and delegated-exit success coverage. The [implementation brief](p17-implementation-r1-queued-brief.txt) requires a successful delegated exit, not merely a deferred gap.

Preserve the frozen plan and original receipts. Publish explicit implementation errata/transition records and corrected current fixture/command records, identifying the exact historical claims they supersede. Never silently replace evidence or manufacture an initial failed JSON. This is authorized implementation of the accepted design with binding review corrections, not a third planning-only review cycle.

`planning_accepted=true`. `implementation_accepted=false`, `source_execution_accepted=false`, `platform_reuse=false`, `wider_family_gate_open=false`. This acceptance contributes the design part of program task 18.1 and authorizes tasks 18.2–18.7 under their real evidence gates. Actual source entry/setup and all substantive reuse obligations remain open. P16 scoped source acceptance already exists independently and is unchanged. No mainnet/deployment, accrual/rpow, permit/UUPS/L2, P21/P30, composition or whole-program claim is added. Atlas remains parked.
