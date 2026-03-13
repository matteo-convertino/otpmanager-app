import 'package:flutter/material.dart';

class OtpManagerSlidableAction extends StatelessWidget {
  const OtpManagerSlidableAction({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.padding = const EdgeInsets.only(top: 10, bottom: 10, right: 10),
    this.borderRadius = 10.0,
    this.border = BorderSide.none,
  });

  final String label;
  final Icon icon;
  final Color backgroundColor;
  final Function() onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final BorderSide border;

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              side: border,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 20),
                  child: icon,
                ),
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
