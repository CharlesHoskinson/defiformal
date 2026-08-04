import assert from "node:assert/strict";
import test from "node:test";

import { closes as referenceCloses } from "../viz/src/laws.ts";
import { PROTOCOLS } from "../viz/src/protocols.ts";

test("independent analyzer reproduces the reference closure engine", async () => {
  const model = await import("./.gp-ord-scratch.mjs");
  assert.equal(model.elements.length, 58);
  assert.equal(model.parsedLaws.filter((law) => law.subjects.length > 0).length, 25);
  for (const protocol of PROTOCOLS) {
    assert.equal(
      model.evaluateClosure(protocol.syms).ok,
      referenceCloses(protocol.syms).ok,
      protocol.id,
    );
  }
});

test("validity implements signature, corrected X11a, and atomic-scope rulings", async () => {
  const model = await import("./.gp-ord-scratch.mjs");
  assert.deepEqual(model.classify(["Ve"]).reasons.outOfSignature, ["Ve"]);
  assert.equal(model.classify(["Fl", "Xm"]).reasons.atomicScope, true);
  assert.equal(model.classify(["Au", "Gs"]).verdict, "ADMISSIBLE");
  assert.equal(model.classify(["Uc", "Aw", "At", "Bs"]).reasons.x11a, false);
  assert.equal(model.classify(["Uc"]).reasons.x11a, true);
});

test("full vocabulary is closed and blind set has exactly 156 unique cases", async () => {
  const model = await import("./.gp-ord-scratch.mjs");
  assert.equal(model.evaluateClosure(model.elements.map((element) => element.sym)).ok, true);
  const results = model.analyzeBlindSet();
  assert.equal(results.cases.length, 156);
  assert.equal(new Set(results.cases.map((entry) => entry.id)).size, 156);
});
