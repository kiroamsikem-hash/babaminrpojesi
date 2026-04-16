# 🔥 Firebase Kurulum Talimatları

## 📋 Gereksinimler

- Firebase hesabı (ücretsiz)
- Node.js (Firebase CLI için)
- Flutter CLI

## 🚀 Adım Adım Kurulum

### 1. Firebase Projesi Oluştur

1. [Firebase Console](https://console.firebase.google.com/) 'a git
2. "Add project" / "Proje ekle" butonuna tıkla
3. Proje adı: `civilization-timeline` (veya istediğin isim)
4. Google Analytics: İsteğe bağlı (kapatabilirsin)
5. "Create project" / "Proje oluştur"

### 2. Firebase CLI Kur

```bash
# Node.js ile Firebase CLI kur
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# Flutter için Firebase CLI kur
dart pub global activate flutterfire_cli
```

### 3. Flutter Projesine Firebase Ekle

```bash
# Proje klasörüne git
cd civilization_timeline_app

# FlutterFire yapılandır
flutterfire configure

# Projeyi seç: civilization-timeline
# Platformları seç: Android, iOS, Web, Windows
```

Bu komut otomatik olarak şunları oluşturacak:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `web/index.html` (Firebase config)
- `windows/runner/firebase_options.dart`

### 4. Firestore Database Oluştur

1. Firebase Console'da projenize gidin
2. Sol menüden "Firestore Database" seçin
3. "Create database" butonuna tıklayın
4. **Test mode** seçin (geliştirme için)
5. Location: `eur3 (europe-west)` (veya size yakın)
6. "Enable" butonuna tıklayın

### 5. Firebase Storage Oluştur

1. Sol menüden "Storage" seçin
2. "Get started" butonuna tıklayın
3. **Test mode** seçin
4. Location: Firestore ile aynı
5. "Done" butonuna tıklayın

### 6. Firebase Authentication Aktifleştir

1. Sol menüden "Authentication" seçin
2. "Get started" butonuna tıklayın
3. "Sign-in method" sekmesine gidin
4. "Anonymous" seçeneğini aktifleştirin
5. "Save" butonuna tıklayın

### 7. Firestore Security Rules (Önemli!)

Firestore Database > Rules sekmesine gidin ve şu kuralları ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı kendi verilerine erişebilir
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anonim kullanıcılar kendi verilerine erişebilir
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 8. Storage Security Rules

Storage > Rules sekmesine gidin ve şu kuralları ekleyin:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 9. Paketleri Yükle

```bash
cd civilization_timeline_app
flutter pub get
```

### 10. Test Et

```bash
# Android
flutter run -d <android-device>

# Windows
flutter run -d windows

# Web
flutter run -d chrome
```

## 📱 Platform Spesifik Ayarlar

### Android

`android/app/build.gradle.kts` dosyasında minimum SDK kontrol et:

```kotlin
defaultConfig {
    minSdk = 21  // Firebase için minimum
    targetSdk = 36
}
```

### iOS

`ios/Podfile` dosyasında platform versiyonunu kontrol et:

```ruby
platform :ios, '13.0'  # Firebase için minimum
```

### Web

`web/index.html` dosyasında Firebase config otomatik eklendi.

### Windows

Windows için ek ayar gerekmez, `flutterfire configure` her şeyi halletti.

## 🔧 Sorun Giderme

### "Firebase not initialized" Hatası

`main.dart` dosyasında Firebase initialize edildiğinden emin ol:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### "Permission denied" Hatası

- Firestore ve Storage security rules'ları kontrol et
- Authentication aktif mi kontrol et
- Kullanıcı giriş yapmış mı kontrol et

### "Network error" Hatası

- İnternet bağlantısını kontrol et
- Firebase projesi aktif mi kontrol et
- API key'ler doğru mu kontrol et

## 📊 Firebase Console'da Veri Görüntüleme

1. Firebase Console > Firestore Database
2. `users/{userId}/events` koleksiyonunu aç
3. Gerçek zamanlı veri değişikliklerini gör

## 💰 Maliyet Kontrolü

Firebase Console > Usage sekmesinde kullanımı takip et:

- **Okuma**: Günlük 50K ücretsiz
- **Yazma**: Günlük 20K ücretsiz
- **Storage**: 1GB ücretsiz
- **Transfer**: 10GB/ay ücretsiz

## 🎯 Sonraki Adımlar

1. ✅ Firebase kurulumu tamamlandı
2. ✅ Firestore ve Storage aktif
3. ✅ Security rules ayarlandı
4. ✅ Authentication aktif
5. 🔄 Uygulamayı test et
6. 🔄 Telefon ve bilgisayarda eş zamanlı çalıştır

## 📞 Destek

Sorun yaşarsan:
1. Firebase Console > Project Settings > Service accounts
2. "Generate new private key" ile debug bilgisi al
3. Firebase dokümantasyonuna bak: https://firebase.google.com/docs

---

**Kurulum tamamlandıktan sonra uygulama otomatik olarak senkronize olacak!** 🎉
