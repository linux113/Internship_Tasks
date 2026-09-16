import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_clean import strip_dart
ROOT = '/home/user/Internship_Tasks/alfurqan-android-app'
FIND_PAT = re.compile(r'Get\.find<\s*([A-Za-z0-9_]+)\s*>')
warns = 0; checked = 0; fwo = 0
for dp, dn, fn in os.walk(ROOT):
    if any(x in dp for x in ('/build', '/.dart_tool', '/.idea', '/dev_audit')): continue
    for f in fn:
        if not f.endswith('.dart'): continue
        p = os.path.join(dp, f)
        src = open(p, encoding='utf-8').read()
        if 'Get.find<' not in src: continue
        s = strip_dart(src)
        lines = s.split('\n')
        rel = p.replace(ROOT+'/', '')
        for i, ln in enumerate(lines):
            for m in FIND_PAT.finditer(ln):
                ctrl = m.group(1)
                checked += 1
                lo = max(0, i-3); hi = min(len(lines), i+1)
                ctx = '\n'.join(lines[lo:hi])
                if 'isRegistered' in ctx or 'Get.put' in ctx or '.obs' in ln.split('Get.find')[0]:
                    continue
                warns += 1
                print(f'[warn] {rel}:{i+1} unguarded Get.find<{ctrl}>')
        if 'firstWhere(' in s:
            for i, ln in enumerate(lines):
                if 'firstWhere(' in ln:
                    seg = '\n'.join(lines[i:i+8])
                    if 'orElse' not in seg:
                        fwo += 1
                        print(f'[warn] {rel}:{i+1} firstWhere w/o orElse')
print(f'{checked} Get.find calls, {warns} warns; firstWhere-risk {fwo}')
print('audit3 done (warns tolerated if pre-existing)')
