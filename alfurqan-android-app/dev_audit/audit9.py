#!/usr/bin/env python3
"""audit9 — 28/09 Lalit build error ka guard: koi lib/ file jo
StatelessWidget/StatefulWidget/Widget/BuildContext/Key USE karti hai par
usme flutter/material.dart YA config.dart (jo chain se material laata hai)
import NAHI ho — to `flutter run` guiysafe "Type not found" dega (jeti bhi
static scan isko miss karti thi; sandbox me flutter SDK nahi hai isliye
ye python guard hai).
Exit 0 = clean.
"""
import re
import sys
from pathlib import Path

ROOT = Path('/home/user/Internship_Tasks/alfurqan-android-app/multikart/lib')
USES = re.compile(
    r'\b(StatelessWidget|StatefulWidget|State<|BuildContext|Key\?|Widget\b|MaterialApp|ThemeData|IconData|Color\b|TextStyle|Image.network|EdgeInsets)\b')
IMPORT_OK = re.compile(
    r"import\s+(['\"])(package:flutter/(material|cupertino|widgets)\.dart?|dart:ui|.*config\.dart)\1")

problems = []
count = 0
for f in sorted(ROOT.rglob('*.dart')):
    rel = str(f.relative_to(ROOT))
    if rel.startswith('common/language/'):
        continue  # pure data map (translations) — flutter import nahi chahiye
    text = f.read_text(encoding='utf8', errors='replace')
    body = '\n'.join(line for line in text.splitlines()
                     if not line.lstrip().startswith('import '))
    if not USES.search(body):
        continue
    count += 1
    if not IMPORT_OK.search(text):
        # flutter/widgets bhi chain me aaye (package:flutter/material.dart
        # etc.) — check kiya; config.dart ke andar ka chain hum trust karte
        problems.append(str(f.relative_to(ROOT.parent)))

print('audit9:', count, 'flutter-widget files checked')
if problems:
    print('audit9 ISSUES:', len(problems))
    for p in problems:
        print('  - imports missing flutter framework:', p)
    sys.exit(1)
print('audit9 CLEAN')
