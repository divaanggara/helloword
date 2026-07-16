import re

with open('lib/screens/login_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace hardcoded light mode colors to Theme-aware
content = content.replace('backgroundColor: const Color(0xFFFCF9F8)', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor')
content = content.replace('color: Color(0xFFFCF9F8)', 'color: Theme.of(context).scaffoldBackgroundColor')

# Text Colors
content = content.replace('color: Color(0xFF1B1C1C)', 'color: Theme.of(context).colorScheme.onSurface')
content = content.replace('color: Color(0xFF454652)', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)')
content = content.replace('color: const Color(0xFF454652)', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)')
content = content.replace('color: const Color(0xFF1B1C1C)', 'color: Theme.of(context).colorScheme.onSurface')

# Borders / Lines
content = content.replace('color: Color(0xFFC5C5D4)', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)')
content = content.replace('color: const Color(0xFFC5C5D4)', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)')

# The ElevatedButton background uses Color(0xFF24389C) and text is Colors.white. This is fine to leave as is for primary color.
content = content.replace('backgroundColor: const Color(0xFF24389C)', 'backgroundColor: Theme.of(context).colorScheme.primary')
content = content.replace('color: Color(0xFF24389C)', 'color: Theme.of(context).colorScheme.primary')
content = content.replace('color: const Color(0xFF24389C)', 'color: Theme.of(context).colorScheme.primary')


with open('lib/screens/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
