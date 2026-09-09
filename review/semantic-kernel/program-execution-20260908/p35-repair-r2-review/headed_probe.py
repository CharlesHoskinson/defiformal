from pathlib import Path
from playwright.sync_api import sync_playwright
from PIL import ImageGrab
import ctypes,subprocess,os,time,json,datetime
O=Path(__file__).resolve().parent;U=Path('/home/charl/defiformal-wt-atlas-grok-gpt6-20260908/viz/dist/index.html').as_uri();display=next(':'+str(i) for i in range(141,160) if not Path('/tmp/.X11-unix/X'+str(i)).exists());r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'display':display,'zoom':[]};log=open(O/'xvfb.stderr.log','w');xv=subprocess.Popen(['Xvfb',display,'-screen','0','1600x1100x24','-nolisten','tcp'],stdout=log,stderr=log)
try:
 time.sleep(.25);x=ctypes.CDLL('libX11.so.6');xt=ctypes.CDLL('libXtst.so.6');x.XOpenDisplay.argtypes=[ctypes.c_char_p];x.XOpenDisplay.restype=ctypes.c_void_p;d=x.XOpenDisplay(display.encode());assert d;x.XStringToKeysym.argtypes=[ctypes.c_char_p];x.XStringToKeysym.restype=ctypes.c_ulong;x.XKeysymToKeycode.argtypes=[ctypes.c_void_p,ctypes.c_ulong];x.XKeysymToKeycode.restype=ctypes.c_uint;x.XFlush.argtypes=[ctypes.c_void_p];xt.XTestFakeKeyEvent.argtypes=[ctypes.c_void_p,ctypes.c_uint,ctypes.c_int,ctypes.c_ulong]
 def key(k,down):xt.XTestFakeKeyEvent(d,x.XKeysymToKeycode(d,x.XStringToKeysym(k.encode())),down,0)
 def combo(k):key('Control_L',1);key(k,1);key(k,0);key('Control_L',0);x.XFlush(d)
 def letter(k):key(k,1);key(k,0);x.XFlush(d)
 def shot(n):ImageGrab.grab(xdisplay=display).save(O/n)
 with sync_playwright() as pw:
  b=pw.chromium.launch(executable_path='/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome',headless=False,args=['--no-sandbox','--disable-gpu','--window-size=1280,960','--window-position=0,0'],env={**os.environ,'DISPLAY':display});p=b.new_page(no_viewport=True,reduced_motion='reduce');p.goto(U);p.wait_for_selector('#table .tile');p.wait_for_timeout(300)
  metrics='''()=>({innerWidth,innerHeight,outerWidth,outerHeight,dpr:devicePixelRatio,visualScale:visualViewport.scale,root:getComputedStyle(document.documentElement).fontSize,scrollWidth:document.documentElement.scrollWidth,tiles:[...document.querySelectorAll('#table .tile')].map(e=>{let r=e.getBoundingClientRect();return {id:e.dataset.id,x:r.x,y:r.y,w:r.width,h:r.height,overflow:e.scrollHeight-e.clientHeight,font:getComputedStyle(e.querySelector('.t-nm')).fontSize}})})'''
  r['zoom'].append({'step':0,'metrics':p.evaluate(metrics)})
  for i in range(5):combo('equal');p.wait_for_timeout(200);r['zoom'].append({'step':i+1,'metrics':p.evaluate(metrics)})
  shot('native-zoom200.png');p.locator('#table').scroll_into_view_if_needed();p.wait_for_timeout(150);shot('native-zoom200-table.png');r['zoom_table']=p.evaluate(metrics)
  combo('0');p.wait_for_timeout(250);combo('f');p.wait_for_timeout(150)
  for c in 'constant-product':letter('minus' if c=='-' else c)
  p.wait_for_timeout(300);shot('native-find-positive.png');r['find_selection']=p.evaluate('getSelection()?.toString()');combo('a')
  for c in 'zzzzgptsixabsent':letter(c)
  p.wait_for_timeout(200);shot('native-find-negative.png');letter('Escape');p.wait_for_timeout(150)
  combo('p');p.wait_for_timeout(1800);shot('native-print-preview.png');r['pages_after_print']=[q.url for q in b.contexts[0].pages];letter('Escape');p.wait_for_timeout(300);r['after_print_metrics']=p.evaluate(metrics)
  b.close()
 (O/'headed-probe.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'display':display,'zoom':[(a['step'],a['metrics']['innerWidth'],a['metrics']['dpr']) for a in r['zoom']],'selection':r['find_selection']},indent=2))
finally:
 xv.terminate();xv.wait(timeout=5);log.close()
