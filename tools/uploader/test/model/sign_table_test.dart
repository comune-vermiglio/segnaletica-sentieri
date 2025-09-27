import 'package:flutter_test/flutter_test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_table_string.dart';

class PlaceManagerMock extends Fake implements PlaceManager {
  final Set<String> availablePlaces;

  PlaceManagerMock({required this.availablePlaces});

  @override
  bool containsPlace(String name) => availablePlaces.contains(name);
}

void main() {
  group('SignTable', () {
    test('from CSV', () {
      const firstString = 'Laghetti di San Leonardo';
      const secondString = 'Volpaia';
      const thirdString = 'Cadin';
      var csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Cambiare',
        'Direzione',
        'Sinistra',
        ' Laghetti di San Leonardo ',
        secondString,
        thirdString,
      ];
      var signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          DirectionTable(
            status: SignTableStatus.change,
            direction: SignTableDirection.left,
            firstString: SignTableString('Laghetti di San Leonardo'),
            secondString: SignTableString(secondString),
            thirdString: SignTableString(thirdString),
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Ok',
        'Direzione',
        'Destra',
        firstString,
        secondString,
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          DirectionTable(
            status: SignTableStatus.ok,
            direction: SignTableDirection.right,
            firstString: SignTableString(firstString),
            secondString: SignTableString(secondString),
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Nuovo',
        'Direzione',
        'Destra',
        firstString,
        '',
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          DirectionTable(
            status: SignTableStatus.add,
            direction: SignTableDirection.right,
            firstString: SignTableString(firstString),
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Nuovo',
        'Località',
        'Destra',
        firstString,
        '',
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          PlaceTable(
            status: SignTableStatus.add,
            firstString: SignTableString(firstString),
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Eliminare',
        'Direzione',
        'Sinistra',
        '',
        '',
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          DirectionTable(
            status: SignTableStatus.remove,
            direction: SignTableDirection.left,
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Wrong value',
        'Direzione',
        'Sinistra',
        '',
        '',
        '',
      ];
      expect(() => SignTable.fromCsv(csv), throwsArgumentError);
    });

    test('is ok', () {
      final place1 = 'place1';
      final place2 = 'place2';
      final place3 = 'place3';
      final placeManager = PlaceManagerMock(
        availablePlaces: {place1, place2, place3},
      );
      var table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
      );
      expect(table.isOk(placeManager: placeManager), isFalse);
      expect(table.isNotOk(placeManager: placeManager), isTrue);
      table = DirectionTable(
        status: SignTableStatus.remove,
        direction: SignTableDirection.left,
      );
      expect(table.isOk(placeManager: placeManager), isTrue);
      expect(table.isNotOk(placeManager: placeManager), isFalse);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(' '),
      );
      expect(table.isOk(placeManager: placeManager), isFalse);
      expect(table.isNotOk(placeManager: placeManager), isTrue);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(place1),
      );
      expect(table.isOk(placeManager: placeManager), isTrue);
      expect(table.isNotOk(placeManager: placeManager), isFalse);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString('wrong place 1'),
      );
      expect(table.isOk(placeManager: placeManager), isFalse);
      expect(table.isNotOk(placeManager: placeManager), isTrue);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(place1),
        secondString: SignTableString(place2),
      );
      expect(table.isOk(placeManager: placeManager), isTrue);
      expect(table.isNotOk(placeManager: placeManager), isFalse);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(place1),
        secondString: SignTableString('wrong place 2'),
      );
      expect(table.isOk(placeManager: placeManager), isFalse);
      expect(table.isNotOk(placeManager: placeManager), isTrue);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(place1),
        secondString: SignTableString(place2),
        thirdString: SignTableString(place3),
      );
      expect(table.isOk(placeManager: placeManager), isTrue);
      expect(table.isNotOk(placeManager: placeManager), isFalse);
      table = DirectionTable(
        status: SignTableStatus.ok,
        direction: SignTableDirection.left,
        firstString: SignTableString(place1),
        secondString: SignTableString(place2),
        thirdString: SignTableString('wrong place 3'),
      );
      expect(table.isOk(placeManager: placeManager), isFalse);
      expect(table.isNotOk(placeManager: placeManager), isTrue);
    });
  });
}
