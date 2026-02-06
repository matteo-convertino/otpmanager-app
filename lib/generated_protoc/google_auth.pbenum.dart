// This is a generated file - do not edit.
//
// Generated from google_auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MigrationPayload_Algorithm extends $pb.ProtobufEnum {
  static const MigrationPayload_Algorithm ALGO_INVALID =
      MigrationPayload_Algorithm._(0, _omitEnumNames ? '' : 'ALGO_INVALID');
  static const MigrationPayload_Algorithm SHA1 =
      MigrationPayload_Algorithm._(1, _omitEnumNames ? '' : 'SHA1');

  static const $core.List<MigrationPayload_Algorithm> values =
      <MigrationPayload_Algorithm>[
    ALGO_INVALID,
    SHA1,
  ];

  static final $core.List<MigrationPayload_Algorithm?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static MigrationPayload_Algorithm? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MigrationPayload_Algorithm._(super.value, super.name);
}

class MigrationPayload_OtpType extends $pb.ProtobufEnum {
  static const MigrationPayload_OtpType invalid =
      MigrationPayload_OtpType._(0, _omitEnumNames ? '' : 'invalid');
  static const MigrationPayload_OtpType hotp =
      MigrationPayload_OtpType._(1, _omitEnumNames ? '' : 'hotp');
  static const MigrationPayload_OtpType totp =
      MigrationPayload_OtpType._(2, _omitEnumNames ? '' : 'totp');

  static const $core.List<MigrationPayload_OtpType> values =
      <MigrationPayload_OtpType>[
    invalid,
    hotp,
    totp,
  ];

  static final $core.List<MigrationPayload_OtpType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MigrationPayload_OtpType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MigrationPayload_OtpType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
