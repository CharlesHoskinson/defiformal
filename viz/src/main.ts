import "./styles.css";
import "./story.css";
import "./packed.css";
import "./three.css";
import {
  ATLAS_REVIEWED, ATLAS_VERSION, ATOM_LABEL, BONDS, CHANGELOG, CONTESTED,
  ELEMENTS, GROUPS, HAZARDS, LAWS, STRATA, hazardsFor, lawsFor,
  type Atom, type Element, type Status,
} from "./data";
import { HOWTO, PROTOCOLS, type Protocol } from "./protocols";
import { Scene3D } from "./scene3d";
import { Vector3 } from "three";

type Layout = "matrix" | "strata";
type Order = "group" | "stratum" | "id";
type View = "elements" | "laws" | "hazards";

const STATUS_WORD: Record<Status, string> = {
  core: "core",
  candidate: "candidate: recurrence evidence short",
  provisional: "contested: note required",
  limit: "degenerate limit: not an element",
};
const HZ_WORD = { F: "forbidden", H: "elevated", U: "unverifiable" } as const;
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

const state = {
  view: "elements" as View,
  layout: "matrix" as Layout,
  order: "group" as Order,
  query: "",
  status: new Set<Status>(),
  selected: null as string | null,
  rule: null as string | null,
  protocol: null as string | null,
  motion: !reduceMotion,
  three: false,
};

let scene: Scene3D | null = null;

const el = <K extends keyof HTMLElementTagNameMap>(t: K, c?: string, x?: string) => {
  const n = document.createElement(t);
  if (c) n.className = c;
  if (x != null) n.textContent = x;
  return n;
};
const groupOf = (g: string) => GROUPS.find((x) => x.id === g)!;
const proto = () => PROTOCOLS.find((p) => p.id === state.protocol) || null;

/** membership of the currently projected protocol */
function inProtocol(e: Element): boolean {
  const p = proto();
  return !p || p.syms.includes(e.sym);
}

function accessibleName(e: Element): string {
  const hz = hazardsFor(e.sym);
  return [
    e.sym, e.name, `ID ${e.id}`,
    `group ${e.group} ${groupOf(e.group).name}`,
    `stratum S${e.stratum}`, STATUS_WORD[e.status], ATOM_LABEL[e.atom],
    hz.length ? `hazard ${[...new Set(hz.map((h) => HZ_WORD[h.cls]))].join(" and ")}` : "no hazard membership",
    e.disc ? "discriminator required" : "no discriminator required",
  ].join(", ");
}

function matches(e: Element): boolean {
  if (state.status.size && !state.status.has(e.status)) return false;
  if (state.rule) {
    if (!lawsFor(e.sym).some((l) => l.id === state.rule) &&
        !hazardsFor(e.sym).some((h) => h.id === state.rule)) return false;
  }
  const q = state.query.trim().toLowerCase();
  if (!q) return true;
  return e.sym.toLowerCase().includes(q) || e.name.toLowerCase().includes(q) || e.id.toLowerCase().includes(q);
}

function announce(m: string) {
  const l = document.getElementById("live");
  if (!l) return;
  l.textContent = "";
  setTimeout(() => { l.textContent = m; }, 30);
}

/* ------------------------------------------------------------- markers */

function statusGlyph(s: Status) {
  const g = el("span", `glyph ${s === "provisional" ? "contested" : s}`);
  g.setAttribute("aria-hidden", "true");
  return g;
}
function noDenom() {
  const n = el("span", "nodenom");
  n.setAttribute("aria-hidden", "true");
  n.innerHTML = "<i>n</i><u></u><s></s>";
  n.title = "no denominator: exposure and survivors were never collected";
  return n;
}

/* --------------------------------------------------------------- tiles */

const tiles = new Map<string, HTMLButtonElement>();

function buildTile(e: Element) {
  const b = el("button", `tile s${e.stratum}`) as HTMLButtonElement;
  b.type = "button";
  b.dataset.id = e.id;
  b.dataset.sym = e.sym;
  b.setAttribute("aria-label", accessibleName(e));
  b.setAttribute("aria-pressed", "false");
  b.tabIndex = -1;
  const top = el("span", "t-top");
  top.append(el("span", "t-id", e.id), el("span", "t-strat", `S${e.stratum}`));
  b.append(top, el("span", "t-sym", e.sym), el("span", "t-nm", e.name));
  const badge = el("span", "t-badge");
  badge.append(statusGlyph(e.status));
  if (e.status !== "core") badge.append(noDenom());
  badge.append(el("span", "", e.status === "provisional" ? "contested" : e.status === "limit" ? "limit" : e.status));
  b.append(badge);
  const seq = el("span", "t-seq");
  seq.setAttribute("aria-hidden", "true");
  b.append(seq);
  b.addEventListener("click", () => select(e.id));
  b.addEventListener("keydown", onTileKey);
  return b;
}

