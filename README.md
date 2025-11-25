# Build Laser ⚡️

**A beautiful, readable, and intelligent wrapper for Dart's build_runner.**

Stop scrolling through thousands of lines of terminal noise. **Build Laser** parses your build output in real-time, hides the clutter, highlights the slow tasks, and gives you a precise progress bar based on historical performance.

## 📸 Screenshots

![Demo of Build Laser in action](https://raw.githubusercontent.com/bassiuz/build_laser/main/assets/screenshot.png)


| **Standard build_runner** | **Build Laser ⚡️** |
|:---:|:---:|
| ❌ Walls of text<br>❌ Hard to find errors<br>❌ "Log overflowed"<br>❌ No time estimate | ✅ **Live Progress Bar**<br>✅ **Smart Filtering** (hides <1s tasks)<br>✅ **Warning Summary** at the end<br>✅ **Time Estimation** |

## ✨ Features

* **⚡️ Noise Reduction:** Automatically hides tasks that take 0s, keeping your console clean.
* **📊 Live Progress Bar:** Learns from your previous builds to show a "Time Remaining" estimate and a visual progress bar.
* **⚠️ Warning Collector:** Captures W lines (warnings) and re-prints them in a summary at the end. No more missing deprecation warnings in the scroll-back.
* **🧹 Deep Clean:** A built-in command to nuke all generated files (.g.dart, .freezed.dart, etc.) and reset the cache.
* **⏱ Performance Insights:** Highlights slow builders in **Red** so you know what is slowing you down.

## 🚀 Installation

You can install it globally to use it in any project:

```bash
dart pub global activate build_laser
```

Or add it to your project as a dev dependency:

```bash
dart pub add --dev build_laser
```

## 🛠 Usage

### Standard Build
By default, running build_laser is equivalent to running dart run build_runner build --delete-conflicting-outputs.

```bash
build_laser
```

### Watch Mode
Pass any arguments you normally would. They are forwarded directly to build_runner.

```bash
build_laser watch
```

### Deep Clean
Delete all generated files (.g.dart, .freezed.dart, .hive.dart, etc.) and clear the build cache.

```bash
build_laser clean
```

## 🧠 How the Progress Bar Works

1. **First Run:** build_laser doesn't know how many tasks your project has, so it shows a **Spinner** (⠋) and a timer.
2. **Learning:** Upon successful completion, it saves your project's metrics (Total Actions & Total Time) to .dart_tool/build_laser_cache.json.
3. **Subsequent Runs:** It uses that cache to render a **Determinate Progress Bar** ([████░░] 60%) and estimates the remaining time.

## ❌ Handling Errors

If the build fails, build_laser will pass the exit code through (useful for CI/CD) and print the critical errors in **Red** so they stand out immediately.

## 🤝 Contributing

This package is intended to make the Flutter/Dart development experience smoother. PRs are welcome!