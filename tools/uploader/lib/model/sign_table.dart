import 'package:equatable/equatable.dart';

import 'direction_table.dart';
import 'place_manager.dart';
import 'place_table.dart';
import 'sign_table_string.dart';

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
  final SignTableString? firstString;
  final SignTableString? secondString;
  final SignTableString? thirdString;

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

  bool isOk({required PlaceManager placeManager}) =>
      (status == SignTableStatus.remove || !(firstString?.isEmpty ?? true)) &&
      (firstString?.isOk(placeManager: placeManager) ?? true) &&
      (secondString?.isOk(placeManager: placeManager) ?? true) &&
      (thirdString?.isOk(placeManager: placeManager) ?? true);

  bool isNotOk({required PlaceManager placeManager}) =>
      !isOk(placeManager: placeManager);
}
