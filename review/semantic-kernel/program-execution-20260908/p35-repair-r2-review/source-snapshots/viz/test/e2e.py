"""Drive the built atlas in a real browser.

Mouse/3D interaction from the historical driver is retained. Keyboard
reachability, focus restoration, accessible names and reduced-motion behaviour
are asserted against the declared reading-order/name contract in atlas_contract.py,
not against a copy of viz/src/main.ts helpers.
"""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

from atlas_contract import (
    STATUS_WORD,
    declared_order,
    load_atlas,
    missing_name_fields,
    next_typeahead,
    self_check,
)

VIZ = Path(__file__).resolve().parents[1]
DIST = (VIZ / "dist" / "index.html").resolve()
URL = os.environ.get("ATLAS_VIZ_URL", DIST.as_uri())
CHROME = os.environ.get(
    "ATLAS_CHROME",
    str(Path.home() / ".cache/ms-playwright/chromium-1228/chrome-linux64/chrome"),
)
SCREEN_DIR = Path(os.environ.get("ATLAS_SCREENSHOT_DIR", "")) if os.environ.get("ATLAS_SCREENSHOT_DIR") else None
EVIDENCE_JSON = os.environ.get("ATLAS_E2E_EVIDENCE")

fails, notes = [], []
evidence = {
    "url": URL,
    "chrome": CHROME,
    "dist": str(DIST),
    "keyboard": [],
    "names": {},
    "reduced_motion": {},
    "mouse": [],
}


def check(cond, msg):
    (notes if cond else fails).append(("ok  " if cond else "FAIL ") + msg)
    return bool(cond)


def focused_tile(page):
    return page.evaluate(
        """() => {
      const a = document.activeElement;
      const t = a && a.closest ? a.closest('.tile') : null;
      if (!t) {
        return {
          id: null,
          sym: null,
          tag: a ? a.tagName : null,
          className: a ? a.className : null,
        };
      }
      return { id: t.dataset.id, sym: t.dataset.sym, label: t.getAttribute('aria-label') };
    }"""
    )


def table_tile_ids(page):
    return page.evaluate(
        """() => Array.from(document.querySelectorAll('#table button.tile'))
            .map(t => t.dataset.id)"""
    )


def all_tile_names(page):
    return page.evaluate(
        """() => Array.from(document.querySelectorAll('button.tile')).map(t => ({
            id: t.dataset.id || null,
            sym: t.dataset.sym || null,
            where: t.closest('.contested') ? 'contested' : (t.closest('#table') ? 'table' : 'other'),
            label: t.getAttribute('aria-label') || '',
            text: t.innerText,
          }))"""
    )


def click_seg(page, label):
    page.get_by_role("button", name=label, exact=True).click()
    page.wait_for_timeout(250)


def enter_3d(page):
    click_seg(page, "3D")
    page.wait_for_timeout(1400)
    check(page.locator("#table.is3d").count() == 1, "3D: is3d class applied after Dimension click")


def ensure_flat(page):
    if page.locator("#table.is3d").count():
        click_seg(page, "Flat")
        page.wait_for_timeout(900)


def wait_ready(page):
    page.wait_for_function("() => document.querySelectorAll('#table .tile').length >= 1")
    page.wait_for_timeout(200)


def focus_grid(page):
    handle = page.locator('#table .tile[tabindex="0"]')
    check(handle.count() >= 1, f"roving tabindex present ({handle.count()})")
    if handle.count() < 1:
        return None
    handle.first.focus()
    page.wait_for_timeout(50)
    return focused_tile(page)


def walk_arrows(page, expected_ids, direction="ArrowRight"):
    got = []
    cur = focused_tile(page)
    if not cur or not cur.get("id"):
        return got
    got.append(cur["id"])
    for _ in range(len(expected_ids) - 1):
        page.keyboard.press(direction)
        nxt = focused_tile(page)
        got.append(nxt.get("id") if nxt else None)
    return got


