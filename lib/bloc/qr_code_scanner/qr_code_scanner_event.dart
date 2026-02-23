import 'package:equatable/equatable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScannerEvent extends Equatable {
  const QrCodeScannerEvent();

  @override
  List<Object> get props => [];
}

class ShowImagePicker extends QrCodeScannerEvent {}

class ErrorChanged extends QrCodeScannerEvent {
  const ErrorChanged({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

class BarcodeCaptured extends QrCodeScannerEvent {
  const BarcodeCaptured({required this.barcode});

  final BarcodeCapture barcode;

  @override
  List<Object> get props => [barcode];
}
