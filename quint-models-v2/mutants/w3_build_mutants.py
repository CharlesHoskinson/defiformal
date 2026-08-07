#!/usr/bin/env python3
"""Build the M1 contrast-set members for liquity and polymarket.

M1 is the v1 shortcut body substituted at the single definition site, exactly as
the pilot did for uniswap_v2 (PILOT-NOTES trap K10).  Everything else -- the T0
vectors, the invariants, the witnesses -- is carried over unchanged, which is the
point: what survives and what dies is the measurement.
"""
import os
import re

BASE = "/root/DefiElements/quint-models-v2"
OUT = os.path.join(BASE, "mutants")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- liquity M1
src = open(os.path.join(BASE, "liquity.qnt")).read()
src = src.replace('from "./kernel"', 'from "../kernel"')
src = src.replace('from "./sorted"', 'from "../sorted"')

start = src.index("  /// TroveManager.redeemCollateral.  THE SIGNATURE IS THE REPAIR")
end = src.index("  /// PriceFeed.fetchPrice")
M1_REDEEM = '''  /// M1 -- the v1 body verbatim (quint-models/L2/liquity.qnt:130-171).  The
  /// trove is a PARAMETER.  Everything else in this file is unchanged.
  action redeem(u: int, boldAmt: int): bool = all {
    USERS.contains(u),
    hasTrove(troves, u),
    boldAmt > 0,
    freeBold >= boldAmt,
    price > 0,
    val t = findTrove(troves, u)
    val collOut = boldAmt * WAD / price
    all {
      boldAmt <= t.debt,
      collOut <= t.coll,
      troves\' = reInsert(troves, { ...t, debt: t.debt - boldAmt,
                                   coll: t.coll - collOut,
                                   active: t.debt - boldAmt > 0 }),
      boldSupply\' = boldSupply - boldAmt,
      freeBold\' = freeBold - boldAmt,
      systemColl\' = systemColl - collOut,
      userColl\' = userColl + collOut,
      spDeposits\' = spDeposits,
      spColl\' = spColl,
      price\' = price,
      lastOp\' = OP_REDEEM,
      lastTouched\' = 1,
    }
  }

'''
src = src[:start] + M1_REDEEM + src[end:]
src = src.replace("      redeemCollateral(boldAmt),", "      redeem(u, boldAmt),")
src = src.replace("module liquity {", "module liquity {\n  // CONTRAST SET MEMBER M1 -- see mutants/README\n")
open(os.path.join(OUT, "liquity_M1.qnt"), "w").write(src)

# ------------------------------------------------------------ polymarket M1
src = open(os.path.join(BASE, "polymarket.qnt")).read()
src = src.replace('from "./kernel"', 'from "../kernel"')

start = src.index("  /// CTFExchange.matchOrders -> Trading._matchOrders.  THE SIGNATURE IS THE")
end = src.index("  /// UmaCtfAdapter.resolve")
M1_TRADE = '''  /// M1 -- the v1 body verbatim (quint-models/L6/polymarket.qnt:75-97).  ONE
  /// counterparty, a bilateral transfer, and the price is a driver `nondet`.
  /// Everything else in this file is unchanged.
  action tradeYes(seller: str, buyer: str, yesAmt: int, prc: int): bool = all {
    phase == PHASE_OPEN,
    USERS.contains(seller),
    USERS.contains(buyer),
    seller != buyer,
    yesAmt > 0,
    prc > 0,
    posYes.get(seller) >= yesAmt,
    cash.get(buyer) >= yesAmt * prc,
    posYes\' = posYes.setBy(seller, y => y - yesAmt).setBy(buyer, y => y + yesAmt),
    posNo\' = posNo,
    cash\' = cash.setBy(buyer, c => c - yesAmt * prc)
                .setBy(seller, c => c + yesAmt * prc),
    lockedCollateral\' = lockedCollateral,
    book\' = book,
    phase\' = phase,
    payout\' = payout,
    lastOp\' = OP_MATCH_COMP,
  }

'''
src = src[:start] + M1_TRADE + src[end:]
src = src.replace("      matchOrders(TAKERS[ti]),", "      tradeYes(u, TAKERS[ti].maker, amount, ti + 1),")
src = src.replace("module polymarket {", "module polymarket {\n  // CONTRAST SET MEMBER M1 -- see mutants/README\n")
open(os.path.join(OUT, "polymarket_M1.qnt"), "w").write(src)
print("written")
