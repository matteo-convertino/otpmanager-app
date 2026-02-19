// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart'
    as _i767;
import 'package:otp_manager/bloc/auth/auth_bloc.dart' as _i272;
import 'package:otp_manager/bloc/home/home_bloc.dart' as _i1019;
import 'package:otp_manager/bloc/icon_picker/icon_picker_bloc.dart' as _i994;
import 'package:otp_manager/bloc/login/login_bloc.dart' as _i95;
import 'package:otp_manager/bloc/manual/manual_bloc.dart' as _i560;
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart' as _i650;
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart' as _i147;
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart'
    as _i935;
import 'package:otp_manager/bloc/settings/settings_bloc.dart' as _i1050;
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_bloc.dart'
    as _i511;
import 'package:otp_manager/bloc/web_viewer/web_viewer_bloc.dart' as _i66;
import 'package:otp_manager/di/app_module.dart' as _i12;
import 'package:otp_manager/di/db_module.dart' as _i314;
import 'package:otp_manager/object_box/objectbox.dart' as _i799;
import 'package:otp_manager/repository/api/otp_manager_api_client.dart'
    as _i146;
import 'package:otp_manager/repository/local/impl/account_repository_impl.dart'
    as _i184;
import 'package:otp_manager/repository/local/impl/shared_account_repository_impl.dart'
    as _i148;
import 'package:otp_manager/repository/local/impl/user_repository_impl.dart'
    as _i810;
import 'package:otp_manager/repository/local/interface/account_repository.dart'
    as _i129;
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart'
    as _i736;
import 'package:otp_manager/repository/local/interface/user_repository.dart'
    as _i673;
