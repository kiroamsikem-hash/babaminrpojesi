import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../data/models/civilization.dart';
import '../../../domain/providers/database_provider.dart';

/// Column (Civilization) Editor Dialog
class ColumnEditor extends ConsumerStatefulWidget {
  final Civilization? civilization;

  const ColumnEditor({super.key, this.civilization});

  @override
  ConsumerState<ColumnEditor> createState() => _ColumnEditorState();
}

class _ColumnEditorState extends ConsumerState<ColumnEditor> {
  late TextEditingController _nameController;
  late TextEditingController _regionController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  
  Color _selectedColor = Colors.blue;
  List<String> _tags = [];
  String? _photoPath;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.civilization?.name ?? '');
    _regionController = TextEditingController(text: widget.civilization?.region ?? '');
    _descriptionController = TextEditingController(text: widget.civilization?.description ?? '');
    _tagController = TextEditingController();
    
    if (widget.civilization != null) {
      _selectedColor = Color(widget.civilization!.colorValue);
      _tags = widget.civilization!.tags ?? [];
      _photoPath = widget.civilization!.photoPath;
      _photoUrl = widget.civilization!.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      // Request permission
      final status = await Permission.photos.request();
      
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf izni gerekli')),
          );
        }
        return;
      }

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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medeniyet adı gerekli')),
      );
      return;
    }

    final repo = ref.read(civilizationRepositoryProvider);
    
    final civilization = widget.civilization ?? Civilization();
    civilization.name = _nameController.text.trim();
    civilization.region = _regionController.text.trim();
    civilization.description = _descriptionController.text.trim();
    civilization.colorValue = _selectedColor.value;
    civilization.tags = _tags.isEmpty ? null : _tags;
    civilization.photoPath = _photoPath;
    civilization.photoUrl = _photoUrl;
    civilization.updatedAt = DateTime.now();
    
    if (widget.civilization == null) {
      civilization.createdAt = DateTime.now();
    }

    try {
      await repo.create(civilization);
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
                Icon(Icons.view_column, color: _selectedColor),
                const SizedBox(width: 12),
                Text(
                  widget.civilization == null ? 'Yeni Sütun' : 'Sütunu Düzenle',
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
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medeniyet Adı *',
                        hintText: 'Örn: Hitit, Miken, Batı Anadolu',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Region
                    TextField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        labelText: 'Bölge',
                        hintText: 'Örn: Anadolu, Yunanistan',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color Picker
                    const Text('Renk', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                        Colors.pink,
                        Colors.amber,
                        Colors.cyan,
                        Colors.indigo,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                              hintText: 'Etiket ekle (Örn: Saraylar, Ticaret)',
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
                        hintText: 'Medeniyet hakkında notlar...',
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
