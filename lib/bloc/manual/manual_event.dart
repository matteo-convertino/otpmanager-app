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

class CodeTypeValueChanged extends ManualEvent {
  const CodeTypeValueChanged({required this.codeTypeValue});

  final String codeTypeValue;

  @override
  List<Object> get props => [codeTypeValue];
}

class IntervalValueChanged extends ManualEvent {
  const IntervalValueChanged({required this.intervalValue});

  final int intervalValue;

  @override
  List<Object> get props => [intervalValue];
}

class AlgorithmValueChanged extends ManualEvent {
  const AlgorithmValueChanged({required this.algorithmValue});

  final String algorithmValue;

  @override
  List<Object> get props => [algorithmValue];
}

class DigitsValueChanged extends ManualEvent {
  const DigitsValueChanged({required this.digitsValue});

  final int digitsValue;

  @override
  List<Object> get props => [digitsValue];
}
