# Vacuity

**Claim.** A checker that examined nothing reports success unless you stop it.
These are the dangerous ones, because a green pass invites no investigation.

## The measured cases

| gate | what it printed | what it had examined |
|---|---|---|
| `sigma/verify_final.py` | `X21-armed pairs (60-app basis): 0 of 0`, exit 0 | nothing — its glob matched zero files on every tree but the author's |
| `formal/v3/validate.mjs` | `0 specs, 0 rejected`, exit 0 | an empty directory |
| `gate33_cert_check.py` | `PASS 0 files` | an IR directory with no JSON |
| `totalgate.mjs` | `all headline totals agree with the verdicts`, exit 0 | **no assignment at all** — every `functionalObligations` array was `[]`, so each file was counted and none contributed |

The last is the first silent PASS of the project and the worst outcome it
produced. A false failure sends someone to look. A false pass ends the enquiry.

## Why count-based guards were not enough

The first three fixes were count-based — zero versus non-zero. The defect is
**completeness**-based, and three rounds in a row found the gap:

- `[]` **is** an array, so a type check passes and the loop runs zero times.
- A zero-file guard says nothing about **four files of five**: one remains, the
  guard stays silent, `approx` comes up short, and `strict` is compared. Measured:
  `FAIL strict coverage 29.5%` against the paper's 29.0%, exit 1, and
  `BUILD FAILED: a headline total disagrees` — about a file that was deleted.
- A non-empty array says nothing about a **truncated** one.

## The rule

1. **Zero examined is a blocked check**, exit 3 — never a pass, never a
   content verdict.
2. **State the denominator in the output.** The gate now opens with
   `ok   walked 12 categories, 60 spec files, 60 verdict records, 1259 obligation items`.
   A reader can see what it counted.
3. **Prefer an invariant over a count.** See
   [cross-source invariants](cross-source-invariants.md) — the fix that finally
   closed this class needs no hardcoded corpus size at all.

## Related

[Blocked is not failed](blocked-is-not-failed.md) ·
[Cross-source invariants](cross-source-invariants.md)
