import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:otp_manager/utils/store_new_user.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../routing/constants.dart';
import '../routing/navigation_service.dart';

class WebViewer extends StatefulWidget {
  const WebViewer({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<WebViewer> createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  late final NextcloudClient _client;
  late Future<NextcloudCoreLoginFlowInit> result;
  final WebViewController _webViewController = WebViewController();
  double _isLoadingPercentage = 0;
  bool _isLoginPage = false;

  @override
  void initState() {
    super.initState();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    result = _nextcloudLoginSetup()
        .timeout(const Duration(seconds: 20))
        .catchError((error, stackTrace) {
      if (error is TimeoutException) {
        NavigationService().resetToScreen(loginRoute,
            arguments: "The server is taking too time to respond!");
      } else {
        NavigationService().resetToScreen(loginRoute,
            arguments: "The url is not of a valid nextcloud server!");
      }
    });
  }

  Future<NextcloudCoreLoginFlowInit> _nextcloudLoginSetup() async {
    _client = NextcloudClient(
      widget.url,
      userAgentOverride: 'OTP Manager App',
    );

    NextcloudCoreLoginFlowInit init = await _client.core.initLoginFlow();

    _webViewController
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            setState(() {
              _isLoginPage = false;
              _isLoadingPercentage = 1;
            });

            if (url.endsWith("grant")) {
              _client.core
                  .getLoginFlowResult(token: init.poll.token)
                  .then((result) {
                storeNewUser(
                  context: context,
                  url: widget.url,
                  appPassword: result.appPassword,
                  isGuest: false,
                );
                NavigationService().resetToScreen(homeRoute);
              });
            }
          },
          onPageStarted: (String? url) {
            setState(() {
              _isLoginPage = url?.contains("flow") == true;
              _isLoadingPercentage = 0;
            });
          },
          onProgress: (int progressValue) {
            setState(() => _isLoadingPercentage = progressValue / 100);
          },
        ),
      )
      ..loadRequest(Uri.parse(init.login));

    return init;
  }

  Stack _loadingPage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blue,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
              child: LinearProgressIndicator(
                value: _isLoadingPercentage,
                color: Colors.white,
                backgroundColor: Colors.white38,
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: FutureBuilder<NextcloudCoreLoginFlowInit>(
        future: result,
        builder: (BuildContext context,
            AsyncSnapshot<NextcloudCoreLoginFlowInit> snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoadingPercentage != 1.0 && _isLoginPage) _loadingPage(),
              ],
            );
          } else {
            return _loadingPage();
          }
        },
      ),
    );
  }
}
