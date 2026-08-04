const toSet = (value) => value instanceof Set ? value : new Set(value);

const bare = (text) => text
  .replace(/\{[^}]*\}/g, "")
  .replace(/[()]/g, "")
  .trim();

const ordered = (set, universe) => universe.filter((element) => set.has(element));

const subsetOf = (left, right) => {
  for (const element of left) {
    if (!right.has(element)) return false;
  }
  return true;
};

const union = (left, right) => new Set([...left, ...right]);

const intersection = (left, right) =>
  new Set([...left].filter((element) => right.has(element)));

export function parseOperationalLaws(elements, sourceLaws) {
  const symbols = new Set(elements.map((element) => element.sym));

  return sourceLaws.map((source) => {
    const [left = "", right = ""] = source.rule.split("→");
    const subjects = left
      .split("|")
      .map(bare)
      .filter((symbol) => symbols.has(symbol));
    const terms = right.split("+").map((sourceTerm) => {
      const alternatives = sourceTerm
        .split("|")
        .map(bare)
        .filter((symbol) => symbols.has(symbol));
      const hasUnknownAlternative = sourceTerm
        .split("|")
        .map(bare)
        .some((symbol) => !symbols.has(symbol));

      return {
        source: sourceTerm.trim(),
        alternatives,
        external: alternatives.length === 0,
        mixed: alternatives.length > 0 && hasUnknownAlternative,
      };
    });

    return {
      id: source.id,
      rule: source.rule,
      async: source.async,
      subjects,
      subjectSource: left.trim(),
      terms,
      externalTerms: terms.filter((term) => term.external).length,
      mixedTerms: terms.filter((term) => term.mixed).length,
      unsupportedSubject: subjects.length === 0,
    };
  });
}

export function closureResult(protocolValue, parsedLaws) {
  const protocol = toSet(protocolValue);
  const fired = [];

  for (const law of parsedLaws) {
    const firedBy = law.subjects.filter((subject) => protocol.has(subject));
    if (firedBy.length === 0) continue;

    const missing = law.terms
      .filter((term) => !term.external)
      .filter((term) => !term.alternatives.some((alternative) => protocol.has(alternative)));
    fired.push({
      id: law.id,
      firedBy,
      missing: missing.map((term) => ({
        source: term.source,
        alternatives: term.alternatives,
      })),
      satisfied: missing.length === 0,
    });
  }

  return {
    ok: fired.every((law) => law.satisfied),
    fired,
    violated: fired.filter((law) => !law.satisfied),
  };
}

export function extractHazardProjection(source, symbols) {
  const elements = [...new Set(
    (source.combo.match(/\b[A-Z][a-z]{1,2}\b/g) ?? [])
      .filter((symbol) => symbols.has(symbol)),
  )];

  return {
    id: source.id,
    family: source.id.replace(/[ab]$/, ""),
    combo: source.combo,
    cls: source.cls,
    elements,
    projectionEligible: elements.length >= 2,
    hasNegativePolarity: /\b(no|without|absent|missing)\b/i.test(source.combo),
  };
}

export function enumerateSubsets(universe) {
  if (universe.length > 20) {
    throw new Error(`Refusing to enumerate 2^${universe.length} subsets`);
  }

  const count = 2 ** universe.length;
  const subsets = [];
  for (let mask = 0; mask < count; mask += 1) {
    const set = new Set();
    for (let bit = 0; bit < universe.length; bit += 1) {
      if ((mask & (2 ** bit)) !== 0) set.add(universe[bit]);
    }
    subsets.push(set);
  }
  return subsets;
}

export function hazardFreeProjection(protocolValue, hazardProjections) {
  const protocol = toSet(protocolValue);
  return hazardProjections
    .filter((hazard) => hazard.projectionEligible)
    .every((hazard) => !subsetOf(new Set(hazard.elements), protocol));
}

const firstPair = (models, predicate) => {
  for (let leftIndex = 0; leftIndex < models.length; leftIndex += 1) {
    for (let rightIndex = leftIndex + 1; rightIndex < models.length; rightIndex += 1) {
      const result = predicate(models[leftIndex], models[rightIndex]);
      if (result) return result;
    }
  }
  return null;
};

const minimalContaining = (models, element, universe) => {
  const containing = models.filter((model) => model.has(element));
  return containing
    .filter((candidate) => !containing.some((other) =>
      other.size < candidate.size && subsetOf(other, candidate)))
    .map((model) => ordered(model, universe));
};

