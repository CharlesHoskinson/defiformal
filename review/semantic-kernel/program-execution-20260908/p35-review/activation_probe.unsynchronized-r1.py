from pathlib import Path
from playwright.sync_api import sync_playwright
import json,datetime
O=Path(__file__).resolve().parent;U=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908/viz/dist/index.html').as_uri();matrix=json.loads((O/'browser-probe.json').read_text())['matrix'];r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'matrix':[],'errors':[]}
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome',args=['--no-sandbox','--disable-gpu']);p=b.new_page(viewport={'width':1280,'height':900},reduced_motion='reduce');p.on('pageerror',lambda e:r['errors'].append(str(e)))
 for m in matrix:
  p.goto(U);p.wait_for_selector('#table .tile')
  for label in [m['arrangement'],m['order']]+(['3D'] if m['dimension']=='3D' else []):p.get_by_role('button',name=label,exact=True).click()
  p.wait_for_timeout(80);p.locator('#q').click();p.keyboard.press('Tab');row={'arrangement':m['arrangement'],'order':m['order'],'dimension':m['dimension'],'entries':[]}
  for eid in m['expected']:
   origin=p.evaluate('document.activeElement.dataset.id');p.keyboard.press('Enter');opened=p.evaluate('Boolean(document.querySelector("dialog.detail")?.open)');text=p.locator('dialog.detail').inner_text();p.keyboard.press('Escape');restored=p.evaluate('document.activeElement.dataset.id');row['entries'].append({'expected':eid,'origin':origin,'opened':opened,'detail_contains_id':eid in text,'restored':restored,'pass':origin==eid and opened and eid in text and restored==eid});p.keyboard.press('ArrowRight')
  p.keyboard.press('Home');p.keyboard.press('c');row['typeahead_symbol']=p.evaluate('document.activeElement.dataset.sym');r['matrix'].append(row);print(row['arrangement'],row['order'],row['dimension'],sum(e['pass'] for e in row['entries']),flush=True)
 b.close()
(O/'activation-probe.json').write_text(json.dumps(r,indent=2)+'\n')
