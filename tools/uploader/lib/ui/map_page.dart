import 'package:flutter/material.dart';
import 'package:uploader/ui/app_map.dart';
import 'package:uploader/ui/utils.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: UiUtils.pagePadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppMap(),
      ),
    );
  }
}
