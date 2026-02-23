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
  final String? nameError;
  final String? issuerError;
  final String? secretKeyError;
  final String codeTypeValue;
  final int intervalValue;
  final String algorithmValue;
  final int digitsValue;
  final bool isEdit;
  final bool isSharedAccount;

  const ManualState({
    required this.iconKey,
    required this.name,
    required this.issuer,
    required this.secretKey,
    required this.nameError,
    required this.issuerError,
    required this.secretKeyError,
    required this.codeTypeValue,
    required this.intervalValue,
    required this.algorithmValue,
    required this.digitsValue,
    required this.isEdit,
    required this.isSharedAccount,
  });

  ManualState.initial(dynamic account)
    : iconKey = account?.iconKey ?? 'default',
      name = account?.name ?? '',
      issuer = account?.issuer ?? '',
      secretKey = account?.secret ?? '',
      secretKeyError = null,
      issuerError = null,
      nameError = null,
      codeTypeValue = account?.type ?? OtpType.totp.value,
      intervalValue = account?.period ?? 30,
      algorithmValue =
          (account?.algorithm as Algorithm?)?.name ?? Algorithm.SHA1.name,
      digitsValue = account?.digits ?? 6,
      isEdit = account != null,
      isSharedAccount = account is SharedAccount;

  ManualState copyWith({
    String? iconKey,
    String? name,
    String? issuer,
    String? secretKey,
    Optional<String>? nameError,
    Optional<String>? issuerError,
    Optional<String>? secretKeyError,
    String? codeTypeValue,
    int? intervalValue,
    String? algorithmValue,
    int? digitsValue,
  }) {
    return ManualState(
      iconKey: iconKey ?? this.iconKey,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      secretKey: secretKey ?? this.secretKey,
      nameError: nameError == null ? this.nameError : nameError.value,
      issuerError: issuerError == null ? this.issuerError : issuerError.value,
      secretKeyError: secretKeyError == null
          ? this.secretKeyError
          : secretKeyError.value,
      codeTypeValue: codeTypeValue ?? this.codeTypeValue,
      intervalValue: intervalValue ?? this.intervalValue,
      algorithmValue: algorithmValue ?? this.algorithmValue,
      digitsValue: digitsValue ?? this.digitsValue,
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
    nameError,
    issuerError,
    secretKeyError,
    codeTypeValue,
    intervalValue,
    algorithmValue,
    digitsValue,
  ];
}
