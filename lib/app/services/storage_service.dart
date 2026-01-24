import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:photo_gallery/modules/gallery/views/photo_session.dart';

class StoragePhotoService {
  static const String _sessionsFolder = 'sessions';

  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final sessionsDir = Directory(p.join(dir.path, _sessionsFolder));

    if (!sessionsDir.existsSync()) {
      sessionsDir.createSync(recursive: true);
    }

    return sessionsDir;
  }

  static Future<PhotoSession> createSession() async {
    final base = await _baseDir();
    final createdAt = DateTime.now();
    final folderName = createdAt.millisecondsSinceEpoch.toString();

    final sessionDir = Directory(p.join(base.path, folderName));
    sessionDir.createSync();

    return PhotoSession(
      folderPath: sessionDir.path,
      createdAt: createdAt,
      images: [],
    );
  }

  /// حفظ صورة داخل الجلسة
  static Future<File> saveImage(
    File image,
    PhotoSession session,
  ) async {
    final fileName =
        'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final savedImage = await image.copy(
      p.join(session.folderPath, fileName),
    );

    return savedImage;
  }

  /// تحميل كل الجلسات
  static Future<Map<DateTime, List<PhotoSession>>> loadSessions() async {
    final base = await _baseDir();
    final sessionDirs =
        base.listSync().whereType<Directory>().toList();

    Map<DateTime, List<PhotoSession>> grouped = {};

    for (final dir in sessionDirs) {
      final folderName = p.basename(dir.path);

      DateTime createdAt;
      try {
        createdAt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(folderName),
        );
      } catch (_) {
        continue;
      }

      final files =
          dir.listSync().whereType<File>().toList();

      if (files.isEmpty) continue;

      final dayKey = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
      );

      final session = PhotoSession(
        folderPath: dir.path,
        createdAt: createdAt,
        images: files,
      );

      grouped.putIfAbsent(dayKey, () => []);
      grouped[dayKey]!.add(session);
    }

    // ترتيب الجلسات داخل كل يوم
    for (final day in grouped.keys) {
      grouped[day]!.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }

    return grouped;
  }
}
