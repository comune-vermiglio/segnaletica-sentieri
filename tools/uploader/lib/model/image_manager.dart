import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'position.dart';
import 'sign_image.dart';

class ImageManager extends ChangeNotifier {
  final List<SignImage> _images = [];

  void clean() {
    _images.clear();
    notifyListeners();
  }

  Future<void> loadDirectory(Directory dir) async {
    await for (var file in dir.list().where((e) => e is File)) {
      final image = await SignImage.fromFile(file as File);
      _images.add(image);
    }
    notifyListeners();
  }

  List<SignImage> get images => _images;

  List<SignImage> getCloserImages(Position position) {
    final tmp = _images
        .where((img) => img.position != null)
        .map((img) => (img.position!.distanceTo(position), img));
    return tmp.sorted((a, b) => a.$1.compareTo(b.$1)).map((e) => e.$2).toList();
  }
}
