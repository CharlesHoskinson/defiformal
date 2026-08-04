import fs from 'node:fs';
import { admissible } from './model.mjs';

const inputPath = '/root/DefiElements/algebra/blind-test-set.json';
const outputPath = '/root/DefiElements/algebra/verdicts/GP-LOG.json';
const input = JSON.parse(fs.readFileSync(inputPath, 'utf8'));

if (!Array.isArray(input.cases) || input.cases.length !== 156) {
  throw new Error(`Expected 156 blind cases, found ${input.cases?.length}`);
}

const verdicts = input.cases.map(({ id, elements }) => ({
  id,
  verdict: admissible(elements).ok ? 'ADMISSIBLE' : 'INADMISSIBLE',
}));

fs.writeFileSync(outputPath, `${JSON.stringify({ verdicts }, null, 2)}\n`);

const admissibleCount = verdicts.filter(({ verdict }) => verdict === 'ADMISSIBLE').length;
const inadmissibleCount = verdicts.length - admissibleCount;
console.log(`ADMISSIBLE: ${admissibleCount} out of ${verdicts.length}`);
console.log(`INADMISSIBLE: ${inadmissibleCount} out of ${verdicts.length}`);
