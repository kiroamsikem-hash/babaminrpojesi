# 🚀 RENDER.COM DEPLOYMENT - ADIM ADIM

## 📋 ÖNCESİ HAZIRLIK

✅ Backend GitHub'da: `https://github.com/kiroamsikem-hash/babaminrpojesi`
✅ Backend klasörü: `backend/`
✅ NeonDB PostgreSQL hazır olmalı

---

## 1️⃣ NEONDB POSTGRESQL OLUŞTUR

### NeonDB'ye Git
🔗 https://neon.tech

1. **Sign Up / Login** yap
2. **Create Project** tıkla
3. **Project Name**: `civilization-timeline`
4. **Region**: Yakın bir bölge seç (örn: Frankfurt)
5. **Create Project** tıkla

### Connection String'i Kopyala
```
postgresql://[user]:[password]@[host]/[database]?sslmode=require
```

**Örnek:**
```
postgresql://neondb_owner:abc123xyz@ep-cool-name-123456.eu-central-1.aws.neon.tech/neondb?sslmode=require
```

⚠️ **ÖNEMLİ**: Bu connection string'i kaydet, Render'da kullanacağız!

---

## 2️⃣ RENDER.COM'DA WEB SERVICE OLUŞTUR

### Render'a Git
🔗 https://render.com

1. **Sign Up / Login** yap (GitHub ile giriş yapabilirsin)
2. **Dashboard** → **New +** → **Web Service**

### Repository Bağla
1. **Connect GitHub** tıkla
2. Repository seç: `kiroamsikem-hash/babaminrpojesi`
3. **Connect** tıkla

### Service Ayarları

| Alan | Değer |
|------|-------|
| **Name** | `babaminrpojesi` (veya istediğin isim) |
| **Region** | Frankfurt (veya yakın bölge) |
| **Branch** | `main` |
| **Root Directory** | `backend` ⚠️ ÖNEMLİ! |
| **Runtime** | `Node` |
| **Build Command** | `npm install && npx prisma generate && npx prisma db push` |
| **Start Command** | `npm start` |
| **Instance Type** | `Free` (başlangıç için) |

### Environment Variables Ekle

**Add Environment Variable** butonuna tıkla ve şunları ekle:

```bash
DATABASE_URL=postgresql://[NEONDB_CONNECTION_STRING]
NODE_ENV=production
PORT=10000
```

**Örnek:**
```bash
DATABASE_URL=postgresql://neondb_owner:abc123xyz@ep-cool-name-123456.eu-central-1.aws.neon.tech/neondb?sslmode=require
NODE_ENV=production
PORT=10000
```

### Deploy Et!
1. **Create Web Service** tıkla
2. Deploy başlayacak (2-3 dakika sürer)
3. Logları izle

---

## 3️⃣ DEPLOY SONRASI KONTROL

### API URL'ini Al
Deploy tamamlandıktan sonra URL'in şöyle olacak:
```
https://babaminrpojesi.onrender.com
```

### Test Et
Browser'da aç:
```
https://babaminrpojesi.onrender.com
```

Şunu görmelisin:
```json
{
  "status": "ok",
  "message": "Civilization Timeline API (PostgreSQL + NeonDB)",
  "version": "1.0.0"
}
```

### API Endpoint'leri Test Et

**Civilizations:**
```
GET https://babaminrpojesi.onrender.com/api/civilizations
```

**Events:**
```
GET https://babaminrpojesi.onrender.com/api/events
```

**Connections:**
```
GET https://babaminrpojesi.onrender.com/api/connections
```

---

## 4️⃣ FLUTTER APP'E BACKEND URL EKLE

Backend hazır olunca Flutter app'e URL'i ekleyeceğiz:

**Dosya**: `lib/core/api/api_service.dart` (oluşturacağız)

```dart
class ApiService {
  static const String baseUrl = 'https://babaminrpojesi.onrender.com/api';
  
  // API methods...
}
```

---

## 🔧 SORUN GİDERME

### Build Hatası: "Prisma generate failed"
**Çözüm**: Build command'i kontrol et:
```bash
npm install && npx prisma generate && npx prisma db push
```

### Database Connection Error
**Çözüm**: 
1. NeonDB connection string'i doğru mu kontrol et
2. `?sslmode=require` parametresi var mı kontrol et
3. NeonDB'de database aktif mi kontrol et

### "Root Directory not found"
**Çözüm**: Root Directory'yi `backend` olarak ayarla

### Free Tier Sleep Mode
⚠️ **Önemli**: Render free tier 15 dakika inaktivite sonrası uyur.
- İlk istek 30-60 saniye sürebilir (cold start)
- Paid plan'de bu sorun yok

---

## 📊 RENDER DASHBOARD

### Logları İzle
Dashboard → Service → **Logs** sekmesi

### Restart Service
Dashboard → Service → **Manual Deploy** → **Deploy latest commit**

### Environment Variables Güncelle
Dashboard → Service → **Environment** sekmesi

---

## ✅ BAŞARILI DEPLOY ÇIKTISI

```
==> Cloning from https://github.com/kiroamsikem-hash/babaminrpojesi
==> Checking out commit in branch main
==> Running build command 'npm install && npx prisma generate && npx prisma db push'
==> Uploading build...
==> Build successful 🎉
==> Deploying...
==> Running 'npm start'
🚀 Server running on port 10000
📡 API: http://localhost:10000/api
🐘 PostgreSQL (NeonDB) connected
==> Your service is live 🎉
==> https://babaminrpojesi.onrender.com
```

---

## 🎯 SONRAKI ADIMLAR

1. ✅ Backend Render'da çalışıyor
2. ⏭️ Flutter app'e API entegrasyonu ekle
3. ⏭️ Sync service'i backend'e bağla
4. ⏭️ Test et!

---

## 💰 MALIYET

**NeonDB Free Tier:**
- 0.5 GB storage
- 1 project
- Ücretsiz!

**Render Free Tier:**
- 750 saat/ay
- 512 MB RAM
- Ücretsiz!

**Toplam**: 0₺ 🎉

---

## 📞 DESTEK

Sorun olursa:
1. Render logs'u kontrol et
2. NeonDB dashboard'u kontrol et
3. GitHub repo'yu kontrol et
