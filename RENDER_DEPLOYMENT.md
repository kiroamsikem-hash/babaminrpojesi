# 🚀 Render.com + NeonDB Deployment Guide

## 🎯 Backend: PostgreSQL + NeonDB (Ücretsiz)

✅ NeonDB: PostgreSQL (512MB ücretsiz)
✅ Render.com: Backend hosting (750 saat/ay ücretsiz)
✅ REST API ile senkronizasyon
⚠️ Gerçek zamanlı sync yok, polling gerekir

## � NeonDB Kurulumu (Zaten Hazır!)

✅ NeonDB hesabın var
✅ Database oluşturulmuş
✅ Connection string hazır:

```
postgresql://neondb_owner:npg_Kbl1pd6nyAMI@ep-curly-sea-anjutse4-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### Test Et (Opsiyonel)

```bash
# PostgreSQL client ile bağlan
psql 'postgresql://neondb_owner:npg_Kbl1pd6nyAMI@ep-curly-sea-anjutse4-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Tabloları listele
\dt

# Çık
\q
```

## 🌐 Render.com'da Deploy

### Adım 1: GitHub'a Push (Zaten Hazır!)

✅ Repo: https://github.com/kiroamsikem-hash/babaminrpojesi
✅ Backend klasörü: `civilization_timeline_app/backend/`

### Adım 2: Render.com'a Gir

1. [Render.com](https://render.com)'a git
2. Sign up / Login (GitHub ile giriş yap)

### Adım 3: Web Service Oluştur

1. Dashboard > **New +** > **Web Service**
2. **Connect GitHub repository:** `kiroamsikem-hash/babaminrpojesi`
3. Configure:

```
Name: civilization-timeline-api
Root Directory: civilization_timeline_app/backend
Environment: Node
Build Command: npm install && npx prisma generate && npx prisma db push
Start Command: npm start
Plan: Free
```

### Adım 4: Environment Variables

**Environment Variables** bölümüne ekle:

- **Key:** `DATABASE_URL`
- **Value:** 
```
postgresql://neondb_owner:npg_Kbl1pd6nyAMI@ep-curly-sea-anjutse4-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### Adım 5: Deploy

1. **Create Web Service** butonuna tıkla
2. Deployment başlayacak (5-10 dakika)

### Adım 6: Deployment Logs İzle

Deployment sırasında göreceksin:
```
==> Installing dependencies
==> npm install
==> npx prisma generate
==> npx prisma db push
==> Starting service
🚀 Server running on port 10000
🐘 PostgreSQL (NeonDB) connected
```

### Adım 7: API URL'i Al

Deployment tamamlandıktan sonra URL'in:
```
https://civilization-timeline-api.onrender.com
```

(Render otomatik URL verir, seninkini kopyala)

### Adım 8: Test Et

```bash
# Health check
curl https://civilization-timeline-api.onrender.com

# Response:
# {"status":"ok","message":"Civilization Timeline API (PostgreSQL + NeonDB)","version":"1.0.0"}

# Get civilizations
curl https://civilization-timeline-api.onrender.com/api/civilizations

# Response:
# []
```

## 📱 Flutter App'i Güncelle (Opsiyonel)

Şu an Firebase kullanıyor. REST API'ye geçmek istersen:

### REST API Service Oluştur

```dart
// lib/core/api/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://YOUR-RENDER-URL.onrender.com/api';
  
  Future<List<Map<String, dynamic>>> getCivilizations() async {
    final response = await http.get(Uri.parse('$baseUrl/civilizations'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load');
  }
  
  Future<void> syncAll(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$baseUrl/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }
}
```

### Polling ile Senkronizasyon

```dart
// Her 30 saniyede bir sync
Timer.periodic(Duration(seconds: 30), (timer) async {
  await apiService.syncAll({
    'civilizations': localData.civilizations,
    'events': localData.events,
    'connections': localData.connections,
  });
});
```

## 💰 Maliyet (Tamamen Ücretsiz!)

### NeonDB (Ücretsiz Tier)
- ✅ 512MB PostgreSQL
- ✅ Always-on
- ✅ 3GB veri transferi/ay
- ✅ Sınırsız sorgu

### Render.com (Ücretsiz Tier)
- ✅ 750 saat/ay (31 gün)
- ⚠️ 15 dakika inaktivite sonrası sleep
- ⚠️ Cold start ~30 saniye (ilk istek)
- ✅ Otomatik HTTPS

## ⚠️ Önemli Notlar

### Cold Start Problemi
Render.com ücretsiz plan 15 dakika kullanılmazsa uyur. İlk istek 30 saniye sürebilir.

**Çözüm:** Cron job ile her 10 dakikada ping at:
```bash
# cron-job.org kullan (ücretsiz)
curl https://YOUR-RENDER-URL.onrender.com
```

### Polling Senkronizasyon
Gerçek zamanlı sync yok. Flutter app'te polling yapman gerekir:

```dart
// Her 30 saniyede bir sync
Timer.periodic(Duration(seconds: 30), (timer) {
  syncService.syncAll();
});
```

## 🔄 API Endpoints

Backend hazır, şu endpoint'ler var:

```
GET  /                          # Health check
GET  /api/civilizations         # Tüm medeniyetler
POST /api/civilizations         # Yeni medeniyet
PUT  /api/civilizations/:id     # Güncelle
DELETE /api/civilizations/:id   # Sil

GET  /api/events                # Tüm olaylar
POST /api/events                # Yeni olay
PUT  /api/events/:id            # Güncelle
DELETE /api/events/:id          # Sil

GET  /api/connections           # Tüm bağlantılar
POST /api/connections           # Yeni bağlantı
DELETE /api/connections/:id     # Sil

POST /api/sync                  # Toplu senkronizasyon
```

## � Hızlı Özet

1. ✅ NeonDB hazır (PostgreSQL)
2. ✅ Backend kodu hazır (Node.js + Prisma)
3. ✅ GitHub'da (babaminrpojesi)
4. 🔄 Render.com'da deploy et (yukarıdaki adımlar)
5. 📱 Flutter app'i güncelle (opsiyonel)

## 📞 Sorun Çözme

### Deployment Hatası
```bash
# Render logs'a bak
# Dashboard > Service > Logs
```

### Database Bağlantı Hatası
```bash
# DATABASE_URL doğru mu kontrol et
# NeonDB dashboard'da connection string'i kopyala
```

### Cold Start Çok Yavaş
```bash
# Cron job ekle (her 10 dakikada ping)
# https://cron-job.org
```

## 🎉 Sonuç

Backend tamamen ücretsiz ve hazır! Render.com'da deploy et, telefon ve bilgisayardan kullan.

---

**GitHub Repo:** https://github.com/kiroamsikem-hash/babaminrpojesi

**Backend:** `civilization_timeline_app/backend/`

**NeonDB:** PostgreSQL (512MB ücretsiz)

**Render.com:** Node.js hosting (750 saat/ay)
