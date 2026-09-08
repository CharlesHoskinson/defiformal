from pathlib import Path
from playwright.sync_api import sync_playwright
import json,re,hashlib,datetime

OUT=Path(__file__).resolve().parent
W=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908')
CHROME=Path('/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome')
URL=(W/'viz/dist/index.html').as_uri()
data=(W/'viz/src/data.ts').read_text()
block=data.split('export const ELEMENTS')[1].split('\n];')[0]
elements=[dict(zip(['id','sym','name','group','stratum','atom','status'],m)) for m in re.findall(r'id: "([^"]+)", sym: "([^"]+)", name: "([^"]+)", group: "([^"]+)", stratum: (\d+), atom: "([^"]+)", status: "([^"]+)"',block)]
assert len(elements)==59
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'url':URL,'chromium_path':str(CHROME),'chromium_sha256':hashlib.sha256(CHROME.read_bytes()).hexdigest(),'dist_sha256':hashlib.sha256((W/'viz/dist/index.html').read_bytes()).hexdigest(),'matrix':[],'errors':[]}
def ids(page):return page.locator('#table button.tile').evaluate_all('(es)=>es.map(e=>e.dataset.id)')
def focused(page):return page.evaluate('document.activeElement.dataset.id || document.activeElement.tagName')
def button(page,label):page.get_by_role('button',name=label,exact=True).click()
sample_js='''async () => {
 const out=[];
 for(let i=0;i<40;i++) {
   await new Promise(requestAnimationFrame);
   const tile=document.querySelector('#table .tile:focus') || document.querySelector('#table .tile');
   const r=tile.getBoundingClientRect();
   out.push({t:performance.now(),id:tile.dataset.id,x:r.x,y:r.y,w:r.width,h:r.height,
    ownTransform:tile.style.transform,parentTransform:tile.parentElement.style.transform,
    animations:document.getAnimations().length});
 }
 return out;
}'''
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path=str(CHROME),args=['--no-sandbox','--disable-gpu'])
 result['browser_version']=browser.version
 page=browser.new_page(viewport={'width':1280,'height':900},reduced_motion='reduce')
 page.on('pageerror',lambda e:result['errors'].append(str(e)))
 for arrangement in ['By depth','By family']:
  for order in ['By group','By stratum','By ID']:
   for dimension in ['Flat','3D']:
    page.goto(URL);page.wait_for_selector('#table .tile');button(page,arrangement);button(page,order)
    if dimension=='3D':button(page,'3D')
    page.wait_for_timeout(80)
    key=(lambda e:(e['group'],int(e['stratum']),e['id'])) if order=='By group' else ((lambda e:(int(e['stratum']),e['group'],e['id'])) if order=='By stratum' else (lambda e:e['id']))
    expected=[e['id'] for e in sorted(elements,key=key)]
    dom=ids(page)
    page.locator('#q').click();page.keyboard.press('Tab')
    walk=[focused(page)]
    for _ in range(58):page.keyboard.press('ArrowRight');walk.append(focused(page))
    page.keyboard.press('Home');home=focused(page);page.keyboard.press('End');end=focused(page)
    page.keyboard.press('Enter');opened=page.locator('dialog.detail').evaluate('(d)=>d.open');page.keyboard.press('Escape');restored=focused(page)
    result['matrix'].append({'arrangement':arrangement,'order':order,'dimension':dimension,'expected':expected,'dom':dom,'dom_matches':dom==expected,'keyboard':walk,'keyboard_matches':walk==expected,'home':home,'end':end,'dialog_opened':opened,'restored':restored,'dimension_buttons':page.locator('.controls button').evaluate_all('(es)=>es.filter(e=>["Flat","3D"].includes(e.textContent)).map(e=>({text:e.textContent,pressed:e.getAttribute("aria-pressed")}))')})
    print(arrangement,order,dimension,'DOM',dom==expected,'keyboard',walk==expected,flush=True)
 page.goto(URL);page.wait_for_selector('#table .tile')
 result['reduced_motion_matches']=page.evaluate("matchMedia('(prefers-reduced-motion: reduce)').matches")
 page.locator('#q').click();page.keyboard.press('Tab');page.keyboard.press('ArrowRight')
 result['flat_reduced_focus_samples']=page.evaluate(sample_js)
 button(page,'3D');page.wait_for_timeout(300)
 page.locator('#q').click();page.keyboard.press('Tab');page.keyboard.press('ArrowRight')
 result['three_reduced_focus_samples']=page.evaluate(sample_js)
 result['names']=page.locator('#table .tile').evaluate_all('(es)=>es.map(e=>({id:e.dataset.id,label:e.getAttribute("aria-label"),badge:e.querySelector(".t-badge").innerText}))')
 result['ax_tree']=page.context.new_cdp_session(page).send('Accessibility.getFullAXTree')
 button(page,'Laws');page.wait_for_timeout(300)
 result['laws_from_three']={'tile_count':page.locator('#table .tile').count(),'rule_count':page.locator('#table .rule').count(),'table_text':page.locator('#table').inner_text()[:1500],'is3d':page.locator('#table').evaluate('(e)=>e.classList.contains("is3d")')}
 page.screenshot(path=str(OUT/'laws-after-3d.png'))
 page.goto(URL);button(page,'Laws');page.wait_for_timeout(100)
 result['laws_from_flat']={'tile_count':page.locator('#table .tile').count(),'rule_count':page.locator('#table .rule').count(),'table_text':page.locator('#table').inner_text()[:1500],'is3d':page.locator('#table').evaluate('(e)=>e.classList.contains("is3d")')}
 page.goto(URL);page.wait_for_selector('#table .tile');page.locator('#q').fill('no_match_gpt6_control_928');page.wait_for_timeout(100)
 result['no_search_match']={'live':page.locator('#live').inner_text(),'tile_count':page.locator('#table .tile').count(),'tab0':page.locator('#table .tile[tabindex="0"]').count(),'button_names':page.locator('#table .tile').evaluate_all('(es)=>es.slice(0,2).map(e=>({name:e.getAttribute("aria-label"),hidden:e.getAttribute("aria-hidden"),opacity:getComputedStyle(e).opacity}))')}
 page.locator('#q').fill('');page.screenshot(path=str(OUT/'first-1280.png'))
 browser.close()
(OUT/'browser-probe.json').write_text(json.dumps(result,indent=2)+'\n')
print('Saved browser-probe.json',flush=True)
