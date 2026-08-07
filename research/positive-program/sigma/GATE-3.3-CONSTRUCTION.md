# Phase 3.3 — construction + certificate (sketch)

**Target:** synthesis of a protocol as a term over P, plus a certificate checkable
in time linear in the construction.

## Minimal design

1. **IR** — existing gen-ir JSON trees of protocol defs (already used for 2.3).
2. **Certificate** — for each generated node, a tag in {Led, Prop, Cmp, Post, KERNEL}
   plus optional port/polarity annotation.
3. **Checker** — pure function: walk tree, verify each node matches its tag's
   signature and local laws (e.g. Led assignments conserve ‖bal‖ when claimed).

## Status

**NOT STARTED.** Precondition: 1.2 formal enough to trust tags; generation
pipeline already exists (`basis/generate.py`).

Cheapest next step: tag the ten v2 IR files with P-labels and write
`check_certificate.py` that rejects mistags.
