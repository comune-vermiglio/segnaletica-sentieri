import 'package:test/test.dart';
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
        'Sinistra',
        firstString,
        secondString,
        thirdString,
      ];
      var signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          SignTable(
            status: SignTableStatus.change,
            direction: SignTableDirection.left,
            firstString: firstString,
            secondString: secondString,
            thirdString: thirdString,
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Ok',
        'Destra',
        firstString,
        secondString,
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          SignTable(
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
        'Nuova',
        'Destra',
        firstString,
        '',
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          SignTable(
            status: SignTableStatus.add,
            direction: SignTableDirection.right,
            firstString: firstString,
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Eliminare',
        'Sinistra',
        '',
        '',
        '',
      ];
      signTable = SignTable.fromCsv(csv);
      expect(
        signTable,
        equals(
          SignTable(
            status: SignTableStatus.remove,
            direction: SignTableDirection.left,
          ),
        ),
      );
      csv = [
        '(46.2906727, 10.6815487)',
        'Non necessario',
        'Wrong value',
        'Sinistra',
        '',
        '',
        '',
      ];
      expect(() => SignTable.fromCsv(csv), throwsArgumentError);
    });
  });
}
