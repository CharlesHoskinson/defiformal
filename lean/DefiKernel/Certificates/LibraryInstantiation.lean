import DefiKernel.Arithmetic.Operations
import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.TrustedHost

/-!
Actual Lean-checked library instantiation for P20 task 21.3.

Envelope `libraries` theorem-name tags never discharge LibraryTheoremsInstantiated.
Only a compiled identity with a recorded theorem from accepted Arithmetic counts.
-/
namespace DefiKernel.Certificates.LibraryInstantiation

open DefiKernel.Arithmetic

/-- Compiled instantiation of accepted Arithmetic checked-addition. -/
theorem instantiated_add_ok_iff {w : Nat} (a b q : Word w) :
    Operations.add a b = .ok q ↔ a.value + b.value = q.value :=
  Operations.add_ok_iff a b q

/-- Fully qualified names of theorems this certificate increment actually instantiated. -/
def instantiatedTheoremNames : List String :=
  ["DefiKernel.Arithmetic.Operations.add_ok_iff"]

/-- Theorem-name tags discharge nothing unless they name a compiled instantiation. -/
def namesDischarged (libs : List LibraryRefEnc) : Bool :=
  !libs.isEmpty && libs.all (fun l => instantiatedTheoremNames.contains l.theoremName)

/-- Module identity required when a library ref supplies `moduleName`. -/
def instantiatedModuleName : String :=
  "DefiKernel.Arithmetic.Operations"

/-- Path+sha256+theorem token naming the compiled Arithmetic add instantiation.
Distinct from Typed/Composition source-identity records and from envelope git. -/
def addOkIffCompilerRecord : String :=
  TrustedHost.arithmeticAddCompilerRecord

def wordWidth : Nat := 64

def ofNat64 (n : Nat) : Option (Word 64) :=
  if h : n < 2 ^ 64 then some ⟨n, h⟩ else none

def ratEncToNat (r : RatEnc) : Option Nat :=
  if r.den == 1 && r.num ≥ 0 then some r.num.toNat else none

def ratToNat (q : ℚ) : Option Nat :=
  if q.den == 1 && q.num ≥ 0 then some q.num.toNat else none

/-- Operands of the supported transfer credit claim: recipient_pre + amount = recipient_post. -/
structure TransferCreditOperands where
  pre : Word 64
  delta : Word 64
  post : Word 64
  deriving DecidableEq, Repr

def lookupCell (cells : List StateCellEnc) (d : Domain) (p : Party) (a : Asset) : Option RatEnc :=
  (cells.find? (fun c => c.domain == d && c.party == p && c.asset == a)).map (·.amount)

def requestAmount (req : RequestEnc) : Option (Asset × Nat) :=
  match req.arguments with
  | [v] =>
    match v.unit with
    | .numeric (.amount a) =>
      (ratToNat v.valRat).map (fun n => (a, n))
    | _ => none
  | _ => none

/-- Extract credit-cell operands from the payload and the claimed or recomputed post world.
Does not consult a caller success flag. Returns none on non-integral or missing cells. -/
def extractTransferCredit
    (payload : TypedExecutePayloadEnc) (claimWorld : WorldEnc) :
    Option TransferCreditOperands := do
  let (asset, deltaN) ← requestAmount payload.request
  let recip ← payload.request.parties.head?
  let preRat ← lookupCell payload.state.cells payload.ctx.domain recip asset
  let postRat ← lookupCell claimWorld.state.cells payload.ctx.domain recip asset
  let preN ← ratEncToNat preRat
  let postN ← ratEncToNat postRat
  let preW ← ofNat64 preN
  let deltaW ← ofNat64 deltaN
  let postW ← ofNat64 postN
  some ⟨preW, deltaW, postW⟩

/-- Executable evidence: run accepted `Operations.add` on extracted operands. -/
def addHolds (op : TransferCreditOperands) : Bool :=
  match Operations.add op.pre op.delta with
  | .ok q => decide (q = op.post)
  | .error _ => false

