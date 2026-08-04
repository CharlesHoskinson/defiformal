import "./styles.css";
import {
  ATLAS_REVIEWED,
  ATLAS_VERSION,
  ATOM_LABEL,
  BONDS,
  CHANGELOG,
  CONTESTED,
  ELEMENTS,
  GROUPS,
  HAZARDS,
  LAWS,
  STRATA,
  hazardsFor,
  lawsFor,
  type Atom,
  type Element,
  type Status,
} from "./data";

/* ------------------------------------------------------------------ state */

type Layout = "matrix" | "strata" | "twoup";
type Order = "group" | "stratum" | "id";
type View = "elements" | "laws" | "hazards";

const STATUS_WORD: Record<Status, string> = {
  core: "core",
  candidate: "candidate: recurrence evidence short",
  provisional: "contested: note required",
  limit: "degenerate limit: not an element",
};
const STATUS_GLYPH: Record<Status, string> = {
  core: "core", candidate: "candidate", provisional: "contested", limit: "limit",
};
const HZ_WORD = { F: "forbidden", H: "elevated", U: "unverifiable" } as const;

const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

const state = {
  view: "elements" as View,
  layout: (reduceMotion ? "twoup" : "matrix") as Layout,
  order: "group" as Order,
  query: "",
  status: new Set<Status>(),
  atoms: new Set<Atom>(),
  selected: null as string | null,
  rule: null as string | null,
  motion: !reduceMotion,
};

/* -------------------------------------------------------------- helpers */

const el = <K extends keyof HTMLElementTagNameMap>(
  tag: K, cls?: string, text?: string
): HTMLElementTagNameMap[K] => {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (text != null) n.textContent = text;
  return n;
};

const groupOf = (g: string) => GROUPS.find((x) => x.id === g)!;

/** The nine-field accessible-name template. Every field is mandatory. */
function accessibleName(e: Element): string {
  const hz = hazardsFor(e.sym);
  const hzTxt = hz.length
    ? `hazard ${[...new Set(hz.map((h) => HZ_WORD[h.cls]))].join(" and ")}`
    : "no hazard membership";
  return [
    e.sym,
    e.name,
    `ID ${e.id}`,
    `group ${e.group} ${groupOf(e.group).name}`,
    `stratum S${e.stratum}`,
    STATUS_WORD[e.status],
    ATOM_LABEL[e.atom],
    hzTxt,
    e.disc ? "discriminator required" : "no discriminator required",
  ].join(", ");
}

function matches(e: Element): boolean {
  if (state.status.size && !state.status.has(e.status)) return false;
  if (state.atoms.size && !state.atoms.has(e.atom)) return false;
  if (state.rule) {
    const inLaw = lawsFor(e.sym).some((l) => l.id === state.rule);
    const inHz = hazardsFor(e.sym).some((h) => h.id === state.rule);
    if (!inLaw && !inHz) return false;
  }
  const q = state.query.trim().toLowerCase();
  if (!q) return true;
  return (
    e.sym.toLowerCase().includes(q) ||
    e.name.toLowerCase().includes(q) ||
    e.id.toLowerCase().includes(q)
  );
}

function announce(msg: string) {
  const live = document.getElementById("live")!;
  live.textContent = "";
  window.setTimeout(() => { live.textContent = msg; }, 30);
}

/* --------------------------------------------------------------- markers */

function statusGlyph(s: Status): HTMLElement {
  const g = el("span", `glyph ${STATUS_GLYPH[s]}`);
  g.setAttribute("aria-hidden", "true");
  return g;
}

/** The missing-denominator mark. Only where no denominator exists. */
function noDenom(): HTMLElement {
  const n = el("span", "nodenom");
  n.setAttribute("aria-hidden", "true");
  n.innerHTML = "<i>n</i><u></u><s></s>";
  n.title = "no denominator: exposure and survivors not collected";
  return n;
}

/* ----------------------------------------------------------------- tiles */

const tiles = new Map<string, HTMLButtonElement>();

