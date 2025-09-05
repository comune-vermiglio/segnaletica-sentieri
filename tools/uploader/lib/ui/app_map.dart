import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/image_manager.dart';
import 'package:uploader/model/sign_manager.dart';

import '../model/sign.dart';
import '../model/sign_image.dart';

class AppMap extends StatelessWidget {
  final Sign? signHighlight;
  final SignImage? imageHighLight;

  const AppMap({super.key, this.signHighlight, this.imageHighLight});

  @override
  Widget build(BuildContext context) {
    LatLng center;
    double zoomLevel;
    if (signHighlight != null) {
      center = signHighlight!.position.latLng;
      zoomLevel = 18;
    } else if (imageHighLight != null && imageHighLight!.position != null) {
      center = imageHighLight!.position!.latLng;
      zoomLevel = 18;
    } else {
      center = LatLng(46.296905, 10.691365);
      zoomLevel = 14;
    }
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: zoomLevel),
      children: [
        TileLayer(urlTemplate: dotenv.env['MAP_URL']),
        Consumer2<ImageManager, SignManager>(
          builder: (context, imageManager, signManager, _) {
            return MarkerLayer(
              markers: [
                ...signManager.signs.map(
                  (sign) => Marker(
                    point: sign.position.latLng,
                    child: Icon(
                      Icons.signpost,
                      color: sign == signHighlight ? Colors.red : Colors.black,
                      size: sign == signHighlight ? 30 : 20,
                    ),
                  ),
                ),
                ...imageManager.images
                    .where((img) => img.position != null)
                    .map(
                      (img) => Marker(
                        point: img.position!.latLng,
                        child: Tooltip(
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            basename(img.file.path),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
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
                          child: Icon(
                            Icons.image,
                            color: img == imageHighLight
                                ? Colors.red
                                : Colors.black,
                            size: img == imageHighLight ? 30 : 20,
                          ),
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
