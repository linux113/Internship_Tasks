import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_clean import strip_dart
ROOT = '/home/user/Internship_Tasks/alfurqan-android-app'
KEYWORDS = {'if','for','while','switch','catch','return','do','else','try','on','assert',
            'with','throw','yield','await','sync','async','case','default','new','const',
            'final','var','get','set','is','in','super','this','true','false','null'}
FUNC_DECL = re.compile(r'^\s*(?:static\s+)?(?:[A-Za-z_<>.?,\s]+\s)?([a-z_][A-Za-z0-9_]*)\s*\([^()]*\)\s*(?:async\s*\*?\s*)?\{\s*$')
reports = set(); bodies = 0
for dp, dn, fn in os.walk(ROOT):
    if any(x in dp for x in ('/build', '/.dart_tool', '/.idea', '/dev_audit')): continue
    for f in fn:
        if not f.endswith('.dart'): continue
        p = os.path.join(dp, f)
        s = strip_dart(open(p, encoding='utf-8').read())
        lines = s.split('\n')
        rel = p.replace(ROOT+'/', '')
        n = len(lines)
        for i in range(n):
            m = FUNC_DECL.match(lines[i])
            if not m or m.group(1) in KEYWORDS: continue
            d = lines[i].count('{') - lines[i].count('}')
            if d <= 0: continue
            bodies += 1
            j = i + 1; depth = d; body = []
            while j < n and depth > 0:
                l2 = lines[j]; body.append((j+1, l2))
                depth += l2.count('{') - l2.count('}'); j += 1
            decls = {}; depth = 0
            for lnno, l2 in body:
                if depth == 0:
                    mm = FUNC_DECL.match(l2)
                    if mm and mm.group(1) not in KEYWORDS:
                        decls.setdefault(mm.group(1), lnno)
                depth += l2.count('{') - l2.count('}')
            for lnno, l2 in body:
                for name, dln in decls.items():
                    if lnno >= dln: continue
                    for mm in re.finditer(r'\b' + re.escape(name) + r'\s*\(', l2):
                        k = mm.start() - 1
                        while k >= 0 and l2[k] in ' \t': k -= 1
                        if k >= 0 and (l2[k] == '.' or l2[k].isalnum() or l2[k] == '_'):
                            continue
                        reports.add(f'[fwd-ref] {rel}:{lnno} `{name}` used before local decl at :{dln}')
for r in sorted(reports): print(r)
print(f'{bodies} bodies scanned; {len(reports)} forward-reference issues')
sys.exit(1 if reports else 0)
