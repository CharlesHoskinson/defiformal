# Tether USDT — draft source research

`dispute-26` / `unit:lane3:c2:p0` / `async_cross_domain`: proposed **supported**. Unaccepted; independent review pending.

Issuer-coordinated exchange chain swaps described in the retained Tether article dated October24,2019, as served at capture time; not an autonomous bridge or every USDT transfer.

source statement: Tether describes receipt confirmation on an originating chain before the corresponding transfer on a destination chain, coordinated with the requesting exchange. [chain-swaps-destination](https://tether.io/news/explained-chain-swaps)

inference under proposed rule: This is a causally linked two-domain workflow with an explicit receipt-confirmation delivery boundary, satisfying R-async_cross_domain for the issuer-coordinated chain-swap path. Multichain token availability alone was not the reason. [chain-swaps-destination](https://tether.io/news/explained-chain-swaps)

scope qualification: Source-chain destruction is conditional: the article also permits retaining inventory after destination delivery. The finding does not assume a universal atomic burn-and-mint mechanism. [chain-swaps-destination](https://tether.io/news/explained-chain-swaps)

Qualifications:

- The two tether.to HTTP200 bodies were meta-refresh wrappers with no article text; they receive zero substantive evidence credit. The explicitly named tether.io destination was followed without executing embedded scripts.
- Three response bodies were retained including those two wrappers, within the cap; only one is a substantive primary article.
- The displayed article date is historical but the served bytes are a current capture, not a recovered2019 snapshot.
- Receipt confirmation is the documented boundary; no block threshold, finality proof, latency bound, relayer code, cryptographic cross-chain verification or live swap transaction was inspected.
- No claim is made about current chain support, reserve sufficiency, guaranteed redemption, or equivalence to USDT0/LayerZero and other separate products.

Retained 3 response bodies, of which 1 are substantive primary sources, totaling 43092 bytes; 3 exact original-byte locators. HTTP failure attempts: 0. Retrieval times, headers, content qualification and hashes remain in the packet.

[Original A/B/generated observations](selection-and-observations.json) preserve the unresolved facet; the [proposal](proposed-adjudication.json) binds the actual proposed rule predicate and scoped reasoning. No canonical corpus edit, missing-attachment recovery or deployment-fidelity claim is made.

Independently review the issuer-mediated workflow finding. Any stronger execution or historical assertion requires separately binding the actual chain pair, confirmation policy and transaction sequence.

Author: GPT-6 stock Codex harness. Native review and acceptance have not been performed.
