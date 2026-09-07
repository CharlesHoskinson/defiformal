## Context

Source inspected at `bbbc303ada632685520c416adda50a6f8aace710`. `DefiKernel.Typed.Quantity` contains a nonnegative rational amount; `State.balance` is rational, and typed transition effects aggregate signed rational deltas. None of those definitions implies bounded-word arithmetic. The new library imports their accepted APIs but changes no existing kernel operation or theorem statement.

## Goals / Non-Goals

Establish executable checked unsigned arithmetic with universal Lean theorems, explicit directed rounding, two fee conventions and a dimensioned reference adapter. Give subsequent financial libraries reusable proof statements and truthful failure contracts.

Signed arithmetic, bit-level opcode semantics, compiler correctness, gas, fixed-point transcendental functions, protocol-specific tick arithmetic, optimized modular-inverse multiplication, chain adapters and deployed fidelity are separate work. This package does not close those obligations or change every rational expression into a word operation.

## Decisions

### 1. Word representation and errors

Use `DefiKernel.Arithmetic.Word (w : Nat)` with fields `value : Nat` and `bound : value < 2^w`. The mathematical family includes `w=0`, whose only value is zero; this degenerate case is not advertised as a hardware width. Application fixtures select widths explicitly. Width is a compiled parameter, not an unbounded input supplied through a new public CLI.

```lean
inductive Failure
  | inputOverflow | addOverflow | subUnderflow | mulOverflow
  | divisionByZero | quotientOverflow | invalidRate
  | nonPositiveScale | negativeQuantity | nonIntegralQuantity
  deriving DecidableEq, Repr

inductive Rounding | down | up
  deriving DecidableEq, Repr

def ofNat (w n : Nat) : Except Failure (Word w)
def add (a b : Word w) : Except Failure (Word w)
def sub (a b : Word w) : Except Failure (Word w)
def mul (a b : Word w) : Except Failure (Word w)
def mulDiv (mode : Rounding) (a b : Word w) (denominator : Nat) :
    Except Failure (Word w)
```

`ofNat` succeeds exactly when `n < 2^w`; it never silently reduces modulo the word size. Addition/multiplication compute the natural result and reject if it is outside the word bound. Subtraction checks `b.value ≤ a.value` before natural subtraction. Each operation returns its own named error. The representation's bound proof is not a runtime wraparound operation.

`mulDiv` accepts a natural denominator independently of the operand word width. This supports fixed rational rates whose denominator need not fit the amount width. A future same-width machine wrapper must separately check its denominator range; no such deployed wrapper is claimed here. A zero denominator is refused before quotient computation or overflow classification. Positive denominators use the exact unbounded product `a.value*b.value`, then divide and round, then check the final word bound. Intermediate product overflow is deliberately relevant to `mul` and irrelevant to this full-product `mulDiv`. This does not prove an optimized machine implementation computes that product correctly.

The runtime arithmetic definitions precede `-- BEGIN PROOFS` in their respective modules. No `noncomputable`, `sorry`, custom axioms or `native_decide` may enter the accepted new executable/proof closure. Kernel reduction and ordinary proof terms remain the authority.

### 2. Independent mathematical specifications

Define specifications as equations, inequalities and failure predicates over natural/integer/rational values, rather than by calling the implementation. For positive denominator `d`, floor success yields a unique `q` with `q*d ≤ a*b < (q+1)*d`; ceiling success yields the least `q` with `a*b ≤ q*d`, with `q=0` iff the product is zero. Ceiling is floor plus one iff the remainder is nonzero. The implementation may use quotient/remainder, but correctness statements must expose these independent characterizations. A private `roundNat (mode : Rounding) (numerator denominator : Nat) : Nat` supplies the shared unbounded calculation; public callers establish the positive-denominator premise before using it.

Prove the if-and-only-if success/refusal characterization for each operation, exact error precedence, word bounds, zero and exact-division behavior, and monotonicity of successful numeric results with explicit premises: at fixed other operands addition/multiplication and positive-denominator mulDiv are monotone in the amount; checked subtraction is monotone in the minuend and antitone in the subtrahend when both calls succeed. No monotonicity assertion compares a refusal to a numeric result. For rational interpretation, floor error is in `[0,1)` atomic units and ceiling error in `[0,1)` on the opposite side. A successful rounded result generally differs from exact rational division; do not claim equality without divisibility. Prove floor and ceiling coincide exactly when the product is divisible by the positive denominator. Overflow may make one or both checked operations refuse, so statements about numeric equality must mention successful results or use an unbounded specification.

