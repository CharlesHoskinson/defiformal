"""Independent integer oracle for concentrated-liquidity planning fixtures.

Implements the documented mathematical specifications and the TickMath /
TickBitmap / SqrtPriceMath / SwapMath integer algorithms from Uniswap v3-core
v1.0.0 commit e3589b192d0be27e100cd0daaf6c97204fdb1899. This is a planning
checker, not Lean, not solc, and not a claim that assembly FullMath equals
unbounded natural division.

All integers are Python int (unbounded). uint256 wrap is modelled for wrapping
multiplication overflow tests AND for the token0 add-path denominator sum
(Solidity 0.7.6 native uint256 +). This remains a diagnostic third
implementation: not Lean, not solc, not EVM, and not accepted source behavior.
"""
from __future__ import annotations

U256 = 2**256
U160 = 2**160
U128 = 2**128
U24 = 2**24
I256_MIN = -(2**255)
I256_MAX = 2**255 - 1
I128_MIN = -(2**127)
I128_MAX = 2**127 - 1
I24_MIN = -(2**23)
I24_MAX = 2**23 - 1

Q96 = 2**96
Q128 = 2**128
FEE_DEN = 1_000_000
MIN_TICK = -887272
MAX_TICK = 887272
MIN_SQRT_RATIO = 4295128739
MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342

TICK_CONSTANTS = [
    (0x1, 0xFFFC_B933_BD6F_AD37_AA2D_162D_1A59_4001),
    (0x2, 0xFFF9_7272_373D_4132_59A4_6990_580E_213A),
    (0x4, 0xFFF2_E50F_5F65_6932_EF12_357C_F3C7_FDCC),
    (0x8, 0xFFE5_CACA_7E10_E4E6_1C36_24EA_A094_1CD0),
    (0x10, 0xFFCB_9843_D60F_6159_C9DB_5883_5C92_6644),
    (0x20, 0xFF97_3B41_FA98_C081_472E_6896_DFB2_54C0),
    (0x40, 0xFF2E_A164_66C9_6A38_43EC_78B3_26B5_2861),
    (0x80, 0xFE5D_EE04_6A99_A2A8_11C4_61F1_969C_3053),
    (0x100, 0xFCBE_86C7_900A_88AE_DCFF_C83B_479A_A3A4),
    (0x200, 0xF987_A725_3AC4_1317_6F2B_074C_F781_5E54),
    (0x400, 0xF339_2B08_22B7_0005_940C_7A39_8E4B_70F3),
    (0x800, 0xE715_9475_A2C2_9B74_43B2_9C7F_A6E8_89D9),
    (0x1000, 0xD097_F3BD_FD20_22B8_845A_D8F7_92AA_5825),
    (0x2000, 0xA9F7_4646_2D87_0FDF_8A65_DC1F_90E0_61E5),
    (0x4000, 0x70D8_69A1_56D2_A1B8_90BB_3DF6_2BAF_32F7),
    (0x8000, 0x31BE_135F_97D0_8FD9_8123_1505_542F_CFA6),
    (0x10000, 0x09AA_508B_5B7A_84E1_C677_DE54_F3E9_9BC9),
    (0x20000, 0x005D_6AF8_DEDB_8119_6699_C329_225E_E604),
    (0x40000, 0x0002_216E_584F_5FA1_EA92_6041_BEDF_E98),
    (0x80000, 0x0000_0048_A170_391F_7DC4_2444_E8FA_2),
]


class OracleError(Exception):
    def __init__(self, name: str):
        super().__init__(name)
        self.name = name


def u256(n: int, err: str = "uint256Overflow") -> int:
    if n < 0 or n >= U256:
        raise OracleError(err)
    return n


def u160(n: int, err: str = "uint160Overflow") -> int:
    if n < 0 or n >= U160:
        raise OracleError(err)
    return n


def u128(n: int, err: str = "liquidityOverflow") -> int:
    if n < 0 or n >= U128:
        raise OracleError(err)
    return n


