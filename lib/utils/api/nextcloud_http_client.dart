import 'dart:io';

import 'package:http/http.dart';

class NextcloudHttpClient extends BaseClient {
  final Client _httpClient = Client();

  NextcloudHttpClient();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers[HttpHeaders.userAgentHeader] = 'OTP Manager App';
    return _httpClient.send(request);
  }

  @override
  void close() => _httpClient.close();
}
