# 🎓 Ödev Asistanı - AI Destekli Eğitim Uygulaması

Yapay zeka ile ödev yapan, soru çözen ve öğrencilere yardımcı olan mobil uygulama.

## 📱 Özellikler

- ✅ Kullanıcı kayıt/giriş sistemi
- ✅ Matematik soruları çözme
- ✅ Kompozisyon yazma
- ✅ Çeviri yapma
- ✅ Geçmiş sorular
- ✅ Profil yönetimi
- 🔜 Kamera ile soru çözme (OCR)

## 🛠️ Teknolojiler

### Backend
- Node.js + Express
- PostgreSQL (NeonDB)
- Google Gemini AI (Ücretsiz)
- JWT Authentication

### Mobile
- Flutter
- Provider (State Management)
- Material Design

## 🚀 Kurulum

**KURULUM.md** dosyasını aç ve adım adım takip et.

Özet:
1. Backend'i GitHub'a yükle
2. Render.com'da deploy et
3. Mobile app'te URL'i güncelle
4. APK oluştur

## 📂 Proje Yapısı

```
odev-asistani/
├── backend/          # Node.js API
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── config/
│   └── package.json
│
├── mobile/           # Flutter App
│   ├── lib/
│   │   ├── screens/
│   │   ├── providers/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── config/
│   └── pubspec.yaml
│
└── KURULUM.md       # Deployment rehberi
```

## 🔑 API Keys

- **Gemini AI:** Ücretsiz (günlük limit var)
- **NeonDB:** Ücretsiz PostgreSQL
- **Render.com:** Ücretsiz hosting

## 📞 Destek

Sorun yaşarsan KURULUM.md dosyasındaki "Sorun Giderme" bölümüne bak.

---

**Hazırlayan:** AI Destekli Geliştirme
**Lisans:** MIT
