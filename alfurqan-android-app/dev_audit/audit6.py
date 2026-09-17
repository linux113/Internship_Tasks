import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_clean import strip_dart
ROOT = '/home/user/Internship_Tasks/alfurqan-android-app'
reports = []

# RULE-A: TextFormField ke constructor block me bare `onSubmitted:` compile
# error hai (Flutter ka TextFormField sirf `onFieldSubmitted` janta hai —
# 17/09 Lalit ke PC par actual break hua tha).
formfields = 0
for dp, dn, fn in os.walk(ROOT):
    if any(x in dp for x in ('/build', '/.dart_tool', '/.idea', '/dev_audit')): continue
    for f in fn:
        if not f.endswith('.dart'): continue
        p = os.path.join(dp, f)
        raw = open(p, encoding='utf-8').read()
        s = strip_dart(raw)
        rel = p.replace(ROOT + '/', '')
        lines = s.split('\n')
        # line-number lookup table
        pos = 0; starts = []
        for ln in lines:
            starts.append(pos); pos += len(ln) + 1
        def lineno(idx):
            lo, hi = 0, len(starts) - 1
            while lo < hi:
                mid = (lo + hi + 1) // 2
                if starts[mid] <= idx: lo = mid
                else: hi = mid - 1
            return lo + 1
        for m in re.finditer(r'\bTextFormField\s*\(', s):
            formfields += 1
            depth = 1; j = m.end(); block = []
            while j < len(s) and depth > 0 and j - m.end() < 6000:
                c = s[j]; block.append(c)
                if c == '(': depth += 1
                elif c == ')': depth -= 1
                j += 1
            txt = ''.join(block)
            if re.search(r'(?<!field)\bonSubmitted\s*:', txt):
                reports.append(f'[A:TextFormField] {rel}:{lineno(m.start())} bare onSubmitted — onFieldSubmitted use karo')
        # RULE-B: dio + get/config-barrel DONO import karne wali file me
        # MultipartFile/FormData sirf `dio.` qualified ho (17/09 "imported
        # from both" ambiguity Lalit ke PC par hui thi).
        # NOTE: import-detection RAW text par — strip_dart import path strings
        # blank kar deta hai ('import          ;'), isliye lines (stripped) se
        # import mat nikalo. Usage-scan stripped lines par hi sahi hai.
        imp = [l2.strip() for l2 in raw.split(chr(10)) if l2.strip().startswith(('import ', 'part '))]
        has_dio = any(re.match(r"^import\s+'package:dio/dio\.dart'", ln) for ln in imp)
        has_barrel = any(re.search(r"(package:get/get\.dart'|/config\.dart')", ln) for ln in imp)
        if has_dio and has_barrel:
            for i, ln in enumerate(lines, 1):
                if ln.strip().startswith(('import ', 'part ')): continue
                for mm in re.finditer(r'\b(MultipartFile|FormData)\b', ln):
                    pre = ln[max(0, mm.start() - 8):mm.start()]
                    if not pre.endswith('dio.'):
                        reports.append(f'[B:multipart] {rel}:{i} bare `{mm.group(1)}` — dio.-qualified likho (dio + get barrel dono import hain)')

for r in sorted(reports): print(r)
print(f'{formfields} TextFormField blocks scanned; {len(reports)} compile-risk issues')
sys.exit(1 if reports else 0)
