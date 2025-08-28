import 'package:equatable/equatable.dart';

enum SignPoleStatus {
  ok,
  add,
  change,
  remove,
  notNeeded,
  onlyMark;

  factory SignPoleStatus.fromCsv(List<String> values) {
    switch (values[1]) {
      case 'Ok':
        return SignPoleStatus.ok;
      case 'Nuovo':
        return SignPoleStatus.add;
      case 'Cambiare':
        return SignPoleStatus.change;
      case 'Eliminare':
        return SignPoleStatus.remove;
      case 'Non necessario':
        return SignPoleStatus.notNeeded;
      case 'Solo segno rosso':
        return SignPoleStatus.onlyMark;
      default:
        throw ArgumentError('Unknown SignPoleStatus: ${values[1]}');
    }
  }
}

class SignPole extends Equatable {
  final SignPoleStatus status;

  const SignPole({required this.status});

  factory SignPole.fromCsv(List<String> values) {
    return SignPole(status: SignPoleStatus.fromCsv(values));
  }

  @override
  List<Object?> get props => [status];
}
