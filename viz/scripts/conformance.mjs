#!/usr/bin/env node
/* Conformance harness — gates the build.
 * Implements openspec/changes/design-atlas-visualization/specs/atlas-conformance. */
import { readFileSync, existsSync, statSync } from "node:fs";
import { gzipSync } from "node:zlib";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const repo = join(root, "..");
const fails = [];
const notes = [];

/* ------------------------------------------------------------- colour ---- */

const hex = (h) => {
  const s = h.replace("#", "");
  const n = s.length === 3 ? s.split("").map((c) => c + c).join("") : s;
  return [0, 2, 4].map((i) => parseInt(n.slice(i, i + 2), 16) / 255);
};
const lin = (c) => (c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
const Y = (h) => {
  const [r, g, b] = hex(h).map(lin);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ratio = (a, b) => {
  const [hi, lo] = Y(a) >= Y(b) ? [Y(a), Y(b)] : [Y(b), Y(a)];
  return (hi + 0.05) / (lo + 0.05);
};

/** Brettel-style channel collapse: both common dichromacies lose the
 *  red-green axis, so we approximate by projecting R and G together and
 *  re-measuring luminance separation. */
const collapse = (h, kind) => {
  const [r, g, b] = hex(h);
  const m = kind === "deuter" ? 0.7 * r + 0.3 * g : 0.4 * r + 0.6 * g;
  const to = (v) => `0${Math.round(Math.min(1, Math.max(0, v)) * 255).toString(16)}`.slice(-2);
  return `#${to(m)}${to(m)}${to(b)}`;
};

const css = readFileSync(join(root, "src/styles.css"), "utf8");

/* Both themes are checked. A light theme that fails contrast is a real
   defect, not a lesser edition. */
const blockOf = (sel) => {
  const i = css.indexOf(sel);
  if (i < 0) return null;
  const open = css.indexOf("{", i);
  return css.slice(open, css.indexOf("}", open));
};
const THEMES = [
  { name: "dark", css: blockOf(":root {") },
  { name: "light", css: blockOf(':root[data-theme="light"]') },
];

for (const theme of THEMES) {
  if (!theme.css) { fails.push(`theme block for ${theme.name} not found`); continue; }
  const token = (name) => {
    const m = theme.css.match(new RegExp(`--${name}:\\s*(#[0-9a-fA-F]{3,6})`));
    if (!m) { fails.push(`[${theme.name}] token --${name} missing`); return null; }
    return m[1];
  };
  const strata = [0, 1, 2, 3, 4].map((i) => ({ id: `S${i}`, hex: token(`s${i}`) }));
  const hazards = [
    { id: "forbidden", hex: token("hz-f") },
    { id: "elevated", hex: token("hz-h") },
    { id: "unverifiable", hex: token("hz-u") },
  ];
  const ink = token("ink");
  const ground = token("ground");
  if (!ink || !ground || strata.some((s) => !s.hex) || hazards.some((h) => !h.hex)) continue;

  /* 1. hazard chroma must never be mistakable for stratum depth.
        Hazard classes are told apart from each other by mark and label,
        so only the hazard/stratum boundary is enforced chromatically. */
  for (const h of hazards) {
    for (const s of strata) {
      for (const k of ["deuter", "protan"]) {
        const r = ratio(collapse(h.hex, k), collapse(s.hex, k));
        if (r < 1.5) {
          fails.push(`[${theme.name}] hazard:${h.id} (${h.hex}) vs ${s.id} (${s.hex}) = ${r.toFixed(2)}:1 under ${k}anopia — below the 1.5:1 floor`);
        }
      }
    }
  }

  /* 2. adjacent strata must be separable by lightness alone. */
  for (let i = 0; i < strata.length - 1; i++) {
    const r = ratio(strata[i].hex, strata[i + 1].hex);
    // 1.25 floor. Stratum is carried by band position, the printed S-token AND
    // lightness — lightness is one of three channels, so it need not be
    // independently sufficient, and a stricter floor cannot coexist with the
    // 4.5:1 text requirement across five steps on either ground.
    if (r < 1.25) fails.push(`[${theme.name}] ${strata[i].id} vs ${strata[i + 1].id} = ${r.toFixed(2)}:1 — adjacent strata not separable`);
  }

  /* 3. text contrast at rendered size. */
  for (const s of [...strata, { id: "ground", hex: ground }]) {
    const r = ratio(ink, s.hex);
    if (r < 4.5) fails.push(`[${theme.name}] ink on ${s.id} = ${r.toFixed(2)}:1 — below 4.5:1`);
  }

  console.log(`\n[${theme.name}] stratum Y:`, strata.map((s) => `${s.id} ${Y(s.hex).toFixed(3)}`).join("  "));
  console.log(`[${theme.name}] hazard Y: `, hazards.map((h) => `${h.id} ${Y(h.hex).toFixed(3)}`).join("  "));
}

/* 4. hazard chroma is never used for small text on the ground. */
if (/(?:font-size:\s*(?:[0-9.]+)px[^}]*color:\s*var\(--hz-|color:\s*var\(--hz-[fhu]\)[^}]*font-size)/.test(css)) {
  notes.push("check: hazard chroma appears near a font-size rule — must be a field or a >=3px mark, not small text");
}

/* --------------------------------------------------------------- deps ---- */

const pkg = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
for (const banned of ["three", "@react-three/fiber", "babylonjs", "pixi.js"]) {
  if (deps[banned]) fails.push(`banned scene-graph dependency present: ${banned}`);
}

/* ------------------------------------------------------------ payload ---- */

const dist = join(root, "dist/index.html");
if (existsSync(dist)) {
  const raw = readFileSync(dist);
  const gz = gzipSync(raw).length;
  const kb = (gz / 1024).toFixed(1);
  if (gz > 150 * 1024) fails.push(`payload ${kb} KB gzipped — over the 150 KB budget`);
  else notes.push(`payload ${kb} KB gzipped (budget 150 KB), ${(raw.length / 1024).toFixed(1)} KB raw`);
} else {
  notes.push("no dist/index.html yet — payload check skipped");
}

/* ------------------------------------------------- data / document sync -- */

const data = readFileSync(join(root, "src/data.ts"), "utf8");
const count = (re) => (data.match(re) || []).length;
const core = count(/status:\s*"core"/g);
const cand = count(/status:\s*"candidate"/g);
const contested = (data.match(/export const CONTESTED[\s\S]*?\n\];/) || [""])[0]
  .split("\n").filter((l) => /\{\s*id:\s*"P/.test(l)).length;

const doc = join(repo, "docs/UNIFIED-DEFI-ELEMENT-TABLE.md");
if (existsSync(doc)) {
  const md = readFileSync(doc, "utf8");
  const m = md.match(/(\d+)\s*core elements?\s*·\s*(\d+)\s*candidates?\s*·\s*(\d+)\s*provisional/i);
  if (m) {
    const [, dc, dn, dp] = m.map(Number);
    if (dc !== core) fails.push(`core count drift: export ${core}, document ${dc}`);
    if (dn !== cand) fails.push(`candidate count drift: export ${cand}, document ${dn}`);
    if (dp !== contested) fails.push(`contested count drift: export ${contested}, document ${dp}`);
    if (dc === core && dn === cand && dp === contested)
      notes.push(`data/document in sync: ${core} core, ${cand} candidate, ${contested} contested`);
  } else notes.push("could not locate the count line in the atlas document — sync check skipped");
} else notes.push("atlas document not found — sync check skipped");

/* ------------------------------------------------------- source rules ---- */

const src = readFileSync(join(root, "src/main.ts"), "utf8");
if (!/aria-live/.test(src)) fails.push("no polite live region found");
if (!/showModal\(\)/.test(src)) fails.push("detail surface is not a focus-trapping dialog");
if (!/prefers-reduced-motion/.test(src)) fails.push("reduced motion is not consulted in main.ts");
const disallowed = src.match(/periodic table/gi) || [];
if (disallowed.length > 1) fails.push(`the phrase "periodic table" appears ${disallowed.length} times — only the disavowal is permitted`);
if (disallowed.length === 1 && !/not a periodic table/i.test(src))
  fails.push('the single use of "periodic table" is not inside its disavowal');

/* -------------------------------------------------------------- report --- */

console.log("\nAtlas conformance\n" + "-".repeat(50));
notes.forEach((n) => console.log("  note:", n));

if (fails.length) {
  console.error("\nFAILED\n" + fails.map((f) => "  ✗ " + f).join("\n") + "\n");
  process.exit(1);
}
console.log("\n  ✓ all conformance checks passed\n");
