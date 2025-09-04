import 'package:equatable/equatable.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/place_table.dart';

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

abstract class SignTable extends Equatable {
  final SignTableStatus status;
  final String? firstString;
  final String? secondString;
  final String? thirdString;

  const SignTable({
    required this.status,
    this.firstString,
    this.secondString,
    this.thirdString,
  });

  @override
  List<Object?> get props => [status, firstString, secondString, thirdString];

  factory SignTable.fromCsv(List<dynamic> row) {
    assert(row.length >= 4);
    switch (row[3]) {
      case 'Direzione':
        return DirectionTable.fromCsv(row);
      case 'Località':
        return PlaceTable.fromCsv(row);
      default:
        throw ArgumentError('Colonna direzione/località con valore errato');
    }
  }

  bool get isNotOk =>
      status != SignTableStatus.remove && (firstString?.isEmpty ?? true);

  bool get isOk => !isNotOk;
}
