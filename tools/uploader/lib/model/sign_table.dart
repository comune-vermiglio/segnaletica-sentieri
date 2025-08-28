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
      case 'Nuova':
        return SignTableStatus.add;
      case 'Cambiare':
        return SignTableStatus.change;
      case 'Eliminare':
        return SignTableStatus.remove;
      default:
        throw ArgumentError('Unknown status: $value');
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
        throw ArgumentError('Unknown direction: $value');
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

  factory SignTable.fromCsv(List<String> values) {
    return SignTable(
      status: SignTableStatus.fromString(values[2]),
      direction: SignTableDirection.fromString(values[3]),
      firstString: values.length > 4 && values[4].isNotEmpty ? values[4] : null,
      secondString: values.length > 5 && values[5].isNotEmpty
          ? values[5]
          : null,
      thirdString: values.length > 6 && values[6].isNotEmpty ? values[6] : null,
    );
  }
}
