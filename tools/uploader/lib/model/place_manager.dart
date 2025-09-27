import 'dart:io';

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
    final rows = const CsvToListConverter().convert(content);
    for (final values in rows.skip(1)) {
      _places.add(Place.fromCsv(values));
    }
    notifyListeners();
  }
}