export function analyzeFiniteOrder(universe, parsedLaws, hazardProjections) {
  const subsets = enumerateSubsets(universe);
  const closureModels = subsets.filter((set) => closureResult(set, parsedLaws).ok);
  const safeModels = closureModels.filter((set) =>
    hazardFreeProjection(set, hazardProjections));

  const unionFailure = firstPair(closureModels, (left, right) => {
    const joined = union(left, right);
    if (closureResult(joined, parsedLaws).ok) return null;
    return {
      left: ordered(left, universe),
      right: ordered(right, universe),
      union: ordered(joined, universe),
    };
  });

  const intersectionFailure = firstPair(closureModels, (left, right) => {
    const met = intersection(left, right);
    if (closureResult(met, parsedLaws).ok) return null;
    return {
      left: ordered(left, universe),
      right: ordered(right, universe),
      intersection: ordered(met, universe),
    };
  });

  const safeJoinFailure = firstPair(safeModels, (left, right) => {
    const joined = union(left, right);
    const armed = hazardProjections
      .filter((hazard) => hazard.projectionEligible)
      .filter((hazard) => subsetOf(new Set(hazard.elements), joined));
    if (armed.length === 0) return null;
    return {
      left: ordered(left, universe),
      right: ordered(right, universe),
      union: ordered(joined, universe),
      armedHazards: armed.map((hazard) => hazard.id),
    };
  });

  return {
    universe,
    totalSubsets: subsets.length,
    closureModelCount: closureModels.length,
    safeModelCount: safeModels.length,
    closureUnionClosed: unionFailure === null,
    closureFormsFiniteLattice: unionFailure === null,
    unionFailure,
    intersectionFailure,
    safeFormsFiniteLattice: safeJoinFailure === null,
    safeJoinFailure,
    minimalClosureByElement: Object.fromEntries(
      universe.map((element) => [element, minimalContaining(closureModels, element, universe)]),
    ),
    minimalSafeByElement: Object.fromEntries(
      universe.map((element) => [element, minimalContaining(safeModels, element, universe)]),
    ),
    closureModels,
    safeModels,
  };
}

function rankFor(symbol, termsBySubject, mode, memo, visiting) {
  if (memo.has(symbol)) return memo.get(symbol);
  if (visiting.has(symbol)) return null;

  visiting.add(symbol);
  const terms = termsBySubject.get(symbol) ?? [];
  if (terms.length === 0) {
    visiting.delete(symbol);
    memo.set(symbol, 0);
    return 0;
  }

  const termRanks = [];
  for (const alternatives of terms) {
    const alternativeRanks = alternatives.map((alternative) =>
      rankFor(alternative, termsBySubject, mode, memo, visiting));
    if (alternativeRanks.some((rank) => rank === null)) {
      visiting.delete(symbol);
      memo.set(symbol, null);
      return null;
    }
    termRanks.push(mode === "choice"
      ? Math.min(...alternativeRanks)
      : Math.max(...alternativeRanks));
  }

  visiting.delete(symbol);
  const rank = 1 + Math.max(...termRanks);
  memo.set(symbol, rank);
  return rank;
}

export function analyzeRanks(elements, parsedLaws) {
  const termsBySubject = new Map(elements.map((element) => [element.sym, []]));
  for (const law of parsedLaws) {
    const internalTerms = law.terms
      .filter((term) => !term.external)
      .map((term) => term.alternatives);
    for (const subject of law.subjects) {
      termsBySubject.set(subject, [
        ...(termsBySubject.get(subject) ?? []),
        ...internalTerms,
      ]);
    }
  }

  const choiceMemo = new Map();
  const strictMemo = new Map();
  const rows = elements.map((element) => {
    const choiceRank = rankFor(element.sym, termsBySubject, "choice", choiceMemo, new Set());
    const strictRank = rankFor(element.sym, termsBySubject, "strict", strictMemo, new Set());
    return {
      symbol: element.sym,
      handStratum: element.stratum,
      choiceRank,
      strictRank,
      choiceMatches: choiceRank === element.stratum,
      strictMatches: strictRank === element.stratum,
    };
  });

  const attributes = new Map(elements.map((element) => [element.sym, element]));
  const deeperDependencies = [];
  for (const law of parsedLaws) {
    for (const subject of law.subjects) {
      for (const term of law.terms.filter((candidate) => !candidate.external)) {
        for (const required of term.alternatives) {
          if (attributes.get(required).stratum > attributes.get(subject).stratum) {
            deeperDependencies.push({
              law: law.id,
              subject,
              subjectStratum: attributes.get(subject).stratum,
              required,
              requiredStratum: attributes.get(required).stratum,
            });
          }
        }
      }
    }
  }

  return {
    rows,
    choiceMatchCount: rows.filter((row) => row.choiceMatches).length,
    strictMatchCount: rows.filter((row) => row.strictMatches).length,
    choiceDisagreements: rows.filter((row) => !row.choiceMatches),
    strictDisagreements: rows.filter((row) => !row.strictMatches),
    deeperDependencies,
    hasCycle: rows.some((row) => row.choiceRank === null || row.strictRank === null),
  };
}

const requirementsFullyExpressible = (protocol, parsedLaws) => {
  const fired = parsedLaws.filter((law) =>
    law.subjects.some((subject) => protocol.has(subject)));
  return fired.every((law) => law.externalTerms === 0 && law.mixedTerms === 0);
};

const atomicScopeConsistent = (protocol, attributes) => {
  const hasCrossDomain = [...protocol].some((symbol) => attributes.get(symbol).group === "G12");
  return !(protocol.has("Fl") && hasCrossDomain);
};

