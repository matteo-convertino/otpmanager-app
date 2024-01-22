import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/utils/base32.dart';

import '../../models/account.dart';
import '../../repository/local_repository.dart';
import '../../utils/uri_decoder.dart';
import 'manual_event.dart';
import 'manual_state.dart';

class ManualBloc extends Bloc<ManualEvent, ManualState> {
  final Account? account;
  //final Box<Account> _accountBox = objectBox.store.box<Account>();
  final LocalRepositoryImpl localRepositoryImpl;

  ManualBloc({this.account, required this.localRepositoryImpl})
      : super(ManualState.initial(account)) {
    on<AddOrEditAccount>(_onAddOrEditAccount);
    on<IconKeyChanged>(_onIconKeyChanged);
    on<NameChanged>(_onNameChanged);
    on<IssuerChanged>(_onIssuerChanged);
    on<SecretKeyChanged>(_onSecretKeyChanged);
    on<CodeTypeValueChanged>(_onCodeTypeValueChanged);
    on<IntervalValueChanged>(_onIntervalValueChanged);
    on<AlgorithmValueChanged>(_onAlgorithmValueChanged);
    on<DigitsValueChanged>(_onDigitsValueChanged);
  }

  void _storeAccount(Emitter<ManualState> emit, Account account, String msg) {
    localRepositoryImpl.updateAccount(account);
    emit(state.copyWith(message: msg));
  }

  void _onAddOrEditAccount(AddOrEditAccount event, Emitter<ManualState> emit) {
    String name = Uri.decodeFull(state.name.trim());
    String issuer = Uri.decodeFull(state.issuer.trim());
    String secretKey = state.secretKey.trim().toUpperCase();

    if (name.isEmpty) {
      emit(state.copyWith(nameError: "The account name is required"));
    } else if (name.length > 256) {
      emit(state.copyWith(
          nameError: "The account name cannot be longer than 256 characters"));
    }

    if (issuer.length > 256) {
      emit(state.copyWith(
          issuer: "The account issuer cannot be longer than 256 characters"));
    }

    if (secretKey.isEmpty) {
      emit(state.copyWith(secretKeyError: "The secret key is required"));
    } else if (secretKey.length < 16) {
      emit(state.copyWith(
          secretKeyError:
              "The secret key cannot be shorter than 16 characters"));
    } else if (secretKey.length > 512) {
      emit(state.copyWith(
          secretKeyError:
              "The secret key cannot be longer than 512 characters"));
    } else if (!Base32.isValid(secretKey)) {
      emit(state.copyWith(
          secretKeyError: "The secret key is not base 32 encoded"));
    }

    if (state.nameError == null &&
        state.issuerError == null &&
        state.secretKeyError == null) {
      Account newAccount;
      int? lastPosition = localRepositoryImpl.getAccountLastPosition();
      int position;

      if (lastPosition != null) {
        position = lastPosition + 1;
      } else {
        position = 0;
      }

      if (account == null) {
        newAccount = Account(
          iconKey: state.iconKey,
          secret: secretKey,
          name: name,
          issuer: issuer,
          dbAlgorithm: UriDecoder.getAlgorithmFromString(state.algorithmValue),
          digits: state.digitsValue,
          type: state.codeTypeValue,
          period: state.codeTypeValue == "totp" ? state.intervalValue : null,
          position: position,
        );

        Account? sameAccount =
            localRepositoryImpl.getAccountBySecret(secretKey);

        if (sameAccount == null) {
          _storeAccount(emit, newAccount, "New account has been added");
        } else if (sameAccount.deleted) {
          newAccount.id = sameAccount.id;
          _storeAccount(emit, newAccount, "New account has been added");
        } else {
          emit(
              state.copyWith(secretKeyError: "This secret key already exists"));
        }
      } else {
        account?.iconKey = state.iconKey;
        account?.name = name;
        account?.issuer = issuer;
        account?.dbAlgorithm =
            UriDecoder.getAlgorithmFromString(state.algorithmValue);
        account?.digits = state.digitsValue;
        account?.type = state.codeTypeValue;
        account?.period =
            state.codeTypeValue == "totp" ? state.intervalValue : null;
        account?.toUpdate = true;
        newAccount = account!;

        _storeAccount(emit, newAccount, "Account has been edited");
      }
    }
  }

  void _onIconKeyChanged(IconKeyChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(iconKey: event.key));
  }

  void _onNameChanged(NameChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(name: event.name, nameError: "null"));
  }

  void _onIssuerChanged(IssuerChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(issuer: event.issuer, issuerError: "null"));
  }

  void _onSecretKeyChanged(SecretKeyChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(secretKey: event.secretKey, secretKeyError: "null"));
  }

  void _onCodeTypeValueChanged(
      CodeTypeValueChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(codeTypeValue: event.codeTypeValue));
  }

  void _onIntervalValueChanged(
      IntervalValueChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(intervalValue: event.intervalValue));
  }

  void _onAlgorithmValueChanged(
      AlgorithmValueChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(algorithmValue: event.algorithmValue));
  }

  void _onDigitsValueChanged(
      DigitsValueChanged event, Emitter<ManualState> emit) {
    emit(state.copyWith(digitsValue: event.digitsValue));
  }
}
