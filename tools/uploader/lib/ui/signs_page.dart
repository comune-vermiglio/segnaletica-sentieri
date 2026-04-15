import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/image_manager.dart';
import 'package:uploader/model/only_mark_sign.dart';
import 'package:uploader/model/sign_with_tables.dart';
import 'package:uploader/ui/app_map.dart';
import 'package:uploader/ui/sign_with_tables_widget.dart';
import 'package:uploader/ui/utils.dart';

import '../model/place_manager.dart';
import '../model/sign.dart';
import '../model/sign_manager.dart';

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

  const SignDataTable({
    super.key,
    required this.manager,
    required this.indexSelected,
    required this.onSelected,
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
                          final placeManager = Provider.of<PlaceManager>(
                            context,
                            listen: false,
                          );
                          bool ok;
                          if (sign is SignWithTables) {
                            ok = sign.tables
                                .map(
                                  (table) =>
                                      table.isOk(placeManager: placeManager),
                                )
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
          Row(
            children: [
              Expanded(
                child: FilledButton(
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
              ),
              // const SizedBox(width: 20),
              // Expanded(child: _SaveButton(manager: manager)),
            ],
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
            child: AppMap(
              signHighlight: sign,
              key: UniqueKey(),
              showControls: false,
              showTooltip: false,
            ),
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
          SignWithTablesWidget(sign: sign as SignWithTables),
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

class _SaveButton extends StatefulWidget {
  final SignManager manager;
  const _SaveButton({required this.manager});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _loading
          ? null
          : () async {
              final selectedCsvFile = await FilePicker.platform.saveFile(
                allowedExtensions: ['csv'],
                type: FileType.custom,
              );
              if (selectedCsvFile != null && selectedCsvFile.isNotEmpty) {
                setState(() => _loading = true);
                await widget.manager.saveCsv(
                  File(selectedCsvFile),
                  overwriteTimes: true,
                );
                setState(() => _loading = false);
              }
            },
      child: _loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 1),
            )
          : const Text('Salva file CSV'),
    );
  }
}
