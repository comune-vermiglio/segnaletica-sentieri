import 'package:test/test.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign.dart';
import 'package:uploader/model/sign_pole.dart';
import 'package:uploader/model/sign_table.dart';

void main() {
  group('Sign', () {
    test('from CSV', () {
      final csvData = [
        [
          '(46.292476, 10.686197) ',
          'Non necessario',
          'Cambiare',
          'Sinistra',
          'info1',
          'info2',
          'info3',
        ],
        [
          ' (46.292476, 10.686197)',
          'Non necessario',
          'Ok',
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
          Sign(
            tables: [
              SignTable(
                direction: SignTableDirection.left,
                status: SignTableStatus.change,
                firstString: 'info1',
                secondString: 'info2',
                thirdString: 'info3',
              ),
              SignTable(
                direction: SignTableDirection.right,
                status: SignTableStatus.ok,
                firstString: 'info11',
                secondString: 'info12',
                thirdString: 'info13',
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
