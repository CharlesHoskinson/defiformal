import assert from "node:assert/strict";
import {
  analyzeFiniteOrder,
  closureResult,
  extractHazardProjection,
  parseOperationalLaws,
} from "./analyze.mjs";

const elements = ["A", "B", "C", "D", "E"].map((sym) => ({ sym }));

const parsed = parseOperationalLaws(elements, [
  { id: "L1", rule: "(A|B) → (C|D) + E + prose", async: "yes" },
  { id: "L2", rule: "A + B → C", async: "no" },
]);

assert.deepEqual(parsed[0].subjects, ["A", "B"]);
assert.deepEqual(parsed[0].terms.map((term) => term.alternatives), [["C", "D"], ["E"], []]);
assert.equal(parsed[0].externalTerms, 1);
assert.equal(parsed[1].unsupportedSubject, true);

assert.equal(closureResult(new Set(["A", "C", "E"]), parsed).ok, true);
assert.equal(closureResult(new Set(["A", "D"]), parsed).ok, false);

const negative = extractHazardProjection(
  { id: "X", combo: "Aa with no Bb", cls: "F" },
  new Set(["Aa", "Bb"]),
);
assert.deepEqual(negative.elements, ["Aa", "Bb"]);
assert.equal(negative.hasNegativePolarity, true);

const disjunctiveLaws = parseOperationalLaws(elements, [
  { id: "L", rule: "A → B | C", async: "yes" },
]);
const order = analyzeFiniteOrder(["A", "B", "C"], disjunctiveLaws, []);
assert.equal(order.closureUnionClosed, true);
assert.deepEqual(order.intersectionFailure, {
  left: ["A", "B"],
  right: ["A", "C"],
  intersection: ["A"],
});

console.log("analyze_test: all assertions passed");
