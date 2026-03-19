import 'package:equatable/equatable.dart';

class ManualEvent extends Equatable {
  const ManualEvent();

  @override
  List<Object> get props => [];
}

class AddOrEditAccount extends ManualEvent {}

class IconKeyChanged extends ManualEvent {
  const IconKeyChanged({required this.key});

  final String key;

  @override
  List<Object> get props => [key];
}

class NameChanged extends ManualEvent {
  const NameChanged({required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class IssuerChanged extends ManualEvent {
  const IssuerChanged({required this.issuer});

  final String issuer;

  @override
  List<Object> get props => [issuer];
}

class SecretKeyChanged extends ManualEvent {
  const SecretKeyChanged({required this.secretKey});

  final String secretKey;

  @override
  List<Object> get props => [secretKey];
}

class TypeChanged extends ManualEvent {
  const TypeChanged({required this.type});

  final String type;

  @override
  List<Object> get props => [type];
}

class PeriodChanged extends ManualEvent {
  const PeriodChanged({required this.period});

  final int period;

  @override
  List<Object> get props => [period];
}

class AlgorithmChanged extends ManualEvent {
  const AlgorithmChanged({required this.algorithm});

  final String algorithm;

  @override
  List<Object> get props => [algorithm];
}

class DigitsChanged extends ManualEvent {
  const DigitsChanged({required this.digits});

  final int digits;

  @override
  List<Object> get props => [digits];
}

class CounterChanged extends ManualEvent {
  const CounterChanged({required this.counter});

  final String counter;

  @override
  List<Object> get props => [counter];
}
