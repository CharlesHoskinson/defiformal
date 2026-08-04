# GP-LOG
GP-LOG is a dependency-free Node.js propositional solver for the DeFi-composition algebra.
`model.mjs` transcribes the 58 elements, 29 laws, and 20 hazard combinations as literals.
It applies the specified parser and treats external prose terms as satisfied residue.
It promotes L15's bounded emergency alternative to `Gp` and L8's named custodian to `At`.
Closure requires every term of each fired law to be satisfied.
The only evaluable baseline hazard is X2, using the atlas hazard regex behavior.
XL1 and XL2 reject the two formal flash-liquidity witnesses.
LN1 requires `Aw` when both `Fz` and `Xf` are present.
Run verdicts with `node algebra/solvers/GP-LOG/run.mjs` from the repository root.
Run calibration with `node algebra/solvers/GP-LOG/calibrate.mjs` from the repository root.
Outputs are written to the requested verdict and calibration JSON paths.
