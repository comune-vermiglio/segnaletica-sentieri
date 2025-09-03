import 'package:test/test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/sign_table.dart';

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
            firstString: 'Laghetti di San Leonardo',
            secondString: secondString,
            thirdString: thirdString,
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
            firstString: firstString,
            secondString: secondString,
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
            firstString: firstString,
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
          PlaceTable(status: SignTableStatus.add, firstString: firstString),
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
  });
}
