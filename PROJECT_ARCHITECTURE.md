# 🏛️ Antik Medeniyetler Timeline - Profesyonel Mimari

## 📁 Klasör Yapısı (Feature-First Architecture)

```
lib/
├── main.dart                           # Uygulama giriş noktası
│
├── core/                               # Çekirdek katman
│   ├── database/
│   │   ├── isar_service.dart          # Isar DB singleton
│   │   └── migrations.dart            # DB versiyonlama
│   ├── theme/
│   │   ├── app_theme.dart             # Dark/Light tema
│   │   └── app_colors.dart            # Renk paleti
│   ├── constants/
│   │   └── app_constants.dart         # Global sabitler
│   └── utils/
│       ├── date_utils.dart            # Tarih yardımcıları
│       └── file_utils.dart            # Dosya işlemleri
│
├── data/                               # Veri katmanı
│   ├── models/                         # Isar Entity modelleri
│   │   ├── civilization.dart          # @collection
│   │   ├── period_event.dart          # @collection
│   │   ├── artifact.dart              # @collection
│   │   ├── connection.dart            # @collection (İlişki)
│   │   └── media_file.dart            # @collection (Fotoğraf/Dosya)
│   ├── repositories/
│   │   ├── civilization_repository.dart
│   │   ├── event_repository.dart
│   │   ├── artifact_repository.dart
│   │   └── connection_repository.dart
│   └── parsers/
│       └── csv_parser.dart            # CSV → Isar dönüştürücü
│
├── domain/                             # İş mantığı katmanı
│   ├── providers/                      # Riverpod providers
│   │   ├── database_provider.dart
│   │   ├── timeline_provider.dart
│   │   ├── graph_provider.dart
│   │   └── inspector_provider.dart
│   └── services/
│       ├── search_service.dart        # Full-text search
│       └── export_service.dart        # Excel export
│
├── presentation/                       # UI katmanı
│   ├── screens/
│   │   ├── main_screen.dart           # Ana layout
│   │   ├── timeline_screen.dart       # Kronoloji grid
│   │   └── graph_screen.dart          # Knowledge graph
│   ├── widgets/
│   │   ├── timeline/
│   │   │   ├── timeline_canvas.dart   # InteractiveViewer
│   │   │   ├── timeline_grid.dart     # Grid çizimi
│   │   │   ├── event_card.dart        # Olay kartı
│   │   │   ├── year_axis.dart         # Y ekseni
│   │   │   └── civilization_axis.dart # X ekseni
│   │   ├── graph/
│   │   │   ├── knowledge_graph.dart   # Node graph
│   │   │   ├── graph_node.dart        # Tek node
│   │   │   └── connection_line.dart   # Bağlantı çizgisi
│   │   ├── inspector/
│   │   │   ├── inspector_panel.dart   # Sağ detay paneli
│   │   │   ├── media_uploader.dart    # Fotoğraf yükleme
│   │   │   ├── rich_text_editor.dart  # Metin editörü
│   │   │   └── link_selector.dart     # Bağlantı seçici
│   │   └── common/
│   │       ├── loading_indicator.dart
│   │       └── error_widget.dart
│   └── dialogs/
│       ├── import_dialog.dart         # CSV import
│       └── export_dialog.dart         # Excel export
│
└── generated/                          # Otomatik üretilen dosyalar
    └── *.g.dart                        # Isar şemaları
```

## 📦 Gerekli Paketler (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  
  # CSV & File Operations
  csv: ^6.0.0
  file_picker: ^8.0.0+1
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0
  graphview: ^1.2.0
  
  # Image & Media
  image_picker: ^1.1.0
  cached_network_image: ^3.3.1
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.9
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.0
  
  # Linting
  flutter_lints: ^6.0.0
```

## 🗄️ Veri Modeli (Entity Relationships)

```
┌─────────────────┐
│  Civilization   │
│  (Medeniyet)    │
│─────────────────│
│ id: Id          │
│ name: String    │
│ color: int      │
│ region: String  │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼────────┐      N:M      ┌─────────────────┐
│  PeriodEvent    │◄───────────────┤   Connection    │
│  (Dönem/Olay)   │                │   (Bağlantı)    │
│─────────────────│                │─────────────────│
│ id: Id          │                │ id: Id          │
│ startYear: int  │                │ sourceId: Id    │
│ endYear: int?   │                │ targetId: Id    │
│ title: String   │                │ type: String    │
│ description: St │                │ label: String?  │
│ civilizationId  │                └─────────────────┘
└────────┬────────┘                         │
         │                                  │
         │ 1:N                              │
         │                                  │
┌────────▼────────┐                         │
│    Artifact     │◄────────────────────────┘
│   (Buluntu)     │
│─────────────────│
│ id: Id          │
│ name: String    │
│ description: St │
│ eventId: Id?    │
│ mediaFiles: []  │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼────────┐
│   MediaFile     │
│  (Fotoğraf)     │
│─────────────────│
│ id: Id          │
│ path: String    │
│ type: String    │
│ artifactId: Id  │
└─────────────────┘
```

## 🎯 Özellikler

1. **Interactive Timeline Grid**
   - Pan & Zoom (InteractiveViewer)
   - Virtualized rendering (sadece görünen hücreler)
   - Sticky headers (X ve Y eksenleri)
   - Drag & drop event kartları

2. **Knowledge Graph**
   - Node-based visualization
   - Connection lines
   - Interactive node selection
   - Auto-layout algorithm

3. **Inspector Panel**
   - Rich text editor
   - Media upload (fotoğraf, PDF)
   - Link to other items
   - Full-text search

4. **Data Management**
   - CSV import/export
   - Full-text search (Isar)
   - Undo/Redo
   - Auto-save

## 🚀 Geliştirme Fazları

- [x] Faz 0: Mimari planlama
- [ ] Faz 1: Database & Models (Isar entities + CSV parser)
- [ ] Faz 2: Riverpod Providers & Core UI
- [ ] Faz 3: Interactive Timeline Grid
- [ ] Faz 4: Knowledge Graph
- [ ] Faz 5: Inspector Panel & Relations
