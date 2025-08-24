import 'package:test/test.dart';
import 'package:uploader/position.dart';

void main() {
  group('Position', () {
    test('get distance to', () {
      const position1 = Position(latitude: 46.292476, longitude: 10.686197);
      const position2 = Position(latitude: 46.292504, longitude: 10.686482);
      final distance = position1.getDistanceTo(position2);
      expect(distance, closeTo(22.118, 0.001));
    });
  });
}
