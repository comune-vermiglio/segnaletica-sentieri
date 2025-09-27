import 'sign_table.dart';
import 'sign_table_string.dart';

enum SignTableDirection {
  left,
  right;

  factory SignTableDirection.fromString(String value) {
    switch (value) {
      case 'Sinistra':
        return SignTableDirection.left;
      case 'Destra':
        return SignTableDirection.right;
      default:
        throw ArgumentError('Direzione sconosciuta: $value');
    }
  }
}

class DirectionTable extends SignTable {
  final SignTableDirection direction;

  const DirectionTable({
    required super.status,
    required this.direction,
    super.firstString,
    super.secondString,
    super.thirdString,
  });

  @override
  List<Object?> get props => [...super.props, direction];

  factory DirectionTable.fromCsv(List<dynamic> row) {
    assert(row[3] == 'Direzione');
    return DirectionTable(
      status: SignTableStatus.fromString(row[2]),
      direction: SignTableDirection.fromString(row[4]),
      firstString: row.length > 5 && row[5].isNotEmpty
          ? SignTableString(row[5].trim())
          : null,
      secondString: row.length > 6 && row[6].isNotEmpty
          ? SignTableString(row[6].trim())
          : null,
      thirdString: row.length > 7 && row[7].isNotEmpty
          ? SignTableString(row[7].trim())
          : null,
    );
  }
}
