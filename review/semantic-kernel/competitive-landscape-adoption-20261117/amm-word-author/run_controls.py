from pathlib import Path
import argparse,subprocess,sys,json
p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);p.add_argument('--toolchain',type=Path,required=True);p.add_argument('--source',type=Path,default=Path(__file__).with_name('Controls.lean'));a=p.parse_args()
try:
 if not a.source.read_bytes():raise FileNotFoundError('empty control source')
 env={'PATH':str(a.toolchain/'bin')+':/usr/bin:/bin','HOME':str(Path.home())}
 r=subprocess.run([str(a.toolchain/'bin/lake'),'env','lean',str(a.source)],cwd=a.repo/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 sys.stdout.buffer.write(r.stdout);sys.stderr.buffer.write(r.stderr)
 if b'BLOCKED:' in r.stdout+r.stderr:sys.exit(3)
 if r.returncode:sys.exit(1)
 rows=[s.split() for s in r.stdout.decode().splitlines() if s.startswith('WORD_CONTROL ') and not s.startswith('WORD_CONTROL PASSED ')]
 if not rows:print('BLOCKED: empty observed controls',file=sys.stderr);sys.exit(3)
 if len(rows)!=15 or len({s[1] for s in rows})!=15 or any(len(s)!=3 or s[2]!='true' for s in rows) or r.stdout.decode().splitlines().count('WORD_CONTROL PASSED 15/15')!=1:
  print('FAIL: incomplete or false Word controls',file=sys.stderr);sys.exit(1)
 print(json.dumps({'status':'PASS','finite_assertions':15,'scope':'fresh finite control source importing the pinned built Checked module'}))
except (FileNotFoundError,PermissionError) as error:
 print('BLOCKED: '+str(error),file=sys.stderr);sys.exit(3)
