import json
# Exact integer formula transcribed from pinned SharesMathLib.toAssetsDown.
# This is a local arithmetic diagnostic, not EVM execution or a reachable-state proof.
virtual_shares = 1_000_000
virtual_assets = 1
total_shares = 2_000_000
supplier_shares = [1_000_000, 1_000_000]
assets_before = 2
assets_after = 1
def claim(shares, assets):
    product = shares * (assets + virtual_assets)
    assert 0 <= product < 2**256
    return product // (total_shares + virtual_shares)
before = [claim(s, assets_before) for s in supplier_shares]
after = [claim(s, assets_after) for s in supplier_shares]
losses = [a - b for a, b in zip(before, after)]
loss = assets_before - assets_after
assert before == [1, 1] and after == [0, 0]
assert loss == 1 and sum(losses) == 2
print(json.dumps({"evidence_class": "local arithmetic diagnostic", "source_execution": False,
    "supplier_shares": supplier_shares, "total_shares": total_shares,
    "assets_before": assets_before, "assets_after": assets_after,
    "claims_before": before, "claims_after": after, "claim_decreases": losses,
    "aggregate_asset_decrease": loss, "sum_claim_decreases": sum(losses),
    "loss_minus_sum_claim_decreases": loss - sum(losses),
    "reachable_liquidation_state_proved": False}, indent=2))
