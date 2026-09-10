#!/usr/bin/env python3
"""Extract exact source lines for P26 observation mapping. Read-only. No Go execution."""
from __future__ import annotations

import json
import sys
from pathlib import Path

PREP = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/"
    "p26-source-grok-r1-sandbox/review/semantic-kernel/program-execution-20260908/"
    "p26-ibc-source-preparation"
)

SPECS = [
    ("recv_packet_timeout_elapsed", "source/modules/core/04-channel/keeper/packet.go", 147, 149),
    ("recv_proof_then_replay", "source/modules/core/04-channel/keeper/packet.go", 154, 164),
    ("recv_start_sequence_error", "source/modules/core/04-channel/keeper/packet.go", 189, 192),
    ("unordered_duplicate_noop", "source/modules/core/04-channel/keeper/packet.go", 199, 206),
    ("ordered_old_sequence_noop", "source/modules/core/04-channel/keeper/packet.go", 224, 230),
    ("ordered_future_sequence_error", "source/modules/core/04-channel/keeper/packet.go", 232, 238),
    ("ack_empty_commitment_noop", "source/modules/core/04-channel/keeper/packet.go", 377, 386),
    ("ack_delete_commitment", "source/modules/core/04-channel/keeper/packet.go", 436, 438),
    ("timeout_maturity", "source/modules/core/04-channel/keeper/timeout.go", 68, 71),
    ("timeout_empty_commitment_noop", "source/modules/core/04-channel/keeper/timeout.go", 75, 82),
    ("timeout_nonreceipt_branches", "source/modules/core/04-channel/keeper/timeout.go", 91, 113),
    ("timeout_executed_delete", "source/modules/core/04-channel/keeper/timeout.go", 130, 142),
    ("timeout_on_close_noop", "source/modules/core/04-channel/keeper/timeout.go", 196, 203),
    ("msg_recv_noop_before_callback", "source/modules/core/keeper/msg_server.go", 433, 445),
    ("msg_timeout_noop_before_callback", "source/modules/core/keeper/msg_server.go", 497, 516),
    ("msg_timeout_on_close_noop", "source/modules/core/keeper/msg_server.go", 549, 557),
    ("msg_ack_noop_before_callback", "source/modules/core/keeper/msg_server.go", 597, 616),
    ("ics20_send_blocked_sender", "source/modules/apps/transfer/keeper/relay.go", 63, 65),
    ("ics20_recv_blocked_receiver", "source/modules/apps/transfer/keeper/relay.go", 137, 139),
    ("ics20_success_ack_no_refund", "source/modules/apps/transfer/keeper/relay.go", 220, 228),
    ("ics20_timeout_refund", "source/modules/apps/transfer/keeper/relay.go", 235, 243),
    ("ics20_refund_blocked_sender", "source/modules/apps/transfer/keeper/relay.go", 257, 263),
    ("ics20_refund_origin_branches", "source/modules/apps/transfer/keeper/relay.go", 275, 292),
    ("ics20_unescrow_can_fail", "source/modules/apps/transfer/keeper/relay.go", 315, 322),
    ("update_client_verify_then_freeze", "source/modules/core/02-client/keeper/client.go", 56, 75),
    ("recover_client", "source/modules/core/02-client/keeper/client.go", 118, 145),
    ("verify_membership_requires_active", "source/modules/core/02-client/keeper/keeper.go", 336, 347),
    ("frozen_status", "source/modules/light-clients/07-tendermint/client_state.go", 81, 88),
    ("freeze_height_assign", "source/modules/light-clients/07-tendermint/update.go", 211, 217),
    ("send_packet_requires_active", "source/modules/core/04-channel/keeper/packet.go", 60, 63),
]


def main() -> int:
    excerpts = []
    failures = []
    for spec_id, rel, start, end in SPECS:
        path = PREP / rel
        if not path.is_file():
            failures.append({"id": spec_id, "error": "missing", "path": rel})
            continue
        lines = path.read_text().splitlines()
        if end > len(lines) or start < 1:
            failures.append({
                "id": spec_id,
                "error": "range",
                "path": rel,
                "start": start,
                "end": end,
                "nlines": len(lines),
            })
            continue
        excerpts.append({
            "id": spec_id,
            "path": rel,
            "start_line": start,
            "end_line": end,
            "lines": [
                {"n": i, "text": lines[i - 1]}
                for i in range(start, end + 1)
            ],
        })
    result = {
        "probe": "p26-source-observation-extract",
        "excerpt_count": len(excerpts),
        "failure_count": len(failures),
        "failures": failures,
        "excerpts": excerpts,
        "source_execution": False,
        "proof_or_execution": False,
        "empty_check_blocked": len(SPECS) == 0,
    }
    json.dump(result, sys.stdout, indent=2)
    sys.stdout.write("\n")
    if len(SPECS) == 0:
        return 3
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
