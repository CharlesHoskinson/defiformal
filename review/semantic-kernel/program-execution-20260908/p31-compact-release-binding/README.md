# Compact 0.31.1 release binding

Root checked the installed x86_64 Linux MUSL package against the official Compact release metadata. The local artifact.zip is 27,444,336 bytes, SHA-256 `e291b4bab4d4e857707008f8b1c25c2b8e0c843f6c737d0ee6c0d9ac69a6bbfb`. Both size and digest match the GitHub release asset. Each of its six members matches the installed file byte-for-byte: compactc, compactc.bin, fixup-compact, format-compact, zkir and zkir-v3. This is release package identity evidence, not a source rebuild.

The installed zkir member remains SHA-256 `5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc`, the exact tool used by the sealed P31 mock-format controls. The archive was read locally; it was not downloaded again, extracted over the installation, or executed by this check. Exact asset URL, GitHub asset ID, fetch receipts and member hashes are retained in binding.json.

The compactc-v0.31.1 tag resolves to commit `30034b5e58983bace24c0a22a969946957a73967`. The complete, nontruncated tree response contains release documentation/templates and prior prerelease archives; it does not contain compiler or ZKIR build sources. The release body is null. This bounded observation does not establish that build sources or provenance are unavailable elsewhere.

Together with the separately captured midnight-zkir2.1.0 crate, this supplies concrete release and source inputs for independent interface review. The relationship between that published source and this release binary remains an explicit unverified build assumption. No reproducible build or compiler correctness theorem is claimed. This preparation does not accept adapter32.7, semantic correspondence, fullP31 or a cryptographic proof.

Source: [official Compact 0.31.1 release](https://github.com/midnightntwrk/compact/releases/tag/compactc-v0.31.1). The existing local package is identified by digest rather than duplicated in this evidence folder.
