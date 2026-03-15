import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uploader/model/place.dart';
import 'package:uploader/ui/utils.dart';

import '../model/place_manager.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  var _loading = false;

  set loading(bool value) {
    if (value != _loading) {
      setState(() => _loading = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: UiUtils.pagePadding,
      child: Consumer<PlaceManager>(
        builder: (context, manager, _) {
          return _loading
              ? Center(child: CircularProgressIndicator())
              : manager.places.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nessun località trovato'),
                      const SizedBox(height: 20),
                      _LoadButton(
                        manager: manager,
                        loadingCallback: (val) => loading = val,
                      ),
                    ],
                  ),
                )
              : PlaceDataTable(manager: manager);
        },
      ),
    );
  }
}

class _LoadButton extends StatelessWidget {
  final PlaceManager manager;
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

class PlaceDataTable extends StatelessWidget {
  final PlaceManager manager;

  const PlaceDataTable({super.key, required this.manager});

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
                  'Nome',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Posizione',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Altitudine',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: [
              for (final place in manager.places)
                DataRow(
                  cells: [
                    DataCell(Text(place.name, textAlign: TextAlign.center)),
                    DataCell(
                      Text(
                        place.position == null
                            ? '---'
                            : '${place.position!.latitude.toString()},${place.position!.longitude.toString()}',
                      ),
                    ),
                    DataCell(
                      place.position == null
                          ? Text('---')
                          : _ElevationWidget(place: place),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 30),
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

class _ElevationWidget extends StatefulWidget {
  final Place place;
  const _ElevationWidget({required this.place});

  @override
  State<_ElevationWidget> createState() => _ElevationWidgetState();
}

class _ElevationWidgetState extends State<_ElevationWidget> {
  double? elevation;
  var loading = false;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Row(
      children: [
        if (elevation != null) ...[
          Text('${elevation!.toInt()} m'),
          const SizedBox(width: 8),
        ],
        IconButton(
          icon: Icon(Icons.sync),
          onPressed: () async {
            setState(() {
              loading = true;
            });
            final tmp = await widget.place.position!.elevation;
            setState(() {
              elevation = tmp;
              loading = false;
            });
          },
        ),
      ],
    );
  }
}
