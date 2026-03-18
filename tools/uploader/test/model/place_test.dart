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

    test('from csv with position and elevation', () {
      final place = Place.fromCsv([
        '  Place Name  ',
        ' (46.292476, 10.686197) ',
        '1234',
      ]);
      expect(place.name, 'Place Name');
      expect(
        place.position,
        const Position(
          latitude: 46.292476,
          longitude: 10.686197,
          elevation: 1234,
        ),
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
        position: const Position(
          latitude: 46.292476,
          longitude: 10.686197,
          elevation: 1234,
        ),
      );
      final place2 = Place(
        name: 'Place Name',
        position: const Position(
          latitude: 46.292476,
          longitude: 10.686197,
          elevation: 1234,
        ),
      );
      expect(place1, equals(place2));
    });

    test('copy with', () {
      const name = 'Place Name';
      const lat = 46.292476;
      const lon = 10.686197;
      const elevation = 1234;
      final place = Place(
        name: name,
        position: const Position(latitude: lat, longitude: lon),
      );
      final newPlace = place.copyWith(
        position: const Position(
          latitude: lat,
          longitude: lon,
          elevation: elevation,
        ),
      );
      expect(
        newPlace,
        equals(
          Place(
            name: name,
            position: const Position(
              latitude: lat,
              longitude: lon,
              elevation: elevation,
            ),
          ),
        ),
      );
    });
  });
}
