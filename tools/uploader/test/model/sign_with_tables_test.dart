import 'package:test/test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/place.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign.dart';
import 'package:uploader/model/sign_pole.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_table_string.dart';
import 'package:uploader/model/sign_with_tables.dart';

import 'place_manager_mock.dart';

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

    test('to csv without computing times', () async {
      final sign = SignWithTables(
        tables: [
          DirectionTable(
            direction: SignTableDirection.left,
            status: SignTableStatus.change,
            firstString: SignTableString('info1', time: Duration(hours: 1)),
            secondString: SignTableString('info2'),
            thirdString: SignTableString('info3'),
          ),
          DirectionTable(
            direction: SignTableDirection.right,
            status: SignTableStatus.ok,
            firstString: SignTableString('info11'),
            secondString: SignTableString('info12', time: Duration(hours: 2)),
            thirdString: SignTableString('info13'),
          ),
          PlaceTable(
            status: SignTableStatus.remove,
            firstString: SignTableString('info21'),
          ),
        ],
        pole: SignPole(status: SignPoleStatus.notNeeded),
        position: const Position(latitude: 46.292476, longitude: 10.686197),
      );
      final tmp = await sign.toCsv(
        timesFromInternet: false,
        placeManager: PlaceManagerMock()..getPlaceByNameIO = [('info1', null)],
      );
      expect(
        tmp,
        equals([
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Cambiare',
            'Direzione',
            'Sinistra',
            'info1',
            '1.00',
            'info2',
            '',
            'info3',
            '',
          ],
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Ok',
            'Direzione',
            'Destra',
            'info11',
            '',
            'info12',
            '2.00',
            'info13',
            '',
          ],
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Eliminare',
            'Località',
            'Sinistra',
            'info21',
            '',
            '',
          ],
        ]),
      );
    });

    test('to csv with computing times', () async {
      final sign = SignWithTables(
        tables: [
          DirectionTable(
            direction: SignTableDirection.left,
            status: SignTableStatus.change,
            firstString: SignTableString('info1', time: Duration(hours: 1)),
            secondString: SignTableString('info2'),
            thirdString: SignTableString('info3'),
          ),
          DirectionTable(
            direction: SignTableDirection.right,
            status: SignTableStatus.ok,
            firstString: SignTableString('info11'),
            secondString: SignTableString('info12', time: Duration(hours: 2)),
            thirdString: SignTableString('info13'),
          ),
          PlaceTable(
            status: SignTableStatus.remove,
            firstString: SignTableString('info21'),
          ),
        ],
        pole: SignPole(status: SignPoleStatus.notNeeded),
        position: const Position(latitude: 46.292476, longitude: 10.686197),
      );
      final tmp = await sign.toCsv(
        timesFromInternet: true,
        placeManager: PlaceManagerMock()
          ..getPlaceByNameIO = [
            ('info1', null),
            (
              'info2',
              Place(
                name: 'info2',
                position: const Position(latitude: 46.293, longitude: 10.687),
              ),
            ),
            ('info3', null),
            ('info11', null),
            ('info12', null),
            (
              'info13',
              Place(
                name: 'info13',
                position: const Position(latitude: 46.24, longitude: 10.68),
              ),
            ),
            (
              'info21',
              Place(
                name: 'info21',
                position: const Position(latitude: 46.25, longitude: 10.89),
              ),
            ),
          ],
      );
      expect(
        tmp,
        equals([
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Cambiare',
            'Direzione',
            'Sinistra',
            'info1',
            '1.00',
            'info2',
            '0.05',
            'info3',
            '',
          ],
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Ok',
            'Direzione',
            'Destra',
            'info11',
            '',
            'info12',
            '2.00',
            'info13',
            '5.05',
          ],
          [
            '(46.292476, 10.686197)',
            'Non necessario',
            'Eliminare',
            'Località',
            'Sinistra',
            'info21',
            '',
            '',
          ],
        ]),
      );
    });
  });
}
