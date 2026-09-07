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
  have hn : n < 2 ^ w := lt_of_le_of_lt (fee_bound _ _ _ _ _ hr hd) gross.bound
  have hnet : gross.value - n < 2 ^ w := lt_of_le_of_lt (Nat.sub_le _ _) gross.bound
  refine ⟨⟨gross, ⟨n, hn⟩, gross, ⟨gross.value - n, hnet⟩⟩, ?_, rfl, rfl, rfl, rfl⟩
  simp [feeFromGross, bind, Except.bind, validatedRate, Nat.ne_of_gt hs, not_lt.mpr hr, hd,
    Word.checked, hn, hnet, pure, Except.pure]

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
    · simp [feeFromGross, bind, Except.bind, validatedRate, Nat.lt_of_not_ge hr, hr]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeFromGross, bind, Except.bind, validatedRate, hz]

theorem feeFromGross_error_iff (mode : Rounding) (gross : Word w) (num den : Nat)
    (failure : Failure) :
    feeFromGross mode gross num den = .error failure ↔
      (den = 0 ∨ den < num) ∧ failure = .invalidRate := by
  by_cases hs : 0 < den
  · by_cases hr : num ≤ den
    · obtain ⟨n, hd⟩ := (Rounding.divideNat_exists_iff mode (gross.value * num) den).mpr hs
      obtain ⟨actual, he, _⟩ := feeFromGross_of_round mode gross num den n hs hr hd
      simp [he, Nat.ne_of_gt hs, not_lt.mpr hr]
    · simp [feeFromGross, bind, Except.bind, validatedRate, Nat.lt_of_not_ge hr, eq_comm]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeFromGross, bind, Except.bind, validatedRate, hz, eq_comm]

theorem feeFromGross_conservation (mode : Rounding) (gross : Word w) (num den : Nat)
    (quote : FeeQuote w) (success : feeFromGross mode gross num den = .ok quote) :
    quote.charged.value = quote.received.value + quote.fee.value := by
  obtain ⟨_, hr, hd, _, hc, hn⟩ := (feeFromGross_ok_iff _ _ _ _ _).mp success
  have hb := fee_bound mode gross num den quote.fee.value hr hd
  rw [hc, hn]
  omega

theorem feeOnTop_of_round (mode : Rounding) (principal : Word w) (num den n : Nat)
    (hs : 0 < den) (hr : num ≤ den)
    (hd : Rounding.divideNat mode (principal.value * num) den = .ok n)
    (hb : principal.value + n < 2 ^ w) :
    ∃ quote, feeOnTop mode principal num den = .ok quote ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.fee.value = n ∧ quote.charged.value = principal.value + n := by
  have hn : n < 2 ^ w := lt_of_le_of_lt (fee_bound _ _ _ _ _ hr hd) principal.bound
  refine ⟨⟨principal, ⟨n, hn⟩, ⟨principal.value + n, hb⟩, principal⟩,
    ?_, rfl, rfl, rfl, rfl⟩
  simp [feeOnTop, bind, Except.bind, validatedRate, Nat.ne_of_gt hs, not_lt.mpr hr, hd,
    Word.checked, hn, hb, pure, Except.pure]

theorem feeOnTop_overflow_of_round (mode : Rounding) (principal : Word w)
    (num den n : Nat) (hs : 0 < den) (hr : num ≤ den)
    (hd : Rounding.divideNat mode (principal.value * num) den = .ok n)
    (hb : 2 ^ w ≤ principal.value + n) :
    feeOnTop mode principal num den = .error .addOverflow := by
  have hn : n < 2 ^ w := lt_of_le_of_lt (fee_bound _ _ _ _ _ hr hd) principal.bound
  simp [feeOnTop, bind, Except.bind, validatedRate, Nat.ne_of_gt hs, not_lt.mpr hr, hd,
    Word.checked, hn, not_lt.mpr hb]

