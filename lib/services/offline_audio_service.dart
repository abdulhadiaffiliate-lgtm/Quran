import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'reciter_service.dart';

/// Manages offline audio availability for full-surah playback:
///  - A set of short surahs are bundled with the app (Mishary Alafasy
///    only), so they play instantly with zero network and zero wait.
///  - Any other surah can be downloaded on demand once, after which it
///    plays from local storage instead of streaming.
class OfflineAudioService {
  OfflineAudioService._();

  /// Surahs bundled offline (Alafasy only) — short surahs, mostly the
  /// final, shorter portion of the Quran. ~30-50MB total.
  static const Set<int> bundledSurahs = {
    1, 81, 82, 84, 85, 86, 87, 88, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
  };

  static const String _bundledReciter = 'ar.alafasy';

  static bool isBundled(int surahNumber, String reciterId) {
    return reciterId == _bundledReciter && bundledSurahs.contains(surahNumber);
  }

  static String _bundledAssetPath(int surahNumber) =>
      'assets/audio/surahs/$surahNumber.mp3';

  /// Returns the local file path for a downloaded surah, or null if it
  /// hasn't been downloaded.
  static Future<String?> getDownloadedPath(
      int surahNumber, String reciterId) async {
    final dir = await _downloadDir();
    final file = File('${dir.path}/${reciterId}_$surahNumber.mp3');
    if (await file.exists()) return file.path;
    return null;
  }

  static Future<Directory> _downloadDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/offline_audio');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns a playable source for the given surah: bundled asset path,
  /// downloaded local file path, or null if neither is available
  /// (caller should fall back to streaming the network URL).
  static Future<String?> getOfflineSource(
      int surahNumber, String reciterId) async {
    if (isBundled(surahNumber, reciterId)) {
      // Bundled assets need to be copied to a real file path the first
      // time, since the audio player needs a filesystem path, not an
      // asset bundle reference.
      final dir = await _downloadDir();
      final cachedFile = File('${dir.path}/bundled_$surahNumber.mp3');
      if (await cachedFile.exists()) return cachedFile.path;
      try {
        final bytes = await rootBundle.load(_bundledAssetPath(surahNumber));
        await cachedFile.writeAsBytes(bytes.buffer.asUint8List());
        return cachedFile.path;
      } catch (_) {
        return null;
      }
    }
    return getDownloadedPath(surahNumber, reciterId);
  }

  /// Downloads a surah's full audio for offline playback. Reports
  /// progress via [onProgress] (0.0 to 1.0, or null if size unknown).
  static Future<bool> downloadSurah(
    int surahNumber,
    String reciterId, {
    void Function(double? progress)? onProgress,
  }) async {
    try {
      final url = ReciterService.fullSurahUrl(reciterId, surahNumber);
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) return false;

      final dir = await _downloadDir();
      final file = File('${dir.path}/${reciterId}_$surahNumber.mp3');
      final sink = file.openWrite();

      final total = response.contentLength;
      int received = 0;

      await response.stream.listen((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null) {
          onProgress(total != null && total > 0 ? received / total : null);
        }
      }).asFuture();

      await sink.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDownloaded(int surahNumber, String reciterId) async {
    final path = await getDownloadedPath(surahNumber, reciterId);
    return path != null;
  }

  static Future<void> deleteDownload(int surahNumber, String reciterId) async {
    final dir = await _downloadDir();
    final file = File('${dir.path}/${reciterId}_$surahNumber.mp3');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
