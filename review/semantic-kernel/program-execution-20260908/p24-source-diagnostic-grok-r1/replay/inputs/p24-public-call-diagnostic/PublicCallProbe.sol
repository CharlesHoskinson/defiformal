// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {Morpho} from "src/Morpho.sol";
import {IMorpho, Id, MarketParams, Market, Position} from "src/interfaces/IMorpho.sol";
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {OracleMock} from "src/mocks/OracleMock.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {MathLib, WAD} from "src/libraries/MathLib.sol";
import {SharesMathLib} from "src/libraries/SharesMathLib.sol";
import {ErrorsLib} from "src/libraries/ErrorsLib.sol";
import {ORACLE_PRICE_SCALE, MAX_LIQUIDATION_INCENTIVE_FACTOR, LIQUIDATION_CURSOR} from "src/libraries/ConstantsLib.sol";

/// Root source-entry diagnostic. One actor, zero IRM, one timestamp, upstream mocks.
/// The production Morpho source is unchanged. This is not a P24 model or proof.
contract PublicCallProbe {
    using MarketParamsLib for MarketParams;
    using MathLib for uint256;
    using SharesMathLib for uint256;

    function probe(uint256 scenario) external returns (uint256[16] memory out) {
        require(scenario < 4, "unknown scenario");
        IMorpho morpho = IMorpho(address(new Morpho(address(this))));
        ERC20Mock loan = new ERC20Mock();
        ERC20Mock collateral = new ERC20Mock();
        OracleMock oracle = new OracleMock();
        uint256 lltv = 0.75e18;
        MarketParams memory mp = MarketParams(address(loan), address(collateral), address(oracle), address(0), lltv);
        morpho.enableIrm(address(0));
        morpho.enableLltv(lltv);
        morpho.createMarket(mp);
        Id id = mp.id();
        oracle.setPrice(ORACLE_PRICE_SCALE);
        loan.approve(address(morpho), type(uint256).max);
        collateral.approve(address(morpho), type(uint256).max);
        uint256 supplied = scenario < 2 ? 100e18 : (scenario == 2 ? 2e18 : 1e18);
        uint256 posted = scenario < 2 ? 400 : 10e18;
        uint256 borrowed = scenario < 2 ? 300 : 1e18;
        loan.setBalance(address(this), supplied);
        morpho.supply(mp, supplied, 0, address(this), hex"");
        collateral.setBalance(address(this), posted);
        morpho.supplyCollateral(mp, posted, address(this), hex"");
        morpho.borrow(mp, borrowed, 0, address(this), address(this));
        if (scenario == 3) morpho.borrow(mp, 0, 1, address(this), address(this));
        uint256 price = scenario == 0 ? ORACLE_PRICE_SCALE :
            (scenario == 1 ? ORACLE_PRICE_SCALE - 0.01e18 :
            (scenario == 2 ? ORACLE_PRICE_SCALE / 10 : ORACLE_PRICE_SCALE / 100));
        oracle.setPrice(price);
        Market memory beforeMarket = morpho.market(id);
        Position memory beforePosition = morpho.position(id, address(this));
        out[0] = scenario;
        out[3] = beforeMarket.totalSupplyAssets;
        out[5] = beforeMarket.totalBorrowAssets;
        out[7] = beforeMarket.totalBorrowShares;
        out[9] = beforePosition.collateral;
        out[14] = beforePosition.supplyShares;
        if (scenario == 0) {
            try morpho.liquidate(mp, address(this), 0, 1, hex"") returns (uint256, uint256) {
                revert("healthy liquidation unexpectedly succeeded");
            } catch (bytes memory reason) {
                require(keccak256(reason) == keccak256(abi.encodeWithSignature("Error(string)", ErrorsLib.HEALTHY_POSITION)), "wrong refusal");
                out[13] = 1;
            }
        } else {
            uint256 seizeInput = scenario == 1 ? 0 : (scenario == 2 ? 1e18 : posted);
            (out[1], out[2]) = morpho.liquidate(mp, address(this), seizeInput, scenario == 1 ? 1 : 0, hex"");
            if (scenario == 3) {
                uint256 factor = WAD.wDivDown(WAD - LIQUIDATION_CURSOR.wMulDown(WAD - lltv));
                if (factor > MAX_LIQUIDATION_INCENTIVE_FACTOR) factor = MAX_LIQUIDATION_INCENTIVE_FACTOR;
                uint256 repaidShares = seizeInput.mulDivUp(price, ORACLE_PRICE_SCALE).wDivUp(factor)
                    .toSharesUp(beforeMarket.totalBorrowAssets, beforeMarket.totalBorrowShares);
                out[12] = beforeMarket.totalBorrowAssets > out[2] ? beforeMarket.totalBorrowAssets - out[2] : 0;
                // Derived branch diagnostic using pinned arithmetic, not an independent oracle.
                out[11] = (beforePosition.borrowShares - repaidShares)
                    .toAssetsUp(out[12], beforeMarket.totalBorrowShares - repaidShares);
            }
        }
        Market memory afterMarket = morpho.market(id);
        Position memory afterPosition = morpho.position(id, address(this));
        out[4] = afterMarket.totalSupplyAssets;
        out[6] = afterMarket.totalBorrowAssets;
        out[8] = afterMarket.totalBorrowShares;
        out[10] = afterPosition.collateral;
        out[15] = afterPosition.supplyShares;
        if (scenario == 0) {
            require(keccak256(abi.encode(beforeMarket, beforePosition)) == keccak256(abi.encode(afterMarket, afterPosition)), "refusal changed observed structs");
        }
    }
}
