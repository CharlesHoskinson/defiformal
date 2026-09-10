# Task 2.2 bytecode SHA256 bindings

Campaign compile uses solc 0.8.21 SHA `f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df`, optimizer runs 200, `metadata.bytecodeHash = none`, `evmVersion = shanghai`.
Historical administrative smoke used `bytecodeHash = ipfs` and is **not** campaign identity.
Captured `src/SUsds.sol` SHA256 `9fe0c713751142e75a1da60ad6c0127d5ad01cb6d24289183ac48b202f3c5d69` is unchanged from the pin.

`compile.py` records `bytecode_sha256.{creation,runtime}` as SHA256 of the **hex text** object string from solc. Opus R4 notes hashed the **decoded bytecode bytes**. Both encodings are recorded. Historical source and smoke bytes are not modified.

Evidence: `grok-r5/attempt-1/evm/compile/compile.json`. R4 and grok-r5 SUsds objects are byte-identical.

| Artifact | SHA256 | Encoding | Role |
|---|---|---|---|
| Historical IPFS smoke SUsds creation | `8277f71a7ddddb5821d04026c6cec449bacb9cda057ab56e97b61b7b731bf425` | smoke | `is_campaign_bytecode: false`; ipfs metadata |
| Historical IPFS smoke SUsds runtime | `f034c81cc8e931b37acff16f30d19498955ebafd625548f1ff7d4c49adc7b2cb` | smoke | smoke-only |
| Campaign SUsds creation (hex text) | `b04a023088e6532e0647ccabf723d1ad1a998edb5e0dd2870a5ec2a0798f78cb` | UTF-8 hex string | `compile.json` `bytecode_sha256.creation` |
| Campaign SUsds runtime (hex text) | `e0f712bdc2fd6c7f5923ccc7a06a89612be841caa99c3de957d5c7011789fc24` | UTF-8 hex string | `compile.json` `bytecode_sha256.runtime` |
| Campaign SUsds creation (raw bytes) | `9f8138560a97e23c4070e75d7b73011908b4da82c8c6be540a87884b362d1bd0` | unhexlify | matches Opus R4 reviewer-computed none-metadata hash |
| Campaign SUsds runtime (raw bytes) | `16f3e78d1f0f498c7854b832b41bdd774a75adbb1c81b9410f760c3c3e6e3ff5` | unhexlify | campaign identity, not IPFS smoke |

Why these differ from historical IPFS smoke: solc `metadata.bytecodeHash` is `none` for the campaign and `ipfs` for the administrative smoke. Source pin bytes are the same. Why hex-text and raw-bytes hashes differ from each other: they hash different encodings of the same object.
