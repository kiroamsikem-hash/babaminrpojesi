# 🏛️ Antik Medeniyetler Zaman Çizelgesi

Modern, etkileşimli Flutter mobil uygulaması - M.Ö. 3900'den M.Ö. 500'e kadar antik medeniyetlerin tarihsel olaylarını görselleştirin.

## 📱 Özellikler

- ✅ **AI Destekli Toplu Düzenleme** - Ctrl+A ile seç, "50 azalt" gibi komutlarla yıl ayarla
- ✅ **Etkileşimli Timeline Canvas** - Yatay ve dikey kaydırma ile gezinme
- ✅ **Sticky Headers** - Medeniyet ve yıl başlıkları her zaman görünür
- ✅ **Fotoğraf Desteği** - Önemli olaylar için tarihsel görseller
- ✅ **Filtreleme** - Medeniyete göre filtrele, arama yap
- ✅ **Detay Paneli** - Bottom sheet ile olay detayları ve fotoğraflar
- ✅ **Dark Mode** - Fütüristik, müzemsi tasarım
- ✅ **Renk Kodlu Kartlar** - Her medeniyet için özel renk paleti
- ✅ **CSV Parsing** - Boş hücreleri atlar, optimize edilmiş veri işleme
- ✅ **State Management** - Provider ile reaktif state yönetimi
- ✅ **Overflow Koruması** - Kartlar için max yükseklik ve scroll desteği

## 🏗️ Mimari

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── models/
│   └── historical_event.dart      # Veri modeli (imageUrl desteği)
├── services/
│   └── csv_parser_service.dart    # CSV parsing servisi
├── providers/
│   └── timeline_provider.dart     # State management (Provider)
├── screens/
│   └── timeline_screen.dart       # Ana ekran
├── widgets/
│   ├── timeline_canvas.dart       # Etkileşimli timeline grid
│   ├── event_card.dart            # Olay kartı (fotoğraf desteği)
│   ├── detail_panel.dart          # Detay bottom sheet (fotoğraf gösterimi)
│   └── filter_bar.dart            # Filtreleme bar'ı
└── constants/
    ├── app_constants.dart         # Renkler, konfigürasyon
    └── image_mappings.dart        # Olay-fotoğraf eşleştirmeleri
```

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.11.4+
- Dart 3.11.4+

### Adımlar

1. **Bağımlılıkları yükle:**
```bash
cd civilization_timeline_app
flutter pub get
```

2. **Uygulamayı çalıştır:**
```bash
# Android emulator veya cihaz
flutter run

# iOS simulator (macOS)
flutter run -d ios

# Chrome (web)
flutter run -d chrome
```

3. **Build al:**
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## 📦 Kullanılan Paketler

- `provider: ^6.1.1` - State management
- `csv: ^6.0.0` - CSV parsing
- `flutter_staggered_animations: ^1.1.1` - Animasyonlar
- `intl: ^0.19.0` - Tarih formatlama

## 🎨 Tasarım Özellikleri

### Renk Paleti
- **Minoan**: Altın (#FFD700)
- **Hitit**: Kızıl (#DC143C)
- **Miken**: Kraliyet Mavisi (#4169E1)
- **Mezopotamya**: Toprak Tonu (#8B4513)
- **Yunan**: Ege Mavisi (#00CED1)
- **Batı Anadolu**: Mor (#9370DB)

### Timeline Konfigürasyonu
- Yıl aralığı: M.Ö. 3900 - M.Ö. 500
- Her yıl için yükseklik: 80px
- Medeniyet sütunu genişliği: 280px
- Sticky eksenler (yıl ve medeniyet başlıkları)

## 📊 Veri Yapısı

CSV formatı:
```csv
Yıl,Minoan,Hitit,Miken,Mezopotamya,Yunan,Batı Anadolu
-3900,,,,,,"Troia I yerleşimi başlar"
-3500,"Erken Minoan Dönemi başlar",,,,,"Beycesultan kültürü"
...
```

## 🤖 AI Destekli Toplu Düzenleme

Uygulamanın en güçlü özelliği! Olayları toplu olarak düzenleyebilirsiniz:

### Nasıl Kullanılır?

1. **Olayları Seç**: Kartlara uzun basarak seçin veya "Tümünü Seç" ile hepsini seçin
2. **AI Komut Gir**: Doğal dilde komut yazın
3. **Uygula**: Enter'a basın veya gönder butonuna tıklayın

### Komut Örnekleri:

- `50 azalt` - Seçili olayları 50 yıl geriye al
- `60 yıl arttır` - Seçili olayları 60 yıl ileriye al
- `-100` - 100 yıl geriye al
- `+75` - 75 yıl ileriye al

### Kısayollar:

- `Ctrl+A` veya `Cmd+A` - Toplu düzenleme panelini aç
- `Ctrl+E` veya `Cmd+E` - Toplu düzenleme panelini aç
- Uzun basma - Tek bir olayı seç/seçimi kaldır

### Hızlı Aksiyonlar:

Panel içinde hazır butonlar:
- -50 yıl
- -100 yıl
- +50 yıl
- +100 yıl

## 🖼️ Fotoğraf Sistemi

Uygulama, belirli olaylar için otomatik olarak Wikipedia'dan tarihsel görseller yükler:

- **Knossos Sarayı** - Minoan medeniyeti
- **Thera Yanardağı** - Santorini patlaması
- **Hattuşa** - Hitit başkenti
- **Kadeş Savaşı** - Hitit-Mısır savaşı
- **Miken Sarayları** - Aslan Kapısı
- **Troia** - Troia kalıntıları
- **Hammurabi Kanunları** - Hammurabi steli
- **Babil** - İştar Kapısı
- **Olimpiyat** - Olympia tapınağı

Yeni fotoğraflar eklemek için `lib/constants/image_mappings.dart` dosyasını düzenleyin.

## 🔄 Gelecek Özellikler

- [x] Fotoğraf desteği
- [x] Overflow koruması
- [ ] Fotoğraf galerisi (birden fazla fotoğraf)
- [ ] Favorilere ekleme
- [ ] Offline mod
- [ ] Çoklu dil desteği
- [ ] Wikipedia entegrasyonu
- [ ] Zaman periyodu filtreleme (Tunç Çağı, Demir Çağı)
- [ ] Karanlık/Aydınlık tema geçişi

## 📝 Lisans

Bu proje eğitim amaçlıdır.

## 👨‍💻 Geliştirici

Flutter & Dart ile geliştirilmiştir.
