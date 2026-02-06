import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_bloc.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_event.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_state.dart';

class WebViewer extends HookWidget {
  WebViewer({super.key});

  InAppWebViewController? _webViewController;

  Stack _loadingPage(double percentage) {
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
                value: percentage,
                color: Colors.white,
                backgroundColor: Colors.white38,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = useState(0.0);

    useEffect(() {
      context.read<WebViewerBloc>().add(InitNextcloudLogin());
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.blue,
      body: BlocConsumer<WebViewerBloc, WebViewerState>(
        listener: (context, state) {
          if (state.initUrl != '') {
            _webViewController?.loadUrl(
              urlRequest: URLRequest(url: WebUri(state.initUrl)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              InAppWebView(
                initialSettings: InAppWebViewSettings(),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                  //_webViewController?.loadUrl(urlRequest: initUrl.value!);
                },
                onLoadStart:
                    (InAppWebViewController controller, WebUri? webUri) {
                      context.read<WebViewerBloc>().add(
                        UpdateLoadingScreen(
                          isLogin: webUri?.toString().contains('flow') == true,
                        ),
                      );
                    },
                onLoadStop:
                    (InAppWebViewController controller, WebUri? webUri) async {
                      if (webUri != null) {
                        progress.value = 1;
                        context.read<WebViewerBloc>().add(
                          OnLoadStop(url: webUri.toString()),
                        );
                      }
                    },
                onProgressChanged:
                    (InAppWebViewController controller, int webViewProgress) {
                      context.read<WebViewerBloc>().add(
                        const UpdateLoadingScreen(isLogin: null),
                      );
                      progress.value = webViewProgress / 100;
                    },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async => ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED,
                    ),
              ),
              if (state.isLoading || (progress.value != 1.0 && state.isLogin))
                _loadingPage(progress.value),
            ],
          );
        },
        //},
      ),
    );
  }
}