function orderedElements(): Element[] {
  const l = [...ELEMENTS];
  if (state.order === "group")
    return l.sort((a, b) => a.group.localeCompare(b.group) || a.stratum - b.stratum || a.id.localeCompare(b.id));
  if (state.order === "stratum")
    return l.sort((a, b) => a.stratum - b.stratum || a.group.localeCompare(b.group) || a.id.localeCompare(b.id));
  return l.sort((a, b) => a.id.localeCompare(b.id));
}

/* ---------------------------------------------------------- placements */

function matrixPlacement() {
  const place = new Map<string, { row: number; col: number }>();
  const occ = new Map<string, Element[]>();
  for (const e of ELEMENTS) {
    const k = `${e.group}|${e.stratum}`;
    if (!occ.has(k)) occ.set(k, []);
    occ.get(k)!.push(e);
  }
  const bandRows = STRATA.map((s) =>
    Math.max(1, ...GROUPS.map((g) => (occ.get(`${g.id}|${s.id}`) ?? []).length)));
  const bandStart: number[] = [];
  let r = 2;
  STRATA.forEach((s, i) => { bandStart[s.id] = r; r += bandRows[i]; });
  for (const [k, list] of occ) {
    const [gid, sid] = k.split("|");
    const gi = GROUPS.findIndex((g) => g.id === gid);
    list.sort((a, b) => a.id.localeCompare(b.id));
    list.forEach((e, i) => place.set(e.id, { row: bandStart[+sid] + i, col: gi + 2 }));
  }
  return { place, occ, bandRows, bandStart };
}

function strataPlacement(perRow = 15) {
  const place = new Map<string, { row: number; col: number }>();
  const bandStart: number[] = [];
  let r = 2;
  for (const s of STRATA) {
    bandStart[s.id] = r;
    const list = ELEMENTS.filter((e) => e.stratum === s.id)
      .sort((a, b) => a.group.localeCompare(b.group) || a.id.localeCompare(b.id));
    list.forEach((e, i) => place.set(e.id, { row: r + Math.floor(i / perRow), col: (i % perRow) + 2 }));
    r += Math.max(1, Math.ceil(list.length / perRow));
  }
  return { place, bandStart, perRow };
}

function placeTiles(g: HTMLElement, place: Map<string, { row: number; col: number }>) {
  for (const e of orderedElements()) {
    const p = place.get(e.id);
    if (!p) continue;
    const n = tiles.get(e.id)!;
    n.style.gridRow = String(p.row);
    n.style.gridColumn = String(p.col);
    g.append(n);
  }
}

/* The table is packed, not a cross-product. Group and stratum are close to
   collinear in this data — credit is all S3, pricing all S1 — so a 16x5 grid
   is empty by construction. Draw only what exists: five depth rows, each a
   run of labelled family blocks. Both axes stay exact. */

function familyBlock(grp: typeof GROUPS[number], list: Element[]): HTMLElement {
  const b = el("section", "fam");
  const h = el("header", "fam-h");
  h.append(el("span", "fam-id", grp.id));
  h.append(el("span", "fam-nm", grp.name));
  h.append(el("span", "fam-n", String(list.length)));
  h.title = grp.boundary;
  b.append(h);
  const row = el("div", "fam-row");
  list.forEach((e) => row.append(tiles.get(e.id)!));
  b.append(row);
  return b;
}

function buildDepthView(): HTMLElement {
  const wrap = el("div", "depth");
  for (const s of STRATA) {
    const band = el("section", "band");
    const lab = el("div", "band-lab");
    lab.append(el("span", "band-s", `S${s.id}`));
    lab.append(el("span", "band-nm", s.name));
    lab.append(el("span", "band-d claim", s.desc));
    band.append(lab);
    const body = el("div", "band-body");
    let n = 0;
    for (const g of GROUPS) {
      const list = ELEMENTS.filter((e) => e.group === g.id && e.stratum === s.id)
        .sort((a, b) => a.id.localeCompare(b.id));
      if (!list.length) continue;
      n += list.length;
      body.append(familyBlock(g, list));
    }
    lab.append(el("span", "band-n", `${n}`));
    band.append(body);
    wrap.append(band);
  }
  return wrap;
}

function buildFamilyView(): HTMLElement {
  const wrap = el("div", "families");
  for (const g of GROUPS) {
    const list = ELEMENTS.filter((e) => e.group === g.id)
      .sort((a, b) => a.stratum - b.stratum || a.id.localeCompare(b.id));
    if (!list.length) continue;
    const sec = el("section", "fam wide");
    const h = el("header", "fam-h");
    h.append(el("span", "fam-id", g.id));
    h.append(el("span", "fam-nm", g.name));
    h.append(el("span", "fam-n", String(list.length)));
    sec.append(h);
    sec.append(el("p", "fam-q claim", g.boundary));
    const row = el("div", "fam-row");
    list.forEach((e) => row.append(tiles.get(e.id)!));
    sec.append(row);
    wrap.append(sec);
  }
  return wrap;
}

function buildGrid(): HTMLElement {
  return state.layout === "matrix" ? buildDepthView() : buildFamilyView();
}

