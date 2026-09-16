import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_clean import strip_dart
ROOT = '/home/user/Internship_Tasks/alfurqan-android-app'
bad = 0; total = 0
for dp, dn, fn in os.walk(ROOT):
    if any(x in dp for x in ('/build', '/.dart_tool', '/.idea', '/dev_audit')): continue
    for f in fn:
        if not f.endswith('.dart'): continue
        total += 1
        p = os.path.join(dp, f)
        try: src = open(p, encoding='utf-8').read()
        except Exception as e:
            print('READ ERR', p, e); bad += 1; continue
        s = strip_dart(src)
        stack = []; pairs = {')':'(', ']':'[', '}':'{'}
        line = 1; ok = True
        for ch in s:
            if ch == '\n': line += 1
            elif ch in '([{': stack.append((ch, line))
            elif ch in ')]}':
                if not stack or stack[-1][0] != pairs[ch]:
                    print(f'MISMATCH {p}:{line} got {ch}'); ok = False; bad += 1; break
                stack.pop()
        if ok and stack:
            print(f'UNCLOSED {p} open {stack[-1][0]} from line {stack[-1][1]}'); bad += 1
print(f'{total} files checked, {bad} problems')
sys.exit(1 if bad else 0)
