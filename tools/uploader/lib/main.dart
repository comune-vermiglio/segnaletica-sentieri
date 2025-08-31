import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/image_manager.dart';
import 'model/sign_manager.dart';
import 'ui/app.dart';

void main() {
  final imageManager = ImageManager();
  final signManager = SignManager();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: imageManager),
        ChangeNotifierProvider.value(value: signManager),
      ],
      child: MyApp(),
    ),
  );
}
