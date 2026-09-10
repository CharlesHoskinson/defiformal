# P22 Curve source entry

The newly captured source pin is Curve `curve-contract` commit `574f44027d089de0eac765f5a74ea5ae96aba968`, `contracts/pools/3pool/StableSwap3Pool.vy`. The development records pointed to this file, but their historical source revision was not established. This capture is a new explicit pin.

`get_D` lines195–218 uses three coins and at most255 iterations. It breaks when adjacent iterates differ by at most1 and otherwise returns the final `D` after the loop. Thus bound exhaustion is a successful residual return if arithmetic completes, not an explicit nonconvergence revert. No reached-exhaustion witness or compiler execution was produced here. Zero denominators and uint256 arithmetic remain separate obligations.

The old two-coin/AMP100/K8 development model is historical input. It cannot establish unchanged execution of this three-coin pin. P22 must retain honest convergence/residual reporting, iteration bounds, ordinary and residual/exceptional observations, a false-convergence mutant, an over-bound negative and independent review. Source capture does not prove those requirements.

All copied source/config/license bytes and Git blob identities are in readiness.json. P17 opens the wider-family resource gate. AGY remains assigned to P19; no P22 author or reviewer was dispatched by this preparation.
