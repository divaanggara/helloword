import re

def fix_const(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We just need to remove 'const ' where there's 'Theme.of(context)' in the same statement, 
    # but that's hard to regex. We'll just replace 'const TextStyle' with 'TextStyle', 
    # 'const Text' with 'Text', and 'const Icon' with 'Icon' everywhere.
    content = content.replace('const TextStyle', 'TextStyle')
    content = content.replace('const Text', 'Text')
    content = content.replace('const Icon', 'Icon')
    content = content.replace('const InputDecoration', 'InputDecoration')
    content = content.replace('const Divider', 'Divider')
    content = content.replace('const CircleAvatar', 'CircleAvatar')
    content = content.replace('const BoxDecoration', 'BoxDecoration')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_const('lib/screens/login_screen.dart')
fix_const('lib/screens/beranda_screen.dart')
