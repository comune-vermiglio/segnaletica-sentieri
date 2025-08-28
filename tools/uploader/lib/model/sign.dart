import 'position.dart';
import 'sign_pole.dart';
import 'sign_table.dart';

class Sign {
  final List<SignTable> tables;
  final SignPole pole;
  final Position position;

  const Sign({
    required this.tables,
    required this.pole,
    required this.position,
  });
}
