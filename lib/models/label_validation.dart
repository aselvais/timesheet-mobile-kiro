/// Validates a task label string.
///
/// Returns `null` if the label is valid, or an error message string if not.
///
/// Rules:
/// - Must be non-empty (after trimming)
/// - Must be ≤ 100 characters
String? validateLabel(String label) {
  if (label.trim().isEmpty) {
    return 'Label must not be empty.';
  }
  if (label.length > 100) {
    return 'Label must be 100 characters or fewer.';
  }
  return null;
}
