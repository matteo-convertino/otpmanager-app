import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../routing/constants.dart';

class OtpManagerState extends Equatable {
  final bool darkTheme;
  final bool copyWithTap;
  final bool openSearchBarOnStartup;
  final bool clickToRevealCodes;
  final String initialRoute;

  const OtpManagerState({
    required this.darkTheme,
    required this.copyWithTap,
    required this.openSearchBarOnStartup,
    required this.clickToRevealCodes,
    required this.initialRoute,
  });

  OtpManagerState.initial(User? user, bool isLogged)
    : this(
        darkTheme: user?.darkTheme ?? false,
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
    bool? darkTheme,
    bool? copyWithTap,
    bool? openSearchBarOnStartup,
    bool? clickToRevealCodes,
  }) {
    return OtpManagerState(
      darkTheme: darkTheme ?? this.darkTheme,
      copyWithTap: copyWithTap ?? this.copyWithTap,
      openSearchBarOnStartup:
          openSearchBarOnStartup ?? this.openSearchBarOnStartup,
      clickToRevealCodes: clickToRevealCodes ?? this.clickToRevealCodes,
      initialRoute: initialRoute,
    );
  }

  @override
  List<Object> get props => [
    darkTheme,
    copyWithTap,
    openSearchBarOnStartup,
    clickToRevealCodes,
  ];
}
