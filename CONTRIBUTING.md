# Contributing

Use the [delivery repository](https://github.com/stefan-contiu/defiformal) and
base proposed changes on `semantic-kernel-pivot`, its development and delivery
branch. Follow [AGENTS.md](AGENTS.md) for the current implementation and review
workflow. Keep a change focused on one behavior, proof obligation or document
correction, and state its expected result.

Submit original code and proofs only when you have the right to contribute
them under [Apache-2.0](LICENSE). Identify imported material, its source revision
and its retained terms. Preserve source notices and provenance; see the
[license scope and third-party notices](THIRD_PARTY_NOTICES.md).

For Lean changes, use the repository's pinned toolchain and dependencies:

```sh
cd lean
lake exe cache get
lake build
```

The [CI workflow](.github/workflows/lean.yml) also runs a fresh audit of the
imported kernel. For changes to audit behavior, run the existing positive and
negative controls from the repository root, using a new evidence directory
outside the checkout:

```sh
python3 scripts/test_kernel_axiom_audit.py --output /tmp/kernel-axiom-controls
```

Accepted kernel proofs must not use `sorry`, custom axioms or `native_decide`.
Preserve historical theorem statements and negative results. A verification
change needs a passing control and a deliberate failing input; an empty check
cannot pass. Record the exact source revision, tool identity, command and result.
Keep mathematical proofs, bounded executions and measurements distinct.

A pull request should describe the problem, resulting behavior, relevant checks
and remaining limits. Record author and reviewer identities accurately, including
AI assistance. Bug reports should include the source revision, tool version,
reproduction command, expected result and actual output.
