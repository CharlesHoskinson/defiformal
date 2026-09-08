"""Independent atlas ordering/name contract.

Reads viz/src/data.ts. Does not import or copy orderedElements/accessibleName
from viz/src/main.ts. Expected keyboard order comes from the declared
reading-order contract (by group / by stratum / by ID) plus the typed export.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

VIZ = Path(__file__).resolve().parents[1]
DATA_TS = VIZ / "src" / "data.ts"

# Spec/design status words — not read from main.ts.
STATUS_WORD = {
    "core": "core",
    "candidate": "candidate: recurrence evidence short",
    "provisional": "contested: note required",
    "limit": "degenerate limit: not an element",
}
HZ_WORD = {"F": "forbidden", "H": "elevated", "U": "unverifiable"}
ATOM_WORD = {
    "N": "async-native",
    "R": "async-repairable",
    "I": "async-impossible",
}

NINE_FIELDS = (
    "symbol",
    "name",
    "id",
    "group",
    "stratum",
    "status",
    "asynchrony",
    "hazard",
    "discriminator",
)


@dataclass(frozen=True)
class Element:
    id: str
    sym: str
    name: str
    group: str
    stratum: int
    atom: str
    status: str
    disc: str | None


@dataclass(frozen=True)
class Group:
    id: str
    name: str
    boundary: str


@dataclass(frozen=True)
class Hazard:
    id: str
    combo: str
    cls: str


@dataclass(frozen=True)
class Contested:
    id: str
    sym: str
    name: str
    gate: str


def _block(src: str, name: str) -> str:
    m = re.search(rf"export const {name}\s*(?::[^=]+)?=\s*\[", src)
    if not m:
        raise ValueError(f"missing export {name}")
    i = m.end() - 1
    depth = 0
    for j, ch in enumerate(src[i:], i):
        if ch == "[":
            depth += 1
        elif ch == "]":
            depth -= 1
            if depth == 0:
                return src[i : j + 1]
    raise ValueError(f"unclosed export {name}")


def load_atlas(path: Path = DATA_TS):
    src = path.read_text(encoding="utf-8")
    groups = []
    for m in re.finditer(
        r'\{\s*id:\s*"(G\d+)",\s*name:\s*"([^"]+)",\s*boundary:\s*"([^"]+)"\s*\}',
        _block(src, "GROUPS"),
    ):
        groups.append(Group(m.group(1), m.group(2), m.group(3)))
    group_by_id = {g.id: g for g in groups}

    elements = []
    for m in re.finditer(
        r'\{\s*id:\s*"([^"]+)",\s*sym:\s*"([^"]+)",\s*name:\s*"([^"]+)",\s*'
        r'group:\s*"([^"]+)",\s*stratum:\s*(\d+),\s*atom:\s*"([^"]+)",\s*'
        r'status:\s*"([^"]+)"([^}]*)\}',
        _block(src, "ELEMENTS"),
    ):
        rest = m.group(8)
        disc_m = re.search(r'disc:\s*"([^"]+)"', rest)
        elements.append(
            Element(
                id=m.group(1),
                sym=m.group(2),
                name=m.group(3),
                group=m.group(4),
                stratum=int(m.group(5)),
                atom=m.group(6),
                status=m.group(7),
                disc=disc_m.group(1) if disc_m else None,
            )
        )

    hazards = []
    for m in re.finditer(
        r'\{\s*id:\s*"([^"]+)",\s*combo:\s*"([^"]+)",\s*cls:\s*"([FHU])"',
        _block(src, "HAZARDS"),
    ):
        hazards.append(Hazard(m.group(1), m.group(2), m.group(3)))

    contested = []
    for m in re.finditer(
        r'\{\s*id:\s*"(P\d+)",\s*sym:\s*"([^"]+)",\s*name:\s*"([^"]+)",\s*gate:\s*"([^"]+)"\s*\}',
        _block(src, "CONTESTED"),
    ):
        contested.append(Contested(m.group(1), m.group(2), m.group(3), m.group(4)))

    if not groups or not elements:
        raise ValueError("empty groups or elements — blocked, not a pass")
    return {
        "groups": groups,
        "group_by_id": group_by_id,
        "elements": elements,
        "hazards": hazards,
        "contested": contested,
        "source": str(path),
    }


def declared_order(elements: list[Element], order: str) -> list[Element]:
    """Declared reading-order contract from the interaction spec.

    by group: group, then stratum, then ID
    by stratum: stratum, then group, then ID
    by ID: ID
    """
    if order == "group":
        key = lambda e: (e.group, e.stratum, e.id)
    elif order == "stratum":
        key = lambda e: (e.stratum, e.group, e.id)
    elif order == "id":
        key = lambda e: e.id
    else:
        raise ValueError(f"unknown reading order {order}")
    return sorted(elements, key=key)


def hazards_for(sym: str, hazards: list[Hazard]) -> list[Hazard]:
    out = []
    for h in hazards:
        if re.search(rf"\b{re.escape(sym)}\b", h.combo):
            out.append(h)
    return out


def expected_accessible_name(e: Element, group_by_id: dict[str, Group], hazards: list[Hazard]) -> dict:
    """Nine required field strings that must appear in the accessible name."""
    g = group_by_id[e.group]
    hz = hazards_for(e.sym, hazards)
    if hz:
        classes = []
        for h in hz:
            w = HZ_WORD[h.cls]
            if w not in classes:
                classes.append(w)
        hazard = "hazard " + " and ".join(classes)
        # membership of any class token is the requirement; join wording may vary
        hazard_needles = classes
    else:
        hazard = "no hazard membership"
        hazard_needles = [hazard]
    disc = "discriminator required" if e.disc else "no discriminator required"
    return {
        "symbol": e.sym,
        "name": e.name,
        "id": e.id,
        "group": e.group,
        "group_name": g.name,
        "stratum": f"S{e.stratum}",
        "status": STATUS_WORD[e.status],
        "asynchrony": ATOM_WORD[e.atom],
        "hazard": hazard,
        "hazard_needles": hazard_needles,
        "discriminator": disc,
    }


def missing_name_fields(name: str, e: Element, group_by_id: dict[str, Group], hazards: list[Hazard]) -> list[str]:
    if not name or not name.strip():
        return list(NINE_FIELDS)
    fields = expected_accessible_name(e, group_by_id, hazards)
    missing = []
    if e.sym not in name:
        missing.append("symbol")
    if e.name not in name:
        missing.append("name")
    if e.id not in name:
        missing.append("id")
    if e.group not in name:
        missing.append("group")
    if fields["stratum"] not in name:
        missing.append("stratum")
    if fields["status"] not in name:
        missing.append("status")
    if fields["asynchrony"] not in name:
        missing.append("asynchrony")
    if fields["hazard"] == "no hazard membership":
        if "no hazard membership" not in name:
            missing.append("hazard")
    else:
        if not any(n in name for n in fields["hazard_needles"]):
            missing.append("hazard")
    if fields["discriminator"] not in name:
        missing.append("discriminator")
    return missing


def next_typeahead(seq: list[Element], current_id: str, letter: str) -> str:
    """Spec: type-ahead matches on symbol, continuing after the current entry."""
    ids = [e.id for e in seq]
    i = ids.index(current_id)
    rot = seq[i + 1 :] + seq[: i + 1]
    needle = letter.lower()
    for e in rot:
        if e.sym.lower().startswith(needle):
            return e.id
    return current_id


def self_check() -> dict:
    atlas = load_atlas()
    els = atlas["elements"]
    counts = {
        "elements": len(els),
        "unique_ids": len({e.id for e in els}),
        "groups": len(atlas["groups"]),
        "contested": len(atlas["contested"]),
        "hazards": len(atlas["hazards"]),
        "core": sum(e.status == "core" for e in els),
        "candidate": sum(e.status == "candidate" for e in els),
        "limit": sum(e.status == "limit" for e in els),
        "provisional_in_elements": sum(e.status == "provisional" for e in els),
    }
    if counts["elements"] == 0:
        raise SystemExit("blocked: zero elements")
    # negative companion for the name checker
    probe = els[0]
    full_fields = expected_accessible_name(probe, atlas["group_by_id"], atlas["hazards"])
    fake_full = ", ".join(
        [
            probe.sym,
            probe.name,
            f"ID {probe.id}",
            f"group {probe.group} {full_fields['group_name']}",
            full_fields["stratum"],
            full_fields["status"],
            full_fields["asynchrony"],
            full_fields["hazard"],
            full_fields["discriminator"],
        ]
    )
    missing_status = missing_name_fields(
        fake_full.replace(full_fields["status"], "STATUS_OMITTED"),
        probe,
        atlas["group_by_id"],
        atlas["hazards"],
    )
    empty_missing = missing_name_fields("", probe, atlas["group_by_id"], atlas["hazards"])
    good = missing_name_fields(fake_full, probe, atlas["group_by_id"], atlas["hazards"])
    if "status" not in missing_status:
        raise SystemExit("name checker did not catch omitted status — always-green")
    if empty_missing != list(NINE_FIELDS):
        raise SystemExit(f"empty name must miss all nine, got {empty_missing}")
    if good:
        raise SystemExit(f"complete synthetic name should pass, missing {good}")
    orders = {k: [e.id for e in declared_order(els, k)] for k in ("group", "stratum", "id")}
    if orders["group"] == orders["id"] and orders["stratum"] == orders["id"]:
        raise SystemExit("all three reading orders collapsed — order contract is vacuous")
    return {
        "counts": counts,
        "negative_omitted_status": missing_status,
        "orders_first5": {k: v[:5] for k, v in orders.items()},
        "orders_len": {k: len(v) for k, v in orders.items()},
    }


if __name__ == "__main__":
    import json

    print(json.dumps(self_check(), indent=2))
