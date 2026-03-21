import 'package:equatable/equatable.dart';
import 'package:otp_manager/bloc/recover_password/password_requirements_state.dart';

class RecoverPasswordState extends Equatable {
  final String newPassword;
  final String confirmPassword;
  final PasswordRequirementsState passwordRequirements;
  final String errorMsg;
  final int attempts;

  const RecoverPasswordState({
    required this.newPassword,
    required this.confirmPassword,
    required this.passwordRequirements,
    required this.errorMsg,
    required this.attempts,
  });

  const RecoverPasswordState.initial()
    : newPassword = '',
      confirmPassword = '',
      passwordRequirements = const PasswordRequirementsState.initial(),
      errorMsg = '',
      attempts = 3;

  RecoverPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    PasswordRequirementsState? passwordRequirements,
    String? errorMsg,
    int? attempts,
  }) {
    return RecoverPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordRequirements: passwordRequirements ?? this.passwordRequirements,
      errorMsg: errorMsg ?? this.errorMsg,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  List<Object> get props => [
    newPassword,
    confirmPassword,
    passwordRequirements,
    errorMsg,
    attempts,
  ];
}
