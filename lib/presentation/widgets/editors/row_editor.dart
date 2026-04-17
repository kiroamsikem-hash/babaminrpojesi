import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../data/models/period_event.dart';
import '../../../data/models/civilization.dart';
import '../../../domain/providers/database_provider.dart';

/// Row (Event) Editor Dialog
class RowEditor extends ConsumerStatefulWidget {
  final PeriodEvent? event;
  final List<Civilization> civilizations;

  const RowEditor({
    super.key,
    this.event,
    required this.civilizations,
  });

  @override
  ConsumerState<RowEditor> createState() => _RowEditorState();
}

class _RowEditorState extends ConsumerState<RowEditor> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startYearController;
  late TextEditingController _endYearController;
  late TextEditingController _periodController;
  late TextEditingController _tagController;
  
  int? _selectedCivilizationId;
  List<String> _tags = [];
  String? _photoPath;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _startYearController = TextEditingController(
      text: widget.event?.startYear.toString() ?? '',
    );
    _endYearController = TextEditingController(
      text: widget.event?.endYear?.toString() ?? '',
    );
    _periodController = TextEditingController(text: widget.event?.period ?? '');
    _tagController = TextEditingController();
    
    if (widget.event != null) {
      _selectedCivilizationId = widget.event!.civilizationId;
      _tags = widget.event!.tags ?? [];
      _photoPath = widget.event!.photoPath;
      _photoUrl = widget.event!.photoUrl;
    } else if (widget.civilizations.isNotEmpty) {
      _selectedCivilizationId = widget.civilizations.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _periodController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoPath = image.path;
          _photoUrl = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf seçildi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf seçme hatası: $e')),
        );
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Olay başlığı gerekli')),
      );
      return;
    }

    if (_startYearController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlangıç yılı gerekli')),
      );
      return;
    }

    final startYear = int.tryParse(_startYearController.text.trim());
    if (startYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir yıl girin')),
      );
      return;
    }

    final endYear = _endYearController.text.trim().isEmpty
        ? null
        : int.tryParse(_endYearController.text.trim());

    if (_selectedCivilizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medeniyet seçin')),
      );
      return;
    }

    final repo = ref.read(eventRepositoryProvider);
    
    final event = widget.event ?? PeriodEvent();
    event.title = _titleController.text.trim();
    event.description = _descriptionController.text.trim();
    event.startYear = startYear;
    event.endYear = endYear;
    event.civilizationId = _selectedCivilizationId!;
    event.period = _periodController.text.trim();
    event.tags = _tags.isEmpty ? null : _tags;
    event.photoPath = _photoPath;
    event.photoUrl = _photoUrl;
    event.updatedAt = DateTime.now();
    
    if (widget.event == null) {
      event.createdAt = DateTime.now();
      // Calculate grid position
      final civIndex = widget.civilizations
          .indexWhere((c) => c.id == _selectedCivilizationId);
      event.gridX = (civIndex + 1).toDouble();
      event.gridY = ((startYear + 3900) / 3400) * 100;
    }

    try {
      await repo.create(event);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.event, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  widget.event == null ? 'Yeni Satır' : 'Satırı Düzenle',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Olay Başlığı *',
                        hintText: 'Örn: Truva Savaşı, Saray İnşaatı',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Civilization
                    DropdownButtonFormField<int>(
                      value: _selectedCivilizationId,
                      decoration: const InputDecoration(
                        labelText: 'Medeniyet *',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: widget.civilizations.map((civ) {
                        return DropdownMenuItem(
                          value: civ.id,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(civ.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(civ.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCivilizationId = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Years
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Başlangıç Yılı (M.Ö.) *',
                              hintText: 'Örn: -1200',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Bitiş Yılı (M.Ö.)',
                              hintText: 'Opsiyonel',
                              prefixIcon: Icon(Icons.event_available),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Period
                    TextField(
                      controller: _periodController,
                      decoration: const InputDecoration(
                        labelText: 'Dönem',
                        hintText: 'Örn: Tunç Çağı, Demir Çağı',
                        prefixIcon: Icon(Icons.history),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photo
                    const Text('Fotoğraf', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_photoPath != null || _photoUrl != null)
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: _photoPath != null
                                    ? FileImage(File(_photoPath!)) as ImageProvider
                                    : NetworkImage(_photoUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () => setState(() {
                                _photoPath = null;
                                _photoUrl = null;
                              }),
                            ),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Fotoğraf Ekle'),
                      ),
                    const SizedBox(height: 16),

                    // Tags
                    const Text('Etiketler', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Etiket ekle (Örn: Savaş, Barış)',
                              prefixIcon: Icon(Icons.label),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Olay hakkında detaylar...',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),
            
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
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
