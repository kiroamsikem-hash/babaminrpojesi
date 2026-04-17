import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/period_event.dart';
import '../../../domain/providers/timeline_provider.dart';
import '../../../domain/providers/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Link Selector Widget - Create connections between entities
class LinkSelector extends ConsumerStatefulWidget {
  final int sourceId;
  final String sourceType;
  final Function(Connection) onConnectionCreated;

  const LinkSelector({
    super.key,
    required this.sourceId,
    required this.sourceType,
    required this.onConnectionCreated,
  });

  @override
  ConsumerState<LinkSelector> createState() => _LinkSelectorState();
}

class _LinkSelectorState extends ConsumerState<LinkSelector> {
  String _selectedConnectionType = ConnectionTypes.similar;
  PeriodEvent? _selectedEvent;
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.link, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text(
                  'Bağlantı Oluştur',
                  style: TextStyle(
                    fontSize: 20,
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
            const SizedBox(height: 24),

            // Connection Type
            DropdownButtonFormField<String>(
              initialValue: _selectedConnectionType,
              decoration: const InputDecoration(
                labelText: 'Bağlantı Tipi',
                prefixIcon: Icon(Icons.category),
              ),
              items: ConnectionTypes.all.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: ConnectionTypes.getColor(type),
                      ),
                      const SizedBox(width: 8),
                      Text(ConnectionTypes.getLabel(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedConnectionType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Target Event Selector
            eventsAsync.when(
              data: (events) {
                // Filter out source event
                final filteredEvents = events
                    .where((e) => e.id != widget.sourceId)
                    .toList();

                return DropdownButtonFormField<PeriodEvent>(
                  initialValue: _selectedEvent,
                  decoration: const InputDecoration(
                    labelText: 'Hedef Olay',
                    prefixIcon: Icon(Icons.event),
                  ),
                  items: filteredEvents.map((event) {
                    return DropdownMenuItem(
                      value: event,
                      child: Text(
                        '${event.title} (M.Ö. ${event.startYear.abs()})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedEvent = value);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Hata'),
            ),
            const SizedBox(height: 16),

            // Label
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Etiket (Opsiyonel)',
                hintText: 'Örn: Benzer seramik tipi',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                hintText: 'Bağlantı hakkında detaylı bilgi...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _selectedEvent != null ? _createConnection : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createConnection() async {
    if (_selectedEvent == null) return;

    try {
      final repo = ref.read(connectionRepositoryProvider);

      final connection = Connection.create(
        sourceId: widget.sourceId,
        targetId: _selectedEvent!.id,
        sourceType: widget.sourceType,
        targetType: EntityTypes.event,
        connectionType: _selectedConnectionType,
        label: _labelController.text.isEmpty ? null : _labelController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        strength: 5,
      );

      await repo.create(connection);

      widget.onConnectionCreated(connection);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı oluşturuldu')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  /// Show link selector dialog
  static Future<void> show(
    BuildContext context,
    int sourceId,
    String sourceType,
    Function(Connection) onConnectionCreated,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => LinkSelector(
        sourceId: sourceId,
        sourceType: sourceType,
        onConnectionCreated: onConnectionCreated,
      ),
    );
  }
}
