import 'package:flutter/material.dart';

class OtpManagerSlidableAction extends StatelessWidget {
  const OtpManagerSlidableAction({
    super.key,
    required this.label,
    required this.icon,
    required this.padding,
    required this.backgroundColor,
    required this.border,
    this.iconColor = Colors.white,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BorderRadiusGeometry border;
  final Color iconColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox.expand(
        child: Padding(
          padding: padding,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: border),
              side: BorderSide.none,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
