import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/theme_v2.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_question_card.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'video_lab_screen.dart';
import 'flashcard_screen.dart';
import 'study_planner_screen.dart';
import 'socratic_mode_screen.dart';
import 'graph_screen.dart';
import 'history_screen.dart';
import 'premium_screen.dart';
import 'admin_panel_screen.dart';
import 'page_scan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentQuestions();
  }

  Future<void> _loadRecentQuestions() async {
    await context.read<QuestionProvider>().fetchQuestions();
  }

  void _onQuickAction(String type) {
    if (type == 'camera') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(questionType: type),
        ),
      );
    }
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          questionType: 'genel',
          initialQuestion: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final user = authProvider.user;

    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildHomeTab(user, questionProvider);
        break;
      case 1:
        currentScreen = const ProfileScreen();
        break;
      case 2:
        currentScreen = const HistoryScreen();
        break;
      default:
        currentScreen = _buildHomeTab(user, questionProvider);
    }

    return Scaffold(
      body: SafeArea(child: currentScreen),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: languageProvider.translate('dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: languageProvider.translate('profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_rounded),
            label: languageProvider.currentLanguage == 'tr' ? 'Geçmiş' : 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(user, QuestionProvider questionProvider) {
    return RefreshIndicator(
      onRefresh: _loadRecentQuestions,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            title: const Text('Ödev Asistanı'),
            actions: [
              // Premium Button
              IconButton(
                icon: const Icon(Icons.star_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
                tooltip: 'Premium',
              ),
              // Admin Button (only for admin users)
              if (user?.email == 'byazar1628@gmail.com' || user?.email == 'myazar483@gmail.com')
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                    );
                  },
                  tooltip: 'Admin Panel',
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Header Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba, ${user?.name ?? 'Elif'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearchSubmit,
                      decoration: InputDecoration(
                        hintText: 'Bugün ne öğrenmek istersin?',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildMinimalistCard(
                  icon: Icons.document_scanner_rounded,
                  title: 'Sayfa Tara',
                  emoji: '📄',
                  color: const Color(0xFF5C6BC0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PageScanScreen()),
                    );
                  },
                ),
                _buildMinimalistCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Fotoğraf Çek',
                  emoji: '📸',
                  color: QuietTechColors.cardPurple,
                  onTap: () => _onQuickAction('camera'),
                ),
                _buildMinimalistCard(
                  icon: Icons.calculate_rounded,
                  title: 'Matematik',
                  emoji: '🔢',
                  color: QuietTechColors.cardOrange,
                  onTap: () => _onQuickAction('matematik'),
                ),
                _buildMinimalistCard(
                  icon: Icons.translate_rounded,
                  title: 'Çeviri',
                  emoji: '🌍',
                  color: QuietTechColors.cardBlue,
                  onTap: () => _onQuickAction('ceviri'),
                ),
                _buildMinimalistCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Kompozisyon',
                  emoji: '✍️',
                  color: QuietTechColors.cardGreen,
                  onTap: () => _onQuickAction('kompozisyon'),
                ),
                _buildMinimalistCard(
                  icon: Icons.video_library_rounded,
                  title: 'Video Lab',
                  emoji: '🎬',
                  color: QuietTechColors.cardPink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VideoLabScreen()),
                    );
                  },
                ),
                _buildMinimalistCard(
                  icon: Icons.style_rounded,
                  title: 'Akıllı Kartlar',
                  emoji: '🎴',
                  color: QuietTechColors.cardTeal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FlashcardScreen()),
                    );
                  },
                ),
                _buildMinimalistCard(
                  icon: Icons.event_note_rounded,
                  title: 'Çalışma Planı',
                  emoji: '🎯',
                  color: QuietTechColors.cardRed,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudyPlannerScreen()),
                    );
                  },
                ),
                _buildMinimalistCard(
                  icon: Icons.psychology_rounded,
                  title: 'Sokratik Öğrenme',
                  emoji: '🤔',
                  color: const Color(0xFF7E57C2),
                  onTap: () {
                    _showSocraticDialog();
                  },
                ),
                _buildMinimalistCard(
                  icon: Icons.show_chart_rounded,
                  title: 'Grafik Çizim',
                  emoji: '📊',
                  color: const Color(0xFF26A69A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GraphScreen()),
                    );
                  },
                ),
              ]),
            ),
          ),

          // Recent Questions Header
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Son Etkinlikler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Recent Questions List
          if (questionProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (questionProvider.questions.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Henüz soru çözmediniz\nYukarıdaki butonlardan başlayın!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final question = questionProvider.questions[index];
                    return RecentQuestionCard(
                      question: question,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              questionType: question.type,
                              existingQuestion: question,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: questionProvider.questions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
  }

  void _showSocraticDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤔 Sokratik Öğrenme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Direkt cevap vermiyorum! Seni düşündürerek öğretiyorum.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Sorunuzu yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SocraticModeScreen(
                      question: controller.text.trim(),
                    ),
                  ),
                );
              }
            },
            child: const Text('Başla'),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistCard({
    required IconData icon,
    required String title,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [QuietTechColors.softShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
