import 'dart:io';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import 'place.dart';

class PlaceManager extends ChangeNotifier {
  final List<Place> _places = [];

  void clean() {
    _places.clear();
    notifyListeners();
  }

  List<Place> get places => _places;

  Future<void> loadCsv(File csvFile) async {
    _places.clear();
    final content = await csvFile.readAsString();
    final rows = CsvCodec().decode(content);
    for (final values in rows.skip(1)) {
      _places.add(Place.fromCsv(values));
    }
    notifyListeners();
  }

  bool containsPlace(String name) => _places.any((place) => place.name == name);

  Place? getPlaceByName(String name) =>
      _places.firstWhereOrNull((place) => place.name == name);

  Future<void> saveCsv(
    File csvFile, {
    bool elevationFromInternet = false,
  }) async {
    final codec = CsvCodec();
    List<List<dynamic>> rows = [
      ["LOCALITA'", 'POSIZIONE', 'ALTITUDINE'],
    ];
    for (final place in _places) {
      List<dynamic> row = [place.name];
      if (place.position != null) {
        var position = place.position!;
        if (elevationFromInternet) {
          final newElevation = await place.position!.elevationFromInternet;
          position = place.position!.copyWith(elevation: newElevation);
        }
        row.addAll([
          '(${position.latitude},${position.longitude})',
          if (position.elevation != null) position.elevation,
        ]);
      }
      rows.add(row);
    }
    final csvString = codec.encode(rows);
    await csvFile.writeAsString(csvString);
  }
}
