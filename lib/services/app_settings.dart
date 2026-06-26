import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Simple persistent app settings stored as JSON.
class AppSettings extends ChangeNotifier {
  bool _isDark = true;
  double? _defaultHourlyRate;

  bool get isDark => _isDark;
  double? get defaultHourlyRate => _defaultHourlyRate;

  set isDark(bool v) {
    _isDark = v;
    notifyListeners();
    _save();
  }

  set defaultHourlyRate(double? v) {
    _defaultHourlyRate = v;
    notifyListeners();
    _save();
  }

  Future<void> load() async {
    try {
      final f = await _file();
      if (f.existsSync()) {
        final data = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
        _isDark = data['isDark'] as bool? ?? true;
        _defaultHourlyRate = (data['defaultHourlyRate'] as num?)?.toDouble();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode({
        'isDark': _isDark,
        'defaultHourlyRate': _defaultHourlyRate,
      }));
    } catch (_) {}
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }
}
