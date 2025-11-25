import 'dart:async';

import 'printer.dart';
import 'store.dart';

class BuildParser {
  final LaserPrinter printer;
  final LaserStore? store; // Nullable if loading failed
  final List<String> warnings = [];

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _refreshTimer;

  int _actionCount = 0;
  bool _isRunning = false;

  // Regex
  final RegExp _progressRegex = RegExp(r'^\s*([\d\.]+[smh])\s+([a-zA-Z0-9_:-]+)\s+(.*)');
  final RegExp _warningRegex = RegExp(r'^W\s+(.*)');
  final RegExp _summaryRegex = RegExp(r'^Built\s+.*build_runner');

  BuildParser(this.printer, this.store);

  // Getters for Runner to save later
  int get currentDurationMillis => _stopwatch.elapsedMilliseconds;
  int get currentActionCount => _actionCount;

  void start() {
    _isRunning = true;
    _stopwatch.start();

    // Refresh UI every 100ms
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isRunning) {
        printer.printStatus(
          elapsed: _stopwatch.elapsed,
          currentActions: _actionCount,
          totalActions: store?.hasData == true ? store!.lastActionCount : null,
          totalTime:
              store?.hasData == true ? Duration(milliseconds: store!.lastDurationMillis) : null,
        );
      }
    });
  }

  void stop() {
    _isRunning = false;
    _stopwatch.stop();
    _refreshTimer?.cancel();
  }

  void parseLine(String line) {
    line = line.trimRight();
    if (line.isEmpty) return;

    if (_summaryRegex.hasMatch(line)) {
      stop();
      return;
    }

    final warningMatch = _warningRegex.firstMatch(line.trim());
    if (warningMatch != null) {
      String msg = warningMatch.group(1) ?? "";
      warnings.add(msg);
      printer.printWarning(msg);
      return;
    }

    final progressMatch = _progressRegex.firstMatch(line);
    if (progressMatch != null) {
      _actionCount++;
      final time = progressMatch.group(1)!;
      final builder = progressMatch.group(2)!;
      String rest = progressMatch.group(3)!;

      String context = '';
      if (rest.contains(';')) {
        final parts = rest.split(';');
        rest = parts.first;
        if (parts.length > 1) context = parts.last.trim();
      }

      printer.printTask(time, builder, rest, context);
      return;
    }

    if (!line.startsWith('[INFO]') && !line.startsWith('build_runner')) {
      printer.printGenericLog(line);
    }
  }
}
