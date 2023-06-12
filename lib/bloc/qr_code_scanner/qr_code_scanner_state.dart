import 'package:equatable/equatable.dart';

class QrCodeScannerState extends Equatable {
  final String error;
  final String addWithSuccess;

  const QrCodeScannerState({required this.error, required this.addWithSuccess});

  const QrCodeScannerState.initial()
      : error = "",
        addWithSuccess = "";

  QrCodeScannerState copyWith({String? error, String? addWithSuccess}) {
    return QrCodeScannerState(
      error: error ?? this.error,
      addWithSuccess: addWithSuccess ?? this.addWithSuccess,
    );
  }

  @override
  List<Object> get props => [error];
}
