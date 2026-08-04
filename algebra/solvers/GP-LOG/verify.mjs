import assert from 'node:assert/strict';
import fs from 'node:fs';

const { verdicts } = JSON.parse(
  fs.readFileSync('/root/DefiElements/algebra/verdicts/GP-LOG.json', 'utf8'),
);
assert.equal(verdicts.length, 156);
console.log(`OK ${verdicts.length}`);
