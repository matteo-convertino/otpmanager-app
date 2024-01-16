import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/user.dart';

class SettingsState extends Equatable {
  final bool copiedToClipboard;
  final PackageInfo packageInfo;
  final String url;
  final int selectedAskTimeIndex;

  const SettingsState({
    required this.copiedToClipboard,
    required this.packageInfo,
    required this.url,
    required this.selectedAskTimeIndex,
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
        selectedAskTimeIndex = user.passwordAskTime.index;

  SettingsState copyWith({
    bool? copiedToClipboard,
    PackageInfo? packageInfo,
    int? selectedAskTimeIndex,
  }) {
    return SettingsState(
      copiedToClipboard: copiedToClipboard ?? this.copiedToClipboard,
      packageInfo: packageInfo ?? this.packageInfo,
      url: url,
      selectedAskTimeIndex: selectedAskTimeIndex ?? this.selectedAskTimeIndex,
    );
  }

  @override
  List<Object> get props => [
        copiedToClipboard,
        packageInfo,
        selectedAskTimeIndex,
      ];
}
