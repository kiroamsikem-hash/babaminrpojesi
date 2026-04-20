import 'package:flutter/material.dart';
import 'dart:async';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../models/study_session_model.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final ApiService _apiService = ApiService();
  List<StudySession> _sessions = [];
  bool _isLoading = true;
  Map<String, dynamic>? _todayStats;
  
  // Timer state
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  StudySession? _activeTimerSession;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sessionsResponse = await _apiService.getActiveSessions();
      final statsResponse = await _apiService.getTodayStats();

      if (sessionsResponse['success']) {
        setState(() {
          _sessions = (sessionsResponse['data'] as List)
              .map((json) => StudySession.fromJson(json))
              .toList();
          _todayStats = statsResponse['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(sessionsResponse['message'] ?? 'Veriler yüklenemedi');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer(StudySession session, int minutes) {
    setState(() {
      _remainingSeconds = minutes * 60;
      _isTimerRunning = true;
      _activeTimerSession = session;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer(autoComplete: true);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer(autoComplete: true);
      }
    });
  }

  Future<void> _stopTimer({bool autoComplete = false}) async {
    _timer?.cancel();
    
    if (_activeTimerSession != null && _remainingSeconds < (_activeTimerSession!.dailyGoal * 60)) {
      // Çalışılan süreyi hesapla
      final studiedMinutes = ((_activeTimerSession!.dailyGoal * 60) - _remainingSeconds) ~/ 60;
      
      if (studiedMinutes > 0) {
        try {
          await _apiService.updateStudyProgress(_activeTimerSession!.id, studiedMinutes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(autoComplete 
                    ? '🎉 Tebrikler! $studiedMinutes dakika tamamlandı!'
                    : '✅ $studiedMinutes dakika kaydedildi!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Hata gösterme
        }
      }
    }

    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
      _activeTimerSession = null;
    });

    _loadData();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Çalışma Planlayıcı'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Timer Widget (if active)
                if (_activeTimerSession != null) _buildTimerWidget(),
                
                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildTodayStats(),
                          _buildSessionsList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _activeTimerSession == null
          ? FloatingActionButton.extended(
              onPressed: _showCreateSessionDialog,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Hedef'),
            )
          : null,
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _activeTimerSession!.subject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isTimerRunning)
                ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Duraklat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _resumeTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Devam Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _stopTimer(autoComplete: false),
                icon: const Icon(Icons.stop),
                label: const Text('Bitir'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    final minutesToday = int.parse(_todayStats?['minutes_today']?.toString() ?? '0');
    final activeSessions = int.parse(_todayStats?['active_sessions']?.toString() ?? '0');
    final goalsMet = int.parse(_todayStats?['goals_met']?.toString() ?? '0');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bugünkü İlerleme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('⏱️', '$minutesToday dk', 'Çalışma'),
              _buildStatItem('🎯', '$activeSessions', 'Aktif Hedef'),
              _buildStatItem('✅', '$goalsMet', 'Tamamlanan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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

  Widget _buildSessionsList() {
    if (_sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz çalışma hedefi yok',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni hedef eklemek için + butonuna tıklayın',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(StudySession session) {
    final daysRemaining = session.daysRemaining;
    final progress = session.progressPercentage;
    final isActiveTimer = _activeTimerSession?.id == session.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isActiveTimer ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.book, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysRemaining > 0
                            ? '$daysRemaining gün kaldı'
                            : daysRemaining == 0
                                ? 'Bugün!'
                                : '${-daysRemaining} gün geçti',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysRemaining < 0 ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isActiveTimer)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                        onPressed: () => _showEditSessionDialog(session),
                        tooltip: 'Düzenle',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _showDeleteDialog(session),
                        tooltip: 'Sil',
                      ),
                      IconButton(
                        icon: const Icon(Icons.timer, color: AppColors.primary),
                        onPressed: () => _showTimerDialog(session),
                        tooltip: 'Zamanlayıcı Başlat',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bugünkü Hedef',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            '${session.completedToday} / ${session.dailyGoal} dk',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 100 ? Colors.green : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                session.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditSessionDialog(StudySession session) {
    final subjectController = TextEditingController(text: session.subject);
    final notesController = TextEditingController(text: session.notes);
    DateTime selectedDate = session.targetDate is String 
        ? DateTime.parse(session.targetDate as String)
        : session.targetDate as DateTime;
    int dailyGoal = session.dailyGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Hedef Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Konu / Ders',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Hedef Tarih'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Günlük Hedef:'),
                    const Spacer(),
                    Text('$dailyGoal dk', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                  value: dailyGoal.toDouble(),
                  min: 15,
                  max: 240,
                  divisions: 15,
                  label: '$dailyGoal dk',
                  onChanged: (value) {
                    setDialogState(() => dailyGoal = value.toInt());
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar (Opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty) return;

                try {
                  // TODO: Backend'e güncelleme isteği gönder
                  // await _apiService.updateStudySession(...)
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Hedef güncellendi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(StudySession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedefi Sil'),
        content: Text('${session.subject} hedefini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteStudySession(session.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Hedef silindi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showTimerDialog(StudySession session) {
    int minutes = session.dailyGoal - session.completedToday;
    if (minutes <= 0) minutes = 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('⏱️ Zamanlayıcı Başlat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.subject,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Text(
                '$minutes dakika',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Slider(
                value: minutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '$minutes dk',
                onChanged: (value) {
                  setDialogState(() => minutes = value.toInt());
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
              onPressed: () {
                Navigator.pop(context);
                _startTimer(session, minutes);
              },
              child: const Text('Başlat'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionDialog() {
    final subjectController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    int dailyGoal = 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Çalışma Hedefi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Konu / Ders',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Hedef Tarih'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Günlük Hedef:'),
                    const Spacer(),
                    Text('$dailyGoal dk', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                  value: dailyGoal.toDouble(),
                  min: 15,
                  max: 240,
                  divisions: 15,
                  label: '$dailyGoal dk',
                  onChanged: (value) {
                    setDialogState(() => dailyGoal = value.toInt());
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar (Opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty) return;

                try {
                  await _apiService.createStudySession(
                    subject: subjectController.text.trim(),
                    targetDate: selectedDate.toIso8601String(),
                    dailyGoal: dailyGoal,
                    notes: notesController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Hedef oluşturuldu!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
