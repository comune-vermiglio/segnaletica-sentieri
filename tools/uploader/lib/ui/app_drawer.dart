import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int? selectedIndex;
  final void Function(int)? onDestinationSelected;

  const AppDrawer({super.key, this.selectedIndex, this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: NavigationRail(
        minWidth: 80,
        labelType: NavigationRailLabelType.all,
        destinations: [
          NavigationRailDestination(
            label: Text('Immagini'),
            icon: Icon(Icons.image_outlined),
            selectedIcon: Icon(Icons.image),
          ),
          NavigationRailDestination(
            padding: const EdgeInsets.symmetric(vertical: 14),
            label: Text('Cartelli'),
            icon: Icon(Icons.signpost_outlined),
            selectedIcon: Icon(Icons.signpost),
          ),
          NavigationRailDestination(
            label: Text('Mappa'),
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
          ),
        ],
        selectedIndex: selectedIndex,
        useIndicator: true,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
