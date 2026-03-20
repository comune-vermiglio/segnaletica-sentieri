import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/position.dart';

import 'sign_table.dart';
import 'sign_table_string.dart';

class PlaceTable extends SignTable {
  const PlaceTable({
    required super.status,
    super.firstString,
    super.secondString,
    super.thirdString,
  });

  @override
  List<Object?> get props => [status, firstString, secondString, thirdString];

  factory PlaceTable.fromCsv(List<dynamic> row) {
    assert(row[3] == 'Località');
    return PlaceTable(
      status: SignTableStatus.fromString(row[2]),
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

  @override
  Future<List<String>> toCsv({
    required bool timesFromInternet,
    required Position signPosition,
    required PlaceManager placeManager,
  }) async {
    return [
      status.toString(),
      'Località',
      'Sinistra',
      firstString?.text ?? '',
      secondString?.text ?? '',
      thirdString?.text ?? '',
    ];
  }
}