def run_mouse_historical(page):
    section = []
    n = page.locator(".tile").count()
    check(n >= 59, f"flat: tiles rendered ({n})")
    section.append({"tiles": n})
    page.locator('.tile[data-sym="Pl"]').first.click()
    page.wait_for_timeout(500)
    check(page.locator("dialog.detail").count() == 1, "flat: element dialog opens on tile click")
    check(
        "Pooled lending" in page.locator("dialog.detail").inner_text(),
        "flat: dialog shows the right element",
    )
    page.keyboard.press("Escape")
    page.wait_for_timeout(300)

    page.get_by_role("button", name="Aave v3").click()
    page.wait_for_timeout(600)
    check(
        page.locator(".tile.member").count() == 10,
        f"flat: Aave projects 10 members ({page.locator('.tile.member').count()})",
    )
    check(page.locator("#readout").count() == 1, "flat: readout appears")

    page.get_by_role("button", name="3D", exact=True).click()
    page.wait_for_timeout(1400)
    check(page.locator("#table.is3d").count() == 1, "3D: is3d class applied")
    n3d = page.evaluate("document.querySelectorAll('#table [style*=matrix3d]').length")
    check(n3d > 40, f"3D: tiles lifted into the scene ({n3d} transformed)")
    pe = page.evaluate(
        """() => {
      const t = document.querySelector('#table.is3d .tile');
      return t ? getComputedStyle(t).pointerEvents : 'none-found';
    }"""
    )
    check(pe == "auto", f"3D: tiles are pointer-interactive (pointer-events: {pe})")
    page.locator('#table.is3d .tile[data-sym="Ct"]').first.scroll_into_view_if_needed()
    page.wait_for_timeout(400)
    hit = page.evaluate(
        """() => {
      const t = document.querySelector('#table.is3d .tile[data-sym="Ct"]');
      if (!t) return 'no tile';
      const r = t.getBoundingClientRect();
      if (r.width < 2) return 'zero size';
      const cx = r.left + r.width/2, cy = r.top + r.height/2;
      if (cx < 0 || cy < 0 || cx > innerWidth || cy > innerHeight) return 'offscreen';
      const el = document.elementFromPoint(cx, cy);
      return el && el.closest('.tile') ? 'reachable' : 'blocked by ' + (el ? el.className : 'null');
    }"""
    )
    check(hit == "reachable", f"3D: tile is hit-testable at its centre ({hit})")
    try:
        page.locator('#table.is3d .tile[data-sym="Ct"]').first.click(timeout=4000)
        page.wait_for_timeout(500)
        check(page.locator("dialog.detail").count() == 1, "3D: element dialog opens on tile click")
        page.keyboard.press("Escape")
        page.wait_for_timeout(250)
    except Exception as ex:
        check(False, f"3D: tile click threw ({str(ex)[:90]})")

    page.get_by_role("button", name="Terra / Anchor").click()
    page.wait_for_timeout(1500)
    check(page.locator("#table.is3d").count() == 1, "3D: stays in 3D after protocol change")
    check(
        page.locator(".tile.member").count() == 6,
        f"3D: Terra projects 6 members ({page.locator('.tile.member').count()})",
    )
    check(page.locator("#readout.dead").count() == 1, "3D: dead-protocol readout shown")

    page.get_by_role("button", name="Flat", exact=True).click()
    page.wait_for_timeout(900)
    check(page.locator("#table.is3d").count() == 0, "exit: back to flat cleanly")
    left = page.evaluate("document.querySelectorAll('#table [style*=matrix3d]').length")
    check(left == 0, f"exit: no transforms left on tiles ({left})")
    check(page.locator(".tile").count() >= 59, "exit: tiles restored to the document")
    evidence["mouse"] = section
    return section


