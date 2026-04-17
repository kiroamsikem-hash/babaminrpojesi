# 🎯 Kullanım Notları - Medeniyet Zaman Çizelgesi

## ✅ Tamamlanan Özellikler

### 1. Excel Gibi Satır Seçimi
- Satırın herhangi bir yerine tıklayın → Satır mavi ile parlar
- Tekrar tıklayın → Seçim kalkar
- Seçili satır tüm sütunlarda vurgulanır

### 2. Fotoğraf Ekleme (Düzeltildi)
- Artık tüm editörlerde fotoğraf ekleme çalışıyor
- İlk kullanımda izin istenir
- İzin verildikten sonra galeriden fotoğraf seçebilirsiniz

### 3. Kullanım Kılavuzu
- Sağ alttaki yardım butonuna tıklayın
- VEYA üç nokta menüsünden "Kullanım Kılavuzu"
- 8 sayfalık detaylı rehber
- Tüm özellikleri öğrenin

## 🎮 Nasıl Kullanılır?

### Satır Seçme
```
1. Bir satıra tıklayın
2. Satır mavi ile parlar
3. Tekrar tıklayın → Seçim kalkar
```

### Sütun Düzenleme (Medeniyet)
```
Mobil: Sütun başlığına uzun basın
Masaüstü: Sütun başlığına sağ tıklayın

Seçenekler:
- Sütunu Düzenle → İsim, renk, fotoğraf, etiket
- Yeni Satır Ekle → Bu medeniyete olay ekle
```

### Satır Düzenleme (Yıl)
```
Mobil: Yıl etiketine uzun basın
Masaüstü: Yıl etiketine sağ tıklayın

Seçenekler:
- Satırı Düzenle → Yıl bilgilerini düzenle
- Satıra Fotoğraf Ekle → Yıl arka planı
- Satıra Etiket Ekle → Yıl etiketi
- Bu Yıla Olay Ekle → Yeni olay
```

### Olay Düzenleme
```
Mobil: Olay kartına uzun basın
Masaüstü: Olay kartına sağ tıklayın

Seçenekler:
- Olayı Düzenle → Tüm bilgileri değiştir
- Fotoğraf Ekle → Olay görseli
- Etiket Ekle → Olay kategorisi
- Sil → Olayı kaldır
```

### Ayarlar (⋮)
```
Sağ üst köşedeki 3 noktaya tıklayın

Özellikler:
- Yıl Aralığı: -4050 ile -550 arası
- Yıl Adımı: 1, 5, 10, 25, 50, 100, 200, 500
- Tarih Formatı: M.Ö., BC, BCE
- Görünüm: Grid, etiketler, fotoğraflar
- Hücre Boyutu: Yükseklik ve genişlik
- Hızlı Ön Ayarlar: Tunç Çağı, Demir Çağı
```

## 📱 APK Kurulumu

### Debug APK (Test İçin)
```bash
# Mevcut dizinde
flutter build apk --debug

# APK konumu:
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (Üretim)
```bash
# ÖNEMLİ: Proje yolunda Türkçe karakter sorunu var!
# Çözüm: Projeyi Türkçe karakter olmayan bir yola taşıyın

# Örnek 1: Desktop'a taşı
cd C:\Users\yazar\Desktop
mkdir civilization_timeline
move "babamın web site\civilization_timeline_app" civilization_timeline\
cd civilization_timeline\civilization_timeline_app

# Örnek 2: C:\ kök dizinine taşı
cd C:\
mkdir projects
move "C:\Users\yazar\Desktop\babamın web site\civilization_timeline_app" projects\
cd projects\civilization_timeline_app

# Sonra build et
flutter clean
flutter build apk --release

# APK konumu:
build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 Özellikler

### Satır Seçimi
- ✅ Excel gibi satır seçimi
- ✅ Mavi vurgulu görünüm
- ✅ Tüm sütunlarda parlama
- ✅ Yıl ekseninde vurgulama

### Fotoğraf Ekleme
- ✅ Sütunlara fotoğraf (medeniyet)
- ✅ Satırlara fotoğraf (yıl)
- ✅ Olaylara fotoğraf
- ✅ İzin yönetimi

### Etiketler
- ✅ Sütunlara etiket (medeniyet)
- ✅ Satırlara etiket (yıl)
- ✅ Olaylara etiket
- ✅ İlk 2 etiket gösterilir

### Kullanım Kılavuzu
- ✅ 8 sayfalık rehber
- ✅ Görsel anlatım
- ✅ İpuçları
- ✅ Kolay erişim

## 🐛 Bilinen Sorunlar

### APK Build Sorunu
**Problem**: Release APK build edilemiyor
**Sebep**: Proje yolunda Türkçe karakter (ı) var
**Çözüm**: Projeyi Türkçe karakter olmayan yola taşıyın (yukarıya bakın)

### Neden Oluyor?
- Dart AOT derleyicisi ASCII olmayan karakterlerle sorun yaşıyor
- Debug build çalışır (AOT kullanmaz)
- Release build AOT gerektirir (Türkçe karakterle çalışmaz)

## 📊 İstatistikler

- **Toplam özellik**: 13 görev tamamlandı
- **Satır sayısı**: ~15,000+ satır kod
- **Dosya sayısı**: 50+ dosya
- **Kullanım kılavuzu**: 8 sayfa
- **Desteklenen yıl aralığı**: -4050 ile -550

## 🚀 Sonraki Adımlar

1. **Projeyi taşı** (Türkçe karakter olmayan yola)
2. **Release APK build et**
3. **Telefona kur ve test et**:
   - Satır seçimi
   - Fotoğraf ekleme
   - Kullanım kılavuzu
   - Tüm özellikler

## 💡 İpuçları

### Mobil Kullanım
- Uzun basın → Menü açılır
- İki parmakla yakınlaştırın
- Tek parmakla kaydırın

### Masaüstü Kullanım
- Sağ tıklayın → Menü açılır
- Mouse tekerleği → Yakınlaştır
- Sürükle → Kaydır

### Hızlı Kullanım
- Ayarlardan ön ayarları kullanın
- Renklerle medeniyetleri ayırın
- Etiketlerle olayları kategorize edin
- Fotoğraflarla görsel zenginlik katın

## 📞 Destek

Sorun yaşarsanız:
1. Kullanım kılavuzunu okuyun (uygulamada)
2. TASK_13_COMPLETED.md dosyasına bakın
3. GitHub'da issue açın

## 🎉 Tebrikler!

Artık Excel'den çok daha güçlü bir medeniyet zaman çizelgesi uygulamanız var!
