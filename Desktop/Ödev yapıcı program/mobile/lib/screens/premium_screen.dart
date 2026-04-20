import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/theme.dart';
import '../services/api_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _packages = [];
  Map<String, dynamic>? _premiumStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Packages endpoint public, her zaman çalışır
      final packagesResponse = await _apiService.get('/premium/packages');
      
      // Status endpoint auth gerektirir, optional
      Map<String, dynamic>? statusData;
      try {
        final statusResponse = await _apiService.get('/premium/status');
        statusData = statusResponse['data'];
      } catch (statusError) {
        print('Premium status error (ignored): $statusError');
        // Status alınamazsa default değerler kullan
        statusData = {
          'isPremium': false,
          'premiumTier': 'free',
          'dailyLimit': 5,
          'usedToday': 0,
          'remainingToday': 5,
        };
      }

      if (mounted) {
        setState(() {
          _packages = packagesResponse['data'] ?? [];
          _premiumStatus = statusData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Premium data load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show detailed error
        String errorMessage = 'Veriler yüklenemedi';
        if (e.toString().contains('premium_packages')) {
          errorMessage = 'Premium sistem henüz kurulmamış. Lütfen migration çalıştırın.';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Paketleri görmek için giriş yapın.';
        } else {
          errorMessage = 'Hata: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Premium'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusCard(),
                  _buildPackagesList(),
                  _buildFeaturesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isPremium = _premiumStatus?['isPremium'] == true;
    final tier = _premiumStatus?['premiumTier'] ?? 'free';
    final dailyLimit = _premiumStatus?['dailyLimit'] ?? 5;
    final usedToday = _premiumStatus?['usedToday'] ?? 0;
    final remainingToday = _premiumStatus?['remainingToday'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [Colors.amber, Colors.orange]
              : [Colors.grey[400]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? Colors.amber : Colors.grey).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isPremium ? '⭐ Premium Üye' : '🆓 Ücretsiz Üye',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tier.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Günlük Limit', '$dailyLimit'),
              _buildStatItem('Kullanılan', '$usedToday'),
              _buildStatItem('Kalan', '$remainingToday'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Premium Paketler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._packages.map((pkg) => _buildPackageCard(pkg)).toList(),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg) {
    final name = pkg['name'] ?? '';
    final price = pkg['price'] ?? 0;
    final dailyLimit = pkg['daily_limit'] ?? 0;
    final features = pkg['features'] != null 
        ? (jsonDecode(pkg['features'].toString()) as List).cast<String>()
        : <String>[];

    Color color = Colors.orange;
    String emoji = '🥉';
    if (name == 'Standart') {
      color = Colors.purple;
      emoji = '🥈';
    } else if (name == 'Premium') {
      color = Colors.green;
      emoji = '🥇';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'Günlük $dailyLimit soru',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$price ₺',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '/ay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchasePackage(pkg),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Satın Al',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ Premium Ayrıcalıkları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('🚀', 'Daha fazla günlük soru hakkı'),
          _buildFeatureItem('🎯', 'Tüm özelliklere sınırsız erişim'),
          _buildFeatureItem('🎨', 'Reklamsız deneyim'),
          _buildFeatureItem('⚡', 'Öncelikli destek'),
          _buildFeatureItem('🤖', 'Gelişmiş AI modelleri'),
          _buildFeatureItem('📹', 'Sınırsız video analizi'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePackage(Map<String, dynamic> pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pkg['name']} Paketi'),
        content: Text(
          'Bu paketi ${pkg['price']} ₺ karşılığında satın almak istiyor musunuz?\n\n'
          'Not: Bu demo sürümünde ödeme simüle edilmektedir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.post('/premium/purchase', {
          'packageId': pkg['id'],
          'paymentMethod': 'demo',
          'transactionId': 'demo_${DateTime.now().millisecondsSinceEpoch}',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Premium satın alındı!'),
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
}
