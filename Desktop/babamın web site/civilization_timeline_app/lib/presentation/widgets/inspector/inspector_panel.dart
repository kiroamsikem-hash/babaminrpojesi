import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/period_event.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/providers/database_provider.dart';
import '../../../domain/providers/graph_provider.dart';
import 'media_uploader.dart';
import 'link_selector.dart';

/// Inspector Panel - Right sidebar for event details
class InspectorPanel extends ConsumerStatefulWidget {
  final PeriodEvent event;
  final VoidCallback onClose;

  const InspectorPanel({
    super.key,
    required this.event,
    required this.onClose,
  });

  @override
  ConsumerState<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends ConsumerState<InspectorPanel> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.inspectorWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Olay Detayları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year Info
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Yıl',
                    content: 'M.Ö. ${widget.event.startYear.abs()}',
                  ),
                  const SizedBox(height: 16),

                  // Period Info
                  if (widget.event.period != null)
                    _buildInfoCard(
                      icon: Icons.history,
                      title: 'Dönem',
                      content: widget.event.period!,
                    ),
                  const SizedBox(height: 16),

                  // Title Editor
                  const Text(
                    'Başlık',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Olay başlığı...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Description Editor
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Detaylı açıklama ekleyin...',
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 24),

                  // Media Section
                  MediaUploader(
                    eventId: widget.event.id,
                    onMediaAdded: (media) {
                      // Handle media added
                    },
                  ),
                  const SizedBox(height: 24),

                  // Connections Section
                  _buildConnectionsSection(),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Değişiklikleri Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return MediaUploader(
      eventId: widget.event.id,
      onMediaAdded: (media) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medya eklendi')),
        );
      },
    );
  }

  Widget _buildConnectionsSection() {
    final connectionsAsync = ref.watch(
      connectionsForEntityProvider((
        id: widget.event.id,
        type: EntityTypes.event,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Bağlantılar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => LinkSelector(
                    sourceId: widget.event.id,
                    sourceType: EntityTypes.event,
                    onConnectionCreated: (connection) {
                      ref.invalidate(connectionsForEntityProvider);
                    },
                  ),
                );
              },
              icon: const Icon(Icons.link, size: 18),
              label: const Text('Bağla'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        connectionsAsync.when(
          data: (connections) {
            if (connections.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Henüz bağlantı oluşturulmamış',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              );
            }

            return Column(
              children: connections.map((connection) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ConnectionTypes.getColor(connection.connectionType),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: ConnectionTypes.getColor(connection.connectionType),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ConnectionTypes.getLabel(connection.connectionType),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            if (connection.label != null)
                              Text(
                                connection.label!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () => _deleteConnection(connection.id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Hata'),
        ),
      ],
    );
  }

  Future<void> _deleteConnection(int connectionId) async {
    try {
      final repo = ref.read(connectionRepositoryProvider);
      await repo.delete(connectionId);
      ref.invalidate(connectionsForEntityProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı silindi')),
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

  Future<void> _saveChanges() async {
    try {
      final repo = ref.read(eventRepositoryProvider);
      
      widget.event.title = _titleController.text;
      widget.event.description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;
      
      await repo.update(widget.event);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değişiklikler kaydedildi')),
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
}
