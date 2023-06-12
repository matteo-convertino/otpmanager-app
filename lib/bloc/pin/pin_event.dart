import 'package:equatable/equatable.dart';

class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object> get props => [];
}

class PinSubmit extends PinEvent {
  const PinSubmit({required this.pin});

  final String pin;

  @override
  List<Object> get props => [pin];
}
