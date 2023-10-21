import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/otp_manager/otp_manager_bloc.dart';
import '../bloc/otp_manager/otp_manager_state.dart';

class AuthInput extends HookWidget {
  const AuthInput({
    Key? key,
    required this.onChanged,
    required this.onSubmit,
    required this.enabled,
    required this.errorMsg,
  }) : super(key: key);

  final Function(String) onChanged;
  final Function() onSubmit;
  final bool enabled;
  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    final passwordFocusNode = useFocusNode();
    final obscured = useState(true);

    void toggleObscured() {
      obscured.value = !obscured.value;
      if (passwordFocusNode.hasPrimaryFocus) {
        return; // If focus is on text field, dont unfocus
      }
      passwordFocusNode.canRequestFocus = false; // Prevents focus if tap on eye
    }

    return BlocBuilder<OtpManagerBloc, OtpManagerState>(
      builder: (context, state) {
        return TextField(
          enabled: enabled,
          onChanged: (value) => onChanged(value),
          keyboardType: TextInputType.visiblePassword,
          obscureText: obscured.value,
          focusNode: passwordFocusNode,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelText: "Password",
            filled: true,
            fillColor: state.darkTheme ? Colors.grey.shade800 : null,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: IconButton(
              onPressed: toggleObscured,
              icon: Icon(
                obscured.value ? Icons.visibility : Icons.visibility_off,
                color: errorMsg != "" ? Colors.red : Colors.blue,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: IconButton(
                onPressed: onSubmit,
                icon: Icon(
                  Icons.arrow_forward,
                  color: errorMsg != "" ? Colors.red : Colors.blue,
                ),
              ),
            ),
            errorText: errorMsg != "" ? errorMsg : null,
            errorMaxLines: 5
          ),
        );
      },
    );
  }
}
