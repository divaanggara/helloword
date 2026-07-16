import re

filepath = 'lib/screens/login_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace `children: const [` with `children: [` everywhere. It's safe since flutter analyzer will suggest adding const back where possible.
content = content.replace('children: const [', 'children: [')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
