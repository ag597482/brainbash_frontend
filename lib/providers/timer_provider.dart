import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A countdown timer provider that emits remaining seconds.
class CountdownTimerNotifier extends StateNotifier<int> {
  CountdownTimerNotifier() : super(0);

  Timer? _timer;
  int _totalSeconds = 0;

  int get totalSeconds => _totalSeconds;
  bool get isRunning => _timer?.isActive ?? false;
  bool get isExpired => state <= 0 && _totalSeconds > 0;

  /// Start a countdown from [seconds].
  void start(int seconds) {
    _timer?.cancel();
    _totalSeconds = seconds;
    state = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state = state - 1;
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Pause the countdown.
  void pause() {
    _timer?.cancel();
  }

  /// Resume the countdown.
  void resume() {
    if (state > 0 && !isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state > 0) {
          state = state - 1;
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  /// Reset to zero.
  void reset() {
    _timer?.cancel();
    _totalSeconds = 0;
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final countdownTimerProvider =
    StateNotifierProvider<CountdownTimerNotifier, int>((ref) {
  return CountdownTimerNotifier();
});

/// A stopwatch-style provider that counts elapsed milliseconds upward.
class ElapsedTimerNotifier extends StateNotifier<int> {
  ElapsedTimerNotifier() : super(0);

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  bool get isRunning => _stopwatch.isRunning;

  void start() {
    _stopwatch.reset();
    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      state = _stopwatch.elapsedMilliseconds;
    });
  }

  int stop() {
    _stopwatch.stop();
    _ticker?.cancel();
    state = _stopwatch.elapsedMilliseconds;
    return state;
  }

  void restart() {
    _stopwatch.reset();
    _stopwatch.start();
    state = 0;
  }

  int lap() {
    return _stopwatch.elapsedMilliseconds;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}

final elapsedTimerProvider =
    StateNotifierProvider<ElapsedTimerNotifier, int>((ref) {
  return ElapsedTimerNotifier();
});
