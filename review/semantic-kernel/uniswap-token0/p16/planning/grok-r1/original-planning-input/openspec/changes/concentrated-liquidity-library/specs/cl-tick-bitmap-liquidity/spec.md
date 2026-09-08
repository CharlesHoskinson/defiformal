## Purpose

Specify floor compression of signed ticks, one-word initialized-tick search including uninitialized edges, signed liquidity deltas, and factory fee/spacing predicates as input context.

## ADDED Requirements

### Requirement: CLB01 Negative tick compression floors rather than truncates

`compress(tick, spacing)` SHALL equal floor division toward `-∞`. Equivalently it SHALL match Solidity 0.7.6 truncated division followed by decrement when `tick < 0` and `tick % spacing ≠ 0`. `position(-1)` SHALL be word `-1` bit 255.

#### Scenario: B01 -61 compressed with spacing 60 is -2 and -60 is -1

- **WHEN** `compress` is evaluated on -61 and -60 with spacing 60
- **THEN** the results are -2 and -1.

#### Scenario: B02 compressed tick -1 occupies bit 255 of word -1

- **WHEN** `position` is evaluated on -1
- **THEN** `wordPos` is -1 and `bitPos` is 255.

### Requirement: CLB02 One-word search is inclusive or exclusive and may return an uninitialized edge

`nextInitializedTickWithinOneWord` SHALL search only the current or adjacent bitmap word. `lte=true` SHALL include the current compressed bit. `lte=false` SHALL start at `compressed+1`. If no initialized bit is present in the masked word, it SHALL return the word-edge tick and `initialized=false`. It SHALL NOT walk the whole pool.

#### Scenario: B03 an initialized bit at tick 0 is found by an inclusive search

- **WHEN** the map has word 0 equal to 1 and the query is tick 0, spacing 1, `lte=true`
- **THEN** next is 0 and initialized is true.

#### Scenario: B04 an empty word exclusive search returns tick 255 uninitialized

- **WHEN** the map is empty and the query is tick 0, spacing 1, `lte=false`
- **THEN** next is 255 and initialized is false.

### Requirement: CLB03 Signed liquidity deltas refuse under and overflow

`addDelta(x,y)` SHALL return `x+y` as `uint128` when that sum is in range. Negative `y` SHALL return `liquidityUnderflow` when the subtraction wraps or exceeds `x`. Nonnegative `y` SHALL return `liquidityOverflow` when the sum exceeds `2^128-1`.

#### Scenario: B05 10 plus 5 is 15 and 10 plus -3 is 7

- **WHEN** `addDelta` is evaluated on those pairs
- **THEN** the results are 15 and 7.

#### Scenario: B06 10 plus -11 underflows and max uint128 plus 1 overflows

- **WHEN** `addDelta` is evaluated on (10, -11) and (`2^128-1`, 1)
- **THEN** the errors are `liquidityUnderflow` and `liquidityOverflow`.

### Requirement: CLB04 Factory fee and spacing are predicates not SwapMath checks

A fee/spacing pair SHALL be valid only if `fee < 1000000` and `0 < spacing < 16384`. Builtin pairs (500,10), (3000,60) and (10000,200) SHALL be valid. These predicates SHALL NOT be treated as a factory contract, deployment, or SwapMath runtime check.

#### Scenario: B07 builtin pairs are valid and 1e6, 0 and 16384 are not

- **WHEN** the six predicate cases in F44 are evaluated
- **THEN** the three builtin pairs succeed and fee 1000000, spacing 0 and spacing 16384 fail.
