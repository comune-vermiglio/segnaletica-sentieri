import 'package:equatable/equatable.dart';
import 'package:uploader/model/position.dart';

class Place extends Equatable {
  final String name;
  final Position? position;

  const Place({required this.name, this.position});

  factory Place.fromCsv(List<dynamic> row) {
    if (row.length < 2) {
      throw ArgumentError('La riga deve avere almeno 2 colonne');
    }
    return Place(
      name: row[0].trim(),
      position: row[1].isNotEmpty ? Position.fromCsv(row[1]) : null,
    );
  }

  @override
  List<Object?> get props => [name, position];
}
