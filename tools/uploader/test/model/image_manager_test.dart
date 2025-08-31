import 'dart:io';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:uploader/model/image_manager.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign_image.dart';

void main() {
  group('ImageManager', () {
    test('get closer images', () async {
      final firstImg = await SignImage.fromFile(
        File('test/data/imgs/IMG_7788.HEIC'),
      );
      final secondImg = await SignImage.fromFile(
        File('test/data/imgs/IMG_7789.HEIC'),
      );
      final thirdImg = await SignImage.fromFile(
        File('test/data/imgs/IMG_7790.HEIC'),
      );
      final manager = ImageManager();
      await manager.loadDirectory(Directory('test/data/imgs'));
      expect(
        const DeepCollectionEquality().equals(manager.images, [
          firstImg,
          secondImg,
          thirdImg,
        ]),
        isTrue,
      );
      final images = manager.getCloserImages(
        Position(latitude: 46.289699999999996, longitude: 10.682355555555555),
      );
      expect(images, <SignImage>[firstImg, thirdImg, secondImg]);
    });
  });
}
