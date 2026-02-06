import 'package:otp_manager/models/user.dart';

abstract class UserRepository {
  User? get();
  void add(User user);
  void update(User user);
  bool isLogged();
  void removeAll();
}