### 3. Fee semantics

```lean
structure FeeQuote (w : Nat) where
  principal : Word w
  fee : Word w
  charged : Word w
  received : Word w

def feeFromGross (mode : Rounding) (gross : Word w) (num den : Nat) :
    Except Failure (FeeQuote w)
def feeOnTop (mode : Rounding) (principal : Word w) (num den : Nat) :
    Except Failure (FeeQuote w)
```

Both APIs validate `0 < den` and `num ≤ den` first. They apply the shared unbounded rounding calculation to `gross.value*num` or `principal.value*num`; they do not coerce the natural rate numerator into a `Word w` or truncate a large numerator/denominator. An invalid fraction returns `invalidRate`, including `den=0`; it is not a `mulDiv` invocation's `divisionByZero`. This wrapper-specific precedence is explicit and must be tested. The numerator and denominator are natural rate parameters, not words.

For `feeFromGross`, `charged=gross`, `principal=gross`, `fee=round(gross*num/den)` and `received=gross-fee`. Prove `fee≤gross`, so a valid rate cannot cause fee or subtraction overflow. The `principal` field here records the input basis, not the receiver's net amount. For `feeOnTop`, `received=principal`, `fee=round(principal*num/den)` and `charged=principal+fee`; a valid rate may still return `addOverflow`. In both successful cases prove `charged=received+fee` over naturals, with every output below the word bound. Zero and unit rates, tiny gross values and exact fractions receive named laws. Fee application does not assume a fee recipient is distinct from another ledger party.

These conventions are deliberately separate. No claim says all protocols use one of them, charge on the same asset, permit the same rate range or round in the same direction.

### 4. Dimensioned conversion and executable reference workflow

```lean
def toQuantity (asset : A) (scale : ℚ) (hscale : 0 < scale) (q : Word w) :
    DefiKernel.Typed.Quantity asset
def fromRat (w : Nat) (scale amount : ℚ) : Except Failure (Word w)
```

`toQuantity` interprets one integer unit as `scale` units of the named asset. `fromRat` checks nonpositive scale, then negative amount, then whether `amount/scale` is a natural integer, then its word bound. Failures are respectively `nonPositiveScale`, `negativeQuantity`, `nonIntegralQuantity`, `inputOverflow`. Do not truncate a fractional input or reinterpret one asset as another. Prove same-scale round trips and successful conversion iff an in-range natural multiple exists. The typed output prevents accidental cross-asset substitution; compile-time wrong-asset rejection is recorded separately from runtime mutation evidence.

`Reference.lean` constructs a registered constant-quote typed transfer template from a successful fee quote and a positive scale. It debits `charged`, credits `received` to the recipient and `fee` to the collector, with no supply effect. The quote's provenance and template construction are explicit inputs to the correspondence theorem; a caller cannot supply the internal `Typed.Evaluated` record to `execute`. This reference adapter does not add rounding operators to `Typed.Expr`, claim arbitrary user-supplied templates implement fees, or pretend a fixed quote is a live price oracle.

Prove the constructed effects sum to zero in the same asset/domain using `charged=received+fee` and scale distributivity. Show the actual existing typed executor returns the expected complete `Typed.ExecutionResult` (state and capability store) under its existing authority, footprint, balance and registry premises. A refusal is the actual `Except.error` value; it does not contain an invented post-world. Compare the exact refusal and preserve the supplied input state/store in the read-only observation record for insufficient funds or unauthorized debit. Coincident recipient/collector cells aggregate both credits; payer/recipient coincidence also uses the existing net-effect semantics. State that this is the kernel's net-effect model, not a sequential token debit-order guarantee.

The arithmetic layer itself is pure and creates no capabilities, receipts or messages. The reference workflow reuses current execution rather than defining a second trusted executor. All required hypotheses remain visible in exported proof statements.

