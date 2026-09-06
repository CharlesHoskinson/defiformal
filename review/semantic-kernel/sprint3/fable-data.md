Verdict: no blocking correctness or provenance bug found in the attached records. The arithmetic is internally consistent, every sampled decision applies AGREE or INTERSECTION_UNRESOLVED correctly, and the split children do not inherit parent-only mechanisms. This is a source read of the attachments only. Nothing was built, checked or hashed here, and the manifest, raw annotation files and lane files were not in scope.

What checked out:

- **Counts reconcile.** Source rows sum to the mapped rows, the split arithmetic reaches the candidate count, and per-facet agreements plus unresolved differences sum to the facet decision total.
- **Decision records match inputs.** For all eight sampled units the retained set equals the intersection of the two annotator sets, unresolved labels equal the symmetric difference, and unit facets equal the retained sets.
- **Split attribution respects BUNDLE_CONTEXT.** V1 rationales cite Recovery Mode and redistribution only. V2 rationales cite rate-ordered redemption, batch managers and PIL only. OUSG and USDY do not cross-inherit, and Global Markets carries only the category-level function.

Findings, none blocking:

1. **Empty-on-empty counted as provisional agreement (medium, reporting).** Ten of the forty sampled facet decisions are two empty sets recorded as agreement. The headline agreement count therefore mixes "both evidenced the same labels" with "neither found evidence". Fix: add per-facet agreed_nonempty and agreed_empty counts in coverage, and cite only the nonempty figure.
2. **Ondo Stocks claim is unbound (medium, provenance).** The excerpts file and README both state that current Ondo navigation uses Ondo Stocks, but no excerpt contains that string, so the claim is not covered by any recorded hash. Fix: add the excerpt, or reword the caution as "observed in the temporary capture, not excerpted".
3. **Hash inputs underspecified (low, reproducibility).** The excerpts file does not say whether response_sha256 covers body bytes or headers plus body, nor how the excerpt list is serialized before hashing. Fix: state both in the file and in the README reproduction section.
4. **Split counts are not machine-checked (low).** Coverage reports source rows and candidate units but not how many rows were split into how many children. The 72-to-75 claim lives only in README prose. Fix: emit split_rows and split_children and have check assert the identity.
5. **Liquity children share one product ID (low, identity claim).** V1 and V2 both carry product:liquity while Ondo children get distinct product IDs. Sharing a product ID asserts a single-product identity the source does not make. Fix: give each version its own product ID or mark the shared product status as bundled_label.
6. **Agreement on forced-fit labels hides taxonomy gaps (future work).** Both annotators map Maple delegates, Ondo NAV managers and Liquity batch managers to curator. Agreement records this as provisional truth and discards the source's forced-fit signal. Consider a per-facet taxonomy_gap flag so AGREE does not launder a poor fit.

Limits of this review: the sample shows only one row per shared label, so the claim that Maple, Jupiter and Steakhouse siblings are not merged could not be checked. The annotator input hash the README promises is not in the projection. The decisions array shows only unresolved cases, so the sample cannot confirm that AGREE decisions are also persisted as records.

Recommended order: fix 1 and 2 before this coverage report is cited anywhere. Items 3 to 5 fit the next increment. Item 6 belongs with the source-acquisition work already listed in the README.
