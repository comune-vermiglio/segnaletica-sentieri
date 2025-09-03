import 'package:uploader/model/sign_table.dart';

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
          ? row[5].trimLeft().trimRight()
          : null,
      secondString: row.length > 6 && row[6].isNotEmpty
          ? row[6].trimLeft().trimRight()
          : null,
      thirdString: row.length > 7 && row[7].isNotEmpty
          ? row[7].trimLeft().trimRight()
          : null,
    );
  }
}
