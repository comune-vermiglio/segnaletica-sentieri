import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/place_manager.dart';

import 'model/image_manager.dart';
import 'model/sign_manager.dart';
import 'ui/app.dart';

void main() async {
  final imageManager = ImageManager();
  final signManager = SignManager();
  final placeManager = PlaceManager();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: imageManager),
        ChangeNotifierProvider.value(value: signManager),
        ChangeNotifierProvider.value(value: placeManager),
      ],
      child: MyApp(),
    ),
  );
}
