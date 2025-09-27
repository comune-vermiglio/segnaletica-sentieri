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

    test('contains place', () async {
      final file = File('test/data/places.csv');
      final manager = PlaceManager();
      await manager.loadCsv(file);
      expect(manager.containsPlace('Volpaia'), isTrue);
      expect(manager.containsPlace('Stavél'), isTrue);
      expect(manager.containsPlace('Verniana'), isTrue);
      expect(manager.containsPlace('Passo Tonale'), isTrue);
      expect(manager.containsPlace('Vermiglio'), isTrue);
      expect(manager.containsPlace('Vernian'), isFalse);
      expect(manager.containsPlace('Stavel'), isFalse);
      expect(manager.containsPlace('Passo del Tonale'), isFalse);
      expect(manager.containsPlace('passo Tonale'), isFalse);
      expect(manager.containsPlace('Passo tonale'), isFalse);
      expect(manager.containsPlace('vermiglio'), isFalse);
      expect(manager.containsPlace('Vermiglio '), isFalse);
      expect(manager.containsPlace(' Vermiglio'), isFalse);
    });
  });
}
