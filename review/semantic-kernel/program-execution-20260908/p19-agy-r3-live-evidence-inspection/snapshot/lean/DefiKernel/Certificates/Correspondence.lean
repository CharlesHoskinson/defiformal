import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Observation

namespace DefiKernel.Certificates

/-! Correspondence theorems and open remainder obligations for serialized certificates.
In accordance with P19 specifications and RC01/P20 gates:
- Bounded finite fixture evidence (F25, F27, F28, etc.) is verified computationally.
- Universal quantified theorems (T-roundtrip, T-canonical-bytes, etc.) remain open obligations for P20.
- Strictly zero `sorry`, custom axioms, or `native_decide` are used in accepted kernel proofs. -/

/-- Supported DecodedIR predicate over the defined execution universe.
    Restricted to DecodedExecution with complete 32-cell state table,
    nonnegative amounts with positive denominators, unique registry entries,
    and supported sequential step forms.
    Codec and audit documents are not execution-supported (audit and codec have
    dedicated checkAudit/checkBytes contracts, not rawExecute). -/
def SupportedIR (ir : DecodedIR) : Prop :=
  match ir with
  | .execution (.typed env payload) =>
    env.mode = "typed-execute" ∧
    payload.state.cells.length = 32 ∧
    payload.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    (payload.registry.entries.map (·.id)).Nodup
  | .execution (.step env payload) =>
    env.mode = "composition-step" ∧
    (match payload.step with | .unsupported _ => False | _ => True) ∧
    payload.pre.state.cells.length = 32 ∧
    payload.pre.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    (payload.config.registry.entries.map (·.id)).Nodup
  | .execution (.run env payload) =>
    env.mode = "composition-run" ∧
    payload.steps.all (fun s ↦ match s with | .unsupported _ => false | _ => true) = true ∧
    payload.world.state.cells.length = 32 ∧
    payload.world.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    (payload.config.registry.entries.map (·.id)).Nodup
  | .audit _ => False
  | .codec _ => False

/-- Canonical DecodedIR predicate requiring canonical rationals (lowest terms, den > 0).
    Non-canonical orders or whitespace are byte-level decode refusals. -/
def CanonicalIR (ir : DecodedIR) : Prop :=
  match ir with
  | .execution (.typed _ payload) =>
    payload.state.cells.all (fun c ↦ c.amount.den > 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true
  | .execution (.step _ payload) =>
    payload.pre.state.cells.all (fun c ↦ c.amount.den > 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true
  | .execution (.run _ payload) =>
    payload.world.state.cells.all (fun c ↦ c.amount.den > 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true
  | .audit _ => False
  | .codec _ => False

/-- Statement of universal roundtrip obligation (RC01 / P20 open obligation).
Recorded as a formal Prop without sorry or custom axioms. -/
def EncodeDecodeRoundtripStatement : Prop :=
  ∀ (ir : DecodedIR), SupportedIR ir → CanonicalIR ir → decodeBytes (encodeModule ir) = .ok ir

/-- Statement of canonical bytes obligation (P20 open obligation). -/
def DecodeEncodeCanonicalBytesStatement : Prop :=
  ∀ raw ir, decodeBytes raw = .ok ir → CanonicalIR ir → encodeModule ir = raw

/-- Refused decode returns no kernel object (S39-S40, S78). -/
theorem decode_error_no_kernel (raw : ByteArray) (e : DecodeFailure)
    (h : decodeBytes raw = .error e) (h_not_res : ∀ lim, e ≠ .resourceLimit lim) :
    checkBytes raw = .codec (.malformed e) := by
  dsimp [checkBytes]
  rw [h]
  cases e with
  | resourceLimit lim =>
    exfalso
    exact h_not_res lim rfl
  | emptyDocument => rfl
  | lexicalScientificOrFloat => rfl
  | notJsonObject => rfl
  | duplicateKey _ => rfl
  | noncanonicalWhitespace => rfl
  | schemaVersion => rfl
  | missingField _ => rfl
  | jsonType _ => rfl
  | unknownIdentifier _ => rfl
  | uniqueness _ => rfl
  | illegalRational _ => rfl
  | stateNonneg => rfl
  | unknownExecutableField _ => rfl
  | unsupportedForm _ => rfl

/-- Resource limit decode refusal maps to blocked codec result. -/
theorem decode_error_resource_limit (raw : ByteArray) (lim : String)
    (h : decodeBytes raw = .error (.resourceLimit lim)) :
    checkBytes raw = .codec (.blocked lim) := by
  dsimp [checkBytes]
  rw [h]

/-- Canonical rational decoding theorem: canonical numerator/denominator pair decodes to RatEnc. -/
theorem rational_decode_canonical (num : Int) (den : Nat) (h_den : den ≠ 0) (h_gcd : Int.gcd num.natAbs den = 1) :
    decodeRational num den = .ok ⟨num, den⟩ := by
  unfold decodeRational
  split
  · contradiction
  · split
    · rename_i h_noncan
      have h1 : ¬ (Int.gcd num.natAbs den ≠ 1) := by
        intro h_contra
        exact h_contra h_gcd
      contradiction
    · rfl

/-- Exact correspondence between RatEnc and ℚ components. -/
theorem rat_fromRat_num_den (q : ℚ) :
    (RatEnc.fromRat q).num = q.num ∧ (RatEnc.fromRat q).den = q.den :=
  ⟨rfl, rfl⟩

/-- Rational encode/decode roundtrip: any canonical rational roundtrips via decodeRational. -/
theorem rational_roundtrip (r : RatEnc) (h_den : r.den ≠ 0) (h_gcd : Int.gcd r.num.natAbs r.den = 1) :
    decodeRational r.num r.den = .ok r :=
  rational_decode_canonical r.num r.den h_den h_gcd

end DefiKernel.Certificates
