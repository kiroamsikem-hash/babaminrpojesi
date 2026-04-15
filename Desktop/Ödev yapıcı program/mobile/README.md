# 📱 Ödev Asistanı - Flutter Mobile App

AI destekli eğitim asistanı mobil uygulaması.

## 🎯 Özellikler

- ✅ Kamera ile soru tarama (OCR)
- ✅ AI destekli adım adım çözüm
- ✅ Matematik problemleri çözme
- ✅ Kompozisyon ve essay yazma
- ✅ Çeviri desteği
- ✅ Soru geçmişi
- ✅ Google & Apple ile giriş
- ✅ Modern ve kullanıcı dostu arayüz

## 📋 Gereksinimler

- Flutter 3.0+
- Dart 3.0+
- Android Studio / Xcode
- Backend API çalışır durumda olmalı

## 🛠️ Kurulum

### 1. Flutter'ı Yükleyin

[Flutter Kurulum Rehberi](https://docs.flutter.dev/get-started/install)

### 2. Bağımlılıkları Yükleyin

```bash
cd mobile
flutter pub get
```

### 3. Backend URL'ini Ayarlayın

`lib/config/constants.dart` dosyasını açın ve backend URL'inizi güncelleyin:

```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

**Not:** Android emülatörde `localhost` yerine `10.0.2.2` kullanın:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

### 4. Uygulamayı Çalıştırın

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (test için)
flutter run -d chrome
```

## 📱 Platform Özellikleri

### Android

`android/app/src/main/AndroidManifest.xml` dosyasına kamera izni ekleyin:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

`ios/Runner/Info.plist` dosyasına kamera izni ekleyin:

```xml
<key>NSCameraUsageDescription</key>
<string>Soru fotoğrafı çekmek için kamera erişimi gerekli</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Galeri erişimi gerekli</string>
```

## 🎨 Tasarım Sistemi

### Renkler

- Primary: `#4A90E2` (Mavi)
- Secondary: `#50C878` (Yeşil)
- Background: `#F8F9FA` (Açık Gri)
- Surface: `#FFFFFF` (Beyaz)

### Font

- Inter (Google Fonts)

## 📦 Kullanılan Paketler

- `provider` - State management
- `http` / `dio` - API istekleri
- `camera` - Kamera erişimi
- `image_picker` - Galeri erişimi
- `google_ml_kit` - OCR
- `google_fonts` - Font yönetimi
- `shared_preferences` - Local storage
- `timeago` - Zaman formatı

## 🏗️ Proje Yapısı

```
lib/
├── config/              # Konfigürasyon (theme, constants)
├── models/              # Data modelleri
├── providers/           # State management (Provider)
├── screens/             # Ekranlar
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth_screen.dart
│   ├── dashboard_screen.dart
│   ├── chat_screen.dart
│   ├── camera_screen.dart
│   └── profile_screen.dart
├── services/            # API servisleri
├── widgets/             # Reusable widget'lar
└── main.dart            # Ana dosya
```

## 🚀 Build

### Android APK

```bash
flutter build apk --release
```

APK dosyası: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
flutter build ios --release
```

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

## 🧪 Test

```bash
flutter test
```

## 📝 Notlar

- İlk çalıştırmada backend bağlantısını kontrol edin
- OCR için Google ML Kit kullanılıyor (offline çalışır)
- Kamera izinleri gereklidir
- Minimum Android 21 (Lollipop)
- Minimum iOS 12

## 🐛 Sorun Giderme

### "Unable to connect to backend"

- Backend sunucusunun çalıştığından emin olun
- `constants.dart` dosyasındaki URL'i kontrol edin
- Android emülatörde `10.0.2.2` kullanın

### Kamera açılmıyor

- İzinlerin verildiğinden emin olun
- Manifest/Info.plist dosyalarını kontrol edin

### OCR çalışmıyor

- Google ML Kit modellerinin indirildiğinden emin olun
- İnternet bağlantısını kontrol edin (ilk kullanımda)

## 📄 Lisans

MIT