def run_keyboard_matrix(page, atlas):
    els = atlas["elements"]
    arrangements = [("matrix", "By depth"), ("strata", "By family")]
    orders = [("group", "By group"), ("stratum", "By stratum"), ("id", "By ID")]
    dimensions = [("2d", "Flat"), ("3d", "3D")]
    for arr_key, arr_label in arrangements:
        for ord_key, ord_label in orders:
            expected = declared_order(els, ord_key)
            expected_ids = [e.id for e in expected]
            check(len(expected_ids) == len(els) and len(els) > 0,
                  f"declared {ord_key} order nonempty complete ({len(expected_ids)})")
            check(len(set(expected_ids)) == len(expected_ids),
                  f"declared {ord_key} order has unique ids")
            for dim_key, dim_label in dimensions:
                tag = f"{arr_label}/{ord_label}/{dim_label}"
                ensure_flat(page)
                click_seg(page, arr_label)
                click_seg(page, ord_label)
                live = page.locator("#live").inner_text()
                check(
                    bool(live.strip()) and ("order" in live.lower() or ord_key in live.lower() or "reading" in live.lower()),
                    f"{tag}: live region announced the order change ({live!r})",
                )
                if dim_key == "3d":
                    enter_3d(page)
                wait_ready(page)
                n_table = len(table_tile_ids(page))
                check(n_table == len(els), f"{tag}: table tile count {n_table} == {len(els)}")
                dom_ids = table_tile_ids(page)
                missing_dom = [i for i in expected_ids if i not in dom_ids]
                extra_dom = [i for i in dom_ids if i not in expected_ids]
                check(not missing_dom, f"{tag}: DOM missing entries {missing_dom[:8]}")
                check(not extra_dom, f"{tag}: DOM extra entries {extra_dom[:8]}")
                permutation_only = (
                    sorted(dom_ids) == sorted(expected_ids) and dom_ids != expected_ids
                )
                check(
                    not permutation_only,
                    f"{tag}: DOM is a permutation of declared {ord_key}, not the "
                    f"selected total order (dom0={dom_ids[:4]} exp0={expected_ids[:4]})",
                )
                check(
                    dom_ids == expected_ids,
                    f"{tag}: DOM/accessibility order matches declared {ord_key} "
                    f"(dom0={dom_ids[:4]} exp0={expected_ids[:4]})",
                )
                if dim_key == "2d":
                    boxes = sample_tile_boxes(page)
                    xs = [t["x"] for t in boxes]
                    ys = [t["y"] for t in boxes]
                    check(max(xs) - min(xs) > 40, f"{tag}: visual x-spread preserved ({max(xs)-min(xs):.1f})")
                    check(max(ys) - min(ys) > 40, f"{tag}: visual y-spread preserved ({max(ys)-min(ys):.1f})")
                    if arr_key == "matrix":
                        bands = page.locator("#table .band").count()
                        check(bands == 5, f"{tag}: depth visual still has 5 bands ({bands})")
                        by_s = {}
                        for t in boxes:
                            lab = (t.get("strat") or "").strip()
                            if lab.startswith("S") and lab[1:].isdigit():
                                by_s.setdefault(int(lab[1:]), []).append(t["y"])
                        if 0 in by_s and 1 in by_s:
                            check(
                                max(by_s[0]) < min(by_s[1]),
                                f"{tag}: depth visual keeps S0 above S1 "
                                f"(S0max={max(by_s[0]):.1f} S1min={min(by_s[1]):.1f})",
                            )
                    else:
                        fams = page.locator("#table .fam").count()
                        check(fams >= 8, f"{tag}: family visual blocks present ({fams})")
                cur = focus_grid(page)
                check(bool(cur and cur.get("id")), f"{tag}: grid took keyboard focus ({cur})")
                if not cur or not cur.get("id"):
                    evidence["keyboard"].append({"tag": tag, "skipped": "no-focus"})
                    continue
                check(
                    cur["id"] == expected_ids[0],
                    f"{tag}: initial focus is first declared id "
                    f"(got {cur['id']} want {expected_ids[0]})",
                )
                got = walk_arrows(page, expected_ids, "ArrowRight")
                missing_focus = [i for i in expected_ids if i not in got]
                check(
                    got == expected_ids,
                    f"{tag}: ArrowRight focus sequence matches declared order "
                    f"(len {len(got)} missing {missing_focus[:8]} got0={got[:4]})",
                )
                page.keyboard.press("End")
                end = focused_tile(page)
                check(
                    end and end.get("id") == expected_ids[-1],
                    f"{tag}: End jumps to last ({end} want {expected_ids[-1]})",
                )
                page.keyboard.press("Home")
                home = focused_tile(page)
                check(
                    home and home.get("id") == expected_ids[0],
                    f"{tag}: Home jumps to first ({home} want {expected_ids[0]})",
                )
                # typeahead on symbol, independent of onTileKey
                letter = None
                for ch in "CPS":
                    hits = [e for e in expected if e.sym.lower().startswith(ch.lower())]
                    if len(hits) >= 2:
                        letter = ch
                        break
                if letter:
                    before = focused_tile(page)["id"]
                    want = next_typeahead(expected, before, letter)
                    page.keyboard.press(letter.lower())
                    after = focused_tile(page)
                    check(
                        after and after.get("id") == want,
                        f"{tag}: typeahead {letter!r} from {before} -> {after} want {want}",
                    )
                # modal open/close/restoration from keyboard
                origin = focused_tile(page)["id"]
                page.keyboard.press("Enter")
                page.wait_for_timeout(300)
                opened = page.evaluate(
                    "() => { const d = document.querySelector('dialog.detail'); return !!(d && d.open); }"
                )
                check(opened, f"{tag}: Enter opens detail dialog")
                page.keyboard.press("Escape")
                page.wait_for_timeout(300)
                still_open = page.evaluate(
                    "() => { const d = document.querySelector('dialog.detail'); return !!(d && d.open); }"
                )
                check(not still_open, f"{tag}: Escape closes detail dialog (open={still_open})")
                restored = focused_tile(page)
                check(
                    restored and restored.get("id") == origin,
                    f"{tag}: focus restored to {origin} after close (got {restored})",
                )
                evidence["keyboard"].append(
                    {
                        "tag": tag,
                        "declared_len": len(expected_ids),
                        "dom_len": len(dom_ids),
                        "focus_len": len(got),
                        "dom_matches": dom_ids == expected_ids,
                        "focus_matches": got == expected_ids,
                    }
                )


def run_view_transitions(page):
    ensure_flat(page)
    click_seg(page, "The table")
    wait_ready(page)
    evidence["views"] = []
    for dim in ("Flat", "3D"):
        click_seg(page, "The table")
        wait_ready(page)
        if dim == "3D":
            enter_3d(page)
        else:
            ensure_flat(page)
        for view, min_rules in (("Laws", 20), ("Hazards", 15)):
            click_seg(page, view)
            page.wait_for_timeout(400)
            stat = page.evaluate(
                """() => {
                  const table = document.getElementById('table');
                  const tiles = table ? table.querySelectorAll('button.tile').length : -1;
                  const rules = table ? table.querySelectorAll('.rule').length : -1;
                  const overlay = (() => {
                    const r = table && table.querySelector('.rule');
                    if (!r) return 'no-rule';
                    const b = r.getBoundingClientRect();
                    const el = document.elementFromPoint(b.left + Math.min(24, b.width/2), b.top + 12);
                    return el && el.closest && el.closest('.tile') ? 'tile-over-rule' : 'clear';
                  })();
                  return {
                    tiles, rules, is3d: !!(table && table.classList.contains('is3d')),
                    overlay, sample: (table && table.innerText || '').slice(0, 180),
                  };
                }"""
            )
            evidence["views"].append({"from": dim, "view": view, **stat})
            check(stat["tiles"] == 0, f"{dim}->{view}: no table tiles overlay rules (tiles={stat['tiles']})")
            check(stat["rules"] >= min_rules, f"{dim}->{view}: rule cards present ({stat['rules']})")
            check(stat["overlay"] == "clear", f"{dim}->{view}: rule text not covered by a tile ({stat['overlay']})")
            click_seg(page, "The table")
            page.wait_for_timeout(500)
            back = page.evaluate(
                """() => ({
                  tiles: document.querySelectorAll('#table button.tile').length,
                  is3d: !!document.getElementById('table')?.classList.contains('is3d'),
                })"""
            )
            check(back["tiles"] >= 59, f"{view}->table from {dim}: tiles restored ({back['tiles']})")
            if dim == "3D":
                check(back["is3d"], f"{view}->table from 3D: 3D arrangement path restored")


