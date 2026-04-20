import 'package:flutter/material.dart';
import '../config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Şartları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Kullanım Şartları ve Koşulları',
              'Son Güncelleme: ${DateTime.now().year}',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Hizmetin Kabul Edilmesi',
              'Kiwo uygulamasını ("Uygulama") kullanarak, bu Kullanım Şartlarını kabul etmiş olursunuz. Bu şartları kabul etmiyorsanız, lütfen uygulamayı kullanmayınız.',
            ),
            _buildSection(
              '2. Hizmet Tanımı',
              'Kiwo, yapay zeka destekli bir eğitim asistanı uygulamasıdır. Uygulama, öğrencilere ödev ve ders çalışmalarında yardımcı olmak amacıyla tasarlanmıştır. Hizmetimiz şunları içerir:\n\n'
              '• Soru çözme ve açıklama\n'
              '• Matematik problemleri çözümü\n'
              '• Kompozisyon yazma yardımı\n'
              '• Çeviri hizmetleri\n'
              '• OCR (Optik Karakter Tanıma) ile görüntüden metin çıkarma',
            ),
            _buildSection(
              '3. Kullanıcı Sorumlulukları',
              'Uygulamayı kullanırken:\n\n'
              '• Doğru ve güncel bilgiler sağlamalısınız\n'
              '• Hesap güvenliğinizden siz sorumlusunuz\n'
              '• Uygulamayı yasa dışı amaçlarla kullanmamalısınız\n'
              '• Başkalarının haklarını ihlal etmemelisiniz\n'
              '• Sistemi manipüle etmeye çalışmamalısınız',
            ),
            _buildSection(
              '4. Yapay Zeka Kullanımı',
              'Uygulamamız, sorularınızı yanıtlamak için üçüncü taraf yapay zeka hizmetlerini (Groq, Google Gemini, vb.) kullanmaktadır. Bu hizmetler:\n\n'
              '• Bazen hatalı veya eksik bilgi verebilir\n'
              '• Yanıtların doğruluğunu garanti edemeyiz\n'
              '• Kritik kararlar için profesyonel danışmanlık almalısınız\n'
              '• AI yanıtları eğitim amaçlıdır, kesin bilgi kaynağı değildir',
            ),
            _buildSection(
              '5. Kullanım Limitleri',
              'Ücretsiz hesaplar için günlük soru limiti uygulanmaktadır. Premium hesaplar daha yüksek limitlerden yararlanır. Limitler önceden haber verilmeksizin değiştirilebilir.',
            ),
            _buildSection(
              '6. Fikri Mülkiyet Hakları',
              'Uygulama ve içeriği (tasarım, logo, kod, vb.) telif hakkı ile korunmaktadır. Tüm hakları saklıdır. İzinsiz kopyalama, dağıtma veya değiştirme yasaktır.',
            ),
            _buildSection(
              '7. Hizmet Değişiklikleri',
              'Kiwo, önceden haber vermeksizin:\n\n'
              '• Hizmeti değiştirme\n'
              '• Özellikleri ekleme veya kaldırma\n'
              '• Fiyatlandırmayı güncelleme\n'
              '• Hizmeti geçici veya kalıcı olarak durdurma\n\nhakkını saklı tutar.',
            ),
            _buildSection(
              '8. Sorumluluk Reddi',
              'Kiwo, "olduğu gibi" sunulmaktadır. Şunları garanti etmiyoruz:\n\n'
              '• Hizmetin kesintisiz olacağını\n'
              '• Hataların düzeltileceğini\n'
              '• Sonuçların doğruluğunu\n'
              '• Belirli bir amaca uygunluğu\n\n'
              'Uygulamayı kullanımınızdan doğabilecek zararlardan sorumlu değiliz.',
            ),
            _buildSection(
              '9. Hesap İptali',
              'Kiwo, şu durumlarda hesabınızı askıya alabilir veya iptal edebilir:\n\n'
              '• Kullanım şartlarını ihlal etmeniz\n'
              '• Hileli veya kötüye kullanım tespit edilmesi\n'
              '• Yasal zorunluluklar\n'
              '• Uzun süre kullanılmaması',
            ),
            _buildSection(
              '10. Değişiklikler',
              'Bu kullanım şartları zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinde bildirilecektir. Değişikliklerden sonra uygulamayı kullanmaya devam etmeniz, yeni şartları kabul ettiğiniz anlamına gelir.',
            ),
            _buildSection(
              '11. İletişim',
              'Sorularınız için bizimle iletişime geçebilirsiniz:\n\n'
              'Email: support@kiwo.app\n'
              'Geliştirici: Melih Y.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Text(
                'Bu kullanım şartlarını kabul ederek, yukarıdaki tüm maddeleri okuduğunuzu ve anladığınızı beyan edersiniz.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
