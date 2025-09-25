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
}
