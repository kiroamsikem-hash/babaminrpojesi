# 🔄 Backend & Senkronizasyon Planı

## 🎯 Hedef

Telefon ve Windows bilgisayarda eş zamanlı çalışan, gerçek zamanlı senkronize uygulama.

## 🏗️ Mimari Seçenekleri

### Seçenek 1: Firebase (ÖNERİLEN) ⭐

**Avantajlar:**
- ✅ Gerçek zamanlı senkronizasyon
- ✅ Offline support (yerel cache)
- ✅ Authentication (kullanıcı girişi)
- ✅ Cloud Storage (fotoğraflar için)
- ✅ Ücretsiz tier (günde 50K okuma, 20K yazma)
- ✅ Kolay kurulum

**Teknolojiler:**
- Firebase Firestore (database)
- Firebase Storage (media files)
- Firebase Auth (kullanıcı yönetimi)
- Firebase Cloud Functions (backend logic)

### Seçenek 2: Kendi Backend'i

**Teknolojiler:**
- Node.js + Express
- PostgreSQL / MongoDB
- Socket.io (real-time)
- AWS S3 / MinIO (storage)

**Dezavantajlar:**
- ❌ Sunucu gerekli
- ❌ Daha karmaşık
- ❌ Bakım gerektirir

## 📋 Firebase Entegrasyonu (Önerilen)

### Adım 1: Firebase Paketleri

```yaml
dependencies:
  # Firebase Core
  firebase_core: ^3.8.1
  
  # Firestore (Database)
  cloud_firestore: ^5.6.1
  
  # Storage (Media)
  firebase_storage: ^12.4.1
  
  # Auth (Kullanıcı)
  firebase_auth: ^5.4.1
  
  # Offline Support
  connectivity_plus: ^6.1.2
```

### Adım 2: Veri Modeli Değişiklikleri

**Mevcut:** Isar (Local)
**Yeni:** Firestore (Cloud) + Isar (Cache)

**Hybrid Yaklaşım:**
- Firestore: Ana database (cloud)
- Isar: Offline cache (local)
- Senkronizasyon: İki yönlü

### Adım 3: Senkronizasyon Stratejisi

```dart
// 1. Veri okuma: Önce cache, sonra cloud
Stream<List<Event>> getEvents() {
  // Local cache'den hemen göster
  final localEvents = isarService.getEvents();
  
  // Cloud'dan güncelle
  firestore.collection('events').snapshots().listen((snapshot) {
    // Firestore -> Isar sync
    syncToLocal(snapshot.docs);
  });
  
  return localEvents;
}

// 2. Veri yazma: Önce local, sonra cloud
Future<void> saveEvent(Event event) async {
  // Önce local'e kaydet (hızlı)
  await isarService.saveEvent(event);
  
  // Sonra cloud'a gönder (arka planda)
  await firestore.collection('events').doc(event.id).set(event.toJson());
}
```

### Adım 4: Çakışma Çözümü

**Last-Write-Wins:**
- En son güncelleme kazanır
- Timestamp bazlı

**Conflict Resolution:**
```dart
if (cloudTimestamp > localTimestamp) {
  // Cloud verisi daha yeni
  updateLocal(cloudData);
} else if (localTimestamp > cloudTimestamp) {
  // Local veri daha yeni
  updateCloud(localData);
}
```

## 🔐 Kullanıcı Yönetimi

### Anonim Giriş (Basit)

```dart
// Kullanıcı ID otomatik oluştur
final user = await FirebaseAuth.instance.signInAnonymously();
```

### Email/Password (Gelişmiş)

```dart
// Kayıt
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Giriş
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

## 📁 Dosya Yapısı Değişiklikleri

```
lib/
├── core/
│   ├── database/
│   │   ├── isar_service.dart          # Local cache
│   │   ├── firestore_service.dart     # Cloud database (YENİ)
│   │   └── sync_service.dart          # Senkronizasyon (YENİ)
│   └── storage/
│       ├── local_storage.dart         # Local media
│       └── cloud_storage.dart         # Firebase Storage (YENİ)
│
├── data/
│   ├── models/
│   │   └── *.dart                     # Firestore serialization ekle
│   └── repositories/
│       ├── *_repository.dart          # Hybrid repo (local + cloud)
│       └── sync_repository.dart       # Sync logic (YENİ)
│
└── domain/
    └── providers/
        ├── auth_provider.dart         # Firebase Auth (YENİ)
        └── sync_provider.dart         # Sync state (YENİ)
```

## 🚀 Implementasyon Adımları

### Faz 1: Firebase Setup
1. Firebase projesi oluştur
2. Android/iOS/Web config ekle
3. Paketleri yükle
4. Initialize Firebase

### Faz 2: Firestore Entegrasyonu
1. Firestore service oluştur
2. Model'lere toJson/fromJson ekle
3. Repository'leri güncelle
4. Stream-based reactive updates

### Faz 3: Storage Entegrasyonu
1. Firebase Storage setup
2. Media upload/download
3. Thumbnail generation
4. Cache management

### Faz 4: Senkronizasyon
1. Sync service oluştur
2. Conflict resolution
3. Offline queue
4. Background sync

### Faz 5: Auth & Security
1. Firebase Auth setup
2. Firestore security rules
3. User-based data isolation
4. Multi-device support

## 💰 Maliyet Tahmini (Firebase)

### Ücretsiz Tier (Spark Plan)
- ✅ 50K okuma/gün
- ✅ 20K yazma/gün
- ✅ 1GB storage
- ✅ 10GB transfer/ay

**Yeterli mi?**
- Tek kullanıcı: ✅ Fazlasıyla yeterli
- 2-3 cihaz: ✅ Sorunsuz
- 10+ kullanıcı: ⚠️ Ücretli plana geçiş gerekebilir

### Ücretli Plan (Blaze - Pay as you go)
- $0.06 / 100K okuma
- $0.18 / 100K yazma
- $0.026 / GB storage

## 🔄 Alternatif: Supabase

Firebase'e alternatif, açık kaynak:

**Avantajlar:**
- ✅ PostgreSQL (SQL)
- ✅ Real-time subscriptions
- ✅ Storage
- ✅ Auth
- ✅ Ücretsiz tier: 500MB database, 1GB storage

**Paketler:**
```yaml
dependencies:
  supabase_flutter: ^2.9.1
```

## 📊 Karşılaştırma

| Özellik | Firebase | Supabase | Kendi Backend |
|---------|----------|----------|---------------|
| Kurulum | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Real-time | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Offline | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Maliyet | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Esneklik | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🎯 Önerim

**Firebase ile başla:**
1. Hızlı kurulum
2. Güvenilir
3. Ücretsiz tier yeterli
4. Offline support mükemmel
5. Dokümantasyon bol

**Gerekirse Supabase'e geç:**
- SQL gerekirse
- Daha fazla kontrol istersen
- Maliyet önemliyse

## 🚀 Hemen Başlayalım mı?

Hangi yöntemi tercih ediyorsun?

1. **Firebase** (Önerilen - Hızlı & Kolay)
2. **Supabase** (SQL & Açık Kaynak)
3. **Kendi Backend** (Tam Kontrol)

Seçimini yap, hemen implementasyona başlayalım! 🔥
