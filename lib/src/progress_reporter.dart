import 'dart:async';

/// Reports progress of asset optimization.
class ProgressReporter {
  /// Creates a new [ProgressReporter].
  ProgressReporter() {
    _progressController = StreamController<ProgressUpdate>.broadcast();
  }

  late final StreamController<ProgressUpdate> _progressController;
  int _total = 0;
  int _current = 0;
  final List<String> _errors = [];

  /// Stream of progress updates.
  Stream<ProgressUpdate> get progress => _progressController.stream;

  /// Starts progress reporting with the given total.
  void start(int total) {
    _total = total;
    _current = 0;
    _errors.clear();
    _emit();
  }

  /// Increments progress by one.
  void increment() {
    _current++;
    _emit();
  }

  /// Marks current item as skipped.
  void skip() {
    _current++;
    _emit();
  }

  /// Records an error for the given asset.
  void error(String asset, String message) {
    _errors.add('$asset: $message');
    _emit();
  }

  void _emit() {
    if (!_progressController.isClosed) {
      _progressController.add(
        ProgressUpdate(
          current: _current,
          total: _total,
          errors: List.unmodifiable(_errors),
        ),
      );
    }
  }

  /// Closes the progress stream.
  void dispose() {
    _progressController.close();
  }
}

/// Represents a progress update.
class ProgressUpdate {
  /// Creates a new [ProgressUpdate].
  const ProgressUpdate({
    required this.current,
    required this.total,
    required this.errors,
  });

  /// Current number of processed items.
  final int current;

  /// Total number of items to process.
  final int total;

  /// List of errors encountered.
  final List<String> errors;

  /// Progress as a percentage (0-100).
  double get percentage => (current / total) * 100;
}