### 5. Source layout and acceptance artifacts

Create `lean/DefiKernel/Arithmetic/{Word,Operations,Rounding,Fees,Quantity,Reference,Examples,Tests,Audit,Verify}.lean`. Each production module contains runtime definitions followed by a marked proof section. `Word` owns representation/construction; `Operations` checked basic operations; `Rounding` full-product division; `Fees` quote policies; `Quantity` dimensioned conversion; `Reference` the registered fee template and actual-executor correspondence. `Examples` supplies independent literal financial fixtures. `Tests` evaluates named comparisons. `Audit` enumerates imported declaration types/axioms dynamically; `Verify` imports the complete intended root. Add only the necessary package-root integration after checking the actual `lakefile.toml` layout. Preserve all historical modules.

Create `scripts/check_integer_arithmetic_mutations.py` and `scripts/test_integer_arithmetic_runner.py`. Reuse the accepted runner contract and hardening patterns after inspecting their actual current source, with a new explicit package manifest and audit root. The official planning freeze must enumerate every declaration/helper allowed in the mutation projection and exact literal control expectations; a guessed file inventory or substring proof eraser is insufficient. Author-draft fixture/mutation inventory accompanies this plan, but runner controls require that concrete freeze before the gate.

Named runtime fixtures include checked boundaries, true full-product behavior, zero/exact/nonexact division, floor-fitting/ceiling-overflow, both fee conventions, scale conversion, exact full-world success/refusal and duplicate ledger targets. Four-bit exhaustive arithmetic is supplementary bounded execution, never the generic proof. Use an independently written Python `divmod` integer oracle for this finite diagnostic comparison and retain its code/input/output hashes; it is not a chain implementation.

Every source mutation must alter one production runtime expression, compile under the frozen projection, falsify its designated named observation, and retain global and separate unaffected sibling positives. The mutant's own observed output cannot be used as its expected result. A compiler refusal, source-text difference, unchanged copy or failed tool setup is not a detected semantic mutant. Pure quantity/fee query mutations are labelled as such, while reference-effect mutations exercise the actual typed executor. Preserve failed development attempts.

Exit0 requires complete nonempty evidence; exit1 is a well-formed semantic/counter discrepancy; exit3 is blocked, missing, malformed, drifted or incomplete evidence. The runner itself must reject forged summaries, zero checks, changed inputs, stale logs, wrong declared roots, missing package files, wrong-world observations and unexecuted controls. Exact control files/counts are a pre-freeze obligation, not claimed current execution.

### 6. Review and scope gates

This author draft may be developed independently of S10's new runtime files, but accepted current Typed APIs, toolchain, proof roots and runner contracts must be freshly bound before official review. Freeze proposal, design, specs, tasks, every fixture/mutant/control, source context and preservation inputs. Obtain nonauthor GPT-6 and native Fable5.1 medium on the identical candidate before implementation. GPT-6 implements through the stock harness; no Foreman. Native Grok plus Fable review actual final source, proofs, runtime observations, mutations, runner controls and limitations. Record requested/reported models and unavailable responses honestly.

The final scenario map distinguishes generic proofs, concrete instances, finite execution, compiler controls, mutations and unchecked assumptions. A complete unsigned arithmetic package does not certify signed funding, a particular Solidity/EVM implementation, concentrated-liquidity formulas, fees of every protocol or deployed fidelity. Those remain separately scoped roadmap obligations.

## Risks / Trade-offs

Natural arithmetic makes the specification clear but does not establish a finite-register implementation's performance or bit-level correctness. Directed rounding can preserve local accounting while changing protocol economics; later library refinements must choose the protocol's exact convention. Explicit conversion prevents silent truncation but requires an application to supply the correct asset scale. A pure constant-quote transfer is a useful accounting bridge, not a model of dynamic quote discovery or live routing.

## Migration Plan

Finish the concrete runner/control inventory and source manifest, pass the official planning gate, then implement pure words/rounding, fee and quantity proofs, the actual typed reference workflow, and integrated evidence. Deliver and archive only after native final reviews pass. Root owns branch commits/pushes. No existing theorem, runtime arithmetic or corpus record is rewritten by this draft.
