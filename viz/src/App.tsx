import { useMemo, useState } from "react";
import {
  AnimatePresence,
  LayoutGroup,
  motion,
  useReducedMotion,
} from "framer-motion";
import {
  ATOM_LABEL,
  BONDS,
  ELEMENTS,
  GROUPS,
  HAZARDS,
  LAWS,
  PROVISIONAL,
  SCREEN,
  SPECTRUM,
  STRATA,
  type Atom,
  type Element,
  type Status,
} from "./data";

const STRAT_VAR = ["var(--s0)", "var(--s1)", "var(--s2)", "var(--s3)", "var(--s4)"];

const STATUS_LABEL: Record<Status, string> = {
  core: "Core",
  candidate: "Candidate",
  provisional: "Provisional",
  limit: "Degenerate limit",
};

type View = "elements" | "bonds" | "hazards" | "method";
type Axis = "group" | "stratum";

const TABS: { id: View; label: string }[] = [
  { id: "elements", label: "Elements" },
  { id: "bonds", label: "Bonds & laws" },
  { id: "hazards", label: "Hazards" },
  { id: "method", label: "Method" },
];

/* ------------------------------------------------------------------ tile */

function Tile({
  el,
  dim,
  selected,
  onSelect,
  reduce,
}: {
  el: Element;
  dim: boolean;
  selected: boolean;
  onSelect: () => void;
  reduce: boolean;
}) {
  return (
    <motion.button
      layout={reduce ? false : "position"}
      layoutId={reduce ? undefined : el.id}
      initial={reduce ? false : { opacity: 0, y: 8 }}
      animate={{ opacity: dim ? 0.16 : 1, y: 0 }}
      exit={reduce ? undefined : { opacity: 0, scale: 0.96 }}
      transition={{
        layout: { type: "spring", stiffness: 260, damping: 30 },
        opacity: { duration: 0.22 },
        y: { duration: 0.28 },
      }}
      whileHover={reduce || dim ? undefined : { y: -3 }}
      className={`tile is-${el.status}${selected ? " selected" : ""}`}
      onClick={onSelect}
      aria-label={`${el.sym} — ${el.name}`}
    >
      <span className="stratum-bar" style={{ background: STRAT_VAR[el.stratum] }} />
      <span className="id">{el.id}</span>
      <span className="sym">{el.sym}</span>
      <span className="nm">{el.name}</span>
      <span className="foot">
        <span className={`atom is-${el.atom}`}>{el.atom}</span>
        {el.disc ? <span className="disc-dot" title="Carries a mandatory discriminator" /> : null}
      </span>
    </motion.button>
  );
}

/* -------------------------------------------------------------- elements */

function ElementsView({
  axis,
  matches,
  selected,
  setSelected,
  reduce,
}: {
  axis: Axis;
  matches: (el: Element) => boolean;
  selected: Element | null;
  setSelected: (e: Element | null) => void;
  reduce: boolean;
}) {
  const blocks = useMemo(() => {
    if (axis === "group") {
      return GROUPS.map((g) => ({
        key: g.id,
        ord: g.id,
        name: g.name,
        blurb: g.boundary,
        items: ELEMENTS.filter((e) => e.group === g.id),
      })).filter((b) => b.items.length > 0);
    }
    return STRATA.map((s) => ({
      key: `S${s.id}`,
      ord: s.label,
      name: s.name,
      blurb: s.desc,
      items: ELEMENTS.filter((e) => e.stratum === s.id),
    }));
  }, [axis]);

  return (
    <LayoutGroup>
      {blocks.map((b) => {
        const shown = b.items.filter(matches).length;
        return (
          <motion.section layout={!reduce} key={b.key} className="axis-block">
            <div className="axis-head">
              <span className="ord">{b.ord}</span>
              <span className="nm">{b.name}</span>
              <span className="bd">{b.blurb}</span>
              <span className="ct">
                {shown}/{b.items.length}
              </span>
            </div>
            <div className="grid">
              {b.items.map((el) => (
                <Tile
                  key={el.id}
                  el={el}
                  dim={!matches(el)}
                  selected={selected?.id === el.id}
                  onSelect={() => setSelected(el)}
                  reduce={reduce}
                />
              ))}
            </div>
          </motion.section>
        );
      })}
    </LayoutGroup>
  );
}

/* ---------------------------------------------------------------- drawer */

