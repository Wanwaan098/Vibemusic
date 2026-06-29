import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';

class AlbumFormDialog extends StatefulWidget {
  final Album? initialAlbum;
  final Function(
    String title,
    String artistId,
    String coverUrl,
    int releaseYear,
  )
  onSubmit;

  const AlbumFormDialog({super.key, this.initialAlbum, required this.onSubmit});

  @override
  State<AlbumFormDialog> createState() => _AlbumFormDialogState();
}

class _AlbumFormDialogState extends State<AlbumFormDialog> {
  late TextEditingController titleController;
  late TextEditingController coverUrlController;
  late TextEditingController releaseYearController;
  String? selectedArtistId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.initialAlbum?.title ?? '',
    );
    coverUrlController = TextEditingController(
      text: widget.initialAlbum?.coverUrl ?? '',
    );
    releaseYearController = TextEditingController(
      text: widget.initialAlbum?.releaseYear.toString() ?? '',
    );
    selectedArtistId = widget.initialAlbum?.artistId;
  }

  @override
  void dispose() {
    titleController.dispose();
    coverUrlController.dispose();
    releaseYearController.dispose();
    super.dispose();
  }

  void _submit() {
    if (titleController.text.trim().isEmpty ||
        coverUrlController.text.trim().isEmpty ||
        releaseYearController.text.trim().isEmpty ||
        selectedArtistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      widget.onSubmit(
        titleController.text.trim(),
        selectedArtistId!,
        coverUrlController.text.trim(),
        int.parse(releaseYearController.text.trim()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initialAlbum == null ? 'Thêm Album' : 'Sửa Album',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Tên Album',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.album),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ArtistManagerProvider>(
              builder: (context, artistProvider, _) {
                if (artistProvider.artists.isEmpty) {
                  return const Text(
                    'Không có nghệ sĩ nào. Vui lòng thêm nghệ sĩ trước.',
                  );
                }
                return DropdownButtonFormField<String>(
                  value: selectedArtistId,
                  decoration: InputDecoration(
                    labelText: 'Chọn Nghệ sĩ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: artistProvider.artists
                      .map(
                        (artist) => DropdownMenuItem(
                          value: artist.id,
                          child: Text(artist.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedArtistId = value),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: coverUrlController,
              decoration: InputDecoration(
                labelText: 'URL Ảnh Album',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.image),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: releaseYearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Năm Phát Hành',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
