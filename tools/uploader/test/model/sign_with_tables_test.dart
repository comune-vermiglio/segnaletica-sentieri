import 'package:test/test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign.dart';
import 'package:uploader/model/sign_pole.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_table_string.dart';
import 'package:uploader/model/sign_with_tables.dart';

void main() {
  group('SignWithTables', () {
    test('from CSV', () {
      final csvData = [
        [
          '(46.292476, 10.686197) ',
          'Non necessario',
          'Cambiare',
          'Direzione',
          'Sinistra',
          'info1',
          'info2',
          'info3',
        ],
        [
          ' (46.292476, 10.686197)',
          'Non necessario',
          'Ok',
          'Direzione',
          'Destra',
          'info11',
          'info12',
          'info13',
        ],
      ];
      final sign = Sign.fromCsv(csvData);
      expect(
        sign,
        equals(
          SignWithTables(
            tables: [
              DirectionTable(
                direction: SignTableDirection.left,
                status: SignTableStatus.change,
                firstString: SignTableString('info1'),
                secondString: SignTableString('info2'),
                thirdString: SignTableString('info3'),
              ),
              DirectionTable(
                direction: SignTableDirection.right,
                status: SignTableStatus.ok,
                firstString: SignTableString('info11'),
                secondString: SignTableString('info12'),
                thirdString: SignTableString('info13'),
              ),
            ],
            pole: SignPole(status: SignPoleStatus.notNeeded),
            position: const Position(latitude: 46.292476, longitude: 10.686197),
          ),
        ),
      );
    });

    test('from CSV exceptions', () {
      expect(() => Sign.fromCsv([]), throwsArgumentError);
      expect(() => Sign.fromCsv([[]]), throwsArgumentError);
      expect(
        () => Sign.fromCsv([
          ['(46.292476, 10.686197)', 'Non necessario'],
        ]),
        throwsArgumentError,
      );
      expect(
        () => Sign.fromCsv([
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Cambiare',
            'Sinistra',
            'info1',
            'info2',
            'info3',
          ],
          [
            '(46.2924, 10.68619)',
            'Non necessario',
            'Cambiare',
            'Sinistra',
            'info1',
            'info2',
            'info3',
          ],
        ]),
        throwsArgumentError,
      );

      expect(
        () => Sign.fromCsv([
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Cambiare',
            'Sinistra',
            'info1',
            'info2',
            'info3',
          ],
          [
            '(46.292476, 10.686197)',
            'Ok',
            'Cambiare',
            'Sinistra',
            'info1',
            'info2',
            'info3',
          ],
        ]),
        throwsArgumentError,
      );
    });
  });
}