def mul_div(a: int, b: int, d: int) -> int:
    if d == 0:
        raise OracleError("divisionByZero")
    q = (a * b) // d
    return u256(q, "quotientOverflow")


def mul_div_rounding_up(a: int, b: int, d: int) -> int:
    q = mul_div(a, b, d)
    if (a * b) % d > 0:
        if q == U256 - 1:
            raise OracleError("quotientOverflow")
        q += 1
    return q


def div_rounding_up(x: int, y: int) -> int:
    """UnsafeMath.divRoundingUp for y>0. y==0 is unspecified in source."""
    if y == 0:
        raise OracleError("zeroDenominatorUnsafe")
    return x // y + (1 if x % y else 0)


def low_gas_add(x: int, y: int) -> int:
    z = x + y
    if z >= U256 or z < x:
        raise OracleError("addOverflow")
    return z


def product_fits_u256(amount: int, sqrt_p: int) -> bool:
    """Solidity 0.7.6 wrap check: (amount * sqrtPX96) / amount == sqrtPX96."""
    if amount == 0:
        return True
    return amount * sqrt_p < U256


def get_sqrt_ratio_at_tick(tick: int) -> int:
    if tick < I24_MIN or tick > I24_MAX:
        raise OracleError("intOverflow")
    abs_tick = -tick if tick < 0 else tick
    if abs_tick > MAX_TICK:
        raise OracleError("tickOutOfBounds")
    ratio = TICK_CONSTANTS[0][1] if abs_tick & 0x1 else 1 << 128
    for bit, const in TICK_CONSTANTS[1:]:
        if abs_tick & bit:
            product = ratio * const
            if product >= U256:
                raise OracleError("uint256Overflow")
            ratio = product >> 128
    if tick > 0:
        ratio = (U256 - 1) // ratio
    extra = 0 if ratio % (1 << 32) == 0 else 1
    return u160((ratio >> 32) + extra)


def greatest_tick_at_or_below(sqrt_p: int) -> int:
    """Independent inverse spec: greatest tick with getSqrtRatioAtTick(tick) <= sqrt_p."""
    if sqrt_p < MIN_SQRT_RATIO or sqrt_p >= MAX_SQRT_RATIO:
        raise OracleError("ratioOutOfBounds")
    lo, hi = MIN_TICK, MAX_TICK
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if get_sqrt_ratio_at_tick(mid) <= sqrt_p:
            lo = mid
        else:
            hi = mid - 1
    return lo


def get_amount1_delta(sqrt_a: int, sqrt_b: int, liquidity: int, round_up: bool) -> int:
    if sqrt_a > sqrt_b:
        sqrt_a, sqrt_b = sqrt_b, sqrt_a
    delta = sqrt_b - sqrt_a
    if round_up:
        return mul_div_rounding_up(liquidity, delta, Q96)
    return mul_div(liquidity, delta, Q96)


def get_amount0_delta(sqrt_a: int, sqrt_b: int, liquidity: int, round_up: bool) -> int:
    if sqrt_a > sqrt_b:
        sqrt_a, sqrt_b = sqrt_b, sqrt_a
    if sqrt_a <= 0:
        raise OracleError("priceZero")
    numerator1 = liquidity << 96
    numerator2 = sqrt_b - sqrt_a
    if round_up:
        return div_rounding_up(mul_div_rounding_up(numerator1, numerator2, sqrt_b), sqrt_a)
    return mul_div(numerator1, numerator2, sqrt_b) // sqrt_a


