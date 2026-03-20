import 'package:flutter_test/flutter_test.dart';
import 'package:uploader/model/place.dart';
import 'package:uploader/model/place_manager.dart';

class PlaceManagerMock extends Fake implements PlaceManager {
  var getPlaceByNameCalled = 0;
  List<(String, Place?)>? getPlaceByNameIO;

  PlaceManagerMock();

  @override
  Place? getPlaceByName(String name) {
    assert(
      getPlaceByNameIO != null &&
          getPlaceByNameCalled < getPlaceByNameIO!.length,
    );
    expect(getPlaceByNameIO![getPlaceByNameCalled].$1, equals(name));
    final tmp = getPlaceByNameIO![getPlaceByNameCalled].$2;
    getPlaceByNameCalled++;
    return tmp;
  }
}