/* --------------------------------------------------------------- FLIP */

function withFlip(fn: () => void) {
  if (!state.motion) return fn();
  const first = new Map<string, DOMRect>();
  tiles.forEach((t, id) => { if (t.isConnected) first.set(id, t.getBoundingClientRect()); });
  fn();
  tiles.forEach((t, id) => {
    const a = first.get(id);
    if (!a || !t.isConnected) return;
    const b = t.getBoundingClientRect();
    const dx = a.left - b.left, dy = a.top - b.top;
    if (!dx && !dy) return;
    t.animate([{ transform: `translate(${dx}px,${dy}px)` }, { transform: "none" }],
      { duration: 280, easing: "cubic-bezier(.2,.7,.3,1)" });
  });
}

/* ----------------------------------------------------------- projection */

function applyProjection() {
  const p = proto();
  tiles.forEach((t, id) => {
    const e = ELEMENTS.find((x) => x.id === id)!;
    const member = !p || p.syms.includes(e.sym);
    t.classList.toggle("dim", !matches(e) || (!!p && !member));
    t.classList.toggle("member", !!p && member);
    const seq = t.querySelector<HTMLElement>(".t-seq")!;
    if (p && member) {
      const i = p.syms.indexOf(e.sym);
      seq.textContent = String(i + 1);
    } else seq.textContent = "";
    t.classList.toggle("loop", !!(p?.broke?.cycle && member && ["As", "Rd", "Em"].includes(e.sym)));
  });
}

/* ------------------------------------------------------------ 3D mode */

/* The 3D layout is computed, not inherited. Reusing the flat layout's measured
   positions dragged in band padding, the hidden label column and the height of
   wrapped rows, which is what pushed the planes so far apart. Each stratum
   instead becomes a compact block, centred on its own plane. */
const PLANE_STEP = 360;   // depth between planes: enough to actually see
const BAND_GAP = 74;      // vertical breathing room between stratum blocks

function layout3D(tw: number, th: number) {
  const GX = 9, GY = 9;
  const boxes = new Map<string, { x: number; y: number; z: number }>();
  let cursorY = 0, maxX = 0;
  for (const s of STRATA) {
    const list = ELEMENTS.filter((e) => e.stratum === s.id)
      .sort((a, b) => a.group.localeCompare(b.group) || a.id.localeCompare(b.id));
    if (!list.length) continue;
    const cols = Math.max(1, Math.ceil(Math.sqrt(list.length * 2.2)));
    const rows = Math.ceil(list.length / cols);
    list.forEach((e, i) => {
      const c = i % cols, r = Math.floor(i / cols);
      const x = (c - (cols - 1) / 2) * (tw + GX);
      const y = cursorY - r * (th + GY) - th / 2;
      boxes.set(e.id, { x, y, z: -s.id * PLANE_STEP });
      maxX = Math.max(maxX, Math.abs(x) + tw / 2);
    });
    cursorY -= rows * (th + GY) + BAND_GAP;
  }
  const extentH = Math.abs(cursorY) + BAND_GAP;
  const midY = -extentH / 2;
  return { boxes, extentH, extentW: maxX * 2, midY };
}

function measure() {
  const host = document.getElementById("table")!;
  const hr = host.getBoundingClientRect();
  const probe = tiles.get(ELEMENTS[0].id)!;
  const pr = probe.getBoundingClientRect();
  const tw = pr.width || 118, th = pr.height || 82;

  const { boxes: pos, extentH, extentW, midY } = layout3D(tw, th);
  const boxes = new Map<string, { el: HTMLElement; box: any }>();
  tiles.forEach((t, id) => {
    const p = pos.get(id);
    if (!p) return;
    boxes.set(id, { el: t, box: { x: p.x, y: p.y - midY, w: tw, h: th, z: p.z } });
  });
  // Frame the content at roughly life size: the near plane renders 1:1 and
  // deeper planes shrink by perspective alone.
  const pad = 1.06;
  const byW = (extentW * pad) / Math.max(0.2, hr.width / Math.max(1, extentH * pad));
  const frameH = Math.max(extentH * pad, byW);
  const hostH = Math.round(frameH);
  return { boxes, w: hr.width, h: hostH, frameH, host };
}

function enter3D() {
  const { boxes, w, h, frameH, host } = measure();
  homeBoxes = new Map();
  boxes.forEach((v, k) => homeBoxes.set(k, { x: v.box.x, y: v.box.y, z: v.box.z }));
  host.classList.add("is3d");
  host.style.height = `${h}px`;
  scene = new Scene3D(host, !state.motion);
  scene.onSpiralEnd = () => {
    const ro = document.getElementById("readout");
    ro?.classList.add("broke-done");
    announce("The loop broke.");
  };
  scene.mount(boxes, w, h, frameH);
  apply3D();
  // the flat containers collapse and the scene centres itself in a tall box,
  // so without this the viewport is left staring at empty space
  host.scrollIntoView({ behavior: state.motion ? "smooth" : "auto", block: "start" });
  host.addEventListener("focusin", on3DFocus);
  window.addEventListener("resize", re3D);
}

