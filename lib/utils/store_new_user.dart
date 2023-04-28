import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../main.dart' show objectBox, DarkThemeProvider;
import '../models/user.dart';

void storeNewUser({
  required BuildContext context,
  required String url,
  required String appPassword,
  required bool isGuest,
}) {
  var box = objectBox.store.box<User>();
  var user = User(url: url, appPassword: appPassword, isGuest: isGuest);
  box.put(user);

  // set default theme mode
  var themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
  themeChange.darkTheme = false;
}
