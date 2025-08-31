import 'package:equatable/equatable.dart';

enum SignTableStatus {
  ok,
  add,
  change,
  remove;

  factory SignTableStatus.fromString(String value) {
    switch (value) {
      case 'Ok':
        return SignTableStatus.ok;
      case 'Nuovo':
        return SignTableStatus.add;
      case 'Cambiare':
        return SignTableStatus.change;
      case 'Eliminare':
        return SignTableStatus.remove;
      default:
        throw ArgumentError('Stato della tabella sconosciuto: $value');
    }
  }

  @override
  String toString() {
    switch (this) {
      case SignTableStatus.ok:
        return 'Ok';
      case SignTableStatus.add:
        return 'Nuovo';
      case SignTableStatus.change:
        return 'Cambiare';
      case SignTableStatus.remove:
        return 'Eliminare';
    }
  }
}

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

class SignTable extends Equatable {
  final SignTableStatus status;
  final SignTableDirection direction;
  final String? firstString;
  final String? secondString;
  final String? thirdString;

  const SignTable({
    required this.status,
    required this.direction,
    this.firstString,
    this.secondString,
    this.thirdString,
  });

  @override
  List<Object?> get props => [
    status,
    direction,
    firstString,
    secondString,
    thirdString,
  ];

  factory SignTable.fromCsv(List<dynamic> row) {
    return SignTable(
      status: SignTableStatus.fromString(row[2]),
      direction: SignTableDirection.fromString(row[3]),
      firstString: row.length > 4 && row[4].isNotEmpty
          ? row[4].trimLeft().trimRight()
          : null,
      secondString: row.length > 5 && row[5].isNotEmpty
          ? row[5].trimLeft().trimRight()
          : null,
      thirdString: row.length > 6 && row[6].isNotEmpty
          ? row[6].trimLeft().trimRight()
          : null,
    );
  }
}
