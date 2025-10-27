# App Icon Instructions

## Overview

The Canastracker app needs custom launcher icons featuring playing cards. This file explains how to create and install them.

## Icon Requirements

### Design Concept
- **Theme**: Playing cards (Canastra/Canasta game)
- **Style**: Clean, recognizable at small sizes
- **Suggested elements**:
  - 2-3 playing cards fanned out
  - Card suits (hearts, diamonds, clubs, spades)
  - Brazilian/colorful style
  - Green background (#2E7D32) to represent card table

### Technical Specifications

You need to create **2 image files**:

1. **app_icon.png** (Regular icon)
   - Size: 1024x1024 pixels
   - Format: PNG with transparency
   - Used for: Older Android devices and legacy icons

2. **app_icon_foreground.png** (Adaptive icon foreground)
   - Size: 1024x1024 pixels
   - Format: PNG with transparency
   - Important: Center your design in a 672x672px safe zone (leave 176px margin on all sides)
   - Background: Transparent (the green #2E7D32 background is set in configuration)

## How to Create the Icons

### Option 1: Use AI Image Generators (Recommended)
Use tools like:
- **DALL-E** (ChatGPT Plus): "Create an app icon featuring 3 playing cards fanned out, showing an Ace of hearts, King of spades, and Queen of diamonds. Clean, modern design suitable for a mobile app icon. Transparent background."
- **Midjourney**: Similar prompt with `--ar 1:1`
- **Canva**: Use their icon template with playing card graphics

### Option 2: Use Design Tools
- **Figma**: Free online tool with card graphics available
- **Inkscape**: Free vector graphics editor
- **Adobe Illustrator**: Professional vector tool
- Find free playing card SVGs at sites like flaticon.com or icons8.com

### Option 3: Commission a Designer
- **Fiverr**: $5-20 for simple icon design
- **Upwork**: Professional designers available
- Provide this document as reference

## Installation Steps

Once you have your icon files:

1. Place both PNG files in this directory (`assets/icon/`):
   ```
   assets/icon/
   ├── app_icon.png (1024x1024)
   └── app_icon_foreground.png (1024x1024)
   ```

2. Install the flutter_launcher_icons package:
   ```bash
   flutter pub get
   ```

3. Generate the launcher icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. Rebuild your app:
   ```bash
   flutter clean
   flutter build apk --release
   ```

5. The icons will be automatically generated in all required sizes and placed in:
   ```
   android/app/src/main/res/mipmap-*/
   ```

## Configuration

The icon configuration is already set up in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#2E7D32"  # Green card table color
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

## Tips for Good Icon Design

1. **Keep it simple**: Icons are viewed at very small sizes (48x48dp on devices)
2. **High contrast**: Ensure elements stand out against the green background
3. **Recognizable**: Should be identifiable as a card game app at a glance
4. **Test it**: View the icon at different sizes before finalizing
5. **Avoid text**: Don't include the app name - it appears below the icon

## Example Search Queries

If searching for inspiration or stock images:
- "playing cards icon app"
- "canasta game logo"
- "card game app icon"
- "playing cards mobile icon"
- "casino cards icon design"

## Need Help?

If you need assistance:
1. The green background color (#2E7D32) represents a card table
2. Focus on 2-3 cards maximum to avoid clutter
3. Use bold, simple shapes that scale well
4. Consider adding subtle shadows for depth

## Current Status

⚠️ **ICONS NOT YET CREATED**

The placeholder files need to be replaced with actual icon artwork. Once created, follow the installation steps above.