import 'package:otp_manager/routing/navigation_service.dart' as _i863;
import 'package:otp_manager/service/account_service.dart' as _i578;
import 'package:otp_manager/service/encryption_service.dart' as _i975;
import 'package:otp_manager/service/nextcloud_service.dart' as _i674;
import 'package:otp_manager/service/snackbar_service.dart' as _i540;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dbModule = _$DbModule();
    final appModule = _$AppModule();
    await gh.factoryAsync<_i799.ObjectBox>(
      () => dbModule.objectBox,
      preResolve: true,
    );
    gh.lazySingleton<_i974.Logger>(() => appModule.logger);
    gh.lazySingleton<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(
      () => appModule.scaffoldMessengerKey,
    );
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => appModule.navigatorKey,
    );
    gh.lazySingleton<_i146.OtpManagerApiClient>(
      () => _i146.OtpManagerApiClient(),
    );
    gh.lazySingleton<_i129.AccountRepository>(
      () => _i184.AccountRepositoryImpl(logger: gh<_i974.Logger>()),
    );
    gh.lazySingleton<_i736.SharedAccountRepository>(
      () => _i148.SharedAccountRepositoryImpl(logger: gh<_i974.Logger>()),
    );
    gh.lazySingleton<_i673.UserRepository>(() => _i810.UserRepositoryImpl());
    gh.factory<_i994.IconPickerBloc>(
      () => _i994.IconPickerBloc(issuer: gh<String>()),
    );
    gh.lazySingleton<_i863.NavigationService>(
      () =>
          _i863.NavigationService(gh<_i409.GlobalKey<_i409.NavigatorState>>()),
    );
    gh.lazySingleton<_i540.SnackbarService>(
      () => _i540.SnackbarService(
        gh<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(),
      ),
    );
    gh.lazySingleton<_i578.AccountService>(
      () => _i578.AccountService(
        accountRepository: gh<_i129.AccountRepository>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        logger: gh<_i974.Logger>(),
      ),
    );
    gh.factoryParam<_i560.ManualBloc, Object?, dynamic>(
      (account, _) => _i560.ManualBloc(
        account: account,
        accountRepository: gh<_i129.AccountRepository>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        accountService: gh<_i578.AccountService>(),
        navigationService: gh<_i863.NavigationService>(),
      ),
    );
    gh.factory<_i95.LoginBloc>(
      () => _i95.LoginBloc(
        userRepository: gh<_i673.UserRepository>(),
        navigationService: gh<_i863.NavigationService>(),
      ),
    );
    gh.factoryParam<_i767.AccountDetailsBloc, Object, dynamic>(
      (account, _) => _i767.AccountDetailsBloc(
        userRepository: gh<_i673.UserRepository>(),
        accountRepository: gh<_i129.AccountRepository>(),
        accountService: gh<_i578.AccountService>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        navigationService: gh<_i863.NavigationService>(),
        account: account,
      ),
    );
    gh.factory<_i147.OtpManagerBloc>(
      () => _i147.OtpManagerBloc(userRepository: gh<_i673.UserRepository>()),
    );
    gh.factory<_i1050.SettingsBloc>(
      () => _i1050.SettingsBloc(userRepository: gh<_i673.UserRepository>()),
    );
    gh.lazySingleton<_i975.EncryptionService>(
      () => _i975.EncryptionService(userRepository: gh<_i673.UserRepository>()),
    );
    gh.factory<_i935.QrCodeScannerBloc>(
      () => _i935.QrCodeScannerBloc(
        accountRepository: gh<_i129.AccountRepository>(),
        accountService: gh<_i578.AccountService>(),
        navigationService: gh<_i863.NavigationService>(),
      ),
    );
    gh.factoryParam<_i66.WebViewerBloc, String, dynamic>(
      (nextcloudUrl, _) => _i66.WebViewerBloc(
        userRepository: gh<_i673.UserRepository>(),
        otpManagerApiClient: gh<_i146.OtpManagerApiClient>(),
        navigationService: gh<_i863.NavigationService>(),
        logger: gh<_i974.Logger>(),
        nextcloudUrl: nextcloudUrl,
      ),
    );
    gh.lazySingleton<_i674.NextcloudService>(
      () => _i674.NextcloudService(
        otpManagerApiClient: gh<_i146.OtpManagerApiClient>(),
        userRepository: gh<_i673.UserRepository>(),
        accountRepository: gh<_i129.AccountRepository>(),
        accountService: gh<_i578.AccountService>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        encryption: gh<_i975.EncryptionService>(),
        navigationService: gh<_i863.NavigationService>(),
        logger: gh<_i974.Logger>(),
      ),
    );
    gh.factory<_i1019.HomeBloc>(
      () => _i1019.HomeBloc(
        userRepository: gh<_i673.UserRepository>(),
        accountRepository: gh<_i129.AccountRepository>(),
        accountService: gh<_i578.AccountService>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        encryption: gh<_i975.EncryptionService>(),
        nextcloudService: gh<_i674.NextcloudService>(),
        navigationService: gh<_i863.NavigationService>(),
      ),
    );
    gh.factoryParam<_i511.UnlockSharedAccountBloc, int, dynamic>(
      (accountId, _) => _i511.UnlockSharedAccountBloc(
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
        nextcloudService: gh<_i674.NextcloudService>(),
        userRepository: gh<_i673.UserRepository>(),
        homeBloc: gh<_i1019.HomeBloc>(),
        navigationService: gh<_i863.NavigationService>(),
        accountId: accountId,
      ),
    );
    gh.factory<_i272.AuthBloc>(
      () => _i272.AuthBloc(
        userRepository: gh<_i673.UserRepository>(),
        nextcloudService: gh<_i674.NextcloudService>(),
        navigationService: gh<_i863.NavigationService>(),
      ),
    );
    gh.factory<_i650.OtpAccountBloc>(
      () => _i650.OtpAccountBloc(
        homeBloc: gh<_i1019.HomeBloc>(),
        accountRepository: gh<_i129.AccountRepository>(),
        nextcloudService: gh<_i674.NextcloudService>(),
        sharedAccountRepository: gh<_i736.SharedAccountRepository>(),
      ),
    );
    return this;
  }
}

class _$DbModule extends _i314.DbModule {}

class _$AppModule extends _i12.AppModule {}
