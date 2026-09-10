// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {Morpho} from "src/Morpho.sol";
import {IMorpho, MarketParams, Id} from "src/interfaces/IMorpho.sol";
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {OracleMock} from "src/mocks/OracleMock.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {MorphoBalancesLib} from "src/libraries/periphery/MorphoBalancesLib.sol";

/// Root diagnostic of two distinct suppliers' rounded integrator balances.
contract TwoSupplierProbe {
    using MarketParamsLib for MarketParams;
    using MorphoBalancesLib for IMorpho;

    function probe() external returns (uint256[14] memory out) {
        IMorpho m = IMorpho(address(new Morpho(address(this))));
        ERC20Mock loan = new ERC20Mock();
        ERC20Mock collateral = new ERC20Mock();
        OracleMock oracle = new OracleMock();
        MarketParams memory mp = MarketParams(address(loan), address(collateral), address(oracle), address(0), 0.75e18);
        m.enableIrm(address(0));
        m.enableLltv(mp.lltv);
        m.createMarket(mp);
        Id id = mp.id();
        address first = address(0x1001);
        address second = address(0x1002);
        loan.approve(address(m), type(uint256).max);
        collateral.approve(address(m), type(uint256).max);
        loan.setBalance(address(this), 2);
        m.supply(mp, 1, 0, first, hex"");
        m.supply(mp, 1, 0, second, hex"");
        collateral.setBalance(address(this), 10);
        oracle.setPrice(1e36);
        m.supplyCollateral(mp, 10, address(this), hex"");
        m.borrow(mp, 2, 0, address(this), address(this));
        out[0] = m.market(id).totalSupplyAssets;
        out[2] = m.expectedSupplyAssets(mp, first);
        out[3] = m.expectedSupplyAssets(mp, second);
        out[6] = m.position(id, first).supplyShares;
        out[7] = m.position(id, second).supplyShares;
        oracle.setPrice(1e10);
        (out[10], out[11]) = m.liquidate(mp, address(this), 10, 0, hex"");
        out[1] = m.market(id).totalSupplyAssets;
        out[4] = m.expectedSupplyAssets(mp, first);
        out[5] = m.expectedSupplyAssets(mp, second);
        out[8] = m.position(id, first).supplyShares;
        out[9] = m.position(id, second).supplyShares;
        out[12] = m.market(id).totalBorrowAssets;
        out[13] = m.position(id, address(this)).collateral;
    }
}
