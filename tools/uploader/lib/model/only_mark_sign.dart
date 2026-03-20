import 'package:uploader/model/place_manager.dart';

import 'position.dart';
import 'sign.dart';

class OnlyMarkSign extends Sign {
  const OnlyMarkSign({required super.position});

  factory OnlyMarkSign.fromCsv(List<List<dynamic>> table) {
    final positionRaw = table.first[0].trim();
    final latLonStrs = positionRaw
        .trim()
        .substring(1, positionRaw.length - 1)
        .split(',');
    return OnlyMarkSign(
      position: Position(
        latitude: double.parse(latLonStrs[0].trim()),
        longitude: double.parse(latLonStrs[1].trim()),
      ),
    );
  }

  @override
  Future<List<List<String>>> toCsv({
    required bool timesFromInternet,
    required PlaceManager placeManager,
  }) async {
    return [
      [
        '(${position.latitude}, ${position.longitude})',
        'Solo segno rosso',
        'Ok',
        'Direzione',
        'Sinistra',
      ],
    ];
  }
}
