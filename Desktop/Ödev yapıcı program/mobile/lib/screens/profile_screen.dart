import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionProvider>().fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('Kullanıcı bulunamadı'));
    }

    final totalQuestions = questionProvider.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.isPremium
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isPremium 
                            ? '⭐ Premium ${user.premiumTier ?? ""}' 
                            : '🆓 Ücretsiz',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isPremium
                              ? AppTheme.success
                              : AppTheme.secondary,
                        ),
                      ),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '👑 Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // İstatistikler
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İstatistikler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Toplam Soru',
                      totalQuestions.toString(),
                      Icons.quiz_outlined,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Eğitim Seviyesi',
                      _getEducationLevelText(user.educationLevel),
                      Icons.school_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ayarlar
            Card(
              child: Column(
                children: [
                  _buildSettingTile(
                    'Profil Düzenle',
                    Icons.edit_outlined,
                    () => _showEditProfileDialog(context, authProvider),
                  ),
                  const Divider(height: 1),
                  _buildLanguageSelector(context),
                  const Divider(height: 1),
                  _buildThemeSwitcher(context),
                  const Divider(height: 1),
                  _buildSettingTile(
                    'Şifre Değiştir',
                    Icons.lock_outlined,
                    () => _showChangePasswordDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    'Hakkında',
                    Icons.info_outlined,
                    () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: AppTheme.textSecondary,
      ),
      title: const Text(
        'Karanlık Tema',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (_) => themeProvider.toggleTheme(),
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return ListTile(
      leading: const Icon(
        Icons.language,
        color: AppTheme.textSecondary,
      ),
      title: const Text(
        'Dil / Language',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: languageProvider.currentLanguage,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'tr', child: Text('🇹🇷 Türkçe')),
          DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
        ],
        onChanged: (value) {
          if (value != null) {
            languageProvider.setLanguage(value);
          }
        },
      ),
    );
  }

  String _getEducationLevelText(String level) {
    switch (level) {
      case 'ilkokul':
        return 'İlkokul';
      case 'ortaokul':
        return 'Ortaokul';
      case 'lise':
        return 'Lise';
      case 'universite':
        return 'Üniversite';
      default:
        return level;
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.user?.name);
    String selectedLevel = authProvider.user?.educationLevel ?? 'lise';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'İsim',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Eğitim Seviyesi',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'ilkokul', child: Text('İlkokul')),
                DropdownMenuItem(value: 'ortaokul', child: Text('Ortaokul')),
                DropdownMenuItem(value: 'lise', child: Text('Lise')),
                DropdownMenuItem(value: 'universite', child: Text('Üniversite')),
              ],
              onChanged: (value) {
                if (value != null) selectedLevel = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authProvider.updateProfile(
                name: nameController.text,
                educationLevel: selectedLevel,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Profil güncellendi' : 'Güncelleme başarısız',
                    ),
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre (Tekrar)',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifreler eşleşmiyor')),
                );
                return;
              }
              // TODO: Backend'e şifre değiştirme isteği gönder
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şifre değiştirme yakında eklenecek')),
              );
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödev Asistanı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'AI destekli ödev ve soru çözme uygulaması',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
