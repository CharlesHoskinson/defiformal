import DefiKernel.Arithmetic.Rounding

/-! Gross-based and on-top fee quotes. Natural rate parameters are never word-truncated. -/
namespace DefiKernel.Arithmetic.Fees

structure FeeQuote (w : Nat) where
  principal : Word w
  fee : Word w
  charged : Word w
  received : Word w
  deriving DecidableEq, Repr

variable {w : Nat}

def validatedRate (num den : Nat) : Except Failure Nat :=
  if den = 0 ∨ num > den then .error .invalidRate else .ok num

def feeFromGross (mode : Rounding) (gross : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (gross.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let received ← Word.checked .subUnderflow (gross.value - fee.value)
  return ⟨gross, fee, gross, received⟩

def feeOnTop (mode : Rounding) (principal : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (principal.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let charged ← Word.checked .addOverflow (principal.value + fee.value)
  return ⟨principal, fee, charged, principal⟩

-- BEGIN PROOFS

@[simp] theorem validatedRate_ok_iff (num den rate : Nat) :
    validatedRate num den = .ok rate ↔ 0 < den ∧ num ≤ den ∧ num = rate := by
  unfold validatedRate
  by_cases h : den = 0 ∨ num > den
  · simp only [h, if_true, reduceCtorEq, false_iff]
    omega
  · simp only [h, if_false, Except.ok.injEq]
    omega

@[simp] theorem validatedRate_error_iff (num den : Nat) (failure : Failure) :
    validatedRate num den = .error failure ↔
      (den = 0 ∨ den < num) ∧ failure = .invalidRate := by
  unfold validatedRate
  by_cases h : den = 0 ∨ num > den <;> simp [h, eq_comm]

theorem fee_bound (mode : Rounding) (amount : Word w) (num den n : Nat)
    (hr : num ≤ den) (hd : Rounding.divideNat mode (amount.value * num) den = .ok n) :
    n ≤ amount.value :=
  Rounding.divideNat_le mode _ _ _ _ hd (Nat.mul_le_mul_left _ hr)

theorem feeFromGross_of_round (mode : Rounding) (gross : Word w) (num den n : Nat)
    (hs : 0 < den) (hr : num ≤ den)
    (hd : Rounding.divideNat mode (gross.value * num) den = .ok n) :
    ∃ quote, feeFromGross mode gross num den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = n ∧ quote.received.value = gross.value - n := by
  have hn : n < 2^w := lt_of_le_of_lt (fee_bound _ _ _ _ _ hr hd) gross.bound
  have hnet : gross.value - n < 2^w := lt_of_le_of_lt (Nat.sub_le _ _) gross.bound
  refine ⟨⟨gross, ⟨n, hn⟩, gross, ⟨gross.value - n, hnet⟩⟩, ?_, rfl, rfl, rfl, rfl⟩
  simp [feeFromGross, bind, Except.bind, Functor.map, Except.map, validatedRate, Nat.ne_of_gt hs, not_lt.mpr hr, hd,
    Word.checked, hn, hnet]

theorem feeFromGross_ok_iff (mode : Rounding) (gross : Word w) (num den : Nat)
    (quote : FeeQuote w) :
    feeFromGross mode gross num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧
      Rounding.divideNat mode (gross.value * num) den = .ok quote.fee.value ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.received.value = gross.value - quote.fee.value := by
  by_cases hs : 0 < den
  · by_cases hr : num ≤ den
    · obtain ⟨n, hd⟩ := (Rounding.divideNat_exists_iff mode (gross.value * num) den).mpr hs
      obtain ⟨actual, he, hp, hc, hf, hn⟩ := feeFromGross_of_round mode gross num den n hs hr hd
      constructor
      · intro h
        have e : actual = quote := Except.ok.inj (he.symm.trans h)
        subst actual
        exact ⟨hs, hr, hf ▸ hd, hp, hc, hf ▸ hn⟩
      · rintro ⟨_, _, hdiv, qp, qc, qn⟩
        have nq : n = quote.fee.value := Except.ok.inj (hd.symm.trans hdiv)
        have af : actual.fee = quote.fee := Word.ext (hf.trans nq)
        have an : actual.received = quote.received := Word.ext (hn.trans (nq ▸ qn.symm))
        have ap := hp.trans qp.symm
        have ac := hc.trans qc.symm
        have eq : actual = quote := by cases actual; cases quote; simp_all
        exact he.trans (congrArg Except.ok eq)
    · simp [feeFromGross, bind, Except.bind, Functor.map, Except.map, validatedRate, Nat.lt_of_not_ge hr, hr]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeFromGross, bind, Except.bind, Functor.map, Except.map, validatedRate, hz]

theorem feeFromGross_error_iff (mode : Rounding) (gross : Word w) (num den : Nat)
    (failure : Failure) :
    feeFromGross mode gross num den = .error failure ↔
      (den = 0 ∨ den < num) ∧ failure = .invalidRate := by
  by_cases hs : 0 < den
  · by_cases hr : num ≤ den
    · obtain ⟨n, hd⟩ := (Rounding.divideNat_exists_iff mode (gross.value * num) den).mpr hs
      obtain ⟨actual, he, _⟩ := feeFromGross_of_round mode gross num den n hs hr hd
      simp [he, Nat.ne_of_gt hs, not_lt.mpr hr]
    · simp [feeFromGross, bind, Except.bind, Functor.map, Except.map, validatedRate, Nat.lt_of_not_ge hr, eq_comm]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeFromGross, bind, Except.bind, Functor.map, Except.map, validatedRate, hz, eq_comm]

theorem feeFromGross_conservation (mode : Rounding) (gross : Word w) (num den : Nat)
    (quote : FeeQuote w) (success : feeFromGross mode gross num den = .ok quote) :
    quote.charged.value = quote.received.value + quote.fee.value := by
  obtain ⟨_, hr, hd, _, hc, hn⟩ := (feeFromGross_ok_iff _ _ _ _ _).mp success
  have hb := fee_bound mode gross num den quote.fee.value hr hd
  rw [hc, hn]
  omega

end DefiKernel.Arithmetic.Fees
