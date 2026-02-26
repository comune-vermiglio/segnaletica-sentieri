import 'package:test/test.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/time_computing.dart';

void main() {
  group('TimeComputing', () {
    test('get travel info - flat', () async {
      const timeComputing = TimeComputing();
      final from = Position(latitude: 46.2858245, longitude: 10.6727306);
      final to = Position(latitude: 46.2771804, longitude: 10.6605182);
      final result = await timeComputing.getTravelDuration(from, to);
      expect(result!.$1, equals(1199));
      expect(result.$2, equals(1243));
      expect(result.$3, const Duration(minutes: 25));
    });

    test('get travel info - up hill', () async {
      const timeComputing = TimeComputing();
      final from = Position(latitude: 46.2858245, longitude: 10.6727306);
      final to = Position(latitude: 46.2841637, longitude: 10.6944552);
      final result = await timeComputing.getTravelDuration(from, to);
      expect(result!.$1, equals(1199));
      expect(result.$2, equals(1567));
      expect(result.$3, const Duration(minutes: 75));
    });

    test('get travel info - down hill', () async {
      const timeComputing = TimeComputing();
      final from = Position(latitude: 46.2841637, longitude: 10.6944552);
      final to = Position(latitude: 46.2858245, longitude: 10.6727306);
      final result = await timeComputing.getTravelDuration(from, to);
      expect(result!.$1, equals(1567));
      expect(result.$2, equals(1199));
      expect(result.$3, const Duration(minutes: 60));
    });
  });
}
