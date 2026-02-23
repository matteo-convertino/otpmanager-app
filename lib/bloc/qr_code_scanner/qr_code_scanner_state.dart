import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otp_manager/utils/optional.dart';

class QrCodeScannerState extends Equatable {
  final String error;
  final XFile? image;

  const QrCodeScannerState({required this.error, this.image});

  const QrCodeScannerState.initial() : error = '', image = null;

  QrCodeScannerState copyWith({String? error, Optional<XFile>? image}) {
    return QrCodeScannerState(
      error: error ?? this.error,
      image: image == null ? this.image : image.value,
    );
  }

  @override
  List<Object?> get props => [error, image];
}
