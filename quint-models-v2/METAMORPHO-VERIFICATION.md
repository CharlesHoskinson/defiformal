# metamorpho.qnt — verification transcript

Commands and results, run 2026-08-06. Reproduce from `quint-models-v2/`.

    quint typecheck metamorpho.qnt
      -> clean

    python3 ../research/positive-program/phase2/respec_lint.py metamorpho.qnt
      -> TOTAL FINDINGS: 0 across 1 spec(s)

    quint run metamorpho.qnt --invariant=<I> --max-steps=20 --max-samples=3000

      inv_all              [ok]
      inv_T0               [ok]
      inv_conservation     [ok]
      inv_capsRespected    [ok]
      inv_nonNegative      [ok]
      inv_sharesSum        [ok]

    quint run metamorpho.qnt --invariant=<W> --max-steps=25 --max-samples=20000

      wit_nonLocalReallocation           [violation]
      wit_outsiderMovesDepositorAssets   [violation]
      wit_mandateGranted                 [violation]
      wit_capBinds                       [violation]

Witnesses are reachability obligations: `[violation]` is the required outcome and
means the state IS reachable.

## What the two columns mean together

Every invariant the corpus knows how to write is `[ok]` over the same reachable
space in which an outsider redistributes depositors' assets. The invariants are
not wrong and the witness is not a bug — they are measuring different things, and
only one of them is measuring the mandate.
