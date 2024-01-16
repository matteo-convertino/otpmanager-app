import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../routing/constants.dart';

class OtpManagerState extends Equatable {
  final bool darkTheme;
  final bool copyWithTap;
  final String initialRoute;

  const OtpManagerState({
    required this.darkTheme,
    required this.copyWithTap,
    required this.initialRoute,
  });

  OtpManagerState.initial(
    User? user,
    bool isLogged,
  ) : this(
          darkTheme: user?.darkTheme ?? false,
          copyWithTap: user?.copyWithTap ?? false,
          initialRoute: isLogged
              ? (user?.password != null &&
                      user?.iv != null &&
                      (user?.passwordExpirationDate == null ||
                          DateTime.now()
                              .isBefore(user!.passwordExpirationDate!))
                  ? homeRoute
                  : authRoute)
              : loginRoute,
        );

  OtpManagerState copyWith({bool? darkTheme, bool? copyWithTap}) {
    return OtpManagerState(
      darkTheme: darkTheme ?? this.darkTheme,
      copyWithTap: copyWithTap ?? this.copyWithTap,
      initialRoute: initialRoute,
    );
  }

  @override
  List<Object> get props => [darkTheme, copyWithTap];
}
