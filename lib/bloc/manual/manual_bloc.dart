import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/home/home_bloc.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/helper/base32_helper.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';
import 'package:otp_manager/utils/optional.dart';

import '../../models/account.dart';
import '../../utils/helper/otp_uri_decoder_helper.dart';
import 'manual_event.dart';
import 'manual_state.dart';

@injectable
class ManualBloc extends Bloc<ManualEvent, ManualState> {
  final AccountRepository accountRepository;
  final SharedAccountRepository sharedAccountRepository;
  final AccountService accountService;
  final NavigationService navigationService;
  final HomeBloc homeBloc;

  final Object? account; // Account | SharedAccount

  ManualBloc({
    required this.accountRepository,
    required this.sharedAccountRepository,
    required this.accountService,
    required this.navigationService,
    required this.homeBloc,
    @factoryParam this.account,
  }) : super(ManualState.initial(account)) {
    on<AddOrEditAccount>(_onAddOrEditAccount);
    on<IconKeyChanged>(_onIconKeyChanged);
    on<NameChanged>(_onNameChanged);
    on<IssuerChanged>(_onIssuerChanged);
    on<SecretKeyChanged>(_onSecretKeyChanged);
    on<TypeChanged>(_onCodeTypeValueChanged);
    on<PeriodChanged>(_onIntervalValueChanged);
    on<AlgorithmChanged>(_onAlgorithmValueChanged);
    on<DigitsChanged>(_onDigitsValueChanged);
    on<CounterChanged>(_onCounterChanged);
  }

  bool _isFormValid(
    String name,
    String issuer,
    String secretKey,
    int? counter,
    Emitter<ManualState> emit,
  ) {
    bool isValid = true;

    if (name.isEmpty) {
      emit(state.copyWith(nameError: Optional('The account name is required')));
      isValid = false;
    } else if (name.length > 256) {
      emit(
        state.copyWith(
          nameError: Optional(
            'The account name cannot be longer than 256 characters',
          ),
        ),
      );
      isValid = false;
    }

    if (issuer.length > 256) {
      emit(
        state.copyWith(
          issuer: 'The account issuer cannot be longer than 256 characters',
        ),
      );
      isValid = false;
    }

    if (account != null) return isValid;

    if (secretKey.isEmpty) {
      emit(
        state.copyWith(secretKeyError: Optional('The secret key is required')),
      );
      isValid = false;
    } else if (secretKey.length < 16) {
      emit(
        state.copyWith(
          secretKeyError: Optional(
            'The secret key cannot be shorter than 16 characters',
          ),
        ),
      );
      isValid = false;
    } else if (secretKey.length > 512) {
      emit(
        state.copyWith(
          secretKeyError: Optional(
            'The secret key cannot be longer than 512 characters',
          ),
        ),
      );
      isValid = false;
    } else if (!Base32Helper.isValid(secretKey)) {
      emit(
        state.copyWith(
          secretKeyError: Optional('The secret key is not base 32 encoded'),
        ),
      );
      isValid = false;
    }

    if (state.counter.isNotEmpty && counter == null) {
      emit(state.copyWith(counterError: Optional('Counter must be a number')));
      isValid = false;
    }

    return isValid;
  }

  void _onAddOrEditAccount(AddOrEditAccount event, Emitter<ManualState> emit) {
    String name = Uri.decodeFull(removeDiacritics(state.name.trim()));
    String issuer = Uri.decodeFull(removeDiacritics(state.issuer.trim()));
    String secretKey = state.secretKey.trim().toUpperCase();
    int? counter = state.counter.isEmpty ? null : int.tryParse(state.counter);

    if (!_isFormValid(name, issuer, secretKey, counter, emit)) return;

    int position = accountService.getLastPosition() + 1;

    final acc = account;

    if (acc == null) {
      Account newAccount = Account(
        iconKey: state.iconKey,
        secret: secretKey,
        name: name,
        issuer: issuer,
        dbAlgorithm: OtpUriDecoderHelper.getAlgorithmIndexFromString(
          state.algorithm,
        ),
        digits: state.digits,
        type: state.type,
        period: state.type == OtpType.totp.value ? state.period : null,
        position: position,
        counter: state.counter.isEmpty ? null : int.tryParse(state.counter),
      );

      Account? sameAccount = accountRepository.getBySecret(secretKey);

      if (sameAccount == null) {
        accountRepository.add(newAccount);
        getIt<SnackbarService>().showMessage('New account has been added');
      } else if (sameAccount.deleted) {
        newAccount.id = sameAccount.id;
        accountRepository.add(newAccount);
        getIt<SnackbarService>().showMessage('New account has been added');
      } else {
        emit(
          state.copyWith(
            secretKeyError: Optional('This secret key already exists'),
          ),
        );
        return;
      }
    } else {
      (acc as dynamic).iconKey = state.iconKey;
      (acc as dynamic).name = name;
      (acc as dynamic).issuer = issuer;

      if (acc is Account) {
        acc.dbAlgorithm = OtpUriDecoderHelper.getAlgorithmIndexFromString(
          state.algorithm,
        );
        acc.digits = state.digits;
        acc.type = state.type;
        acc.period = state.type == OtpType.totp.value ? state.period : null;
      }

      if (acc is Account) {
        accountRepository.update(acc);
      } else if (acc is SharedAccount) {
        sharedAccountRepository.update(acc);
      }

      getIt<SnackbarService>().showMessage('Account has been edited');
    }

    homeBloc.add(NextcloudSync());
    navigationService.goBackToScreen(homeRoute);
  }

  void _onIconKeyChanged(IconKeyChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(iconKey: event.key));
  }

  void _onNameChanged(NameChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(name: event.name, nameError: Optional(null)));
  }

  void _onIssuerChanged(IssuerChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(issuer: event.issuer, issuerError: Optional(null)));

    emit(
      state.copyWith(
        iconKey: event.issuer.isEmpty
            ? 'default'
            : OtpIconsHelper.findFirst(event.issuer),
      ),
    );
  }

  void _onSecretKeyChanged(SecretKeyChanged event, Emitter<ManualState> emit) {
    emit(
      state.copyWith(
        secretKey: event.secretKey,
        secretKeyError: Optional(null),
      ),
    );
  }

  void _onCodeTypeValueChanged(TypeChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(type: event.type));
  }

  void _onIntervalValueChanged(PeriodChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(period: event.period));
  }

  void _onAlgorithmValueChanged(
    AlgorithmChanged event,
    Emitter<ManualState> emit,
  ) {
    emit(state.copyWith(algorithm: event.algorithm));
  }

  void _onDigitsValueChanged(DigitsChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(digits: event.digits));
  }

  void _onCounterChanged(CounterChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(counter: event.counter, counterError: Optional(null)));
  }
}
