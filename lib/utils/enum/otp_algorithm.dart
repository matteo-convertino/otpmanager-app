import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OtpAlgorithm {
  sha1('SHA1'),
  sha256('SHA256'),
  sha512('SHA512');

  final String value;

  const OtpAlgorithm(this.value);
}
