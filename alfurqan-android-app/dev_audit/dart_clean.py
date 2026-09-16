import re, sys

def strip_dart(src):
    out = []
    i, n = 0, len(src)
    mode = None
    while i < n:
        c = src[i]
        two = src[i:i+2]
        three = src[i:i+3]
        if mode is None:
            if two == '//':
                mode = 'line'; out.append('  '); i += 2; continue
            if two == '/*':
                mode = 'block'; out.append('  '); i += 2; continue
            if two in ("r'", 'r"'):
                mode = 'raw_sq' if two == "r'" else 'raw_dq'; out.append('  '); i += 2; continue
            if three == "'''":
                mode = 'tsq'; out.append('   '); i += 3; continue
            if three == '"""':
                mode = 'tdq'; out.append('   '); i += 3; continue
            if c == "'":
                mode = 'sq'; out.append(' '); i += 1; continue
            if c == '"':
                mode = 'dq'; out.append(' '); i += 1; continue
            out.append(c); i += 1; continue
        if mode == 'line':
            if c == '\n': mode = None; out.append('\n')
            else: out.append(' ')
            i += 1; continue
        if mode == 'block':
            if two == '*/': mode = None; out.append('  '); i += 2; continue
            out.append('\n' if c == '\n' else ' '); i += 1; continue
        if mode in ('sq', 'dq'):
            q = "'" if mode == 'sq' else '"'
            if c == '\\': out.append('  '); i += 2; continue
            if c == q: mode = None; out.append(' '); i += 1; continue
            out.append('\n' if c == '\n' else ' '); i += 1; continue
        if mode in ('tsq', 'tdq'):
            if three == "'''" or three == '"""':
                mode = None; out.append('   '); i += 3; continue
            out.append('\n' if c == '\n' else ' '); i += 1; continue
        if mode in ('raw_sq', 'raw_dq'):
            q = "'" if mode == 'raw_sq' else '"'
            if c == q: mode = None; out.append(' '); i += 1; continue
            out.append('\n' if c == '\n' else ' '); i += 1; continue
    return ''.join(out)
