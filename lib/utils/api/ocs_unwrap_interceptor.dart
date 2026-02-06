import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:otp_manager/dto/error_dto.dart';

class OcsUnwrapInterceptor extends Interceptor {
  bool _isOcs(dynamic data) {
    return data is Map<String, dynamic> &&
        data.containsKey('ocs') &&
        data['ocs'] is Map<String, dynamic> &&
        data['ocs'].containsKey('data') &&
        data['ocs'].containsKey('meta');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (_isOcs(data)) response.data = data['ocs']['data'];

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;

    if (_isOcs(data)) {
      final metaJson = data['ocs']['meta'];

      if (metaJson is Map<String, dynamic>) {
        if (err.response?.statusCode != null) {
          metaJson['statuscode'] = err.response!.statusCode;
        }

        metaJson['message'] = _parseMessage(metaJson['message']);
        final errorDto = ErrorDto.fromJson(metaJson);

        handler.reject(err.copyWith(error: errorDto));
        return;
      }
    }

    handler.next(err);
  }

  Object _parseMessage(Object m) {
    if (m is! String) return m;

    final looksLikeJson =
        (m.startsWith('{') && m.endsWith('}')) ||
        (m.startsWith('[') && m.endsWith(']'));

    if (!looksLikeJson) return m;

    try {
      return jsonDecode(m);
    } catch (_) {
      return m;
    }
  }
}
