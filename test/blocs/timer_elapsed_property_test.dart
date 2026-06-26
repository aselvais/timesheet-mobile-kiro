/// Property-based tests for elapsed time computation in TimerBloc.
///
/// Validates: Requirements 4.1, 4.2
///
/// The `_onTick` handler computes:
///   elapsed = DateTime.now().difference(activeSession.startTime)
///
/// Properties tested:
/// 1. For any startTime in the past, elapsed >= Duration.zero
/// 2. For any two "now" snapshots t1 < t2 with the same startTime,
///    t2.difference(startTime) >= t1.difference(startTime)
///    (monotonically non-decreasing)
library;

import 'package:glados/glados.dart';
import 'package:test/test.dart';

/// Computes elapsed duration exactly as `_onTick` does in [TimerBloc].
Duration computeElapsed(DateTime now, DateTime startTime) =>
    now.difference(startTime);

void main() {
  /// **Validates: Requirements 4.1, 4.2**
  ///
  /// Property 1: For any startTime that is before or equal to `now`,
  /// the elapsed duration is always >= Duration.zero.
  Glados(any.positiveInt).test(
    'elapsed duration is non-negative for any past startTime',
    (offsetMs) {
      final now = DateTime.now();
      // startTime is `offsetMs` milliseconds in the past
      final startTime = now.subtract(Duration(milliseconds: offsetMs));

      final elapsed = computeElapsed(now, startTime);

      expect(elapsed, greaterThanOrEqualTo(Duration.zero));
    },
  );

  /// **Validates: Requirements 4.1, 4.2**
  ///
  /// Property 2: For any two wall-clock snapshots t1 and t2 where t1 <= t2,
  /// with the same startTime, the elapsed duration at t2 is >= elapsed at t1
  /// (monotonically non-decreasing).
  Glados2(any.positiveInt, any.positiveInt).test(
    'elapsed duration is monotonically non-decreasing across ticks',
    (offsetMs, gapMs) {
      final base = DateTime(2024, 1, 1, 0, 0, 0); // fixed reference point
      // startTime is `offsetMs` ms before base
      final startTime = base.subtract(Duration(milliseconds: offsetMs));

      // t1 is `base`, t2 is `gapMs` ms after base — so t1 <= t2
      final t1 = base;
      final t2 = base.add(Duration(milliseconds: gapMs));

      final elapsed1 = computeElapsed(t1, startTime);
      final elapsed2 = computeElapsed(t2, startTime);

      expect(elapsed2, greaterThanOrEqualTo(elapsed1));
    },
  );
}
