import 'package:equatable/equatable.dart';

import 'place_manager.dart';

class SignTableString extends Equatable {
  final String text;

  const SignTableString(this.text);

  @override
  List<Object?> get props => [text];

  bool get isEmpty => text.trim().isEmpty;

  bool isOk({required PlaceManager placeManager}) =>
      placeManager.containsPlace(text);
}