theorem feeOnTop_ok_iff (mode : Rounding) (principal : Word w) (num den : Nat)
    (quote : FeeQuote w) :
    feeOnTop mode principal num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧
      Rounding.divideNat mode (principal.value * num) den = .ok quote.fee.value ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.charged.value = principal.value + quote.fee.value := by
  by_cases hs : 0 < den
  · by_cases hr : num ≤ den
    · obtain ⟨n, hd⟩ :=
        (Rounding.divideNat_exists_iff mode (principal.value * num) den).mpr hs
      by_cases hb : principal.value + n < 2 ^ w
      · obtain ⟨actual, he, hp, hc, hf, hn⟩ :=
          feeOnTop_of_round mode principal num den n hs hr hd hb
        constructor
        · intro h
          have e : actual = quote := Except.ok.inj (he.symm.trans h)
          subst actual
          exact ⟨hs, hr, hf ▸ hd, hp, hc, hf ▸ hn⟩
        · rintro ⟨_, _, hdiv, qp, qc, qn⟩
          have nq : n = quote.fee.value := Except.ok.inj (hd.symm.trans hdiv)
          have af : actual.fee = quote.fee := Word.ext (hf.trans nq)
          have an : actual.charged = quote.charged := Word.ext (hn.trans (nq ▸ qn.symm))
          have ap := hp.trans qp.symm
          have ac := hc.trans qc.symm
          have eq : actual = quote := by cases actual; cases quote; simp_all
          exact he.trans (congrArg Except.ok eq)
      · have he := feeOnTop_overflow_of_round mode principal num den n hs hr hd
          (Nat.le_of_not_gt hb)
        rw [he]
        simp only [reduceCtorEq, false_iff]
        rintro ⟨_, _, hdiv, _, _, hq⟩
        have nq : n = quote.fee.value := Except.ok.inj (hd.symm.trans hdiv)
        exact hb (by simpa [nq, ← hq] using quote.charged.bound)
    · simp [feeOnTop, bind, Except.bind, validatedRate, Nat.lt_of_not_ge hr, hr]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeOnTop, bind, Except.bind, validatedRate, hz]

theorem feeOnTop_error_iff (mode : Rounding) (principal : Word w) (num den : Nat)
    (failure : Failure) :
    feeOnTop mode principal num den = .error failure ↔
      ((den = 0 ∨ den < num) ∧ failure = .invalidRate) ∨
      (0 < den ∧ num ≤ den ∧ ∃ n,
        Rounding.divideNat mode (principal.value * num) den = .ok n ∧
        2 ^ w ≤ principal.value + n ∧ failure = .addOverflow) := by
  by_cases hs : 0 < den
  · by_cases hr : num ≤ den
    · obtain ⟨n, hd⟩ :=
        (Rounding.divideNat_exists_iff mode (principal.value * num) den).mpr hs
      by_cases hb : principal.value + n < 2 ^ w
      · obtain ⟨actual, he, _⟩ := feeOnTop_of_round mode principal num den n hs hr hd hb
        simp [he, Nat.ne_of_gt hs, not_lt.mpr hr, hs, hr, hd, Nat.not_le_of_lt hb]
      · have he := feeOnTop_overflow_of_round mode principal num den n hs hr hd
          (Nat.le_of_not_gt hb)
        simp [he, Nat.ne_of_gt hs, not_lt.mpr hr, hs, hr, hd, Nat.le_of_not_gt hb, eq_comm]
    · simp [feeOnTop, bind, Except.bind, validatedRate, Nat.lt_of_not_ge hr, hr, eq_comm]
  · have hz : den = 0 := Nat.eq_zero_of_not_pos hs
    simp [feeOnTop, bind, Except.bind, validatedRate, hz, eq_comm]

theorem feeOnTop_conservation (mode : Rounding) (principal : Word w) (num den : Nat)
    (quote : FeeQuote w) (success : feeOnTop mode principal num den = .ok quote) :
    quote.charged.value = quote.received.value + quote.fee.value := by
  obtain ⟨_, _, _, _, hr, hc⟩ := (feeOnTop_ok_iff _ _ _ _ _).mp success
  simpa [hr] using hc

/-- The success specification uses independent floor inequalities. -/
theorem feeFromGross_down_ok_iff (gross : Word w) (num den : Nat) (quote : FeeQuote w) :
    feeFromGross .down gross num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧ quote.fee.value * den ≤ gross.value * num ∧
      gross.value * num < (quote.fee.value + 1) * den ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.received.value = gross.value - quote.fee.value := by
  rw [feeFromGross_ok_iff, Rounding.divideNat_down_ok_iff]
  constructor
  · rintro ⟨hs, hr, ⟨_, hlo, hhi⟩, hp, hc, hn⟩
    exact ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
  · rintro ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
    exact ⟨hs, hr, ⟨hs, hlo, hhi⟩, hp, hc, hn⟩

/-- The success specification uses independent ceiling leastness. -/
theorem feeFromGross_up_ok_iff (gross : Word w) (num den : Nat) (quote : FeeQuote w) :
    feeFromGross .up gross num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧ gross.value * num ≤ quote.fee.value * den ∧
      (∀ k : Nat, gross.value * num ≤ k * den → quote.fee.value ≤ k) ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.received.value = gross.value - quote.fee.value := by
  rw [feeFromGross_ok_iff, Rounding.divideNat_up_ok_iff]
  constructor
  · rintro ⟨hs, hr, ⟨_, hlo, hhi⟩, hp, hc, hn⟩
    exact ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
  · rintro ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
    exact ⟨hs, hr, ⟨hs, hlo, hhi⟩, hp, hc, hn⟩

