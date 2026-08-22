# Blocked is not failed

**Claim.** A check that could not run and a property that is false are different
facts. Merging them produces the worst class of wrong answer: a confident,
specific, false statement that sends someone to the wrong place.

## The evidence

`paper/build.sh` line 49, as shipped:

```bash
node ../formal/v3/totalgate.mjs >/dev/null 2>&1 || die "a headline total disagrees with the verdicts"
```

Two faults in one line. The redirect discards the only diagnosis the gate
produces — here `EACCES: scandir '/root/defiformal/expansion'`. And `||` maps
*every* nonzero exit onto one editorial sentence.

Measured on a clean clone: both PDFs render, bibtex is clean, zero undefined
references, and all eight of `totalgate.mjs`'s predicates **pass** once the gate
can reach its input — 1259 obligations, 570 covered, 689 residue, 45.3%, 29.0%.
The totals agreed. The gate never ran.

A crash tells you to look at the machine. This told you to look at the
mathematics, where there was nothing to find.

## The contract

| exit | meaning | act on |
|---|---|---|
| `0` | the property holds over a non-empty corpus | nothing |
| `1` | the property is false | the manuscript |
| `3` | the check could not be performed | the environment |

`3` was not invented for this. `negtest-composition.sh`,
`negtest-footprints.sh` and `negtest-measurements.sh` already used
`sys.exit(3)` for `PERTURBATION DID NOT APPLY` — the check could not be
performed. Adopting the existing convention beat picking a free number.

## Where it hides

The contract is easy to state and was wrong in four more places after the
headline fix:

- **`gate.sh`'s `chk()`** judged on output text alone, so a harness that died
  could be called `ok` on a stray needle.
- **`loop2gate.sh`** got a `printf` announcing the blocked case while its
  *verdict* still came from `case "$b" in *"OK"*)`. The commit message said both
  callers now branched on the exit code. Only one did.
- **The three inline sites** in `gate.sh` (claims, smoke, graph claims) — the
  only three actually blocked on this machine, so the fix had missed every live
  case.
- **`totalgate.mjs`'s own walk.** `readdir` was guarded; every `readFileSync`
  and `JSON.parse` inside was not. An unreadable `verdicts.json` one directory
  deeper threw, node exited 1, and `build.sh` announced a totals disagreement.

**Lesson:** the contract is not implemented until every site that emits a
verdict consults it. Enumerate them; do not assume the ones you wrote later
inherited it. See [assertions that cannot fail](assertions-that-cannot-fail.md)
for why "I already fixed that" is not evidence.

## The direction that matters more

A false FAIL sends someone to look and they find nothing. A false PASS ends the
enquiry. Both are defects; only one is silent.

The first silent PASS here: with `functionalObligations: []` in every spec file,
each file was counted and no assignment was, and the gate printed *all headline
totals agree with the verdicts* having measured no assignment at all. See
[vacuity](vacuity.md).

## Related

[Vacuity](vacuity.md) · [Cross-source invariants](cross-source-invariants.md) ·
[What this gate still cannot do](remaining-bounds.md)
