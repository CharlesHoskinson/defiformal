/* Score council verdicts against the held key.
 *
 * The headline number is the discrimination ratio: acceptance on REAL divided
 * by acceptance on RANDOM. An algebra that accepts everything scores 1.0 and
 * fails no matter how elegant it is. Our own closure predicate scores 3.3.
 *
 * KNOCKOUT is graded separately and strictly: those cases differ from a working
 * protocol by exactly one symbol - the sole satisfier of a fired requirement -
 * so anything below 100% rejection there is not reading the laws at all.
 */
import fs from "node:fs";
const A = "/root/DefiElements/algebra";

const key = new Map(
  JSON.parse(fs.readFileSync(`${A}/blind-test-KEY.json`, "utf8")).key.map((k) => [k.id, k])
);

const FAMS = ["REAL", "KNOCKOUT", "ARMED", "INVERTED", "HYBRID", "RANDOM"];
const rows = [];

for (const f of fs.readdirSync(`${A}/verdicts`).filter((f) => f.endsWith(".json")).sort()) {
  const id = f.replace(/\.json$/, "");
  let raw;
  try { raw = JSON.parse(fs.readFileSync(`${A}/verdicts/${f}`, "utf8")); }
  catch (e) { rows.push({ id, error: `unparseable: ${e.message}` }); continue; }

  // accept a few shapes rather than failing a model on packaging
  const list = Array.isArray(raw) ? raw : raw.verdicts ?? raw.cases ?? raw.results;
  if (!Array.isArray(list)) { rows.push({ id, error: "no verdict array found" }); continue; }

  const seen = new Map();
  for (const v of list) {
    const cid = v.id ?? v.case ?? v.caseId;
    const val = String(v.verdict ?? v.result ?? v.label ?? "").toUpperCase();
    if (cid) seen.set(cid, val.startsWith("A") ? "A" : "I");
  }

  const tally = Object.fromEntries(FAMS.map((k) => [k, { n: 0, acc: 0 }]));
  let missing = 0;
  for (const [cid, k] of key) {
    const v = seen.get(cid);
    if (!v) { missing++; continue; }
    const t = tally[k.label];
    if (!t) continue;
    t.n++;
    if (v === "A") t.acc++;
  }

  const rate = (k) => (tally[k].n ? tally[k].acc / tally[k].n : NaN);
  const real = rate("REAL"), rand = rate("RANDOM");
  rows.push({
    id,
    answered: seen.size,
    missing,
    real, rand,
    ratio: rand > 0 ? real / rand : (real > 0 ? Infinity : NaN),
    knockoutRej: 1 - rate("KNOCKOUT"),
    hybrid: rate("HYBRID"),
    armedRej: 1 - rate("ARMED"),
    invRej: 1 - rate("INVERTED"),
  });
}

const pc = (x) => (Number.isNaN(x) ? "  --" : `${Math.round(x * 100)}%`.padStart(4));
console.log("model      ans  miss | REAL  RAND  ratio | KO-rej ARM-rej INV-rej HYBRID");
console.log("-".repeat(76));
console.log(`${"[baseline]".padEnd(10)}  --    -- | ${pc(0.5)} ${pc(0.15)}   3.3x |  100%   ---     ---   ${pc(0.42)}`);
for (const r of rows) {
  if (r.error) { console.log(`${r.id.padEnd(10)} ERROR: ${r.error}`); continue; }
  const ratio = Number.isFinite(r.ratio) ? `${r.ratio.toFixed(1)}x`.padStart(5)
              : (r.ratio === Infinity ? "  inf" : "   --");
  console.log(
    `${r.id.padEnd(10)} ${String(r.answered).padStart(3)} ${String(r.missing).padStart(5)} | ` +
    `${pc(r.real)} ${pc(r.rand)} ${ratio} |  ${pc(r.knockoutRej)}   ${pc(r.armedRej)}    ${pc(r.invRej)}   ${pc(r.hybrid)}`
  );
}
console.log("-".repeat(76));
console.log("ratio = accept(REAL)/accept(RANDOM). 1.0x = accepts everything, no discriminating power.");
console.log("KO-rej below 100% means the model is not reading the laws: knockouts differ from a");
console.log("working protocol by one symbol - the sole satisfier of a fired requirement term.");
