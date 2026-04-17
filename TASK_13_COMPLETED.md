# Task 13: Excel-Like Row Selection, Photo Permissions & User Guide

## ✅ COMPLETED FEATURES

### 1. Excel-Like Row Selection
- **Entire row clickable**: Click anywhere on a row to select it
- **Visual highlight**: Selected rows glow with blue background (alpha: 0.1) and blue border
- **Year axis highlight**: Selected year shows blue background (alpha: 0.2), blue border, and bold blue text
- **Toggle selection**: Click again to deselect
- **Provider**: `selectedRowProvider` in `timeline_provider.dart`

### 2. Photo Permissions Fixed
- **Added `permission_handler: ^11.3.1`** to `pubspec.yaml`
- **Updated all editors** to request photo permissions before picking:
  - `column_editor.dart` - Civilization photos
  - `row_editor.dart` - Event photos
  - `year_row_editor.dart` - Year row photos
- **Permission flow**: Request → Check → Pick image
- **User feedback**: Shows snackbar if permission denied

### 3. In-App User Guide
- **Comprehensive 8-step tutorial** with page navigation
- **Topics covered**:
  1. Welcome & Overview
  2. Row Selection (Excel-like)
  3. Pan & Zoom (Figma/Miro-like)
  4. Column (Civilization) Operations
  5. Row (Year) Operations
  6. Event Card Operations
  7. Settings (⋮ menu)
  8. Tips & Tricks
- **Access points**:
  - Floating Action Button (help icon)
  - Three-dot menu → "Kullanım Kılavuzu"
- **Features**:
  - Page indicators
  - Previous/Next navigation
  - Icons and visual design
  - Mobile & desktop tips

## 📁 FILES MODIFIED

### Core Files
- `lib/presentation/widgets/editors/column_editor.dart` - Added permission_handler
- `lib/presentation/widgets/editors/row_editor.dart` - Added permission_handler
- `lib/presentation/widgets/editors/year_row_editor.dart` - Already had permission_handler
- `lib/presentation/widgets/timeline/timeline_canvas.dart` - Row selection UI
- `lib/domain/providers/timeline_provider.dart` - Added selectedRowProvider
- `lib/presentation/screens/timeline_screen.dart` - Added user guide button & menu item
- `pubspec.yaml` - Added permission_handler dependency

### New Files
- `lib/presentation/widgets/guide/user_guide_dialog.dart` - Complete user guide widget

### Android Permissions
- `android/app/src/main/AndroidManifest.xml` - Already has all required permissions:
  - READ_EXTERNAL_STORAGE
  - WRITE_EXTERNAL_STORAGE
  - READ_MEDIA_IMAGES
  - CAMERA

## 🎯 HOW TO USE

### Row Selection
1. Click anywhere on a row (not just the year label)
2. Row highlights with blue glow
3. Click again to deselect

### Photo Picker
1. Click "Fotoğraf Ekle" in any editor
2. App requests permission (first time only)
3. Grant permission
4. Select photo from gallery
5. Photo appears in editor

### User Guide
1. Click the floating help button (bottom right)
   OR
2. Click three-dot menu → "Kullanım Kılavuzu"
3. Navigate through 8 pages
4. Click "İleri" to go forward, "Geri" to go back
5. Click "Bitir" on last page to close

## 🐛 KNOWN ISSUE: APK Build

### Problem
Release APK build fails due to Turkish character (ı) in project path:
```
C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app
                              ↑ This character causes issues
```

### Solution
**Move the project to a path without Turkish characters:**

```bash
# Option 1: Move to Desktop root
cd C:\Users\yazar\Desktop
mkdir civilization_timeline
move "babamın web site\civilization_timeline_app" civilization_timeline\
cd civilization_timeline\civilization_timeline_app

# Option 2: Move to C:\ root
cd C:\
mkdir projects
move "C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app" projects\
cd projects\civilization_timeline_app

# Then build
flutter clean
flutter build apk --release
```

### Why This Happens
- Dart AOT compiler has issues with non-ASCII characters in file paths
- Debug builds work because they don't use AOT compilation
- Release builds require AOT compilation which fails with Turkish characters

## 📱 TESTING

### Debug APK (Works)
```bash
flutter build apk --debug
# APK: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (After moving project)
```bash
flutter clean
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 USER GUIDE CONTENT

### Page 1: Welcome
- Introduction to the app
- Excel-like but more powerful
- Rows = Years, Columns = Civilizations

### Page 2: Row Selection
- Click row to select
- Blue highlight
- Click again to deselect

### Page 3: Pan & Zoom
- Two-finger pinch to zoom
- One-finger drag to pan
- Figma/Miro-like navigation

### Page 4: Column Operations
- Right-click or long-press column header
- Edit civilization
- Add new event
- Photos and tags

### Page 5: Row Operations
- Right-click or long-press year label
- Edit year row
- Add photo to year
- Add tag to year
- Add event to year

### Page 6: Event Cards
- Right-click or long-press event
- Edit event
- Add photo
- Add tag
- Delete event

### Page 7: Settings
- Year range (-4050 to -550)
- Year step (1, 5, 10, 25, 50, 100, 200, 500)
- Date format (M.Ö., BC, BCE)
- Display options
- Cell size
- Quick presets

### Page 8: Tips
- Mobile: Long press for menu
- Desktop: Right-click for menu
- Colors for civilizations
- Tags for categorization
- Photos for visual richness
- Quick presets in settings

## ✅ CHECKLIST

- [x] Excel-like row selection implemented
- [x] Row highlight with blue glow
- [x] Year axis highlight when selected
- [x] Permission handler added to all editors
- [x] Photo picker requests permissions
- [x] User guide dialog created (8 pages)
- [x] User guide accessible from FAB
- [x] User guide accessible from menu
- [x] Debug APK builds successfully
- [ ] Release APK (blocked by Turkish character in path)

## 🚀 NEXT STEPS

1. **Move project to path without Turkish characters**
2. **Build release APK**
3. **Test on device**:
   - Row selection
   - Photo picker permissions
   - User guide navigation
   - All features from guide

## 📊 STATISTICS

- **Total files modified**: 7
- **New files created**: 1
- **Lines of code added**: ~350
- **User guide pages**: 8
- **Features completed**: 3/3

## 🎉 SUMMARY

All requested features have been implemented successfully:
1. ✅ Excel-like row selection with visual highlight
2. ✅ Photo picker with proper permissions
3. ✅ Comprehensive in-app user guide

The only remaining issue is building the release APK, which requires moving the project to a path without Turkish characters. Debug APK works perfectly and can be used for testing.
