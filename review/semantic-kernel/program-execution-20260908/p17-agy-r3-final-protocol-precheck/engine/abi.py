#!/usr/bin/env python3
"""ABI word encoding for vault/token0 engine calls."""
from __future__ import annotations


def strip0x(value: str) -> str:
    v = value.lower()
    return v[2:] if v.startswith("0x") else v


def encode_word(value: int) -> bytes:
    if value < 0 or value >= 2**256:
        raise ValueError(f"not uint256: {value}")
    return value.to_bytes(32, "big")


def encode_address(addr: str) -> bytes:
    h = strip0x(addr)
    if len(h) != 40:
        raise ValueError(f"not address: {addr}")
    return encode_word(int(h, 16))


def encode_bytes(data: bytes) -> bytes:
    head = encode_word(32)
    body = encode_word(len(data)) + data
    pad = (32 - (len(data) % 32)) % 32
    return head + body + (b"\x00" * pad)


def encode_address_bytes(addr: str, data: bytes) -> bytes:
    """Constructor (address, bytes memory)."""
    head = encode_address(addr) + encode_word(64)
    tail = encode_word(len(data)) + data
    pad = (32 - (len(data) % 32)) % 32
    return head + tail + (b"\x00" * pad)


def calldata(selector_hex: str, *words: int | str) -> bytes:
    sel = strip0x(selector_hex)
    if len(sel) != 8:
        raise ValueError(f"selector not 4 bytes: {selector_hex}")
    out = bytes.fromhex(sel)
    for w in words:
        if isinstance(w, str):
            out += encode_address(w)
        else:
            out += encode_word(w)
    return out


def decode_uint(returndata_hex: str) -> int | None:
    h = strip0x(returndata_hex)
    if len(h) != 64 or any(c not in "0123456789abcdef" for c in h):
        return None
    return int(h, 16)


def decode_revert_payload(payload_hex: str) -> dict | None:
    """Decodes Error(string) or Panic(uint256) ABI payload.

    Returns dict with 'selector' and 'decoded_error' on valid structured revert,
    or None if malformed or not a recognized selector.
    """
    h = strip0x(payload_hex)
    if len(h) < 8 or len(h) % 2 != 0 or any(c not in "0123456789abcdef" for c in h.lower()):
        return None
    sel = h[:8].lower()
    data = bytes.fromhex(h[8:])
    if sel == "4e487b71":
        # Panic(uint256)
        if len(data) != 32:
            return None
        code = int.from_bytes(data, "big")
        return {"selector": sel, "decoded_error": f"Panic(0x{code:02x})"}
    if sel == "08c379a0":
        # Error(string)
        if len(data) < 64:
            return None
        offset = int.from_bytes(data[:32], "big")
        if offset != 32:
            return None
        str_len = int.from_bytes(data[32:64], "big")
        pad = (32 - (str_len % 32)) % 32
        if len(data) != 64 + str_len + pad:
            return None
        str_bytes = data[64 : 64 + str_len]
        padding = data[64 + str_len :]
        if any(b != 0 for b in padding):
            return None
        try:
            decoded = str_bytes.decode("utf-8")
        except UnicodeDecodeError:
            return None
        return {"selector": sel, "decoded_error": decoded}
    return None
