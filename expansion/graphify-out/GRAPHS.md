# The graphs in this directory

Two files sit here and they are easy to confuse. One of them is not what its
name suggests.

## `merged-graph.json` — 709 nodes, 618 links

The twelve per-lane graphs (`expansion/<slug>/graphify-out/graph.json`) unioned
by `graphify merge-graphs`. Node counts and link counts are the exact sums of
the parts, because that is all the merge does.

**It contains zero cross-lane links.** Every one of its 100 connected components
lies inside a single lane; the largest has 47 nodes. `merge-graphs` namespaces
each node by its lane (`09-rwa::raw_ondo_2_design`), so a concept appearing in
two lanes becomes two unrelated nodes. The file is twelve graphs in one
envelope, useful for searching all lanes at once and for nothing else.

Do not cite it as evidence that categories share structure. It cannot witness
that, by construction.

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
pair shares nothing.** Forty of the 53 carried elements appear in more than one
category.

The elements that span the most categories:

| | | categories |
|---|---|---|
| `Up` | mutable implementation proxy | 12 of 12 |
| `Fd` | surplus and fee distribution | 11 |
| `Gp` | guardian or pause | 11 |
| `Sh` | pro-rata share accounting | 10 |
| `Xf` | cross-domain asset transfer | 10 |
| `Aw` | permission / identity gate | 10 |

By degree the god-nodes are `Gp` and `Aw` at 94 each, then `Sh` 76, `Up` 66,
`Fd` and `Ex` 58. Every one is an element; the highest-degree protocol reaches
43. That ordering is the graph restating the paper's central claim — the
elements, not the applications, are what the categories have in common.

One measurement that reads as a defect and is not: **0 of 1257 distinct
obligation texts recur across categories.** Obligations are keyed per protocol
(`obligation:Curve:F1`), so identical requirements in two categories are
distinct nodes by construction. Sharing is only observable at the element layer,
which is the layer that carries meaning.

## Known thin spots

Reported rather than papered over:

- `03-cdp-stablecoins` is the smallest lane graph at **32 nodes / 20 links**,
  against a median near 50, on the same three research documents other lanes
  have. Its ingest is complete; its graph is thinner than its siblings'.
- Isolated nodes concentrate in three lanes: `01-spot-exchange` 15 of 48 and
  `04-liquid-staking` 15 of 53, then `03-cdp-stablecoins` 5 and `12-prediction`
  4. The other eight lanes have none. 39 isolated nodes across 709.

These are limits of the local semantic pass, not of the ingest. No paper claim
depends on a lane graph: the article's figures come from `verdicts.json` through
`emit-tex.mjs`, and the cross-category claims come from `domain-graph.json`
above. The lane graphs are navigation.
