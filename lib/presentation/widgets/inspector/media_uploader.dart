import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../data/models/media_file.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Media Uploader Widget
class MediaUploader extends ConsumerStatefulWidget {
  final int eventId;
  final Function(MediaFile) onMediaAdded;

  const MediaUploader({
    super.key,
    required this.eventId,
    required this.onMediaAdded,
  });

  @override
  ConsumerState<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends ConsumerState<MediaUploader> {
  final ImagePicker _picker = ImagePicker();
  final List<MediaFile> _mediaFiles = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Medya Dosyaları',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _isUploading ? null : _showUploadOptions,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              tooltip: 'Medya Ekle',
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Media Grid
        if (_mediaFiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Henüz medya eklenmemiş',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fotoğraf veya dosya eklemek için + butonuna tıklayın',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _mediaFiles.length,
            itemBuilder: (context, index) {
              final media = _mediaFiles[index];
              return _buildMediaThumbnail(media);
            },
          ),

        if (_isUploading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildMediaThumbnail(MediaFile media) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media.isImage && media.path.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(media.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 32),
                  );
                },
              ),
            )
          else
            Center(
              child: Icon(
                _getFileIcon(media.type),
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => _deleteMedia(media),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Dosya'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isUploading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > AppConstants.maxFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dosya çok büyük (max 10MB)')),
            );
          }
          return;
        }

        final media = MediaFile.create(
          path: image.path,
          type: 'image',
          fileName: image.name,
          fileSizeBytes: fileSize,
          eventId: widget.eventId,
        );

        setState(() {
          _mediaFiles.add(media);
        });

        widget.onMediaAdded(media);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf eklendi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFile() async {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dosya seçici yakında eklenecek')),
    );
  }

  void _deleteMedia(MediaFile media) {
    setState(() {
      _mediaFiles.remove(media);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medya silindi')),
    );
  }
}