const stratumMonotone = (protocol, parsedLaws, attributes) =>
  parsedLaws.every((law) => law.subjects
    .filter((subject) => protocol.has(subject))
    .every((subject) => law.terms
      .filter((term) => !term.external)
      .every((term) => term.alternatives
        .filter((required) => protocol.has(required))
        .some((required) =>
          attributes.get(required).stratum <= attributes.get(subject).stratum))));

const minimalViolations = (models, predicate, universe) => {
  const violations = models.filter((model) => !predicate(model));
  return violations
    .filter((candidate) => !violations.some((other) =>
      other.size < candidate.size && subsetOf(other, candidate)))
    .map((model) => ordered(model, universe));
};

export async function runAtlasAnalysis() {
  const data = await import(new URL("../viz/src/data.ts", import.meta.url));
  const protocolSource = await import(new URL("../viz/src/protocols.ts", import.meta.url));
  const mechanisms = data.ELEMENTS.filter((element) => element.status !== "limit");
  const symbols = new Set(mechanisms.map((element) => element.sym));
  const parsedLaws = parseOperationalLaws(mechanisms, data.LAWS);
  const hazardProjections = data.HAZARDS.map((hazard) =>
    extractHazardProjection(hazard, symbols));

  const protocolClosure = protocolSource.PROTOCOLS.map((protocol) => {
    const result = closureResult(new Set(protocol.syms), parsedLaws);
    return {
      id: protocol.id,
      name: protocol.name,
      dead: Boolean(protocol.dead),
      closes: result.ok,
      violations: result.violated,
    };
  });

  const boundedUniverse = [
    "Fl", "Xm", "Xf", "Rl", "Of", "Bs",
    "Sl", "Au", "Gs", "Uc", "Aw", "At",
  ];
  const order = analyzeFiniteOrder(boundedUniverse, parsedLaws, hazardProjections);
  const attributes = new Map(mechanisms.map((element) => [element.sym, element]));

  const candidateViolations = {
    machineCheckability: minimalViolations(
      order.safeModels,
      (protocol) => requirementsFullyExpressible(protocol, parsedLaws),
      boundedUniverse,
    ),
    atomicScope: minimalViolations(
      order.safeModels,
      (protocol) => atomicScopeConsistent(protocol, attributes),
      boundedUniverse,
    ),
    stratumMonotonicity: minimalViolations(
      order.safeModels,
      (protocol) => stratumMonotone(protocol, parsedLaws, attributes),
      boundedUniverse,
    ),
  };

  return {
    sourceCounts: {
      elementRows: data.ELEMENTS.length,
      mechanismRows: mechanisms.length,
      limitRows: data.ELEMENTS.filter((element) => element.status === "limit").length,
      lawRows: data.LAWS.length,
      executableLawRows: parsedLaws.filter((law) => !law.unsupportedSubject).length,
      internalLawTerms: parsedLaws.reduce((sum, law) =>
        sum + law.terms.filter((term) => !term.external).length, 0),
      externalLawTerms: parsedLaws.reduce((sum, law) => sum + law.externalTerms, 0),
      mixedLawTerms: parsedLaws.reduce((sum, law) => sum + law.mixedTerms, 0),
      hazardRows: data.HAZARDS.length,
      hazardFamilies: new Set(hazardProjections.map((hazard) => hazard.family)).size,
      projectedHazardRows: hazardProjections.filter((hazard) => hazard.projectionEligible).length,
      protocolRows: protocolSource.PROTOCOLS.length,
      deadProtocolRows: protocolSource.PROTOCOLS.filter((protocol) => protocol.dead).length,
    },
    unsupportedLaws: parsedLaws
      .filter((law) => law.unsupportedSubject)
      .map((law) => ({ id: law.id, subject: law.subjectSource })),
    negativeProjectedHazards: hazardProjections
      .filter((hazard) => hazard.projectionEligible && hazard.hasNegativePolarity)
      .map((hazard) => ({ id: hazard.id, elements: hazard.elements, combo: hazard.combo })),
    protocolClosure,
    ranks: analyzeRanks(mechanisms, parsedLaws),
    boundedSearch: {
      universe: boundedUniverse,
      totalSubsets: order.totalSubsets,
      closureModelCount: order.closureModelCount,
      safeModelCount: order.safeModelCount,
      closureUnionClosed: order.closureUnionClosed,
      closureFormsFiniteLattice: order.closureFormsFiniteLattice,
      intersectionFailure: order.intersectionFailure,
      safeFormsFiniteLattice: order.safeFormsFiniteLattice,
      safeJoinFailure: order.safeJoinFailure,
      minimalClosureByElement: order.minimalClosureByElement,
      minimalSafeByElement: order.minimalSafeByElement,
      candidateViolations,
    },
  };
}

if (process.argv[1]?.endsWith("analyze.mjs")) {
  const result = await runAtlasAnalysis();
  console.log(JSON.stringify(result, null, 2));
}
