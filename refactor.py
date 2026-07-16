import re

with open('lib/screens/beranda_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Backgrounds
content = content.replace('backgroundColor: const Color(0xFF0B101E)', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor')
content = content.replace('color: const Color(0xFF0B101E)', 'color: Theme.of(context).scaffoldBackgroundColor')
content = content.replace('color: const Color(0xFF131B2F)', 'color: Theme.of(context).colorScheme.surface')
content = content.replace('color: const Color(0xFF1E293B)', 'color: Theme.of(context).colorScheme.surface')
content = content.replace('backgroundColor: const Color(0xFF1E293B)', 'backgroundColor: Theme.of(context).colorScheme.surface')

# Text Colors (only safe ones that look like `color: Colors.white`)
# To avoid replacing Colors.white inside blue buttons or specific backgrounds, 
# we can just blindly replace text colors and see. 
# Actually, let's just replace `color: Colors.white` with `color: Theme.of(context).colorScheme.onSurface`
# Wait, let's look for `style: TextStyle(..., color: Colors.white, ...)` specifically?
# Let's replace `color: Colors.white` -> `color: Theme.of(context).colorScheme.onSurface`
# Then we will fix up the buttons if needed.
content = content.replace('color: Colors.white', 'color: Theme.of(context).colorScheme.onSurface')
content = content.replace('color: Colors.white70', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)')
content = content.replace('color: Colors.white54', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)')
content = content.replace('color: Colors.white38', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)')
content = content.replace('color: Colors.white24', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24)')
content = content.replace('color: Colors.white12', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)')
content = content.replace('color: Colors.white10', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.10)')

with open('lib/screens/beranda_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
