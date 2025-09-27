import 'package:test/test.dart';
import 'package:uploader/model/place.dart';
import 'package:uploader/model/position.dart';

void main() {
  group('Place', () {
    test('from csv with position', () {
      final place = Place.fromCsv([
        '  Place Name  ',
        ' (46.292476, 10.686197) ',
      ]);
      expect(place.name, 'Place Name');
      expect(
        place.position,
        const Position(latitude: 46.292476, longitude: 10.686197),
      );
    });

    test('from csv without position', () {
      final place = Place.fromCsv(['  Place Name  ', '']);
      expect(place.name, 'Place Name');
      expect(place.position, isNull);
    });

    test('equal', () {
      final place1 = Place(
        name: 'Place Name',
        position: const Position(latitude: 46.292476, longitude: 10.686197),
      );
      final place2 = Place(
        name: 'Place Name',
        position: const Position(latitude: 46.292476, longitude: 10.686197),
      );
      expect(place1, equals(place2));
    });
  });
}
