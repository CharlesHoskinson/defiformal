import fs from 'node:fs';
import path from 'node:path';
import { admissible, ELEMENTS, fireableLaws, parsedLaws } from './model.mjs';

const lanesDirectory = '/root/DefiElements/corpus50/lanes';
const negativePath = '/root/DefiElements/algebra/negative-corpus.json';
const outputPath = '/root/DefiElements/algebra/solvers/GP-LOG/calibration-results.json';
const families = ['KNOCKOUT', 'ARMED', 'INVERTED', 'HYBRID', 'RANDOM'];

const realProtocols = [];
for (const filename of fs.readdirSync(lanesDirectory).filter((name) => name.endsWith('.json')).sort()) {
  const lane = JSON.parse(fs.readFileSync(path.join(lanesDirectory, filename), 'utf8'));
  for (const category of lane.categories) {
    for (const protocol of category.protocols) {
      realProtocols.push({ name: protocol.name, symbols: [...new Set(protocol.elements)] });
    }
  }
}
if (realProtocols.length !== 72) {
  throw new Error(`Expected 72 REAL protocols, found ${realProtocols.length}`);
}

const negativeCases = JSON.parse(fs.readFileSync(negativePath, 'utf8')).cases;
if (!Array.isArray(negativeCases) || negativeCases.length !== 84) {
  throw new Error(`Expected 84 negative-corpus cases, found ${negativeCases?.length}`);
}

function acceptance(items, symbolsOf) {
  const acceptCount = items.filter((item) => admissible(symbolsOf(item)).ok).length;
  return { acceptCount, total: items.length, acceptRate: acceptCount / items.length };
}

const real = acceptance(realProtocols, ({ symbols }) => symbols);
const perFamily = Object.fromEntries(
  families.map((family) => {
    const cases = negativeCases.filter((entry) => entry.family === family);
    return [family, acceptance(cases, ({ syms }) => syms)];
  }),
);
const allSynthetic = acceptance(negativeCases, ({ syms }) => syms);

const nonHornTerms = [];
let hornCount = 0;
for (const law of fireableLaws) {
  for (const term of law.terms) {
    if (term.external) continue;
    if (term.alts.length <= 1) {
      hornCount += 1;
    } else {
      nonHornTerms.push({ lawId: law.id, alts: term.alts });
    }
  }
}

function lawIdOrder(a, b) {
  return Number(a.slice(1)) - Number(b.slice(1));
}

const profiles = ELEMENTS.map((element) => {
  const subjectOf = parsedLaws
    .filter(({ subjects }) => subjects.includes(element))
    .map(({ id }) => id)
    .sort(lawIdOrder);
  const altOf = parsedLaws
    .filter(({ terms }) => terms.some(({ alts }) => alts.includes(element)))
    .map(({ id }) => id)
    .sort(lawIdOrder);
  return { element, subjectOf, altOf };
});

const profileGroups = new Map();
for (const profile of profiles) {
  const key = JSON.stringify([profile.subjectOf, profile.altOf]);
  const group = profileGroups.get(key) ?? {
    elements: [],
    subjectOf: profile.subjectOf,
    altOf: profile.altOf,
  };
  group.elements.push(profile.element);
  profileGroups.set(key, group);
}
const redundantProfiles = [...profileGroups.values()].filter(({ elements }) => elements.length > 1);

const results = {
  assertedCounts: {
    realProtocols: realProtocols.length,
    negativeCases: negativeCases.length,
  },
  acceptance: {
    REAL: real,
    perFamily,
    ALL_SYNTHETIC: allSynthetic,
    discriminationRatio: real.acceptRate / allSynthetic.acceptRate,
  },
  hornClassification: {
    hornCount,
    nonHornCount: nonHornTerms.length,
    nonHornTerms,
  },
  redundancyProfiles: redundantProfiles,
};

const formatted = `${JSON.stringify(results, null, 2)}\n`;
fs.writeFileSync(outputPath, formatted);
process.stdout.write(formatted);
