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
              elevation: 1234,
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

    test('get place by name', () async {
      final file = File('test/data/places.csv');
      final manager = PlaceManager();
      await manager.loadCsv(file);
      expect(
        manager.getPlaceByName('Volpaia'),
        const Place(
          name: 'Volpaia',
          position: Position(
            latitude: 46.2858245,
            longitude: 10.6727306,
            elevation: 1234,
          ),
        ),
      );
      expect(
        manager.getPlaceByName('Stavél'),
        const Place(
          name: 'Stavél',
          position: Position(latitude: 46.2771804, longitude: 10.6605182),
        ),
      );
      expect(
        manager.getPlaceByName('Verniana'),
        const Place(
          name: 'Verniana',
          position: Position(latitude: 46.2968901, longitude: 10.6669773),
        ),
      );
      expect(
        manager.getPlaceByName('Passo Tonale'),
        const Place(name: 'Passo Tonale'),
      );
      expect(
        manager.getPlaceByName('Vermiglio'),
        const Place(name: 'Vermiglio'),
      );
      expect(manager.getPlaceByName('Volpai'), isNull);
      expect(manager.getPlaceByName(''), isNull);
    });

    test('save to csv', () async {
      final readFile = File('test/data/places.csv');
      final manager = PlaceManager();
      await manager.loadCsv(readFile);
      final saveFile = File('test/data/places_temp.csv');
      if (saveFile.existsSync()) {
        saveFile.deleteSync();
      }
      expect(saveFile.existsSync(), isFalse);
      await manager.saveCsv(saveFile);
      expect(saveFile.existsSync(), isTrue);
      final content = saveFile.readAsStringSync();
      expect(
        content,
        "LOCALITA',POSIZIONE,ALTITUDINE\r\nVolpaia,\"(46.2858245,10.6727306)\",1234\r\nStavél,\"(46.2771804,10.6605182)\"\r\nVerniana,\"(46.2968901,10.6669773)\"\r\nVermiglio\r\nPasso Tonale",
      );
      saveFile.deleteSync();
    });

    test('save to csv with internet elevation', () async {
      final readFile = File('test/data/places.csv');
      final manager = PlaceManager();
      await manager.loadCsv(readFile);
      final saveFile = File('test/data/places_temp.csv');
      if (saveFile.existsSync()) {
        saveFile.deleteSync();
      }
      expect(saveFile.existsSync(), isFalse);
      await manager.saveCsv(saveFile, elevationFromInternet: true);
      expect(saveFile.existsSync(), isTrue);
      final content = saveFile.readAsStringSync();
      expect(
        content,
        "LOCALITA',POSIZIONE,ALTITUDINE\r\nVolpaia,\"(46.2858245,10.6727306)\",1199\r\nStavél,\"(46.2771804,10.6605182)\",1243\r\nVerniana,\"(46.2968901,10.6669773)\",1755\r\nVermiglio\r\nPasso Tonale",
      );
      saveFile.deleteSync();
    });
  });
}
