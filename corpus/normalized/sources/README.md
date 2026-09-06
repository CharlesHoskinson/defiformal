# Limited external provenance capture

The parent harness retrieved the official pages listed in primary-excerpts.json
on the recorded UTC dates. Each record includes the requested/final URL, HTTP
status, content type, response SHA-256, selected excerpts and excerpt SHA-256.
Excerpt normalization removes script/style text, collapses whitespace and removes
spaces immediately before punctuation. Response hashes cover the exact body bytes returned by urllib response.read(),
excluding headers. Excerpt hashes use the UTF-8 encoding of the listed strings
joined with LF and a final LF, without JSON serialization. Each source contributes at most 25 excerpt words.

Full response bytes are not committed; their hashes fingerprint the retrieval
but do not themselves authenticate the publisher or let a future reader recover
a changed page. The current documentation is distinct from the frozen historical
lane narrative and was not shown to the blind annotators. No contract address,
chain deployment or bytecode revision is asserted from this capture.

The original proposal's `sandbox:/mnt/data/defi_kernel_corpus_crosswalk.csv` and
`defi_kernel_taxonomy_schema.json` were not found in the searched accessible home
and Desktop trees. `/mnt/data` was absent. The new corpus/schema are reconstructed
artifacts, and the original proposal's unresolved citation tokens remain open
bibliographic work. This sprint does not claim to have recovered every source.
