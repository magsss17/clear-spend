#!/usr/bin/env python3
"""
Script to help set up the app icon for ClearSpend iOS app.
This script will copy and resize your logo to the AppIcon.appiconset folder.
"""

import os
import sys
from pathlib import Path
from PIL import Image

def setup_app_icon(logo_path, output_dir):
    """
    Copy and resize logo to AppIcon format.
    
    Args:
        logo_path: Path to the logo image file
        output_dir: Directory where AppIcon.appiconset is located
    """
    try:
        # Load the logo
        logo = Image.open(logo_path)
        
        # Convert to RGB if necessary (remove transparency for iOS)
        if logo.mode in ('RGBA', 'LA', 'P'):
            # Create a white background
            background = Image.new('RGB', logo.size, (255, 255, 255))
            if logo.mode == 'P':
                logo = logo.convert('RGBA')
            background.paste(logo, mask=logo.split()[-1] if logo.mode == 'RGBA' else None)
            logo = background
        
        # Resize to 1024x1024 (square, maintaining aspect ratio with padding if needed)
        logo_1024 = Image.new('RGB', (1024, 1024), (255, 255, 255))
        logo.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
        
        # Center the logo
        x_offset = (1024 - logo.size[0]) // 2
        y_offset = (1024 - logo.size[1]) // 2
        logo_1024.paste(logo, (x_offset, y_offset))
        
        # Save to AppIcon.appiconset folder
        appicon_dir = Path(output_dir) / "AppIcon.appiconset"
        appicon_dir.mkdir(parents=True, exist_ok=True)
        
        output_path = appicon_dir / "AppIcon.png"
        logo_1024.save(output_path, "PNG")
        
        print(f"✅ Successfully created AppIcon.png at {output_path}")
        print(f"   Size: 1024x1024 pixels")
        print("\nNext steps:")
        print("1. Open Xcode")
        print("2. Clean build folder (Shift+Cmd+K)")
        print("3. Build and run the app")
        print("4. The icon should appear on the simulator home screen!")
        
        return True
        
    except FileNotFoundError:
        print(f"❌ Error: Logo file not found at {logo_path}")
        return False
    except Exception as e:
        print(f"❌ Error processing image: {e}")
        print("\nMake sure you have Pillow installed:")
        print("  pip install Pillow")
        return False

if __name__ == "__main__":
    # Get the project root directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    assets_dir = project_root / "ClearSpend" / "Assets.xcassets"
    
    if len(sys.argv) < 2:
        print("Usage: python setup_app_icon.py <path_to_logo_image>")
        print("\nExample:")
        print("  python setup_app_icon.py ~/Downloads/ClearSpend-logo.png")
        print("\nThe script will:")
        print("  - Convert your logo to 1024x1024 PNG format")
        print("  - Place it in ClearSpend/Assets.xcassets/AppIcon.appiconset/")
        print("  - Remove transparency (iOS requires solid background)")
        sys.exit(1)
    
    logo_path = sys.argv[1]
    setup_app_icon(logo_path, assets_dir)

