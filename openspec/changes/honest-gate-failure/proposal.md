## Why

On a fresh clone `./paper/build.sh` exits 1 with:

```
BUILD FAILED: a headline total disagrees with the verdicts
```

That sentence is false. Measured on this tree: both PDFs render (atlas 39pp,
supplement 120pp), bibtex is clean, there are zero undefined references, and
every one of `totalgate.mjs`'s eight predicates **passes** once the gate can
reach its input — 1259 obligations, 570 covered, 689 residue, 45.3%, 29.0%, and
the four stale-token checks. The totals agree. The gate never ran.

The defect is line 49:

```bash
node ../formal/v3/totalgate.mjs >/dev/null 2>&1 || die "a headline total disagrees with the verdicts"
```

Two independent faults in one line. The redirect discards the only diagnosis the
gate produces — here `EACCES: scandir '/root/defiformal/expansion'`. And `||` maps
*every* nonzero exit onto one domain-specific sentence, so an environment error
is reported to the reader as a mathematical inconsistency in the paper.

This is the worst possible direction for a build script to be wrong in. A
crash tells you to look at the machine. This tells you to look at the
mathematics, and there is nothing there to find. It is also the exact failure
class the paper's own method exists to prevent — a checker returning a
confident wrong answer that the check itself cannot catch.

`formal/v3/gate.sh:3` carries the same defect in a second shape:

```bash
cd /root/defiformal
fail=0
```

No `|| exit`. When the `cd` fails the script keeps running in whatever directory
it started in, every harness misses its input, and the gate reports
`FAIL 61 of 72 satisfy laws+warrants` — a specific, plausible, false claim about
the corpus. The correct pattern is already in this tree twice:
`formal/v3/smoke.sh` opens `cd "$(dirname "$0")"`, and `negtest-claims.sh` opens
`cd /root/defiformal || exit 9`. `gate.sh` is the outlier.

An adversarial pass over the gate suite found a third shape of the same lie: a
gate that reports success because it examined nothing. `sigma/verify_final.py`
globs a hardcoded path, matches zero files, prints
`X21-armed pairs (60-app basis): 0 of 0` and **exits 0**. `validate.mjs` on an
empty directory prints `0 specs, 0 rejected` and exits 0. `gate33_cert_check.py`
prints `PASS` when its IR directory holds zero JSON files. Each is a live pass
with an empty denominator.

All three shapes are one bug: **the scripts cannot distinguish a property that
failed from a check that did not run.**

## What Changes

- **Separate the two failure modes at the exit-code level.** A gate exits `1`
  when it evaluated its property and the property is false, and `3` when it
  could not evaluate the property at all. Callers report them differently and
  never merge them.
- **Stop discarding gate diagnostics.** `paper/build.sh` line 49 surfaces the
  gate's own stderr on failure and reports the totals-disagreement message only
  on the exit code that actually means a totals disagreement.
- **Guard every `cd` in the gate shells.** `formal/v3/gate.sh:3` and the twelve
  sibling scripts that open `cd /root/defiformal` become script-relative with an
  explicit failure exit, following `smoke.sh`.
- **Make `totalgate.mjs` resolve its own roots** from `import.meta.url` rather
  than `/root/defiformal`, so the honest path is exercisable end to end and the
  gate that already passes can be seen to pass.
- **Refuse the vacuous pass.** A gate whose corpus is empty exits `3`, not `0`.
  Zero files examined is a blocked check, never a satisfied property.
- **Extend the negative-test suite to the reporters themselves.** The existing
  `negtest-*.sh` scripts prove the *content* checkers catch manuscript errors.
  None of them proves that `build.sh` and `gate.sh` report a blocked check
  correctly — which is why this defect survived to a published clone.

## Non-goals

- **Not** repairing the other ~200 path-broken scripts. Only `totalgate.mjs`
  and the gate shells are touched, and only because the honesty fix cannot be
  demonstrated without them. The general root-resolution work is a separate
  change.
- **Not** changing what any gate checks. `totalgate.mjs`'s predicates, including
  its unanchored `String.includes` matching and the `inad`/`assigned` values it
  computes but ignores, are left exactly as they are. Widening a check and
  fixing how failure is reported are different changes and must not ride
  together.
- **Not** touching `atlas.tex` or any measurement.
