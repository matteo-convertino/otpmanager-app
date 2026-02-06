import 'package:http/http.dart';

abstract class NextcloudRepository {
  Future<void> sendHttpRequest({
    required String resource,
    required Map<String, dynamic> data,
    void Function(Response)? onComplete,
    void Function(Response)? onFailed,
    void Function()? onError,
  });
}
