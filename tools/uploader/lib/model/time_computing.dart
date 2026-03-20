import 'position.dart';

class TimeComputing {
  const TimeComputing();

  (int, int, Duration)? getTravelDuration(Position from, Position to) {
    final fromElevation = from.elevation;
    final toElevation = to.elevation;
    if (fromElevation != null && toElevation != null) {
      final diffElevation = (toElevation - fromElevation).abs();
      final distance = from.distanceTo(to);
      final percent = (diffElevation / distance) * 100;
      int minutes;
      if (percent > 10) {
        if (toElevation > fromElevation) {
          minutes = (diffElevation / 300 * 60).ceil();
        } else {
          minutes = (diffElevation / 400 * 60).ceil();
        }
      } else {
        minutes = (distance / 1000 * 17).ceil();
      }
      return (
        fromElevation,
        toElevation,
        Duration(minutes: (minutes / 5).ceil() * 5),
      );
    }
    return null;
  }
}
