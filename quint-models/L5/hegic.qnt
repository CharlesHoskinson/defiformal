// Hegic — peer-to-pool options: OperationalTreasury locks max-loss at write.
// Sources:
//   hegic_contracts/packages/herge/contracts/OperationalTreasury.sol
//     buy (L76) → strategy.create → _lockLiquidity (L101)
//     unlock (L139) after expiration
//     payOff (L154) before expiration
//     totalBalance (L236) = token.balanceOf(this)
//   IOperationalTreasury.LockedLiquidity { state, negativepnl, positivepnl, expiration }
// Solvency gate at write (L113-117):
//   totalLocked + lockedPremium <= totalBalance() + coverPool.availableForPayment()
// Scope: one treasury, one cover pool number, fixed-size positions, cash payoff.
// NOT covered: strategy-specific pricers, CoverPool epochs, admin withdraw,
//   composed payoffs (straddle/strangle as separate strategies).

module hegic {
  import common.* from "./common"

  pure val POS_IDS: Set[int] = Set(0, 1, 2)
  pure val MAX_LOSS_SET: Set[int] = Set(10, 20, 30)
  pure val PREMIUM_SET: Set[int] = Set(1, 2, 5)
  pure val PAYOFF_SET: Set[int] = Set(0, 5, 15, 25)
  pure val TIME_SET: Set[int] = Set(0, 1, 2, 5)

  type PosState = Idle | Locked | Unlocked

  type Position = {
    state: PosState,
    maxLoss: int,      // negativePNL
    premium: int,      // positivePNL
    expiration: int,
  }

  pure def emptyPos: Position =
    { state: Idle, maxLoss: 0, premium: 0, expiration: 0 }

  var book: ReservedBook
  var positions: int -> Position
  var nextId: int
  var now: int

  action init: bool = all {
    // Seed treasury with balance so writes can be admitted.
    book' = { totalLocked: 0, lockedPremium: 0, balance: 100, coverAvailable: 20 },
    positions' = POS_IDS.mapBy(_ => emptyPos),
    nextId' = 0,
    now' = 0,
  }

  /// OperationalTreasury.buy → _lockLiquidity
  action buy(maxLoss: int, premium: int, period: int): bool = all {
    MAX_LOSS_SET.contains(maxLoss),
    PREMIUM_SET.contains(premium),
    TIME_SET.contains(period),
    nextId < 3,
    canReserve(book, maxLoss, premium),
    book' = applyReserve(book, maxLoss, premium),
    positions' = positions.put(nextId, {
      state: Locked,
      maxLoss: maxLoss,
      premium: premium,
      expiration: now + period + 1,  // period 0 still expires after advance
    }),
    nextId' = nextId + 1,
    now' = now,
  }

  /// OperationalTreasury.unlock — after expiration; release reservation, keep premium.
  action unlock(id: int): bool = {
    val p = positions.get(id)
    all {
      POS_IDS.contains(id),
      p.state == Locked,
      now > p.expiration,
      canRelease(book, p.maxLoss, p.premium),
      book' = applyRelease(book, p.maxLoss, p.premium),
      positions' = positions.put(id, { ...p, state: Unlocked }),
      nextId' = nextId,
      now' = now,
    }
  }

  /// OperationalTreasury.payOff — exercise before expiry; payoff <= maxLoss.
  action payOff(id: int, amount: int): bool = {
    val p = positions.get(id)
    val released = applyRelease(book, p.maxLoss, p.premium)
    all {
      POS_IDS.contains(id),
      PAYOFF_SET.contains(amount),
      p.state == Locked,
      now <= p.expiration,
      amount >= 0,
      amount <= p.maxLoss,
      canRelease(book, p.maxLoss, p.premium),
      // ensure cover+balance can pay after releasing reservation
      capacity(released) >= amount,
      book' = applyPayClaim(released, amount),
      positions' = positions.put(id, { ...p, state: Unlocked }),
      nextId' = nextId,
      now' = now,
    }
  }

  /// Time advance (abstract).
  action tick(dt: int): bool = all {
    TIME_SET.contains(dt),
    dt > 0,
    now' = now + dt,
    book' = book,
    positions' = positions,
    nextId' = nextId,
  }

  /// Admin/LP top-up of treasury balance (provide liquidity).
  action provide(amt: int): bool = all {
    MAX_LOSS_SET.contains(amt),
    amt > 0,
    book' = { ...book, balance: book.balance + amt },
    positions' = positions,
    nextId' = nextId,
    now' = now,
  }

  action step: bool = any {
    nondet ml = MAX_LOSS_SET.oneOf()
    nondet pr = PREMIUM_SET.oneOf()
    nondet pe = TIME_SET.oneOf()
    buy(ml, pr, pe),
    nondet i = POS_IDS.oneOf()
    unlock(i),
    nondet j = POS_IDS.oneOf()
    nondet po = PAYOFF_SET.oneOf()
    payOff(j, po),
    nondet d = TIME_SET.oneOf()
    tick(d),
    nondet a = MAX_LOSS_SET.oneOf()
    provide(a),
  }

  /// Write-time solvency invariant: locked + premium <= capacity, or no locks.
  /// After payOff, balance may drop while locks already released — still holds.
  val writeSolvency: bool =
    book.totalLocked >= 0
      and book.lockedPremium >= 0
      and book.balance >= 0
      and book.coverAvailable >= 0
      and (book.totalLocked + book.lockedPremium <= capacity(book))

  /// Position book matches aggregate locks.
  val lockAccounting: bool = {
    val lockedLoss = POS_IDS.fold(0, (acc, id) => {
      val p = positions.get(id)
      if (p.state == Locked) acc + p.maxLoss else acc
    })
    val lockedPrem = POS_IDS.fold(0, (acc, id) => {
      val p = positions.get(id)
      if (p.state == Locked) acc + p.premium else acc
    })
    book.totalLocked == lockedLoss and book.lockedPremium == lockedPrem
  }
}
