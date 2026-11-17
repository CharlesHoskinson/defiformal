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
        PositionUtils.UpdatePositionParams memory params;
        params.market.longToken = address(1);
        params.market.shortToken = address(2);
        params.market.indexToken = address(3);
        PositionUtils.DecreasePositionCollateralValues memory values;
        values.output.outputToken = address(1);
        values.output.secondaryOutputToken = address(2);
        values.output.outputAmount = primaryOutput;
        values.remainingCollateralAmount = collateral;
        values.output.secondaryOutputAmount = secondaryOutput;
        MarketUtils.MarketPrices memory prices;
        prices.longTokenPrice = Price.Props(primaryPrice,primaryPrice);
        prices.shortTokenPrice = Price.Props(secondaryPrice,secondaryPrice);
        prices.indexTokenPrice = Price.Props(1,1);
        DecreasePositionCollateralUtils.PayForCostResult memory result;
        (values,result) = DecreasePositionCollateralUtils.payForCost(
            params,values,prices,Price.Props(primaryPrice,primaryPrice),costUsd);
        return (values.output.outputAmount,values.remainingCollateralAmount,
            values.output.secondaryOutputAmount,result.amountPaidInCollateralToken,
            result.amountPaidInSecondaryOutputToken,result.remainingCostUsd);
    }
}
