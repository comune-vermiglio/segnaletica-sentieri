import 'package:equatable/equatable.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/sign_with_tables.dart';

import 'position.dart';

abstract class Sign extends Equatable {
  final Position position;

  const Sign({required this.position});

  factory Sign.fromCsv(List<List<dynamic>> table) {
    if (table.isEmpty || table[0].isEmpty) {
      throw ArgumentError('Tabella vuota o prima riga vuota');
    }
    final positionRaw = table.first[0].trim();
    final poleStatusRaw = table.first[1];
    for (final row in table) {
      if (row.length < 8) {
        throw ArgumentError('Ogni riga deve avere almeno 8 colonne');
      }
      if (row[0].trim() != positionRaw) {
        throw ArgumentError('Dati di posizione incoerenti');
      }
      if (row[1] != poleStatusRaw) {
        throw ArgumentError(
          'Dati di stato del palo incoerenti per la posizione $positionRaw',
        );
      }
    }
    switch (poleStatusRaw) {
      case 'Solo segno rosso':
        return OnlyMarkSign.fromCsv(table);
      default:
        return SignWithTables.fromCsv(table);
    }
  }

  @override
  List<Object?> get props => [position];
}
