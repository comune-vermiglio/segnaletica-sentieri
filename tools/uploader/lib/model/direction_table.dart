import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/time_computing.dart';

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

  @override
  String toString() {
    return switch (this) {
      SignTableDirection.left => 'Sinistra',
      SignTableDirection.right => 'Destra',
    };
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
    assert(row.length > 10 && row[3] == 'Direzione');
    return DirectionTable(
      status: SignTableStatus.fromString(row[2]),
      direction: SignTableDirection.fromString(row[4]),
      firstString: row[5].trim().isEmpty
          ? null
          : SignTableString(
              row[5].trim(),
              time: DirectionTable._parseTime(row[6].trim()),
            ),
      secondString: row[7].trim().isEmpty
          ? null
          : SignTableString(
              row[7].trim(),
              time: DirectionTable._parseTime(row[8].trim()),
            ),
      thirdString: row[9].trim().isEmpty
          ? null
          : SignTableString(
              row[9].trim(),
              time: DirectionTable._parseTime(row[10].trim()),
            ),
    );
  }

  @override
  Future<List<String>> toCsv({
    required bool overwriteTimes,
    required Position signPosition,
    required PlaceManager placeManager,
  }) async {
    const timeComputing = TimeComputing();
    final tmpTimes = [firstString?.time, secondString?.time, thirdString?.time];
    final tmpText = [firstString?.text, secondString?.text, thirdString?.text];
    if (overwriteTimes) {
      for (var i = 0; i < tmpTimes.length; i++) {
        if (tmpText[i] != null) {
          final place = placeManager.getPlaceByName(tmpText[i]!);
          if (place != null && place.position != null) {
            final placePosition = place.position!;
            var tmpSignPosition = signPosition;
            if (tmpSignPosition.elevation == null) {
              tmpSignPosition = tmpSignPosition.copyWith(
                elevation: await signPosition.elevationFromInternet,
              );
            }
            print(
              'Computing time from $signPosition to ${place.position} for ${tmpText[i]}',
            );
            final tmp = timeComputing.getTravelDuration(
              tmpSignPosition,
              placePosition,
            );
            await Future.delayed(const Duration(seconds: 2));
            if (tmp != null) {
              tmpTimes[i] = tmp.$3;
            }
          }
        }
      }
    }
    return [
      status.toString(),
      'Direzione',
      direction.toString(),
      tmpText[0] ?? '',
      if (tmpTimes[0] != null) _formatTime(tmpTimes[0]!) else '',
      tmpText[1] ?? '',
      if (tmpTimes[1] != null) _formatTime(tmpTimes[1]!) else '',
      tmpText[2] ?? '',
      if (tmpTimes[2] != null) _formatTime(tmpTimes[2]!) else '',
    ];
  }

  String _formatTime(Duration time) =>
      '${time.inHours}.${time.inMinutes.remainder(60).toString().padLeft(2, '0')}';

  static Duration? _parseTime(String time) {
    if (time.isEmpty) {
      return null;
    }
    final parts = time.split('.');
    if (parts.length != 2) {
      throw ArgumentError('Formato del tempo non valido: $time');
    }
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  @override
  bool isOk({required PlaceManager placeManager}) =>
      super.isOk(placeManager: placeManager) &&
      (firstString?.isOk(placeManager: placeManager) ?? true) &&
      (secondString?.isOk(placeManager: placeManager) ?? true) &&
      (thirdString?.isOk(placeManager: placeManager) ?? true);
}
