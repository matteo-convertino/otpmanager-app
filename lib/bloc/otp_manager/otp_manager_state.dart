import 'package:equatable/equatable.dart';
import 'package:otp_manager/utils/enum/theme_mode.dart';

import '../../models/user.dart';
import '../../routing/constants.dart';

class OtpManagerState extends Equatable {
  final ThemeMode themeMode;
  final bool blackTheme;
  final bool copyWithTap;
  final bool openSearchBarOnStartup;
  final bool clickToRevealCodes;
  final String initialRoute;

  const OtpManagerState({
    required this.themeMode,
    required this.blackTheme,
    required this.copyWithTap,
    required this.openSearchBarOnStartup,
    required this.clickToRevealCodes,
    required this.initialRoute,
  });

  OtpManagerState.initial(User? user, bool isLogged)
    : this(
        themeMode: user?.themeMode ?? ThemeMode.system,
        blackTheme: user?.blackTheme ?? false,
        copyWithTap: user?.copyWithTap ?? false,
        openSearchBarOnStartup: user?.openSearchBarOnStartup ?? false,
        clickToRevealCodes: user?.clickToRevealCodes ?? false,
        initialRoute: isLogged
            ? ((user?.password != null && user?.iv != null) ||
                          user?.isGuest == true) &&
                      (user?.passwordExpirationDate == null ||
                          DateTime.now().isBefore(
                            user!.passwordExpirationDate!,
                          ))
                  ? homeRoute
                  : authRoute
            : loginRoute,
      );

  OtpManagerState copyWith({
    ThemeMode? themeMode,
    bool? copyWithTap,
    bool? blackTheme,
    bool? openSearchBarOnStartup,
    bool? clickToRevealCodes,
  }) {
    return OtpManagerState(
      themeMode: themeMode ?? this.themeMode,
      blackTheme: blackTheme ?? this.blackTheme,
      copyWithTap: copyWithTap ?? this.copyWithTap,
      openSearchBarOnStartup:
          openSearchBarOnStartup ?? this.openSearchBarOnStartup,
      clickToRevealCodes: clickToRevealCodes ?? this.clickToRevealCodes,
      initialRoute: initialRoute,
    );
  }

  @override
  List<Object> get props => [
    themeMode,
    blackTheme,
    copyWithTap,
    openSearchBarOnStartup,
    clickToRevealCodes,
  ];
}
