"""Gate 2.2 precondition 2: can the 19 unspecced applications actually be specced?

The Phase 2 standard is a re-spec written against contract source, with T0
vectors read off the contract. An application with no contracts on disk cannot
meet it, and that must be DECLARED rather than quietly skipped -- which is the
failure mode this whole phase exists to prevent.

This checks the 19 against `protocol-repos/` only. It does not go to the network:
"absent here" means absent here, not "has no public contracts", and the two are
reported as different things.
"""
import glob
import os
import re

ROOT = "/root/DefiElements"

UNSPECCED = [
    ("Binance Bitcoin (BTCB)", "bridge"),
    ("Ethena (USDe / sUSDe)", "cdp"),
    ("Lista CDP", "cdp"),
    ("Binance Wallet", "intent"),
    ("DFlow", "intent"),
    ("LiquidMesh", "intent"),
    ("OKX DEX", "intent"),
    ("Binance staked ETH (WBETH)", "lsd"),
    ("Aevo (Ribbon Finance lineage)", "opt"),
    ("Rysk V12", "opt"),
    ("Aster", "perp"),
    ("Jupiter Perpetual Exchange", "perp"),
    ("edgeX", "perp"),
    ("Kalshi", "pred"),
    ("BlackRock BUIDL", "rwa"),
    ("Circle USYC (Hashnote)", "rwa"),
    ("World Liberty Financial USD1", "fiat"),
    ("CIAN Yield Layer", "yield"),
    ("Steakhouse Financial", "yield"),
]

repos = []
for d in sorted(glob.glob(f"{ROOT}/protocol-repos/*/*")):
    if os.path.isdir(d):
        repos.append((os.path.basename(os.path.dirname(d)), os.path.basename(d)))


# Generic words that appear in many repo names and identify nothing. A first cut
# used every token of length >= 3 and produced SIX matches, all false:
#   "Binance staked ETH"        -> tethercoin_USDT        ("eth" inside "tether")
#   "CIAN Yield Layer"          -> LayerZero-v2           ("layer")
#   "OKX DEX"                   -> hyperliquid-dex        ("dex")
#   "Jupiter Perpetual Exchange"-> Polymarket_ctf-exchange("exchange")
#   "Circle USYC (Hashnote)"    -> circlefin_evm-cctp     ("circle", wrong product)
#   "Ethena"                    -> (same "eth" trap)
# Substring matching on short generic tokens identifies the category, not the
# protocol.
GENERIC = {"eth", "dex", "usd", "exchange", "layer", "yield", "finance",
           "protocol", "contracts", "core", "swap", "perp", "perpetual",
           "staked", "wallet", "bitcoin", "circle", "binance", "labs", "v12"}


def toks(s):
    s = s.split("(")[0].lower()
    out = [t for t in re.split(r"[^a-z0-9]+", s) if len(t) >= 4]
    return [t for t in out if t not in GENERIC]


print(f"repos on disk: {len(repos)}\n")
print(f"{'application':<32} {'cat':<7} contracts on disk")
print("-" * 74)
have, lack = [], []
for name, cat in UNSPECCED:
    ts = toks(name)
    hit = None
    for rcat, rname in repos:
        low = rname.lower()
        if any(t in low for t in ts):
            hit = f"{rcat}/{rname}"
            break
    if hit:
        have.append((name, hit))
        print(f"{name[:32]:<32} {cat:<7} {hit}")
    else:
        lack.append((name, cat))
        print(f"{name[:32]:<32} {cat:<7} -- none --")

print(f"\n{'='*74}")
print(f"with contracts on disk : {len(have)} of {len(UNSPECCED)}")
print(f"without                : {len(lack)} of {len(UNSPECCED)}")
print()
print("WITHOUT, grouped by why it matters:")
for name, cat in lack:
    print(f"   {cat:<7} {name}")
print()
print("This is 'absent from protocol-repos', NOT 'has no public contracts'.")
print("Some of these are Solana or CEX-adjacent (Jupiter, edgeX, Kalshi,")
print("Binance products) and some are curator FIRMS rather than protocols.")
print("Each needs a per-application decision, and the decision must be written")
print("down -- an application skipped silently is indistinguishable from one")
print("that was specced and found to generate.")
