import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/user.dart';

class SettingsState extends Equatable {
  final bool copiedToClipboard;
  final PackageInfo packageInfo;
  final String url;
  final String? pin;

  const SettingsState({
    required this.copiedToClipboard,
    required this.packageInfo,
    required this.url,
    required this.pin,
  });

  SettingsState.initial(User user)
      : copiedToClipboard = false,
        packageInfo = PackageInfo(
          appName: "Unknown",
          packageName: "Unknown",
          version: "Unknown",
          buildNumber: "Unknown",
        ),
        url = user.url,
        pin = user.pin;

  SettingsState copyWith({
    bool? copiedToClipboard,
    PackageInfo? packageInfo,
  }) {
    return SettingsState(
      copiedToClipboard: copiedToClipboard ?? this.copiedToClipboard,
      packageInfo: packageInfo ?? this.packageInfo,
      url: url,
      pin: pin,
    );
  }

  @override
  List<Object> get props => [copiedToClipboard, packageInfo];
}
