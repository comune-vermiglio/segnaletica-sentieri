import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Position extends Equatable {
  final double latitude;
  final double longitude;
  final int? elevation;

  const Position({
    required this.latitude,
    required this.longitude,
    this.elevation,
  });

  factory Position.fromCsv(String positionStr, [int? elevationStr]) {
    var tmp = positionStr.trim();
    final latLonStrs = tmp.substring(1, tmp.length - 1).split(',');
    return Position(
      latitude: double.parse(latLonStrs[0].trim()),
      longitude: double.parse(latLonStrs[1].trim()),
      elevation: elevationStr,
    );
  }

  // Returns distance in meters.
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
  List<Object?> get props => [latitude, longitude, elevation];

  @override
  String toString() =>
      'Lat: $latitude, Lng: $longitude ${elevation != null ? ', Elev: $elevation m' : ''}';

  LatLng get latLng => LatLng(latitude, longitude);

  Future<double?> get elevationFromInternet async {
    final response = await http.get(
      Uri.parse(
        'https://api.open-meteo.com/v1/elevation?latitude=$latitude&longitude=$longitude',
      ),
    );
    if (response.statusCode == 200) {
      final body = (jsonDecode(response.body)['elevation']);
      if (body.isNotEmpty) {
        return body.first;
      }
    }
    return null;
  }
}