def run_search(page, atlas):
    ensure_flat(page)
    click_seg(page, "By group")
    target = next(e for e in atlas["elements"] if e.id == "E001")
    page.fill("#q", target.id)
    page.wait_for_timeout(200)
    live = page.locator("#live").inner_text()
    listbox = page.locator("#search-results, [role='listbox']")
    check(listbox.count() >= 1, "search: results listbox exists")
    options = page.locator("#search-results [role='option'], [role='listbox'] [role='option'], #search-results button, #search-results a")
    n_opt = options.count()
    check(n_opt == 1, f"search unique {target.id}: one result option ({n_opt})")
    visible_list = page.evaluate(
        """() => {
          const box = document.querySelector('#search-results, [role="listbox"]');
          if (!box) return {exists:false};
          const r = box.getBoundingClientRect();
          return {exists:true, w:r.width, h:r.height, text: box.innerText.slice(0, 240)};
        }"""
    )
    check(visible_list.get("h", 0) > 8, f"search: results list is visible ({visible_list})")
    a11y_tiles = page.evaluate(
        """() => Array.from(document.querySelectorAll('#table button.tile'))
            .filter(t => !t.hidden && t.getAttribute('aria-hidden') !== 'true'
              && getComputedStyle(t).display !== 'none'
              && getComputedStyle(t).visibility !== 'hidden').length"""
    )
    check(
        a11y_tiles == 1,
        f"search unique: unmatched tiles are not still all accessibility-exposed ({a11y_tiles})",
    )
    page.locator("#q").press("Enter")
    page.wait_for_timeout(300)
    opened = page.evaluate("() => { const d = document.querySelector('dialog.detail'); return !!(d && d.open); }")
    check(opened, "search Enter selects the matching element (detail open)")
    detail = page.evaluate("() => document.querySelector('dialog.detail')?.innerText || ''")
    check(target.name in detail or target.id in detail, f"search Enter opened {target.id}")
    page.keyboard.press("Escape")
    page.wait_for_timeout(200)
    page.fill("#q", "ZZZ-NO-SUCH-ELEMENT")
    page.wait_for_timeout(200)
    zero = page.evaluate(
        """() => {
          const box = document.querySelector('#search-results, [role="listbox"]');
          const opts = box ? box.querySelectorAll('[role="option"], button, a').length : 0;
          const live = document.getElementById('live')?.textContent || '';
          return {opts, live, text: box ? box.innerText : '', empty: !!document.querySelector('#search-results .empty, .search-empty, [data-empty="true"]')};
        }"""
    )
    check(zero["opts"] == 0, f"search zero-results: no selectable options ({zero})")
    check(
        "0" in (zero["live"] + zero["text"]) or "no match" in (zero["live"] + zero["text"]).lower() or zero["empty"],
        f"search zero-results state is announced/visible ({zero})",
    )
    page.fill("#q", "")
    page.wait_for_timeout(150)
    evidence["search"] = {"unique_live": live, "visible_list": visible_list, "zero": zero}


def run_badges(page, atlas):
    ensure_flat(page)
    rows = page.evaluate(
        """() => Array.from(document.querySelectorAll('#table button.tile')).map(t => ({
            id: t.dataset.id,
            badge: (t.querySelector('.t-badge')?.innerText || '').replace(/\\s+/g, ' ').trim(),
          }))"""
    )
    by_id = {e.id: e for e in atlas["elements"]}
    bad = []
    for row in rows:
        e = by_id.get(row["id"])
        if not e:
            bad.append((row["id"], "unknown", row["badge"]))
            continue
        want = STATUS_WORD[e.status]
        if want not in row["badge"]:
            bad.append((row["id"], want, row["badge"]))
    check(not bad, f"visible badges use full status phrases ({bad[:6]})")
    evidence["badges"] = {"checked": len(rows), "bad": bad[:12]}


def run_dimension_aria(page):
    ensure_flat(page)
    def pressed():
        return page.evaluate(
            """() => {
              const btns = Array.from(document.querySelectorAll('.controls .seg button'));
              const hit = (label) => {
                const b = btns.find(x => x.textContent.trim() === label);
                return b ? b.getAttribute('aria-pressed') : null;
              };
              return {flat: hit('Flat'), three: hit('3D')};
            }"""
        )
    before = pressed()
    check(before["flat"] == "true" and before["three"] == "false", f"Dimension start Flat pressed ({before})")
    page.get_by_role("button", name="3D", exact=True).click()
    page.wait_for_timeout(50)
    after = pressed()
    check(
        after["flat"] == "false" and after["three"] == "true",
        f"Dimension aria-pressed updates immediately after 3D ({after})",
    )
    page.wait_for_timeout(400)
    ensure_flat(page)
    evidence["dimension_aria"] = {"before": before, "after": after}


