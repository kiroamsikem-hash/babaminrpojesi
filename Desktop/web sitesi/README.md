# 🔗 IP Logger - Gelişmiş Link Takip Sistemi

Modern ve profesyonel IP tracking sistemi. Detaylı ziyaretçi analizi ve konum takibi.

## ✨ Özellikler

### 📍 Konum Takibi
- **GPS Bazlı Konum** (Kullanıcı izni ile)
  - Hassas koordinatlar (5-50 metre)
  - Yükseklik, hız, yön bilgisi
  - Tam adres (Sokak, mahalle, ilçe)
  
- **IP Bazlı Konum**
  - Şehir, bölge, ülke
  - Posta kodu
  - ISP/Organizasyon bilgisi
  - Tahmini adres

### 🗺️ Harita Entegrasyonu
- Leaflet.js ile interaktif harita
- Tüm ziyaretçiler haritada işaretli
- Detaylı popup bilgileri
- "Haritada Göster" butonu

### 📊 Detaylı Bilgiler

**Cihaz:**
- İşletim sistemi
- Tarayıcı
- Ekran çözünürlüğü
- CPU çekirdek sayısı
- Cihaz belleği
- Dokunmatik nokta sayısı

**Tarayıcı:**
- Dil ayarları
- Saat dilimi
- Cookies, LocalStorage
- Eklentiler
- Referrer

**Bağlantı:**
- Bağlantı tipi (4G, WiFi)
- Download hızı
- Ping (RTT)
- Data saver modu

**Batarya:**
- Seviye (%)
- Şarj durumu
- Şarj/Boşalma süresi

**Fingerprint:**
- Canvas Fingerprint
- WebGL bilgileri
- Audio Context
- Medya cihazları

### 🎨 Arayüz
- Modern dark theme
- Animasyonlu toast bildirimleri
- Responsive tasarım
- Smooth animasyonlar
- Kategorize edilmiş bilgiler

## 🚀 Kurulum

1. Tüm dosyaları bir klasöre kopyalayın
2. `index.html` dosyasını tarayıcıda açın
3. Link oluşturun ve paylaşın

## 📁 Dosya Yapısı

```
├── index.html          # Ana sayfa (Link oluşturma)
├── view.html           # Ziyaretçi sayfası (Veri toplama)
├── track.html          # Takip paneli
├── style.css           # Ana sayfa stilleri
├── track-style.css     # Takip paneli stilleri
├── script.js           # Ana sayfa JavaScript
└── track-script.js     # Takip paneli JavaScript
```

## 🔒 Güvenlik ve Gizlilik

### Yasal Uyarı
- Bu sistem sadece yasal amaçlar için kullanılmalıdır
- Link oluşturan kişi tüm sorumluluğu kabul eder
- KVKK ve GDPR kurallarına uygun kullanılmalıdır
- Kullanıcı onayı olmadan kişisel veri toplamak yasaktır

### Kullanım Şartları
- Taciz, dolandırıcılık veya yasadışı faaliyetler için kullanım yasaktır
- Platform sadece teknik altyapı sağlar
- Kullanıcıların oluşturduğu linklerden platform sorumlu değildir

## 🛠️ Teknolojiler

- **Frontend:** HTML5, CSS3, JavaScript (ES6+)
- **Harita:** Leaflet.js
- **İkonlar:** Font Awesome 6
- **Fontlar:** Inter, Playfair Display
- **API:** ipapi.co (IP bilgisi), OpenStreetMap Nominatim (Reverse Geocoding)

## 📝 Notlar

### LocalStorage Kullanımı
Şu anda veriler LocalStorage'da saklanıyor (demo amaçlı).
Gerçek kullanım için backend gereklidir:
- Node.js + Express
- MongoDB / PostgreSQL
- REST API

### GPS İzni
GPS bazlı konum için kullanıcı izni gerekir.
İzin verilmezse IP bazlı konum kullanılır.

### API Limitleri
- ipapi.co: 1000 istek/gün (ücretsiz)
- Nominatim: 1 istek/saniye

## 🎯 Kullanım

1. **Link Oluştur:**
   - Başlık ekle (opsiyonel)
   - Yönlendirme URL'i ekle (opsiyonel)
   - Kullanım şartlarını kabul et
   - "Link Oluştur" butonuna tıkla

2. **Link Paylaş:**
   - Oluşturulan linki kopyala
   - İstediğin yerde paylaş

3. **Takip Et:**
   - Takip linkini aç
   - Ziyaretçi bilgilerini gör
   - Haritada konumları incele

## 📱 Responsive

Tüm cihazlarda çalışır:
- Masaüstü
- Tablet
- Mobil

## 🎨 Özelleştirme

### Renk Teması
`style.css` ve `track-style.css` dosyalarından renkler değiştirilebilir.

### Harita Stili
`track-script.js` içinde Leaflet tile layer değiştirilebilir.

## 📄 Lisans

Bu proje eğitim amaçlıdır. Ticari kullanım için izin gereklidir.

## ⚠️ Sorumluluk Reddi

BU SİSTEMİ KULLANARAK, OLUŞTURDUĞUNUZ LİNKLERDEN VE TOPLANAN VERİLERDEN DOĞACAK TÜM YASAL SORUMLULUĞU KABUL ETMİŞ SAYILIRSINIZ.

---

Made with ❤️ for educational purposes
