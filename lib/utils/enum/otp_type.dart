import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OtpType {
  totp('totp'),
  hotp('hotp');

  final String value;

  const OtpType(this.value);
}
