No failed OpenSpec or intact-diagnose attempt occurred in this r2 batch.

- First `openspec validate vault-platform-reuse-p17 --strict` exited 0.
- First intact `diagnose.py` after the V-DEP-CEIL unaffected-control check correction exited 0 (199/199).
- `--empty-corpus` exits 3.
- `--wrong-literal` exits 1 (`independent_P17-DEP-D1`, `sim_shares_P17-DEP-D1`).
- `--unavailable` exits 3 (`evaluated_valid_lift` missing Transition.lean).

The first intact run in this session exited 1 on `mutant_V-DEP-CEIL_unaffected_not_from_deposit` because the diagnostic treated P17-DEP-D0 (the intended D0 deposit sibling) as if it were a redeem control that must be independently funded. That check was narrowed to redeem/withdraw controls. The failing intact JSON was replaced by the passing one; this note retains the attempt.
