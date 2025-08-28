import 'dart:io';

import 'package:test/test.dart';
import 'package:uploader/model/sign_image.dart';
import 'package:uploader/model/position.dart';

void main() {
  group('SignImage', () {
    test('position', () async {
      final image = SignImage(File('test/data/IMG_7788.HEIC'));
      final position = await image.position;
      expect(
        position,
        equals(
          const Position(
            latitude: 46.289699999999996,
            longitude: 10.682355555555555,
          ),
        ),
      );
    });
  });
}
