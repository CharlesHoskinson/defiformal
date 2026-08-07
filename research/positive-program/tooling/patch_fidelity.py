import pathlib

p = pathlib.Path("/root/DefiElements/research/positive-program/phase2/P2-FIDELITY.md")
t = p.read_text(encoding="utf-8")

banner = """> ## AMENDED 2026-08-05 after plan review (`P2-REVIEW.md`)
>
> **Two repairs are applied below and override the original text wherever they
> conflict.**
>
> **R1 — F3 Parsimony no longer authorises deletion.** As originally written, F3
> instructed the worker to collapse any distinction the mutant suite did not
> need and *iterate to a fixed point*. The worker also authors the mutant suite,
> so a thin suite licenses deleting almost anything — and the generation
> measurement becomes circular, since the corpus would then be a function of the
> ten contrast sets. This is the same failure shape as the three known traps
> (the check passes because the stressing states were removed), except mandated.
> F3 is now a **reporting** obligation. Deletion additionally requires the
> contract-facing droppability test of section 2, which dominates.
>
> **R4 — the contrast set has three mandatory members.** Distant rivals are free
> to kill; Curve's own blend beats a contrast set of constant-sum plus
> constant-product. Every contrast set must contain, in addition to whatever the
> author chooses:
>   1. **the v1 shortcut body itself** — the exact abstraction this re-spec
>      exists to remove, as a live rival;
>   2. **a chaos relaxation** — the maximally permissive version in the same
>      relaxation direction, uniform across all ten;
>   3. **a near neighbour** agreeing with the target on at least 90% of the
>      declared domain, sourced from a sibling protocol already in the corpus.
>
> Three repairs (T0 conformance vectors, the extended nondet convention, and the
> i64 domain fixes) are specified separately in the repaired execution contract.

"""

if "AMENDED 2026-08-05" not in t:
    lines = t.split("\n")
    insert_at = 1 if lines and lines[0].startswith("#") else 0
    t = "\n".join(lines[:insert_at]) + "\n\n" + banner + "\n".join(lines[insert_at:])

t = t.replace(
    "- **F3 Parsimony.** No strict collapse `Q′ ≺ Q` (quotient of a state variable, deletion of a\n  field, coarsening of a definition) satisfies F1 and F2.",
    "- **F3 Parsimony (AMENDED R1 — reporting only).** Any strict collapse `Q′ ≺ Q`\n"
    "  (quotient of a state variable, deletion of a field, coarsening of a definition)\n"
    "  that still satisfies F1 and F2 is **recorded as a parsimony candidate**. It is\n"
    "  NOT deleted on that basis alone: the mutant suite is author-supplied, so\n"
    "  surviving it proves only that the author's rivals were weak. Deletion requires\n"
    "  the contract-facing droppability test of section 2 to pass as well.")

t = t.replace(
    "3. **Parsimony run (F3).** For each spec-side distinction `d` (state variable, record field,\n"
    "   guard conjunct, exactness of an arithmetic definition), form `Q/d` by collapsing it. Re-run\n"
    "   step 2. If `Q/d` still kills all mutants and preserves all declared invariants, `d` is\n"
    "   unearned concreteness — **delete it**. Iterate to a fixed point.",
    "3. **Parsimony run (F3) — AMENDED R1.** For each spec-side distinction `d`, form\n"
    "   `Q/d` and re-run step 2. If `Q/d` still kills all mutants and preserves all\n"
    "   declared invariants, **record `d` in a parsimony report**. Do NOT delete it,\n"
    "   and do NOT iterate to a fixed point. Deletion is permitted only when the\n"
    "   section 2 contract-facing test also says `d` is droppable — i.e. no\n"
    "   state-changing guard in the contract reads it and no rival mechanism turns\n"
    "   on it. A distinction the contract uses stays, however weak the rivals are.")

p.write_text(t, encoding="utf-8")
print("P2-FIDELITY.md amended: R1 (parsimony) and R4 (contrast set) applied")
