import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OtpPeriod {
  p30(30),
  p45(45),
  p60(60);

  final int value;

  const OtpPeriod(this.value);
}