def run_names(page, atlas):
    tiles = all_tile_names(page)
    table = [t for t in tiles if t["where"] == "table"]
    contested = [t for t in tiles if t["where"] == "contested"]
    check(len(table) == len(atlas["elements"]), f"name-scan table tiles {len(table)}")
    check(len(table) > 0, "name-scan table nonempty")
    by_id = {e.id: e for e in atlas["elements"]}
    missing_any = []
    for t in table:
        e = by_id.get(t["id"])
        if not e:
            missing_any.append(("unknown-id", t["id"]))
            continue
        miss = missing_name_fields(t["label"], e, atlas["group_by_id"], atlas["hazards"])
        if miss:
            missing_any.append((t["id"], t["sym"], miss, t["label"][:120]))
    check(not missing_any, f"every table tile 9-field name ({len(missing_any)} bad: {missing_any[:6]})")
    # contested tiles are rendered; they must be named, not empty. Nine-field
    # group/stratum/asynchrony are not invented for entries the export does not
    # classify on those axes — record actual labels.
    empty_c = [t for t in contested if not t["label"].strip()]
    check(len(contested) == len(atlas["contested"]), f"contested tiles {len(contested)}")
    check(not empty_c, f"contested tiles have accessible names ({len(empty_c)} empty)")
    contested_missing_status = [
        t["sym"] for t in contested if "contested: note required" not in (t["label"] or "")
    ]
    check(
        not contested_missing_status,
        f"contested names include status restriction ({contested_missing_status[:8]})",
    )
    evidence["names"] = {
        "table": len(table),
        "contested": len(contested),
        "bad_table": missing_any[:20],
        "contested_labels": [
            {"id": t["id"], "sym": t["sym"], "label": t["label"]} for t in contested
        ],
    }


def run_filter_focus(page, atlas):
    ensure_flat(page)
    click_seg(page, "By group")
    expected = declared_order(atlas["elements"], "group")
    focus_grid(page)
    first = expected[0]
    # filter to a later unique name so the focused first tile is excluded
    target = next(e for e in expected if e.id != first.id)
    page.fill("#q", target.name)
    page.wait_for_timeout(200)
    q = target.name.lower()
    remaining = [
        e.id
        for e in expected
        if q in e.name.lower() or q in e.sym.lower() or q in e.id.lower()
    ]
    check(len(remaining) >= 1, f"search remaining nonempty ({remaining})")
    # Typing happens in the search field; the roving tabindex on the grid must
    # still move off the excluded tile so Tab returns to a remaining entry.
    tab0 = page.evaluate(
        """() => {
          const t = document.querySelector('#table .tile[tabindex="0"]');
          return t ? t.dataset.id : null;
        }"""
    )
    check(
        tab0 in remaining and tab0 != first.id,
        f"filter moves roving tabindex off excluded {first.id} onto remaining (tab0={tab0})",
    )
    page.fill("#q", "")
    page.wait_for_timeout(150)


def sample_tile_boxes(page):
    return page.evaluate(
        """() => Array.from(document.querySelectorAll('#table button.tile')).map(t => {
            const r = t.getBoundingClientRect();
            const tr = getComputedStyle(t).transform;
            const strat = t.querySelector('.t-strat');
            return {
              id: t.dataset.id, x: r.x, y: r.y, w: r.width, h: r.height, transform: tr,
              strat: strat ? strat.textContent : null,
            };
          })"""
    )


def capture_rendered_frames(page, n=40):
    return page.evaluate(
        """(n) => new Promise((resolve) => {
            const t = document.querySelector('#table .tile[tabindex="0"]')
              || document.querySelector('#table button.tile');
            if (!t) { resolve([]); return; }
            const frames = [];
            let i = 0;
            const tick = () => {
              const r = t.getBoundingClientRect();
              let node = t;
              let parentTransform = null;
              while (node && node !== document.body) {
                const tr = getComputedStyle(node).transform;
                if (tr && tr !== 'none') { parentTransform = tr; break; }
                node = node.parentElement;
              }
              frames.push({
                x: r.x, y: r.y, w: r.width, h: r.height,
                self: getComputedStyle(t).transform,
                ancestor: parentTransform,
              });
              i += 1;
              if (i < n) requestAnimationFrame(tick);
              else resolve(frames);
            };
            requestAnimationFrame(tick);
          })""",
        n,
    )


def frame_motion(frames):
    if not frames:
        return {"n": 0, "unique_ancestors": 0, "dy": 0, "dh": 0, "dx": 0}
    ys = [f["y"] for f in frames]
    hs = [f["h"] for f in frames]
    xs = [f["x"] for f in frames]
    ancestors = {f.get("ancestor") or "" for f in frames}
    return {
        "n": len(frames),
        "unique_ancestors": len(ancestors),
        "dy": max(ys) - min(ys),
        "dh": max(hs) - min(hs),
        "dx": max(xs) - min(xs),
    }


