## Purpose

Require independent fixtures, characteristic mutants, an honest proof/execution boundary, four distinct claim levels, and a named remainder for full tick traversal.

## ADDED Requirements

### Requirement: CLE01 Fixtures carry independent expected literals

Every named runtime fixture SHALL include independently computed expected success values or named errors. Expected numbers SHALL be decimal strings. A fixture SHALL NOT take its expected observation from a Lean run of the implementation under test.

#### Scenario: E01 positive fixtures compare frozen decimal literals

- **WHEN** the positive and mixed fixtures F01–F04, F07, F09–F14, F16–F17, F20–F24, F27–F31, F34–F41, F44–F45 are evaluated after implementation
- **THEN** each matches the frozen `fixtures.json` literal, including tick 0 = `79228162514264337593543950336`.

#### Scenario: E02 negative fixtures return the named constructors

- **WHEN** the refusal fixtures F05, F06, F08, F15, F18, F19, F25, F26, F32, F33, F42, F43 are evaluated
- **THEN** each returns exactly the frozen error constructor and no fabricated post-state.

### Requirement: CLE02 Characteristic mutants discriminate rounding, fee, bounds, overflow, sign and iteration

Each planned mutant SHALL change one production runtime expression, compile, make its designated fixture false, and leave stated global and sibling positives true. A compiler error, missing anchor or timeout SHALL be blocked, not counted as detection.

#### Scenario: E03 the twelve planned mutants keep F01, F10, F28 and F40 true

- **WHEN** M01–M12 are applied one at a time after implementation
- **THEN** each designated fixture is false, the mutant’s sibling remains true, and F01, F10, F28 and F40 remain true.

### Requirement: CLE03 Proof, execution, correspondence and deployment stay distinct

Accepted proofs SHALL contain no `sorry`, custom axiom or `native_decide`. Finite `#eval` SHALL not be advertised as a generic theorem. Assembly FullMath, compiler/EVM, and deployed systems SHALL remain gaps. Completing the swap-step library SHALL leave full `UniswapV3Pool.swap` traversal named open.

#### Scenario: E04 axiom audit of imported ConcentratedLiquidity theorems is nonempty and standard

- **WHEN** `#audit_axioms DefiKernel.ConcentratedLiquidity` runs on the implemented import closure
- **THEN** the theorem scope is nonempty and every transitive axiom is among `propext`, `Classical.choice` and `Quot.sound`.

#### Scenario: E05 four claim levels are recorded without collapsing them

- **WHEN** the package is described in evidence
- **THEN** L1 library, L2 pure executable model, L3 partial pinned-source correspondence and L4 deployed fidelity are listed separately, with L4 out of scope.

#### Scenario: E06 full pool traversal remains a named remainder

- **WHEN** this increment’s tasks are complete
- **THEN** roadmap item “Uniswap-style concentrated-liquidity arithmetic and tick traversal” stays unchecked because `R-FULL-TRAVERSAL` is still open, and no document claims `computeSwapStep` is that loop.