function exit3D() {
  const host = document.getElementById("table")!;
  host.removeEventListener("focusin", on3DFocus);
  window.removeEventListener("resize", re3D);
  scene?.dispose();
  scene = null;
  host.classList.remove("is3d");
  host.style.height = "";
  render();
}

function on3DFocus(ev: FocusEvent) {
  const t = (ev.target as HTMLElement).closest(".tile") as HTMLElement | null;
  if (t?.dataset.id) scene?.focusOn(t.dataset.id);
}

let reT = 0;
function re3D() {
  window.clearTimeout(reT);
  reT = window.setTimeout(() => {
    if (!scene) return;
    const host = document.getElementById("table")!;
    host.style.height = "";
    host.classList.remove("is3d");
    const { boxes, w, h, frameH } = measure();
    homeBoxes = new Map();
    boxes.forEach((v, k) => homeBoxes.set(k, { x: v.box.x, y: v.box.y, z: v.box.z }));
    host.classList.add("is3d");
    host.style.height = `${h}px`;
    scene.mount(boxes, w, h, frameH);
    apply3D();
  }, 140);
}

/** The money shot: members lift out of the plane and assemble in order. */
function apply3D() {
  if (!scene) return;
  const p = proto();
  const next = new Map<string, Vector3>();

  if (!p) {
    scene.stopSpiral();
    const { boxes } = measure3DHome();
    boxes.forEach((b, id) => next.set(id, new Vector3(b.x, b.y, b.z)));
    scene.moveTo(next, 8, 420);
    scene.home_();
    return;
  }

  const members = p.syms
    .map((s) => ELEMENTS.find((e) => e.sym === s))
    .filter(Boolean) as Element[];
  const cols = Math.ceil(Math.sqrt(members.length));
  const GX = 150, GY = 128;
  members.forEach((e, i) => {
    const c = i % cols, r = Math.floor(i / cols);
    next.set(e.id, new Vector3(
      (c - (cols - 1) / 2) * GX,
      -(r - (Math.ceil(members.length / cols) - 1) / 2) * GY,
      340
    ));
  });
  const home = measure3DHome().boxes;
  ELEMENTS.forEach((e) => {
    if (next.has(e.id)) return;
    const b = home.get(e.id);
    if (b) next.set(e.id, new Vector3(b.x * 1.12, b.y * 1.12, b.z - 420));
  });
  scene.moveTo(next, 36, 560);
  scene.home_();

  if (p.broke?.cycle) {
    const loopIds = members.filter((e) => ["As", "Rd", "Em"].includes(e.sym)).map((e) => e.id);
    window.setTimeout(() => scene?.spiral(loopIds, 3), 900);
  } else scene.stopSpiral();
}

/** Resting positions, captured from the document layout before lifting. */
let homeBoxes = new Map<string, { x: number; y: number; z: number }>();
function measure3DHome() { return { boxes: homeBoxes }; }

/* ------------------------------------------------------------ selection */

function select(id: string | null) {
  state.selected = id;
  tiles.forEach((t, tid) => t.setAttribute("aria-pressed", String(tid === id)));
  if (id) { history.replaceState(null, "", `#${id}`); openDetail(ELEMENTS.find((e) => e.id === id)!); }
}

function onTileKey(ev: KeyboardEvent) {
  const list = orderedElements().filter(matches);
  const cur = (ev.currentTarget as HTMLElement).dataset.id!;
  const i = list.findIndex((e) => e.id === cur);
  let n = -1;
  if (ev.key === "ArrowRight" || ev.key === "ArrowDown") n = Math.min(i + 1, list.length - 1);
  else if (ev.key === "ArrowLeft" || ev.key === "ArrowUp") n = Math.max(i - 1, 0);
  else if (ev.key === "Home") n = 0;
  else if (ev.key === "End") n = list.length - 1;
  else if (/^[a-zA-Z]$/.test(ev.key)) {
    const rot = list.slice(i + 1).concat(list.slice(0, i + 1));
    const hit = rot.find((e) => e.sym.toLowerCase().startsWith(ev.key.toLowerCase()));
    if (hit) n = list.findIndex((e) => e.id === hit.id);
  } else return;
  ev.preventDefault();
  if (n >= 0) focusTile(list[n].id);
}

function focusTile(id: string) {
  tiles.forEach((t) => (t.tabIndex = -1));
  const t = tiles.get(id);
  if (!t) return;
  t.tabIndex = 0;
  t.focus();
}

/* --------------------------------------------------------------- detail */

