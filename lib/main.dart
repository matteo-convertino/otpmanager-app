import 'package:flutter/material.dart' hide Router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart' hide FileOutput;
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/domain/nextcloud_service.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/repository/nextcloud_repository.dart';
import 'package:otp_manager/logger/filter.dart';
import 'package:otp_manager/utils/clear_app_data.dart';
import 'package:otp_manager/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import 'logger/file_output.dart';
import "object_box/objectbox.dart";
import 'otp_manager.dart';

late ObjectBox objectBox;

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

Future<void> main() async {
  try {
    // This is required so ObjectBox can get the application directory
    // to store the database in.
    WidgetsFlutterBinding.ensureInitialized();

    objectBox = await ObjectBox.create();
  } catch (e) {
    // temporary solution for a severe bug with object box
    showToast(
      "An automatic logout was performed due to a bug in the previous version",
      toastLength: Toast.LENGTH_LONG,
    );
    clearAppData();
    logger.e(e);

    Restart.restartApp();
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalRepositoryImpl>(
          create: (_) => LocalRepositoryImpl(),
        ),
        RepositoryProvider<NextcloudRepositoryImpl>(
          create: (_) => NextcloudRepositoryImpl(),
        ),
        RepositoryProvider<NextcloudService>(
          create: (context) => NextcloudService(
            context.read<NextcloudRepositoryImpl>(),
            context.read<LocalRepositoryImpl>(),
          ),
        ),
      ],
      child: BlocProvider<OtpManagerBloc>(
        create: (context) => OtpManagerBloc(
          localRepositoryImpl: context.read<LocalRepositoryImpl>(),
        ),
        child: const OtpManager(),
      ),
    ),
  );
}
