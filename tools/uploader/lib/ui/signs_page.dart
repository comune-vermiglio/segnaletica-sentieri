import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/direction_table.dart';
import 'package:uploader/model/image_manager.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/place_table.dart';
import 'package:uploader/model/sign_with_tables.dart';
import 'package:uploader/ui/app_map.dart';
import 'package:uploader/ui/utils.dart';

import '../model/sign.dart';
import '../model/sign_manager.dart';
import '../model/sign_table.dart';

class SignsPage extends StatefulWidget {
  const SignsPage({super.key});

  @override
  State<SignsPage> createState() => _SignsPageState();
}

const _distanceOk = 10.0;

class _SignsPageState extends State<SignsPage> {
  var _loading = false;
  var _indexSelected = 0;

  set loading(bool value) {
    if (value != _loading) {
      setState(() => _loading = value);
    }
  }

  set indexSelected(int value) {
    if (value != _indexSelected) {
      setState(() => _indexSelected = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: UiUtils.pagePadding,
      child: Consumer<SignManager>(
        builder: (context, manager, _) {
          return _loading
              ? Center(child: CircularProgressIndicator())
              : manager.signs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nessun cartello trovato'),
                      const SizedBox(height: 20),
                      _LoadButton(
                        manager: manager,
                        loadingCallback: (val) => loading = val,
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SignDataTable(
                        manager: manager,
                        indexSelected: _indexSelected,
                        onSelected: (value) => indexSelected = value,
                        loadingCallback: (val) => loading = val,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Card(
                        child: SignSelectedWidget(
                          sign: manager.signs[_indexSelected],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _LoadButton extends StatelessWidget {
  final SignManager manager;
  final Function(bool) loadingCallback;
  const _LoadButton({required this.manager, required this.loadingCallback});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final snack = ScaffoldMessenger.of(context);
        final selectedCsvFile = await FilePicker.platform.pickFiles(
          allowedExtensions: ['csv'],
          type: FileType.custom,
        );
        if (selectedCsvFile != null &&
            selectedCsvFile.files.isNotEmpty &&
            selectedCsvFile.files.single.path != null) {
          loadingCallback(true);
          try {
            await manager.loadCsv(File(selectedCsvFile.files.single.path!));
          } catch (e) {
            final snackBar = SnackBar(
              content: Text('Errore nel file CSV. $e'),
              duration: const Duration(minutes: 1),
              showCloseIcon: true,
            );
            snack.showSnackBar(snackBar);
          } finally {
            loadingCallback(false);
          }
        }
      },
      child: const Text('Apri file CSV'),
    );
  }
}

class SignDataTable extends StatelessWidget {
  final SignManager manager;
  final int indexSelected;
  final Function(int) onSelected;
  final Function(bool) loadingCallback;

  const SignDataTable({
    super.key,
    required this.manager,
    required this.indexSelected,
    required this.onSelected,
    required this.loadingCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        children: [
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Posizione',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  '# tabelle',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Immagine',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tabelle',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: [
              for (final (index, sign) in manager.signs.indexed)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${sign.position.latitude.toString()},${sign.position.longitude.toString()}',
                      ),
                    ),
                    if (sign is SignWithTables)
                      DataCell(
                        Text(
                          sign.tables.length.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (sign is OnlyMarkSign)
                      DataCell(Text('---', textAlign: TextAlign.center)),
                    DataCell(
                      Consumer<ImageManager>(
                        builder: (context, imgMan, _) {
                          final closerImgs = imgMan.getCloserImages(
                            sign.position,
                          );
                          final ok =
                              closerImgs.isNotEmpty &&
                              closerImgs.first.position!.distanceTo(
                                    sign.position,
                                  ) <=
                                  _distanceOk;
                          return Icon(
                            ok
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: ok
                                ? Colors.green.withAlpha(160)
                                : Colors.red.withAlpha(160),
                          );
                        },
                      ),
                    ),
                    DataCell(
                      Builder(
                        builder: (context) {
                          bool ok;
                          if (sign is SignWithTables) {
                            ok = sign.tables
                                .map((table) => table.isOk)
                                .reduce((el, val) => val = val & el);
                          } else {
                            ok = true;
                          }
                          return Icon(
                            ok
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: ok
                                ? Colors.green.withAlpha(160)
                                : Colors.red.withAlpha(160),
                          );
                        },
                      ),
                    ),
                  ],
                  selected: manager.signs.indexOf(sign) == indexSelected,
                  onSelectChanged: (selected) {
                    if (selected ?? false) {
                      onSelected(index);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 30),
          _LoadButton(manager: manager, loadingCallback: loadingCallback),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => manager.clean(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Cancella'),
                const SizedBox(width: 8),
                Icon(Icons.delete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignSelectedWidget extends StatelessWidget {
  final Sign sign;

  const SignSelectedWidget({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SignTitle('Posizione', first: true),
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppMap(signHighlight: sign, key: UniqueKey()),
          ),
        ),
        if (sign is OnlyMarkSign)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('Solo segno rosso/bianco'),
          ),
        if (sign is SignWithTables) ...[
          SignTitle('Palo'),
          Text((sign as SignWithTables).pole.status.toString()),
          SignTitle('Tabelle'),
          for (final (index, table) in (sign as SignWithTables).tables.indexed)
            Row(
              children: [
                Text('${index + 1}.'),
                const SizedBox(width: 6),
                Text(table.status.toString()),
              ],
            ),
          const SizedBox(height: 20),
          for (final table in (sign as SignWithTables).tables) ...[
            if (table is DirectionTable) DirectionTableWidget(table),
            if (table is PlaceTable) PlaceTableWidget(table),
            const SizedBox(height: 20),
          ],
        ],
        SignImage(sign),
      ],
    );
  }
}

class SignTitle extends StatelessWidget {
  final String text;
  final bool first;
  const SignTitle(this.text, {super.key, this.first = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, top: first ? 0 : 20),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

const _tableHeight = 140.0;

class DirectionTableWidget extends StatelessWidget {
  static const arrowWidth = 50.0;
  static const endMarkerWidth = 60.0;
  final DirectionTable table;
  const DirectionTableWidget(this.table, {super.key});

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
                height: 40,
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
                height: 40,
                bottom: 0,
                child: Container(color: Colors.red),
              ),
              Positioned(
                left: table.direction == SignTableDirection.right
                    ? arrowWidth + endMarkerWidth
                    : null,
                right: table.direction == SignTableDirection.left
                    ? arrowWidth + endMarkerWidth
                    : null,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment:
                        table.direction == SignTableDirection.left
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children:
                        [
                          if (table.firstString != null) table.firstString,
                          if (table.secondString != null) table.secondString,
                          if (table.thirdString != null) table.thirdString,
                        ].map((str) {
                          return Text(
                            str!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Colors.black,
                            ),
                          );
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
  const PlaceTableWidget(this.table, {super.key});

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
            maxWidth: 260,
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
                      str!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black,
                      ),
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

class SignImage extends StatelessWidget {
  final Sign sign;
  const SignImage(this.sign, {super.key});

  @override
  Widget build(BuildContext context) {
    final images = Provider.of<ImageManager>(
      context,
      listen: false,
    ).getCloserImages(sign.position);
    if (images.isEmpty ||
        images.first.position!.distanceTo(sign.position) > _distanceOk) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignTitle('Immagine'),
          Text('Nessuna immagine vicina trovata.'),
          if (images.isNotEmpty)
            Text(
              'Distanza immagine più vicina: ${images.first.position!.distanceTo(sign.position).toStringAsFixed(2)}m',
            ),
        ],
      );
    }
    final image = images.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignTitle('Immagine'),
        Center(
          child: SizedBox(
            width: 600,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(image.file),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('File immagine: ${basename(image.file.path)}'),
        Text(
          'Distanza immagine: ${image.position!.distanceTo(sign.position).toStringAsFixed(2)}m',
        ),
        if (images.length > 1) ...[
          Text(
            'Distanza prossima immagine: ${images[1].position!.distanceTo(sign.position).toStringAsFixed(2)}m',
          ),
        ],
      ],
    );
  }
}