function openDetail(e: Element) {
  document.querySelector("dialog.detail")?.remove();
  const d = el("dialog", "detail") as HTMLDialogElement;
  d.setAttribute("aria-label", `${e.sym} — ${e.name}`);
  const c = el("button", "d-close", "CLOSE ✕");
  c.addEventListener("click", () => d.close());
  d.append(c, el("div", "version", e.id), el("div", "d-sym", e.sym), el("div", "d-nm", e.name));
  d.append(el("p", "d-def claim", e.def));
  if (e.note) d.append(el("p", "d-note claim", e.note));
  const chg = CHANGELOG[e.id];
  if (chg) d.append(el("p", "d-note claim",
    `Classification changed during review: ${chg.from} → ${chg.to}. ${chg.why}`));

  const dl = el("dl", "meta");
  const add = (k: string, v: string) => dl.append(el("dt", "", k), el("dd", "", v));
  add("Status", STATUS_WORD[e.status]);
  add("Group", `${e.group} · ${groupOf(e.group).name}`);
  add("What could sit here instead", groupOf(e.group).boundary);
  add("Stratum", `S${e.stratum} · ${STRATA[e.stratum].name}`);
  add("Asynchrony", ATOM_LABEL[e.atom]);
  if (e.disc) add("Discriminator", e.disc);
  d.append(dl);

  const used = PROTOCOLS.filter((p) => p.syms.includes(e.sym));
  if (used.length) {
    d.append(el("div", "d-h", "Appears in"));
    const row = el("div", "chips");
    used.forEach((p) => {
      const b = el("button", "", p.name + (p.dead ? " ✝" : "")) as HTMLButtonElement;
      b.type = "button";
      b.addEventListener("click", () => { d.close(); setProtocol(p.id); });
      row.append(b);
    });
    d.append(row);
  }

  const laws = lawsFor(e.sym);
  if (laws.length) {
    d.append(el("div", "d-h", `Laws naming ${e.sym} (${laws.length})`));
    laws.forEach((l) => d.append(el("div", "d-item", `${l.id}  ${l.rule}`)));
  }
  const hz = hazardsFor(e.sym);
  if (hz.length) {
    d.append(el("div", "d-h", `Hazard rules naming ${e.sym} (${hz.length})`));
    hz.forEach((h) => {
      const it = el("div", "d-item");
      const cl = el("span", `hz-class hz-${h.cls}`);
      cl.append(el("span", `hz-chip ${h.cls}`), document.createTextNode(HZ_WORD[h.cls]));
      it.append(cl, document.createTextNode(` ${h.id}  ${h.combo}`));
      d.append(it);
    });
    d.append(el("p", "d-note claim",
      "Case-only evidence; exposure and survivors not collected; probability not estimated."));
  }
  document.body.append(d);
  d.showModal();
  d.addEventListener("close", () => { const t = tiles.get(e.id); if (t) { t.tabIndex = 0; t.focus(); } });
}

/* ------------------------------------------------------------- protocol */

function setProtocol(id: string | null) {
  state.protocol = state.protocol === id ? null : id;
  history.replaceState(null, "", state.protocol ? `#p=${state.protocol}` : " ");
  if (state.three && scene) {
    // stay in the scene: update the readout in place, then fly the tiles
    const old = document.getElementById("readout");
    old?.remove();
    const ro = readout();
    if (ro) document.querySelector(".rail-protocols")!.after(ro);
    document.querySelectorAll<HTMLButtonElement>(".proto").forEach((b, i) => {
      const on = PROTOCOLS[i]?.id === state.protocol;
      b.classList.toggle("on", on);
      b.setAttribute("aria-pressed", String(on));
    });
    applyProjection();
    apply3D();
  } else render();
  const p = proto();
  announce(p ? `${p.name} projected onto the table: ${p.syms.length} elements.` : "Protocol cleared.");
  if (p) document.getElementById("readout")?.scrollIntoView({ behavior: state.motion ? "smooth" : "auto", block: "nearest" });
}

function protocolRail(): HTMLElement {
  const s = el("section", "rail-protocols");
  s.append(el("h2", "sec-h", "Read a protocol"));
  s.append(el("p", "sec-sub claim",
    "Pick one. It lights up in the table below, numbered in the order each part became necessary. Four of these are dead — and those are the instructive ones."));
  const row = el("div", "protos");
  PROTOCOLS.forEach((p) => {
    const b = el("button", `proto${p.dead ? " dead" : ""}${state.protocol === p.id ? " on" : ""}`) as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-pressed", String(state.protocol === p.id));
    b.append(el("span", "pn", p.name + (p.dead ? "  ✝" : "")));
    b.append(el("span", "pk", p.kind));
    b.append(el("span", "pc", `${p.syms.length} elements`));
    b.addEventListener("click", () => setProtocol(p.id));
    row.append(b);
  });
  s.append(row);
  return s;
}

