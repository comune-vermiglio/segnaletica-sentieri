import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/place_manager.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/position.dart';
import 'package:uploader/model/sign_table.dart';
import 'package:uploader/model/sign_with_tables.dart';
import 'package:uploader/model/time_computing.dart';

class SignWithTablesWidget extends StatelessWidget {
  final SignWithTables sign;
  final bool small;
  final bool showTooltip;

  const SignWithTablesWidget({
    super.key,
    required this.sign,
    this.small = false,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: small ? 6 : 20),
        for (final table in sign.tables) ...[
          if (table is DirectionTable)
            DirectionTableWidget(table, sign.position, small, showTooltip),
          if (table is PlaceTable) PlaceTableWidget(table, small),
          SizedBox(height: small ? 6 : 20),
        ],
      ],
    );
  }
}

class DirectionTableWidget extends StatelessWidget {
  final DirectionTable table;
  final Position position;
  final bool small;
  final bool showTooltip;

  const DirectionTableWidget(
    this.table,
    this.position,
    this.small,
    this.showTooltip, {
    super.key,
  });

  double get _tableHeight => small ? 80 : 140;
  double get arrowWidth => small ? 30 : 50;
  double get endMarkerWidth => small ? 40 : 60;

  @override
  Widget build(BuildContext context) {
    if (table.status != SignTableStatus.remove) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: _tableHeight,
            minHeight: _tableHeight,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: arrowWidth,
                right: arrowWidth,
                top: 0,
                bottom: 0,
                child: Container(color: Colors.white),
              ),
              Positioned(
                left: table.direction == SignTableDirection.left ? 0 : null,
                right: table.direction == SignTableDirection.right ? 0 : null,
                width: arrowWidth,
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: TrianglePainter(direction: table.direction),
                ),
              ),
              Positioned(
                left: table.direction == SignTableDirection.right
                    ? arrowWidth
                    : null,
                right: table.direction == SignTableDirection.left
                    ? arrowWidth
                    : null,
                width: endMarkerWidth,
                height: small ? 25 : 40,
                top: 0,
                child: Container(color: Colors.red),
              ),
              Positioned(
                left: table.direction == SignTableDirection.right
                    ? arrowWidth
                    : null,
                right: table.direction == SignTableDirection.left
                    ? arrowWidth
                    : null,
                width: endMarkerWidth,
                height: small ? 25 : 40,
                bottom: 0,
                child: Container(color: Colors.red),
              ),
              Positioned(
                left: table.direction == SignTableDirection.right
                    ? arrowWidth + endMarkerWidth
                    : arrowWidth,
                right: table.direction == SignTableDirection.left
                    ? arrowWidth + endMarkerWidth
                    : arrowWidth,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        [
                          if (table.firstString != null) table.firstString,
                          if (table.secondString != null) table.secondString,
                          if (table.thirdString != null) table.thirdString,
                        ].map((str) {
                          final placeManager = Provider.of<PlaceManager>(
                            context,
                            listen: false,
                          );
                          if (str!.isOk(placeManager: placeManager)) {
                            final place = placeManager.getPlaceByName(str.text);
                            assert(place != null);
                            const timeComputing = TimeComputing();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  str.text,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: small ? 14 : 26,
                                    color: Colors.black,
                                  ),
                                ),
                                FutureBuilder(
                                  future: position.elevationFromInternet,
                                  builder: (context, snapshot) {
                                    String message;
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      if (place?.position != null) {
                                        final travelInfo = timeComputing
                                            .getTravelDuration(
                                              position.copyWith(
                                                elevation: snapshot.data!,
                                              ),
                                              place!.position!,
                                            );
                                        final fromEle = travelInfo?.$1;
                                        final toEle = travelInfo?.$2;
                                        final minutes = travelInfo?.$3;
                                        if (fromEle == null ||
                                            toEle == null ||
                                            minutes == null) {
                                          message =
                                              'Errore nel computo del tempo di percorrenza';
                                        } else {
                                          message =
                                              'Da ${fromEle}m a ${place.name} (${toEle}m). Differenza: ${toEle - fromEle}m. Distanza lineare: ${place.position?.distanceTo(position).toInt()}m. Tempo stimato: ${minutes.inHours}h ${minutes.inMinutes.remainder(60)}min. Pendenza media: ${(((toEle - fromEle).abs() / (place.position!.distanceTo(position))) * 100).toStringAsFixed(1)}%';
                                        }
                                      } else {
                                        message =
                                            'Destinazione non disponibile';
                                      }
                                    } else {
                                      message =
                                          'Recupero altitudine cartello da internet...';
                                    }
                                    final text = str.time == null
                                        ? '---'
                                        : '${str.time?.inHours}.${str.time?.inMinutes.remainder(60).toString().padLeft(2, '0')}';
                                    if (showTooltip) {
                                      return Tooltip(
                                        message: message,
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: small ? 14 : 26,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        text,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: small ? 14 : 26,
                                          color: Colors.black,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Text(
                              str.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red,
                              ),
                            );
                          }
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class TrianglePainter extends CustomPainter {
  final SignTableDirection direction;

  TrianglePainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawPath(getPath(size.width, size.height), paint);
  }

  Path getPath(double x, double y) {
    switch (direction) {
      case SignTableDirection.left:
        return Path()
          ..moveTo(x, 0)
          ..lineTo(0, y / 2)
          ..lineTo(x, y)
          ..lineTo(x, 0);
      case SignTableDirection.right:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(x, y / 2)
          ..lineTo(0, y)
          ..lineTo(0, 0);
    }
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.direction != direction;
  }
}

class PlaceTableWidget extends StatelessWidget {
  final PlaceTable table;
  final bool small;
  const PlaceTableWidget(this.table, this.small, {super.key});

  double get _tableHeight => small ? 80 : 140;

  @override
  Widget build(BuildContext context) {
    if (table.status != SignTableStatus.remove) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Colors.white,
          ),
          constraints: BoxConstraints(
            maxWidth: small ? 160 : 260,
            maxHeight: _tableHeight,
            minHeight: _tableHeight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [
                    if (table.firstString != null) table.firstString,
                    if (table.secondString != null) table.secondString,
                    if (table.thirdString != null) table.thirdString,
                  ].map((str) {
                    return Text(
                      str!.text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: small ? 14 : 26,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }).toList(),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
