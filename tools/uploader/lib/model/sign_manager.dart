import 'dart:io';

import 'package:flutter/foundation.dart';

import 'sign.dart';

class SignManager extends ChangeNotifier {
  final List<Sign> _signs = [];

  void clean() {
    _signs.clear();
    notifyListeners();
  }

  List<Sign> get signs => _signs;

  Future<void> loadCsv(File csvFile) async {
    _signs.clear();
    final rows = await csvFile.readAsLines();
    String currentPosition = '';
    List<List<String>> currentRows = [];
    for (var row in rows.skip(1)) {
      if (!row.startsWith('"')) {
        break;
      }
      final endLng = row.trimLeft().indexOf('"', 1);
      final values = row.substring(endLng + 2).split(',');
      values.insert(0, row.trimLeft().substring(1, endLng));
      if (values.length != 7) {
        throw ArgumentError('Each row must have exactly 7 columns');
      }
      final tmp = values[0];
      if (tmp != currentPosition) {
        if (currentRows.isNotEmpty) {
          _signs.add(Sign.fromCsv(currentRows));
          currentRows.clear();
        }
        currentPosition = tmp;
        currentRows.add(values);
      } else {
        currentRows.add(values);
      }
    }
    if (currentRows.isNotEmpty) {
      _signs.add(Sign.fromCsv(currentRows));
    }
    notifyListeners();
  }
}