function buildTile(e: Element): HTMLButtonElement {
  const b = el("button", `tile s${e.stratum}`) as HTMLButtonElement;
  b.type = "button";
  b.dataset.id = e.id;
  b.setAttribute("aria-label", accessibleName(e));
  b.setAttribute("aria-pressed", "false");
  b.tabIndex = -1;

  const top = el("span", "t-top");
  top.append(el("span", "t-id", e.id), el("span", "t-strat", `S${e.stratum}`));
  b.append(top, el("span", "t-sym", e.sym), el("span", "t-nm", e.name));

  const badge = el("span", "t-badge");
  badge.append(statusGlyph(e.status));
  if (e.status !== "core") badge.append(noDenom());
  const word = e.status === "core" ? "core"
    : e.status === "candidate" ? "candidate"
    : e.status === "limit" ? "limit" : "contested";
  badge.append(el("span", "", word));
  if (e.disc) {
    const d = el("span", "", "· disc");
    d.title = "carries a mandatory discriminator";
    badge.append(d);
  }
  b.append(badge);

  b.addEventListener("click", () => select(e.id));
  b.addEventListener("keydown", onTileKey);
  return b;
}

function orderedElements(): Element[] {
  const list = [...ELEMENTS];
  if (state.order === "group") {
    return list.sort((a, b) =>
      a.group.localeCompare(b.group) || a.stratum - b.stratum || a.id.localeCompare(b.id));
  }
  if (state.order === "stratum") {
    return list.sort((a, b) =>
      a.stratum - b.stratum || a.group.localeCompare(b.group) || a.id.localeCompare(b.id));
  }
  return list.sort((a, b) => a.id.localeCompare(b.id));
}

/* ------------------------------------------------------------ placements */

interface Placement { row: number; col: number }

function matrixPlacement() {
  const place = new Map<string, Placement>();
  const occ = new Map<string, Element[]>();
  for (const e of ELEMENTS) {
    const k = `${e.group}|${e.stratum}`;
    (occ.get(k) ?? occ.set(k, []).get(k)!).push(e);
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
    list.forEach((e, i) =>
      place.set(e.id, { row: bandStart[+sid] + i, col: gi + 2 }));
  }
  return { place, occ, bandRows, bandStart, totalRows: r - 1 };
}

function strataPlacement(perRow = 14) {
  const place = new Map<string, Placement>();
  const bandStart: number[] = [];
  let r = 2;
  for (const s of STRATA) {
    bandStart[s.id] = r;
    const list = ELEMENTS.filter((e) => e.stratum === s.id)
      .sort((a, b) => a.group.localeCompare(b.group) || a.id.localeCompare(b.id));
    list.forEach((e, i) =>
      place.set(e.id, { row: r + Math.floor(i / perRow), col: (i % perRow) + 2 }));
    r += Math.max(1, Math.ceil(list.length / perRow));
  }
  return { place, bandStart, totalRows: r - 1, perRow };
}

/* ------------------------------------------------------------- rendering */

function buildMatrixGrid(useClones: boolean): HTMLElement {
  const { place, occ, bandRows, bandStart } = matrixPlacement();
  const g = el("div", "grid");
  g.style.gridTemplateColumns = `4.5rem repeat(${GROUPS.length}, minmax(5.2rem, 1fr))`;

  GROUPS.forEach((grp, i) => {
    const h = el("div", "axis-x", grp.id);
    h.title = `${grp.id} — ${grp.name}. ${grp.boundary}`;
    h.style.gridRow = "1";
    h.style.gridColumn = String(i + 2);
    h.setAttribute("aria-hidden", "true");
    g.append(h);
  });

  STRATA.forEach((s, i) => {
    const y = el("div", "axis-y");
    y.innerHTML = `<b>S${s.id}</b>`;
    y.title = `S${s.id} — ${s.name}. ${s.desc}`;
    y.style.gridRow = `${bandStart[s.id]} / span ${bandRows[i]}`;
    y.style.gridColumn = "1";
    y.setAttribute("aria-hidden", "true");
    g.append(y);

    GROUPS.forEach((grp, gi) => {
      const list = occ.get(`${grp.id}|${s.id}`) ?? [];
      const c = el("div", `cell${list.length ? "" : " empty"}`);
      c.style.gridRow = `${bandStart[s.id]} / span ${bandRows[i]}`;
      c.style.gridColumn = String(gi + 2);
      c.setAttribute("aria-hidden", "true");
      if (list.length > 1) c.append(el("span", "occ", String(list.length)));
      g.append(c);
    });
  });

  placeTiles(g, place, useClones);
  return g;
}

