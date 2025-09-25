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

  factory SignWithTables.fromCsv(List<List<dynamic>> table) {
    final positionRaw = table.first[0].trim();
    final latLonStrs = positionRaw
        .trim()
        .substring(1, positionRaw.length - 1)
        .split(',');
    return SignWithTables(
      tables: table.map((row) => SignTable.fromCsv(row)).toList(),
      pole: SignPole.fromCsv(table.first),
      position: Position(
        latitude: double.parse(latLonStrs[0].trim()),
        longitude: double.parse(latLonStrs[1].trim()),
      ),
    );
  }

  @override
  List<Object?> get props => [tables, pole, ...super.props];
}
