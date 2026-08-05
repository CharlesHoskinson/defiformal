// prop:mixed gives the criterion for "neither Horn nor dual-Horn" as "two or
// more negative literals". That is the criterion for failing DUAL-Horn. Failing
// Horn needs two or more POSITIVE literals.
//
//   Horn      : at most one positive literal
//   dual-Horn : at most one negative literal
//
// Count both for every conditional row, from the negated clauses the paper
// itself prints in m4-oplus.
const ROWS = {
  "X2":    { clause: "!Fl v !c v !d",                    neg: 3, pos: 0 },
  "X21":   { clause: "!Fl v !Xf",                        neg: 2, pos: 0 },
  "X11a*": { clause: "!Uc v Aw   (and !Uc v At)",        neg: 1, pos: 1 },
  "X18":   { clause: "!Oa v !Li v Ex v Tp",              neg: 2, pos: 2 },
  "X19*":  { clause: "!Aw v !Xf v At v Fz v Xm",         neg: 2, pos: 3 },
};

console.log("row      neg  pos   Horn  dualHorn  classification   clause");
for (const [id, r] of Object.entries(ROWS)) {
  const horn = r.pos <= 1, dual = r.neg <= 1;
  const cls = horn && dual ? "both" : horn ? "Horn" : dual ? "dual-Horn" : "neither";
  console.log(`${id.padEnd(8)} ${String(r.neg).padStart(3)} ${String(r.pos).padStart(4)}   ` +
    `${(horn ? "yes" : "no ").padEnd(5)} ${(dual ? "yes" : "no ").padEnd(9)} ${cls.padEnd(16)} ${r.clause}`);
}

console.log("\nwhat separates them:");
console.log("  neither Horn nor dual-Horn  <=>  at least 2 POSITIVE and at least 2 NEGATIVE literals");
console.log("\nwhy the stated criterion is not sufficient:");
console.log("  a clause with 5 negative and 1 positive literal has two or more negative");
console.log("  literals, yet at most one positive literal, so it IS Horn.");
console.log("\nthe conclusion for X18 and X19* is nevertheless correct:");
console.log("  X18  2 neg and 2 pos -> neither");
console.log("  X19* 2 neg and 3 pos -> neither");
console.log("  so the proposition's verdict stands; only its stated reason is incomplete.");