function buildStrataGrid(useClones: boolean): HTMLElement {
  const { place, bandStart, perRow } = strataPlacement();
  const g = el("div", "grid");
  g.style.gridTemplateColumns = `4.5rem repeat(${perRow}, minmax(5.4rem, 1fr))`;
  STRATA.forEach((s) => {
    const y = el("div", "axis-y");
    y.innerHTML = `<b>S${s.id}</b>`;
    y.style.gridRow = String(bandStart[s.id]);
    y.style.gridColumn = "1";
    y.setAttribute("aria-hidden", "true");
    g.append(y);
  });
  placeTiles(g, place, useClones);
  return g;
}

function placeTiles(g: HTMLElement, place: Map<string, Placement>, useClones: boolean) {
  for (const e of orderedElements()) {
    const p = place.get(e.id);
    if (!p) continue;
    let node: HTMLElement;
    if (useClones) {
      node = tiles.get(e.id)!.cloneNode(true) as HTMLElement;
      node.setAttribute("aria-hidden", "true");
      (node as HTMLButtonElement).tabIndex = -1;
      node.dataset.clone = "1";
    } else {
      node = tiles.get(e.id)!;
    }
    node.style.gridRow = String(p.row);
    node.style.gridColumn = String(p.col);
    g.append(node);
  }
}

function mappingText(): string {
  if (state.layout === "strata")
    return "<b>Band</b> = prerequisite category. Horizontal position within a band is not semantic. Position predicts nothing else.";
  if (state.layout === "twoup")
    return "<b>Left:</b> column = substitutability family, band = prerequisite category. <b>Right:</b> bands only. The same elements, two arrangements, neither canonical.";
  return "<b>Column</b> = substitutability family. <b>Band</b> = prerequisite category. Order within a cell is <b>not</b> semantic. Position predicts nothing else.";
}

/* ------------------------------------------------------------------ FLIP */

function withFlip(mutate: () => void) {
  if (!state.motion) { mutate(); return; }
  const first = new Map<string, DOMRect>();
  tiles.forEach((t, id) => { if (t.isConnected) first.set(id, t.getBoundingClientRect()); });
  mutate();
  tiles.forEach((t, id) => {
    const a = first.get(id);
    if (!a || !t.isConnected) return;
    const b = t.getBoundingClientRect();
    const dx = a.left - b.left, dy = a.top - b.top;
    if (!dx && !dy) return;
    t.animate(
      [{ transform: `translate(${dx}px, ${dy}px)` }, { transform: "none" }],
      { duration: 280, easing: "cubic-bezier(.2,.7,.3,1)" }
    );
  });
}

/* -------------------------------------------------------------- selection */

function select(id: string | null) {
  state.selected = id;
  tiles.forEach((t, tid) => t.setAttribute("aria-pressed", String(tid === id)));
  document.querySelectorAll<HTMLElement>('[data-clone="1"]').forEach((c) =>
    c.setAttribute("aria-pressed", String(c.dataset.id === id)));
  if (id) {
    history.replaceState(null, "", `#${id}`);
    openDetail(ELEMENTS.find((e) => e.id === id)!);
    drawConnector();
  }
}

function onTileKey(ev: KeyboardEvent) {
  const list = orderedElements().filter(matches);
  const cur = (ev.currentTarget as HTMLElement).dataset.id!;
  const i = list.findIndex((e) => e.id === cur);
  let next = -1;
  if (ev.key === "ArrowRight" || ev.key === "ArrowDown") next = Math.min(i + 1, list.length - 1);
  else if (ev.key === "ArrowLeft" || ev.key === "ArrowUp") next = Math.max(i - 1, 0);
  else if (ev.key === "Home") next = 0;
  else if (ev.key === "End") next = list.length - 1;
  else if (/^[a-zA-Z]$/.test(ev.key)) {
    const from = list.slice(i + 1).concat(list.slice(0, i + 1));
    const hit = from.find((e) => e.sym.toLowerCase().startsWith(ev.key.toLowerCase()));
    if (hit) next = list.findIndex((e) => e.id === hit.id);
  } else return;
  ev.preventDefault();
  if (next < 0) return;
  focusTile(list[next].id);
}

