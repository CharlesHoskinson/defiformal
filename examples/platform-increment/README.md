# P18 token0 library increment (version 0.1.0)

This directory is the versioned external-user example for the accepted P16
Uniswap v3 token0 next-price Lean library. It is an arithmetic-only increment.
Source refinement, vault reuse, certificates, and whole-program completion
remain open.

The library result is produced by Lean. Python here only binds tools and
launches Lean. It is not a substitute for the helper.

## What you can run

Public entrypoint:

`DefiKernel.ConcentratedLiquidity.SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp`

Inputs: `sqrtPX96` (uint160), `liquidity` (uint128), `amount` (uint256), `add` (bool).
There is no fee argument and no pool storage.

The example prints twelve bounded observations, including:

- zero-amount identity success `(2^96, 1, 0, add)` returning `2^96`
- planned add `(2^96, 1, 1, true)` returning `2^95`
- removal-denominator failure `(2^96, 1, 1, false)` as `error:subUnderflow`
- denominator-sum overflow fallback success on `P16-WRAP`

## Tool binding (required separate step)

Do not hard-code a private worktree or cache path. Copy
`environment.example.json` if you need to name binaries, then bind:

```sh
python3 examples/platform-increment/bind-environment.py \
  --out /tmp/p18-environment.bound.json
```

The binder runs `lake env lean --version` from the repository `lean/`
directory and requires toolchain `leanprover/lean4:v4.33.0-rc2`. A default
PATH `lean` that reports a different version is not used.

Optional: pass `--config path/to/environment.json` if `lake` is not on PATH.

`solc` and `evm` are not required for this Lean example. The accepted pinned
Solidity/EVM campaign is reused by hash from
`review/semantic-kernel/program-execution-20260908/p16-source-candidate-r6.tar.gz`.

## Run the example

```sh
python3 examples/platform-increment/run-token0-example.py \
  --binding /tmp/p18-environment.bound.json
```

Equivalent after a successful bind, from `lean/`:

```sh
lake env lean ../examples/platform-increment/lean/Token0ReleaseExample.lean
```

Expect `denominator=12`, twelve `match=true` rows, and `status=ok`. A zero
denominator is a blocked check, not success.

## Affected library check (unchanged P16 consumer)

From `lean/`:

```sh
lake env lean DefiKernel/ConcentratedLiquidity/RuntimeAudit.lean
```

That command reuses the accepted Examples/Tests tables. It is not a new
Solidity campaign.

`lake env lean DefiKernel/ConcentratedLiquidity/Tests.lean` is a compile-only
check. Empty stdout from that command is compilation evidence, not a model
runtime observation.

## Release packets and consumer classification

```sh
python3 review/semantic-kernel/platform-increment/p18/validation/validate_p18.py
python3 review/semantic-kernel/platform-increment/p18/validation/run_release_controls.py \
  --out-dir /tmp/p18-release-controls
```

The validator requires `p18.token0.next-price.packet.json` from an inventory
that is independent of the loaded packet glob. Missing required packet or empty
required evidence exits 3. Contradictory hashes or invented denominators exit 1.
Intact matching evidence exits 0. Schema validity is not proof.

## What this release does not claim

- P17 vault source, `P17.platform_reuse`, or token0-vault composition
- TickMath, SwapMath, token1/delta, bitmap/factory, compiled M09
- P19/P20 certificates or representation correspondence
- P30 source or assembly refinement
- P37 whole-program completion
- Independent acceptance of this P18 candidate (Opus review is pending)
- Schema validity of evidence packets as proof or execution credit
