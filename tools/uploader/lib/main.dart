import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/image_manager.dart';
import 'ui/app.dart';

void main() {
  final imageManager = ImageManager();
  runApp(ChangeNotifierProvider.value(value: imageManager, child: MyApp()));
}
