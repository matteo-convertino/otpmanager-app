import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';

import '../models/account.dart';

/// Performs operations by managing both accounts (the user's own) and
/// shared accounts (those shared with the user)
@LazySingleton()
class AccountService {
  final AccountRepository accountRepository;
  final SharedAccountRepository sharedAccountRepository;
  final Logger logger;

  AccountService({
    required this.accountRepository,
    required this.sharedAccountRepository,
    required this.logger,
  });

  int getLastPosition() {
    int accountLastPosition = accountRepository.getLastPosition();
    int sharedAccountLastPosition = sharedAccountRepository.getLastPosition();

    return max(accountLastPosition, sharedAccountLastPosition);
  }

  void setAsDeleted(dynamic account) {
    account.deleted = true;

    accountRepository.scalePositionAfter(account.position!);
    sharedAccountRepository.scalePositionAfter(account.position!);

    account.position = null;

    account is SharedAccount
        ? sharedAccountRepository.update(account)
        : accountRepository.update(account);
  }

  bool repairPositionError() {
    logger.d('AccountRepositoryImpl._checkPositions start');

    List allAccounts = [
      ...accountRepository.getVisible(),
      ...sharedAccountRepository.getVisible(),
    ];

    allAccounts.sort((a, b) => a.position.compareTo(b.position));

    void adjustAccountsPosition(int start, int difference) {
      logger.d('AccountRepositoryImpl._adjustAccountsPosition start');

      for (int i = start; i < allAccounts.length; i++) {
        allAccounts[i].position = allAccounts[i].position! + difference;
        allAccounts[i].toUpdate = true;

        if (allAccounts[i] is Account) {
          accountRepository.update(allAccounts[i]);
        } else {
          sharedAccountRepository.update(allAccounts[i]);
        }
      }
    }

    if (allAccounts.isNotEmpty) {
      bool repairedError = false;

      // check if first account has position = 0
      if (allAccounts[0].position != 0) {
        repairedError = true;
        adjustAccountsPosition(0, -allAccounts[0].position);
      }

      for (int i = 0; i < allAccounts.length - 1; i++) {
        if (allAccounts[i].position == allAccounts[i + 1].position) {
          // there are two accounts with same position
          // increment by 1 the position of all accounts after

          repairedError = true;
          adjustAccountsPosition(i + 1, 1);
        } else if (allAccounts[i].position + 1 != allAccounts[i + 1].position) {
          // accounts do not have a step of 1

          repairedError = true;
          allAccounts[i + 1].position = allAccounts[i].position + 1;
          allAccounts[i + 1].toUpdate = true;

          if (allAccounts[i + 1] is Account) {
            accountRepository.update(allAccounts[i + 1]);
          } else {
            sharedAccountRepository.update(allAccounts[i + 1]);
          }
        }
      }

      return repairedError;
    }

    return false;
  }

  void reorder(int oldIndex, int newIndex) {
    List<Account> accountsBetween;
    List<SharedAccount> sharedAccountsBetween;

    int difference;
    int newPosition = newIndex;

    if (newIndex > oldIndex) {
      newPosition -= 1;
      accountsBetween = accountRepository.getBetweenPositions(
        oldIndex,
        newPosition,
      );
      sharedAccountsBetween = sharedAccountRepository.getBetweenPositions(
        oldIndex,
        newPosition,
      );
      difference = -1;
    } else {
      accountsBetween = accountRepository.getBetweenPositions(
        newIndex - 1,
        oldIndex - 1,
      );
      sharedAccountsBetween = sharedAccountRepository.getBetweenPositions(
        newIndex - 1,
        oldIndex - 1,
      );
      difference = 1;
    }

    dynamic accountToMove =
        (accountRepository.getByPosition(oldIndex) ??
        sharedAccountRepository.getByPosition(oldIndex))!;

    for (Account accountBetween in accountsBetween) {
      accountBetween.position = accountBetween.position! + difference;
      accountRepository.update(accountBetween);
    }

    for (SharedAccount sharedAccountBetween in sharedAccountsBetween) {
      sharedAccountBetween.position =
          sharedAccountBetween.position! + difference;
      sharedAccountRepository.update(sharedAccountBetween);
    }

    accountToMove.position = newPosition;

    if (accountToMove is Account) {
      accountRepository.update(accountToMove);
    } else {
      sharedAccountRepository.update(accountToMove);
    }
  }
}
