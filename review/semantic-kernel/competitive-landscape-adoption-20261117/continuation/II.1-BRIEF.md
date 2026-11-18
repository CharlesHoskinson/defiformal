# Routed vault deposit and token0 quote implementation plan

Goal: demonstrate one actual financially connected composition under the accepted II.1 spec. Use the existing author/checker workflow; no new orchestration.

Source baseline: `2387370cdc5ffaa0d6f4035e86b19d61b459cd15`. Destination: `semantic-kernel-pivot`.

- [ ] Prove native `Vault.convertToShares Token0Bridge.amt1 rayChi = .ok Token0Bridge.amt1`; feed the returned Word into `Token0Bridge.libraryWord sqrtP_Q96 L1 ... true`, proving the existing `postWord` result. Test an incorrect expected result as a negative control.
- [ ] Add a minimal common-universe adapter in a new namespace. Deposit exports the minted raw sUSDS balance; the quote consumes it through `.priorOutput` with `.amount susds`. Preserve historical sources. The synthetic sqrt-price register is neither pool storage nor settlement.
- [ ] Instantiate one `ComponentContract`; prove unit-rate backing invariant initialization and preservation over actual execution, discharging each step's local guarantees. Invoke one named matched-delta backing lemma for both steps. No unproved local-guarantee premise.
- [ ] Check successful routing, wrong asset, unavailable output and refused deposit; prove expected refusal/prefix behavior. Record per-component authored lines and prospective AI session intervals separately from unavailable historical effort and human person-hours.
- [ ] Build the candidate with pinned Lean, run fresh axiom audit and focused negative controls, freeze changed-file hashes, obtain independent Astra medium review, then verify/integrate accepted source.

Allowed changes: new workflow/proof/test modules and focused documentation/evidence; add imports to build/audit entry points. No historical theorem weakening, custom axioms, `sorry` or `native_decide`. Full-domain arithmetic remains II.2.
