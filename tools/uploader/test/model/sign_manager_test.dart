import 'dart:io';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign_manager.dart';
import 'package:uploader/model/sign_pole.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_with_tables.dart';

void main() {
  group('SignManager', () {
    test('load CSV', () async {
      final file = File('test/data/signs.csv');
      final manager = SignManager();
      expect(manager.signs, isEmpty);
      await manager.loadCsv(file);
      expect(
        const DeepCollectionEquality().equals(manager.signs, [
          SignWithTables(
            tables: [
              DirectionTable(
                status: SignTableStatus.change,
                direction: SignTableDirection.left,
                firstString: 'Laghetti di San Leonardo',
                secondString: 'Volpaia',
              ),
            ],
            pole: SignPole(status: SignPoleStatus.notNeeded),
            position: Position(latitude: 46.2906727, longitude: 10.6815487),
          ),
          SignWithTables(
            tables: [
              DirectionTable(
                status: SignTableStatus.change,
                direction: SignTableDirection.right,
                firstString: 'Volpaia',
                secondString: 'Stavel',
              ),
              DirectionTable(
                status: SignTableStatus.remove,
                direction: SignTableDirection.left,
              ),
              PlaceTable(status: SignTableStatus.add, firstString: 'Volpaia'),
            ],
            pole: SignPole(status: SignPoleStatus.ok),
            position: Position(latitude: 46.2860383, longitude: 10.6739416),
          ),
          OnlyMarkSign(
            position: Position(latitude: 46.3008268, longitude: 10.6500200),
          ),
        ]),
        isTrue,
      );
    });
  });
}
