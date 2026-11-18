// SPDX-License-Identifier: BUSL-1.1
// Exact derived GMX excerpts retain upstream terms; wrapper stubs are explicit observations.
pragma solidity 0.8.29;
import "contracts/market/MarketUtils.sol";
import "contracts/position/DecreasePositionCollateralUtils.sol";
library P27ObservedStore {
    struct Store { uint256 minCollateralUsd; }
    function getUint(Store memory data, bytes32) internal pure returns (uint256) { return data.minCollateralUsd; }
}
interface P27ErrorSignatures {
    function PositionShouldNotBeLiquidated(string calldata,int256,int256,int256) external;
    function InsufficientFundsToPayForCosts(uint256,string calldata) external;
    function EmptyHoldingAddress() external;
}
contract P27BranchProbe {
    using SafeCast for uint256;
    using Position for Position.Props;
    using Order for Order.Props;
    using P27ObservedStore for P27ObservedStore.Store;
    // Inputs are upstream observations, not executions of source oracle/fee/impact computation.
    function selectedHealth(uint256[5] calldata numbers, int256[2] calldata signedValues)
        external pure returns (int256,int256,int256)
    {
        if (true) { // selected liquidation order; no prior handler validation is claimed
            (bool isLiquidatable, string memory reason, PositionUtils.IsPositionLiquidatableInfo memory info) =
                _health(numbers,signedValues);
            if (!isLiquidatable) {
                revert Errors.PositionShouldNotBeLiquidated(
                    reason,
                    info.remainingCollateralUsd,
                    info.minCollateralUsd,
                    info.minCollateralUsdForLeverage
                );
            }
        }

        return _equityProjection(numbers,signedValues);
    }
    function _equityProjection(uint256[5] memory numbers,int256[2] memory signedValues)
        private pure returns (int256,int256,int256)
    {
        (,,PositionUtils.IsPositionLiquidatableInfo memory info)=_health(numbers,signedValues);
        return (info.remainingCollateralUsd,info.minCollateralUsd,info.minCollateralUsdForLeverage);
    }
    function _health(uint256[5] memory numbers,int256[2] memory signedValues)
        private pure returns (bool,string memory,PositionUtils.IsPositionLiquidatableInfo memory info)
    {
        PositionUtils.IsPositionLiquidatableCache memory cache;
        cache.collateralUsd=numbers[0]*numbers[1];
        cache.positionPnlUsd=signedValues[0];
        cache.priceImpactUsd=signedValues[1];
        uint256 collateralCostUsd=numbers[2]*numbers[1];
        P27ObservedStore.Store memory dataStore=P27ObservedStore.Store(numbers[3]);
        info.minCollateralUsdForLeverage=numbers[4].toInt256();
        bool shouldValidateMinCollateralUsd=true;
        info.remainingCollateralUsd =
            cache.collateralUsd.toInt256()
            + cache.positionPnlUsd
            + cache.priceImpactUsd
            - collateralCostUsd.toInt256();

        if (shouldValidateMinCollateralUsd) {
            info.minCollateralUsd = dataStore.getUint(Keys.MIN_COLLATERAL_USD).toInt256();
            if (info.remainingCollateralUsd < info.minCollateralUsd) {
                return (true, "min collateral", info);
            }
        }

        if (info.remainingCollateralUsd <= 0) {
            return (true, "< 0", info);
        }

        if (info.remainingCollateralUsd < info.minCollateralUsdForLeverage) {
            return (true, "min collateral for leverage", info);
        }

        return (false, "", info);
    }


    function emptyFees(uint256[8] calldata input) external pure returns (uint256[10] memory) {
        return _project(DecreasePositionCollateralUtils.getEmptyFees(_fees(input)));
    }
    function early(uint256[8] calldata input,uint256[3] calldata sizesAndResidual,
        bool liquidation,bool adl,uint8 stage) external pure returns (uint256[11] memory output)
    {
        PositionUtils.UpdatePositionParams memory params;
        params.position.setSizeInUsd(sizesAndResidual[0]);
        params.order.setSizeDeltaUsd(sizesAndResidual[1]);
        params.order.setOrderType(liquidation?Order.OrderType.Liquidation:Order.OrderType.MarketDecrease);
        params.secondaryOrderType=adl?Order.SecondaryOrderType.Adl:Order.SecondaryOrderType.None;
        DecreasePositionCollateralUtils.ProcessCollateralCache memory collateralCache;
        collateralCache.result.remainingCostUsd=sizesAndResidual[2];
        string memory step=_step(stage);
        collateralCache.isInsolventCloseAllowed =
            params.order.sizeDeltaUsd() == params.position.sizeInUsd() &&
            (
                Order.isLiquidationOrder(params.order.orderType()) ||
                params.secondaryOrderType == Order.SecondaryOrderType.Adl
            );


        if (!collateralCache.isInsolventCloseAllowed) {
            revert Errors.InsufficientFundsToPayForCosts(collateralCache.result.remainingCostUsd, step);
        }

        uint256[10] memory projected=_project(DecreasePositionCollateralUtils.getEmptyFees(_fees(input)));
        output[0]=1;
        for(uint256 i=0;i<10;i++) output[i+1]=projected[i];
        // No source events/storage/handler suffix executed: this is the conditional branch projection.
    }
    function _fees(uint256[8] memory input) private pure returns (PositionPricingUtils.PositionFees memory fees) {
        fees.funding=PositionPricingUtils.PositionFundingFees(input[0],input[1],input[2],input[3],input[4],input[5]);
        fees.totalCostAmount=input[6];
        fees.totalCostAmountExcludingFunding=input[7];
        fees.collateralTokenPrice=Price.Props(2,3);
    }
    function _project(PositionPricingUtils.PositionFees memory fees) private pure returns(uint256[10] memory) {
        return [fees.funding.fundingFeeAmount,fees.funding.claimableLongTokenAmount,
            fees.funding.claimableShortTokenAmount,fees.funding.latestFundingFeeAmountPerSize,
            fees.funding.latestLongTokenClaimableFundingAmountPerSize,
            fees.funding.latestShortTokenClaimableFundingAmountPerSize,
            fees.totalCostAmount,fees.totalCostAmountExcludingFunding,
            fees.collateralTokenPrice.min,fees.collateralTokenPrice.max];
    }
    function _step(uint8 stage) private pure returns(string memory) {
        require(stage<5,"adapter stage outside comparison domain");
        if(stage==0)return "funding";
        if(stage==1)return "pnl";
        if(stage==2)return "fees";
        if(stage==3)return "impact";
        return "diff";
    }
    function fundingStage(uint256[9] calldata input) external pure returns(uint256[6] memory output) {
        uint256 fee=MarketUtils.getFundingAmount(input[0],input[1],input[2],true);
        PositionUtils.UpdatePositionParams memory params;
        params.market.longToken=address(1); params.market.shortToken=address(2);
        PositionUtils.DecreasePositionCollateralValues memory values;
        values.output.outputToken=address(1);values.output.secondaryOutputToken=address(2);
        values.output.outputAmount=input[5];values.remainingCollateralAmount=input[6];
        values.output.secondaryOutputAmount=input[7];
        MarketUtils.MarketPrices memory prices;
        prices.longTokenPrice=Price.Props(input[3],input[3]);
        prices.shortTokenPrice=Price.Props(input[4],input[4]);
        DecreasePositionCollateralUtils.PayForCostResult memory result;
        (values,result)=DecreasePositionCollateralUtils.payForCost(params,values,prices,
            Price.Props(input[3],input[3]),fee*input[3]);
        uint256 claimableCollateralIncrement;
        if(result.amountPaidInSecondaryOutputToken>0) {
            address holdingAddress=input[8]==0?address(0):address(4); // explicit configured-address stub
            if (holdingAddress == address(0)) {
                revert Errors.EmptyHoldingAddress();
            }

            claimableCollateralIncrement=result.amountPaidInSecondaryOutputToken;
        }
        return [fee,result.amountPaidInCollateralToken,result.amountPaidInSecondaryOutputToken,
            result.remainingCostUsd,result.amountPaidInCollateralToken<fee?uint256(1):uint256(0),
            claimableCollateralIncrement];
    }
}
