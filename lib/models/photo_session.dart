import 'dart:io';

class PhotoSession {
  final String folderPath;
  final DateTime createdAt;
  final List<File> images;

  PhotoSession({
    required this.folderPath,
    required this.createdAt,
    required this.images,
  });

  File? get coverImage => images.isNotEmpty ? images.first : null;
}