def run_reduced_motion(browser):
    page = browser.new_page(viewport={"width": 1600, "height": 1000})
    errors = []
    page.on("pageerror", lambda e: errors.append(str(e)))
    page.emulate_media(reduced_motion="reduce")
    page.goto(URL)
    wait_ready(page)
    matches = page.evaluate("window.matchMedia('(prefers-reduced-motion: reduce)').matches")
    check(matches is True, f"prefers-reduced-motion emulation observed ({matches})")
    anims0 = page.evaluate("document.getAnimations().map(a => a.animationName || a.transitionProperty || a.constructor.name)")
    click_seg(page, "By family")
    page.wait_for_timeout(50)
    boxes_a = sample_tile_boxes(page)
    page.wait_for_timeout(280)
    boxes_b = sample_tile_boxes(page)
    moving = []
    by_b = {t["id"]: t for t in boxes_b}
    for a in boxes_a:
        b = by_b.get(a["id"])
        if not b:
            continue
        if abs(a["x"] - b["x"]) > 0.5 or abs(a["y"] - b["y"]) > 0.5:
            moving.append(a["id"])
        if a["transform"] != b["transform"] and "matrix" in (a["transform"] + b["transform"]):
            moving.append(a["id"] + ":transform")
    check(not moving, f"reduced-motion: no positional interpolation after arrangement change ({moving[:8]})")
    anims1 = page.evaluate("document.getAnimations().length")
    check(anims1 == 0, f"reduced-motion: getAnimations empty after layout change ({anims1})")
    click_seg(page, "3D")
    page.wait_for_timeout(100)
    t0 = page.evaluate(
        """() => Array.from(document.querySelectorAll('#table .tile')).slice(0, 12).map(t => t.style.transform || getComputedStyle(t).transform)"""
    )
    time.sleep(0.35)
    t1 = page.evaluate(
        """() => Array.from(document.querySelectorAll('#table .tile')).slice(0, 12).map(t => t.style.transform || getComputedStyle(t).transform)"""
    )
    check(t0 == t1, f"reduced-motion 3D: tile transforms stable after mount (changed {sum(x!=y for x,y in zip(t0,t1))})")
    anims2 = page.evaluate("document.getAnimations().length")
    check(anims2 == 0, f"reduced-motion 3D: getAnimations empty ({anims2})")
    # Camera spring is on a CSS3D ancestor, not the tile-local transform.
    focus_grid(page)
    page.wait_for_timeout(40)
    reduce_frames = capture_rendered_frames(page, 40)
    reduce_motion = frame_motion(reduce_frames)
    check(
        reduce_motion["dy"] < 1.0 and reduce_motion["dh"] < 1.0 and reduce_motion["unique_ancestors"] <= 2,
        f"reduced-motion 3D focus: rendered coordinates stable "
        f"(dy={reduce_motion['dy']:.3f} dh={reduce_motion['dh']:.3f} "
        f"ancestors={reduce_motion['unique_ancestors']})",
    )
    evidence["reduced_motion"] = {
        "matchMedia": matches,
        "animations_initial": anims0,
        "animations_after_layout": anims1,
        "animations_3d": anims2,
        "moving_ids": moving,
        "focus_frames": reduce_motion,
        "errors": errors[:4],
    }
    check(not errors, f"reduced-motion: no JS errors ({errors[:2]})")
    page.close()

    # Positive control: normal motion must still interpolate the camera.
    normal = browser.new_page(viewport={"width": 1600, "height": 1000})
    normal.emulate_media(reduced_motion="no-preference")
    normal.goto(URL)
    wait_ready(normal)
    click_seg(normal, "3D")
    normal.wait_for_timeout(200)
    focus_grid(normal)
    normal_frames = capture_rendered_frames(normal, 40)
    normal_motion = frame_motion(normal_frames)
    check(
        normal_motion["dy"] > 2 or normal_motion["unique_ancestors"] > 5,
        f"normal-motion 3D focus control moves "
        f"(dy={normal_motion['dy']:.3f} ancestors={normal_motion['unique_ancestors']})",
    )
    evidence["reduced_motion"]["normal_focus"] = normal_motion
    # Flat control: focusing a tile does not move its box.
    click_seg(normal, "Flat")
    normal.wait_for_timeout(400)
    focus_grid(normal)
    flat_frames = capture_rendered_frames(normal, 20)
    flat_motion = frame_motion(flat_frames)
    check(
        flat_motion["dy"] < 1.0 and flat_motion["dx"] < 1.0,
        f"Flat focus control is stationary (dy={flat_motion['dy']:.3f} dx={flat_motion['dx']:.3f})",
    )
    evidence["reduced_motion"]["flat_focus"] = flat_motion
    normal.close()


def measure_limits(page):
    return page.evaluate(
        """() => {
          const vis = (el) => {
            if (!el) return null;
            const r = el.getBoundingClientRect();
            return {
              top: r.top, bottom: r.bottom, left: r.left, right: r.right,
              w: r.width, h: r.height,
              inViewport: r.bottom > 0 && r.top < innerHeight && r.right > 0 && r.left < innerWidth && r.width > 0 && r.height > 0,
            };
          };
          const tiles = Array.from(document.querySelectorAll('#table button.tile')).map(t => {
            const r = t.getBoundingClientRect();
            const sym = t.querySelector('.t-sym');
            const badge = t.querySelector('.t-badge');
            return {
              id: t.dataset.id,
              x: r.x, y: r.y, w: r.width, h: r.height,
              symFont: sym ? getComputedStyle(sym).fontSize : null,
              badgeFont: badge ? getComputedStyle(badge).fontSize : null,
              inViewport: r.bottom > 0 && r.top < innerHeight && r.width > 8 && r.height > 8,
            };
          });
          const overlaps = [];
          const visTiles = tiles.filter(t => t.inViewport);
          for (let i = 0; i < visTiles.length; i++) {
            for (let j = i + 1; j < visTiles.length; j++) {
              const a = visTiles[i], b = visTiles[j];
              const ox = Math.min(a.x+a.w, b.x+b.w) - Math.max(a.x, b.x);
              const oy = Math.min(a.y+a.h, b.y+b.h) - Math.max(a.y, b.y);
              if (ox > 2 && oy > 2) overlaps.push([a.id, b.id, ox, oy]);
            }
          }
          return {
            disavowal: vis(document.querySelector('.disavowal')),
            h1: vis(document.querySelector('h1')),
            mapping: vis(document.querySelector('.mapping')),
            table: vis(document.getElementById('table')),
            visibleTileCount: visTiles.length,
            minSymPx: Math.min(...visTiles.map(t => parseFloat(t.symFont) || 99), 99),
            overlaps: overlaps.slice(0, 8),
            innerWidth, innerHeight,
          };
        }"""
    )


