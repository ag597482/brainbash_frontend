import 'dart:async';

/// Precision timer for measuring response times in quizzes.
class TimerService {
  Stopwatch? _stopwatch;
  Timer? _periodicTimer;
  final StreamController<int> _controller = StreamController<int>.broadcast();

  /// Stream of elapsed milliseconds, updated every ~16ms (60fps).
  Stream<int> get elapsedStream => _controller.stream;

  /// Current elapsed time in milliseconds.
  int get elapsedMs => _stopwatch?.elapsedMilliseconds ?? 0;

  /// Whether the timer is currently running.
  bool get isRunning => _stopwatch?.isRunning ?? false;

  /// Start the timer from zero.
  void start() {
    _stopwatch = Stopwatch()..start();
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) {
        if (_stopwatch != null && _stopwatch!.isRunning) {
          _controller.add(_stopwatch!.elapsedMilliseconds);
        }
      },
    );
  }

  /// Stop the timer and return elapsed milliseconds.
  int stop() {
    _stopwatch?.stop();
    _periodicTimer?.cancel();
    return elapsedMs;
  }

  /// Reset the timer to zero without starting.
  void reset() {
    _stopwatch?.reset();
    _controller.add(0);
  }

  /// Restart the timer from zero.
  void restart() {
    reset();
    start();
  }

  /// Record a lap time without stopping.
  int lap() {
    return elapsedMs;
  }

  /// Dispose resources.
  void dispose() {
    _periodicTimer?.cancel();
    _stopwatch?.stop();
    _controller.close();
  }
}
