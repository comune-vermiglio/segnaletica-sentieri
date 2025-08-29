import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:exif/exif.dart';

import 'position.dart';

class SignImage extends Equatable {
  final File file;

  const SignImage(this.file);

  Future<Position?> get position async {
    final fileBytes = await file.readAsBytes();
    final data = await readExifFromBytes(fileBytes);
    final rawLat = data['GPS GPSLatitude'];
    final rawLon = data['GPS GPSLongitude'];
    if (rawLat != null && rawLon != null) {
      final latValues = rawLat.values.toList();
      final lonValues = rawLon.values.toList();
      if (latValues.length == 3 && lonValues.length == 3) {
        return Position(
          latitude: _convertDmsValuesToDecimal(latValues as List<Ratio>),
          longitude: _convertDmsValuesToDecimal(lonValues as List<Ratio>),
        );
      }
    }
    return null;
  }

  double _convertDmsValuesToDecimal(List<Ratio> dmsValues) {
    assert(dmsValues.length == 3);
    return dmsValues[0].toDouble() +
        dmsValues[1].toDouble() / 60 +
        dmsValues[2].toDouble() / 3600;
  }

  @override
  List<Object?> get props => [file];
}
