from pathlib import Path
from playwright.sync_api import sync_playwright
import json,subprocess,hashlib,datetime,re
O=Path(__file__).resolve().parent
W=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908')
C='/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome'
base=W/'review/semantic-kernel/atlas/implementation/grok-accessibility-r1/artifacts/baseline-dist-index.html'
current=W/'viz/dist/index.html'
data=json.loads(subprocess.check_output(['node','--input-type=module','-e',f'import * as d from "{(W/"viz/src/data.ts").as_uri()}"; console.log(JSON.stringify(d))'],text=True))
(O/'exported-data.json').write_text(json.dumps(data,indent=2)+'\n')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'transitions':[],'errors':[]}
def b(p,s):p.get_by_role('button',name=s,exact=True).click()
def stat(p):return p.locator('#table').evaluate('(e)=>({tiles:e.querySelectorAll(".tile").length,rules:e.querySelectorAll(".rule").length,is3d:e.classList.contains("is3d"),text:e.innerText.slice(0,400)})')
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path=C,args=['--no-sandbox','--disable-gpu'])
 p=browser.new_page(viewport={'width':1280,'height':900},reduced_motion='reduce')
 p.on('pageerror',lambda e:r['errors'].append(str(e)))
 for name,path in [('baseline',base),('candidate',current)]:
  for view in ['Laws','Hazards']:
   for dim in ['Flat','3D']:
    p.goto(path.as_uri());p.wait_for_selector('#table .tile')
    if dim=='3D':b(p,'3D');p.wait_for_timeout(200)
    b(p,view);p.wait_for_timeout(200)
    r['transitions'].append({'input':name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'dimension':dim,'view':view,**stat(p)})
 p.goto(current.as_uri());p.wait_for_selector('#table .tile');b(p,'By ID');p.wait_for_timeout(100)
 r['flat_ax_tree']=p.context.new_cdp_session(p).send('Accessibility.getFullAXTree')
 r['order_change_live']=p.locator('#live').inner_text()
 p.locator('#q').fill('E001');p.wait_for_timeout(100)
 r['search_unique_before']={'live':p.locator('#live').inner_text(),'results':p.locator('[role="listbox"]').count(),'visible_tiles':p.locator('#table .tile:visible').count()}
 p.locator('#q').press('Enter');p.wait_for_timeout(60)
 r['search_enter']={'dialog':p.evaluate('Boolean(document.querySelector("dialog.detail")?.open)'),'hash':p.evaluate('location.hash'),'focus':p.evaluate('document.activeElement.id')}
 p.locator('#q').fill('');p.wait_for_timeout(80)
 names=p.locator('#table .tile').evaluate_all('(es)=>es.map(e=>({id:e.dataset.id,name:e.getAttribute("aria-label"),visible:e.innerText,badge:e.querySelector(".t-badge").innerText}))')
 groups={g['id']:g['name'] for g in data['GROUPS']}; words={'core':'core','candidate':'candidate — not yet defensible as core','limit':'degenerate limit — not an element','provisional':'contested — not an element'}
 # Store independently source-derived fields; evaluate semantic field membership explicitly below.
 for n in names:
  e=next(e for e in data['ELEMENTS'] if e['id']==n['id'])
  hs=[h for h in data['HAZARDS'] if re.search(r'(?<![A-Za-z])'+re.escape(e['sym'])+r'(?![A-Za-z])',h['combo'])]
  n['expected_fields']=[e['sym'],e['name'],'ID '+e['id'],'group '+e['group']+' '+groups[e['group']],'stratum S'+str(e['stratum']),e['status'],data['ATOM_LABEL'][e['atom']],['forbidden' if h['cls']=='F' else 'elevated' if h['cls']=='H' else 'unverifiable' for h in hs],bool(e.get('disc'))]
  f=n['expected_fields'];n['nine_fields_match']=all(x in n['name'] for x in f[:7]) and (all(x in n['name'] for x in f[7]) if hs else 'no hazard membership' in n['name']) and (('discriminator required' in n['name'] and 'no discriminator' not in n['name']) if f[8] else 'no discriminator required' in n['name'])
 r['names']=names
 measure='''() => {const t=document.querySelector('#table .tile');return {root:getComputedStyle(document.documentElement).fontSize,tileWidth:t.getBoundingClientRect().width,tileHeight:t.getBoundingClientRect().height,nameFont:getComputedStyle(t.querySelector('.t-nm')).fontSize,badgeFont:getComputedStyle(t.querySelector('.t-badge')).fontSize,viewport:innerWidth,documentWidth:document.documentElement.scrollWidth,tableWidth:document.querySelector('#table').scrollWidth}}'''
 r['text_scale_100']=p.evaluate(measure);p.evaluate('document.documentElement.style.fontSize="32px"');r['text_scale_200']=p.evaluate(measure)
 p.screenshot(path=str(O/'root-font-200.png'))
 p.goto(current.as_uri());p.set_viewport_size({'width':640,'height':450});p.wait_for_selector('#table .tile');r['narrow_reflow']=p.evaluate(measure);p.screenshot(path=str(O/'narrow-640.png'))
 p.set_viewport_size({'width':1280,'height':900});p.goto(current.as_uri());p.wait_for_selector('#table .tile')
 r['find_engine']={'known':p.evaluate('window.find("Constant-product invariant")'),'unknown':p.evaluate('window.find("GPT6_impossible_search_928")')}
 p.emulate_media(media='print');r['print_dom']={'tiles':p.locator('#table .tile:visible').count(),'rules':p.locator('#table .rule:visible').count()};p.pdf(path=str(O/'flat-print.pdf'),print_background=True)
 p.emulate_media(media='screen');p.goto('about:blank');p.goto(current.as_uri()+'#E001');p.wait_for_timeout(120)
 r['deep_link']={'dialog':p.evaluate('Boolean(document.querySelector("dialog.detail")?.open)'),'text':p.evaluate('document.querySelector("dialog.detail")?.innerText?.slice(0,250) || null')}
 browser.close()
(O/'residual-probe.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({k:v for k,v in r.items() if k not in ['flat_ax_tree','names']},indent=2))
print('nine fields',sum(n['nine_fields_match'] for n in names),'/',len(names))
