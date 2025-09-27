import 'position.dart';
import 'sign.dart';
import 'sign_pole.dart';
import 'sign_table.dart';

class SignWithTables extends Sign {
  final List<SignTable> tables;
  final SignPole pole;

  const SignWithTables({
    required this.tables,
    required this.pole,
    required super.position,
  });

  factory SignWithTables.fromCsv(List<List<dynamic>> table) => SignWithTables(
    tables: table.map((row) => SignTable.fromCsv(row)).toList(),
    pole: SignPole.fromCsv(table.first),
    position: Position.fromCsv(table.first[0]),
  );

  @override
  List<Object?> get props => [tables, pole, ...super.props];
}
