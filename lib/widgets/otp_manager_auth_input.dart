import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../bloc/otp_manager/otp_manager_bloc.dart';
import '../bloc/otp_manager/otp_manager_state.dart';

class OtpManagerAuthInput extends HookWidget {
  const OtpManagerAuthInput({
    super.key,
    required this.onChanged,
    required this.onSubmit,
    required this.enabled,
    required this.errorMsg,
    required this.label,
    this.helper,
  });

  final Function(String) onChanged;
  final Function() onSubmit;
  final bool enabled;
  final String errorMsg;
  final String label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final passwordFocusNode = useFocusNode();
    final obscured = useState(true);

    void toggleObscured() {
      obscured.value = !obscured.value;
      if (passwordFocusNode.hasPrimaryFocus) {
        return; // If focus is on text field, don't unfocus
      }
      passwordFocusNode.canRequestFocus = false; // Prevents focus if tap on eye
    }

    return BlocBuilder<OtpManagerBloc, OtpManagerState>(
      builder: (context, state) {
        return TextField(
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: TextInputType.visiblePassword,
          obscureText: obscured.value,
          focusNode: passwordFocusNode,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelText: label,
            helperText: helper,
            filled: true,
            fillColor: state.darkTheme ? Colors.grey.shade800 : null,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: IconButton(
              onPressed: toggleObscured,
              icon: PhosphorIcon(
                obscured.value
                    ? PhosphorIconsRegular.eye
                    : PhosphorIconsRegular.eyeSlash,
                color: errorMsg.isNotEmpty
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: IconButton(
                onPressed: onSubmit,
                icon: PhosphorIcon(
                  PhosphorIconsRegular.arrowRight,
                  color: errorMsg.isNotEmpty
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            errorText: errorMsg.isNotEmpty ? errorMsg : null,
            errorMaxLines: 5,
          ),
        );
      },
    );
  }
}
