# Provisional normalized corpus

This is the source-bound corpus increment of the semantic-kernel migration.
It preserves the 72 historical records in `corpus50/lanes` and maps them to 75
candidate units. Liquity's bundled row is split into V1/V2; Ondo's bundled row
is split into USDY, OUSG and Global Markets. Other product/version bundles and
all deployment identities remain unresolved. This is a development corpus.

The proposal's linked CSV and JSON Schema were not recovered. These files are
new reconstructions; they do not reproduce its absent annotations or the stated
31/72 multi-function count. A valid generated dataset means the reconstruction
is complete and consistent with its declared inputs, not that its financial
classifications or source claims have been verified.

## Reproduce and check

From the repository root, using Python and the dependency version in
`corpus/normalized/requirements.txt`:

Check the committed corpus (actual independent annotations):

```sh
python3 scripts/corpus_normalize.py check --repo .
```

Reproduce it in a new directory and check that output:

```sh
python3 scripts/corpus_normalize.py build --repo . --out /tmp/corpus-build-NEW
python3 scripts/corpus_normalize.py check --repo . --data /tmp/corpus-build-NEW
```

Run the separate CLI regression suite:

```sh
python3 scripts/test_corpus_normalize.py
```

The regression suite constructs synthetic annotations in temporary repositories.
Its agreement counts are fixture values; they are not the actual corpus results.
The actual integration evidence records the first command and a byte comparison
of all three regenerated files separately.

`build` requires a new output directory. It emits `corpus.json`, `crosswalk.csv`
and `coverage.json`. `check` defaults to `corpus/normalized/generated` and accepts
`--data DIR` for another output directory. It checks without regenerating files.
Exit 0 means a complete, nonempty and internally consistent provisional corpus;
exit 1 means invalid derived data or annotations; exit 3 means required evidence
could not be checked. A missing generated output is not a successful empty check.

## What is preserved

- Source file byte hashes, source commit and JSON pointers bind every original
  record, including rank statements, ordering, residue and forced-fit notes.
- Organization IDs are corpus-label containers. Shared Jupiter, Maple and
  Steakhouse labels do not merge their product-context records or prove common
  deployment/legal identity.
- Version labels are distinct from deployed bytecode/source-code revisions.
  Every chain/address/revision remains unresolved here. IDs are stable within
  this frozen inventory, not a universal external entity-resolution service.
- Split children reference the original row as bundled context. Its complete
  mechanism, residue and forced-fit arrays are not asserted for every child.

## Annotation and disagreement

Two separate GPT-6 contexts receive the same neutral annotation input and
controlled taxonomy. Neither reads the other's output. Their files record the
actual input hash and remain separate. This is independent elicitation from the
same model family, not independent human expert verification.

Each candidate has economic-function, instrument, mechanism, execution and trust
facets. The rationale and uncertainty remain available in the raw annotation
files. Empty labels mean not evidenced or unresolved, not proved absence.
Identical label sets are provisional agreement. Different sets retain their
intersection provisionally; the symmetric difference is explicitly unresolved
under a reusable rule. Intersection does not settle the disagreement.

Coverage reports count these decisions and missing identities. Agreement counts
separate matching nonempty label sets from matching empty sets; the latter
record mutual non-evidence. They do not
measure semantic accuracy, generalization, protocol fidelity or kernel adequacy.
No unit in this corpus is an untouched holdout.

Native review also challenged the agreed Liquity V1 `liquidation` label as
insufficiently grounded in child-specific text. It remains an observed model
agreement, with an open source-evidence challenge recorded in the sprint review;
it must not be treated as a verified mechanism classification.

## Provenance boundaries

`inputs/source-manifest.json` binds the three historical files and preserves
their own source statements. Their August 2026 rankings and narrative claims
are not newly fetched, re-ranked or certified by this sprint.

`sources/primary-excerpts.json` records a separate September retrieval of limited
primary documentation excerpts and response fingerprints. These corroborate
named version/product distinctions only. They are not inputs to the historical
blind coding and do not supply deployment addresses or code revisions. Full HTTP
responses were retained in a temporary local capture; the durable artifact is
the excerpt and response fingerprint, not a complete archived page.

The captured V1 page URL and the V2 excerpt provide the version naming; the
retained V1 excerpt itself is unversioned. The official [Liquity V1 documentation](https://docs.liquity.org/liquity-v1) and
[Liquity V2 documentation](https://docs.liquity.org/) distinguish those versions.
[Ondo's documentation](https://docs.ondo.finance/) distinguishes USDY and OUSG.
Its current navigation uses Ondo Stocks; this reconstruction retains the legacy
Global Markets label without asserting a rename or deployment equivalence.

Further source acquisition must resolve deployments, remaining bundled products,
classification disagreements and protocol-dependency edges before this can serve
as a deployment benchmark. See the [sprint design](../../docs/superpowers/specs/2026-09-06-corpus-provenance-design.md)
for acceptance scope and the [migration ledger](../../docs/research/semantic-kernel-progress.md)
for verification and review results.
