import 'dart:ui' show FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FramePerformanceLogger {
  FramePerformanceLogger._();

  static const bool _perfLogEnabled = bool.fromEnvironment(
    'PERF_LOG',
    defaultValue: false,
  );
  static final FramePerformanceLogger instance = FramePerformanceLogger._();

  bool _started = false;
  int _sampleCount = 0;
  int _over16ms = 0;
  int _over32ms = 0;
  Duration _worstBuild = Duration.zero;
  Duration _worstRaster = Duration.zero;

  bool get _isEnabled =>
      _perfLogEnabled && (kDebugMode || kProfileMode) && !kReleaseMode;

  void start() {
    if (!_isEnabled || _started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_started) {
      return;
    }

    for (final timing in timings) {
      _sampleCount += 1;

      final build = timing.buildDuration;
      final raster = timing.rasterDuration;
      final total = timing.totalSpan;

      if (build > _worstBuild) {
        _worstBuild = build;
      }
      if (raster > _worstRaster) {
        _worstRaster = raster;
      }
      if (total > const Duration(milliseconds: 16)) {
        _over16ms += 1;
      }
      if (total > const Duration(milliseconds: 32)) {
        _over32ms += 1;
      }
    }

    if (_sampleCount >= 120) {
      debugPrint(
        '[PERF] frames=$_sampleCount '
        'worstBuild=${_worstBuild.inMilliseconds}ms '
        'worstRaster=${_worstRaster.inMilliseconds}ms '
        '>16ms=$_over16ms '
        '>32ms=$_over32ms',
      );
      _sampleCount = 0;
      _over16ms = 0;
      _over32ms = 0;
      _worstBuild = Duration.zero;
      _worstRaster = Duration.zero;
    }
  }
}
