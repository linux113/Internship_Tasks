import os, re, sys
# R8/okhttp config check (17/09 Lalit-PC v1678 release-build fail se seekha):
# image_cropper 11.0.0 -> jitpack uCrop 2.2.11 okhttp3.* use karta hai par
# app classpath par nahi aata + plugin me consumer R8 rules missing
# (upstream fix baad me aaya). App-side guard:
#  1) pubspec me image_cropper ho to app/build.gradle me okhttp3 impl ho
#  2) app/proguard-rules.pro maujood ho, okhttp3/okio/ucrop rules ke saath
#  3) build.gradle release block us rules file ko refer kare
GRADLE = sys.argv[1] if len(sys.argv) > 1 else \
    '/home/user/Internship_Tasks/alfurqan-android-app/multikart/android/app/build.gradle'
APP_DIR = os.path.dirname(os.path.abspath(GRADLE))
PUB = sys.argv[2] if len(sys.argv) > 2 else \
    '/home/user/Internship_Tasks/alfurqan-android-app/multikart/pubspec.yaml'
issues = []

def read(p):
    return open(p, encoding='utf-8').read() if os.path.isfile(p) else None

pub = read(PUB)
gradle = read(GRADLE)
if pub is None:
    issues.append(f'[r8-okhttp] pubspec.yaml missing ({PUB})')
elif 'image_cropper:' not in pub:
    print('image_cropper absent — okhttp/R8 guard skip (sahi hai)')
    sys.exit(0)

if gradle is None:
    issues.append(f'[r8-okhttp] app/build.gradle missing ({GRADLE})')
else:
    if not re.search(r"implementation\s+['\"]com\.squareup\.okhttp3:okhttp:", gradle):
        issues.append('[r8-okhttp] okhttp3 implementation app/build.gradle me nahi — uCrop(jitpack) okhttp app classpath par nahi laata, release R8 "Missing class okhttp3.*" fail karega (crop plugin ke saath ZAROORI)')
    if not re.search(r"proguardFiles\s+[^#]*['\"]proguard-rules\.pro['\"]", gradle):
        issues.append('[r8-okhttp] release buildType me proguard-rules.pro referenced nahi — image_cropper 11.0.0 ke consumer rules missing hain, app-side rules bina R8 fail karega')

rules = read(os.path.join(APP_DIR, 'proguard-rules.pro'))
if pub is not None and 'image_cropper:' in pub:
    if rules is None:
        issues.append(f'[r8-okhttp] app/proguard-rules.pro missing ({APP_DIR})')
    else:
        for pat, label in [(r'okhttp3', 'okhttp3'), (r'okio', 'okio'),
                           (r'com\.yalantis\.ucrop', 'uCrop')]:
            if f'-keep class {label}' not in rules and not re.search(
                    r'-dontwarn\s+' + pat, rules):
                issues.append(f'[r8-okhttp] proguard-rules.pro me {label} keep/dontwarn rule nahi (image_cropper release fix ke liye chahiye)')

for i in issues: print(i)
print(f'{len(issues)} r8-okhttp issues')
sys.exit(1 if issues else 0)
