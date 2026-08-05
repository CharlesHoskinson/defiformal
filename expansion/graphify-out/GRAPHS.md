# The graphs in this directory

Two files sit here and they are easy to confuse. One of them is not what its
name suggests.

## `merged-graph.json` — 777 nodes, 684 links

The twelve per-lane graphs (`expansion/<slug>/graphify-out/graph.json`) unioned
by `graphify merge-graphs`. Node and link counts are the exact sums of the
parts, because that is all the merge does.

**It contains 0 cross-lane links.** Every one of its 102 connected components
lies inside a single lane; the largest has 47 nodes. `merge-graphs` namespaces
each node by its lane (`09-rwa::raw_ondo_2_design`), so a concept appearing in
two lanes becomes two unrelated nodes. The file is twelve graphs in one
envelope, useful for searching all lanes at once and for nothing else.

Do not cite it as evidence that categories share structure. It cannot witness
that, by construction.

| lane | nodes | links | isolated |
|---|---|---|---|
| `01-spot-exchange` | 48 | 25 | 15 |
| `02-lending` | 57 | 54 | 0 |
| `03-cdp-stablecoins` | 32 | 20 | 5 |
| `04-liquid-staking` | 53 | 29 | 15 |
| `05-perpetuals` | 84 | 80 | 0 |
| `06-yield-vaults` | 49 | 46 | 0 |
| `07-bridges` | 50 | 47 | 0 |
| `08-intents` | 50 | 47 | 0 |
| `09-rwa` | 163 | 157 | 0 |
| `10-options` | 50 | 47 | 0 |
| `11-fiat-stablecoins` | 88 | 84 | 0 |
| `12-prediction` | 53 | 48 | 4 |

## `domain-graph.json` — 1389 nodes, 2601 links

This is the cross-category graph. It is built from `verdicts.json`, not from
prose, so its edges are computed rather than inferred:

| kind | count | |
|---|---|---|
| `obligation` | 1259 | what an application must do |
| `protocol` | 60 | the applications |
| `element` | 58 | the algebra's generators |
| `category` | 12 | |

| relation | count | |
|---|---|---|
| `owes` | 1259 | protocol → obligation |
| `dischargedBy` | 697 | obligation → element |
| `carries` | 585 | protocol → element |
| `has` | 60 | category → protocol |

Categories are joined through the elements their protocols carry, and the
joining is total: **all 66 category pairs share at least one element, and no
pair shares nothing.** 40 of the 53 carried elements appear in more than one
category.

The elements that span the most categories:

| | | categories |
|---|---|---|
| `Up` | mutable implementation proxy | 12 of 12 |
| `Fd` | surplus & fee distribution | 11 of 12 |
| `Gp` | guardian or pause | 11 of 12 |
| `Sh` | pro-rata share accounting | 10 of 12 |
| `Xf` | cross-domain asset transfer | 10 of 12 |
| `Aw` | permission / identity gate | 10 of 12 |

By degree the god-nodes are all elements:

| element | degree |
|---|---|
| `Gp` | 94 |
| `Aw` | 94 |
| `Sh` | 76 |
| `Up` | 66 |
| `Fd` | 58 |
| `Ex` | 58 |

The highest-degree protocol reaches 43. That ordering is the graph restating the
paper's central claim — the elements, not the applications, are what the
categories have in common.

One measurement that reads as a defect and is not: **0 of 1257 distinct
obligation texts recur across categories.** Obligations are keyed per protocol
(`obligation:Curve:F1`), so identical requirements in two categories are
distinct nodes by construction. Sharing is only observable at the element layer,
which is the layer that carries meaning.

## Two kinds of graph, and why node counts do not compare

The lanes do not all hold the same kind of graph, and this matters more than any
count here.

Most lanes hold a **structural** graph: the AST pass emits one node per heading,
disambiguated by line number, so `07-bridges` carries nodes named
`01_research_1_what_it_does_218`. The names mean nothing; the shape is the
document's.

`03-cdp-stablecoins` holds a **semantic** graph: its nodes are `sky_lending`,
`mcd_vat`, `mcd_dog`, `mcd_clipper`, `usde_token`, `liquity_v2`, `lista_cdp` —
named entities from the domain rather than positions in a file.

So 03 has the fewest nodes of any lane, 32, over a research document with 37
headings of which only 13 are distinct — the five applications reuse the same
six sub-headings. `07-bridges` has a document of exactly the same shape (37
headings, 13 distinct, same levels) and yields 50 nodes. The difference is
which pass won, not how well the lane was researched. **Comparing node counts
across the two kinds is meaningless, and calling 03 thin on that basis was
wrong.**

## Known thin spots

Reported rather than papered over: isolated nodes concentrate in
`01-spot-exchange` 15, `04-liquid-staking` 15, `03-cdp-stablecoins` 5, `12-prediction` 4, while the other
8 lanes have none — 39 isolated nodes across 777.

No paper claim depends on a lane graph: the article's figures come from
`verdicts.json` through `emit-tex.mjs`, and the cross-category claims come from
`domain-graph.json` above. The lane graphs are navigation.

## Which graph covers which files

Every source file under a lane is indexed by exactly one of the two graphs,
and the split is not obvious from either one alone.

**The lane graphs index prose only** — research documents, section briefs and
section notes. Across all twelve lanes they contain **zero** nodes drawn from
a spec. `graphify` tracks the spec files in nine of the twelve manifests and
extracts no nodes from them; in the other three it does not track them at all.
That manifest inconsistency is cosmetic — the graphs are uniform.

**The domain graph indexes structure only** — all 60 specs, one protocol node
each, with their 1,259 obligations, the 58 elements and the 12 categories.

So comparing the specs on disk against the lane graphs shows 60 files
apparently missing, and they are not missing.
`formal/v3/lane-coverage.py` checks both halves and says so in one line,
precisely so that this reading is not made twice.

One measurement that is **not** worth pursuing: `graphify-out/manifest.json`
records a per-file `mtime` and `ast_hash`. The hash is over the extracted
AST, not the file bytes, so it cannot be recomputed without running the
extractor, and `mtime` does not survive a fresh clone. A staleness check
built on either is noise; `lane-coverage.py` is the check that holds.
