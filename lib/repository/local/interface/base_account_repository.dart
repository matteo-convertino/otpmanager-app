import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/object_box/objectbox.dart';

abstract class BaseAccountRepository<AccountType> {
  final box = getIt<ObjectBox>().store.box<AccountType>();

  void add(AccountType account) {
    box.put(account);
  }

  void update(AccountType account) {
    (account as dynamic).toUpdate = true;
    box.put(account);
  }

  void remove(int id) {
    box.remove(id);
  }

  void removeAll() {
    box.removeAll();
  }

  AccountType? get(int id) {
    return box.get(id);
  }

  List<AccountType> getAll() {
    return box.getAll();
  }

  List<AccountType> getVisible();
  List<AccountType> getVisibleFiltered(String filter);
  void updateNeverSync();
  void deleteOld(List<int> accountIds);
  void addNew(List<AccountType> accounts);
  void updateEdited(List<AccountType> accounts);
  void scalePositionAfter(int position);
  int getLastPosition();
  List<AccountType> getBetweenPositions(int min, int max);
  AccountType? getByPosition(int position);
}
