import 'package:glados/glados.dart';
import 'package:test/test.dart';
import 'package:time_tracker/models/time_log.dart';

/// Validates: Requirements 3.3
///
/// Property: ∀ closed TimeLog t: t.endTime > t.startTime ⟹ t.duration > Duration.zero
void main() {
  Glados2(any.dateTime, any.positiveInt).test(
    'closed TimeLog with endTime after startTime has positive duration',
    (startTime, offsetMs) {
      // Derive endTime by adding a positive millisecond offset to startTime
      final endTime = startTime.add(Duration(milliseconds: offsetMs));

      final log = TimeLog(
        id: 'test-id',
        taskId: 'task-id',
        startTime: startTime,
        endTime: endTime,
      );

      expect(log.duration, isNotNull);
      expect(log.duration! > Duration.zero, isTrue);
    },
  );
}
