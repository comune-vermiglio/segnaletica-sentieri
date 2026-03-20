import 'package:equatable/equatable.dart';

import 'place_manager.dart';

class SignTableString extends Equatable {
  final String text;
  final Duration? time;

  const SignTableString(this.text, {this.time});

  @override
  List<Object?> get props => [text, time];

  bool get isEmpty => text.trim().isEmpty;

  bool isOk({required PlaceManager placeManager}) =>
      placeManager.containsPlace(text);
}
