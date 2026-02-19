import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OtpDigits {
  d4(4),
  d6(6);

  final int value;

  const OtpDigits(this.value);
}
