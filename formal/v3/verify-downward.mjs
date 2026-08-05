/* Separate the two things my first test conflated.
 *
 * The LISTED clutter is purely negative, so its model class must be downward
 * closed. The CONDITIONAL prohibitions carry negative literals in their
 * antecedents, so removing an element can arm one. Test each alone. */
import { armedListed, bansCond, MECH } from "/root/defiformal/formal/v2/tables.mjs";

const U = ["Fl","Cp","Cl","Pl","Cd","Im","Xf","Rl","Of","Oa","Li","Ex","Aw","At"];
const run = (name, pred) => {
  let models = 0, bad = 0, witness = null;
  for (let m = 0; m < (1 << U.length); m++) {
    const X = U.filter((_, i) => m & (1 << i));
    if (pred(new Set(X)).length) continue;
    models++;
    for (const e of X) {
      const Y = X.filter(x => x !== e);
      if (pred(new Set(Y)).length) { bad++; if (!witness) witness = [X, e, pred(new Set(Y))]; break; }
    }
  }
  console.log(`${name}`);
  console.log(`  models the predicate: ${models} of ${1 << U.length}`);
  console.log(`  of those, have a subset that does NOT: ${bad}`);
  if (witness) console.log(`  witness: {${witness[0].join(",")}} minus ${witness[1]} arms ${JSON.stringify(witness[2])}`);
};

run("LISTED clutter only (purely negative)", armedListed);
console.log();
run("ALL prohibitions, listed + conditional", bansCond);
