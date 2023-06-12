import 'package:equatable/equatable.dart';

class QrCodeScannerEvent extends Equatable {
  const QrCodeScannerEvent();

  @override
  List<Object> get props => [];
}

class ErrorChanged extends QrCodeScannerEvent {
  const ErrorChanged({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

class DecodeAndStoreAccounts extends QrCodeScannerEvent {
  const DecodeAndStoreAccounts({required this.accounts});

  final String accounts;

  @override
  List<Object> get props => [accounts];
}
