import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../widgets/expandable_text/otp_manager_expandable_text.dart';

@LazySingleton()
class SnackbarService {
  SnackbarService(this._scaffoldMessengerKey);

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  void showMessage(String message) => _show(content: _buildMessage(message));

  void showTitleAndDescription({
    required String title,
    required String description,
    bool dismissable = false,
  }) => _show(
    content: Column(
      crossAxisAlignment: .start,
      spacing: 4,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        _buildMessage(description),
      ],
    ),
    dismissable: dismissable,
  );

  void _show({required Widget content, bool dismissable = true}) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: content,
        behavior: SnackBarBehavior.floating,
        persist: !dismissable,
      ),
    );
  }

  Widget _buildMessage(String message) => OtpManagerExpandableText(
    message,
    expandText: 'show more',
    collapseText: 'show less',
    maxLines: 3,
    linkColor: _scaffoldMessengerKey.currentContext == null
        ? Colors.blue
        : Theme.of(_scaffoldMessengerKey.currentContext!).primaryColor,
    expandOnTextTap: true,
  );
}
