import 'dart:io';

import 'package:test/test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign_manager.dart';
import 'package:uploader/model/sign_pole.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_table_string.dart';
import 'package:uploader/model/sign_with_tables.dart';

import 'place_manager_mock.dart';

void main() {
  group('SignManager', () {
    test('load CSV', () async {
      final file = File('test/data/signs.csv');
      final manager = SignManager(placeManager: PlaceManagerMock());
      expect(manager.signs, isEmpty);
      await manager.loadCsv(file);
      expect(
        // const DeepCollectionEquality().equals(
        manager.signs,
        [
          SignWithTables(
            tables: [
              DirectionTable(
                status: SignTableStatus.change,
                direction: SignTableDirection.left,
                firstString: SignTableString('Sentiero di Valle n 15'),
                secondString: SignTableString(
                  'Volpaia',
                  time: Duration(minutes: 15),
                ),
                thirdString: SignTableString(
                  'Croz de la Luna',
                  time: Duration(hours: 3, minutes: 45),
                ),
              ),
              DirectionTable(
                status: SignTableStatus.change,
                direction: SignTableDirection.left,
                firstString: SignTableString(
                  'Cascata di Palù',
                  time: Duration(minutes: 15),
                ),
                secondString: SignTableString(
                  'Masi di Palù',
                  time: Duration(hours: 1, minutes: 20),
                ),
                thirdString: SignTableString(
                  "Pradac'",
                  time: Duration(hours: 3, minutes: 5),
                ),
              ),
            ],
            pole: SignPole(status: SignPoleStatus.add),
            position: Position(latitude: 46.2906727, longitude: 10.6815487),
          ),
          SignWithTables(
            tables: [
              DirectionTable(
                status: SignTableStatus.change,
                direction: SignTableDirection.right,
                firstString: SignTableString('Sentiero di Valle n 15'),
                secondString: SignTableString(
                  'Volpaia',
                  time: Duration(minutes: 35),
                ),
              ),
            ],
            pole: SignPole(status: SignPoleStatus.ok),
            position: Position(latitude: 46.2896754, longitude: 10.6822763),
          ),
          OnlyMarkSign(
            position: Position(latitude: 46.3008268, longitude: 10.6500200),
          ),
          SignWithTables(
            tables: [
              PlaceTable(
                status: SignTableStatus.ok,
                firstString: SignTableString('Raseghe'),
              ),
            ],
            pole: SignPole(status: SignPoleStatus.ok),
            position: Position(latitude: 46.2519235, longitude: 10.6109563),
          ),
        ],
        // ),
        // isTrue,
      );
    });
  });
}
