## Purpose

Widen the kernel's financial scope so that the benchmark swap case runs on the library and the lending and liquidation cells move from partial or unknown. Serves tasks IV.1, IV.3 and IV.4.

## ADDED Requirements

### Requirement: The kernel SHALL have an AMM swap operation

The kernel SHALL provide an AMM swap operation with reserve accounting, specified in Word and exact-rational arithmetic with fees and refusal, and the benchmark R2 case SHALL be re-run on the library.

#### Scenario: Swap specified in both arithmetics

- **WHEN** the AMM module is built
- **THEN** a swap operation with reserve accounting is specified in Word and exact-rational arithmetic with fees and refusal, conservation and no-arbitrage are stated, and R2 is proved on the library rather than on a benchmark model

### Requirement: Liquidation SHALL be modelled with separate theorems

Liquidation SHALL be modelled when sprint P27 opens, with solvency and correctness stated as separate theorems.

#### Scenario: Liquidation cells move

- **WHEN** sprint P27 opens and the liquidation module is built
- **THEN** solvency and correctness are separate theorems and the liquidation cells of both matrices no longer read unknown

### Requirement: Lending SHALL cover repay, accrual and collateral movement

Lending SHALL be extended beyond borrow to repay, interest accrual, collateral deposit and collateral withdrawal.

#### Scenario: Lending cell moves to supported

- **WHEN** repay, interest accrual, collateral deposit and collateral withdrawal are added beside borrow
- **THEN** the lending primitive cell reads supported with each operation named