def run_screenshots(browser):
    if not SCREEN_DIR:
        return
    SCREEN_DIR.mkdir(parents=True, exist_ok=True)
    specs = [
        ("wide-1600x1000", 1600, 1000),
        ("wide-1920x1200", 1920, 1200),
        ("dense-1280x800", 1280, 800),
        ("dense-900x700", 900, 700),
    ]
    evidence["screenshots"] = []
    for name, w, h in specs:
        page = browser.new_page(viewport={"width": w, "height": h})
        page.goto(URL)
        wait_ready(page)
        page.evaluate("window.scrollTo(0,0)")
        page.wait_for_timeout(150)
        first = measure_limits(page)
        page.screenshot(path=str(SCREEN_DIR / f"{name}-first.png"), full_page=False)
        page.locator("#table").first.scroll_into_view_if_needed()
        page.wait_for_timeout(150)
        table = measure_limits(page)
        page.screenshot(path=str(SCREEN_DIR / f"{name}-table.png"), full_page=False)
        page.screenshot(path=str(SCREEN_DIR / f"{name}-full.png"), full_page=True)
        check(
            first.get("disavowal") and first["disavowal"]["inViewport"],
            f"screenshot {name}: disavowal in first viewport without click",
        )
        check(
            table["visibleTileCount"] > 0,
            f"screenshot {name}: table tiles visible after scroll-to-table ({table['visibleTileCount']})",
        )
        check(
            table["minSymPx"] >= 14,
            f"screenshot {name}: visible tile symbol font {table['minSymPx']}px",
        )
        check(
            not table["overlaps"],
            f"screenshot {name}: no overlapping visible tiles ({table['overlaps'][:4]})",
        )
        evidence["screenshots"].append({"name": name, "first": first, "table": table})
        page.close()


def run_print_find_deeplink(browser, page):
    # Browser-engine find (window.find), not a Ctrl-F UI observation.
    known = page.evaluate('window.find("Constant-product invariant")')
    unknown = page.evaluate('window.find("GPT6_impossible_search_928")')
    check(known is True, f"browser-engine find locates a real element name ({known})")
    check(unknown is False, f"browser-engine find rejects an impossible string ({unknown})")
    evidence["find_engine"] = {
        "api": "window.find",
        "not": "Ctrl-F find-in-page UI",
        "known": known,
        "unknown": unknown,
    }
    # Bounded print text, not visual print-quality acceptance.
    page.evaluate("window.dispatchEvent(new Event('beforeprint'))")
    page.emulate_media(media="print")
    if SCREEN_DIR:
        SCREEN_DIR.mkdir(parents=True, exist_ok=True)
        try:
            page.pdf(path=str(SCREEN_DIR / "flat-print.pdf"), print_background=True)
        except Exception as ex:
            notes.append("residual  print PDF not captured: " + str(ex)[:160])
    print_dom = page.evaluate(
        """() => ({
          tiles: document.querySelectorAll('#table button.tile').length,
          text: document.body.innerText,
        })"""
    )
    ids_in_text = [e for e in table_tile_ids(page) if e in print_dom["text"]]
    check(print_dom["tiles"] >= 59, f"print DOM contains table tiles ({print_dom['tiles']})")
    check(len(ids_in_text) >= 59, f"print text contains table IDs ({len(ids_in_text)})")
    evidence["print"] = {
        "kind": "bounded print text from emulate_media(print)",
        "not": "visual print quality",
        "tiles": print_dom["tiles"],
        "ids": len(ids_in_text),
    }
    page.emulate_media(media="screen")
    fresh = browser.new_page(viewport={"width": 1600, "height": 1000})
    # Hash deep link on a fresh load, not same-document navigation.
    target = URL.split("#")[0] + "#E001"
    fresh.goto(target)
    wait_ready(fresh)
    fresh.wait_for_timeout(200)
    deep = fresh.evaluate(
        """() => ({
          hash: location.hash,
          open: !!(document.querySelector('dialog.detail') && document.querySelector('dialog.detail').open),
          text: document.querySelector('dialog.detail')?.innerText?.slice(0, 240) || null,
        })"""
    )
    check(deep["hash"] == "#E001", f"deep-link hash is #E001 ({deep['hash']})")
    check(deep["open"], "fresh #E001 navigation opens detail")
    check(deep["text"] and "E001" in deep["text"], f"deep-link detail names E001 ({deep['text']})")
    evidence["deep_link"] = deep
    fresh.close()


