import 'package:flutter/material.dart';

/// User Guide Dialog - Excel-like tutorial
class UserGuideDialog extends StatefulWidget {
  const UserGuideDialog({super.key});

  @override
  State<UserGuideDialog> createState() => _UserGuideDialogState();
}

class _UserGuideDialogState extends State<UserGuideDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<GuideStep> _steps = [
    GuideStep(
      icon: Icons.grid_on,
      title: 'Hoş Geldiniz!',
      description: 'Medeniyet Zaman Çizelgesi uygulamasına hoş geldiniz. '
          'Bu uygulama Excel gibi çalışır ama çok daha güçlüdür.',
      tips: [
        'Satırlar yılları temsil eder',
        'Sütunlar medeniyetleri temsil eder',
        'Her hücre bir olayı gösterir',
      ],
    ),
    GuideStep(
      icon: Icons.touch_app,
      title: 'Satır Seçimi',
      description: 'Excel gibi satırları seçebilirsiniz:',
      tips: [
        'Bir satıra tıklayın → Satır mavi ile vurgulanır',
        'Tekrar tıklayın → Seçim kaldırılır',
        'Seçili satır tüm sütunlarda parlak görünür',
      ],
    ),
    GuideStep(
      icon: Icons.zoom_in,
      title: 'Yakınlaştırma & Kaydırma',
      description: 'Zaman çizelgesinde gezinin:',
      tips: [
        'İki parmakla yakınlaştırın/uzaklaştırın',
        'Tek parmakla kaydırın',
        'Figma/Miro gibi serbest hareket',
      ],
    ),
    GuideStep(
      icon: Icons.view_column,
      title: 'Sütun (Medeniyet) İşlemleri',
      description: 'Sütun başlığına sağ tıklayın veya uzun basın:',
      tips: [
        'Sütunu Düzenle → İsim, renk, fotoğraf, etiket',
        'Yeni Satır Ekle → Bu medeniyete olay ekle',
        'Fotoğraf arka planda görünür',
        'İlk 2 etiket gösterilir',
      ],
    ),
    GuideStep(
      icon: Icons.table_rows,
      title: 'Satır (Yıl) İşlemleri',
      description: 'Yıl etiketine sağ tıklayın veya uzun basın:',
      tips: [
        'Satırı Düzenle → Yıl bilgilerini düzenle',
        'Satıra Fotoğraf Ekle → Yıl arka planı',
        'Satıra Etiket Ekle → Yıl etiketi',
        'Bu Yıla Olay Ekle → Yeni olay',
      ],
    ),
    GuideStep(
      icon: Icons.event,
      title: 'Olay Kartları',
      description: 'Olay kartlarına sağ tıklayın veya uzun basın:',
      tips: [
        'Olayı Düzenle → Tüm bilgileri değiştir',
        'Fotoğraf Ekle → Olay görseli',
        'Etiket Ekle → Olay kategorisi',
        'Sil → Olayı kaldır',
      ],
    ),
    GuideStep(
      icon: Icons.settings,
      title: 'Ayarlar (⋮)',
      description: 'Sağ üst köşedeki 3 noktaya tıklayın:',
      tips: [
        'Yıl Aralığı → -4050 ile -550 arası',
        'Yıl Adımı → 1, 5, 10, 25, 50, 100, 200, 500',
        'Tarih Formatı → M.Ö., BC, BCE',
        'Görünüm → Grid, etiketler, fotoğraflar',
        'Hücre Boyutu → Yükseklik ve genişlik',
        'Hızlı Ön Ayarlar → Tunç Çağı, Demir Çağı',
      ],
    ),
    GuideStep(
      icon: Icons.tips_and_updates,
      title: 'İpuçları',
      description: 'Daha iyi kullanım için:',
      tips: [
        '📱 Mobil: Uzun basın → Menü açılır',
        '🖥️ Masaüstü: Sağ tıklayın → Menü açılır',
        '🎨 Renkler: Her medeniyet için farklı renk',
        '🏷️ Etiketler: Olayları kategorize edin',
        '📸 Fotoğraflar: Görsel zenginlik katın',
        '⚡ Hızlı: Ayarlardan ön ayarları kullanın',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Kullanım Kılavuzu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            size: 64,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          step.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Tips
                        ...step.tips.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri'),
                ),
                Text(
                  '${_currentPage + 1} / ${_steps.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextPage,
                  icon: Icon(
                    _currentPage < _steps.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentPage < _steps.length - 1 ? 'İleri' : 'Bitir',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GuideStep {
  final IconData icon;
  final String title;
  final String description;
  final List<String> tips;

  GuideStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.tips,
  });
}
