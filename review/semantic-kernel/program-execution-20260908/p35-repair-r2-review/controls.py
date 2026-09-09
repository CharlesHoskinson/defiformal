from pathlib import Path
from playwright.sync_api import sync_playwright
import json,datetime,subprocess
O=Path(__file__).resolve().parent;W=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908');C='/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome';U=(W/'viz/dist/index.html').as_uri();B=(W/'review/semantic-kernel/atlas-residual/p35/grok-r2/before/viz/dist/index.html').as_uri();r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'search_matrix':[],'print':[],'errors':[]}
def save():(O/'controls.json').write_text(json.dumps(r,indent=2)+'\n')
def click(p,n):p.get_by_role('button',name=n,exact=True).click()
def geom(p):return p.locator('#table .tile[data-id="E001"]').evaluate('(e)=>{let r=e.getBoundingClientRect();return {w:r.width,h:r.height,width:e.style.width,height:e.style.height,visible:!e.hidden,position:e.style.position}}')
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path=C,args=['--no-sandbox','--disable-gpu']);p=b.new_page(viewport={'width':1280,'height':900},reduced_motion='reduce');p.on('pageerror',lambda e:r['errors'].append(str(e)));p.add_init_script("window.reviewPrintEvents=[];addEventListener('beforeprint',()=>window.reviewPrintEvents.push('beforeprint'));addEventListener('afterprint',()=>window.reviewPrintEvents.push('afterprint'));")
 for arr in ['By depth','By family']:
  for order in ['By group','By stratum','By ID']:
   p.goto(U);p.wait_for_selector('#table .tile');click(p,arr);click(p,order);click(p,'3D');p.wait_for_timeout(150);m={'arrangement':arr,'order':order,'before':geom(p)}
   p.locator('#q').fill('E001');p.wait_for_timeout(150);m['query']=geom(p);p.locator('#q').fill('');p.wait_for_timeout(150);m['clear']=geom(p);click(p,'Flat');p.wait_for_timeout(150);m['flat_control']=geom(p);r['search_matrix'].append(m);save()
 for version,url in [('r1',B),('r2',U)]:
  for dim in ['Flat','3D']:
   p.goto('about:blank');p.goto(url);p.wait_for_selector('#table .tile')
   if dim=='3D':click(p,'3D')
   p.wait_for_timeout(200);before=geom(p);name=f'{version}-{dim}-fresh.pdf';p.pdf(path=str(O/name),print_background=True);p.wait_for_timeout(80);subprocess.run(['pdftotext','-layout',str(O/name),str(O/name.replace('.pdf','.txt'))],check=True);text=(O/name.replace('.pdf','.txt')).read_text();r['print'].append({'version':version,'dimension':dim,'before':before,'after':geom(p),'events':p.evaluate('window.reviewPrintEvents'),'E001_present':'E001' in text,'CSM_present':'CSM' in text,'pdf':name,'text_characters':len(text)});save()
 p.goto(U);p.wait_for_selector('#table .tile');old=json.loads((O.parent/'p35-review/browser-probe.json').read_text())['names'];prior={e['id']:e['label'] for e in old};names=p.locator('#table .tile').evaluate_all('(es)=>es.map(e=>({id:e.dataset.id,name:e.getAttribute("aria-label"),badge:e.querySelector(".t-badge-word").innerText}))');r['names']=[{**e,'matches_independently_validated_r1_name':e['name']==prior[e['id']]} for e in names];r['contested_badges']=p.locator('.contested .t-badge-word').all_inner_texts();click(p,'3D');r['dimension_state']=p.locator('.controls button').evaluate_all('(es)=>es.filter(e=>["Flat","3D"].includes(e.innerText)).map(e=>({text:e.innerText,pressed:e.getAttribute("aria-pressed")}))');save();b.close()
print('complete')
