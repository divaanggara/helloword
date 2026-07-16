import re

def fix_errors(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix const errors
    content = content.replace('const BorderSide(color: Theme', 'BorderSide(color: Theme')
    content = content.replace('const Divider(color: Theme', 'Divider(color: Theme')
    content = content.replace('const CircularProgressIndicator(color: Theme', 'CircularProgressIndicator(color: Theme')
    
    # Fix onSurfaceXX errors caused by bad replacement order
    content = content.replace('onSurface70', 'onSurface.withOpacity(0.70)')
    content = content.replace('onSurface54', 'onSurface.withOpacity(0.54)')
    content = content.replace('onSurface38', 'onSurface.withOpacity(0.38)')
    content = content.replace('onSurface24', 'onSurface.withOpacity(0.24)')
    content = content.replace('onSurface12', 'onSurface.withOpacity(0.12)')
    content = content.replace('onSurface10', 'onSurface.withOpacity(0.10)')

    # Also remove any leftover const before Positioned or Container if it contains Theme
    # Since regex is safer here:
    content = re.sub(r'const\s+(Positioned\([^)]*Theme\.of)', r'\1', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_errors('lib/screens/login_screen.dart')
fix_errors('lib/screens/beranda_screen.dart')
