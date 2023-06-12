import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_bloc.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_event.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_state.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/show_snackbar.dart';

class WebViewer extends HookWidget {
  const WebViewer({Key? key}) : super(key: key);

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
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<WebViewerBloc>().add(InitNextcloudLogin());
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.blue,
      body: BlocConsumer<WebViewerBloc, WebViewerState>(
        listener: (context, state) {
          if (state.error != "") {
            showSnackBar(context: context, msg: state.error);
          }
        },
        builder: (context, state) {
          if (state.isLoading || (state.percentage != 1.0 && state.isLogin)) {
            return _loadingPage(state.percentage);
          } else {
            return WebViewWidget(controller: state.webViewController);
          }
        },
      ),
    );
  }
}