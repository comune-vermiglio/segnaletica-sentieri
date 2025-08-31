import 'dart:io';

import 'package:flutter/foundation.dart';

import 'sign_image.dart';

class ImageManager extends ChangeNotifier {
  final List<SignImage> _images = [];

  void clean() {
    _images.clear();
    notifyListeners();
  }

  Future<void> loadDirectory(Directory dir) async {
    _images.clear();
    await for (var file in dir.list().where((e) => e is File)) {
      final image = await SignImage.fromFile(file as File);
      _images.add(image);
    }
    notifyListeners();
  }

  List<SignImage> get images => _images;
}
