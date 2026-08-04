"""Actually drive the page. Screenshots proved it renders; this proves it works."""
import sys
from playwright.sync_api import sync_playwright

URL = "file:///root/DefiElements/viz/dist/index.html"
fails, notes = [], []

def check(cond, msg):
    (notes if cond else fails).append(("ok  " if cond else "FAIL ") + msg)

with sync_playwright() as pw:
    b = pw.chromium.launch(args=["--no-sandbox", "--disable-gpu"])
    page = b.new_page(viewport={"width": 1600, "height": 1000})
    errors = []
    page.on("pageerror", lambda e: errors.append(str(e)))
    page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)

    # ---------------- flat mode ----------------
    page.goto(URL); page.wait_for_timeout(900)
    check(page.locator(".tile").count() >= 59, f"flat: tiles rendered ({page.locator('.tile').count()})")

    # click a tile -> detail dialog opens
    page.locator('.tile[data-sym="Pl"]').first.click()
    page.wait_for_timeout(500)
    check(page.locator("dialog.detail").count() == 1, "flat: element dialog opens on tile click")
    check("Pooled lending" in page.locator("dialog.detail").inner_text(), "flat: dialog shows the right element")
    page.keyboard.press("Escape"); page.wait_for_timeout(300)

    # protocol projection
    page.get_by_role("button", name="Aave v3").click(); page.wait_for_timeout(600)
    check(page.locator(".tile.member").count() == 10, f"flat: Aave projects 10 members ({page.locator('.tile.member').count()})")
    check(page.locator("#readout").count() == 1, "flat: readout appears")

    # ---------------- 3D mode ----------------
    page.get_by_role("button", name="3D", exact=True).click()
    page.wait_for_timeout(1400)
    check(page.locator("#table.is3d").count() == 1, "3D: is3d class applied")
    n3d = page.evaluate("document.querySelectorAll('#table [style*=matrix3d]').length")
    check(n3d > 40, f"3D: tiles lifted into the scene ({n3d} transformed)")

    # THE bug we just fixed: are tiles actually clickable in 3D?
    pe = page.evaluate("""() => {
      const t = document.querySelector('#table.is3d .tile');
      return t ? getComputedStyle(t).pointerEvents : 'none-found';
    }""")
    check(pe == "auto", f"3D: tiles are pointer-interactive (pointer-events: {pe})")

    page.locator('#table.is3d .tile[data-sym="Ct"]').first.scroll_into_view_if_needed()
    page.wait_for_timeout(400)
    hit = page.evaluate("""() => {
      const t = document.querySelector('#table.is3d .tile[data-sym="Ct"]');
      if (!t) return 'no tile';
      const r = t.getBoundingClientRect();
      if (r.width < 2) return 'zero size';
      const cx = r.left + r.width/2, cy = r.top + r.height/2;
      if (cx < 0 || cy < 0 || cx > innerWidth || cy > innerHeight) return 'offscreen';
      const el = document.elementFromPoint(cx, cy);
      return el && el.closest('.tile') ? 'reachable' : 'blocked by ' + (el ? el.className : 'null');
    }""")
    check(hit == "reachable", f"3D: tile is hit-testable at its centre ({hit})")

    # click a tile in 3D
    try:
        page.locator('#table.is3d .tile[data-sym="Ct"]').first.click(timeout=4000)
        page.wait_for_timeout(500)
        check(page.locator("dialog.detail").count() == 1, "3D: element dialog opens on tile click")
        page.keyboard.press("Escape"); page.wait_for_timeout(250)
    except Exception as ex:
        check(False, f"3D: tile click threw ({str(ex)[:90]})")

    # switch protocol while in 3D (must not fall back to flat)
    page.get_by_role("button", name="Terra / Anchor").click(); page.wait_for_timeout(1500)
    check(page.locator("#table.is3d").count() == 1, "3D: stays in 3D after protocol change")
    check(page.locator(".tile.member").count() == 6, f"3D: Terra projects 6 members ({page.locator('.tile.member').count()})")
    check(page.locator("#readout.dead").count() == 1, "3D: dead-protocol readout shown")

    # back to flat
    page.get_by_role("button", name="Flat", exact=True).click(); page.wait_for_timeout(900)
    check(page.locator("#table.is3d").count() == 0, "exit: back to flat cleanly")
    left = page.evaluate("document.querySelectorAll('#table [style*=matrix3d]').length")
    check(left == 0, f"exit: no transforms left on tiles ({left})")
    check(page.locator(".tile").count() >= 59, "exit: tiles restored to the document")

    check(not errors, f"no JS errors ({errors[:2]})")
    b.close()

print("\n".join(notes))
if fails:
    print("\n".join(fails)); sys.exit(1)
print("\nall interaction checks passed")
