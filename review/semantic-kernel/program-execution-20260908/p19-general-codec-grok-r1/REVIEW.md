# P19 R10 general codec proof review

**Mark:** `GENERAL_CODEC_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED` (initial; probes pending)  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: AGY R10 archive SHA256 `6b4b06bb5854f979032746f6a30fcbddd572dd95085d317fc0b4482df58d74ca` (3447 files, root-verified). Author reports `PARTIAL_PROOF_WORK`. Root R10 precheck already required changes on depth fidelity and recorded the public-resource classification bug. This audit assesses frozen R10 only. AGY R11 is out of scope.

Compiler target: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Private copied build cache. Frozen sandbox sources are not written.

## Initial status

Source inspection of frozen Correspondence already confirms the two root R10 items:

1. `ExprDepthBounded` is still `exprMaxStackDepth e ≤ 52 ∧ exprDepth e ≤ 55`. REPORT claims the old `exprDepth ≤ 55` cap was eliminated. It remains. Nested collection length predicates were added relative to R9.

2. `EncodeDecodeRoundtripStatement` remains `def Prop`. Component inversions invert `*ToJson` helpers, not `encodeModule` / `decodeBytes`.

3. Author `theorems.json` says 148; `results.json` says 138 Correspondence. Actual declaration counts and axiom audit are pending the private rebuild.

Public-resource classification (`decodeBytes` mapping parser resource errors to `notJsonObject`, Check mapping that to malformed) is source-confirmed in frozen Decode/Check. Runtime membership of SupportedIR is not required for that classification claim.

Historical 54-fixture / 99-scenario evidence is not re-run and is not treated as repaired.

## Next

Rebuild CanonicalJson/Correspondence in private-lean. Count exact theorem declarations. `#print axioms` named new/general theorems. Focused depth-shape check. Hash identity vs REPORT/manifest.
