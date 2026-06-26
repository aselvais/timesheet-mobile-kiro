import 'package:glados/glados.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:time_tracker/models/task.dart';

/// Validates: Requirements 1.1
///
/// Property: Creating N tasks always results in N distinct UUIDs.
void main() {
  final _uuid = Uuid();

  Glados(any.positiveIntOrZero).test(
    'creating N tasks always results in N distinct UUIDs',
    (n) {
      final tasks = List.generate(
        n,
        (_) => Task(
          id: _uuid.v4(),
          label: 'task',
          createdAt: DateTime.now(),
        ),
      );

      final ids = tasks.map((t) => t.id).toSet();
      expect(ids.length, equals(n));
    },
  );
}
