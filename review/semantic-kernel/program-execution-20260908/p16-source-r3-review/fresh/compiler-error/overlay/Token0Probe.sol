pragma solidity =0.7.6;

import "./FullMath.sol";
import "./UnsafeMath.sol";
import "./LowGasSafeMath.sol";
import "./SafeCast.sol";
import "./FixedPoint96.sol";
import "./SqrtPriceMath.sol";

contract Token0Probe {
    function probe(uint160 sqrtPX96, uint128 liquidity, uint256 amount, bool add)
        external
        pure
        returns (uint160)
    {
        return SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add);
    }
}

this is an invalid Solidity source statement;
