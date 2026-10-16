import re, os, sys

errs = []

# 1. Dart brace/paren balance per file (after stripping comments/strings)
for root, _, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(root, f)
        src = open(p, encoding='utf-8').read()
        s = re.sub(r'"(?:[^"\\]|\\.)*"', '""', src)
        s = re.sub(r"'(?:[^'\\]|\\.)*'", "''", s)
        s = re.sub(r'//.*', '', s)
        s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
        for o, c in [('{', '}'), ('(', ')'), ('[', ']')]:
            if s.count(o) != s.count(c):
                errs.append(f'{p}: unbalanced {o}{c}: {s.count(o)} vs {s.count(c)}')

# 2. Relative imports resolve
for root, _, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(root, f)
        for m in re.finditer(r"import '([^']+)'", open(p, encoding='utf-8').read()):
            spec = m.group(1)
            if spec.startswith('dart:') or spec.startswith('package:'):
                continue
            target = os.path.normpath(os.path.join(root, spec))
            if not os.path.exists(target):
                errs.append(f'{p}: missing import {spec}')

# 3. l10n keys used in code exist in dictionary
locale = open('lib/core/l10n/app_locale.dart', encoding='utf-8').read()
used = set()
for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart') and 'app_locale' not in f:
            src = open(os.path.join(root, f), encoding='utf-8').read()
            used |= set(re.findall(r"\.t\('([^']+)'\)", src))
missing = [k for k in used if f"'{k}'" not in locale]
if missing:
    errs.append('missing l10n keys: ' + ', '.join(missing))

from xml.dom.minidom import parse
for xf in ['android/app/src/main/AndroidManifest.xml',
           'android/app/src/main/res/values/styles.xml',
           'android/app/src/main/res/drawable/launch_background.xml']:
    try:
        parse(xf)
    except Exception as e:
        errs.append(f'{xf}: {e}')

print('ERRORS:' if errs else 'ALL CHECKS PASSED')
for e in errs:
    print(' -', e)
sys.exit(1 if errs else 0)
