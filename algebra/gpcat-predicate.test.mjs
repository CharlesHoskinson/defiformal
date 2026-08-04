import assert from "node:assert/strict";

import {
  MECHANISMS,
  classify,
  evaluateSupport,
} from "./gpcat-predicate.mjs";

assert.equal(MECHANISMS.size, 58, "the carrier has exactly 58 mechanisms");

const admissible = [
  [],
  ["Ag"],
  ["Pl", "Sh", "Ex", "Ct", "Li"],
  ["Of", "Xm", "Xf", "Bs"],
];
for (const elements of admissible) {
  assert.equal(classify(elements), "ADMISSIBLE", elements.join(","));
}

const inadmissible = [
  ["Pl"],                                      // missing law terms
  ["Of", "Xm", "Xf"],                      // missing Bs | Sl
  ["Xf", "Xm", "Aw"],                     // fixed X19 projection
  ["Uc", "Aw", "At", "Bs"],             // fixed X11a projection
  ["Fl", "Xm"],                             // cross-domain atomicity
  ["Fl", "Au", "Rl"],                    // cross-domain reservation
  ["Au", "Gs"],                             // L21 stratum erratum
  ["Ve"],                                      // contested, not a mechanism
];
for (const elements of inadmissible) {
  assert.equal(classify(elements), "INADMISSIBLE", elements.join(","));
}

const pl = evaluateSupport(["Pl"]);
assert.deepEqual(pl.openLaws.map(({ id }) => id), ["L1", "L2"]);
assert.deepEqual(pl.unknown, []);

const duplicateSet = evaluateSupport(["Ag", "Ag"]);
assert.equal(duplicateSet.ok, true, "support semantics is idempotent");

console.log("gpcat predicate tests: PASS");
