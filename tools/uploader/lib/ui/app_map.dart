import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/image_manager.dart';
import 'package:uploader/model/sign_manager.dart';
import 'package:uploader/model/sign_with_tables.dart';
import 'package:uploader/ui/sign_with_tables_widget.dart';

import '../model/sign.dart';
import '../model/sign_image.dart';

class AppMap extends StatefulWidget {
  final Sign? signHighlight;
  final SignImage? imageHighLight;
  final bool showControls;
  final bool showTooltip;

  const AppMap({
    super.key,
    this.signHighlight,
    this.imageHighLight,
    this.showControls = true,
    this.showTooltip = true,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  var showImages = true;
  var showSigns = true;
  @override
  Widget build(BuildContext context) {
    LatLng center;
    double zoomLevel;
    if (widget.signHighlight != null) {
      center = widget.signHighlight!.position.latLng;
      zoomLevel = 18;
    } else if (widget.imageHighLight != null &&
        widget.imageHighLight!.position != null) {
      center = widget.imageHighLight!.position!.latLng;
      zoomLevel = 18;
    } else {
      center = LatLng(46.296905, 10.691365);
      zoomLevel = 14;
    }
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: zoomLevel),
      children: [
        TileLayer(urlTemplate: dotenv.env['MAP_URL']),
        if (widget.showControls)
          Positioned(
            top: 0,
            right: 0,
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: showImages,
                          onChanged: (value) {
                            setState(() {
                              showImages = value ?? true;
                            });
                          },
                        ),
                        const Text('Mostra immagini'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: showSigns,
                          onChanged: (value) {
                            setState(() {
                              showSigns = value ?? true;
                            });
                          },
                        ),
                        const Text('Mostra tabelle'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        Consumer2<ImageManager, SignManager>(
          builder: (context, imageManager, signManager, _) {
            return MarkerLayer(
              markers: [
                if (showSigns)
                  ...signManager.signs.map(
                    (sign) => Marker(
                      point: sign.position.latLng,
                      child: _SignMarker(
                        sign: sign,
                        selected: sign == widget.signHighlight,
                        showTooltip: widget.showTooltip,
                      ),
                    ),
                  ),
                if (showImages)
                  ...imageManager.images
                      .where((img) => img.position != null)
                      .map(
                        (img) => Marker(
                          point: img.position!.latLng,
                          child: _ImgMarker(
                            img: img,
                            selected: img == widget.imageHighLight,
                            showTooltip: widget.showTooltip,
                          ),
                        ),
                      ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ImgMarker extends StatelessWidget {
  final SignImage img;
  final bool selected;
  final bool showTooltip;
  const _ImgMarker({
    required this.img,
    required this.selected,
    required this.showTooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTooltip) {
      return _child;
    }
    return Tooltip(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: EdgeInsets.zero,
      richMessage: WidgetSpan(
        child: SizedBox(
          width: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.file(img.file),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 20,
                  child: Container(
                    color: Colors.black.withAlpha(100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        basename(img.file.path),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: _child,
    );
  }

  Widget get _child => Icon(
    Icons.image,
    color: selected ? Colors.red : Colors.black,
    size: selected ? 30 : 20,
  );
}

class _SignMarker extends StatelessWidget {
  final Sign sign;
  final bool selected;
  final bool showTooltip;

  const _SignMarker({
    required this.sign,
    required this.selected,
    required this.showTooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (showTooltip && sign is SignWithTables) {
      return Tooltip(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: EdgeInsets.zero,
        richMessage: WidgetSpan(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign.position.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  for (final (index, table)
                      in (sign as SignWithTables).tables.indexed)
                    Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          table.status.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  SignWithTablesWidget(
                    sign: sign as SignWithTables,
                    small: true,
                    showTooltip: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        child: _child,
      );
    } else {
      return _child;
    }
  }

  Widget get _child => Icon(
    sign is SignWithTables ? Icons.signpost : Icons.drag_handle_rounded,
    color: selected ? Colors.red : Colors.black,
    size: selected ? 30 : 20,
  );
}