function focusTile(id: string) {
  tiles.forEach((t) => (t.tabIndex = -1));
  const t = tiles.get(id)!;
  t.tabIndex = 0;
  t.focus();
}

/* ---------------------------------------------------------------- detail */

let dialogEl: HTMLDialogElement | null = null;

function openDetail(e: Element) {
  dialogEl?.remove();
  const d = el("dialog", "detail") as HTMLDialogElement;
  d.setAttribute("aria-label", `${e.sym} — ${e.name}`);

  const close = el("button", "d-close", "CLOSE ✕");
  close.addEventListener("click", () => d.close());
  d.append(close);

  d.append(el("div", "version", e.id));
  d.append(el("div", "d-sym", e.sym));
  d.append(el("div", "d-nm", e.name));
  const def = el("p", "d-def claim", e.def);
  d.append(def);
  if (e.note) d.append(el("p", "d-note claim", e.note));

  const chg = CHANGELOG[e.id];
  if (chg) {
    const c = el("p", "d-note claim",
      `Classification changed during review: ${chg.from} → ${chg.to}. ${chg.why}`);
    d.append(c);
  }

  const dl = el("dl", "meta");
  const add = (k: string, v: string) => { dl.append(el("dt", "", k), el("dd", "", v)); };
  add("Status", STATUS_WORD[e.status]);
  add("Group", `${e.group} · ${groupOf(e.group).name}`);
  add("Role boundary", groupOf(e.group).boundary);
  add("Stratum", `S${e.stratum} · ${STRATA[e.stratum].name}`);
  add("Asynchrony", ATOM_LABEL[e.atom]);
  if (e.disc) add("Discriminator", e.disc);
  d.append(dl);

  const laws = lawsFor(e.sym);
  if (laws.length) {
    d.append(el("div", "d-h", `Laws naming ${e.sym} (${laws.length})`));
    laws.forEach((l) => d.append(el("div", "d-item", `${l.id}  ${l.rule}`)));
  }
  const hz = hazardsFor(e.sym);
  if (hz.length) {
    d.append(el("div", "d-h", `Hazard rules naming ${e.sym} (${hz.length})`));
    hz.forEach((h) => {
      const item = el("div", "d-item");
      const cls = el("span", `hz-class hz-${h.cls}`);
      cls.append(el("span", `hz-chip ${h.cls}`), document.createTextNode(HZ_WORD[h.cls]));
      item.append(cls, document.createTextNode(` ${h.id}  ${h.combo}`));
      d.append(item);
    });
    d.append(el("p", "d-note claim",
      "Case-only evidence; exposure and survivors not collected; probability not estimated."));
  }

  document.body.append(d);
  dialogEl = d;
  d.showModal();
  d.addEventListener("close", () => {
    const t = tiles.get(e.id);
    if (t) { t.tabIndex = 0; t.focus(); }
  });
}

/* ------------------------------------------------------------- connector */

function drawConnector() {
  document.getElementById("connector")?.remove();
  if (state.layout !== "twoup" || !state.selected) return;
  const board = document.querySelector(".board.two-up") as HTMLElement | null;
  if (!board) return;
  const a = tiles.get(state.selected);
  const b = board.querySelector<HTMLElement>(`[data-clone="1"][data-id="${state.selected}"]`);
  if (!a || !b) return;
  const br = board.getBoundingClientRect();
  const ar = a.getBoundingClientRect(), r2 = b.getBoundingClientRect();
  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.id = "connector";
  svg.setAttribute("aria-hidden", "true");
  Object.assign(svg.style, {
    position: "absolute", left: "0", top: "0", width: `${br.width}px`,
    height: `${br.height}px`, pointerEvents: "none", overflow: "visible",
  } as CSSStyleDeclaration);
  const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
  line.setAttribute("x1", String(ar.right - br.left));
  line.setAttribute("y1", String(ar.top + ar.height / 2 - br.top));
  line.setAttribute("x2", String(r2.left - br.left));
  line.setAttribute("y2", String(r2.top + r2.height / 2 - br.top));
  line.setAttribute("stroke", "currentColor");
  line.setAttribute("stroke-width", "1");
  line.setAttribute("stroke-dasharray", "3 3");
  svg.append(line);
  board.style.position = "relative";
  board.append(svg);
}

