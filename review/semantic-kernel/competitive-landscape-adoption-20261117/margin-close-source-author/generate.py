from pathlib import Path
import json,hashlib
p=Path(__file__).resolve().parent;o=Path('/private/tmp/defiformal-margin-payment-author/source-helper');data=json.loads((o/'standard-input-r3.json').read_text());bindings=[]
def extract(name,start,end):
 s=data['sources'][name]['content'];a=s.index(start);b=s.index(end,a);text=s[a:b];bindings.append(dict(source=name,source_sha256=hashlib.sha256(s.encode()).hexdigest(),start_line=s[:a].count('\n')+1,end_line=s[:b].count('\n')+1,sha256=hashlib.sha256(text.encode()).hexdigest(),text=text));return text
health=extract('contracts/position/PositionUtils.sol','        info.remainingCollateralUsd =','        if (forLiquidation)')
priority=extract('contracts/position/PositionUtils.sol','        if (shouldValidateMinCollateralUsd) {','    // fees and price impact are not included')
# Includes the source function's final closing brace; reuse it as the adapter helper close.
healthy=extract('contracts/position/DecreasePositionUtils.sol','            if (!isLiquidatable) {','        cache.initialCollateralAmount')
# Contains the outer liquidation if's closing brace; wrap in matching selected-liquidation if.
allowed=extract('contracts/position/DecreasePositionCollateralUtils.sol','        collateralCache.isInsolventCloseAllowed =','        // the totalPositionPnl')
early=extract('contracts/position/DecreasePositionCollateralUtils.sol','        if (!collateralCache.isInsolventCloseAllowed) {','        PositionEventUtils.emitPositionFeesInfo')
holding=extract('contracts/position/DecreasePositionCollateralUtils.sol','            if (holdingAddress == address(0)) {','            // send the funding fee amount')
wrapper='''// SPDX-License-Identifier: BUSL-1.1
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
'''+healthy+'''        return _equityProjection(numbers,signedValues);
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
'''+health+priority+'''
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
'''+allowed+early+'''        uint256[10] memory projected=_project(DecreasePositionCollateralUtils.getEmptyFees(_fees(input)));
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
'''+holding+'''            claimableCollateralIncrement=result.amountPaidInSecondaryOutputToken;
        }
        return [fee,result.amountPaidInCollateralToken,result.amountPaidInSecondaryOutputToken,
            result.remainingCostUsd,result.amountPaidInCollateralToken<fee?uint256(1):uint256(0),
            claimableCollateralIncrement];
    }
}
'''
for item in bindings:assert item['text'] in wrapper
(p/'P27BranchProbe.sol').write_text(wrapper);(p/'excerpt-bindings.json').write_text(json.dumps(dict(source_commit='a85ea3491c19c93bb4b5a002d9b358fb769b7849',reused_original_input_sha256=hashlib.sha256((o/'standard-input-r3.json').read_bytes()).hexdigest(),bindings=bindings,scope='Exact source excerpts with declared pure observation stubs and actual unchanged getEmptyFees/fundingAmount/payForCost calls; no original full handler/events/storage or source-computation execution.'),indent=2)+'\n')
s=(o/'compile-r3.py').read_text().replace('P27HelperProbe','P27BranchProbe').replace('standard-input-r3','standard-input-r1').replace('standard-output-r3','standard-output-r1').replace('compile-r3','compile-r1')
(p/'compile-r1.py').write_text(s)
