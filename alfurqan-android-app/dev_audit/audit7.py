import os, re, sys
# Gradle/AGP config consistency check (17/09 Lalit-PC build-break se seekha):
#  1) androidx.core 1.18 / activity 1.12 family -> AGP >= 8.9.1 zaroori
#  2) AGP 8.9.x -> Gradle wrapper >= 8.11.1 zaroori
#  3) AGP 8.8+ me android.enableJetifier=true HARD ERROR
DEFAULT_BASE = '/home/user/Internship_Tasks/alfurqan-android-app/multikart/android'
BASE = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BASE
issues = []

def vparse(t):
    return tuple(int(x) for x in t.split('.'))

def read(p):
    return open(p, encoding='utf-8').read() if os.path.isfile(p) else None

settings = read(os.path.join(BASE, 'settings.gradle'))
if settings is None:
    issues.append(f'[gradle-config] settings.gradle missing ({BASE})')
else:
    m = re.search(r'com\.android\.application"?\s+version\s+"(\d+\.\d+\.\d+)"', settings)
    if not m:
        issues.append('[gradle-config] AGP version pin settings.gradle me nahi mila')
    elif vparse(m.group(1)) < (8, 9, 1):
        issues.append(f'[gradle-config] AGP {m.group(1)} < 8.9.1 — androidx.core 1.18/activity 1.12 family AGP 8.9.1+ maangti hai (checkAarMetadata fail hoga)')

wrapper = read(os.path.join(BASE, 'gradle', 'wrapper', 'gradle-wrapper.properties'))
if wrapper is None:
    issues.append(f'[gradle-config] gradle-wrapper.properties missing ({BASE})')
else:
    m = re.search(r'gradle-(\d+\.\d+(?:\.\d+)?)-', wrapper)
    if not m:
        issues.append('[gradle-config] gradle version distributionUrl me nahi mila')
    elif vparse(m.group(1)) < (8, 11, 1):
        issues.append(f'[gradle-config] Gradle {m.group(1)} < 8.11.1 — AGP 8.9.x ko kam se kam 8.11.1 chahiye')

props = read(os.path.join(BASE, 'gradle.properties'))
if props is None:
    issues.append(f'[gradle-config] gradle.properties missing ({BASE})')
else:
    if re.search(r'^\s*android\.enableJetifier\s*=\s*true\s*$', props, re.M):
        issues.append('[gradle-config] android.enableJetifier=true — AGP 8.8+ me HARD ERROR (false karo; saare plugins AndroidX-native hain)')

for i in issues: print(i)
print(f'{len(issues)} gradle-config issues ({BASE})')
sys.exit(1 if issues else 0)