/* ----------------------------------------------------------------- views */

function renderBoard(host: HTMLElement) {
  host.textContent = "";
  const board = el("div", `board${state.layout === "twoup" ? " two-up" : ""}`);

  if (state.layout === "matrix") board.append(buildMatrixGrid(false));
  else if (state.layout === "strata") board.append(buildStrataGrid(false));
  else {
    const left = el("section");
    left.append(el("h2", "panel-title", "Group × stratum"), buildMatrixGrid(false));
    const right = el("section");
    right.setAttribute("aria-hidden", "true");
    right.append(el("h2", "panel-title", "Stratum bands (mirror)"), buildStrataGrid(true));
    board.append(left, right);
  }
  host.append(board);

  const shown = ELEMENTS.filter(matches).length;
  tiles.forEach((t, id) => {
    const e = ELEMENTS.find((x) => x.id === id)!;
    t.classList.toggle("dim", !matches(e));
  });
  document.querySelectorAll<HTMLElement>('[data-clone="1"]').forEach((c) => {
    const e = ELEMENTS.find((x) => x.id === c.dataset.id)!;
    c.classList.toggle("dim", !matches(e));
  });

  const first = orderedElements().find(matches);
  tiles.forEach((t) => (t.tabIndex = -1));
  if (first) tiles.get(first.id)!.tabIndex = 0;

  host.append(contestedPanel());
  requestAnimationFrame(drawConnector);
  return shown;
}