function Drawer({
  el,
  onClose,
  reduce,
}: {
  el: Element;
  onClose: () => void;
  reduce: boolean;
}) {
  const group = GROUPS.find((g) => g.id === el.group)!;
  const stratum = STRATA[el.stratum];
  const laws = LAWS.filter((l) => new RegExp(`\\b${el.sym}\\b`).test(l.rule));
  const hazards = HAZARDS.filter((h) => new RegExp(`\\b${el.sym}\\b`).test(h.combo));

  return (
    <>
      <motion.div
        className="scrim"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.18 }}
        onClick={onClose}
      />
      <motion.aside
        className="drawer"
        initial={reduce ? { opacity: 0 } : { x: 40, opacity: 0 }}
        animate={reduce ? { opacity: 1 } : { x: 0, opacity: 1 }}
        exit={reduce ? { opacity: 0 } : { x: 40, opacity: 0 }}
        transition={{ type: "spring", stiffness: 320, damping: 34 }}
        aria-label={`${el.sym} detail`}
      >
        <button className="drawer-close" onClick={onClose}>
          CLOSE ✕
        </button>
        <div className="d-id">{el.id}</div>
        <div className="d-sym">{el.sym}</div>
        <div className="d-nm">{el.name}</div>
        <p className="d-def">{el.def}</p>
        {el.note ? <p className="d-note">{el.note}</p> : null}

        <dl className="meta">
          <dt>Status</dt>
          <dd>{STATUS_LABEL[el.status]}</dd>
          <dt>Group</dt>
          <dd>
            {group.id} · {group.name}
          </dd>
          <dt>Stratum</dt>
          <dd>
            <span style={{ color: STRAT_VAR[el.stratum] }}>{stratum.label}</span> · {stratum.name}
          </dd>
          <dt>Asynchrony</dt>
          <dd>{ATOM_LABEL[el.atom]}</dd>
          {el.disc ? (
            <>
              <dt>Discriminator</dt>
              <dd>{el.disc}</dd>
            </>
          ) : null}
        </dl>

        {laws.length > 0 ? (
          <>
            <div className="d-section-title">Laws naming {el.sym}</div>
            {laws.map((l) => (
              <div className="rule" key={l.id}>
                <span className="rid">{l.id}</span>  {l.rule}
              </div>
            ))}
          </>
        ) : null}

        {hazards.length > 0 ? (
          <>
            <div className="d-section-title">Hazards naming {el.sym}</div>
            {hazards.map((h) => (
              <div className="rule is-hazard" key={h.id}>
                <span className="rid">{h.id}</span>  {h.combo}
              </div>
            ))}
          </>
        ) : null}

        <div className="d-section-title">Role boundary</div>
        <p className="d-def" style={{ fontSize: 14 }}>
          {group.boundary}
        </p>
      </motion.aside>
    </>
  );
}

/* ------------------------------------------------------------------- app */

