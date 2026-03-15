import 'package:test/test.dart';
import 'package:uploader/model/position.dart';

void main() {
  group('Position', () {
    test('get distance to', () {
      const position1 = Position(latitude: 46.292476, longitude: 10.686197);
      const position2 = Position(latitude: 46.292504, longitude: 10.686482);
      final distance = position1.distanceTo(position2);
      expect(distance, closeTo(22.118, 0.001));
    });

    test('from csv', () {
      expect(
        Position.fromCsv(' ( 46.292476 , 10.686197  )', 1206),
        equals(
          Position(latitude: 46.292476, longitude: 10.686197, elevation: 1206),
        ),
      );
    });

    test('elevation from internet', () async {
      const position = Position(latitude: 46.292476, longitude: 10.686197);
      final elevation = await position.elevationFromInternet;
      expect(elevation, equals(1206.0));
    });
  });
}
