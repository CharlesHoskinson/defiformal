I'll start by reading the full review request and the review skill so the verdict stays inside the stated scope.Using the review skill next, then I'll inspect the attached implementation and schema only.**Advisory source review only.** I inspected the attached `scripts/corpus_normalize.py` (claimed exact text) and the compact semantic form of `corpus/normalized/corpus.schema.json`. I did not run the script, did not hash the attachments, and did not inspect commit `045126ef8493ff34da5f485c80d71414b29b2df3`. Tests and data are out of scope.

**Verdict: do not treat this as an executed pass.** On source inspection, the build/check decision path matches the stated rule (provisional AGREE; INTERSECTION_UNRESOLVED keeps the intersection and leaves the symmetric difference unresolved). The implementation is **not** a sufficient reconstruction gate, and the schema is **not** a sufficient decision contract.

---

### Blockers

**1. High — 72-to-75 split is ID-only (implementation)**
`scripts/corpus_normalize.py` ~192–203.

`SPLITS` only constrains `(unit_id, legacy_id)` plus `split_rule` / `normalization_status`. The checker does not require split siblings to differ on the split dimension.

- `explicit-version-split` can pass with identical or both-`unresolved` `version` objects.
- `explicit-product-split` can pass with the same `product.id`.
- The ID suffix (`v1`, `usdy`, …) is not bound to `version.value` or `product.id`.

Fix: group units by `legacy_id`. For each `SPLITS` parent, require the exact child count, distinct non-null `version.value` (version split) or distinct `product.id` (product split), and bind the suffix to that field.

**2. High — schema does not encode the decision rule (schema)**
`$defs/adjudication`.

Draft 2020-12 can pair empty `unresolved_labels` with `AGREE` / `provisional_agreement` and non-empty with `INTERSECTION_UNRESOLVED` / `unresolved_difference` (`if`/`then`). The schema allows all four rule×status combinations. It also leaves `retained` / `a` / `b` unconstrained (not intersection / not vocabulary-limited).

`check` rebuilds the corpus and compares bytes, so this is a blocker for **schema-only** acceptance, not for “`check` is mandatory.”

Fix: add `if`/`then` for rule and status vs `unresolved_labels`. Keep set-intersection as a checker invariant (JSON Schema cannot state it well). Fail `check` unless `retained == sorted(set(a)&set(b))` and `unresolved_labels == sorted(set(a)^set(b))` on the **actual** file, not only via rebuild equality.

**3. High — `annotation_refs` need not be annotators `a` and `b` (schema)**
`$defs/unit.annotation_refs` is `minItems: 2`, `maxItems: 2` with no `contains` for `a` and `b`, and no uniqueness on `annotator_id`. `[a,a]` is schema-valid.

Fix: `contains` for each annotator_id, or `prefixItems` `a` then `b`.

---

### Status contract (not a decision-logic fail; CI will mis-bin)

**4. Medium — hash / inventory failures are not one class**

| Event | Status |
|---|---|
| Source SHA256 mismatch | 3 BLOCKED |
| Annotation `input_sha256` mismatch | 1 FAIL (default `require`) |
| Output dir already exists | 1 FAIL |
| Missing generated file | 3 BLOCKED |

Docstring says statuses are 0/1/3 but does not define the split. Provenance mismatch on annotations is the same class as source digest mismatch.

Fix: document 3 = missing/unreadable/escape/unpinned bytes, 1 = well-formed but wrong projection. Use 3 for every digest/`input_sha256` mismatch.

---

### What the source does get right (inspection, not a run)

- **Read-only `check`:** `check` only reads. `build` is the only writer. `check` rebuilds the projection from repo inputs and compares bytes.
- **Binding:** both envelopes must hash the same `annotation-input.json` bytes. Lane files are digested before rows are built. Neutral input is rebuilt from identity map + taxonomy + source rows (parent `original` shared by split children).
- **Decision path:** `retained = sorted(a & b)`, `unresolved = sorted(a ^ b)`; any symmetric difference is `INTERSECTION_UNRESOLVED`. Corpus status stays `provisional_source_bound`. All units are `evaluation_role: development`; deployments are schema-`unresolved`; `verified_deployments` is 0.
- **Stated limits that are not bugs:** proposal bytes are authenticated and not ingested; `source_commit` is not git authentication; empty ∩ empty is AGREE and is documented as “not evidenced”; org/product IDs are label consistency, not legal-entity proofs.

---

### Future work (not blockers for this rule set)

- Unique `legacy_id` / `unit_id` / binding paths live in `check`, not in the schema.
- `annotation_ref.sha256` is not required to equal `input_bindings` for that path.
- `unit.facets` is retained labels only; empty is AGREE-empty or disjoint. Consumers must join `adjudications`.
- Split children share one parent `source_record.original` (fits “no recovered per-child attachments”).
- Duplicated `identity` vs `unit` property blocks can drift.

---

**Accept `check` as the real gate, not the schema.** Do not accept the implementation as a finished 72-to-75 identity reconstruction until split payloads are constrained. I make no claim that this candidate builds, that tests pass, or that the compact schema bytes match `98c005eeb9625f20…`.