function contestedPanel(): HTMLElement {
  const s = el("section", "contested");
  s.append(el("h2", "", "Contested register — 10 entries"));
  s.append(el("p", "why claim",
    "Held apart from the matrix because a necessary criterion is genuinely contested. Not usable in a formula without a note. This separation means “note required” — not “displaced for convenience”."));
  const row = el("div", "row");
  CONTESTED.forEach((c) => {
    const b = el("button", "tile s0") as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-label",
      `${c.sym}, ${c.name}, ID ${c.id}, contested: note required, promotes when ${c.gate}`);
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

function renderRules(host: HTMLElement, kind: "laws" | "hazards") {
  host.textContent = "";
  if (kind === "hazards") {
    const note = el("div", "denom-note claim");
    note.append(noDenom());
    note.append(document.createTextNode(
      "Case-only evidence; exposure and survivors not collected; probability not estimated. These rules record failures and never survivors — membership is categorical, and nothing here is a measured risk."));
    host.append(note);
  }
  const list = el("div", "rules");
  const items = kind === "laws" ? LAWS : HAZARDS;
  items.forEach((it: any) => {
    const b = el("button", `rule${kind === "hazards" ? " hz" : ""}`) as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-pressed", String(state.rule === it.id));
    b.append(el("span", "rid", it.id));
    const body = el("span", "");
    body.append(el("span", "stmt", kind === "laws" ? it.rule : it.combo));
    if (kind === "hazards") body.append(el("span", "why claim", it.grounding));
    b.append(body);
    const right = el("span", "");
    if (kind === "hazards") {
      const cls = el("span", `hz-class hz-${it.cls}`);
      cls.append(el("span", `hz-chip ${it.cls}`), document.createTextNode(HZ_WORD[it.cls as "F"]));
      right.append(cls);
      const members = ELEMENTS.filter((e) => hazardsFor(e.sym).some((h) => h.id === it.id)).length;
      right.append(el("span", "why", ` ${members} elements`));
    } else {
      right.append(el("span", "hz-class", it.async === "no" ? "not async-safe" : "async-safe"));
    }
    b.append(right);
    b.addEventListener("click", () => {
      state.rule = state.rule === it.id ? null : it.id;
      const n = ELEMENTS.filter(matches).length;
      announce(state.rule
        ? `Rule ${it.id} selected. ${n} of ${ELEMENTS.length} elements are members.`
        : "Rule selection cleared.");
      render();
    });
    list.append(b);
  });
  host.append(list);
}

/* ---------------------------------------------------------------- chrome */

function segment(label: string, opts: [string, string][], get: () => string, set: (v: string) => void) {
  const wrap = el("div", "ctl");
  wrap.append(el("span", "lbl", label));
  const seg = el("div", "seg");
  opts.forEach(([v, t]) => {
    const b = el("button", "", t) as HTMLButtonElement;
    b.type = "button";
    b.setAttribute("aria-pressed", String(get() === v));
    b.addEventListener("click", () => set(v));
    seg.append(b);
  });
  wrap.append(seg);
  return wrap;
}

function render() {
  const app = document.getElementById("app")!;
  app.textContent = "";

  const skip = el("a", "skip", "Skip to the atlas") as HTMLAnchorElement;
  skip.href = "#board";
  app.append(skip);

  /* masthead */
  const mast = el("header", "mast");
  const top = el("div", "mast-top");
  const wm = el("div", "");
  wm.append(el("h1", "", "State-Transition Atlas"));
  wm.append(el("div", "version", `${ATLAS_VERSION} · reviewed ${ATLAS_REVIEWED} · 48 core, 10 candidate, 10 contested`));
  top.append(wm);
  const counts = el("div", "mast-right");
  counts.append(segment("Theme", [["dark", "Dark"], ["light", "Light"]],
    () => document.documentElement.dataset.theme || "dark",
    (v) => { document.documentElement.dataset.theme = v; }));
  top.append(counts);
  mast.append(top);

  /* the single permitted use of the phrase, inside its own denial */
  mast.append(el("p", "disavowal",
    "This is not a periodic table. There is no periodic law here, no natural atomic number, and no closure — properties do not recur down a column, and these elements were designed rather than discovered. Position records what the atlas observed; it predicts nothing."));
  app.append(mast);

  /* controls */
  const ctl = el("div", "controls");
  ctl.append(segment("View", [["elements", "Elements"], ["laws", "Laws"], ["hazards", "Hazards"]],
    () => state.view, (v) => { state.view = v as View; state.rule = null; render(); }));

  if (state.view === "elements") {
    ctl.append(segment("Arrangement", [["matrix", "Group × stratum"], ["strata", "Stratum bands"], ["twoup", "Both"]],
      () => state.layout,
      (v) => {
        const host = document.getElementById("board")!;
        state.layout = v as Layout;
        withFlip(() => renderBoard(host));
        document.getElementById("mapping")!.innerHTML = mappingText();
        announce(`Arrangement: ${v === "matrix" ? "group by stratum matrix" : v === "strata" ? "stratum bands" : "both, side by side"}.`);
        document.querySelectorAll<HTMLButtonElement>(".controls .seg button").forEach((b) => {
          if (["Group × stratum", "Stratum bands", "Both"].includes(b.textContent!))
            b.setAttribute("aria-pressed", String(
              (b.textContent === "Group × stratum" && v === "matrix") ||
              (b.textContent === "Stratum bands" && v === "strata") ||
              (b.textContent === "Both" && v === "twoup")));
        });
      }));

    ctl.append(segment("Reading order", [["group", "By group"], ["stratum", "By stratum"], ["id", "By ID"]],
      () => state.order,
      (v) => { state.order = v as Order; announce(`Reading order: ${v}.`); render(); }));

    const sw = el("div", "ctl");
    const lab = el("label", "", "Search");
    lab.setAttribute("for", "q");
    sw.append(lab);
    const inp = el("input") as HTMLInputElement;
    inp.type = "search"; inp.id = "q"; inp.value = state.query;
    inp.placeholder = "symbol, name or ID";
    inp.addEventListener("input", () => {
      state.query = inp.value;
      const n = ELEMENTS.filter(matches).length;
      announce(`${n} of ${ELEMENTS.length} elements shown.`);
      const host = document.getElementById("board")!;
      renderBoard(host);
    });
    inp.addEventListener("keydown", (ev) => {
      if (ev.key !== "Enter") return;
      const hit = orderedElements().find(matches);
      if (hit) { focusTile(hit.id); select(hit.id); }
    });
    sw.append(inp);
    ctl.append(sw);

    const stw = el("div", "ctl");
    stw.append(el("span", "lbl", "Status"));
    const chips = el("div", "chips");
    (["core", "candidate", "limit"] as Status[]).forEach((s) => {
      const b = el("button", "", s === "limit" ? "degenerate limit" : s) as HTMLButtonElement;
      b.type = "button";
      b.setAttribute("aria-pressed", String(state.status.has(s)));
      b.addEventListener("click", () => {
        state.status.has(s) ? state.status.delete(s) : state.status.add(s);
        const n = ELEMENTS.filter(matches).length;
        announce(`Filter changed. ${n} of ${ELEMENTS.length} elements shown.`);
        render();
      });
      chips.append(b);
    });
    stw.append(chips);
    ctl.append(stw);
  }
  app.append(ctl);

  const mapping = el("div", "mapping");
  mapping.id = "mapping";
  mapping.innerHTML = state.view === "elements" ? mappingText()
    : state.view === "laws"
      ? "Required-bond laws. <b>→</b> means <b>requires</b>. Selecting a law shows only the elements it names."
      : "Hazard rules. Membership is <b>categorical</b> — never a magnitude, never a probability.";
  app.append(mapping);

  const main = el("main", "");
  main.id = "board";
  app.append(main);

  if (state.view === "elements") renderBoard(main);
  else renderRules(main, state.view);

  app.append(legend());

  const foot = el("footer", "foot");
  foot.textContent = "Coverage = financial state transitions + typed bonds + authority policy + information exposure + reaction conditions. It does not predict operational compromise, implementation defects, or legal enforceability.";
  app.append(foot);

  const live = el("div", "sr");
  live.id = "live";
  live.setAttribute("aria-live", "polite");
  app.append(live);
}

function legend(): HTMLElement {
  const s = el("section", "legend");
  s.append(el("h2", "", "How to read this"));
  const cols = el("div", "legend-cols");

  const c1 = el("div", "");
  c1.append(el("div", "legend-item", ""));
  c1.lastElementChild!.textContent = "";
  const sr = el("div", "swatch-row");
  STRATA.forEach((st) => {
    const sw = el("span", "swatch");
    sw.style.background = `var(--s${st.id})`;
    sw.title = `S${st.id} — ${st.name}`;
    sr.append(sw);
  });
  c1.append(el("div", "legend-item", "Stratum S0 → S4"), sr);
  c1.append(el("p", "legend-note claim",
    "Stratum is the category of prerequisite an element needs to exist — not a risk score. It carries no colour: it is the band you are in, the S-token on the tile, and lightness only."));
  cols.append(c1);

  const c2 = el("div", "");
  (["core", "candidate", "provisional", "limit"] as Status[]).forEach((st) => {
    const i = el("div", "legend-item");
    i.append(statusGlyph(st));
    i.append(el("span", "", STATUS_WORD[st]));
    c2.append(i);
  });
  const nd = el("div", "legend-item");
  nd.append(noDenom());
  nd.append(el("span", "", "no denominator: exposure and survivors were never collected"));
  c2.append(nd);
  cols.append(c2);

  const c3 = el("div", "");
  (["F", "H", "U"] as const).forEach((k) => {
    const i = el("div", "legend-item");
    i.append(el("span", `hz-chip ${k}`));
    i.append(el("span", "", `hazard: ${HZ_WORD[k]}`));
    c3.append(i);
  });
  c3.append(el("p", "legend-note claim",
    "Colour appears in exactly one place in this interface: hazard class. If something is coloured, it is a hazard. Hazard classes are told apart by their label and mark, not by hue alone."));
  cols.append(c3);

  const c4 = el("div", "");
  BONDS.forEach((b) => {
    const i = el("div", "legend-item");
    i.append(el("span", "k", b.sym));
    i.append(el("span", "", `${b.name} — ${b.q}`));
    c4.append(i);
  });
  cols.append(c4);

  s.append(cols);
  return s;
}

/* ------------------------------------------------------------------ boot */

ELEMENTS.forEach((e) => tiles.set(e.id, buildTile(e)));
render();

const hash = location.hash.slice(1);
if (hash && tiles.has(hash)) { focusTile(hash); select(hash); }

window.addEventListener("resize", () => requestAnimationFrame(drawConnector));
