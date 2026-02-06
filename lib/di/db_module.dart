import 'package:injectable/injectable.dart';
import 'package:otp_manager/object_box/objectbox.dart';

@module
abstract class DbModule {
  @preResolve
  Future<ObjectBox> get objectBox async => ObjectBox.create();
}
