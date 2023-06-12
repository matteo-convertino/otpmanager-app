import 'package:equatable/equatable.dart';

class OtpManagerState extends Equatable {
  final bool darkTheme;
  final bool copyWithTap;
  final String initialRoute;

  const OtpManagerState({
    required this.darkTheme,
    required this.copyWithTap,
    required this.initialRoute,
  });

  const OtpManagerState.initial(
    this.darkTheme,
    this.copyWithTap,
    this.initialRoute,
  );

  OtpManagerState copyWith({bool? darkTheme, bool? copyWithTap}) {
    return OtpManagerState(
      darkTheme: darkTheme ?? this.darkTheme,
      copyWithTap: copyWithTap ?? this.copyWithTap,
      initialRoute: initialRoute,
    );
  }

  @override
  List<Object> get props => [darkTheme, copyWithTap, initialRoute];
}
