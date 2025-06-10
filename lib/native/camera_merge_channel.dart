import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class CameraMergeChannel {
  static const MethodChannel _channel = MethodChannel('camera_merge_channel');
  static final Logger _logger = Logger(); // Для логов

  /// Merges videos using native Swift method.
  /// Returns the merged video file path, or null if failed.
  static Future<String?> mergeVideos(List<String> filePaths) async {
    try {
      _logger.i("📤 Sending video segments to native: $filePaths");
      final result = await _channel.invokeMethod<String>('mergeVideos', filePaths);
      _logger.i("✔️ Video merged successfully: $result");
      return result;
    } on PlatformException catch (e) {
      _logger.e("❌ Error calling native method: ${e.message}");
      return null;
    }
  }
}
