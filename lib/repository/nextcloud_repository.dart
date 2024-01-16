import 'package:http/http.dart' as http;

import '../main.dart' show logger;

abstract class NextcloudRepository {
  Future<http.Response> sendHttpRequest(user, resource, data);
}

class NextcloudRepositoryImpl extends NextcloudRepository {
  @override
  Future<http.Response> sendHttpRequest(user, resource, data) {
    logger.d("Nextcloud._sendHttpRequest start");

    return http
        .post(
          Uri.parse("${user.url}/index.php/apps/otpmanager/$resource"),
          headers: {
            'Authorization': 'Bearer ${user.appPassword}',
            'Content-Type': 'application/json'
          },
          body: data,
        )
        .timeout(const Duration(seconds: 5))
        .catchError((e, stackTrace) {
      logger.e(e);
      return http.Response(
        "The nextcloud server is unreachable now. Try to reload after a while!",
        600,
      );
    });
  }
}
