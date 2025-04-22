class PerformanceMonitor {
  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};

  void startOperation(String name) {
    _timers[name] = Stopwatch()..start();
  }

  void stopOperation(String name) {
    final timer = _timers.remove(name);
    if (timer != null) {
      timer.stop();
      _measurements.putIfAbsent(name, () => []).add(timer.elapsed);
    }
  }

  Map<String, Duration> getAverages() {
    return _measurements.map((key, values) {
      final total = values.reduce((a, b) => a + b);
      return MapEntry(
        key,
        Duration(microseconds: total.inMicroseconds ~/ values.length),
      );
    });
  }
}
