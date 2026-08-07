// Raydium CPMM — constant-product with protocol/fund/creator fee split.
// Source: protocol-repos/dex/raydium-io_raydium-cp-swap/programs/cp-swap/src/
//   states/pool.rs PoolState { lp_supply, protocol_fees_token_*, fund_fees_*, creator_fees_* }
//   curve/constant_product.rs ConstantProductCurve::swap_base_input_without_fees
// Distinction vs Uni V2: multi-leg fee accrual into separate fee vaults (not kLast mint).

module raydium_cp {
  import common.* from "./common"

  pure val FEE_NUM: int = 9975   // example: 0.25% trade fee remainder
  pure val FEE_DEN: int = 10000
  pure val PROTOCOL_SHARE: int = 12  // of 100 fee units → protocol
  pure val FUND_SHARE: int = 4
  // remainder 84 → LPs (stays in vaults / inflates k)
  pure val USERS: Set[str] = Set("alice", "bob")

  var vault0: int
  var vault1: int
  var lpSupply: int
  var lpBal: str -> int
  var protocolFees0: int
  var protocolFees1: int
  var fundFees0: int
  var fundFees1: int

  action init: bool = all {
    vault0' = 100,
    vault1' = 100,
    lpSupply' = 100,
    lpBal' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    protocolFees0' = 0,
    protocolFees1' = 0,
    fundFees0' = 0,
    fundFees1' = 0,
  }

  action deposit(u: str, a0: int, a1: int): bool = all {
    USERS.contains(u),
    a0 > 0, a1 > 0, lpSupply > 0,
    val liq = min(mulDivDown(a0, lpSupply, vault0), mulDivDown(a1, lpSupply, vault1))
    all {
      liq > 0,
      vault0' = vault0 + a0,
      vault1' = vault1 + a1,
      lpSupply' = lpSupply + liq,
      lpBal' = lpBal.put(u, lpBal.get(u) + liq),
      protocolFees0' = protocolFees0,
      protocolFees1' = protocolFees1,
      fundFees0' = fundFees0,
      fundFees1' = fundFees1,
    }
  }

  action withdraw(u: str, shares: int): bool = all {
    USERS.contains(u),
    shares > 0,
    lpBal.get(u) >= shares,
    lpSupply > shares,
    val a0 = mulDivDown(shares, vault0, lpSupply)
    val a1 = mulDivDown(shares, vault1, lpSupply)
    all {
      a0 > 0 and a1 > 0,
      vault0' = vault0 - a0,
      vault1' = vault1 - a1,
      lpSupply' = lpSupply - shares,
      lpBal' = lpBal.put(u, lpBal.get(u) - shares),
      protocolFees0' = protocolFees0,
      protocolFees1' = protocolFees1,
      fundFees0' = fundFees0,
      fundFees1' = fundFees1,
    }
  }

  /// swap base input token0 → token1; peel protocol/fund fees from input
  action swap0for1(amountIn: int): bool = all {
    amountIn > 0,
    vault0 > 0, vault1 > 0,
    // total fee portion of input (FEE_DEN - FEE_NUM)/FEE_DEN
    val feeTotal = mulDivDown(amountIn, FEE_DEN - FEE_NUM, FEE_DEN)
    val toProtocol = mulDivDown(feeTotal, PROTOCOL_SHARE, 100)
    val toFund = mulDivDown(feeTotal, FUND_SHARE, 100)
    val amountInAfterFee = amountIn - feeTotal
    // LP-facing swap uses remaining (fee already removed); use full-fee curve for out
    val out = cpAmountOut(vault0, vault1, amountIn, FEE_NUM, FEE_DEN)
    all {
      out > 0, out < vault1,
      vault0' = vault0 + amountIn - toProtocol - toFund,
      vault1' = vault1 - out,
      protocolFees0' = protocolFees0 + toProtocol,
      fundFees0' = fundFees0 + toFund,
      protocolFees1' = protocolFees1,
      fundFees1' = fundFees1,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet a0 = 1.to(15).oneOf()
    nondet a1 = 1.to(15).oneOf()
    nondet sh = 1.to(15).oneOf()
    nondet din = 1.to(12).oneOf()
    any {
      deposit(u, a0, a1),
      withdraw(u, sh),
      swap0for1(din),
    }
  }

  val lpConservation: bool =
    USERS.fold(0, (acc, u) => acc + lpBal.get(u)) == lpSupply

  val vaultsNonNeg: bool =
    vault0 >= 0 and vault1 >= 0 and protocolFees0 >= 0 and fundFees0 >= 0
}
