# Sprint9 runner development evidence

The new driver and harness equal the reviewed planned text byte for byte: 11 driver
and 26 harness literal substitutions, with no behavior changes. The predecessor
scripts are bound to accepted source `99e2e2c61a1a3c5249026921efdc6cd41ac8f21d` and
planning candidate `0948c177f8939ca6dcc33557c34415d11545ef3e`. The actual predecessor
specification is `review/semantic-kernel/sprint8/mutation-spec.json`.

The harness was created first. Its production-form acceptance control against the
old driver failed as expected: actual exit 3, `missing Atomic audit root`, against
expected exit 0. That run remains in `sprint9-runner-red-predecessor/`.

After creating the new driver, the four selected actual CLI controls passed:

- Production-form discriminating mutant: exit 0.
- Production-form required observation stays true: exit 1.
- Discovered Metatheory dependency: exit 0.
- Runtime definition after proof boundary: exit 3.

These are synthetic development fixtures using installed Lean and the actual CLI.
They are not production mutation evidence or the complete 65-control suite.
`adaptation-and-smoke.json` records the exact commands, run UTC, source identities,
original paths, and hashes of all 89 copied files. Original file bytes are retained;
the two nested Git directories and two package symlinks are explicitly excluded.
Both production-form case CLI log paths, hashes, and captured outputs were checked.

The runner keeps the accepted 600-second default command timeout. Official
production execution must pass `--timeout-seconds 600` explicitly. The harness
retains its 1500-second outer per-case limit. Timing evidence is limited to run UTC
and inherited labeled-command, variant, and case elapsed fields. Inherited timeout
handling does not capture partial stdout or a record for the timed-out command.

Full 65-control and 14-production-mutation runs await the implementation freeze.
The production specification and per-mutant sibling matrix are separate artifacts;
neither changes the protected-positive checking behavior of this runner.