/-- The success specification uses independent floor inequalities. -/
theorem feeOnTop_down_ok_iff (principal : Word w) (num den : Nat) (quote : FeeQuote w) :
    feeOnTop .down principal num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧ quote.fee.value * den ≤ principal.value * num ∧
      principal.value * num < (quote.fee.value + 1) * den ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.charged.value = principal.value + quote.fee.value := by
  rw [feeOnTop_ok_iff, Rounding.divideNat_down_ok_iff]
  constructor
  · rintro ⟨hs, hr, ⟨_, hlo, hhi⟩, hp, hc, hn⟩
    exact ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
  · rintro ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
    exact ⟨hs, hr, ⟨hs, hlo, hhi⟩, hp, hc, hn⟩

/-- The success specification uses independent ceiling leastness. -/
theorem feeOnTop_up_ok_iff (principal : Word w) (num den : Nat) (quote : FeeQuote w) :
    feeOnTop .up principal num den = .ok quote ↔
      0 < den ∧ num ≤ den ∧ principal.value * num ≤ quote.fee.value * den ∧
      (∀ k : Nat, principal.value * num ≤ k * den → quote.fee.value ≤ k) ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.charged.value = principal.value + quote.fee.value := by
  rw [feeOnTop_ok_iff, Rounding.divideNat_up_ok_iff]
  constructor
  · rintro ⟨hs, hr, ⟨_, hlo, hhi⟩, hp, hc, hn⟩
    exact ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
  · rintro ⟨hs, hr, hlo, hhi, hp, hc, hn⟩
    exact ⟨hs, hr, ⟨hs, hlo, hhi⟩, hp, hc, hn⟩

theorem feeFromGross_zero_rate (mode : Rounding) (gross : Word w) (den : Nat)
    (hs : 0 < den) :
    ∃ quote, feeFromGross mode gross 0 den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = 0 ∧ quote.received.value = gross.value := by
  have hd : Rounding.divideNat mode (gross.value * 0) den = .ok 0 := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs]
  simpa using feeFromGross_of_round mode gross 0 den 0 hs (Nat.zero_le _) hd

theorem feeOnTop_zero_rate (mode : Rounding) (principal : Word w) (den : Nat)
    (hs : 0 < den) :
    ∃ quote, feeOnTop mode principal 0 den = .ok quote ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.fee.value = 0 ∧ quote.charged.value = principal.value := by
  have hd : Rounding.divideNat mode (principal.value * 0) den = .ok 0 := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs]
  simpa using feeOnTop_of_round mode principal 0 den 0 hs (Nat.zero_le _) hd
    (by simpa using principal.bound)

theorem feeFromGross_zero_amount (mode : Rounding) (gross : Word w) (num den : Nat)
    (hs : 0 < den) (hr : num ≤ den) (hz : gross.value = 0) :
    ∃ quote, feeFromGross mode gross num den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = 0 ∧ quote.received.value = 0 := by
  have hd : Rounding.divideNat mode (gross.value * num) den = .ok 0 := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs, hz]
  simpa [hz] using feeFromGross_of_round mode gross num den 0 hs hr hd

theorem feeOnTop_zero_amount (mode : Rounding) (principal : Word w) (num den : Nat)
    (hs : 0 < den) (hr : num ≤ den) (hz : principal.value = 0) :
    ∃ quote, feeOnTop mode principal num den = .ok quote ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.fee.value = 0 ∧ quote.charged.value = 0 := by
  have hd : Rounding.divideNat mode (principal.value * num) den = .ok 0 := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs, hz]
  simpa [hz] using feeOnTop_of_round mode principal num den 0 hs hr hd
    (by simpa using principal.bound)

theorem feeFromGross_unit_rate (mode : Rounding) (gross : Word w) (den : Nat)
    (hs : 0 < den) :
    ∃ quote, feeFromGross mode gross den den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = gross.value ∧ quote.received.value = 0 := by
  have hd : Rounding.divideNat mode (gross.value * den) den = .ok gross.value := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs]
  simpa using feeFromGross_of_round mode gross den den gross.value hs (Nat.le_refl _) hd

theorem feeOnTop_unit_rate (mode : Rounding) (principal : Word w) (den : Nat)
    (hs : 0 < den) (hb : principal.value + principal.value < 2 ^ w) :
    ∃ quote, feeOnTop mode principal den den = .ok quote ∧
      quote.principal = principal ∧ quote.received = principal ∧
      quote.fee.value = principal.value ∧
      quote.charged.value = principal.value + principal.value := by
  have hd : Rounding.divideNat mode (principal.value * den) den = .ok principal.value := by
    cases mode <;> simp [Rounding.divideNat, Nat.ne_of_gt hs]
  exact feeOnTop_of_round mode principal den den principal.value hs (Nat.le_refl _) hd hb