def run_zoom(page):
    """Attempt actual browser zoom. Root-font scaling is recorded as a proxy only."""
    measure = """() => {
      const t = document.querySelector('#table button.tile');
      const nm = t && t.querySelector('.t-nm');
      const badge = t && t.querySelector('.t-badge');
      const r = t ? t.getBoundingClientRect() : null;
      return {
        root: getComputedStyle(document.documentElement).fontSize,
        body: getComputedStyle(document.body).fontSize,
        tileW: r ? r.width : null,
        tileH: r ? r.height : null,
        nameFont: nm ? getComputedStyle(nm).fontSize : null,
        badgeFont: badge ? getComputedStyle(badge).fontSize : null,
        innerWidth, scrollWidth: document.documentElement.scrollWidth,
      };
    }"""
    base = page.evaluate(measure)
    zoom = {"method": None, "available": False, "error": None, "base": base, "attempts": []}
    try:
        session = page.context.new_cdp_session(page)
        session.send("Emulation.setPageScaleFactor", {"pageScaleFactor": 2})
        page.wait_for_timeout(200)
        scaled = page.evaluate(measure)
        grew = (
            (scaled["tileW"] and base["tileW"] and scaled["tileW"] >= base["tileW"] * 1.5)
            or (float(str(scaled["nameFont"]).replace("px", "") or 0)
                >= float(str(base["nameFont"]).replace("px", "") or 0) * 1.5)
        )
        zoom["attempts"].append({
            "method": "CDP Emulation.setPageScaleFactor 2",
            "scaled": scaled,
            "layout_changed": bool(grew),
        })
        if grew:
            zoom.update({"method": "CDP Emulation.setPageScaleFactor 2", "available": True, "scaled": scaled})
            check(True, "200% page scale enlarged tile text or box")
        else:
            notes.append(
                "residual  CDP Emulation.setPageScaleFactor(2) is callable on this Chromium "
                "but did not change layout metrics; that is not 200% browser zoom"
            )
        try:
            session.send("Emulation.setPageScaleFactor", {"pageScaleFactor": 1})
        except Exception:
            pass
    except Exception as ex:
        zoom["error"] = str(ex)[:300]
        notes.append(
            "residual  200% browser zoom unavailable via CDP setPageScaleFactor: "
            + str(ex)[:160]
        )
    if not zoom["available"]:
        notes.append(
            "residual  actual 200% browser zoom was not observed on installed "
            "Playwright Chromium; root-font rem growth is a proxy, not a zoom pass"
        )
    # Root-font proxy is recorded separately and is not a zoom pass.
    page.evaluate("document.documentElement.style.fontSize='32px'")
    proxy = page.evaluate(measure)
    if SCREEN_DIR:
        SCREEN_DIR.mkdir(parents=True, exist_ok=True)
        page.screenshot(path=str(SCREEN_DIR / "root-font-200.png"), full_page=False)
    page.evaluate("document.documentElement.style.fontSize=''")
    zoom["root_font_proxy"] = proxy
    evidence["zoom"] = zoom
    name0 = float(str(base["nameFont"]).replace("px", "") or 0)
    namep = float(str(proxy["nameFont"]).replace("px", "") or 0)
    badge0 = float(str(base["badgeFont"]).replace("px", "") or 0)
    badgep = float(str(proxy["badgeFont"]).replace("px", "") or 0)
    check(
        namep > name0 * 1.4,
        f"relative tile name font grows with root 200% (base={base['nameFont']} proxy={proxy['nameFont']})",
    )
    check(
        badgep > badge0 * 1.4,
        f"relative badge font grows with root 200% (base={base['badgeFont']} proxy={proxy['badgeFont']})",
    )


def main():
    contract = self_check()
    check(contract["counts"]["elements"] >= 59, f"contract elements {contract['counts']}")
    atlas = load_atlas()
    if not Path(CHROME).exists():
        check(False, f"chrome executable missing: {CHROME}")
        print("\n".join(notes + fails))
        sys.exit(1)
    if not DIST.exists() and URL.startswith("file:"):
        check(False, f"dist artifact missing: {DIST}")
        print("\n".join(notes + fails))
        sys.exit(1)

    with sync_playwright() as pw:
        browser = pw.chromium.launch(
            executable_path=CHROME,
            args=["--no-sandbox", "--disable-gpu"],
        )
        page = browser.new_page(viewport={"width": 1600, "height": 1000})
        errors = []
        page.on("pageerror", lambda e: errors.append(str(e)))
        page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)
        page.goto(URL)
        wait_ready(page)
        check(URL.startswith("file://") and "defiformal-wt-atlas-grok-gpt6-20260908" in URL,
              f"bound to this worktree artifact ({URL})")
        check("/root/DefiElements/" not in URL, "must not use stale /root/DefiElements hardcode")
        ver = browser.version
        notes.append(f"ok  browser version {ver} exe {CHROME}")
        evidence["browser_version"] = ver

        run_mouse_historical(page)
        # mouse success does not close keyboard requirements
        ensure_flat(page)
        page.goto(URL)
        wait_ready(page)
        run_keyboard_matrix(page, atlas)
        ensure_flat(page)
        click_seg(page, "By depth")
        click_seg(page, "By group")
        run_names(page, atlas)
        run_badges(page, atlas)
        run_dimension_aria(page)
        run_search(page, atlas)
        run_filter_focus(page, atlas)
        run_view_transitions(page)
        run_print_find_deeplink(browser, page)
        run_zoom(page)
        check(not errors, f"no JS errors ({errors[:2]})")
        page.close()
        run_screenshots(browser)
        run_reduced_motion(browser)
        browser.close()

    if EVIDENCE_JSON:
        Path(EVIDENCE_JSON).write_text(json.dumps(evidence, indent=2) + "\n")
    print("\n".join(notes))
    if fails:
        print("\n".join(fails))
        sys.exit(1)
    print("\nall interaction checks passed")


if __name__ == "__main__":
    main()
