import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/image_manager.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  var _loading = false;

  set loading(bool value) {
    if (value != _loading) {
      setState(() => _loading = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageManager>(
      builder: (context, manager, _) {
        return Scaffold(
          floatingActionButton: !_loading && manager.images.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => manager.clean(),
                  child: const Icon(Icons.delete),
                )
              : null,

          body: _loading
              ? CircularProgressIndicator()
              : manager.images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nessuna immagine trovata'),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          final selectedDirectory = await FilePicker.platform
                              .getDirectoryPath();
                          if (selectedDirectory != null) {
                            loading = true;
                            await manager.loadDirectory(
                              Directory(selectedDirectory),
                            );
                            loading = false;
                          }
                        },
                        child: const Text('Apri cartella immagini'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: manager.images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            manager.images[index].file,
                            fit: BoxFit.cover,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }
                                  return Container(
                                    color: Colors.white.withAlpha(10),
                                  );
                                },
                          ),
                          FutureBuilder(
                            future: manager.images[index].position,
                            builder: (context, snap) {
                              return Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 30,
                                child: Container(
                                  color: snap.hasData
                                      ? snap.data != null
                                            ? Colors.green.withAlpha(180)
                                            : Colors.red.withAlpha(180)
                                      : Colors.black.withAlpha(180),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Tooltip(
                                          message:
                                              manager.images[index].file.path,
                                          child: Icon(Icons.image, size: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Tooltip(
                                          message: snap.data?.toString() ?? '',
                                          child: Icon(
                                            Icons.location_on,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
