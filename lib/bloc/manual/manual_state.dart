import 'package:equatable/equatable.dart';
import 'package:otp/otp.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/optional.dart';

class ManualState extends Equatable {
  final String iconKey;
  final String name;
  final String issuer;
  final String secretKey;
  final String type;
  final int period;
  final String algorithm;
  final int digits;
  final String counter;
  final String? nameError;
  final String? issuerError;
  final String? secretKeyError;
  final String? counterError;
  final bool isEdit;
  final bool isSharedAccount;

  const ManualState({
    required this.iconKey,
    required this.name,
    required this.issuer,
    required this.secretKey,
    required this.type,
    required this.period,
    required this.algorithm,
    required this.digits,
    required this.counter,
    required this.nameError,
    required this.issuerError,
    required this.secretKeyError,
    required this.counterError,
    required this.isEdit,
    required this.isSharedAccount,
  });

  ManualState.initial(dynamic account)
    : iconKey = account?.iconKey ?? 'default',
      name = account?.name ?? '',
      issuer = account?.issuer ?? '',
      secretKey = account?.secret ?? '',
      type = account?.type ?? OtpType.totp.value,
      period = account?.period ?? 30,
      algorithm =
          (account?.algorithm as Algorithm?)?.name ?? Algorithm.SHA1.name,
      counter = (account?.counter ?? -1) < 0 ? '' : account.counter.toString(),
      digits = account?.digits ?? 6,
      secretKeyError = null,
      issuerError = null,
      nameError = null,
      counterError = null,
      isEdit = account != null,
      isSharedAccount = account is SharedAccount;

  ManualState copyWith({
    String? iconKey,
    String? name,
    String? issuer,
    String? secretKey,
    String? counter,
    Optional<String>? nameError,
    Optional<String>? issuerError,
    Optional<String>? secretKeyError,
    Optional<String>? counterError,
    String? type,
    int? period,
    String? algorithm,
    int? digits,
  }) {
    return ManualState(
      iconKey: iconKey ?? this.iconKey,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      secretKey: secretKey ?? this.secretKey,
      type: type ?? this.type,
      period: period ?? this.period,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      counter: counter ?? this.counter,
      nameError: nameError == null ? this.nameError : nameError.value,
      issuerError: issuerError == null ? this.issuerError : issuerError.value,
      secretKeyError: secretKeyError == null
          ? this.secretKeyError
          : secretKeyError.value,
      counterError: counterError == null
          ? this.counterError
          : counterError.value,
      isEdit: isEdit,
      isSharedAccount: isSharedAccount,
    );
  }

  @override
  List<Object?> get props => [
    iconKey,
    name,
    issuer,
    secretKey,
    type,
    period,
    algorithm,
    digits,
    counter,
    nameError,
    issuerError,
    secretKeyError,
    counterError,
  ];
}
