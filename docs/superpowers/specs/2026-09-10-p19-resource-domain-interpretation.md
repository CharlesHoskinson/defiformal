# P19 resource-domain interpretation

The required domain includes the full supported canonical typed/step/run grammar within its actual resource limits: serialized bytes at most1MiB, JSON depth64 and array length4096. The R8 additions of per-string4096-character limits and1e18state-rational limits are not authorized grammar restrictions. They must not exclude ordinary otherwise supported documents merely to simplify a proof.

The earlier parser design's structural-bound requirement means that resource admission must have a noncircular, faithful definition. An exact predicate on the byte length produced by the real encoder is a valid resource bound. It is not prior decoder admission, membership in a decoder image, or the desired roundtrip conclusion. It does not prove parsing or inversion and cannot replace those obligations. A complete structural cost function is also valid when its relation to actual serialization is proved and it does not silently narrow the required domain through arbitrary estimates or caps.

Whole-document depth and collection limits still need complete coverage and sufficient-fuel arguments, including all nested payloads and envelope fields. Bounding a guessed estimator alone is insufficient. Constant costs for variable-sized registry entries or complete step/run payloads do not establish a serialized-size bound. Do not place successful lexical/schema parsing or the target equality itself in the domain as a shortcut.

Keep all historical planning bytes and R8 evidence unchanged. This note clarifies a routine implementation choice under the user's full-core authorization; it does not claim a new user approval or waive the universal production codec theorem. Native AGY implements; fresh Grok independently audits the frozen result.
