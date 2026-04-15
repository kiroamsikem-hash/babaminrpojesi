# 📱 Mobil Uygulamayı Başlat - Hızlı Rehber

## ✅ Önce Bunları Yap

### 1. Flutter Kur
**FLUTTER_KURULUM.md** dosyasını aç ve adım adım takip et (30-45 dakika)

### 2. Backend'i Başlat
```powershell
cd backend
npm run dev
```

Görmeli:
```
✅ Server running on port 5000
✅ PostgreSQL Connected
```

---

## 🚀 Hızlı Başlangıç (Flutter Kuruluysa)

### 1. IP Adresini Öğren

```powershell
ipconfig
```

IPv4 Address'i kopyala (örn: `192.168.1.100`)

### 2. Backend URL'ini Ayarla

`mobile/lib/config/constants.dart` dosyasını aç:

```dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

(Kendi IP'nizi yazın)

### 3. Telefonu Bağla

- USB ile bağla
- USB Hata Ayıklama'yı aç
- İzin ver

Kontrol et:
```powershell
flutter devices
```

### 4. Bağımlılıkları Yükle

```powershell
cd mobile
flutter pub get
```

### 5. Çalıştır!

```powershell
flutter run
```

İlk çalıştırma 5-10 dakika sürer!

---

## 📱 Uygulama Özellikleri

### Ana Ekran (Dashboard)
- 🔍 Arama çubuğu
- 📸 Kamera/Tarama
- ✍️ Kompozisyon Yaz
- 🔢 Matematik Çöz
- 🌍 Çeviri Yap
- 📚 Son Etkinlikler

### Özellikler
- ✅ AI ile soru çözme (Gemini - Ücretsiz)
- ✅ Kamera ile OCR
- ✅ Adım adım açıklama
- ✅ Kompozisyon yazma
- ✅ Çeviri
- ✅ Soru geçmişi
- ✅ Profil yönetimi

---

## 🎨 Tasarım

Gönderdiğiniz ekran görüntüsüne uygun:
- Modern, temiz arayüz
- Mavi-beyaz renk paleti
- Büyük, kolay dokunulabilir butonlar
- Smooth animasyonlar

---

## 🆘 Sorun Giderme

### "Unable to connect to backend"

1. Backend çalışıyor mu?
   ```powershell
   # Tarayıcıda aç
   http://localhost:5000/health
   ```

2. IP adresi doğru mu?
   ```powershell
   ipconfig
   ```

3. Firewall engelliyor mu?
   - Windows Defender Firewall
   - Node.js'e izin ver

### "Flutter not found"

Flutter PATH'e eklenmemiş:
1. `C:\flutter\bin` PATH'e ekle
2. PowerShell'i yeniden başlat
3. `flutter --version` test et

### "No devices found"

1. USB Hata Ayıklama açık mı?
2. USB kablosu çalışıyor mu?
3. Telefon tanınıyor mu?
   ```powershell
   flutter devices
   ```

### Emulator çok yavaş

Gerçek telefon kullanın! Çok daha hızlı.

---

## 💡 İpuçlar

1. **Hot Reload:** Kod değiştirince `r` tuşuna bas
2. **Hot Restart:** `R` tuşuna bas (büyük R)
3. **Logs:** `flutter logs` ile logları gör
4. **Debug:** VS Code veya Android Studio kullan

---

## 📊 Proje Durumu

```
✅ Backend: Çalışıyor (Port 5000)
✅ Database: NeonDB (PostgreSQL)
✅ AI: Google Gemini (Ücretsiz)
✅ Mobile: Flutter (Hazır)
```

---

## 🎯 Test Senaryosu

1. **Kayıt Ol**
   - İsim: Test Kullanıcı
   - Email: test@test.com
   - Şifre: test123

2. **Matematik Sorusu Sor**
   - "2x + 5 = 15 denklemini çöz"
   - AI adım adım çözecek

3. **Kamera ile Soru Çöz**
   - Kamera/Tarama butonuna tıkla
   - Sorunun fotoğrafını çek
   - OCR metni çıkaracak
   - AI çözecek

4. **Kompozisyon Yaz**
   - Konu: "Teknolojinin eğitime etkileri"
   - AI essay yazacak

---

## 🎉 Başarılar!

Mobil uygulama tamamen hazır! Telefona kurup test edebilirsiniz! 🚀

**Önemli:** İlk build uzun sürer (5-10 dakika), sabırlı olun!