function readout(): HTMLElement | null {
  const p = proto();
  if (!p) return null;
  const s = el("section", `readout${p.dead ? " dead" : ""}`);
  s.id = "readout";
  const head = el("div", "ro-head");
  head.append(el("h2", "", p.name));
  head.append(el("span", "ro-kind", p.dead ? `${p.kind} · did not survive` : p.kind));
  const x = el("button", "ro-clear", "clear ✕") as HTMLButtonElement;
  x.type = "button";
  x.addEventListener("click", () => setProtocol(null));
  head.append(x);
  s.append(head);

  s.append(el("div", "formula", p.formula));
  s.append(el("p", "ro-read claim", p.reading));

  if (p.build) {
    s.append(el("h3", "ro-h", "Why each part had to be there"));
    const ol = el("ol", "build");
    p.build.forEach((b, i) => {
      const li = el("li");
      li.append(el("span", "bn", String(i + 1)));
      const sym = el("span", "bsym", b.sym);
      sym.addEventListener("click", () => {
        const e = ELEMENTS.find((x) => x.sym === b.sym);
        if (e) select(e.id);
      });
      li.append(sym);
      li.append(el("span", "bwhy claim", b.why));
      ol.append(li);
    });
    s.append(ol);
  }

  if (p.broke) {
    const box = el("div", "broke");
    box.append(el("h3", "", "What broke"));
    box.append(el("p", "claim", p.broke.what));
    if (p.broke.cycle) {
      const cy = el("div", "cycle");
      cy.setAttribute("aria-label", "Reflexive cycle: " + p.broke.cycle.join(", then "));
      p.broke.cycle.forEach((c, i) => {
        cy.append(el("span", "cy", c));
        cy.append(el("span", "cyar", i === p.broke!.cycle!.length - 1 ? "↺" : "→"));
      });
      box.append(cy);
    }
    box.append(el("p", "loss", p.broke.loss));
    if (p.broke.hazard) {
      const h = HAZARDS.find((z) => z.id === p.broke!.hazard);
      if (h) {
        const hb = el("div", "broke-hz");
        const cl = el("span", `hz-class hz-${h.cls}`);
        cl.append(el("span", `hz-chip ${h.cls}`), document.createTextNode(HZ_WORD[h.cls]));
        hb.append(cl, el("span", "", ` ${h.id} — ${h.combo}`));
        box.append(hb);
      }
    } else {
      box.append(el("p", "claim ro-none",
        "No hazard rule covers this. Every element was correct and correctly combined — the defect was in one implementation. The table is blind to that entire class."));
    }
    s.append(box);
  }

  const r = el("p", "residue claim");
  r.append(el("b", "", "Residue: "));
  r.append(document.createTextNode(p.residue));
  s.append(r);
  return s;
}

/* ------------------------------------------------------------- sections */

function howToRead(): HTMLElement {
  const s = el("section", "howread");
  const items = [
    ["Rows are how much must already exist", "S0 needs nothing but the ledger. S4 needs other people to agree. Deeper is not more dangerous — it is more dependent, and confusing those two is how you misprice a protocol."],
    ["Blocks are families of substitutes", "Everything in a block answers one question. Swap Cp for Cl and you still have a DEX. That is what a block means and the only thing it means."],
    ["The shape is the finding", "Families cluster at one depth — credit is all S3, pricing all S1. And S3 is enormous: most of DeFi is machinery for owing, pricing and unwinding obligations."],
    ["Colour only ever means hazard", "There is exactly one coloured thing in this interface and it is danger. Everything else earns its distinction from position, shape and lightness."],
  ];
  items.forEach(([h, b]) => {
    const d = el("div", "hr-item");
    d.append(el("b", "", h));
    d.append(el("span", "claim", b));
    s.append(d);
  });
  return s;
}

function howToThink(): HTMLElement {
  const s = el("section", "howthink");
  s.append(el("h2", "sec-h", "How to think with it"));
  s.append(el("p", "sec-sub claim",
    "Six questions, in this order. Run them against anything — a protocol you are auditing, a pitch deck, your own design — and the table stops being a diagram and becomes a method. Question three pays for the other five."));
  const g = el("div", "think-grid");
  HOWTO.forEach((h) => {
    const c = el("div", "think");
    c.append(el("span", "tn", h.n));
    c.append(el("h3", "", h.q));
    c.append(el("p", "claim", h.body));
    g.append(c);
  });
  s.append(g);
  return s;
}

function legend(): HTMLElement {
  const s = el("section", "legend");
  s.append(el("h2", "sec-h", "Legend"));
  const cols = el("div", "legend-cols");
  const c1 = el("div");
  const sr = el("div", "swatch-row");
  STRATA.forEach((st) => {
    const w = el("span", "swatch");
    w.style.background = `var(--s${st.id})`;
    w.title = `S${st.id} — ${st.name}`;
    sr.append(w);
  });
  c1.append(el("div", "legend-item", "Stratum S0 → S4"), sr);
  c1.append(el("p", "legend-note claim",
    "Prerequisite depth, not risk. Carried by the band, the S-token and lightness — never hue."));
  cols.append(c1);
  const c2 = el("div");
  (["core", "candidate", "provisional", "limit"] as Status[]).forEach((st) => {
    const i = el("div", "legend-item");
    i.append(statusGlyph(st), el("span", "", STATUS_WORD[st]));
    c2.append(i);
  });
  const nd = el("div", "legend-item");
  nd.append(noDenom(), el("span", "", "no denominator — failures counted, survivors never were"));
  c2.append(nd);
  cols.append(c2);
  const c3 = el("div");
  (["F", "H", "U"] as const).forEach((k) => {
    const i = el("div", "legend-item");
    i.append(el("span", `hz-chip ${k}`), el("span", "", `hazard: ${HZ_WORD[k]}`));
    c3.append(i);
  });
  c3.append(el("p", "legend-note claim",
    "Hazard membership is categorical. It is never a probability, because no exposure or survivor counts exist."));
  cols.append(c3);
  const c4 = el("div");
  BONDS.forEach((b) => {
    const i = el("div", "legend-item");
    i.append(el("span", "k", b.sym), el("span", "", `${b.name} — ${b.q}`));
    c4.append(i);
  });
  cols.append(c4);
  s.append(cols);
  return s;
}