def get_next_sqrt_price_from_amount0_rounding_up(
    sqrt_p: int, liquidity: int, amount: int, add: bool
) -> int:
    if amount == 0:
        return sqrt_p
    numerator1 = liquidity << 96
    if add:
        if product_fits_u256(amount, sqrt_p):
            product = amount * sqrt_p
            # Solidity 0.7.6 uint256 addition wraps modulo 2**256. The
            # historical defective oracle used unbounded Python addition, so
            # denom >= numerator1 was true whenever product >= 0 and the
            # wrapped-sum fallback was never taken.
            wrapped_denom = (numerator1 + product) % U256
            if wrapped_denom >= numerator1:
                return u160(mul_div_rounding_up(numerator1, sqrt_p, wrapped_denom))
        inner = low_gas_add(numerator1 // sqrt_p, amount)
        return u160(div_rounding_up(numerator1, inner))
    if not product_fits_u256(amount, sqrt_p):
        raise OracleError("uint256Overflow")
    product = amount * sqrt_p
    if numerator1 <= product:
        raise OracleError("subUnderflow")
    denom = numerator1 - product
    return u160(mul_div_rounding_up(numerator1, sqrt_p, denom), "uint160Overflow")


def get_next_sqrt_price_from_amount1_rounding_down(
    sqrt_p: int, liquidity: int, amount: int, add: bool
) -> int:
    if liquidity == 0:
        raise OracleError("liquidityZero")
    if add:
        if amount <= U160 - 1:
            quotient = (amount << 96) // liquidity
        else:
            quotient = mul_div(amount, Q96, liquidity)
        return u160(low_gas_add(sqrt_p, quotient), "uint160Overflow")
    if amount <= U160 - 1:
        quotient = div_rounding_up(amount << 96, liquidity)
    else:
        quotient = mul_div_rounding_up(amount, Q96, liquidity)
    if sqrt_p <= quotient:
        raise OracleError("subUnderflow")
    return sqrt_p - quotient


def get_next_sqrt_price_from_input(sqrt_p: int, liquidity: int, amount_in: int, zero_for_one: bool) -> int:
    if sqrt_p <= 0:
        raise OracleError("priceZero")
    if liquidity <= 0:
        raise OracleError("liquidityZero")
    if zero_for_one:
        return get_next_sqrt_price_from_amount0_rounding_up(sqrt_p, liquidity, amount_in, True)
    return get_next_sqrt_price_from_amount1_rounding_down(sqrt_p, liquidity, amount_in, True)


def get_next_sqrt_price_from_output(sqrt_p: int, liquidity: int, amount_out: int, zero_for_one: bool) -> int:
    if sqrt_p <= 0:
        raise OracleError("priceZero")
    if liquidity <= 0:
        raise OracleError("liquidityZero")
    if zero_for_one:
        return get_next_sqrt_price_from_amount1_rounding_down(sqrt_p, liquidity, amount_out, False)
    return get_next_sqrt_price_from_amount0_rounding_up(sqrt_p, liquidity, amount_out, False)


def compute_swap_step(
    sqrt_current: int, sqrt_target: int, liquidity: int, amount_remaining: int, fee_pips: int
) -> dict:
    if fee_pips >= FEE_DEN:
        raise OracleError("invalidFee")
    if amount_remaining == I256_MIN:
        raise OracleError("intOverflow")
    zero_for_one = sqrt_current >= sqrt_target
    exact_in = amount_remaining >= 0
    amount_in = 0
    amount_out = 0
    if exact_in:
        amount_remaining_less_fee = mul_div(amount_remaining, FEE_DEN - fee_pips, FEE_DEN)
        amount_in = (
            get_amount0_delta(sqrt_target, sqrt_current, liquidity, True)
            if zero_for_one
            else get_amount1_delta(sqrt_current, sqrt_target, liquidity, True)
        )
        if amount_remaining_less_fee >= amount_in:
            sqrt_next = sqrt_target
        else:
            sqrt_next = get_next_sqrt_price_from_input(
                sqrt_current, liquidity, amount_remaining_less_fee, zero_for_one
            )
    else:
        requested = -amount_remaining
        amount_out = (
            get_amount1_delta(sqrt_target, sqrt_current, liquidity, False)
            if zero_for_one
            else get_amount0_delta(sqrt_current, sqrt_target, liquidity, False)
        )
        if requested >= amount_out:
            sqrt_next = sqrt_target
        else:
            sqrt_next = get_next_sqrt_price_from_output(
                sqrt_current, liquidity, requested, zero_for_one
            )
    reached = sqrt_target == sqrt_next
    if zero_for_one:
        amount_in = (
            amount_in
            if reached and exact_in
            else get_amount0_delta(sqrt_next, sqrt_current, liquidity, True)
        )
        amount_out = (
            amount_out
            if reached and not exact_in
            else get_amount1_delta(sqrt_next, sqrt_current, liquidity, False)
        )
    else:
        amount_in = (
            amount_in
            if reached and exact_in
            else get_amount1_delta(sqrt_current, sqrt_next, liquidity, True)
        )
        amount_out = (
            amount_out
            if reached and not exact_in
            else get_amount0_delta(sqrt_current, sqrt_next, liquidity, False)
        )
    if not exact_in and amount_out > -amount_remaining:
        amount_out = -amount_remaining
    if exact_in and sqrt_next != sqrt_target:
        fee_amount = amount_remaining - amount_in
    else:
        fee_amount = mul_div_rounding_up(amount_in, fee_pips, FEE_DEN - fee_pips)
    return {
        "sqrtRatioNextX96": sqrt_next,
        "amountIn": amount_in,
        "amountOut": amount_out,
        "feeAmount": fee_amount,
        "zeroForOne": zero_for_one,
        "exactIn": exact_in,
        "reachedTarget": reached,
    }


def signed_div_trunc(a: int, b: int) -> int:
    if b == 0:
        raise OracleError("divisionByZero")
    q = abs(a) // abs(b)
    if (a < 0) != (b < 0):
        q = -q
    return q


def signed_mod_trunc(a: int, b: int) -> int:
    return a - signed_div_trunc(a, b) * b


def compress_tick(tick: int, spacing: int) -> int:
    if spacing <= 0:
        raise OracleError("invalidSpacing")
    compressed = signed_div_trunc(tick, spacing)
    if tick < 0 and signed_mod_trunc(tick, spacing) != 0:
        compressed -= 1
    return compressed


def position(compressed: int) -> tuple[int, int]:
    word_pos = compressed >> 8  # arithmetic
    bit_pos = compressed % 256  # Python Euclidean == uint8(solidity trunc % + wrap)
    return word_pos, bit_pos


def msb(x: int) -> int:
    if x <= 0:
        raise OracleError("bitMathZero")
    return x.bit_length() - 1


def lsb(x: int) -> int:
    if x <= 0:
        raise OracleError("bitMathZero")
    return (x & -x).bit_length() - 1


def next_initialized_tick_within_one_word(
    words: dict[int, int], tick: int, spacing: int, lte: bool
) -> tuple[int, bool]:
    compressed = compress_tick(tick, spacing)
    if lte:
        word_pos, bit_pos = position(compressed)
        mask = (1 << bit_pos) - 1 + (1 << bit_pos)
        masked = words.get(word_pos, 0) & mask
        initialized = masked != 0
        if initialized:
            nxt = (compressed - (bit_pos - msb(masked))) * spacing
        else:
            nxt = (compressed - bit_pos) * spacing
        return nxt, initialized
    word_pos, bit_pos = position(compressed + 1)
    mask = ~((1 << bit_pos) - 1) & (U256 - 1)
    masked = words.get(word_pos, 0) & mask
    initialized = masked != 0
    if initialized:
        nxt = (compressed + 1 + (lsb(masked) - bit_pos)) * spacing
    else:
        nxt = (compressed + 1 + (255 - bit_pos)) * spacing
    return nxt, initialized


def add_delta(x: int, y: int) -> int:
    if y < 0:
        dy = -y
        z = x - dy
        if z < 0 or z >= x:
            raise OracleError("liquidityUnderflow")
        return z
    z = x + y
    if z >= U128 or z < x:
        raise OracleError("liquidityOverflow")
    return z


def fee_spacing_valid(fee: int, spacing: int) -> bool:
    return fee < FEE_DEN and 0 < spacing < 16384


def catch(fn):
    try:
        return {"ok": fn()}
    except OracleError as e:
        return {"error": e.name}


def dec(n: int) -> str:
    return str(n)
