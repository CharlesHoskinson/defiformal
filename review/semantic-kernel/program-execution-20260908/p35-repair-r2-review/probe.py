from pathlib import Path
from playwright.sync_api import sync_playwright
import json,datetime,subprocess
O=Path(__file__).resolve().parent;W=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908');U=(W/'viz/dist/index.html').as_uri();C='/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome'
D=json.loads(subprocess.check_output(['node','--input-type=module','-e',f'import * as d from "{(W/"viz/src/data.ts").as_uri()}";console.log(JSON.stringify(d))'],text=True));r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'matrix':[],'motion':[],'search':[],'errors':[]}
def save():(O/'probe.json').write_text(json.dumps(r,indent=2)+'\n')
def b(p,s):p.get_by_role('button',name=s,exact=True).click()
def inspect(p):return p.evaluate('''() => {const ts=[...document.querySelectorAll('#table .tile')].filter(e=>!e.hidden);const rect=e=>{const r=e.getBoundingClientRect();return {x:r.x,y:r.y,w:r.width,h:r.height}};return {tiles:ts.map(e=>({id:e.dataset.id,rect:rect(e),style:e.getAttribute('style'),overflow:e.scrollHeight-e.clientHeight,children:[...e.children].map(c=>({cls:c.className,rect:rect(c)}))})),is3d:document.querySelector('#table').classList.contains('is3d'),docWidth:document.documentElement.scrollWidth,viewport:innerWidth,root:getComputedStyle(document.documentElement).fontSize,live:document.querySelector('#live')?.innerText,options:[...document.querySelectorAll('#search-results [role=option]')].map(e=>e.textContent)}}''')
samples='''async()=>{let a=[];for(let i=0;i<40;i++){await new Promise(requestAnimationFrame);let e=document.querySelector('#table .tile:focus')||document.querySelector('#table .tile');let r=e.getBoundingClientRect();a.push({x:r.x,y:r.y,w:r.width,h:r.height,parent:e.parentElement.style.transform,animations:document.getAnimations().length})}return a}'''
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path=C,args=['--no-sandbox','--disable-gpu']);p=browser.new_page(viewport={'width':1280,'height':900},reduced_motion='reduce');p.on('pageerror',lambda e:r['errors'].append(str(e)))
 for arr in ['By depth','By family']:
  for order in ['By group','By stratum','By ID']:
   for dim in ['Flat','3D']:
    p.goto(U);p.wait_for_selector('#table .tile');b(p,arr);b(p,order)
    if dim=='3D':b(p,dim)
    p.wait_for_timeout(100)
    key=(lambda e:(e['group'],e['stratum'],e['id'])) if order=='By group' else ((lambda e:(e['stratum'],e['group'],e['id'])) if order=='By stratum' else (lambda e:e['id']))
    expected=[e['id'] for e in sorted(D['ELEMENTS'],key=key)];dom=p.locator('#table .tile').evaluate_all('(es)=>es.map(e=>e.dataset.id)');live=p.locator('#live').inner_text();p.locator('#q').click();p.keyboard.press('Tab');walk=[]
    for i in range(59):walk.append(p.evaluate('document.activeElement.dataset.id'));p.keyboard.press('ArrowRight')
    p.keyboard.press('Enter');opened=p.evaluate('Boolean(document.querySelector("dialog.detail")?.open)');p.keyboard.press('Escape');p.wait_for_timeout(40);restored=p.evaluate('document.activeElement.dataset.id');row={'arrangement':arr,'order':order,'dimension':dim,'expected':expected,'dom':dom,'dom_pass':dom==expected,'walk':walk,'keyboard_pass':walk==expected,'live':live,'opened':opened,'restored':restored};r['matrix'].append(row);save()
 for motion in ['reduce','no-preference']:
  p.emulate_media(reduced_motion=motion)
  for dim in ['Flat','3D']:
   p.goto(U);p.wait_for_selector('#table .tile')
   if dim=='3D':b(p,dim);p.wait_for_timeout(300)
   p.locator('#q').click();p.keyboard.press('Tab');p.keyboard.press('ArrowRight');r['motion'].append({'motion':motion,'dimension':dim,'matches':p.evaluate("matchMedia('(prefers-reduced-motion: reduce)').matches"),'samples':p.evaluate(samples)});save()
 p.emulate_media(reduced_motion='reduce')
 for dim in ['Flat','3D']:
  for view in ['Laws','Hazards']:
   p.goto(U);p.wait_for_selector('#table .tile')
   if dim=='3D':b(p,dim)
   b(p,view);p.wait_for_timeout(100);r.setdefault('transitions',[]).append({'from':dim,'view':view,'tiles':p.locator('#table .tile').count(),'rules':p.locator('#table .rule').count()});b(p,'The table');p.wait_for_timeout(100);r['transitions'][-1]['return']=inspect(p);save()
 for dim in ['Flat','3D']:
  p.goto(U);p.wait_for_selector('#table .tile')
  if dim=='3D':b(p,dim);p.wait_for_timeout(300)
  for query in ['E001','GPT6_absent_control_993','E0','']:
   p.locator('#q').fill(query);p.wait_for_timeout(160);r['search'].append({'dimension':dim,'query':query,'observation':inspect(p)});save()
   if query=='E001':
    p.locator('#q').press('Enter');r['search'][-1]['opened']=p.evaluate('Boolean(document.querySelector("dialog.detail")?.open)');p.keyboard.press('Escape');p.wait_for_timeout(60)
  p.screenshot(path=str(O/(dim+'-after-search.png')),full_page=True)
 # root-font, default real geometry, print actual browser-generated PDF without synthetic beforeprint
 p.goto(U);p.wait_for_selector('#table .tile');p.wait_for_timeout(100);r['normal_geometry']=inspect(p);p.evaluate('document.documentElement.style.fontSize="200%"');p.wait_for_timeout(200);r['root200_geometry']=inspect(p);p.screenshot(path=str(O/'root200.png'),full_page=True)
 p.goto(U);p.wait_for_selector('#table .tile');p.wait_for_timeout(100);p.pdf(path=str(O/'flat-direct.pdf'),print_background=True);r['after_pdf']=inspect(p)
 b(p,'3D');p.wait_for_timeout(300);p.pdf(path=str(O/'three-direct.pdf'),print_background=True);r['three_after_pdf']=inspect(p);save();browser.close()
print('completed',flush=True)
