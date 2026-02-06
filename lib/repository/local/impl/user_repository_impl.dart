import 'package:injectable/injectable.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/user.dart';
import 'package:otp_manager/object_box/objectbox.dart';

import '../interface/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final _userBox = getIt<ObjectBox>().store.box<User>();

  @override
  void add(User user) {
    _userBox.put(user);
  }

  @override
  User? get() {
    final users = _userBox.getAll();

    return users.isNotEmpty ? users[0] : null;
  }

  @override
  bool isLogged() {
    return _userBox.getAll().isNotEmpty;
  }

  @override
  void removeAll() {
    _userBox.removeAll();
  }

  @override
  void update(User user) {
    _userBox.put(user);
  }
}
