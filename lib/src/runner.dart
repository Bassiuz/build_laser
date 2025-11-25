import 'dart:convert';
import 'dart:io';

import 'parser.dart';
import 'printer.dart';
import 'store.dart';

class BuildLaserRunner {
  static Future<void> run(List<String> args) async {
    final printer = LaserPrinter();

    // 1. Load Store (Previous run data)
    final store = await LaserStore.load();

    final parser = BuildParser(printer, store);

    List<String> processArgs = ['run', 'build_runner'];
    if (args.isEmpty) {
      processArgs.addAll(['build', '--delete-conflicting-outputs']);
    } else {
      processArgs.addAll(args);
    }

    printer.printStart('dart ${processArgs.join(' ')}');

    parser.start();

    final process = await Process.start(
      'dart',
      processArgs,
      runInShell: true,
    );

    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      parser.parseLine(line);
    });

    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      stdout.write('\x1B[2K\r');
      print('\x1B[31m[ERR] $line\x1B[0m');
    });

    final exitCode = await process.exitCode;

    parser.stop();

    // 2. Save Metrics for next time (if successful)
    if (exitCode == 0 && parser.currentActionCount > 0) {
      await store.save(parser.currentDurationMillis, parser.currentActionCount);
    }

    printer.printSummary('', parser.warnings, exitCode);
    exit(exitCode);
  }
}
