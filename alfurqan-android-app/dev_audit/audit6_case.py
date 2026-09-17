import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_clean import strip_dart
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '_case')
reports = []
formfields = 0
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if f != '_buggy6.dart': continue
        p = os.path.join(dp, f)
        raw = open(p, encoding='utf-8').read()
        s = strip_dart(raw)
        rel = p.replace(ROOT + '/', '')
        lines = s.split('\n')
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
            if re.search(r'(?<!field)\bonSubmitted\s*:', ''.join(block)):
                reports.append(f'[A:TextFormField] {rel}:{lineno(m.start())} bare onSubmitted')
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
                    if not ln[max(0, mm.start() - 8):mm.start()].endswith('dio.'):
                        reports.append(f'[B:multipart] {rel}:{i} bare `{mm.group(1)}`')
for r in sorted(reports): print(r)
print(f'{formfields} TextFormField blocks; {len(reports)} compile-risk issues (expect 3 — negative test)')
sys.exit(1 if reports else 0)
