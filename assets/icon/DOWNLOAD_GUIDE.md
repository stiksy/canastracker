# Quick Icon Download Guide

## Step-by-Step Instructions to Get Your App Icon

### Recommended: Flaticon (Easiest Option)

**Option 1: Simple Playing Cards Icon** ⭐ Recommended

1. **Go to this URL:**
   ```
   https://www.flaticon.com/free-icon/playing-cards_261787
   ```

2. **Click "Download" button** (green button on the right)

3. **Select format:** Choose PNG

4. **Select size:** Choose 1024px (or 512px if 1024 isn't available)

5. **Download the file**

6. **Rename and place files:**
   - Save the downloaded file as `app_icon.png` in this directory (`assets/icon/`)
   - Make a copy and name it `app_icon_foreground.png` in the same directory

### Alternative: Browse Icon Collections

If you want to choose a different style:

**Best Collections:**
- **52 Playing Cards Pack:** https://www.flaticon.com/packs/playing-poker-cards-2
- **53 Cards Pack:** https://www.flaticon.com/packs/playing-cards-11
- **All Playing Cards:** https://www.flaticon.com/free-icons/playing-cards

Pick any icon you like, download as PNG at 1024px, and follow step 6 above.

### After Downloading

Once you have both files in `assets/icon/`:

```bash
# Run this from the project root
flutter pub run flutter_launcher_icons

# Then rebuild
flutter clean
flutter build apk --release
```

### License Note

Flaticon requires attribution for free use. You can:
- Add attribution in your app's about/credits section
- Purchase a premium license to remove attribution requirement (~$10/month)

For a personal project, attribution is fine. For commercial app, consider the premium license.

### Need Help?

If you have trouble downloading:
1. Make sure you're signed up for a free Flaticon account
2. Some icons may require you to "collect" them first before downloading
3. You can always use different icon sites like Icons8 or Freepik

---

**Quick Summary:**
1. Visit: https://www.flaticon.com/free-icon/playing-cards_261787
2. Download as PNG 1024px
3. Save as `app_icon.png` and `app_icon_foreground.png` in `assets/icon/`
4. Run: `flutter pub run flutter_launcher_icons`
5. Done! ✅
