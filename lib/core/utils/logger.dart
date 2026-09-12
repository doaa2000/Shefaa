import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static Future<void> log(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/log.txt');

      final now = DateTime.now();
      final timestamp = now.toIso8601String();
      await file.writeAsString("[$timestamp] $message\n",
          mode: FileMode.append);
    } catch (e) {
      // The logger failing is not worth crashing over, but swallowing it
      // silently means never finding out the log file was never written.
      debugPrint('AppLogger could not write: $e');
    }
  }
}
