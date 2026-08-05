/* Invariant 5 is "cite or drop": every design claim about a live protocol
 * carries a URL and an access date. validate.mjs checks a URL is PRESENT.
 * Nothing has ever checked the citations are well formed, distinct, dated, or
 * that they point at primary sources. This does the local half.
 *
 *   node cites.mjs <expansion-root>            local audit
 *   node cites.mjs <expansion-root> --list N   emit N sampled URLs for a live check
 */
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2] || "/root/defiformal/expansion";
const URL_RE = /https?:\/\/[^\s)\]<>"']+/g;
const DATE_RE = /\b20\d{2}-\d{2}-\d{2}\b/;

const rows = [];
for (const slug of fs.readdirSync(root).filter(d => /^\d\d-/.test(d))) {
  const dir = path.join(root, slug, "specs");
  if (!fs.existsSync(dir)) continue;
  for (const f of fs.readdirSync(dir).filter(f => f.endsWith(".json"))) {
    const spec = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8"));
    for (const o of spec.functionalObligations || [])
      rows.push({ slug, app: spec.app, id: o.id, ev: o.evidence || "" });
  }
}

const urls = [], noUrl = [], noDate = [];
for (const r of rows) {
  const m = r.ev.match(URL_RE);
  if (!m) { noUrl.push(r); continue; }
  if (!DATE_RE.test(r.ev)) noDate.push(r);
  for (const u of m) urls.push({ ...r, url: u.replace(/[.,;]+$/, "") });
}

const uniq = new Map();
for (const u of urls) if (!uniq.has(u.url)) uniq.set(u.url, u);
const host = u => { try { return new URL(u).hostname.replace(/^www\./, ""); } catch { return "MALFORMED"; } };
const byHost = {};
for (const u of uniq.keys()) byHost[host(u)] = (byHost[host(u)] ?? 0) + 1;

if (process.argv.includes("--list")) {
  const n = +process.argv[process.argv.indexOf("--list") + 1] || 40;
  /* one URL per distinct host, so a sample covers the breadth of sources */
  const seen = new Set(), out = [];
  for (const u of uniq.keys()) { const h = host(u); if (seen.has(h)) continue; seen.add(h); out.push(u); if (out.length >= n) break; }
  console.log(out.join("\n"));
} else {
  console.log(`obligations:            ${rows.length}`);
  console.log(`obligations with a URL: ${rows.length - noUrl.length}`);
  console.log(`obligations with none:  ${noUrl.length}${noUrl.length ? "  <-- invariant 5 violation" : ""}`);
  for (const r of noUrl.slice(0, 8)) console.log(`   ${r.slug} ${r.app} ${r.id}`);
  console.log(`obligations with no access date: ${noDate.length}`);
  for (const r of noDate.slice(0, 8)) console.log(`   ${r.slug} ${r.app} ${r.id}: ${r.ev.slice(0, 90)}`);
  console.log(`\ncitation instances: ${urls.length}   distinct URLs: ${uniq.size}   distinct hosts: ${Object.keys(byHost).length}`);
  const mal = [...uniq.keys()].filter(u => host(u) === "MALFORMED");
  console.log(`malformed URLs: ${mal.length}`);
  for (const u of mal.slice(0, 5)) console.log(`   ${u}`);
  console.log(`\ntop sources:`);
  for (const [h, c] of Object.entries(byHost).sort((a, b) => b[1] - a[1]).slice(0, 14))
    console.log(`  ${String(c).padStart(4)}  ${h}`);
  const aggregators = ["defillama.com", "coingecko.com", "coinmarketcap.com", "dune.com", "medium.com", "twitter.com", "x.com"];
  const agg = Object.entries(byHost).filter(([h]) => aggregators.some(a => h.endsWith(a)));
  console.log(`\naggregator or social sources (the method prefers primary): ${agg.reduce((a, [, c]) => a + c, 0)} of ${uniq.size}`);
  for (const [h, c] of agg) console.log(`  ${String(c).padStart(4)}  ${h}`);
}
