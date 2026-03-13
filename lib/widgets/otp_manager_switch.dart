import 'package:flutter/material.dart';

class OtpManagerSwitch extends StatelessWidget {
  const OtpManagerSwitch({
    super.key,
    required this.iconSelected,
    required this.iconAny,
    required this.onChanged,
    required this.value,
  });

  final Icon? iconSelected;
  final Icon? iconAny;
  final void Function(bool)? onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbIcon: iconSelected == null || iconAny == null
          ? null
          : WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
              WidgetState.selected: iconSelected!,
              WidgetState.any: iconAny!,
            }),
      value: value,
      onChanged: onChanged,
    );
  }
}
