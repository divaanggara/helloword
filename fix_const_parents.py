import re

def fix_const_parents(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove `const ` before Row or Column or Center or Padding if it exists
    content = content.replace('const Row(', 'Row(')
    content = content.replace('const Column(', 'Column(')
    content = content.replace('const Center(', 'Center(')
    content = content.replace('const Padding(', 'Padding(')
    content = content.replace('const SizedBox(', 'SizedBox(') # harmless
    content = content.replace('const Expanded(', 'Expanded(')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_const_parents('lib/screens/login_screen.dart')
fix_const_parents('lib/screens/beranda_screen.dart')