function contestedPanel(): HTMLElement {
  const s = el("section", "contested");
  s.append(el("h2", "", "Contested register — 10 entries"));
  s.append(el("p", "why claim",
    "Held outside the table because a necessary criterion is genuinely disputed. Not usable in a formula without a note. The separation means “argued about”, not “filed away”."));
  const row = el("div", "row");
  CONTESTED.forEach((c) => {
    const b = el("button", "tile s0") as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-label", `${c.sym}, ${c.name}, ID ${c.id}, contested: note required, promotes when ${c.gate}`);
    const top = el("span", "t-top");
    top.append(el("span", "t-id", c.id));
    b.append(top, el("span", "t-sym", c.sym), el("span", "t-nm", c.name));
    const badge = el("span", "t-badge");
    badge.append(statusGlyph("provisional"), noDenom(), el("span", "", "contested"));
    b.append(badge);
    b.title = `Promotes when: ${c.gate}`;
    row.append(b);
  });
  s.append(row);
  return s;
}

function rulesView(kind: "laws" | "hazards"): HTMLElement {
  const wrap = el("section", "");
  if (kind === "hazards") {
    const n = el("div", "denom-note claim");
    n.append(noDenom());
    n.append(document.createTextNode(
      "Every rule below records failures. Not one records survivors. X2 describes a combination live in a great many protocols that have never been drained — the rule cannot say why, because there is no sample size. Read these as categories, never as measurements."));
    wrap.append(n);
  }
  const list = el("div", "rules");
  (kind === "laws" ? LAWS : HAZARDS).forEach((it: any) => {
    const b = el("button", `rule${kind === "hazards" ? " hz" : ""}`) as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-pressed", String(state.rule === it.id));
    b.append(el("span", "rid", it.id));
    const body = el("span");
    body.append(el("span", "stmt", kind === "laws" ? it.rule : it.combo));
    if (kind === "hazards") body.append(el("span", "why claim", it.grounding));
    b.append(body);
    const right = el("span");
    if (kind === "hazards") {
      const cl = el("span", `hz-class hz-${it.cls}`);
      cl.append(el("span", `hz-chip ${it.cls}`), document.createTextNode(HZ_WORD[it.cls as "F"]));
      right.append(cl);
    } else right.append(el("span", "hz-class", it.async === "no" ? "not async-safe" : "async-safe"));
    b.append(right);
    b.addEventListener("click", () => {
      state.rule = state.rule === it.id ? null : it.id;
      render();
      announce(state.rule ? `Rule ${it.id} selected. ${ELEMENTS.filter(matches).length} member elements.` : "Cleared.");
    });
    list.append(b);
  });
  wrap.append(list);
  return wrap;
}

function seg(label: string, opts: [string, string][], get: () => string, set: (v: string) => void) {
  const w = el("div", "ctl");
  w.append(el("span", "lbl", label));
  const s = el("div", "seg");
  opts.forEach(([v, t]) => {
    const b = el("button", "", t) as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-pressed", String(get() === v));
    b.addEventListener("click", () => set(v));
    s.append(b);
  });
  w.append(s);
  return w;
}

/* --------------------------------------------------------------- render */