def metadataMatches (lib : LibraryRefEnc) : Bool :=
  instantiatedTheoremNames.contains lib.theoremName &&
    match lib.moduleName with
    | none => true
    | some m => m == instantiatedModuleName

def namesAndMetadataMatch (libs : List LibraryRefEnc) : Bool :=
  !libs.isEmpty && libs.all metadataMatches

def compilerRecordNamesAddOkIff (pin : SourcePinEnc) : Bool :=
  match pin.compiler_record with
  | none => false
  | some s => s == addOkIffCompilerRecord && s ≠ TrustedHost.gitSha

/-- Bound discharge: theorem+module identity, extracted payload/claim operands, executed add,
and a compiler record that names that theorem. Name-only tags do not satisfy this. -/
def instantiatedOverCertificate
    (libs : List LibraryRefEnc) (pin : SourcePinEnc)
    (payload : TypedExecutePayloadEnc) (claimWorld : WorldEnc) : Bool :=
  namesAndMetadataMatch libs &&
    compilerRecordNamesAddOkIff pin &&
    match extractTransferCredit payload claimWorld with
    | none => false
    | some op => addHolds op

def familyBound
    (libs : List LibraryRefEnc) (pin : SourcePinEnc)
    (payload : TypedExecutePayloadEnc) (claimWorld : WorldEnc) : JudgmentOutcome :=
  if libs.isEmpty then
    JudgmentOutcome.notApplicable
  else if instantiatedOverCertificate libs pin payload claimWorld then
    JudgmentOutcome.«true»
  else
    JudgmentOutcome.notApplicable

theorem addHolds_iff (op : TransferCreditOperands) :
    addHolds op = true ↔ Operations.add op.pre op.delta = .ok op.post := by
  dsimp [addHolds]
  cases Operations.add op.pre op.delta with
  | error _ => simp
  | ok q => simp [decide_eq_true_eq, Word.ext_iff]

/-- Transfer-three credit: bob USD 0 + 3 = 3 instantiates accepted `add_ok_iff`. -/
theorem transfer_three_credit_add
    (pre delta post : Word 64)
    (hpre : pre.value = 0) (hdelta : delta.value = 3) (hpost : post.value = 3) :
    Operations.add pre delta = .ok post := by
  have hsum : pre.value + delta.value = post.value := by
    rw [hpre, hdelta, hpost]
  exact (instantiated_add_ok_iff pre delta post).mpr hsum

/-- Transfer-three debit conservation: alice remainder 7 + 3 = start 10. -/
theorem transfer_three_debit_add
    (remain delta start : Word 64)
    (hremain : remain.value = 7) (hdelta : delta.value = 3) (hstart : start.value = 10) :
    Operations.add remain delta = .ok start := by
  have hsum : remain.value + delta.value = start.value := by
    rw [hremain, hdelta, hstart]
  exact (instantiated_add_ok_iff remain delta start).mpr hsum

theorem namesDischarged_ignores_module
    (libs : List LibraryRefEnc)
    (h : namesDischarged libs = true) :
    libs.all (fun l => instantiatedTheoremNames.contains l.theoremName) = true := by
  simp [namesDischarged] at h
  cases libs <;> simp_all

/-- Name-only discharge is not certificate instantiation: missing compiler record fails. -/
theorem name_only_without_compiler_record_fails
    (payload : TypedExecutePayloadEnc) (claimWorld : WorldEnc) :
    let libs : List LibraryRefEnc :=
      [⟨"DefiKernel.Arithmetic.Operations.add_ok_iff", none⟩]
    let pin : SourcePinEnc :=
      ⟨TrustedHost.gitSha, TrustedHost.leanToolchain, TrustedHost.mathlibRev, "", none, none⟩
    namesDischarged libs = true ∧
      instantiatedOverCertificate libs pin payload claimWorld = false := by
  intro libs pin
  constructor
  · decide
  · simp [instantiatedOverCertificate, compilerRecordNamesAddOkIff, pin]

end DefiKernel.Certificates.LibraryInstantiation
