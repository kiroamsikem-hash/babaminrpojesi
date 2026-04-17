# 📱 APK Build Talimatları

## ⚠️ Kritik Sorun: Proje Yolu

Projeniz şu anda Türkçe karakter içeren bir yolda:
```
C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app
```

**Sorun:** Dart AOT compiler, yoldaki "ı" karakterini okuyamıyor ve bu yüzden APK build başarısız oluyor.

## ✅ Çözüm

Projeyi Türkçe karakter içermeyen bir yola taşıyın:

### Yöntem 1: Manuel Kopyalama

```powershell
# Yeni klasör oluştur
mkdir C:\Projects

# Projeyi kopyala
xcopy "C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app" "C:\Projects\civilization_timeline_app" /E /I /H

# Yeni klasöre git
cd C:\Projects\civilization_timeline_app

# APK build et
flutter build apk --release
```

### Yöntem 2: Otomatik Script

PowerShell'de çalıştır:

```powershell
# Hedef klasör
$target = "C:\FlutterProjects\civilization_app"

# Kopyala
Copy-Item -Path "C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app" -Destination $target -Recurse -Force

# Git
cd $target

# Clean
flutter clean

# Pub get
flutter pub get

# Build APK
flutter build apk --release --split-per-abi
```

## 📦 APK Dosyası Konumu

Build başarılı olduğunda APK dosyaları şurada olacak:

```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk  (32-bit ARM)
├── app-arm64-v8a-release.apk    (64-bit ARM) ← Çoğu modern telefon
└── app-x86_64-release.apk       (64-bit x86)
```

**Telefonunuza yüklemek için:** `app-arm64-v8a-release.apk` dosyasını kullanın.

## 🚀 Hızlı Çözüm

Terminal'de çalıştır:

```bash
# 1. Yeni klasöre kopyala
robocopy "C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app" "C:\Projects\civ_app" /E /XD .dart_tool build

# 2. Yeni klasöre git
cd C:\Projects\civ_app

# 3. Clean ve build
flutter clean
flutter pub get
flutter build apk --release

# 4. APK dosyasını bul
explorer build\app\outputs\flutter-apk
```

## 📱 Telefona Yükleme

### USB ile:

```bash
# Telefonu USB ile bağla
# USB debugging açık olmalı

# APK'yı yükle
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Manuel:

1. APK dosyasını telefona kopyala (USB, Bluetooth, veya cloud)
2. Telefonda dosya yöneticisi ile APK'yı aç
3. "Bilinmeyen kaynaklardan yükleme" iznini ver
4. Yükle

## 🔧 Alternatif: Debug APK

Eğer release build sorun yaşıyorsa, debug APK dene:

```bash
flutter build apk --debug
```

Debug APK daha büyük olacak ama daha kolay build olur.

## 📊 Beklenen APK Boyutları

- Debug APK: ~50-80 MB
- Release APK (split): ~20-30 MB (her ABI için)
- Release APK (fat): ~60-80 MB (tüm ABI'ler)

## ⚡ Hızlı Test

Önce debug modda telefonda test et:

```bash
# Telefonu bağla
flutter devices

# Direkt çalıştır
flutter run --release -d <device-id>
```

Bu şekilde APK dosyası oluşturmadan direkt telefonda test edebilirsin.
