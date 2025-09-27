import 'dart:io';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:uploader/model/place.dart';
import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/position.dart';

void main() {
  group('PlaceManager', () {
    test('load csv', () async {
      final file = File('test/data/places.csv');
      final manager = PlaceManager();
      expect(manager.places, isEmpty);
      await manager.loadCsv(file);
      expect(
        const DeepCollectionEquality().equals(manager.places, [
          Place(
            name: 'Volpaia',
            position: const Position(
              latitude: 46.2858245,
              longitude: 10.6727306,
            ),
          ),
          Place(
            name: 'Stavél',
            position: const Position(
              latitude: 46.2771804,
              longitude: 10.6605182,
            ),
          ),
          Place(
            name: 'Verniana',
            position: const Position(
              latitude: 46.2968901,
              longitude: 10.6669773,
            ),
          ),
          Place(name: 'Vermiglio'),
          Place(name: 'Passo Tonale'),
        ]),
        isTrue,
      );
    });
  });
}
