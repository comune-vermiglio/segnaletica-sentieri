import 'dart:io';

import 'package:exif/exif.dart';

import 'position.dart';

class SignImage {
  final File file;
  Position? _position;

  SignImage(this.file);

  Future<Position?> get position async {
    if (_position == null) {
      await _computePosition();
    }
    return _position;
  }

  Future<void> _computePosition() async {
    final fileBytes = await file.readAsBytes();
    final data = await readExifFromBytes(fileBytes);
    final rawLat = data['GPS GPSLatitude'];
    final rawLon = data['GPS GPSLongitude'];
    if (rawLat != null && rawLon != null) {
      final latValues = rawLat.values.toList();
      final lonValues = rawLon.values.toList();
      if (latValues.length == 3 && lonValues.length == 3) {
        _position = Position(
          latitude: _convertDmsValuesToDecimal(latValues as List<Ratio>),
          longitude: _convertDmsValuesToDecimal(lonValues as List<Ratio>),
        );
        return;
      }
    }
    _position = null;
  }

  double _convertDmsValuesToDecimal(List<Ratio> dmsValues) {
    assert(dmsValues.length == 3);
    return dmsValues[0].toDouble() +
        dmsValues[1].toDouble() / 60 +
        dmsValues[2].toDouble() / 3600;
  }
}