function render() {
  const app = document.getElementById("app")!;
  const scroll = window.scrollY;
  app.textContent = "";

  const skip = el("a", "skip", "Skip to the table") as HTMLAnchorElement;
  skip.href = "#table";
  app.append(skip);

  /* hero */
  const hero = el("header", "hero");
  const ht = el("div", "hero-t");
  ht.append(el("h1", "", "The Elements of DeFi"));
  ht.append(el("p", "thesis claim",
    "DeFi does not have an innovation problem. It has a vocabulary problem. Nearly every protocol ever shipped is a recombination of about fifty recurring mechanisms — and once you can name them, most of the industry stops looking novel and starts looking legible."));
  ht.append(el("p", "disavowal claim",
    "Call it a periodic table if you like, but it is not one: no periodic law, no atomic number, nothing recurring down a column. Chemistry discovered its elements. These were designed, in a hurry, by people shipping to production — which is exactly why the combinations are the part worth writing down."));
  hero.append(ht);
  const meta = el("div", "hero-m");
  meta.append(seg("Theme", [["dark", "Dark"], ["light", "Light"]],
    () => document.documentElement.dataset.theme || "dark",
    (v) => { document.documentElement.dataset.theme = v; render(); }));
  meta.append(el("div", "version", `${ATLAS_VERSION} · reviewed ${ATLAS_REVIEWED}`));
  meta.append(el("div", "version", "48 core · 10 candidate · 10 contested · 29 laws · 19 hazards"));
  hero.append(meta);
  app.append(hero);

  app.append(protocolRail());
  const ro = readout();
  if (ro) app.append(ro);

  app.append(howToRead());

  /* controls */
  const ctl = el("div", "controls");
  ctl.append(seg("View", [["elements", "The table"], ["laws", "Laws"], ["hazards", "Hazards"]],
    () => state.view, (v) => { state.view = v as View; state.rule = null; render(); }));
  if (state.view === "elements") {
    ctl.append(seg("Arrangement", [["matrix", "By depth"], ["strata", "By family"]],
      () => state.layout, (v) => {
        state.layout = v as Layout;
        const host = document.getElementById("table")!;
        withFlip(() => { host.textContent = ""; host.append(buildGrid()); applyProjection(); });
        announce(v === "matrix"
          ? "Arranged by depth: five prerequisite rows."
          : "Arranged by family: sixteen substitution groups.");
        document.querySelectorAll<HTMLButtonElement>(".controls .seg button").forEach((b) => {
          if (b.textContent === "By depth") b.setAttribute("aria-pressed", String(v === "matrix"));
          if (b.textContent === "By family") b.setAttribute("aria-pressed", String(v === "strata"));
        });
      }));
    ctl.append(seg("Dimension", [["2d", "Flat"], ["3d", "3D"]],
      () => (state.three ? "3d" : "2d"),
      (v) => {
        const want = v === "3d";
        if (want === state.three) return;
        state.three = want;
        if (want) { enter3D(); announce("Three-dimensional view. Drag the background to tilt; it springs back."); }
        else { exit3D(); announce("Flat view."); }
      }));
    ctl.append(seg("Reading order", [["group", "By group"], ["stratum", "By stratum"], ["id", "By ID"]],
      () => state.order, (v) => { state.order = v as Order; announce(`Reading order: ${v}.`); render(); }));
    const sw = el("div", "ctl");
    const lb = el("label", "", "Search"); lb.setAttribute("for", "q");
    sw.append(lb);
    const inp = el("input") as HTMLInputElement;
    inp.type = "search"; inp.id = "q"; inp.value = state.query;
    inp.placeholder = "symbol, name or ID";
    inp.addEventListener("input", () => {
      state.query = inp.value;
      applyProjection();
      announce(`${ELEMENTS.filter(matches).length} of ${ELEMENTS.length} shown.`);
    });
    sw.append(inp);
    ctl.append(sw);
  }
  app.append(ctl);

  const map = el("div", "mapping");
  map.innerHTML = state.view === "elements"
    ? (state.layout === "matrix"
      ? "<b>Row</b> = prerequisite depth, exactly. <b>Blocks</b> inside a row are families of substitutes. Order within a block is <b>not</b> semantic."
      : "<b>Block</b> = a family of substitutes — everything inside answers the same question. The <b>S-token</b> on each tile is its depth.")
    : state.view === "laws"
      ? "<b>→</b> means <b>requires</b>. Select a law to see only the elements it names."
      : "Membership is <b>categorical</b> — never a magnitude, never a probability.";
  app.append(map);

  const main = el("main");
  main.id = "table";
  app.append(main);

  if (state.view === "elements") {
    main.append(buildGrid());
    applyProjection();
    const first = orderedElements().find(matches);
    tiles.forEach((t) => (t.tabIndex = -1));
    if (first) tiles.get(first.id)!.tabIndex = 0;
    app.append(contestedPanel());
  } else {
    main.append(rulesView(state.view));
  }

  app.append(howToThink());
  app.append(legend());

  const foot = el("footer", "foot");
  foot.append(el("p", "claim",
    "This table explains roughly two thirds of DeFi incidents by count and a minority of them by dollars. That is not a defect in the table — it is the most useful finding on this page. Your largest risk is not your financial design. It is your keys, your signing interface and your build pipeline. Get the mechanism right and you have eliminated the failures people write papers about, not the ones that actually took the money."));
  app.append(foot);

  const live = el("div", "sr");
  live.id = "live";
  live.setAttribute("aria-live", "polite");
  app.append(live);

  window.scrollTo(0, scroll);
}

ELEMENTS.forEach((e) => tiles.set(e.id, buildTile(e)));

const h = location.hash.slice(1);
const parts = h.split("&");
const pPart = parts.find((x) => x.startsWith("p="));
if (pPart && PROTOCOLS.some((p) => p.id === pPart.slice(2))) {
  state.protocol = pPart.slice(2);
}
if (parts.includes("3d")) state.three = true;
render();
if (state.three) requestAnimationFrame(() => enter3D());
if (h && tiles.has(h)) { focusTile(h); select(h); }
