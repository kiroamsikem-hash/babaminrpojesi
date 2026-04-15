# 🚀 Ödev Asistanı - Render.com Kurulum Rehberi

## 📋 Gereksinimler
- GitHub hesabı
- Render.com hesabı (ücretsiz)

---

## 1️⃣ GitHub'a Backend Yükle

### Adım 1: GitHub'da Repository Oluştur
1. https://github.com adresine git
2. Sağ üstte **"+"** > **"New repository"** tıkla
3. Repository adı: **`odev-asistani-backend`**
4. **Public** seç
5. **"Create repository"** tıkla

### Adım 2: Backend'i GitHub'a Yükle
PowerShell'i aç ve şu komutları çalıştır:

```powershell
cd C:\odev-asistani\backend

git init
git add .
git commit -m "Backend initial commit"
git branch -M main
git remote add origin https://github.com/KULLANICI_ADIN/odev-asistani-backend.git
git push -u origin main
```

**NOT:** `KULLANICI_ADIN` yerine kendi GitHub kullanıcı adını yaz!

---

## 2️⃣ Render.com'da Deploy Et

### Adım 1: Render Hesabı Oluştur
1. https://render.com adresine git
2. **"Get Started for Free"** tıkla
3. **GitHub ile giriş yap**

### Adım 2: Web Service Oluştur
1. Dashboard'da **"New +"** > **"Web Service"** tıkla
2. **"Connect GitHub"** tıkla ve izin ver
3. **`odev-asistani-backend`** repository'sini seç
4. **"Connect"** tıkla

### Adım 3: Ayarları Yap
Şu bilgileri gir:

- **Name:** `odev-asistani-api`
- **Region:** `Frankfurt (EU Central)` (Türkiye'ye en yakın)
- **Branch:** `main`
- **Root Directory:** boş bırak
- **Environment:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`
- **Instance Type:** `Free`

### Adım 4: Environment Variables Ekle
Aşağı kaydır, **"Environment Variables"** bölümünde **"Add Environment Variable"** tıkla.

Şu değişkenleri **TEK TEK** ekle:

| Key | Value |
|-----|-------|
| `PORT` | `5000` |
| `NODE_ENV` | `production` |
| `DATABASE_URL` | `postgresql://neondb_owner:npg_gE9dIk8OraBe@ep-late-mode-amlonxs6-pooler.c-5.us-east-1.aws.neon.tech/neondb?sslmode=require` |
| `JWT_SECRET` | `odev-asistani-super-secret-key-2024-production` |
| `JWT_EXPIRE` | `7d` |
| `GEMINI_API_KEY` | `AIzaSyC7qSXKbOUxe-TcE033StmBaqDht5yYtI4` |
| `DAILY_QUESTION_LIMIT_FREE` | `10` |
| `DAILY_QUESTION_LIMIT_PREMIUM` | `100` |
| `ALLOWED_ORIGINS` | `*` |

### Adım 5: Deploy Et
1. **"Create Web Service"** tıkla
2. Deploy başlayacak (5-10 dakika sürer)
3. Üstte yeşil **"Live"** yazısını bekle
4. URL'i kopyala (örnek: `https://odev-asistani-api.onrender.com`)

### Adım 6: Test Et
PowerShell'de:
```powershell
curl https://odev-asistani-api.onrender.com/health
```

Şu cevabı almalısın:
```json
{"status":"OK","message":"Server is running"}
```

✅ Backend başarıyla deploy edildi!

---

## 3️⃣ Mobile App'te Backend URL'ini Güncelle

### Adım 1: constants.dart Dosyasını Aç
```powershell
cd C:\odev-asistani\mobile
notepad lib\config\constants.dart
```

### Adım 2: baseUrl'i Değiştir
Şu satırı bul:
```dart
static const String baseUrl = 'http://192.168.1.107:5000/api';
```

Render URL'in ile değiştir:
```dart
static const String baseUrl = 'https://odev-asistani-api.onrender.com/api';
```

**Kaydet** (Ctrl+S) ve kapat.

---

## 4️⃣ Yeni APK Oluştur

```powershell
cd C:\odev-asistani\mobile
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat build apk --release
```

APK konumu:
```
C:\odev-asistani\mobile\build\app\outputs\flutter-apk\app-release.apk
```

---

## 🎉 Tamamlandı!

Artık uygulaman internetten çalışıyor! APK'yı telefonuna kur ve test et.

### ⚠️ Önemli Notlar

1. **Render Free Plan:** İlk istek 50 saniye sürebilir (cold start)
2. **Veritabanı:** NeonDB ücretsiz planı kullanılıyor
3. **API Limiti:** Gemini API ücretsiz (günlük limit var)

### 🔧 Sorun Giderme

**Backend'e bağlanamıyorum:**
- Render'da servisin "Live" olduğundan emin ol
- URL'i doğru kopyaladığından emin ol
- `/api` eklemeyi unutma

**Deploy başarısız:**
- GitHub'da kod doğru yüklendi mi kontrol et
- Environment variables doğru girildi mi kontrol et
- Render logs'a bak (Dashboard > Logs)

**Uygulama yavaş:**
- Render free plan cold start yapıyor (normal)
- İlk istek 50 saniye sürebilir
- Sonraki istekler hızlı olacak

---

## 📱 Sonraki Adımlar

1. ✅ Backend deploy edildi
2. ✅ Mobile app güncellendi
3. ✅ APK oluşturuldu
4. 🔜 Play Store'a yükleme (isteğe bağlı)

Başarılar! 🚀
