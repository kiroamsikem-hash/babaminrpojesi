import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<dynamic> _users = [];
  List<dynamic> _packages = [];
  List<dynamic> _transactions = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usersResponse = await _apiService.get('/admin/users');
      final packagesResponse = await _apiService.get('/admin/packages');
      final transactionsResponse = await _apiService.get('/admin/transactions');
      final statsResponse = await _apiService.get('/admin/stats');

      if (mounted) {
        setState(() {
          _users = usersResponse['data'] ?? [];
          _packages = packagesResponse['data'] ?? [];
          _transactions = transactionsResponse['data'] ?? [];
          _stats = statsResponse['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Kullanıcılar'),
            Tab(text: 'İstatistikler'),
            Tab(text: 'İşlemler'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildStatsTab(),
                _buildTransactionsTab(),
              ],
            ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isPremium = user['is_premium'] == true;
          final premiumTier = user['premium_tier'] ?? 'free';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPremium ? Colors.amber : Colors.grey,
                child: Text(
                  user['name']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user['name'] ?? 'İsimsiz',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? ''),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPremium ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          premiumTier.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? Colors.amber[800] : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Limit: ${user['daily_limit'] ?? 5}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'grant_temel',
                    child: Text('🥉 Temel Ver'),
                  ),
                  const PopupMenuItem(
                    value: 'grant_standart',
                    child: Text('🥈 Standart Ver'),
                  ),
                  const PopupMenuItem(
                    value: 'grant_premium',
                    child: Text('🥇 Premium Ver'),
                  ),
                  if (isPremium)
                    const PopupMenuItem(
                      value: 'revoke',
                      child: Text('❌ Premium İptal'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('🗑️ Kullanıcıyı Sil'),
                  ),
                ],
                onSelected: (value) => _handleUserAction(value.toString(), user),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: Text('İstatistik yok'));
    }

    final userStats = _stats!['users'] ?? {};
    final revenueStats = _stats!['revenue'] ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard(
              '👥 Toplam Kullanıcı',
              userStats['total_users']?.toString() ?? '0',
              Colors.blue,
            ),
            _buildStatCard(
              '⭐ Premium Kullanıcı',
              userStats['premium_users']?.toString() ?? '0',
              Colors.amber,
            ),
            _buildStatCard(
              '🥉 Temel',
              userStats['temel_users']?.toString() ?? '0',
              Colors.orange,
            ),
            _buildStatCard(
              '🥈 Standart',
              userStats['standart_users']?.toString() ?? '0',
              Colors.purple,
            ),
            _buildStatCard(
              '🥇 Premium',
              userStats['premium_tier_users']?.toString() ?? '0',
              Colors.green,
            ),
            _buildStatCard(
              '📅 Bugün Kayıt',
              userStats['today_signups']?.toString() ?? '0',
              Colors.teal,
            ),
            const Divider(height: 32),
            _buildStatCard(
              '💰 Toplam Gelir',
              '${revenueStats['total_revenue'] ?? 0} ₺',
              Colors.green,
            ),
            _buildStatCard(
              '📊 Toplam İşlem',
              revenueStats['total_transactions']?.toString() ?? '0',
              Colors.indigo,
            ),
            _buildStatCard(
              '💵 Bugün Gelir',
              '${revenueStats['today_revenue'] ?? 0} ₺',
              Colors.lightGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          final amount = transaction['amount'] ?? 0;
          final packageName = transaction['package_name'] ?? '';
          final userName = transaction['user_name'] ?? '';
          final createdAt = transaction['created_at'] ?? '';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  '₺',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                '$userName - $packageName',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                createdAt.split('T')[0],
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '$amount ₺',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleUserAction(String action, Map<String, dynamic> user) async {
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kullanıcıyı Sil'),
          content: Text('${user['name']} kullanıcısını silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          await _apiService.delete('/admin/users/${user['id']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Kullanıcı silindi'),
                backgroundColor: Colors.green,
              ),
            );
            _loadData();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      return;
    }

    if (action == 'revoke') {
      try {
        await _apiService.delete('/admin/premium/revoke/${user['id']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Premium iptal edildi'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // Grant premium
    int packageId = 1;
    if (action == 'grant_standart') packageId = 2;
    if (action == 'grant_premium') packageId = 3;

    try {
      await _apiService.post('/admin/premium/grant', {
        'userId': user['id'],
        'packageId': packageId,
        'duration': 30,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Premium verildi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
