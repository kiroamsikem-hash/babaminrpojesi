import 'package:flutter/material.dart';
import '../config/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Gizlilik Politikası',
              'Son Güncelleme: ${DateTime.now().year}\n\n'
              'Kiwo olarak gizliliğinize önem veriyoruz. Bu politika, kişisel verilerinizin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Toplanan Bilgiler',
              'Uygulamayı kullanırken şu bilgileri topluyoruz:\n\n'
              '1.1. Hesap Bilgileri:\n'
              '• İsim ve soyisim\n'
              '• Email adresi\n'
              '• Şifre (şifrelenmiş olarak)\n'
              '• Eğitim seviyesi\n\n'
              '1.2. Kullanım Verileri:\n'
              '• Sorduğunuz sorular\n'
              '• AI yanıtları\n'
              '• Uygulama kullanım istatistikleri\n'
              '• Cihaz bilgileri (model, işletim sistemi)\n\n'
              '1.3. Görüntü Verileri:\n'
              '• OCR için yüklediğiniz fotoğraflar\n'
              '• Kamera ile çekilen görüntüler',
            ),
            _buildSection(
              '2. Bilgilerin Kullanımı',
              'Topladığımız bilgileri şu amaçlarla kullanırız:\n\n'
              '• Hizmet sunmak ve geliştirmek\n'
              '• Hesabınızı yönetmek\n'
              '• Sorularınızı yanıtlamak\n'
              '• Kullanıcı deneyimini iyileştirmek\n'
              '• Teknik destek sağlamak\n'
              '• Güvenlik ve dolandırıcılık önleme\n'
              '• Yasal yükümlülükleri yerine getirmek',
            ),
            _buildSection(
              '3. Üçüncü Taraf Hizmetler',
              'Uygulamada şu üçüncü taraf hizmetleri kullanılmaktadır:\n\n'
              '3.1. Yapay Zeka Sağlayıcıları:\n'
              '• Groq (Llama modelleri)\n'
              '• Google Gemini\n'
              '• OpenAI (opsiyonel)\n'
              '• Anthropic Claude (opsiyonel)\n\n'
              'Bu hizmetler, sorularınızı işlemek için kullanılır. Her hizmetin kendi gizlilik politikası vardır.\n\n'
              '3.2. Veritabase Hizmeti:\n'
              '• NeonDB (PostgreSQL)\n'
              '• Verileriniz şifrelenmiş olarak saklanır\n\n'
              '3.3. Hosting:\n'
              '• Render.com (Backend sunucu)',
            ),
            _buildSection(
              '4. Veri Güvenliği',
              'Verilerinizi korumak için şu önlemleri alıyoruz:\n\n'
              '• SSL/TLS şifreleme\n'
              '• Şifrelerin hash\'lenerek saklanması\n'
              '• Güvenli veritabanı bağlantıları\n'
              '• Düzenli güvenlik güncellemeleri\n'
              '• Erişim kontrolü ve yetkilendirme\n\n'
              'Ancak, internet üzerinden veri iletiminin %100 güvenli olmadığını unutmayın.',
            ),
            _buildSection(
              '5. Veri Saklama',
              'Verileriniz şu sürelerde saklanır:\n\n'
              '• Hesap bilgileri: Hesap silinene kadar\n'
              '• Soru geçmişi: Hesap silinene kadar\n'
              '• Görüntüler: İşlendikten sonra silinir\n'
              '• Log kayıtları: 30 gün\n\n'
              'Hesabınızı sildiğinizde, tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.',
            ),
            _buildSection(
              '6. Çocukların Gizliliği',
              'Uygulamamız 13 yaş ve üzeri kullanıcılar içindir. 13 yaşından küçük çocuklardan bilerek veri toplamıyoruz. Eğer 13 yaşından küçük bir çocuğun veri sağladığını fark ederseniz, lütfen bizimle iletişime geçin.',
            ),
            _buildSection(
              '7. Haklarınız',
              'KVKK ve GDPR kapsamında şu haklara sahipsiniz:\n\n'
              '• Verilerinize erişim hakkı\n'
              '• Verilerin düzeltilmesini isteme\n'
              '• Verilerin silinmesini isteme\n'
              '• Veri işlemeye itiraz etme\n'
              '• Veri taşınabilirliği\n'
              '• Otomatik karar alma süreçlerine itiraz\n\n'
              'Bu haklarınızı kullanmak için support@kiwo.app adresine email gönderebilirsiniz.',
            ),
            _buildSection(
              '8. Çerezler ve İzleme',
              'Uygulama şu verileri cihazınızda saklar:\n\n'
              '• Oturum token\'ı (JWT)\n'
              '• Kullanıcı tercihleri (tema, dil)\n'
              '• Önbellek verileri\n\n'
              'Bu veriler yalnızca uygulama işlevselliği için kullanılır.',
            ),
            _buildSection(
              '9. Veri Paylaşımı',
              'Kişisel verilerinizi şu durumlar dışında üçüncü taraflarla paylaşmıyoruz:\n\n'
              '• Yasal zorunluluklar\n'
              '• Mahkeme kararları\n'
              '• Güvenlik tehditleri\n'
              '• Hizmet sağlayıcılar (yukarıda belirtilen)\n\n'
              'Verilerinizi asla pazarlama amacıyla satmıyoruz.',
            ),
            _buildSection(
              '10. Uluslararası Veri Transferi',
              'Verileriniz, sunucularımızın bulunduğu ülkelerde işlenebilir. Bu ülkeler:\n\n'
              '• Amerika Birleşik Devletleri (Render.com, Groq)\n'
              '• Avrupa Birliği (NeonDB)\n\n'
              'Tüm transferler uygun güvenlik önlemleriyle yapılır.',
            ),
            _buildSection(
              '11. Politika Değişiklikleri',
              'Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinde veya email ile bildirilecektir.',
            ),
            _buildSection(
              '12. İletişim',
              'Gizlilik ile ilgili sorularınız için:\n\n'
              'Email: support@kiwo.app\n'
              'Veri Sorumlusu: Melih Y.\n'
              'Adres: [Adres bilgisi]',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: AppTheme.success),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gizliliğiniz bizim için önemlidir. Verileriniz güvende.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
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