export default function App() {
  const reduce = !!useReducedMotion();
  const [view, setView] = useState<View>("elements");
  const [axis, setAxis] = useState<Axis>("group");
  const [q, setQ] = useState("");
  const [status, setStatus] = useState<Set<Status>>(new Set());
  const [atoms, setAtoms] = useState<Set<Atom>>(new Set());
  const [selected, setSelected] = useState<Element | null>(null);

  const toggle = <T,>(set: Set<T>, v: T, fn: (s: Set<T>) => void) => {
    const next = new Set(set);
    next.has(v) ? next.delete(v) : next.add(v);
    fn(next);
  };

  const matches = useMemo(() => {
    const needle = q.trim().toLowerCase();
    return (el: Element) => {
      if (status.size && !status.has(el.status)) return false;
      if (atoms.size && !atoms.has(el.atom)) return false;
      if (!needle) return true;
      return (
        el.sym.toLowerCase().includes(needle) ||
        el.name.toLowerCase().includes(needle) ||
        el.def.toLowerCase().includes(needle) ||
        el.id.toLowerCase().includes(needle)
      );
    };
  }, [q, status, atoms]);

  const shownCount = ELEMENTS.filter(matches).length;
  const counts = {
    core: ELEMENTS.filter((e) => e.status === "core").length,
    candidate: ELEMENTS.filter((e) => e.status === "candidate").length,
  };

  return (
    <div className="app">
      <header className="masthead">
        <div className="masthead-inner">
          <div className="wordmark">
            <h1>The DeFi State-Transition Atlas</h1>
            <span className="sub">v1.0 · post-council · informally, a periodic table</span>
          </div>
          <div className="masthead-right">
            <div className="counts">
              <span>
                <b>{counts.core}</b> core
              </span>
              <span>
                <b>{counts.candidate}</b> candidate
              </span>
              <span>
                <b>{PROVISIONAL.length}</b> provisional
              </span>
              <span>
                <b>{LAWS.length}</b> laws
              </span>
              <span>
                <b>{HAZARDS.length}</b> hazards
              </span>
            </div>
          </div>
        </div>
        <nav className="tabs" role="tablist">
          {TABS.map((t) => (
            <button
              key={t.id}
              role="tab"
              aria-selected={view === t.id}
              className="tab"
              onClick={() => setView(t.id)}
            >
              {t.label}
              {view === t.id ? (
                <motion.span
                  className="tab-marker"
                  layoutId={reduce ? undefined : "tabmarker"}
                  transition={{ type: "spring", stiffness: 400, damping: 34 }}
                />
              ) : null}
            </button>
          ))}
        </nav>
      </header>

      <div className="stage">
        {view === "elements" ? (
          <aside className="rail">
            <div className="rail-group">
              <div className="rail-title">Arrange by</div>
              <div className="seg">
                <button aria-pressed={axis === "group"} onClick={() => setAxis("group")}>
                  Group
                </button>
                <button aria-pressed={axis === "stratum"} onClick={() => setAxis("stratum")}>
                  Stratum
                </button>
              </div>
              <p className="rail-note" style={{ marginTop: 10, borderTop: "none", paddingTop: 0 }}>
                Groups answer <em>what could sit here instead</em>. Strata answer{" "}
                <em>what must already exist</em>. The two axes are orthogonal — switch to watch
                every element relocate.
              </p>
            </div>

            <div className="rail-group">
              <div className="rail-title">Search</div>
              <input
                className="search"
                placeholder="symbol, name, definition…"
                value={q}
                onChange={(e) => setQ(e.target.value)}
              />
            </div>

            <div className="rail-group">
              <div className="rail-title">Status</div>
              <div className="chips">
                {(["core", "candidate", "provisional", "limit"] as Status[])
                  .filter((s) => ELEMENTS.some((e) => e.status === s))
                  .map((s) => (
                    <button
                      key={s}
                      className="chip"
                      aria-pressed={status.has(s)}
                      onClick={() => toggle(status, s, setStatus)}
                    >
                      {STATUS_LABEL[s]}
                    </button>
                  ))}
              </div>
            </div>

            <div className="rail-group">
              <div className="rail-title">Asynchrony</div>
              <div className="chips">
                {(["N", "R", "I"] as Atom[]).map((a) => (
                  <button
                    key={a}
                    className="chip"
                    aria-pressed={atoms.has(a)}
                    onClick={() => toggle(atoms, a, setAtoms)}
                  >
                    {a} · {ATOM_LABEL[a].replace("async-", "")}
                  </button>
                ))}
              </div>
            </div>

            <div className="rail-group">
              <div className="rail-title">Stratum</div>
              {STRATA.map((s) => (
                <div className="legend-row" key={s.id}>
                  <span className="k" style={{ color: STRAT_VAR[s.id] }}>
                    {s.label}
                  </span>
                  <span>{s.name}</span>
                </div>
              ))}
            </div>

            <div className="rail-group">
              <div className="rail-title">Reading a tile</div>
              <div className="legend-row">
                <span className="k">▸</span>
                <span>Solid fill — core</span>
              </div>
              <div className="legend-row">
                <span className="k">▸</span>
                <span>Dashed — candidate, usable but flagged</span>
              </div>
              <div className="legend-row">
                <span className="k">▸</span>
                <span>Dotted — degenerate limit</span>
              </div>
              <div className="legend-row">
                <span className="k">●</span>
                <span>Carries a mandatory discriminator</span>
              </div>
            </div>

            <p className="rail-note">
              Showing {shownCount} of {ELEMENTS.length}. Ten further candidates sit in the
              provisional register and are not drawn — they may not appear in a formula without a
              note.
            </p>
          </aside>
        ) : null}

        <main className="main">
          <AnimatePresence mode="wait">
            <motion.div
              key={view}
              initial={reduce ? false : { opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={reduce ? undefined : { opacity: 0, y: -6 }}
              transition={{ duration: 0.2 }}
            >
              {view === "elements" ? (
                <ElementsView
                  axis={axis}
                  matches={matches}
                  selected={selected}
                  setSelected={setSelected}
                  reduce={reduce}
                />
              ) : null}

              {view === "bonds" ? (
                <>
                  <p className="lede">
                    A protocol is not valid because its contracts can call each other. Each bond
                    type must be satisfied <strong>separately</strong> — most exploits are
                    interface-valid and economically or trustfully invalid.
                  </p>
                  <div className="bond-grid">
                    {BONDS.map((b) => (
                      <div className="bond" key={b.sym}>
                        <div className="bs">{b.sym}</div>
                        <div className="bn">{b.name}</div>
                        <div className="bq">{b.q}</div>
                        <div className="bf">{b.fail}</div>
                      </div>
                    ))}
                  </div>

                  <h2 className="section-h">Required-bond laws</h2>
                  <div className="list">
                    {LAWS.map((l) => (
                      <div className="row" key={l.id}>
                        <span className="rid">{l.id}</span>
                        <div className="body">
                          <div className="stmt">{l.rule}</div>
                        </div>
                        <div className="flags">
                          {l.isNew ? <span className="flag new">new in v1.0</span> : null}
                          <span className={`flag ${l.async === "no" ? "no" : ""}`}>
                            {l.async === "no" ? "not async-safe" : "async-safe"}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                </>
              ) : null}

              {view === "hazards" ? (
                <>
                  <p className="lede">
                    Every row below reports failures. <strong>None reports survivors.</strong> The
                    table has no denominator — X2 is instantiated by a large number of live
                    protocols, most of which have not been drained, and the rule as written cannot
                    say why.
                  </p>
                  <div className="callout">
                    <span className="lbl">Named double standard</span>
                    This document applies a false-positive-rate standard to reflexivity and then
                    exempts these rows from it. Survivor counts are owed and unmeasured.
                  </div>
                  <div className="list">
                    {HAZARDS.map((h) => (
                      <div className="row hz" key={h.id}>
                        <span className="rid">{h.id}</span>
                        <div className="body">
                          <div className="stmt">{h.combo}</div>
                          <div className="why">{h.grounding}</div>
                        </div>
                        <div className="flags">
                          <span className={`flag ${h.cls}`}>
                            {h.cls === "F" ? "forbidden" : h.cls === "H" ? "elevated" : "unverifiable"}
                          </span>
                          <span className="flag">base rate {h.base}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </>
              ) : null}

              {view === "method" ? (
                <>
                  <p className="lede">
                    The screen checks <strong>financial architecture</strong>. It cannot support a
                    launch decision on its own, and every row is mandatory and
                    non-short-circuiting.
                  </p>
                  <div className="steps">
                    {SCREEN.map((s) => (
                      <div className="step" key={s.n}>
                        <span className="sn">{s.n}</span>
                        <span className="sl">{s.label}</span>
                        <span className="sb">{s.body}</span>
                      </div>
                    ))}
                  </div>

                  <div className="callout">
                    <span className="lbl">What it would miss</span>
                    Wormhole and Nomad, which nominally had verification and failed in the
                    implementation. Euler, where every required element was present and one new
                    transition omitted the health check. A compiler-codegen reentrancy class, which
                    no row inspects. Ronin, because row 1 enumerates the protocol&rsquo;s own roles
                    but the verifier set&rsquo;s key concentration is what failed.
                  </div>

                  <h2 className="section-h">The atomicity spectrum</h2>
                  <div className="spectrum">
                    {SPECTRUM.map((s, i) => (
                      <div className="spec-row" key={s.level}>
                        <span
                          className="bar"
                          style={{
                            background: `color-mix(in oklab, var(--s0), var(--s4) ${(i / 5) * 100}%)`,
                          }}
                        />
                        <span className="lv">{s.level}</span>
                        <span className="rp">{s.repair}</span>
                      </div>
                    ))}
                  </div>
                  <div className="callout">
                    <span className="lbl">Standing prediction</span>
                    No cross-chain flash liquidity exists without an intermediary, precommitted
                    credit, or a shared rollback domain. <code>Fl</code> is the only
                    async-impossible element — anything marketed as &ldquo;cross-chain flash&rdquo;
                    is <code>Of+Rl+(Bs|Sl)</code>, which has a lender, a reservation and a loss
                    allocator that the word hides.
                  </div>

                  <h2 className="section-h">Provisional register</h2>
                  <div className="list">
                    {PROVISIONAL.map((p) => (
                      <div className="row" key={p.sym}>
                        <span className="rid">{p.sym}</span>
                        <div className="body">
                          <div className="stmt">{p.name}</div>
                          <div className="why">Promotes when: {p.gate}</div>
                        </div>
                        <div className="flags">
                          <span className="flag">not usable unnoted</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </>
              ) : null}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>

      <AnimatePresence>
        {selected ? (
          <Drawer el={selected} onClose={() => setSelected(null)} reduce={reduce} />
        ) : null}
      </AnimatePresence>
    </div>
  );
}
