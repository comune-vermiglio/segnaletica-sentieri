import 'dart:math';

class Position {
  final double latitude;
  final double longitude;

  Position({required this.latitude, required this.longitude});

  double getDistanceTo(Position other) {
    const earthRadius = 6371e3; // meters
    final lat1 = latitude * (3.141592653589793238 / 180);
    final lat2 = other.latitude * (3.141592653589793238 / 180);
    final deltaLat = (other.latitude - latitude) * (3.141592653589793238 / 180);
    final deltaLon =
        (other.longitude - longitude) * (3.141592653589793238 / 180);
    final a =
        (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        (cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
