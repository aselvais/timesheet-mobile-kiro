import 'package:flutter/material.dart';

/// A tag that can be assigned to tasks for categorization.
class Tag {
  final String id;
  final String name;
  final Color color;

  const Tag({required this.id, required this.name, required this.color});

  /// Encode color as ARGB int for storage.
  int get colorValue => color.value;
}
