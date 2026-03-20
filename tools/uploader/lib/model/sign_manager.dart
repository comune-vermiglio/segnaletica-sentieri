import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:uploader/model/place_manager.dart';

import 'sign.dart';

class SignManager extends ChangeNotifier {
  final PlaceManager placeManager;
  final List<Sign> _signs = [];

  SignManager({required this.placeManager});

  void clean() {
    _signs.clear();
    notifyListeners();
  }

  List<Sign> get signs => _signs;

  Future<void> loadCsv(File csvFile) async {
    _signs.clear();
    final content = await csvFile.readAsString();
    final rows = CsvCodec().decode(content);
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

  Future<void> saveCsv(File csvFile, {bool overwriteTimes = false}) async {
    final codec = CsvCodec();
    List<List<dynamic>> rows = [
      [
        "POSIZIONE'",
        'PALO',
        'TABELLA',
        'TIPO TABELLA',
        'DIREZIONE FRECCIA',
        'STRINGA 1',
        'TEMPO 1',
        'STRINGA 2',
        'TEMPO 2',
        'STRINGA 3',
        'TEMPO 3',
      ],
    ];
    for (final sign in _signs) {
      rows.addAll(
        await sign.toCsv(
          overwriteTimes: overwriteTimes,
          placeManager: placeManager,
        ),
      );
    }
    final csvString = codec.encode(rows);
    await csvFile.writeAsString(csvString);
  }
}
