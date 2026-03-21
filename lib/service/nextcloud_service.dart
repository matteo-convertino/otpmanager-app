import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/dto/error_dto.dart';
import 'package:otp_manager/dto/request/account_sync_request_dto.dart';
import 'package:otp_manager/dto/request/account_update_counter_request_dto.dart';
import 'package:otp_manager/dto/request/password_check_request_dto.dart';
import 'package:otp_manager/dto/request/password_update_request_dto.dart';
import 'package:otp_manager/dto/request/shared_account_sync_request_dto.dart';
import 'package:otp_manager/dto/request/shared_account_unlock_request_dto.dart';
import 'package:otp_manager/dto/request/sync_request_dto.dart';
import 'package:otp_manager/dto/response/account_response_dto.dart';
import 'package:otp_manager/dto/response/accounts_sync_response_dto.dart';
import 'package:otp_manager/dto/response/password_response_dto.dart';
import 'package:otp_manager/dto/response/shared_account_response_dto.dart';
import 'package:otp_manager/dto/response/shared_accounts_sync_response_dto.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/api/otp_manager_api_client.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/api/call_api.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/helper/base32_helper.dart';
import 'encryption_service.dart';

@LazySingleton()
class NextcloudService {
  final OtpManagerApiClient otpManagerApiClient;
  final UserRepository userRepository;
  final AccountRepository accountRepository;
  final AccountService accountService;
  final SharedAccountRepository sharedAccountRepository;
  final EncryptionService encryption;
  final NavigationService navigationService;
  final Logger logger;

  NextcloudService({
    required this.otpManagerApiClient,
    required this.userRepository,
    required this.accountRepository,
    required this.accountService,
    required this.sharedAccountRepository,
    required this.encryption,
    required this.navigationService,
    required this.logger,
  });

  Future<void> checkPassword(
    PasswordCheckRequestDto passwordCheckRequestDto, {
    required void Function(PasswordResponseDto) onComplete,
    void Function(ErrorDto)? onFailed,
    void Function()? onError,
  }) async {
    logger.d('NextcloudService.checkPassword start');

    return callApi(
      api: () => otpManagerApiClient.password.check(passwordCheckRequestDto),
      onComplete: onComplete,
      onFailed: onFailed,
      onError: onError,
    );
  }

  Future<void> sync({
    void Function(ErrorDto)? onFailed,
    void Function()? onError,
  }) async {
    logger.d('NextcloudService.sync start');

    final accounts = accountRepository.getAll();
    final sharedAccounts = sharedAccountRepository.getAll();
    final user = userRepository.get()!;

    if (user.password == null || user.iv == null) {
      navigationService.replaceScreen(authRoute);
    }

    for (var e in accounts) {
      e.encryptedSecret ??= encryption.encrypt(data: e.secret);
      accountRepository.add(e);
    }

    final appInfo = await PackageInfo.fromPlatform();

    return callApi(
      api: () => otpManagerApiClient.account.sync(
        SyncRequestDto(
          accounts: accounts.map(AccountSyncRequestDto.fromModel).toList(),
          sharedAccounts: sharedAccounts
              .map(SharedAccountSyncRequestDto.fromModel)
              .toList(),
          appVersion: appInfo.version,
        ),
      ),
      onComplete: (res) async {
        accountRepository.updateNeverSync();
        sharedAccountRepository.updateNeverSync();
        accountRepository.deleteOld(res.accounts.toDelete);
        sharedAccountRepository.deleteOld(res.sharedAccounts.toDelete);

        if (_syncAccountsLocally(res.accounts, res.sharedAccounts)) {
          if (accountService.repairPositionError()) {
            await sync(onFailed: onFailed, onError: onError);
          }
        } else {
          getIt<SnackbarService>().showMessage(
            'Password has changed. Insert the new one.',
          );
          navigationService.replaceScreen(authRoute);
        }
      },
      onFailed: onFailed,
      onError: onError,
    );
  }

  bool _decryptSecretAccounts(List accounts) {
    final user = userRepository.get()!;

    for (var account in accounts) {
      if (account is Account) account.encryptedSecret = account.secret;

      if (account is SharedAccount && !account.unlocked) continue;

      try {
        String decrypted = encryption.decrypt(
          dataBase64: account.encryptedSecret,
        )!;

        if (!Base32Helper.isValid(decrypted)) throw FormatException;

        account.secret = decrypted;
      } catch (_) {
        user.password = null;
        user.iv = null;
        userRepository.update(user);
        return false;
      }
    }

    return true;
  }

  bool _syncAccountsLocally(
    AccountsSyncResponseDto accounts,
    SharedAccountsSyncResponseDto sharedAccounts,
  ) {
    final accountsToAdd = accounts.toAdd
        .map(AccountResponseDto.toModel)
        .toList();
    final accountsToEdit = accounts.toEdit
        .map(AccountResponseDto.toModel)
        .toList();
    final sharedAccountsToAdd = sharedAccounts.toAdd
        .map(SharedAccountResponseDto.toModel)
        .toList();
    final sharedAccountsToEdit = sharedAccounts.toEdit
        .map(SharedAccountResponseDto.toModel)
        .toList();

    if (_decryptSecretAccounts(accountsToAdd) &&
        _decryptSecretAccounts(accountsToEdit) &&
        _decryptSecretAccounts(sharedAccountsToAdd) &&
        _decryptSecretAccounts(sharedAccountsToEdit)) {
      accountRepository.addNew(accountsToAdd);
      accountRepository.updateEdited(accountsToEdit);
      sharedAccountRepository.addNew(sharedAccountsToAdd);
      sharedAccountRepository.updateEdited(sharedAccountsToEdit);

      return true;
    } else {
      return false;
    }
  }

  Future<void> unlockSharedAccount(
    SharedAccountUnlockRequestDto sharedAccountUnlockRequestDto, {
    required Function(void) onComplete,
    void Function(ErrorDto)? onFailed,
    void Function()? onError,
  }) async {
    return callApi(
      api: () => otpManagerApiClient.sharedAccount.unlock(
        sharedAccountUnlockRequestDto,
      ),
      onComplete: onComplete,
      onFailed: onFailed,
      onError: onError,
    );
  }

  Future<void> updateCounter(
    AccountUpdateCounterRequestDto accountUpdateCounterRequestDto, {
    required bool isShared,
    required Function(AccountResponseDto) onComplete,
    void Function(ErrorDto)? onFailed,
    void Function()? onError,
  }) async {
    return callApi(
      api: () => isShared
          ? otpManagerApiClient.sharedAccount.updateCounter(
              accountUpdateCounterRequestDto,
            )
          : otpManagerApiClient.account.updateCounter(
              accountUpdateCounterRequestDto,
            ),
      onComplete: onComplete,
      onFailed: onFailed,
      onError: onError,
    );
  }

  Future<void> updatePassword(
    PasswordUpdateRequestDto passwordUpdateRequestDto, {
    required Function(PasswordResponseDto) onComplete,
    void Function(ErrorDto)? onFailed,
    void Function()? onError,
  }) async {
    return callApi(
      api: () => otpManagerApiClient.password.update(passwordUpdateRequestDto),
      onComplete: onComplete,
      onFailed: onFailed,
      onError: onError,
    );
  }
}
