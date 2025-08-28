import 'package:uploader/model/position.dart';

class SignTable {}

class Pole {}

class Sign {
  final List<SignTable> tables;
  final Pole pole;
  final Position position;

  const Sign({
    required this.tables,
    required this.pole,
    required this.position,
  });
}
