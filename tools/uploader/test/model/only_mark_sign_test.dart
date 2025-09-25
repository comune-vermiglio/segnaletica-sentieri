import 'package:test/test.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign.dart';

void main() {
  group('OnlyMarkSign', () {
    test('from CSV', () {
      final csvData = [
        [
          '(46.292476, 10.686197) ',
          'Solo segno rosso',
          'Cambiare',
          'Direzione',
          'Sinistra',
          'info1',
          'info2',
          'info3',
        ],
      ];
      final sign = Sign.fromCsv(csvData);
      expect(
        sign,
        equals(
          OnlyMarkSign(
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
