import 'dart:convert';
import 'dart:io';

class LaserStore {
  static const String _filePath = '.dart_tool/build_laser_cache.json';

  int lastDurationMillis;
  int lastActionCount;

  LaserStore({this.lastDurationMillis = 0, this.lastActionCount = 0});

  bool get hasData => lastDurationMillis > 0 && lastActionCount > 0;

  static Future<LaserStore> load() async {
    final file = File(_filePath);
    if (await file.exists()) {
      try {
        final jsonString = await file.readAsString();
        final map = jsonDecode(jsonString);
        return LaserStore(
          lastDurationMillis: map['duration'] ?? 0,
          lastActionCount: map['actions'] ?? 0,
        );
      } catch (_) {}
    }
    return LaserStore();
  }

  Future<void> save(int durationMillis, int actionCount) async {
    final file = File(_filePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    final map = {
      'duration': durationMillis,
      'actions': actionCount,
    };

    await file.writeAsString(jsonEncode(map));
  }
}
