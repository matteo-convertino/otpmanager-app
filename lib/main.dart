import 'package:flutter/material.dart' hide Router;
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart' hide FileOutput;
import 'package:otp_manager/logger/filter.dart';
import 'package:provider/provider.dart';

import "models/user.dart";
import "object_box/objectbox.dart";
import "routing/constants.dart";
import 'routing/navigation_service.dart';
import 'routing/router.dart';
import 'logger/file_output.dart';

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  objectBox = await ObjectBox.create();

  runApp(const OtpManager());
}

var logger = Logger(
  filter: Filter(),
  printer: PrettyPrinter(
    printEmojis: false,
    printTime: true,
    colors: false,
    methodCount: 4,
  ),
  output: MultiOutput([FileOutput(), ConsoleOutput()]),
);

late ObjectBox objectBox;

String _getInitialRoute() {
  var box = objectBox.store.box<User>();
  return box.isEmpty() ? loginRoute : homeRoute;
}

class DarkThemeProvider with ChangeNotifier {
  final _box = objectBox.store.box<User>();

  set darkTheme(bool value) {
    if (_box.getAll().isNotEmpty) {
      User user = _box.getAll()[0];
      user.darkTheme = value;
      _box.put(user);
      notifyListeners();
    }
  }

  bool get darkTheme {
    if (_box.getAll().isNotEmpty) {
      User user = _box.getAll()[0];
      return user.darkTheme;
    }

    return false;
  }
}

class OtpManager extends StatefulWidget {
  const OtpManager({Key? key}) : super(key: key);

  @override
  State<OtpManager> createState() => _OtpManagerState();
}

class _OtpManagerState extends State<OtpManager> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget? child) {
          ThemeMode theme = themeChangeProvider.darkTheme == true
              ? ThemeMode.dark
              : ThemeMode.light;

          return MaterialApp(
            title: 'OTP Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: TextTheme(
                titleMedium: GoogleFonts.roboto(color: Colors.white),
                titleLarge: GoogleFonts.roboto(),
              ),
              brightness: Brightness.dark,
              primaryColor: Colors.blue,
            ),
            themeMode: theme,
            onGenerateRoute: Router.generateRoute,
            initialRoute: _getInitialRoute(),
            navigatorKey: NavigationService().navigatorKey,
          );
        },
      ),
    );
  }
}
