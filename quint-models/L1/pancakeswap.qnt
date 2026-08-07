// PancakeSwap Infinity — vault + CL pool manager split (custody ≠ pricing).
// Source: protocol-repos/dex/pancakeswap_infinity-core/src/
//   Vault / SettlementGuard (unsettled deltas), CLPoolManager (concentrated).
// Sibling to Uniswap V4 flash accounting; hook permissions live in pool key bits
// (not mined into hook address as in Uni V4).
// Model: vault balances + one CL active range + deferred deltas.

module pancakeswap {
  import common.* from "./common"

  pure val FEE_NUM: int = 9975
  pure val FEE_DEN: int = 10000
  pure val PROTOCOL_SPLIT: int = 33  // 33% of fee → protocol (docs)

  var vault0: int
  var vault1: int
  var activeL: int
  var price: int
  var unlocked: bool
  var delta0: int
  var delta1: int
  var protocolFees0: int

  action init: bool = all {
    vault0' = 100,
    vault1' = 100,
    activeL' = 50,
    price' = 100,
    unlocked' = false,
    delta0' = 0,
    delta1' = 0,
    protocolFees0' = 0,
  }

  action lockVault: bool = all {
    not(unlocked),
    unlocked' = true,
    delta0' = 0,
    delta1' = 0,
    vault0' = vault0,
    vault1' = vault1,
    activeL' = activeL,
    price' = price,
    protocolFees0' = protocolFees0,
  }

  action swap0for1(amountIn: int): bool = all {
    unlocked,
    amountIn > 0,
    activeL > 0,
    val fee = mulDivDown(amountIn, FEE_DEN - FEE_NUM, FEE_DEN)
    val toProtocol = mulDivDown(fee, PROTOCOL_SPLIT, 100)
    val out = cpAmountOut(vault0, vault1, amountIn, FEE_NUM, FEE_DEN)
    all {
      out > 0, out < vault1,
      vault0' = vault0 + amountIn,
      vault1' = vault1 - out,
      delta0' = delta0 - amountIn,
      delta1' = delta1 + out,
      protocolFees0' = protocolFees0 + toProtocol,
      unlocked' = true,
      activeL' = activeL,
      price' = max(price - 1, 1),
    }
  }

  action settleAndUnlock: bool = all {
    unlocked,
    // Integrator settles net: for simplicity require already zero, or force-settle
    // by absorbing remaining deltas into vault (must be zero for success path)
    deltasNetZero(delta0, delta1),
    unlocked' = false,
    delta0' = 0,
    delta1' = 0,
    vault0' = vault0,
    vault1' = vault1,
    activeL' = activeL,
    price' = price,
    protocolFees0' = protocolFees0,
  }

  /// settle path used mid-scope: pay delta0 debt
  action settle0(userBal0: int): bool = all {
    unlocked,
    delta0 < 0,
    val pay = 0 - delta0
    all {
      userBal0 >= pay,
      delta0' = 0,
      delta1' = delta1,
      unlocked' = true,
      vault0' = vault0,
      vault1' = vault1,
      activeL' = activeL,
      price' = price,
      protocolFees0' = protocolFees0,
    }
  }

  action take1: bool = all {
    unlocked,
    delta1 > 0,
    delta1' = 0,
    delta0' = delta0,
    unlocked' = true,
    vault0' = vault0,
    vault1' = vault1,
    activeL' = activeL,
    price' = price,
    protocolFees0' = protocolFees0,
  }

  action step: bool = {
    nondet din = 1.to(12).oneOf()
    nondet ub = 20.to(50).oneOf()
    any {
      lockVault,
      swap0for1(din),
      settle0(ub),
      take1,
      settleAndUnlock,
    }
  }

  val lockedImpliesSettled: bool =
    not(unlocked) implies deltasNetZero(delta0, delta1)

  val vaultNonNeg: bool = vault0 >= 0 and vault1 >= 0 and activeL >= 0
}
