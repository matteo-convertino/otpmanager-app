import 'package:equatable/equatable.dart';
import 'package:otp_manager/utils/uri_decoder.dart';

import '../../models/account.dart';

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
  final String message;

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
    required this.message,
  });

  ManualState.initial(Account? account)
      : iconKey = account?.iconKey ?? 'default',
        name = account?.name ?? "",
        issuer = account?.issuer ?? "",
        secretKey = account?.secret ?? "",
        secretKeyError = null,
        issuerError = null,
        nameError = null,
        codeTypeValue = account?.type ?? "totp",
        intervalValue = account?.period ?? 30,
        algorithmValue = UriDecoder.getAlgorithmFromAlgo(account?.algorithm),
        digitsValue = account?.digits ?? 6,
        isEdit = account != null,
        message = "";

  ManualState copyWith({
    String? iconKey,
    String? name,
    String? issuer,
    String? secretKey,
    String? nameError,
    String? issuerError,
    String? secretKeyError,
    String? codeTypeValue,
    int? intervalValue,
    String? algorithmValue,
    int? digitsValue,
    String? message,
  }) {
    return ManualState(
      iconKey: iconKey ?? this.iconKey,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      secretKey: secretKey ?? this.secretKey,
      nameError: nameError == "null" ? null : nameError ?? this.nameError,
      issuerError:
          issuerError == "null" ? null : issuerError ?? this.issuerError,
      secretKeyError: secretKeyError == "null"
          ? null
          : secretKeyError ?? this.secretKeyError,
      codeTypeValue: codeTypeValue ?? this.codeTypeValue,
      intervalValue: intervalValue ?? this.intervalValue,
      algorithmValue: algorithmValue ?? this.algorithmValue,
      digitsValue: digitsValue ?? this.digitsValue,
      isEdit: isEdit,
      message: message ?? this.message,
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
        message,
      ];
}
