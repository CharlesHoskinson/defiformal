// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.29;
import "contracts/market/MarketUtils.sol";
import "contracts/position/DecreasePositionCollateralUtils.sol";

// Calls unchanged internal GMX helpers. No handlers, swaps or deployed-system claim.
contract P27HelperProbe {
    function fundingAmount(uint256 latest, uint256 snapshot, uint256 sizeUsd, bool roundUp)
        external pure returns (uint256)
    {
        return MarketUtils.getFundingAmount(latest, snapshot, sizeUsd, roundUp);
    }
    function payCost(uint256 costUsd, uint256 primaryPrice, uint256 secondaryPrice,
        uint256 primaryOutput, uint256 collateral, uint256 secondaryOutput)
        external pure returns (uint256,uint256,uint256,uint256,uint256,uint256)
    {
        return _payCost([costUsd,primaryPrice,secondaryPrice,primaryOutput,collateral,secondaryOutput]);
    }
    function _payCost(uint256[6] memory input)
        private pure returns (uint256,uint256,uint256,uint256,uint256,uint256)
    {
        PositionUtils.UpdatePositionParams memory params;
        params.market.longToken = address(1);
        params.market.shortToken = address(2);
        params.market.indexToken = address(3);
        PositionUtils.DecreasePositionCollateralValues memory values;
        values.output.outputToken = address(1);
        values.output.secondaryOutputToken = address(2);
        values.output.outputAmount = input[3];
        values.remainingCollateralAmount = input[4];
        values.output.secondaryOutputAmount = input[5];
        MarketUtils.MarketPrices memory prices;
        prices.longTokenPrice = Price.Props(input[1],input[1]);
        prices.shortTokenPrice = Price.Props(input[2],input[2]);
        prices.indexTokenPrice = Price.Props(1,1);
        DecreasePositionCollateralUtils.PayForCostResult memory result;
        (values,result) = DecreasePositionCollateralUtils.payForCost(
            params,values,prices,Price.Props(input[1],input[1]),input[0]);
        return (values.output.outputAmount,values.remainingCollateralAmount,
            values.output.secondaryOutputAmount,result.amountPaidInCollateralToken,
            result.amountPaidInSecondaryOutputToken,result.remainingCostUsd);
    }
}
