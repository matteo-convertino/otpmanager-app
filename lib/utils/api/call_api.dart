import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/dto/error_dto.dart';
import 'package:otp_manager/service/snackbar_service.dart';

Future<void> callApi<T>({
  required Future<T> Function() api,
  void Function(T)? onComplete,
  void Function(ErrorDto)? onFailed,
  void Function()? onError,
  bool autoShowSnackbar = true,
}) async {
  await api().then((T response) => onComplete?.call(response)).catchError((
    e,
    st,
  ) {
    print(e);
    print(e is DioException);
    print(e.error is ErrorDto);

    if (e is DioException && e.error is ErrorDto) {
      final errorDto = e.error as ErrorDto;

      getIt<Logger>().e(errorDto.message, stackTrace: st);

      if (autoShowSnackbar) {
        handleErrors(
          statusCode: errorDto.statuscode,
          message: errorDto.message,
        );
      }

      onFailed?.call(errorDto);
      return;
    }

    getIt<Logger>().e(e, stackTrace: st);
    onError?.call();
  });
}

String getTitleByStatus(int status) {
  if (status >= 500) return 'Server error';
  if (status == 404) return 'Not found';
  if (status == 401) return 'Unauthorized';
  if (status == 403) return 'Access denied';
  if (status == 400) return 'Invalid request';
  if (status == 409) return 'Conflict';
  if (status == 422) return 'Validation error';
  if (status >= 400) return 'Request error';

  return 'Something went wrong';
}

void handleErrors({required int statusCode, required Object message}) {
  final title = getTitleByStatus(statusCode);

  List<String> lines = [];

  if (message is Map) {
    final record = message.map(
      (k, v) => MapEntry(k as String, (v as List).cast<String>()),
    );

    for (final entry in record.entries) {
      lines.add('${entry.key}:');
      lines.addAll(entry.value.map((v) => '  • $v'));
    }
  } else if (message is List) {
    lines = message.map((s) => '• $s').toList();
  } else if (message is String) {
    lines = [message];
  } else {
    lines = ['Something went wrong'];
  }

  getIt<SnackbarService>().showTitleAndDescription(
    title: title,
    description: lines.join('\n'),
    dismissable: false,
  );
}
