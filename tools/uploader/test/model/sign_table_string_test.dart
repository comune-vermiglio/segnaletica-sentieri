import 'package:flutter_test/flutter_test.dart';
import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/sign_table_string.dart';

class PlaceManagerMock extends Fake implements PlaceManager {
  (String, bool)? containsPlaceIO;

  @override
  bool containsPlace(String name) {
    assert(containsPlaceIO != null);
    expect(containsPlaceIO!.$1, name);
    return containsPlaceIO!.$2;
  }
}

void main() {
  group('SignTableString', () {
    test('is empty', () {
      expect(SignTableString('  ').isEmpty, isTrue);
      expect(SignTableString('').isEmpty, isTrue);
      expect(SignTableString('a  ').isEmpty, isFalse);
    });

    test('status', () {
      final placeManager = PlaceManagerMock();
      const text = 'some place';
      placeManager.containsPlaceIO = (text, true);
      expect(SignTableString(text).isOk(placeManager: placeManager), isTrue);
      placeManager.containsPlaceIO = (text, false);
      expect(SignTableString(text).isOk(placeManager: placeManager), isFalse);
    });
  });
}
