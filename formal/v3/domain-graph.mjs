/* A knowledge graph of the SUBJECT, not of the documents.
 *
 * The merged graphify graph over the research prose is 539 nodes of which 360
 * edges are `contains` - document hierarchy - and whose most connected nodes
 * are section headings. Useful for navigation, useless as a model of DeFi.
 *
 * This builds the graph the project actually has evidence for, from the
 * obligation specs and the checker verdicts:
 *
 *   nodes    category, protocol, element, obligation
 *   edges    category --has--> protocol
 *            protocol --carries--> element        (its construction)
 *            protocol --owes--> obligation
 *            obligation --dischargedBy--> element (the elements that satisfy it)
 *            obligation --residue--> (none)       marked on the node
 *            element --group--> (on the node)
 *
 * Emitted in graphify's own shape (nodes/links, directed) so every graphify
 * query, path, explain and god-nodes command works on it.
 */
import fs from "node:fs";
import path from "node:path";
import { ELEMS, MECH } from "../v2/tables.mjs";

const root = process.argv[2] || "/root/defiformal/expansion";
const out = process.argv[3] || path.join(root, "graphify-out/domain-graph.json");

const nodes = new Map(), links = [];
const add = (id, attrs) => { if (!nodes.has(id)) nodes.set(id, { id, ...attrs }); return id; };
const link = (source, target, relation) => links.push({ source, target, relation });

for (const s of MECH)
  add(`element:${s}`, { label: s, kind: "element", name: ELEMS[s].name,
    group: ELEMS[s].group, stratum: ELEMS[s].stratum, status: ELEMS[s].status });

let nres = 0, nobl = 0, nproto = 0;
for (const slug of fs.readdirSync(root).filter(d => /^\d\d-/.test(d))) {
  const specDir = path.join(root, slug, "specs");
  if (!fs.existsSync(specDir)) continue;
  const cat = add(`category:${slug}`, { label: slug, kind: "category" });

  for (const f of fs.readdirSync(specDir).filter(f => f.endsWith(".json"))) {
    const spec = JSON.parse(fs.readFileSync(path.join(specDir, f), "utf8"));
    const pid = add(`protocol:${spec.app}`, { label: spec.app, kind: "protocol", category: slug });
    nproto++;
    link(cat, pid, "has");
    for (const e of spec.construction || []) link(pid, `element:${e}`, "carries");

    for (const o of spec.functionalObligations || []) {
      const els = (o.elements || []).filter(e => MECH.includes(e));
      const oid = add(`obligation:${spec.app}:${o.id}`, {
        label: `${o.id} ${String(o.text).slice(0, 70)}`, kind: "obligation",
        protocol: spec.app, category: slug, residue: els.length === 0,
        text: o.text, evidence: o.evidence || "", note: o.note || "" });
      nobl++;
      if (!els.length) nres++;
      link(pid, oid, "owes");
      for (const e of els) link(oid, `element:${e}`, "dischargedBy");
    }
  }
}

const g = { directed: true, multigraph: false, graph: {}, nodes: [...nodes.values()], links,
  hyperedges: [], built_at_commit: "domain-graph.mjs" };
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify(g, null, 1));

console.log(`wrote ${out}`);
console.log(`  nodes ${g.nodes.length}  links ${links.length}`);
console.log(`  protocols ${nproto}, obligations ${nobl} of which residue ${nres}, elements ${MECH.length}`);

/* the questions this graph can answer that the prose graph cannot */
const deg = new Map();
for (const l of links) for (const k of [l.source, l.target]) deg.set(k, (deg.get(k) ?? 0) + 1);
const elemDeg = [...deg].filter(([k]) => k.startsWith("element:"))
  .sort((a, b) => b[1] - a[1]).slice(0, 12);
console.log(`\nmost load-bearing elements (by degree in the obligation graph):`);
for (const [k, d] of elemDeg) console.log(`  ${k.slice(8).padEnd(4)} ${String(d).padStart(3)}  ${ELEMS[k.slice(8)].name}`);

const unused = MECH.filter(s => !links.some(l => l.target === `element:${s}`));
console.log(`\nelements discharging no obligation anywhere in the checked corpus (${unused.length}):`);
console.log(`  ${unused.join(", ")}`);
