import os, subprocess, sys
d = os.path.dirname(os.path.abspath(__file__))
r = subprocess.run([sys.executable, os.path.join(d, 'audit7.py'),
                    os.path.join(d, '_case', 'gradle')],
                   capture_output=True, text=True)
print(r.stdout, end='')
if r.stderr: print(r.stderr, end='', file=sys.stderr)
print('(expect 2 — negative test; exit 1 = checker ne galti pakdi)')
sys.exit(r.returncode)