theorem feeFromGross_exact_fraction (mode : Rounding) (gross : Word w) (num den : Nat)
    (quote : FeeQuote w) (hd : den ∣ gross.value * num)
    (success : feeFromGross mode gross num den = .ok quote) :
    quote.fee.value = gross.value * num / den := by
  obtain ⟨hs, _, hq, _⟩ := (feeFromGross_ok_iff _ _ _ _ _).mp success
  have hm := Nat.mod_eq_zero_of_dvd hd
  cases mode <;> simpa [Rounding.divideNat, Nat.ne_of_gt hs, hm] using hq.symm

theorem feeOnTop_exact_fraction (mode : Rounding) (principal : Word w) (num den : Nat)
    (quote : FeeQuote w) (hd : den ∣ principal.value * num)
    (success : feeOnTop mode principal num den = .ok quote) :
    quote.fee.value = principal.value * num / den := by
  obtain ⟨hs, _, hq, _⟩ := (feeOnTop_ok_iff _ _ _ _ _).mp success
  have hm := Nat.mod_eq_zero_of_dvd hd
  cases mode <;> simpa [Rounding.divideNat, Nat.ne_of_gt hs, hm] using hq.symm

theorem feeFromGross_exists_iff (mode : Rounding) (gross : Word w) (num den : Nat) :
    (∃ quote, feeFromGross mode gross num den = .ok quote) ↔ 0 < den ∧ num ≤ den := by
  constructor
  · rintro ⟨quote, hq⟩
    have h := (feeFromGross_ok_iff _ _ _ _ _).mp hq
    exact ⟨h.1, h.2.1⟩
  · rintro ⟨hs, hr⟩
    obtain ⟨n, hd⟩ := (Rounding.divideNat_exists_iff mode (gross.value * num) den).mpr hs
    obtain ⟨quote, hq, _⟩ := feeFromGross_of_round mode gross num den n hs hr hd
    exact ⟨quote, hq⟩

theorem feeFromGross_fee_le (mode : Rounding) (gross : Word w) (num den : Nat)
    (quote : FeeQuote w) (success : feeFromGross mode gross num den = .ok quote) :
    quote.fee.value ≤ gross.value := by
  obtain ⟨_, hr, hd, _⟩ := (feeFromGross_ok_iff _ _ _ _ _).mp success
  exact fee_bound _ _ _ _ _ hr hd

theorem feeOnTop_fee_le (mode : Rounding) (principal : Word w) (num den : Nat)
    (quote : FeeQuote w) (success : feeOnTop mode principal num den = .ok quote) :
    quote.fee.value ≤ principal.value := by
  obtain ⟨_, hr, hd, _⟩ := (feeOnTop_ok_iff _ _ _ _ _).mp success
  exact fee_bound _ _ _ _ _ hr hd

/-- A proper fractional fee rounds to zero on a one-unit gross amount. -/
theorem feeFromGross_one_down (gross : Word w) (num den : Nat)
    (hg : gross.value = 1) (hr : num < den) :
    ∃ quote, feeFromGross .down gross num den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = 0 ∧ quote.received.value = 1 := by
  have hs : 0 < den := lt_of_le_of_lt (Nat.zero_le _) hr
  have hd : Rounding.divideNat .down (gross.value * num) den = .ok 0 := by
    apply (Rounding.divideNat_down_ok_iff _ _ _).mpr
    simpa [hg] using And.intro hs (And.intro (Nat.zero_le num) hr)
  simpa [hg] using feeFromGross_of_round .down gross num den 0 hs (Nat.le_of_lt hr) hd

/-- A positive valid fractional fee rounds to one on a one-unit gross amount. -/
theorem feeFromGross_one_up (gross : Word w) (num den : Nat)
    (hg : gross.value = 1) (hn : 0 < num) (hr : num ≤ den) :
    ∃ quote, feeFromGross .up gross num den = .ok quote ∧
      quote.principal = gross ∧ quote.charged = gross ∧
      quote.fee.value = 1 ∧ quote.received.value = 0 := by
  have hs : 0 < den := lt_of_lt_of_le hn hr
  have hd : Rounding.divideNat .up (gross.value * num) den = .ok 1 := by
    apply (Rounding.divideNat_up_ok_iff _ _ _).mpr
    refine ⟨hs, by simpa [hg] using hr, ?_⟩
    intro k hk
    by_contra h
    have hz : k = 0 := by omega
    simp [hz, hg] at hk
    omega
  simpa [hg] using feeFromGross_of_round .up gross num den 1 hs hr hd

end DefiKernel.Arithmetic.Fees
