import 'dart:io';

import 'package:csv/csv.dart';
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
    final content = await csvFile.readAsString();
    final rows = const CsvToListConverter().convert(content);
    String currentPosition = '';
    List<List<dynamic>> currentRows = [];
    for (final values in rows.skip(1)) {
      if (values.length != 8) {
        throw ArgumentError('$values non ha 8 colonne');
      }
      if (values[0].isEmpty) {
        break;
      }
      final tmp = values[0].trim();
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
