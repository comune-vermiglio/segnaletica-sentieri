import 'dart:math';

import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final double latitude;
  final double longitude;

  const Position({required this.latitude, required this.longitude});

  double distanceTo(Position other) {
    const earthRadius = 6371e3; // meters
    final lat1 = latitude * (pi / 180);
    final lat2 = other.latitude * (pi / 180);
    final deltaLat = (other.latitude - latitude) * (pi / 180);
    final deltaLon = (other.longitude - longitude) * (pi / 180);
    final a =
        (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        (cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'Lat: $latitude, Lng: $longitude';
}
