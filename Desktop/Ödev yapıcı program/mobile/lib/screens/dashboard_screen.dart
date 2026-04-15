import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_question_card.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

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
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildHomeTab(user, questionProvider) : _buildProfileTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Geçmiş',
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
                QuickActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Kamera / Tarama',
                  color: const Color(0xFF9B7EDE),
                  onTap: () => _onQuickAction('camera'),
                ),
                QuickActionCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Kompozisyon Yaz',
                  color: const Color(0xFF4ECDC4),
                  onTap: () => _onQuickAction('kompozisyon'),
                ),
                QuickActionCard(
                  icon: Icons.calculate_rounded,
                  title: 'Matematik Çöz',
                  color: const Color(0xFFFF6B9D),
                  onTap: () => _onQuickAction('matematik'),
                ),
                QuickActionCard(
                  icon: Icons.translate_rounded,
                  title: 'Çeviri Yap',
                  color: const Color(0xFF4A90E2),
                  onTap: () => _onQuickAction('ceviri'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
