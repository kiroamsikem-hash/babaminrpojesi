import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/graph/knowledge_graph.dart';
import '../../domain/providers/timeline_provider.dart';
import '../../core/constants/app_constants.dart';

/// Knowledge Graph Screen
class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEvent = ref.watch(selectedEventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgi Grafiği'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelp(context);
            },
            tooltip: 'Yardım',
          ),
        ],
      ),
      body: selectedEvent != null
          ? KnowledgeGraph(
              entityId: selectedEvent.id,
              entityType: EntityTypes.event,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bilgi Grafiği',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bir olay seçin',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Özellikler:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Node-based görselleştirme'),
                  const Text('• Bağlantı çizgileri'),
                  const Text('• İnteraktif node seçimi'),
                  const Text('• Otomatik layout algoritması'),
                ],
              ),
            ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bilgi Grafiği Yardım'),
        content: const Text(
          'Bilgi grafiği, olaylar, buluntular ve medeniyetler arasındaki '
          'ilişkileri görsel olarak gösterir.\n\n'
          'Timeline\'dan bir olay seçin ve Inspector panelinden bağlantılar ekleyin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
