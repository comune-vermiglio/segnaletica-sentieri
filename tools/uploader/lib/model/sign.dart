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
      throw ArgumentError('Invalid CSV data');
    }
    final positionRaw = table.first[0].trim();
    final poleStatusRaw = table.first[1];
    for (final row in table) {
      if (row.length < 7) {
        throw ArgumentError('Each row must have at least 7 columns');
      }
      if (row[0].trim() != positionRaw) {
        throw ArgumentError('Inconsistent position data');
      }
      if (row[1] != poleStatusRaw) {
        throw ArgumentError('Inconsistent pole status data');
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
