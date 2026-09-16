import os, re, sys
ROOT = '/home/user/Internship_Tasks/alfurqan-android-app'
LDIR = f'{ROOT}/multikart/lib/common/language'
KEY_PAT = re.compile(r'''^\s*["']([A-Za-z_][A-Za-z0-9_]*)["']\s*:''', re.M)
langs = {}; ok = True
for code in ('en','ar','hi','kr'):
    src = open(f'{LDIR}/{code}.dart', encoding='utf-8').read()
    ks = re.findall(KEY_PAT, src)
    langs[code] = set(ks)
    print(code, len(ks), 'lang keys')
    if len(ks) != len(langs[code]):
        print(f'DUPLICATE KEYS in {code}!'); ok = False
base = langs['en']
for code in ('ar','hi','kr'):
    if langs[code] != base:
        print('KEY MISMATCH', code, 'missing:', sorted(base-langs[code])[:10], 'extra:', sorted(langs[code]-base)[:10])
        ok = False
TR_PAT = re.compile(r'''["']([A-Za-z_][A-Za-z0-9_]*)["']\s*\.tr\b''')
used = set(); files = 0
for dp, dn, fn in os.walk(ROOT):
    if any(x in dp for x in ('/build', '/.dart_tool', '/.idea', '/dev_audit')): continue
    for f in fn:
        if not f.endswith('.dart'): continue
        full = os.path.join(dp, f).replace('\\','/')
        files += 1
        src = open(os.path.join(dp, f), encoding='utf-8').read()
        if '/common/language/' in full: continue
        for m in TR_PAT.finditer(src): used.add(m.group(1))
missing = sorted(k for k in used if k not in base)
print(f'{files} dart files; .tr used={len(used)} missing={len(missing)}')
if missing:
    print('MISSING KEYS:', missing); ok = False
print('audit2', 'CLEAN' if ok else 'FAIL')
sys.exit(0 if ok else 1)
