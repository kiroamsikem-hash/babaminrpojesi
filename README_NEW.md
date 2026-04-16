# 🏛️ Antik Medeniyetler Timeline - Profesyonel Excel-Benzeri Uygulama

Modern, yüksek performanslı Flutter masaüstü/web uygulaması - Tarihsel verileri Excel'i geride bırakan bir deneyimle görselleştirin!

## 🎯 Özellikler

### ✅ Tamamlanan (FAZ 1-3)

- **Isar Database** - İlişkisel NoSQL veritabanı
  - 5 Entity modeli (Civilization, PeriodEvent, Artifact, MediaFile, Connection)
  - Full-text search desteği
  - Stream-based reactive updates
  
- **Riverpod State Management** - Modern, tip-güvenli state yönetimi
  - Database providers
  - Timeline providers
  - Graph providers
  
- **Interactive Timeline Grid** - Excel-benzeri ama çok daha güçlü!
  - Pan & Zoom (InteractiveViewer)
  - Sticky headers (X ve Y eksenleri)
  - Renk kodlu event kartları
  - Responsive grid layout
  
- **Inspector Panel** - Sağ detay paneli
  - Event düzenleme
  - Açıklama ekleme
  - Kaydetme özelliği

### 🚧 Geliştirilecek (FAZ 4-5)

- **Knowledge Graph** - Node-based görselleştirme
- **Connection System** - Entity'ler arası bağlantılar
- **Media Upload** - Fotoğraf ve dosya yükleme
- **Advanced Search** - Full-text search UI
- **Export/Import** - Excel export

## 🏗️ Mimari

### Feature-First Architecture

```
lib/
├── core/                    # Çekirdek katman
│   ├── database/           # Isar service
│   ├── theme/              # Dark theme
│   └── constants/          # Sabitler
├── data/                    # Veri katmanı
│   ├── models/             # Isar entities
│   ├── repositories/       # CRUD operations
│   └── parsers/            # CSV parser
├── domain/                  # İş mantığı
│   └── providers/          # Riverpod providers
└── presentation/            # UI katmanı
    ├── screens/            # Ana ekranlar
    └── widgets/            # Reusable widgets
```

### Veri Modeli

```
Civilization (1) ──→ (N) PeriodEvent
                           ↓
                      Artifact ──→ MediaFile
                           ↓
                      Connection (N:M)
```

## 🚀 Kurulum

```bash
cd civilization_timeline_app

# Bağımlılıkları yükle
flutter pub get

# Isar şemalarını generate et
flutter pub run build_runner build

# Çalıştır
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run -d macos   # macOS
```

## 📦 Teknoloji Yığını

- **Flutter 3.41.6** - UI framework
- **Dart 3.11.4** - Programming language
- **Isar 3.1.0** - NoSQL database
- **Riverpod 2.5.1** - State management
- **InteractiveViewer** - Pan & zoom
- **CustomPaint** - Grid rendering

## 🎨 Özellikler Detay

### Interactive Timeline Grid

- **Pan**: Sürükle ve bırak ile gezinme
- **Zoom**: Mouse tekerleği ile yakınlaştırma (0.3x - 3x)
- **Sticky Headers**: Eksenler her zaman görünür
- **Color Coding**: Her medeniyet için özel renk
- **Responsive**: Dinamik grid boyutlandırma

### Inspector Panel

- **Event Editing**: Başlık ve açıklama düzenleme
- **Auto-save**: Değişiklikler otomatik kaydedilir
- **Media Section**: Fotoğraf ekleme (FAZ 5)
- **Connections**: Bağlantı oluşturma (FAZ 4)

### Database Features

- **Reactive**: Stream-based updates
- **Fast**: Isar'ın native performansı
- **Indexed**: Hızlı sorgular için indexler
- **Relations**: N:M ilişkiler

## 📊 Performans

- **Virtualization**: Sadece görünen hücreler render edilir
- **Lazy Loading**: Veriler ihtiyaç anında yüklenir
- **Optimized Rendering**: CustomPaint ile optimize çizim
- **Memory Efficient**: Isar'ın düşük bellek kullanımı

## 🔄 Geliştirme Fazları

- [x] **FAZ 1**: Database & Models
- [x] **FAZ 2**: Riverpod Providers & Core UI
- [x] **FAZ 3**: Interactive Timeline Grid
- [ ] **FAZ 4**: Knowledge Graph & Connections
- [ ] **FAZ 5**: Inspector Panel & Media Upload

## 🎯 Kullanım

1. **Gezinme**: Timeline'da sürükle-bırak ile gezin
2. **Zoom**: Mouse tekerleği ile yakınlaştır/uzaklaştır
3. **Event Seç**: Bir karta tıkla
4. **Düzenle**: Sağ panelde detayları düzenle
5. **Kaydet**: Değişiklikleri kaydet butonu

## 🐛 Bilinen Sorunlar

- CardTheme deprecation warning (Flutter 3.41.6)
- Analyzer version mismatch warning

## 📝 Lisans

Eğitim amaçlıdır.

## 👨‍💻 Geliştirici

Flutter & Dart ile profesyonel mimari kullanılarak geliştirilmiştir.
