import 'package:equatable/equatable.dart';

import 'position.dart';
import 'sign_pole.dart';
import 'sign_table.dart';

class Sign extends Equatable {
  final List<SignTable> tables;
  final SignPole pole;
  final Position position;

  const Sign({
    required this.tables,
    required this.pole,
    required this.position,
  });

  factory Sign.fromCsv(List<List<dynamic>> table) {
    if (table.isEmpty || table[0].isEmpty) {
      throw ArgumentError('Tabella vuota o prima riga vuota');
    }
    final positionRaw = table.first[0].trim();
    final poleStatusRaw = table.first[1];
    for (final row in table) {
      if (row.length < 7) {
        throw ArgumentError('Ogni riga deve avere almeno 7 colonne');
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
    final latLonStrs = positionRaw
        .trim()
        .substring(1, positionRaw.length - 1)
        .split(',');
    return Sign(
      tables: table.map((row) => SignTable.fromCsv(row)).toList(),
      pole: SignPole.fromCsv(table.first),
      position: Position(
        latitude: double.parse(latLonStrs[0].trim()),
        longitude: double.parse(latLonStrs[1].trim()),
      ),
    );
  }

  @override
  List<Object?> get props => [tables, pole, position];
}
