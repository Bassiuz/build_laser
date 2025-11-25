import 'dart:io';

class LaserPrinter {
  // ANSI Colors
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _magenta = '\x1B[35m';

  // ANSI Cursor Controls
  static const String _clearLine = '\x1B[2K';
  static const String _moveUp = '\x1B[1A';
  static const String _moveToStart = '\r';

  // State to track if the status bar is currently drawn
  bool _statusBarVisible = false;

  // Spinner frames for indeterminate state
  final List<String> _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int _frameIndex = 0;

  void printStart(String command) {
    print('$_magenta$_bold⚡ LASER ACTIVATED $_reset');
    print('$_dim   Running: $command$_reset\n');
  }

  /// Removes the 2-line status bar if it exists, so we can print a log line safely
  void _clearStatus() {
    if (_statusBarVisible) {
      stdout.write(_moveToStart); // Start of line 2
      stdout.write(_clearLine); // Clear line 2
      stdout.write(_moveUp); // Go to line 1
      stdout.write(_clearLine); // Clear line 1
      stdout.write(_moveToStart); // Ready to write
      _statusBarVisible = false;
    }
  }

  void printTask(String time, String builder, String details, String context) {
    _clearStatus(); // Wipe the footer first

    if (time == '0s') return;

    bool isSlow = time.contains('m') || (int.tryParse(time.replaceAll('s', '')) ?? 0) > 10;
    String timeColor = isSlow ? _red : _cyan;

    stdout.writeln('$timeColor$_bold   $time$_reset  $_blue$builder$_reset $_dim$details$_reset');
    if (context.isNotEmpty) {
      stdout.writeln('       $_dim└─ $context$_reset');
    }
  }

  void printWarning(String warning) {
    _clearStatus();
    stdout.writeln('$_yellow$_bold W $_reset $_yellow$warning$_reset');
  }

  void printGenericLog(String line) {
    _clearStatus();
    stdout.writeln('$_dim   $line$_reset');
  }

  /// The Test-Laser style 2-line status bar
  void printStatus({
    required Duration elapsed,
    required int currentActions,
    required int? totalActions,
    required Duration? totalTime,
  }) {
    // If visible, move up to overwrite it. If not, just write.
    if (_statusBarVisible) {
      stdout.write(_moveUp);
    }

    // --- LINE 1: Info ---
    String actionsPart;
    if (totalActions != null && totalActions > 0) {
      actionsPart = '$_green$currentActions$_reset, Total: $totalActions';
    } else {
      actionsPart = '$_green$currentActions$_reset';
    }

    String timePart = _formatTime(elapsed);
    if (totalTime != null && totalTime.inSeconds > 0) {
      timePart += ' / ${_formatTime(totalTime)}';
    }

    // Construct Line 1: "Actions: 140, Total: 1516 | Time: 00:12 / 02:03"
    final line1 = '\r${_clearLine}Actions: $actionsPart $_dim|$_reset Time: $timePart';

    // --- LINE 2: Progress Bar ---
    String line2;
    if (totalActions != null && totalActions > 0) {
      // Determinate Mode
      double percent = (currentActions / totalActions).clamp(0.0, 1.0);
      int terminalWidth = 80; // Standard width safety
      try {
        terminalWidth = stdout.terminalColumns;
      } catch (_) {}

      // Calculate widths
      String percentStr = ' ${(percent * 100).toStringAsFixed(0)}%';
      int availableWidth = terminalWidth - percentStr.length - 2; // -2 for brackets []
      int filledWidth = (percent * availableWidth).round();
      int emptyWidth = availableWidth - filledWidth;

      String bar = '$_green${'█' * filledWidth}$_dim${'░' * emptyWidth}$_reset';
      line2 = '\r$_clearLine[$bar]$percentStr';
    } else {
      // Indeterminate Mode (Spinner)
      _frameIndex = (_frameIndex + 1) % _frames.length;
      String spinner = _frames[_frameIndex];
      line2 = '\r${_clearLine}[$_magenta $spinner $_reset] Calculating total...';
    }

    // PRINT IT
    stdout.writeln(line1); // Print Line 1 + Newline
    stdout.write(line2); // Print Line 2 (No newline, keeps cursor at end)

    _statusBarVisible = true;
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void printSummary(String summaryLine, List<String> collectedWarnings, int exitCode) {
    _clearStatus(); // Wipe the footer one last time
    print('\n$_dim${'-' * 60}$_reset');

    if (collectedWarnings.isNotEmpty) {
      print('\n$_yellow$_bold⚠️  WARNINGS SUMMARY (${collectedWarnings.length})$_reset');
      for (var w in collectedWarnings) {
        print('   $_yellow• $w$_reset');
      }
      print('');
    }

    if (exitCode == 0) {
      final timeReg = RegExp(r'in\s+([\d\.]+[smh])');
      final match = timeReg.firstMatch(summaryLine);
      final time = match?.group(1) ?? '';
      print('$_green$_bold✅  BUILD SUCCESSFUL $time$_reset');
    } else {
      print('$_red$_bold❌  BUILD FAILED (Exit Code: $exitCode)$_reset');
    }
    print('');
  }
}
