# ✅ NeonDB + Render.com Backend Hazır!

## 🎉 Tamamlanan İşlemler

✅ PostgreSQL + Prisma backend oluşturuldu
✅ NeonDB connection string eklendi
✅ Prisma schema hazır (Civilization, Event, Connection)
✅ REST API endpoints hazır
✅ GitHub'a push edildi
✅ Deployment talimatları hazır

## 🚀 Şimdi Ne Yapmalısın?

### 1. Render.com'da Deploy Et

1. [Render.com](https://render.com)'a git
2. GitHub ile giriş yap
3. **New +** > **Web Service**
4. Repository seç: `kiroamsikem-hash/babaminrpojesi`
5. Ayarlar:

```
Name: civilization-timeline-api
Root Directory: civilization_timeline_app/backend
Environment: Node
Build Command: npm install && npx prisma generate && npx prisma db push
Start Command: npm start
Plan: Free
```

6. **Environment Variables** ekle:
   - Key: `DATABASE_URL`
   - Value: `postgresql://neondb_owner:npg_Kbl1pd6nyAMI@ep-curly-sea-anjutse4-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require`

7. **Create Web Service** tıkla

### 2. Deployment Bekle (5-10 dakika)

Logs'ta göreceksin:
```
==> Installing dependencies
==> npm install
==> npx prisma generate
==> npx prisma db push
==> Starting service
🚀 Server running on port 10000
🐘 PostgreSQL (NeonDB) connected
```

### 3. API URL'ini Al

Deployment bitince URL'in:
```
https://civilization-timeline-api-XXXX.onrender.com
```

### 4. Test Et

```bash
# Health check
curl https://YOUR-URL.onrender.com

# Response:
# {"status":"ok","message":"Civilization Timeline API (PostgreSQL + NeonDB)","version":"1.0.0"}
```

## 📱 Flutter App'i Güncelle (Opsiyonel)

Şu an Firebase kullanıyor. REST API'ye geçmek istersen:

### API Service Oluştur

```dart
// lib/core/api/rest_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestApiService {
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
  await restApiService.syncAll({
    'civilizations': localData.civilizations,
    'events': localData.events,
    'connections': localData.connections,
  });
});
```

## 📊 API Endpoints

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

## 💰 Maliyet

✅ **Tamamen Ücretsiz!**

- NeonDB: 512MB PostgreSQL (ücretsiz)
- Render.com: 750 saat/ay (ücretsiz)

## ⚠️ Önemli Notlar

### Cold Start
Render.com ücretsiz plan 15 dakika kullanılmazsa uyur. İlk istek ~30 saniye sürer.

**Çözüm:** Cron job ile her 10 dakikada ping at:
- [cron-job.org](https://cron-job.org) kullan (ücretsiz)
- URL: `https://YOUR-RENDER-URL.onrender.com`

### Gerçek Zamanlı Sync Yok
REST API polling gerektirir. Firebase gibi gerçek zamanlı değil.

## 📁 Dosyalar

```
civilization_timeline_app/
├── backend/
│   ├── server.js              # Express server
│   ├── package.json           # Dependencies
│   ├── prisma/
│   │   └── schema.prisma      # Database schema
│   ├── .env                   # Local config (NeonDB URL)
│   ├── .env.example           # Template
│   ├── .gitignore             # Git ignore
│   └── README.md              # Backend docs
├── RENDER_DEPLOYMENT.md       # Detaylı talimatlar
└── NEONDB_RENDER_HAZIR.md     # Bu dosya
```

## 🔗 Linkler

- **GitHub Repo:** https://github.com/kiroamsikem-hash/babaminrpojesi
- **NeonDB Dashboard:** https://console.neon.tech
- **Render Dashboard:** https://dashboard.render.com

## 📞 Sorun Çözme

### Deployment Hatası
```bash
# Render Dashboard > Service > Logs
# Hata mesajını oku
```

### Database Bağlantı Hatası
```bash
# DATABASE_URL doğru mu kontrol et
# NeonDB dashboard'da connection string'i kopyala
```

### Prisma Hatası
```bash
# Build command'i kontrol et:
npm install && npx prisma generate && npx prisma db push
```

## 🎯 Özet

1. ✅ Backend kodu hazır (PostgreSQL + Prisma)
2. ✅ NeonDB database hazır
3. ✅ GitHub'da (babaminrpojesi)
4. 🔄 Render.com'da deploy et (yukarıdaki adımlar)
5. 📱 Flutter app'i güncelle (opsiyonel)

---

**Detaylı talimatlar:** `RENDER_DEPLOYMENT.md`

**Backend docs:** `backend/README.md`

**GitHub:** https://github.com/kiroamsikem-hash/babaminrpojesi
